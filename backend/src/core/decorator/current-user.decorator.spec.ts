import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it } from "vitest";

setupTests();

import { CurrentUser } from "./current-user.decorator.js";
import { ROUTE_ARGS_METADATA } from "@nestjs/common/constants.js";

describe("CurrentUser Decorator", () => {
  it("should extract user from request execution context", () => {
    class TestController {
      testMethod(@CurrentUser() user: any) {
        return user;
      }
    }

    const metadata = Reflect.getMetadata(ROUTE_ARGS_METADATA, TestController, "testMethod");
    expect(metadata).toBeDefined();
    const key = Object.keys(metadata)[0];
    const factory = metadata[key!].factory;

    const mockCtx = {
      switchToHttp: () => ({
        getRequest: () => ({ user: { id: "user-123" } }),
      }),
    };

    const user = factory(null, mockCtx);
    expect(user).toEqual({ id: "user-123" });
  });
});
