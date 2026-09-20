import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it } from "vitest";

setupTests();

import { CurrentUser } from "./current-user.decorator.js";
import { ROUTE_ARGS_METADATA } from "@nestjs/common/constants.js";
import { InternalServerErrorException } from "@nestjs/common";

describe("CurrentUser Decorator", () => {
  it("should extract user or handle missing user according to allowFailure option", () => {
    class TestController {
      testMethod(@CurrentUser() user: any, @CurrentUser(true) optionalUser: any) {
        return [user, optionalUser];
      }
    }

    const metadata = Reflect.getMetadata(ROUTE_ARGS_METADATA, TestController, "testMethod");
    const keys = Object.keys(metadata);
    const factory1 = metadata[keys[0]!].factory;
    const factory2 = metadata[keys[1]!].factory;

    const mockCtxWithUser = {
      switchToHttp: () => ({
        getRequest: () => ({ user: { id: "user-1" } }),
      }),
    };
    expect(factory1(null, mockCtxWithUser)).toEqual({ id: "user-1" });

    const mockCtxNoUser = {
      switchToHttp: () => ({
        getRequest: () => ({ user: null }),
      }),
    };
    expect(factory2(true, mockCtxNoUser)).toBeNull();
    expect(() => factory1(false, mockCtxNoUser)).toThrow(InternalServerErrorException);
  });
});
