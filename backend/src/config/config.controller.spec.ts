import { setupTests } from "@backend/test/helpers";
setupTests();

import { ConfigController } from "@backend/config/config.controller";
import { UserService } from "@backend/user/user.service";
import { TestEntities } from "@backend/test/entities";
import { APIConfig } from "@backend/config/model/api/configuration.dto";
import { UnsecureAppConfiguration } from "@backend/config/model/api/unsecure.app.config.dto";
import { Configuration } from "@backend/config/core";

describe("ConfigController", () => {
  let controller: ConfigController;
  let userService: Mocked<UserService>;
  const user = TestEntities.user;

  beforeEach(() => {
    userService = {
      allowUserCreation: vi.fn().mockResolvedValue(true),
    } as any;

    controller = new ConfigController(userService);
  });

  describe("get", () => {
    it("should return APIConfig instance", async () => {
      const config = await controller.get(user);

      expect(config).toBeInstanceOf(APIConfig);
    });
  });

  describe("getUnsecure", () => {
    it("should return UnsecureAppConfiguration instance", async () => {
      const config = await controller.getUnsecure();

      expect(userService.allowUserCreation).toHaveBeenCalled();
      expect(config).toBeInstanceOf(UnsecureAppConfiguration);
    });

    it("should include demo credentials in demo mode", async () => {
      const original = Configuration.isDemoMode;
      Configuration.isDemoMode = true;
      try {
        const config = await controller.getUnsecure();
        expect(config).toBeInstanceOf(UnsecureAppConfiguration);
      } finally {
        Configuration.isDemoMode = original;
      }
    });
  });
});
