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
import { ApiError, ContentListUnion, GoogleGenAI } from "@google/genai";
import { BadRequestException, Injectable, InternalServerErrorException } from "@nestjs/common";
import { randomBytes } from "crypto";
import { formatDate, subDays } from "date-fns";
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
            idMap.forEach((genericId, realName) => (aiText = aiText.replaceAll(genericId, realName)));
            chat.text = aiText;
            return response;
          } catch (e: any) {
            // Check if the error object itself contains a message string that looks like JSON
            if (e?.message)
              // Attempt to parse the message string in case it's a JSON-encoded ApiError
              throw JSON.parse(e.message)?.error as ApiError;

            // Fallback: handle cases where the error follows the structure e.error.message
            const err = e?.error as ApiError | undefined;
            if (err?.message) throw err.message;

            throw e;
          } finally {
            // Update the chat with the response
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
  async buildPrompt(user: User) {
    await this.cleanupUserMax(user);
    const rawHistory = await ChatHistory.find({ where: { user: { id: user.id } }, order: { time: "ASC" } });

    const idMap = new Map<string, string>();
    const data = await this.buildUserAccountDetails(user, idMap);
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
              4. Refer to accounts strictly by the provided IDs (e.g., Account_0).
              5. Consider smart finance habits. Reduce unnecessary spending, keep a rainy day fund, invest excess.
              6. Context Data Key Mapping:
                 - Accounts: i=ID, t=Type, s=SubType, b=Balance, r=InterestRate
                 - Holdings: hol (s=Symbol, v=Value)
                 - History: his (b=Balance, d=Date)
                 - Transactions: d=Date, n=Description ID, a=Amount, c=Category, acc=Account ID
              7. MANDATORY ENTITY FORMATTING:
                - User references will be in the format '@ID'.
                - You MUST respond using that exact '@ID' format.
                - CRITICAL: Never strip the '@' prefix. If you write the ID without the '@' prefix, the user's interface will break.
                - Example Correct: "Analysis for @Account_0"
                - Example Incorrect: "Analysis for Account_0"
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
  private async buildUserAccountDetails(user: User, idMap: Map<string, string>) {
    const historicalTimeFrame = subDays(new Date(), 90);
    const accounts = Account.convertListToTargetCurrency(Utility.shuffleArray(await Account.find({ where: { user: { id: user.id } } })), user);
    const transactions = Transaction.convertListToTargetCurrency(
      await Transaction.find({
        where: { account: { user: { id: user.id } }, posted: MoreThan(historicalTimeFrame) },
        order: { posted: "DESC" },
        relations: ["category"],
      }),
      user,
    );

    // Process accounts with their holdings and history snapshots
    const accountData = await Promise.all(
      accounts.map(async (acc) => {
        const genericId = `Account_${randomBytes(2).toString("hex")}`;
        idMap.set(acc.id, genericId);

        const holdings = Holding.convertListToTargetCurrency(await Holding.find({ where: { account: { id: acc.id } } }), user);
        const history = AccountHistory.convertListToTargetCurrency(
          await AccountHistory.find({
            where: { account: { id: acc.id }, time: MoreThan(historicalTimeFrame) },
            order: { time: "DESC" },
            take: 10, // Limit snapshots for token efficiency
          }),
          user,
        );

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
        idMap.set(t.id, genericDescriptionId);
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
  private formatCleanHistory(history: ChatHistory[], idMap: Map<string, string>) {
    const formatted: { role: string; parts: Array<{ text: string }> }[] = [];

    for (const msg of history) {
      let text = msg.text.trim();

      // Skip failed model responses or pure error noise
      if (msg.role === "model" && (text === "" || text.includes("Refresh if the problem persists") || text.includes(ChatHistory.DEFAULT_MODEL_TEXT))) continue;
      // Scrub the "Code: 429" hallucination prefix from valid responses
      if (msg.role === "model") text = text.replace(/^\(Code: 429\)\s*/i, "");
      // Double check after scrubbing that we still have text
      if (text === "") continue;

      if (idMap) text = msg.deIdentifyText(idMap);

      // Ensure role alternation (AI requirement: user -> model -> user)
      // If the last added message has the same role as the current one, replace it.
      if (formatted.length > 0 && formatted[formatted.length - 1]?.role === msg.role) formatted[formatted.length - 1]!.parts = [{ text }];
      else
        formatted.push({
          role: msg.role === "user" ? "user" : "model",
          parts: [{ text }],
        });
    }

    return formatted;
  }
}
