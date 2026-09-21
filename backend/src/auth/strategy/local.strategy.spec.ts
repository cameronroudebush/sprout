import { setupTests } from "@backend/test/helpers";
setupTests();

import { LocalJWTContent } from "@backend/auth/auth.service";
import { LocalStrategy } from "@backend/auth/strategy/local.strategy";
import { User } from "@backend/user/model/user.model";
import { UnauthorizedException } from "@nestjs/common";

describe("LocalStrategy", () => {
  let strategy: LocalStrategy;

  beforeEach(() => {
    jest.clearAllMocks();
    strategy = new LocalStrategy();
  });

  describe("validate", () => {
    it("should return the user instance when the payload username is found in the database", async () => {
      const payload: LocalJWTContent = { username: "alex_dev" } as LocalJWTContent;
      const mockUser = User.fromPlain({ id: "user-456", username: "alex_dev" });

      const findOneSpy = jest.spyOn(User, "findOne").mockResolvedValue(mockUser);

      const result = await strategy.validate(payload);

      expect(findOneSpy).toHaveBeenCalledWith({
        where: { username: "alex_dev" },
      });
      expect(result).toBe(mockUser);
    });

    it("should throw UnauthorizedException when the username does not exist in the database", async () => {
      const payload: LocalJWTContent = { username: "non_existent_user" } as LocalJWTContent;

      jest.spyOn(User, "findOne").mockResolvedValue(null);

      await expect(strategy.validate(payload)).rejects.toThrow(UnauthorizedException);
    });
  });
});
