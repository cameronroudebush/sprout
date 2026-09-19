import { setupTests } from "@backend/test/helpers";
setupTests();

import { Configuration } from "@backend/config/core";
import { TestEntities } from "@backend/test/entities";
import { UserCreationRequest } from "@backend/user/model/api/creation.request.dto";
import { UserDevice } from "@backend/user/model/user.device.model";
import { User } from "@backend/user/model/user.model";
import { UserController } from "@backend/user/user.controller";
import { UserService } from "@backend/user/user.service";
import { BadRequestException, NotFoundException, UnauthorizedException } from "@nestjs/common";

describe("UserController", () => {
  let controller: UserController;
  let userService: Mocked<UserService>;
  const user = TestEntities.user;
  let originalAuthConfig: any;

  beforeEach(() => {
    vi.clearAllMocks();

    userService = {
      allowUserCreation: vi.fn().mockResolvedValue(true),
      deleteUser: vi.fn().mockResolvedValue(undefined),
    } as any;

    controller = new UserController(userService);
  });

  afterEach(() => {
    Configuration.server.auth = originalAuthConfig;
  });

  describe("me", () => {
    it("should throw UnauthorizedException if user is null and allowUserCreation is false", async () => {
      userService.allowUserCreation.mockResolvedValue(false);

      await expect(controller.me(null as any, {} as any)).rejects.toThrow(UnauthorizedException);
    });

    it("should throw NotFoundException if user is null but user creation is allowed for local auth", async () => {
      Configuration.server.auth = { type: "local" } as any;
      userService.allowUserCreation.mockResolvedValue(true);

      await expect(controller.me(null as any, {} as any)).rejects.toThrow(NotFoundException);
    });

    it("should throw UnauthorizedException if user is null, oidc auth type, and no setupUser info in request", async () => {
      Configuration.server.auth = { type: "oidc" } as any;
      userService.allowUserCreation.mockResolvedValue(true);

      await expect(controller.me(null as any, {} as any)).rejects.toThrow(UnauthorizedException);
    });

    it("should throw NotFoundException if user is null, oidc auth type, and setupUser is present in request", async () => {
      Configuration.server.auth = { type: "oidc" } as any;
      userService.allowUserCreation.mockResolvedValue(true);

      const req = { setupUser: { username: "oidcUser" } } as any;
      await expect(controller.me(null as any, req)).rejects.toThrow(NotFoundException);
    });

    it("should return user if user is present", async () => {
      vi.spyOn(User, "findOne").mockResolvedValue(user);

      const res = await controller.me(user, {} as any);

      expect(User.findOne).toHaveBeenCalledWith({ where: { id: user.id } });
      expect(res).toBe(user);
    });
  });

  describe("updateMe", () => {
    it("should throw BadRequestException if new email is already used by another user", async () => {
      const otherUser = User.fromPlain({ id: "user-other", email: "taken@sprout.local" });
      vi.spyOn(User, "findOne").mockResolvedValue(otherUser);

      await expect(controller.updateMe(user, { email: "taken@sprout.local" })).rejects.toThrow(BadRequestException);
    });

    it("should update email and call user.update()", async () => {
      vi.spyOn(User, "findOne").mockResolvedValue(null);
      const updatedUser = TestEntities.user;
      updatedUser.update = vi.fn().mockResolvedValue(updatedUser);

      const res = await controller.updateMe(updatedUser, { email: "new@sprout.local" });

      expect(updatedUser.email).toBe("new@sprout.local");
      expect(updatedUser.update).toHaveBeenCalled();
      expect(res).toBe(updatedUser);
    });

    it("should update without email parameter", async () => {
      const updatedUser = TestEntities.user;
      updatedUser.update = jest.fn().mockResolvedValue(updatedUser);

      const res = await controller.updateMe(updatedUser, {});

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
      vi.spyOn(User, "findOne").mockResolvedValue(null);

      await expect(controller.deleteById(adminUser, "invalid-user")).rejects.toThrow(NotFoundException);
    });

    it("should delete user and return success", async () => {
      const adminUser = TestEntities.user;
      adminUser.admin = true;
      const targetUser = User.fromPlain({ id: "user-target" });
      vi.spyOn(User, "findOne").mockResolvedValue(targetUser);

      const res = await controller.deleteById(adminUser, "user-target");

      expect(userService.deleteUser).toHaveBeenCalledWith(targetUser);
      expect(res).toEqual({ success: true });
    });
  });

  describe("getById", () => {
    it("should throw NotFoundException if user not found", async () => {
      vi.spyOn(User, "findOne").mockResolvedValue(null);

      await expect(controller.getById("invalid-id")).rejects.toThrow(NotFoundException);
    });

    it("should return UserGetDTO for user", async () => {
      vi.spyOn(User, "findOne").mockResolvedValue(user);

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

    it("should create user and return UserCreationResponse for local auth", async () => {
      Configuration.server.auth = { type: "local" } as any;
      userService.allowUserCreation.mockResolvedValue(true);
      vi.spyOn(User, "count").mockResolvedValue(0);
      const mockCreated = { username: "test", id: "u-1" };
      vi.spyOn(User, "createUser").mockResolvedValue(mockCreated as any);

      const res = await controller.create(UserCreationRequest.fromPlain({ username: "test", password: "pwd" }), {} as any);

      expect(User.createUser).toHaveBeenCalledWith({
        username: "test",
        password: "pwd",
        admin: true,
      });
      expect(res).toBe(mockCreated);
    });

    it("should create user and return UserCreationResponse for oidc auth", async () => {
      Configuration.server.auth = { type: "oidc" } as any;
      userService.allowUserCreation.mockResolvedValue(true);
      jest.spyOn(User, "count").mockResolvedValue(1);
      const mockCreated = { username: "oidcUser", id: "u-2" };
      jest.spyOn(User, "createUser").mockResolvedValue(mockCreated as any);

      const req = { setupUser: { username: "oidcUser", email: "oidc@sprout.local" } } as any;
      const res = await controller.create(UserCreationRequest.fromPlain({ username: "", password: "" }), req);

      expect(User.createUser).toHaveBeenCalledWith({
        username: "oidcUser",
        email: "oidc@sprout.local",
        admin: false,
      });
      expect(res).toBe(mockCreated);
    });

    it("should catch createUser error and throw BadRequestException", async () => {
      userService.allowUserCreation.mockResolvedValue(true);
      jest.spyOn(User, "count").mockResolvedValue(0);
      jest.spyOn(User, "createUser").mockRejectedValue(new Error("Database write error"));

      await expect(controller.create(UserCreationRequest.fromPlain({ username: "test", password: "pwd" }), {} as any)).rejects.toThrow(BadRequestException);
    });
  });

  describe("registerDevice", () => {
    it("should create or update device and return deviceId", async () => {
      const mockDevice = { id: "dev-1", update: vi.fn().mockResolvedValue({ id: "dev-1" }) };
      vi.spyOn(UserDevice, "findOne").mockResolvedValue(mockDevice as any);

      const res = await controller.registerDevice(user, { deviceId: "d-123", token: "tok-123" });

      expect(res).toEqual({ success: true, deviceId: "dev-1" });
      expect(mockDevice.update).toHaveBeenCalled();
    });

    it("should insert new device when device is not found", async () => {
      jest.spyOn(UserDevice, "findOne").mockResolvedValue(null);
      const insertSpy = jest.spyOn(UserDevice.prototype, "insert").mockResolvedValue({ id: "dev-new" } as any);

      const res = await controller.registerDevice(user, {
        deviceId: "d-new",
        token: "tok-new",
        deviceName: "My Phone",
      });

      expect(res).toEqual({ success: true, deviceId: "dev-new" });
      expect(insertSpy).toHaveBeenCalled();
    });
  });
});
