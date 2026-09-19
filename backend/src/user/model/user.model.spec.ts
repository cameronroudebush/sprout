import { setupTests } from "@backend/test/helpers";
setupTests();

import { Category } from "@backend/category/model/category.model";
import { TestEntities } from "@backend/test/entities";
import { UserConfig } from "@backend/user/model/user.config.model";
import { User } from "@backend/user/model/user.model";
import { BadRequestException } from "@nestjs/common";

describe("User model", () => {
  it("should create user instance via constructor", () => {
    const config = TestEntities.userConfig;
    const user = new User("johndoe", "john@sprout.local", "John", "Doe", true, config);

    expect(user.username).toBe("johndoe");
    expect(user.email).toBe("john@sprout.local");
    expect(user.firstName).toBe("John");
    expect(user.lastName).toBe("Doe");
    expect(user.admin).toBe(true);
    expect(user.config).toBe(config);
  });

  describe("prettyName", () => {
    it("should return username when firstName and lastName are missing", () => {
      const user = User.fromPlain({ username: "johndoe" });
      expect(user.prettyName).toBe("johndoe");
    });

    it("should return full name when firstName and lastName are present", () => {
      const user = User.fromPlain({ username: "johndoe", firstName: "John", lastName: "Doe" });
      expect(user.prettyName).toBe("John Doe");
    });
  });

  describe("password methods", () => {
    it("should hash password and verify matching password", () => {
      const plain = "Secret123";
      const hashed = User.hashPassword(plain);
      const user = new User("johndoe", "john@sprout.local", "John", "Doe", false, TestEntities.userConfig);
      user.password = hashed;

      expect(user.verifyPassword(plain)).toBe(true);
      expect(user.verifyPassword("WrongPassword")).toBe(false);
    });

    it("should validate password requirements", async () => {
      await expect(User.validatePassword("short")).rejects.toThrow("Password must be at least 8 characters long.");
      await expect(User.validatePassword("lowercase123")).rejects.toThrow("Password must contain at least one uppercase letter.");
      await expect(User.validatePassword("ValidPassword123")).resolves.toBeUndefined();
    });
  });

  describe("checkIfUsernameIsInUser", () => {
    it("should throw BadRequestException if username is empty or whitespace", async () => {
      await expect(User.checkIfUsernameIsInUser("   ")).rejects.toThrow(BadRequestException);
    });

    it("should throw error if username is already in use", async () => {
      vi.spyOn(User, "find").mockResolvedValue([TestEntities.user]);

      await expect(User.checkIfUsernameIsInUser("existingUser")).rejects.toThrow("Username is in use");
    });

    it("should resolve when username is available", async () => {
      vi.spyOn(User, "find").mockResolvedValue([]);

      await expect(User.checkIfUsernameIsInUser("newUser")).resolves.toBeUndefined();
    });
  });

  describe("createUser", () => {
    it("should create user without password", async () => {
      vi.spyOn(User, "checkIfUsernameIsInUser").mockResolvedValue(undefined);
      vi.spyOn(UserConfig, "fromPlain").mockReturnValue({
        insert: vi.fn().mockResolvedValue(TestEntities.userConfig),
      } as any);
      vi.spyOn(Category, "insertMany").mockResolvedValue([] as any);

      vi.spyOn(User, "fromPlain").mockImplementation((u: any) => {
        const instance = new User(u.username, u.email, u.firstName, u.lastName, u.admin, u.config);
        instance.insert = vi.fn().mockResolvedValue(instance);
        return instance;
      });

      const response = await User.createUser({ username: "newuser", admin: false });

      expect(response.username).toBe("newuser");
    });

    it("should create user with valid password", async () => {
      vi.spyOn(User, "checkIfUsernameIsInUser").mockResolvedValue(undefined);
      vi.spyOn(UserConfig, "fromPlain").mockReturnValue({
        insert: vi.fn().mockResolvedValue(TestEntities.userConfig),
      } as any);
      vi.spyOn(Category, "insertMany").mockResolvedValue([] as any);

      vi.spyOn(User, "fromPlain").mockImplementation((u: any) => {
        const instance = new User(u.username, u.email, u.firstName, u.lastName, u.admin, u.config);
        instance.insert = vi.fn().mockResolvedValue(instance);
        return instance;
      });

      const response = await User.createUser({
        username: "passuser",
        password: "ValidPassword123",
        admin: true,
      });

      expect(response.username).toBe("passuser");
    });
  });
});
