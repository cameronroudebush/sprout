import { Transaction } from "@backend/model/transaction";
import { Account, User } from "@common";

/**
 * This class provides generic functionality that should be implemented in the various API handlings
 *  for the financial services.
 */
export abstract class FinanceAPIBase {
  /**
   * Returns the transactions associated to the given user.
   */
  abstract getTransactions(user: User): Promise<Transaction[]>;

  /** Returns accounts associated to the given user */
  abstract getAccounts(user: User): Promise<Account[]>;

  // async handleRegularTransactions(
  //   account: Account & {
  //     plaidItem: PlaidItem;
  //   }
  // ) {
  //   let allTransactions: PlaidTransaction[] = [];
  //   let hasMore = true;
  //   let cursor: string | undefined = undefined;

  //   console.log("Starting transaction sync for account:", account.id);

  //   // Keep fetching transactions until we get them all
  //   while (hasMore) {
  //     console.log("Fetching transactions with cursor:", cursor);
  //     const response = await plaidClient.transactionsSync({
  //       access_token: account.plaidItem.accessToken,
  //       cursor,
  //       count: 500,
  //       options: {
  //         include_original_description: true,
  //         account_id: account.plaidId,
  //       },
  //     });

  //     console.log("Plaid API Response:", {
  //       added: response.data.added.length,
  //       modified: response.data.modified.length,
  //       removed: response.data.removed.length,
  //       has_more: response.data.has_more,
  //     });

  //     // Filter transactions for this account
  //     const addedTransactions = response.data.added.filter(
  //       (tx) => tx.account_id === account.plaidId
  //     );
  //     const modifiedTransactions = response.data.modified.filter(
  //       (tx) => tx.account_id === account.plaidId
  //     );
  //     const removedTransactions = response.data.removed.filter(
  //       (tx) => tx.account_id === account.plaidId
  //     );

  //     // Process added transactions
  //     allTransactions = [...allTransactions, ...addedTransactions];

  //     // Process modified transactions (update existing ones)
  //     for (const modifiedTx of modifiedTransactions) {
  //       await prisma.transaction.update({
  //         where: {
  //           accountId_plaidId: {
  //             accountId: account.id,
  //             plaidId: modifiedTx.transaction_id,
  //           },
  //         },
  //         data: {
  //           date: new Date(modifiedTx.date),
  //           name: modifiedTx.name,
  //           amount: modifiedTx.amount,
  //           category: modifiedTx.category ? modifiedTx.category[0] : null,
  //           merchantName: modifiedTx.merchant_name,
  //           pending: modifiedTx.pending,
  //           // Additional fields
  //           isoCurrencyCode: modifiedTx.iso_currency_code,
  //           unofficialCurrencyCode: modifiedTx.unofficial_currency_code,
  //           authorizedDate: modifiedTx.authorized_date
  //             ? new Date(modifiedTx.authorized_date)
  //             : null,
  //           authorizedDatetime: modifiedTx.authorized_datetime
  //             ? new Date(modifiedTx.authorized_datetime)
  //             : null,
  //           datetime: modifiedTx.datetime ? new Date(modifiedTx.datetime) : null,
  //           paymentChannel: modifiedTx.payment_channel,
  //           transactionCode: modifiedTx.transaction_code,
  //           personalFinanceCategory:
  //             modifiedTx.personal_finance_category?.primary || null,
  //           merchantEntityId: modifiedTx.merchant_entity_id,
  //           // Location data
  //           locationAddress: modifiedTx.location?.address,
  //           locationCity: modifiedTx.location?.city,
  //           locationRegion: modifiedTx.location?.region,
  //           locationPostalCode: modifiedTx.location?.postal_code,
  //           locationCountry: modifiedTx.location?.country,
  //           locationLat: modifiedTx.location?.lat || null,
  //           locationLon: modifiedTx.location?.lon || null,
  //           // Payment metadata
  //           byOrderOf: modifiedTx.payment_meta?.by_order_of,
  //           payee: modifiedTx.payment_meta?.payee,
  //           payer: modifiedTx.payment_meta?.payer,
  //           paymentMethod: modifiedTx.payment_meta?.payment_method,
  //           paymentProcessor: modifiedTx.payment_meta?.payment_processor,
  //           ppd_id: modifiedTx.payment_meta?.ppd_id,
  //           reason: modifiedTx.payment_meta?.reason,
  //           referenceNumber: modifiedTx.payment_meta?.reference_number,
  //         },
  //       });
  //     }

  //     // Process removed transactions
  //     if (removedTransactions.length > 0) {
  //       console.log(
  //         `Deleting ${removedTransactions.length} removed transactions`
  //       );
  //       await prisma.transaction.deleteMany({
  //         where: {
  //           accountId: account.id,
  //           plaidId: {
  //             in: removedTransactions.map((tx) => tx.transaction_id),
  //           },
  //         },
  //       });
  //     }

  //     // Log the date range of received transactions
  //     if (addedTransactions.length > 0) {
  //       const dates = addedTransactions.map((t) => new Date(t.date));
  //       const oldestDate = new Date(Math.min(...dates.map((d) => d.getTime())));
  //       const newestDate = new Date(Math.max(...dates.map((d) => d.getTime())));
  //       console.log("Received transactions date range:", {
  //         oldest: oldestDate.toISOString().split("T")[0],
  //         newest: newestDate.toISOString().split("T")[0],
  //         count: addedTransactions.length,
  //       });
  //     }

  //     hasMore = response.data.has_more;
  //     cursor = response.data.next_cursor;
  //   }

  //   // Calculate actual date range from fetched transactions
  //   const transactionDates = allTransactions.map((t) => new Date(t.date));
  //   const oldestDate =
  //     allTransactions.length > 0
  //       ? new Date(Math.min(...transactionDates.map((d) => d.getTime())))
  //       : new Date();
  //   const newestDate =
  //     allTransactions.length > 0
  //       ? new Date(Math.max(...transactionDates.map((d) => d.getTime())))
  //       : new Date();

  //   // Create download log entry
  //   const downloadLog = await prisma.transactionDownloadLog.create({
  //     data: {
  //       accountId: account.id,
  //       startDate: oldestDate,
  //       endDate: newestDate,
  //       numTransactions: allTransactions.length,
  //       status: "success",
  //     },
  //   });

  //   // Insert new transactions, skipping any that already exist
  //   if (allTransactions.length > 0) {
  //     await prisma.$transaction(
  //       allTransactions.map((transaction) =>
  //         prisma.transaction.upsert({
  //           where: {
  //             accountId_plaidId: {
  //               accountId: account.id,
  //               plaidId: transaction.transaction_id,
  //             },
  //           },
  //           create: {
  //             accountId: account.id,
  //             plaidId: transaction.transaction_id,
  //             date: new Date(transaction.date),
  //             name: transaction.name,
  //             amount: transaction.amount,
  //             category: transaction.category ? transaction.category[0] : null,
  //             merchantName: transaction.merchant_name,
  //             pending: transaction.pending,
  //             // Additional fields
  //             isoCurrencyCode: transaction.iso_currency_code,
  //             unofficialCurrencyCode: transaction.unofficial_currency_code,
  //             authorizedDate: transaction.authorized_date
  //               ? new Date(transaction.authorized_date)
  //               : null,
  //             authorizedDatetime: transaction.authorized_datetime
  //               ? new Date(transaction.authorized_datetime)
  //               : null,
  //             datetime: transaction.datetime
  //               ? new Date(transaction.datetime)
  //               : null,
  //             paymentChannel: transaction.payment_channel,
  //             transactionCode: transaction.transaction_code,
  //             personalFinanceCategory:
  //               transaction.personal_finance_category?.primary || null,
  //             merchantEntityId: transaction.merchant_entity_id,
  //             // Location data
  //             locationAddress: transaction.location?.address,
  //             locationCity: transaction.location?.city,
  //             locationRegion: transaction.location?.region,
  //             locationPostalCode: transaction.location?.postal_code,
  //             locationCountry: transaction.location?.country,
  //             locationLat: transaction.location?.lat || null,
  //             locationLon: transaction.location?.lon || null,
  //             // Payment metadata
  //             byOrderOf: transaction.payment_meta?.by_order_of,
  //             payee: transaction.payment_meta?.payee,
  //             payer: transaction.payment_meta?.payer,
  //             paymentMethod: transaction.payment_meta?.payment_method,
  //             paymentProcessor: transaction.payment_meta?.payment_processor,
  //             ppd_id: transaction.payment_meta?.ppd_id,
  //             reason: transaction.payment_meta?.reason,
  //             referenceNumber: transaction.payment_meta?.reference_number,
  //           },
  //           update: {}, // No update if transaction exists
  //         })
  //       )
  //     );
  //   }

  //   return {
  //     message: "Transactions downloaded successfully",
  //     downloadLog,
  //     numTransactions: allTransactions.length,
  //   };
  // }
}
