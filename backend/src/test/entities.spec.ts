import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { TestEntities } from "@backend/test/entities.js";

describe("TestEntities", () => {
  it("should return valid mock entities for all getters", () => {
    expect(TestEntities.userConfig).toBeDefined();
    expect(TestEntities.user).toBeDefined();
    expect(TestEntities.adminUser.admin).toBe(true);
    expect(TestEntities.institution).toBeDefined();
    expect(TestEntities.account).toBeDefined();
    expect(TestEntities.accountHistory).toBeDefined();
    expect(TestEntities.holding).toBeDefined();
    expect(TestEntities.holdingHistory).toBeDefined();
    expect(TestEntities.sync).toBeDefined();
    expect(TestEntities.notification).toBeDefined();
    expect(TestEntities.category).toBeDefined();
    expect(TestEntities.transaction).toBeDefined();
    expect(TestEntities.transactionRule).toBeDefined();
    expect(TestEntities.plaidInstitutionAsset).toBeDefined();
  });
});
