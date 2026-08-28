import { setupTests } from "@backend/test/helpers";
setupTests();

import { UserConfigController } from "@backend/user/user.config.controller";
import { UserService } from "@backend/user/user.service";
import { SSEService } from "@backend/sse/sse.service";
import { User } from "@backend/user/model/user.model";
import { UserConfig } from "@backend/user/model/user.config.model";
import { TestEntities } from "@backend/test/entities";
import { NotFoundException } from "@nestjs/common";
import { SSEEventType } from "@backend/sse/model/event.model";

describe("UserConfigController", () => {
  let controller: UserConfigController;
  let userService: jest.Mocked<UserService>;
  let sseService: jest.Mocked<SSEService>;
  const user = TestEntities.user;

  beforeEach(() => {
    jest.clearAllMocks();

    userService = {
      syncEncryptedFields: jest.fn().mockResolvedValue(undefined),
    } as any;

    sseService = {
      sendToUser: jest.fn(),
    } as any;

    controller = new UserConfigController(userService, sseService);
  });

  describe("get", () => {
    it("should throw NotFoundException if user missing", async () => {
      jest.spyOn(User, "findOne").mockResolvedValue(null);

      await expect(controller.get(user)).rejects.toThrow(NotFoundException);
    });

    it("should return config for current user", async () => {
      jest.spyOn(User, "findOne").mockResolvedValue(user);

      const res = await controller.get(user);

      expect(res).toEqual(user.config);
    });
  });

  describe("edit", () => {
    it("should throw NotFoundException if existing user config missing", async () => {
      jest.spyOn(UserConfig, "findOne").mockResolvedValue(null);

      await expect(controller.edit(user, {} as any)).rejects.toThrow(NotFoundException);
    });

    it("should update config, sync encrypted fields, and trigger force update if currency changed", async () => {
      const existingConf = UserConfig.fromPlain({ id: "c1", currency: "USD", user });
      jest.spyOn(UserConfig, "findOne").mockResolvedValue(existingConf);

      const newConf = UserConfig.fromPlain({ currency: "EUR" });
      newConf.update = jest.fn().mockResolvedValue(newConf);
      jest.spyOn(UserConfig, "fromPlain").mockReturnValue(newConf);

      const res = await controller.edit(user, newConf);

      expect(userService.syncEncryptedFields).toHaveBeenCalledWith(newConf, existingConf);
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(res).toBe(newConf);
    });
  });
});
