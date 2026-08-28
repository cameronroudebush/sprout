import { setupTests } from "@backend/test/helpers";
setupTests();

import { UserController } from "@backend/user/user.controller";
import { UserService } from "@backend/user/user.service";
import { User } from "@backend/user/model/user.model";
import { UserDevice } from "@backend/user/model/user.device.model";
import { TestEntities } from "@backend/test/entities";
import { BadRequestException, NotFoundException, UnauthorizedException } from "@nestjs/common";
import { UserCreationRequest } from "@backend/user/model/api/creation.request.dto";

describe("UserController", () => {
  let controller: UserController;
  let userService: jest.Mocked<UserService>;
  const user = TestEntities.user;

  beforeEach(() => {
    jest.clearAllMocks();

    userService = {
      allowUserCreation: jest.fn().mockResolvedValue(true),
      deleteUser: jest.fn().mockResolvedValue(undefined),
    } as any;

    controller = new UserController(userService);
  });

  describe("me", () => {
    it("should throw UnauthorizedException if user is null and allowUserCreation is false", async () => {
      userService.allowUserCreation.mockResolvedValue(false);

      await expect(controller.me(null as any, {} as any)).rejects.toThrow(UnauthorizedException);
    });

    it("should throw NotFoundException if user is null but user creation is allowed for local auth", async () => {
      userService.allowUserCreation.mockResolvedValue(true);

      await expect(controller.me(null as any, {} as any)).rejects.toThrow(NotFoundException);
    });

    it("should return user if user is present", async () => {
      jest.spyOn(User, "findOne").mockResolvedValue(user);

      const res = await controller.me(user, {} as any);

      expect(User.findOne).toHaveBeenCalledWith({ where: { id: user.id } });
      expect(res).toBe(user);
    });
  });

  describe("updateMe", () => {
    it("should throw BadRequestException if new email is already used by another user", async () => {
      const otherUser = User.fromPlain({ id: "user-other", email: "taken@sprout.local" });
      jest.spyOn(User, "findOne").mockResolvedValue(otherUser);

      await expect(controller.updateMe(user, { email: "taken@sprout.local" })).rejects.toThrow(BadRequestException);
    });

    it("should update email and call user.update()", async () => {
      jest.spyOn(User, "findOne").mockResolvedValue(null);
      const updatedUser = TestEntities.user;
      updatedUser.update = jest.fn().mockResolvedValue(updatedUser);

      const res = await controller.updateMe(updatedUser, { email: "new@sprout.local" });

      expect(updatedUser.email).toBe("new@sprout.local");
      expect(updatedUser.update).toHaveBeenCalled();
      expect(res).toBe(updatedUser);
    });
  });

  describe("deleteById", () => {
    it("should throw UnauthorizedException if current user is not admin", async () => {
      user.admin = false;

      await expect(controller.deleteById(user, "user-2")).rejects.toThrow(UnauthorizedException);
    });

    it("should throw BadRequestException if admin tries deleting themselves", async () => {
      const adminUser = TestEntities.user;
      adminUser.admin = true;

      await expect(controller.deleteById(adminUser, adminUser.id)).rejects.toThrow(BadRequestException);
    });

    it("should throw NotFoundException if target user does not exist", async () => {
      const adminUser = TestEntities.user;
      adminUser.admin = true;
      jest.spyOn(User, "findOne").mockResolvedValue(null);

      await expect(controller.deleteById(adminUser, "invalid-user")).rejects.toThrow(NotFoundException);
    });

    it("should delete user and return success", async () => {
      const adminUser = TestEntities.user;
      adminUser.admin = true;
      const targetUser = User.fromPlain({ id: "user-target" });
      jest.spyOn(User, "findOne").mockResolvedValue(targetUser);

      const res = await controller.deleteById(adminUser, "user-target");

      expect(userService.deleteUser).toHaveBeenCalledWith(targetUser);
      expect(res).toEqual({ success: true });
    });
  });

  describe("getById", () => {
    it("should throw NotFoundException if user not found", async () => {
      jest.spyOn(User, "findOne").mockResolvedValue(null);

      await expect(controller.getById("invalid-id")).rejects.toThrow(NotFoundException);
    });

    it("should return UserGetDTO for user", async () => {
      jest.spyOn(User, "findOne").mockResolvedValue(user);

      const res = await controller.getById(user.id);

      expect(res).toBeDefined();
      expect(res.username).toBe(user.username);
    });
  });

  describe("create", () => {
    it("should throw BadRequestException if allowUserCreation is false", async () => {
      userService.allowUserCreation.mockResolvedValue(false);

      await expect(controller.create(UserCreationRequest.fromPlain({ username: "test", password: "pwd" }), {} as any)).rejects.toThrow(BadRequestException);
    });

    it("should create user and return UserCreationResponse", async () => {
      userService.allowUserCreation.mockResolvedValue(true);
      jest.spyOn(User, "count").mockResolvedValue(0);
      const mockCreated = { username: "test", id: "u-1" };
      jest.spyOn(User, "createUser").mockResolvedValue(mockCreated as any);

      const res = await controller.create(UserCreationRequest.fromPlain({ username: "test", password: "pwd" }), {} as any);

      expect(User.createUser).toHaveBeenCalledWith({ username: "test", password: "pwd", admin: true });
      expect(res).toBe(mockCreated);
    });
  });

  describe("registerDevice", () => {
    it("should create or update device and return deviceId", async () => {
      const mockDevice = { id: "dev-1", update: jest.fn().mockResolvedValue({ id: "dev-1" }) };
      jest.spyOn(UserDevice, "findOne").mockResolvedValue(mockDevice as any);

      const res = await controller.registerDevice(user, { deviceId: "d-123", token: "tok-123" });

      expect(res).toEqual({ success: true, deviceId: "dev-1" });
    });
  });
});
