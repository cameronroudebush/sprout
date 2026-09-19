import { setupTests } from "@backend/test/helpers";
setupTests();

import { DatabaseBase } from "@backend/database/model/database.base";

class TestEntity extends DatabaseBase {}

describe("DatabaseBase Model", () => {
  it("should instantiate DatabaseBase derived entity", () => {
    const entity = new TestEntity();
    entity.id = "test-uuid";
    expect(entity.id).toBe("test-uuid");
  });
});
