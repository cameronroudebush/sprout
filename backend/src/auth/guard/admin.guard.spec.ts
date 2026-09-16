import { setupTests } from "@backend/test/helpers";
setupTests();

import { AdminGuard } from "@backend/auth/guard/admin.guard";
import { TestEntities } from "@backend/test/entities";
import { User } from "@backend/user/model/user.model";
import { ExecutionContext, ForbiddenException } from "@nestjs/common";

describe("AdminGuard", () => {
  let guard: AdminGuard;

  beforeEach(() => {
    jest.clearAllMocks();
    guard = new AdminGuard();
  });

  describe("attach", () => {
    it("should return a composition decorator", () => {
      const decorator = AdminGuard.attach();
      expect(typeof decorator).toBe("function");
    });
  });

  describe("canActivate", () => {
    function createMockContext(user: any): ExecutionContext {
      return {
        switchToHttp: () => ({
          getRequest: () => ({ user }),
        }),
      } as any;
    }

    it("should return true when user is an instance of User and admin is true", () => {
      const adminUser = Object.assign(Object.create(User.prototype), TestEntities.user, { admin: true });
      const context = createMockContext(adminUser);

      expect(guard.canActivate(context)).toBe(true);
    });

    it("should throw ForbiddenException when user is not present", () => {
      const context = createMockContext(null);
      expect(() => guard.canActivate(context)).toThrow(ForbiddenException);
    });

    it("should throw ForbiddenException when user is not an instance of User", () => {
      const context = createMockContext({ admin: true });
      expect(() => guard.canActivate(context)).toThrow(ForbiddenException);
    });

    it("should throw ForbiddenException when user is an instance of User but admin is false", () => {
      const regularUser = Object.assign(Object.create(User.prototype), TestEntities.user, { admin: false });
      const context = createMockContext(regularUser);

      expect(() => guard.canActivate(context)).toThrow(ForbiddenException);
    });
  });
});
