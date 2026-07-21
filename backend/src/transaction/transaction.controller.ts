import { Account } from "@backend/account/model/account.model";
import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { Category } from "@backend/category/model/category.model";
import { EnabledGuard } from "@backend/config/guard/enabled.guard";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { NotificationType } from "@backend/notification/model/notification.type";
import { NotificationService } from "@backend/notification/notification.service";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { TotalTransactions } from "@backend/transaction/model/api/total.transaction.dto";
import { TransactionSubscription } from "@backend/transaction/model/api/transaction.subscription.dto";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { TransactionService } from "@backend/transaction/transaction.service";
import { User } from "@backend/user/model/user.model";
import { BadRequestException, Body, Controller, Delete, Get, NotFoundException, Param, Patch, Query } from "@nestjs/common";
import { ApiBody, ApiNotFoundResponse, ApiOkResponse, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";
import { endOfDay, startOfDay } from "date-fns";
import { Between, FindOptionsWhere, ILike, In, IsNull, Like } from "typeorm";

/**
 * This controller provides the endpoint for all Transaction related content
 */
@Controller("transaction")
@ApiTags("Transaction")
@AuthGuard.attach()
export class TransactionController {
  constructor(
    private readonly transactionService: TransactionService,
    private readonly sseService: SSEService,
    private readonly notificationService: NotificationService,
  ) {}

  @Patch(":id")
  @ApiOperation({
    summary: "Edit transaction.",
    description: "Edits a transaction by the given ID.",
  })
  @ApiOkResponse({ description: "Transaction updated successfully.", type: Transaction })
  @ApiNotFoundResponse({ description: "Transaction with the specified ID not found." })
  @ApiBody({ type: Transaction })
  @EnabledGuard.attachDemoMode()
  async edit(@Param("id") id: string, @CurrentUser() user: User, @Body() transaction: Transaction) {
    const matchingTransaction = await Transaction.findOne({ where: { id: id, account: { user: { id: user.id } } } });
    if (matchingTransaction == null) throw new NotFoundException("Failed to locate a matching transaction to assign update.");
    if (matchingTransaction.pending) throw new BadRequestException("Pending transactions cannot be edited.");

    // Allow updating the various fields

    // Category
    if (transaction.categoryId != null) {
      const matchingCategory = await Category.findOne({ where: { id: transaction.categoryId, user: { id: user.id } } });
      if (matchingCategory == null) throw new NotFoundException("Failed to locate a matching category to assign the transaction to.");
      matchingTransaction.category = matchingCategory;
    }

    // Description
    matchingTransaction.description = transaction.description ?? matchingTransaction.description;

    matchingTransaction.manuallyEdited = true;

    const updated = await matchingTransaction.update();
    // Updating a transaction has a lot of effect on reports and other locations. Tell the frontend to update all data.
    this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);

    return updated;
  }

  @Delete(":id")
  @ApiOperation({
    summary: "Delete transaction.",
    description: "Deletes a transaction by the given ID.",
  })
  @ApiOkResponse({ description: "Transaction deleted successfully." })
  @ApiNotFoundResponse({ description: "Transaction with the specified ID not found." })
  @EnabledGuard.attachDemoMode()
  async delete(@Param("id") id: string, @CurrentUser() user: User) {
    const matchingTransaction = await Transaction.findOne({ where: { id: id, account: { user: { id: user.id } } } });
    if (matchingTransaction == null) throw new NotFoundException("Failed to locate a matching transaction to delete.");
    await matchingTransaction.remove();
    // Deleting a transaction has a lot of effect on reports and other locations. Tell the frontend to update all data.
    this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);
    return `Transaction with ID ${id} deleted successfully.`;
  }

  @Get()
  @ApiOperation({
    summary: "Get transactions by query.",
    description: "Retrieves transactions based on the provided query parameters.",
  })
  @ApiOkResponse({ description: "Transactions found successfully.", type: [Transaction] })
  @ApiQuery({ name: "startIndex", required: false, type: Number, description: "The starting index for pagination." })
  @ApiQuery({ name: "endIndex", required: false, type: Number, description: "The ending index for pagination." })
  @ApiQuery({ name: "accountId", required: false, type: String, description: "The ID of the account to retrieve transactions from." })
  @ApiQuery({
    name: "category",
    required: false,
    type: String,
    description:
      "A specific category id you want data for. If you pass unknown here, we'll return all categories matching 'null'. If this is not populated, we'll simply return all categories.",
  })
  @ApiQuery({ name: "description", required: false, type: String, description: "A partial description to filter transactions." })
  @ApiQuery({ name: "date", required: false, type: String, format: "date", description: "A specific date to filter transactions." })
  @ApiQuery({ name: "startDate", required: false, type: String, format: "date" })
  @ApiQuery({ name: "endDate", required: false, type: String, format: "date" })
  @ApiQuery({ name: "pending", required: false, type: Boolean })
  async getByQuery(
    @CurrentUser() user: User,
    @Query("startIndex") startIndex?: number,
    @Query("endIndex") endIndex?: number,
    @Query("accountId") accountId?: string,
    @Query("category") category?: string,
    @Query("description") description?: string,
    @Query("date") date?: string,
    @Query("startDate") startDate?: string,
    @Query("endDate") endDate?: string,
    @Query("pending") pending?: boolean,
  ) {
    // Define category clause of this search
    let categoryQuery;
    if (category == null) {
      categoryQuery = undefined; // No category filter
    } else if (category.toLowerCase() === "unknown") {
      categoryQuery = IsNull(); // Filter for un-categorized
    } else {
      // Handle nested categories
      const matchingCategory = await Category.findOne({ where: { id: category, user: { id: user.id } } });
      if (matchingCategory == null) throw new NotFoundException("Failed to locate a matching category.");

      const allIds = [matchingCategory.id];
      const queue = [matchingCategory.id];

      while (queue.length > 0) {
        const currentId = queue.shift()!;
        const children = await Category.find({
          where: { parentCategory: { id: currentId } },
          select: { id: true }, // Only fetch the IDs for efficiency
        });

        for (const child of children) {
          allIds.push(child.id);
          queue.push(child.id);
        }
      }

      categoryQuery = { id: In(allIds) };
    }

    let dateFilter;
    if (date) {
      dateFilter = Between(startOfDay(new Date(date)), endOfDay(new Date(date)));
    } else if (startDate && endDate) {
      dateFilter = Between(startOfDay(new Date(startDate)), endOfDay(new Date(endDate)));
    }

    const account: FindOptionsWhere<Account> = { user: { id: user.id } };
    if (accountId) account.id = accountId;
    const where: FindOptionsWhere<Transaction> = {
      account,
    };
    if (pending) where.pending = pending;
    if (dateFilter) where.posted = dateFilter;
    if (description) where.description = Like(`%${description}%`);
    if (categoryQuery) where.category = categoryQuery;

    return await Transaction.find({
      skip: startIndex,
      take: endIndex,
      where,
      order: { posted: "DESC", pending: "DESC", description: "ASC" },
      relations: { category: { parentCategory: true } },
    });
  }

  @Get("subscriptions")
  @ApiOperation({
    summary: "Get's subscriptions.",
    description: "Retrieves subscriptions based on historical transactions by guessing if they are reoccurring or not.",
  })
  @ApiOkResponse({ description: "Subscriptions found successfully.", type: [TransactionSubscription] })
  async subscriptions(@CurrentUser() user: User) {
    return await this.transactionService.findSubscriptions(user);
  }

  @Get("count")
  @ApiOperation({
    summary: "Get's the total count of transactions across accounts.",
    description: "Retrieves a count of the total number of transactions available for the current user including a total for each account.",
  })
  @ApiQuery({ name: "accountId", required: false, type: String })
  @ApiQuery({ name: "category", required: false, type: String })
  @ApiQuery({ name: "description", required: false, type: String })
  @ApiOkResponse({ description: "Transaction count found successfully.", type: TotalTransactions })
  async getTotal(
    @CurrentUser() user: User,
    @Query("accountId") accountId?: string,
    @Query("category") category?: string,
    @Query("description") description?: string,
  ) {
    const where: FindOptionsWhere<Transaction> = {
      account: {
        user: { id: user.id },
      },
    };
    // Apply Filters to the Count
    if (accountId) where.account = { id: accountId };
    if (category)
      if (category.toLowerCase() === "unknown") {
        // If "Unknown", we look for null categories
        where.category = IsNull();
      } else {
        where.category = { id: category };
      }
    if (description) where.description = ILike(`%${description}%`);
    const total = await Transaction.count({ where });
    // If you're not querying specifics, populate additional content
    const map: TotalTransactions["accounts"] = {};
    if (!accountId && !category && !description) {
      const accounts = await Account.getForUser(user);
      for (const account of accounts)
        map[account.id] = await Transaction.count({
          where: { account: { id: account.id, user: { id: user.id } } },
        });
    }

    return new TotalTransactions(map, total);
  }

  @Delete("duplicates/remove")
  @ApiOperation({
    summary: "Remove duplicate transactions.",
    description: "Scans all transactions for the user (or specific account) and removes duplicates by comparing the amount and date (ignoring time).",
  })
  @ApiQuery({ name: "accountId", required: false, type: String, description: "Optional. Scopes the deduplication to a specific account." })
  @ApiOkResponse({ description: "Returns the a status message on what action was taken for the removal." })
  @EnabledGuard.attachDemoMode()
  async removeDuplicates(@CurrentUser() user: User, @Query("accountId") accountId?: string) {
    const where: FindOptionsWhere<Transaction> = { account: { user: { id: user.id } } };
    let account: Account | undefined | null;
    if (accountId) {
      where.account = { id: accountId };
      account = await Account.findOne({ where: { id: accountId, user: { id: user.id } } });
    }

    // Fetch transactions ordered by posted date so we keep the oldest record
    const transactions = await Transaction.find({
      where,
      order: { posted: "ASC" },
    });

    const seen = new Map<string, Transaction>();
    const duplicatesToRemove: Transaction[] = [];
    const keptTransactionsToUpdate = new Set<Transaction>();

    for (const transaction of transactions) {
      // Normalize the date to midnight to completely ignore time variations
      const dateWithoutTime = startOfDay(new Date(transaction.posted)).getTime();

      // Create a composite key based on date and amount
      const duplicateKey = `${dateWithoutTime}_${transaction.amount}`;

      if (seen.has(duplicateKey)) {
        const keptTransaction = seen.get(duplicateKey)!;
        duplicatesToRemove.push(transaction);

        let isKeptModified = false;

        if (!keptTransaction.categoryId && transaction.categoryId) {
          keptTransaction.category = transaction.category;
          isKeptModified = true;
        }

        if (transaction.extra) {
          if (!keptTransaction.extra) {
            keptTransaction.extra = { ...transaction.extra };
            isKeptModified = true;
          } else {
            const mergedExtra = { ...transaction.extra, ...keptTransaction.extra };
            if (JSON.stringify(keptTransaction.extra) !== JSON.stringify(mergedExtra)) {
              keptTransaction.extra = mergedExtra;
              isKeptModified = true;
            }
          }
        }

        // If we merged data into the kept transaction, queue it for saving
        if (isKeptModified) keptTransactionsToUpdate.add(keptTransaction);
      } else seen.set(duplicateKey, transaction);
    }

    const fromMessage = `${!account ? "" : ` from ` + account.name}`;
    if (duplicatesToRemove.length > 0) {
      // Save any kept transactions that inherited data from their duplicates
      if (keptTransactionsToUpdate.size > 0) await Transaction.upsertMany(Array.from(keptTransactionsToUpdate));
      const removed = await Transaction.deleteMany(duplicatesToRemove.map((x) => x.id));
      // Force a frontend refresh since balances and reports have changed
      this.sseService.sendToUser(user, SSEEventType.FORCE_UPDATE);
      const removedCount = removed.affected ?? duplicatesToRemove.length;
      const message = `Successfully removed ${removedCount} duplicate transaction${removedCount != 1 ? "s" : ""}${fromMessage}.`;
      await this.notificationService.notifyUser(user, message, "Transaction Cleanup", NotificationType.info, false);
      return message;
    } else {
      const message = `No duplicate transactions to remove${fromMessage}.`;
      await this.notificationService.notifyUser(user, message, "Transaction Cleanup", NotificationType.info, false);
      return message;
    }
  }
}
