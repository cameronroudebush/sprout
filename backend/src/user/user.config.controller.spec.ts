import { setupTests } from "@backend/test/helpers";
setupTests();

import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { TestEntities } from "@backend/test/entities";
import { UserConfig } from "@backend/user/model/user.config.model";
import { User } from "@backend/user/model/user.model";
import { UserConfigController } from "@backend/user/user.config.controller";
import { UserService } from "@backend/user/user.service";
import { NotFoundException } from "@nestjs/common";
import { Mocked } from "vitest";

describe("UserConfigController", () => {
  let controller: UserConfigController;
  let userService: Mocked<UserService>;
  let sseService: Mocked<SSEService>;
  const user = TestEntities.user;

  beforeEach(() => {
    vi.clearAllMocks();

    userService = {
      syncEncryptedFields: vi.fn().mockResolvedValue(undefined),
    } as any;

    sseService = {
      sendToUser: vi.fn(),
    } as any;

    controller = new UserConfigController(userService, sseService);
  });

  describe("get", () => {
    it("should throw NotFoundException if user missing", async () => {
      vi.spyOn(User, "findOne").mockResolvedValue(null);

      await expect(controller.get(user)).rejects.toThrow(NotFoundException);
    });

    it("should return config for current user", async () => {
      vi.spyOn(User, "findOne").mockResolvedValue(user);

      const res = await controller.get(user);

      expect(res).toEqual(user.config);
    });
  });

  describe("edit", () => {
    it("should throw NotFoundException if existing user config missing", async () => {
      vi.spyOn(UserConfig, "findOne").mockResolvedValue(null);

      await expect(controller.edit(user, {} as any)).rejects.toThrow(NotFoundException);
    });

    it("should update config, sync encrypted fields, and trigger force update if currency changed", async () => {
      const existingConf = UserConfig.fromPlain({ id: "c1", currency: "USD", user });
      vi.spyOn(UserConfig, "findOne").mockResolvedValue(existingConf);

      const newConf = UserConfig.fromPlain({ currency: "EUR" });
      newConf.update = vi.fn().mockResolvedValue(newConf);
      vi.spyOn(UserConfig, "fromPlain").mockReturnValue(newConf);

      const res = await controller.edit(user, newConf);

      expect(userService.syncEncryptedFields).toHaveBeenCalledWith(newConf, existingConf);
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(res).toBe(newConf);
    });

    it("should update config and sync encrypted fields without sending SSE force update if currency did not change", async () => {
      const existingConf = UserConfig.fromPlain({ id: "c1", currency: "USD", user });
      vi.spyOn(UserConfig, "findOne").mockResolvedValue(existingConf);

      const newConf = UserConfig.fromPlain({ currency: "USD" });
      newConf.update = vi.fn().mockResolvedValue(newConf);
      vi.spyOn(UserConfig, "fromPlain").mockReturnValue(newConf);

      const res = await controller.edit(user, newConf);

      expect(userService.syncEncryptedFields).toHaveBeenCalledWith(newConf, existingConf);
      expect(sseService.sendToUser).not.toHaveBeenCalled();
      expect(res).toBe(newConf);
    });
  });
});
