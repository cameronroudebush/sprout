import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { ChatTimeframe } from "@backend/chat/model/api/chat.request.dto";
import { ChatHistory } from "@backend/chat/model/chat.history.model";
import { Configuration } from "@backend/config/core";
import { Utility } from "@backend/core/model/utility/utility";
import { Holding } from "@backend/holding/model/holding.model";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { TransactionService } from "@backend/transaction/transaction.service";
import { User } from "@backend/user/model/user.model";
import { Injectable } from "@nestjs/common";
import { formatDate, subDays, subMonths, subYears } from "date-fns";
import { MoreThan } from "typeorm";

/** A service focused entirely around generating prompts for various capabilities */
@Injectable()
export class ChatPromptService {
  constructor(private readonly transactionService: TransactionService) {}

  /** Generates the system instruction and prompt content to pass to the LLM for standard chatting. */
  async buildChatPrompt(user: User, timeframe: ChatTimeframe, allowCharts: boolean) {
    const instructions = [
      ...this.getSharedSystemInstructions(user, true, allowCharts),
      `ONLY answer the specific question asked by the user. Do not provide extra summaries or net worth trends unless requested. Keep responses always related to finances.`,
      `Consider smart finance habits. Reduce unnecessary spending, keep a rainy day fund, invest excess.`,
    ];

    return this.createPromptPayload(user, timeframe, instructions);
  }

  /** Generates a prompt tailored for a brief 24-hour daily overview of the user's financial activity. */
  async buildDailyOverviewPrompt(user: User) {
    const instructions = [
      ...this.getSharedSystemInstructions(user, false),
      `Write a warm, natural daily financial summary over the last 24 hours.`,
      `FORMAT REQUIREMENTS:`,
      `1. Start with a 1-sentence quick takeaway (e.g., "Your checking account saw some downward movement today primarily driven by weekend spending.").`,
      `2. Follow with short key bullet points for accounts with notable activity. State the direction of the change and summarize the *reason* based on transaction categories or descriptions (e.g., "Checking decreased slightly, mostly due to dining out and groceries" or "Credit card balance went up following a travel purchase").`,
      `3. End with a 1-sentence reassuring context note (e.g., "Overall, just normal day-to-day spending.").`,
      `4. DO NOT include ANY specific numbers, dollar amounts, percentages, or balances in your response. Focus entirely on the narrative, the direction of the changes, and the spending categories.`,
    ];

    return this.createPromptPayload(user, ChatTimeframe.oneDay, instructions, false);
  }

  /** Builds prompt payload focused specifically on investment accounts & market holdings. */
  async buildHoldingsOverviewPrompt(user: User) {
    const instructions = [
      ...this.getSharedSystemInstructions(user, false),
      `Write a sharp, analytical portfolio update focusing on *performance attribution* and *asset interaction* over the last few days.`,
      `FORMAT REQUIREMENTS:`,
      `1. Start with a 1-sentence bottom line identifying the single biggest driver of the portfolio's performance (e.g., "Despite a flat overall market, volatility in your crypto holdings dragged down your net performance today.").`,
      `2. Focus on Disproportionate Impact: Point out if a smaller, volatile holding (like NVDA or Crypto) drove the majority of the portfolio's movement compared to larger, stable index funds.`,
      `3. Highlight Correlations & Hedges: Explain how different parts of the portfolio interacted (e.g., "Gains in your tech-heavy FBGRX offset the minor losses in your international VXUS holdings.").`,
      `4. DO NOT write generic descriptions of what the funds do (e.g., DO NOT say "VTI tracked the market").`,
      `5. DO NOT list exact dollar balances or minor daily percentage changes. You MAY use proportions or relative terms to explain impact (e.g., "accounted for almost all of today's dip" or "dominated the portfolio's movement").`,
    ];

    return this.createPromptPayload(user, ChatTimeframe.oneDay, instructions, false);
  }

  /**
   * Provides foundational system instructions common to all financial prompts.
   *
   * @param includeCYA Include "cover your ass" which is intended to include the statement recommending consulting a professional.
   * @param allowCharts If we should allow the LLM to generate charts for rendering. False by default.
   */
  private getSharedSystemInstructions(user: User, includeCYA: boolean = true, allowCharts = false): string[] {
    const today = formatDate(new Date(), "MM/dd/yyyy");
    return [
      `You are a financial assistant for Sprout (https://sprout.croudebush.net/).`,
      `Today's date is: ${today}. Use this to determine if bills or subscriptions are upcoming or overdue.`,
      `Be concise. Avoid conversational filler.`,
      `Refer to accounts strictly by the provided IDs (e.g., Acc_0).`,
      `Context Data Key Mapping:
         - Accounts: i=ID, t=Type, s=SubType, b=Balance, r=InterestRate, hol=Holdings (CSV Symbol:Value), his=History (CSV Date:Balance)
         - Transactions are pipe-delimited: Date|DescriptionID|Amount|Category|AccountID
         - Subscriptions are pipe-delimited: DescriptionID|AvgAmount|Period|LastPaidDate|AccountID`,
      `MANDATORY ENTITY FORMATTING:
        - User references will be in the format '@ID'.
        - You MUST respond using that exact '@ID' format.
        - CRITICAL: Never strip the '@' prefix. If you write the ID without the '@' prefix, the user's interface will break.
        - Example Correct: "Analysis for @Acc_0"
        - Example Incorrect: "Analysis for Acc_0"
        - Do not guess names; only use the @ID provided in the mapping.`,
      `The users chosen currency is: ${user.config.currency}. All values will be in this currency already. Please make sure to use the proper currency symbol leading the numbers.`,
      allowCharts
        ? `CHART GENERATION:
          - VISUALIZATION GUIDELINE: You may include a chart whenever visualizing trends, category breakdowns, or historical patterns adds useful context. Maximum ONE chart per response.
          - Output charts in these exact formats when visualizing financial data:
            1. Line (Trends/History over time):
            \`\`\`chart
            {"type":"line","title":"Account Balance Trends","series":[{"label":"@Acc_0","data":[{"date":"08/01/2026","value":1500.50}]}]}
            \`\`\`
            2. Pie (Breakdowns/Portions/Categories):
            \`\`\`chart
            {"type":"pie","title":"Spending Breakdown","data":{"Dining":150.25,"Groceries":420.00}}
            \`\`\`
          - Allowed types: "line", "pie".
          - Date format for line charts: "MM/dd/yyyy".
          - Plain text only for "title", "label", and data keys (no markdown or asterisks).
          - Map line chart "data" directly from the provided "his" context array.`
        : `If the user asks for a chart or visual breakdown, politely inform them that chart generation is currently disabled/unavailable and present the financial insights cleanly using Markdown text, bullet points, or tables instead.`,
      includeCYA ? `Always include: "Consult a financial advisor before making decisions."` : "",
    ];
  }

  /** Assembles context, sanitizes chat history, and returns ready prompt contents. */
  private async createPromptPayload(user: User, timeframe: ChatTimeframe, instructions: string[], includeChatHistory = true) {
    await this.cleanupUserMax(user);

    const idMap = new Map<string, string>();
    const data = await this.buildUserAccountDetails(user, timeframe, idMap);

    let sanitizedHistory: { role: string; parts: Array<{ text: string }> }[] = [];
    if (includeChatHistory) {
      const rawHistory = await ChatHistory.find({ where: { user: { id: user.id } }, order: { time: "ASC" } });
      sanitizedHistory = this.formatCleanHistory(rawHistory, idMap);
    }

    const formattedInstructions = instructions.map((inst, index) => `${index + 1}. ${inst}`).join("\n              ");

    return {
      idMap,
      contents: [
        {
          role: "user",
          parts: [
            {
              text: `SYSTEM INSTRUCTIONS:
              ${formattedInstructions}
              
              CONTEXTUAL DATA:
              ${JSON.stringify(data)}`,
            },
          ],
        },
        ...sanitizedHistory,
      ],
    };
  }

  /** Fetches contextual financial data and generates generic ID maps for privacy. */
  private async buildUserAccountDetails(user: User, timeframe: ChatTimeframe, idMap: Map<string, string>) {
    const historicalTimeFrame = this.getTimeframeDate(timeframe);
    const accounts = Account.convertListToTargetCurrency(Utility.shuffleArray(await Account.find({ where: { user: { id: user.id } } })), user);
    const transactions = Transaction.convertListToTargetCurrency(
      await Transaction.find({
        where: { account: { user: { id: user.id } }, posted: MoreThan(historicalTimeFrame) },
        order: { posted: "DESC" },
        relations: { category: true },
      }),
      user,
    );
    const subscriptions = await this.transactionService.findSubscriptions(user);

    let accIndex = 0;
    const isExtendedTimeframe = timeframe === ChatTimeframe.sixMonths || timeframe === ChatTimeframe.oneYear;

    const accountData = await Promise.all(
      accounts.map(async (acc) => {
        const genericId = `Acc_${accIndex++}`;
        idMap.set(acc.id, genericId);

        const holdings = Holding.convertListToTargetCurrency(await Holding.find({ where: { account: { id: acc.id } } }), user);

        let history = AccountHistory.convertListToTargetCurrency(
          await AccountHistory.find({
            where: { account: { id: acc.id }, time: MoreThan(historicalTimeFrame) },
            order: { time: "DESC" },
          }),
          user,
        );

        if (isExtendedTimeframe) {
          const seenMonths = new Set<string>();
          history = history.filter((h) => {
            const monthKey = formatDate(h.time, "yyyy-MM");
            if (seenMonths.has(monthKey)) return false;
            seenMonths.add(monthKey);
            return true;
          });
        }

        return {
          i: genericId,
          t: acc.type,
          s: acc.subType,
          b: Number(acc.balance).toFixed(2),
          r: acc.interestRate,
          hol: holdings.map((h) => `${h.symbol}:${Number(h.marketValue).toFixed(2)}`).join(","),
          his: history.map((h) => `${formatDate(h.time, "MM/dd")}:${Number(h.balance).toFixed(0)}`).join(","),
        };
      }),
    );

    let txIndex = 0;
    const compactTransactions = transactions.map((t) => {
      const genericDescriptionId = `T_${txIndex++}`;
      idMap.set(t.id, genericDescriptionId);

      const accId = idMap.get(t.account.id) || idMap.get(t.account.name) || "?";
      const cat = t.category?.name || "Uncategorized";
      const amt = Number(t.amount).toFixed(2);
      const date = formatDate(t.posted, "MM/dd/yy");
      return `${date}|${genericDescriptionId}|${amt}|${cat}|${accId}`;
    });

    let subIndex = 0;
    const compactSubscriptions = subscriptions.map((s) => {
      const genericDescriptionId = `Sub_${subIndex++}`;
      idMap.set(s.description || s.transaction.id, genericDescriptionId);

      const accId = idMap.get(s.account.id) || idMap.get(s.account.name) || "?";
      const amt = Number((s as any).averageAmount || (s as any).amount || 0).toFixed(2);
      const lastDate = formatDate(s.transaction.posted, "MM/dd/yy");
      return `${genericDescriptionId}|${amt}|${s.period}|${lastDate}|${accId}`;
    });

    return {
      accounts: accountData,
      transactions: compactTransactions,
      subscriptions: compactSubscriptions,
    };
  }

  /** Truncates old chat history according to configured threshold. */
  private async cleanupUserMax(user: User) {
    const max = Configuration.server.prompt.maxChatHistory;
    const history = await ChatHistory.find({
      where: { user: { id: user.id } },
      order: { time: "DESC" },
    });
    if (history.length > max) await ChatHistory.deleteMany(history.slice(max).map((n) => n.id));
  }

  /** Cleans chat messages for LLM context payload. */
  private formatCleanHistory(history: ChatHistory[], idMap: Map<string, string>) {
    const formatted: { role: string; parts: Array<{ text: string }> }[] = [];

    for (const msg of history) {
      let text = msg.text.trim();
      if (msg.role === "model" && (text === "" || text.includes("Refresh if the problem persists") || text.includes(ChatHistory.DEFAULT_MODEL_TEXT))) continue;
      if (msg.role === "model") text = text.replace(/^\(Code: 429\)\s*/i, "");
      if (text === "") continue;
      if (idMap) text = msg.deIdentifyText(idMap);
      if (formatted.length > 0 && formatted[formatted.length - 1]?.role === msg.role) formatted[formatted.length - 1]!.parts = [{ text }];
      else
        formatted.push({
          role: msg.role === "user" ? "user" : "model",
          parts: [{ text }],
        });
    }

    return formatted;
  }

  /** Computes starting threshold date based on requested timeframe. */
  private getTimeframeDate(timeframe: ChatTimeframe) {
    let historicalTimeFrame: Date | null = null;
    const now = new Date();
    switch (timeframe) {
      case ChatTimeframe.oneDay:
        historicalTimeFrame = subDays(now, 2);
        break;
      case ChatTimeframe.sixMonths:
        historicalTimeFrame = subMonths(now, 6);
        break;
      case ChatTimeframe.oneYear:
        historicalTimeFrame = subYears(now, 1);
        break;
      case ChatTimeframe.threeMonths:
      default:
        historicalTimeFrame = subDays(now, 90);
        break;
    }
    return historicalTimeFrame;
  }
}
