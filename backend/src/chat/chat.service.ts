import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { ChatTimeframe } from "@backend/chat/model/api/chat.request.dto";
import { ChatHistory } from "@backend/chat/model/chat.history.model";
import { Configuration } from "@backend/config/core";
import { Utility } from "@backend/core/model/utility/utility";
import { Holding } from "@backend/holding/model/holding.model";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { ApiError, ContentListUnion, GoogleGenAI } from "@google/genai";
import { BadRequestException, Injectable, InternalServerErrorException } from "@nestjs/common";
import { formatDate, subDays, subMonths, subYears } from "date-fns";
import { MoreThan } from "typeorm";

/** A service that provides reusable functions to LLM prompting capabilities */
@Injectable()
export class ChatService {
  constructor(private readonly sseService: SSEService) {}

  /** Gets the model for the given users LLM configuration */
  async getModel(user: User) {
    if (Configuration.server.prompt.type === "gemini") {
      // Find API key
      const apiKey = Configuration.server.prompt.gemini.key ?? user.config.geminiKey;
      if (!apiKey) throw new BadRequestException("No API key configured. Please set an API key in settings");

      // Load the model based on the key
      const model = new GoogleGenAI({ apiKey }).models;
      return {
        type: Configuration.server.prompt.gemini.model,
        /**
         * Counts the number of input tokens for a given context before sending.
         * @param contents The full payload of system instructions & message context.
         */
        countTokens: async (contents: ContentListUnion) => {
          try {
            const result = await model.countTokens({
              model: Configuration.server.prompt.gemini.model,
              contents,
            });
            return result.totalTokens ?? 0;
          } catch (e) {
            return 0;
          }
        },
        /**
         * Generates the content based on the model as configured by the backend. The
         *  contents provide the context for the prompt.
         * @param chat The initial chat that should be inserted prior to call so the frontend recognizes it's thinking.
         */
        generateContent: async (contents: ContentListUnion, chat: ChatHistory, idMap: Map<string, string>) => {
          try {
            const response = await model.generateContent({ model: Configuration.server.prompt.gemini.model, contents });
            let aiText = response.text ?? "";
            // Convert generic IDs back to real names for the user
            const sortedEntries = Array.from(idMap.entries()).sort((a, b) => b[1].length - a[1].length);
            for (const [realName, genericId] of sortedEntries) aiText = aiText.replaceAll(genericId, realName);
            chat.text = aiText;
            return response;
          } catch (e: any) {
            // Check if the error object itself contains a message string that looks like JSON
            if (e?.message) throw JSON.parse(e.message)?.error as ApiError;
            const err = e?.error as ApiError | undefined;
            if (err?.message) throw err.message;

            throw e;
          } finally {
            chat.isThinking = false;
            await chat.update();
            this.sseService.sendToUser(user, SSEEventType.CHAT, chat);
          }
        },
      };
    } else {
      // For future use of more models. For now just throw an exception
      throw new InternalServerErrorException("Invalid LLM model configured");
    }
  }

  /** Generates the system instruction and prompt content to pass to the LLM. */
  async buildPrompt(user: User, timeframe: ChatTimeframe) {
    await this.cleanupUserMax(user);
    const rawHistory = await ChatHistory.find({ where: { user: { id: user.id } }, order: { time: "ASC" } });

    const idMap = new Map<string, string>();
    const data = await this.buildUserAccountDetails(user, timeframe, idMap);
    const sanitizedHistory = this.formatCleanHistory(rawHistory, idMap);

    return {
      idMap,
      contents: [
        {
          role: "user",
          parts: [
            {
              text: `SYSTEM INSTRUCTIONS:
              1. You are a financial assistant for Sprout (https://sprout.croudebush.net/).
              2. ONLY answer the specific question asked by the user. Do not provide extra summaries or net worth trends unless requested. Keep responses always related to finances.
              3. Be concise. Avoid conversational filler.
              4. Refer to accounts strictly by the provided IDs (e.g., Acc_0).
              5. Consider smart finance habits. Reduce unnecessary spending, keep a rainy day fund, invest excess.
              6. Context Data Key Mapping:
                 - Accounts: i=ID, t=Type, s=SubType, b=Balance, r=InterestRate, hol=Holdings (CSV Symbol:Value), his=History (CSV Date:Balance)
                 - Transactions are pipe-delimited: Date|DescriptionID|Amount|Category|AccountID
              7. MANDATORY ENTITY FORMATTING:
                - User references will be in the format '@ID'.
                - You MUST respond using that exact '@ID' format.
                - CRITICAL: Never strip the '@' prefix. If you write the ID without the '@' prefix, the user's interface will break.
                - Example Correct: "Analysis for @Acc_0"
                - Example Incorrect: "Analysis for Acc_0"
                - Do not guess names; only use the @ID provided in the mapping.
              8. The users chosen currency is: ${user.config.currency}. All values will be in this currency already. Please make sure to use the proper currency symbol leading the numbers.
              9. Always include: "Consult a financial advisor before making decisions."
              
              CONTEXTUAL DATA:
              ${JSON.stringify(data)}`,
            },
          ],
        },
        ...sanitizedHistory,
      ],
    };
  }

  /**
   * Builds a set of account details for the LLM to know their current finance
   *  state. De-identifies all data by using generic ID's for transaction
   *  descriptions and account names.
   */
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
    let accIndex = 0;

    // Determine if we need to down-sample the history for > 3 months (6m, 1y)
    const isExtendedTimeframe = timeframe === ChatTimeframe.sixMonths || timeframe === ChatTimeframe.oneYear;

    // Process accounts with their holdings and history snapshots
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

        // Token Efficiency: Down-sample history by extracting only the latest snapshot per month
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
          // Collapse JSON objects into compact CSV strings
          hol: holdings.map((h) => `${h.symbol}:${Number(h.marketValue).toFixed(2)}`).join(","),
          his: history.map((h) => `${formatDate(h.time, "MM/dd")}:${Number(h.balance).toFixed(0)}`).join(","),
        };
      }),
    );

    let txIndex = 0;
    const compactTransactions = transactions.map((t) => {
      const genericDescriptionId = `T_${txIndex++}`;
      idMap.set(t.id, genericDescriptionId);

      const accId = idMap.get(t.account.name) || "?";
      const cat = t.category?.name || "Uncategorized";
      const amt = Number(t.amount).toFixed(2);
      const date = formatDate(t.posted, "MM/dd/yy");
      return `${date}|${genericDescriptionId}|${amt}|${cat}|${accId}`;
    });

    return {
      accounts: accountData,
      transactions: compactTransactions,
    };
  }

  /** Cleans up the number of charts this user can have so they don't have too many in the db causing too large of a context */
  private async cleanupUserMax(user: User) {
    const max = Configuration.server.prompt.maxChatHistory;
    const history = await ChatHistory.find({
      where: { user: { id: user.id } },
      order: { time: "DESC" },
    });
    if (history.length > max) await ChatHistory.deleteMany(history.slice(max).map((n) => n.id));
  }

  /**
   * Cleans and formats chat history to prevent context poisoning and
   * ensures strict user/model alternation.
   */
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

  /** Based on the given time frame, returns the date that should correspond to that timeframe from now. */
  private getTimeframeDate(timeframe: ChatTimeframe) {
    let historicalTimeFrame: Date | null = null;
    const now = new Date();
    switch (timeframe) {
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
