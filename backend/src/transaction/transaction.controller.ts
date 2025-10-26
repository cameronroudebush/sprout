import { Account } from "@backend/account/model/account.model";
import { Category } from "@backend/category/model/category.model";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { AuthGuard } from "@backend/core/guard/auth.guard";
import { TotalTransactions } from "@backend/transaction/model/api/total.transaction.dto";
import { TransactionSubscription } from "@backend/transaction/model/api/transaction.subscription.dto";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { TransactionService } from "@backend/transaction/transaction.service";
import { User } from "@backend/user/model/user.model";
import { BadRequestException, Body, Controller, Get, NotFoundException, Param, Patch, Query } from "@nestjs/common";
import { ApiBody, ApiNotFoundResponse, ApiOkResponse, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";
import { endOfDay, startOfDay } from "date-fns";
import { Between, In, IsNull, Like } from "typeorm";

/**
 * This controller provides the endpoint for all Transaction related content
 */
@Controller("transaction")
@ApiTags("Transaction")
@AuthGuard.attach()
export class TransactionController {
  constructor(private readonly transactionService: TransactionService) {}

  @Patch(":id")
  @ApiOperation({
    summary: "Edit transaction.",
    description: "Edits a transaction by the given ID.",
  })
  @ApiOkResponse({ description: "Transaction updated successfully.", type: Transaction })
  @ApiNotFoundResponse({ description: "Transaction with the specified ID not found." })
  @ApiBody({ type: Transaction })
  async edit(@Param("id") id: string, @CurrentUser() user: User, @Body() transaction: Transaction) {
    const matchingTransaction = await Transaction.findOne({ where: { id: id, account: { user: { id: user.id } } } });
    if (matchingTransaction == null) throw new NotFoundException("Failed to locate a matching transaction to assign update.");
    if (matchingTransaction.pending) throw new BadRequestException("Pending transactions cannot be edited.");

    // Currently, we only allow category updating
    const matchingCategory = await Category.findOne({ where: { id: transaction.category?.id, user: { id: user.id } } });
    if (matchingCategory == null) throw new NotFoundException("Failed to locate a matching category to assign the transaction to.");
    matchingTransaction.category = matchingCategory;

    return await matchingTransaction.update();
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
  async getByQuery(
    @CurrentUser() user: User,
    @Query("startIndex") startIndex?: number,
    @Query("endIndex") endIndex?: number,
    @Query("accountId") accountId?: string,
    @Query("category") category?: string,
    @Query("description") description?: string,
    @Query("date") date?: string,
  ) {
    // Define category clause of this search
    let categoryQuery;
    if (category == null) {
      categoryQuery = undefined; // No category filter
    } else if (category === "Unknown") {
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
          select: ["id"], // Only fetch the IDs for efficiency
        });

        for (const child of children) {
          allIds.push(child.id);
          queue.push(child.id);
        }
      }

      categoryQuery = { id: In(allIds) };
    }

    return await Transaction.find({
      skip: startIndex,
      take: endIndex,
      where: {
        account: { id: accountId, user: { id: user.id } },
        category: categoryQuery,
        description: description ? Like(`%${description}%`) : undefined,
        posted: date != null ? Between(startOfDay(new Date(date)), endOfDay(new Date(date))) : undefined,
      },
      order: { posted: "DESC", pending: "DESC", description: "ASC" },
      relations: ["category", "category.parentCategory"],
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
  @ApiOkResponse({ description: "Transaction count found successfully.", type: TotalTransactions })
  async getTotal(@CurrentUser() user: User) {
    const map: TotalTransactions["accounts"] = {};
    const accounts = await Account.getForUser(user);
    for (const account of accounts) {
      const transactionCount = await Transaction.count({ where: { account: { id: account.id, user: { id: user.id } } } });
      map[account.id] = transactionCount;
    }
    const total = await Transaction.count({ where: { account: { user: { id: user.id } } } });
    return new TotalTransactions(map, total);
  }
}
