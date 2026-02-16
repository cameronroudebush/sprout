import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { ChatHistory } from "@backend/chat/model/chat.history.model";
import { Configuration } from "@backend/config/core";
import { Utility } from "@backend/core/model/utility/utility";
import { Holding } from "@backend/holding/model/holding.model";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { ContentListUnion, GoogleGenAI } from "@google/genai";
import { BadRequestException, Injectable } from "@nestjs/common";
import { randomBytes } from "crypto";
import { formatDate, subDays } from "date-fns";
import { MoreThan } from "typeorm";

/** A service that provides reusable functions to LLM prompting capabilities */
@Injectable()
export class ChatService {
  constructor(private readonly sseService: SSEService) {}

  /** Gets the model for the given users LLM configuration */
  async getModel(user: User) {
    if (user.config.geminiKey == null) throw new BadRequestException("No API key configured. Please set an API key in settings");
    const model = new GoogleGenAI({ apiKey: user.config.geminiKey }).models;
    return {
      /**
       * Generates the content based on the model as configured by the backend. The
       *  contents provide the context for the prompt.
       * @param chat The initial chat that should be inserted prior to call so the frontend recognizes it's thinking.
       */
      generateContent: async (contents: ContentListUnion, chat: ChatHistory, idMap: Map<string, string>) => {
        try {
          const response = await model.generateContent({ model: Configuration.server.prompt.geminiModel, contents });
          let aiText = response.text ?? "";
          // Convert generic IDs back to real names for the user
          idMap.forEach((genericId, realName) => (aiText = aiText.replaceAll(genericId, realName)));
          chat.text = aiText;
          return response;
        } catch (e) {
          throw e;
        } finally {
          // Update the chat with the response
          chat.isThinking = false;
          await chat.update();
          this.sseService.sendToUser(user, SSEEventType.CHAT, chat);
        }
      },
    };
  }

  /** Generates the system instruction and prompt content to pass to the LLM. */
  async buildPrompt(user: User) {
    await this.cleanupUserMax(user);
    const rawHistory = await ChatHistory.find({ where: { user: { id: user.id } }, order: { time: "ASC" } });
    const sanitizedHistory = this.formatCleanHistory(rawHistory);

    const idMap = new Map<string, string>();
    const data = await this.buildUserAccountDetails(user, idMap);

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
              4. Refer to accounts strictly by the provided IDs (e.g., Account_0).
              5. Consider smart finance habits. Reduce unnecessary spending, keep a rainy day fund, invest excess.
              6. Context Data Key Mapping:
                 - Accounts: i=ID, t=Type, s=SubType, b=Balance, r=InterestRate
                 - Holdings: hol (s=Symbol, v=Value)
                 - History: his (b=Balance, d=Date)
                 - Transactions: d=Date, n=Description ID, a=Amount, c=Category, acc=Account ID
              7. Always include: "Consult a financial advisor before making decisions."
              
              CONTEXTUAL DATA:
              ${JSON.stringify(data)}`,
            },
          ],
        },
        ...sanitizedHistory,
      ],
    };
  }

  /** Builds a set of account details for the LLM to know their current finance state */
  private async buildUserAccountDetails(user: User, idMap: Map<string, string>) {
    const historicalTimeFrame = subDays(new Date(), 90);
    const accounts = Utility.shuffleArray(await Account.find({ where: { user: { id: user.id } } }));
    const transactions = await Transaction.find({
      where: { account: { user: { id: user.id } }, posted: MoreThan(historicalTimeFrame) },
      order: { posted: "DESC" },
      relations: ["category"],
    });

    // Process accounts with their holdings and history snapshots
    const accountData = await Promise.all(
      accounts.map(async (acc) => {
        const genericId = `Account_${randomBytes(2).toString("hex")}`;
        idMap.set(acc.name, genericId);

        const holdings = await Holding.find({ where: { account: { id: acc.id } } });
        const history = await AccountHistory.find({
          where: { account: { id: acc.id }, time: MoreThan(historicalTimeFrame) },
          order: { time: "DESC" },
          take: 10, // Limit snapshots for token efficiency
        });

        return {
          i: genericId,
          t: acc.type,
          s: acc.subType,
          b: acc.balance,
          r: acc.interestRate,
          hol: holdings.map((h) => ({ s: h.symbol, v: h.marketValue })),
          his: history.map((h) => ({ b: h.balance, d: formatDate(h.time, "P") })),
        };
      }),
    );

    return {
      accounts: accountData,
      transactions: transactions.map((t) => {
        const genericDescriptionId = `desc_${randomBytes(2).toString("hex")}`;
        idMap.set(t.description, genericDescriptionId);
        return { d: formatDate(t.posted, "P"), n: genericDescriptionId, a: t.amount, c: t.category?.name, acc: idMap.get(t.account.name) };
      }),
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
  private formatCleanHistory(history: ChatHistory[]): any[] {
    const formatted: any[] = [];

    for (const msg of history) {
      let text = msg.text.trim();

      // Skip failed model responses or pure error noise
      if (msg.role === "model" && (text === "" || text.includes("Refresh if the problem persists") || text.includes(ChatHistory.DEFAULT_MODEL_TEXT))) continue;
      // Scrub the "Code: 429" hallucination prefix from valid responses
      if (msg.role === "model") text = text.replace(/^\(Code: 429\)\s*/i, "");
      // Double check after scrubbing that we still have text
      if (text === "") continue;

      // Ensure role alternation (Gemini requirement: user -> model -> user)
      // If the last added message has the same role as the current one, replace it.
      if (formatted.length > 0 && formatted[formatted.length - 1].role === msg.role) formatted[formatted.length - 1].parts = [{ text }];
      else
        formatted.push({
          role: msg.role === "user" ? "user" : "model",
          parts: [{ text }],
        });
    }

    return formatted;
  }
}
