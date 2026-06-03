import { AccountHistory } from "@backend/account/model/account.history.model";
import { Account } from "@backend/account/model/account.model";
import { HoldingHistory } from "@backend/holding/model/holding.history.model";
import { Holding } from "@backend/holding/model/holding.model";
import { Institution } from "@backend/institution/model/institution.model";
import { Sync } from "@backend/jobs/model/sync.model";
import { Notification } from "@backend/notification/model/notification.model";
import { PlaidInstitutionAsset } from "@backend/providers/plaid/model/plaid.institution.asset";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { User } from "@backend/user/model/user.model";

/** A map of re-usable entities already pre configured */
export const TestEntities = {
  get user() {
    return User.fromPlain({
      id: "user-default-id",
      email: "user@sprout.local",
      firstName: "John",
      lastName: "Doe",
      username: "johndoe",
      admin: false,
      config: {
        id: "config-default-id",
        netWorthRange: "oneMonth",
        emailUpdateFrequency: "none",
        themeStyle: "bliss",
        currency: "USD",
        privateMode: false,
        secureMode: false,
        allowWidgets: true,
        simpleFinToken: "encrypted-token",
        geminiKey: "encrypted-key",
      },
    });
  },

  get institution() {
    return Institution.fromPlain({
      id: "institution-default-id",
      iconType: "icon",
      url: "https://bank.local",
      name: "Sprout Bank",
      hasError: false,
    });
  },

  get account() {
    return Account.fromPlain({
      id: "account-default-id",
      name: "Checking Account",
      provider: "plaid",
      type: "depository",
      subType: "Checking",
      balance: 1000.0,
      availableBalance: 950.0,
      interestRate: null,
      currency: "USD",
      extra: {},
      institution: this.institution,
      user: this.user,
    });
  },

  get accountHistory() {
    return AccountHistory.fromPlain({
      id: "history-default-id",
      time: new Date("2026-06-01T12:00:00.000Z"),
      balance: 1000.0,
      availableBalance: 950.0,
      account: this.account,
    });
  },

  get holding() {
    return Holding.fromPlain({
      id: "holding-default-id",
      accountId: "account-default-id",
      purchasePrice: 150.0,
      costBasis: 1500.0,
      marketValue: 1800.0,
      description: "Apple Inc.",
      shares: 10,
      symbol: "AAPL",
      account: this.account,
    });
  },

  get holdingHistory() {
    return HoldingHistory.fromPlain({
      id: "holding-history-default-id",
      time: new Date("2026-06-01T12:00:00.000Z"),
      costBasis: 1500.0,
      marketValue: 1700.0,
      purchasePrice: 150.0,
      shares: 10,
      holding: this.holding,
    });
  },

  get sync() {
    return Sync.fromPlain({
      id: "sync-default-id",
      time: new Date("2026-06-02T12:00:00.000Z"),
      status: "complete",
      provider: "plaid",
      failureReason: null,
      user: this.user,
    });
  },

  get notification() {
    return Notification.fromPlain({
      id: "notification-default-id",
      createdAt: new Date("2026-06-02T12:00:00.000Z"),
      title: "Sync Success",
      message: "Your data has been refreshed.",
      type: "success",
      isRead: false,
      readAt: null,
      user: this.user,
    });
  },

  get transaction() {
    return Transaction.fromPlain({
      id: "transaction-default-id",
      accountId: "account-default-id",
      categoryId: "category-default-id",
      amount: 45.5,
      description: "Grocery Store",
      pending: false,
      posted: new Date("2026-06-02T10:00:00.000Z"),
      extra: {},
      manuallyEdited: false,
      account: this.account,
    });
  },

  get plaidInstitutionAsset() {
    return PlaidInstitutionAsset.fromPlain({ accessToken: "at-test", itemId: "test", institution: this.institution });
  },
};
