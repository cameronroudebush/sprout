import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { ChatHistory } from "@backend/chat/model/chat.history.model";
import { Configuration } from "@backend/config/core";
import { Holding } from "@backend/holding/model/holding.model";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";
import { ContentListUnion, GoogleGenAI } from "@google/genai";
import { BadRequestException, Injectable } from "@nestjs/common";
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
      generateContent: async (contents: ContentListUnion, chat: ChatHistory) => {
        try {
          const response = await model.generateContent({ model: Configuration.server.prompt.geminiModel, contents });
          chat.text = response.text ?? "";
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

  /**
   * Generates the system instruction and prompt content to pass to the LLM.
   */
  async buildPrompt(user: User) {
    // Clean up to the maximum number of messages
    await this.cleanupUserMax(user);
    // Grab the entire history to add
    const history = await ChatHistory.find({ where: { user: { id: user.id } }, order: { time: "ASC" } });
    return [
      {
        role: "user",
        parts: [
          {
            text:
              `You are a financial assistant for Sprout which can be found at https://sprout.croudebush.net/.` +
              `Note that this sprout is an open source app, do not try and suggest any other links to a sprout service besides the given url.` +
              `Use this data: ${JSON.stringify(await this.buildUserAccountDetails(user))}. ` +
              `Help the user understand their spending and net worth. You may give ideas but you should always recommend consulting a financial advisor.`,
          },
        ],
      },
      // Add all history
      ...history.map((x) => ({ role: x.role, parts: [{ text: x.text }] })),
    ];
  }

  /** Builds a set of account details for the LLM to know their current finance state */
  private async buildUserAccountDetails(user: User) {
    /** How far of data back to include */
    const historicalTimeFrame = subDays(new Date(), 90);

    const accounts = await Account.find({ where: { user: { id: user.id } } });
    const transactions = await Transaction.find({
      where: { account: { user: { id: user.id } }, posted: MoreThan(historicalTimeFrame) },
      order: { posted: "DESC" },
      relations: ["category"],
    });

    // Process accounts with their holdings and history snapshots
    const accountData = await Promise.all(
      accounts.map(async (acc) => {
        const holdings = await Holding.find({ where: { account: { id: acc.id } } });

        // Get history but only take a few recent snapshots to save space
        const history = await AccountHistory.find({
          where: { account: { id: acc.id }, time: MoreThan(historicalTimeFrame) },
          order: { time: "DESC" },
        });

        return {
          name: acc.name,
          type: acc.type,
          bal: acc.balance,
          // Slim holdings: just the asset and value
          holdings: holdings.map((h) => ({ sym: h.symbol, val: h.marketValue, basis: h.costBasis })),
          // Slim history: just the balance and date
          history: history.map((h) => ({ b: h.balance, d: formatDate(h.time, "P") })),
        };
      }),
    );

    return {
      accounts: accountData,
      // Slim down the transactions
      transactions: transactions.map((t) => ({
        d: formatDate(t.posted, "P"),
        m: t.description,
        a: t.amount,
        c: t.category?.name,
      })),
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
}
