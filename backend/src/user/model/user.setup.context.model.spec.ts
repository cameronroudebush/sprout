import { setupTests } from "@backend/test/helpers";
setupTests();

import { UserSetupContext } from "@backend/user/model/user.setup.context.model";

describe("UserSetupContext model", () => {
  it("should create instance with constructor parameters", () => {
    const context = new UserSetupContext("u-123", "ghostUser", "ghost@sprout.local", "Ghost", "User", true);

    expect(context.id).toBe("u-123");
    expect(context.username).toBe("ghostUser");
    expect(context.email).toBe("ghost@sprout.local");
    expect(context.firstName).toBe("Ghost");
    expect(context.lastName).toBe("User");
    expect(context.admin).toBe(true);
  });

  it("should default admin to false when not provided", () => {
    const context = new UserSetupContext("u-456", "normalUser", "normal@sprout.local");

    expect(context.admin).toBe(false);
  });
});
