import { setupTests } from "@backend/test/helpers";
setupTests();

import { Configuration } from "@backend/config/core";
import { EncryptionTransformer } from "@backend/core/decorator/encryption.decorator";
import { Institution } from "@backend/institution/model/institution.model";
import { ProviderBase } from "@backend/providers/base/core";
import { SimpleFINProviderService } from "@backend/providers/simple-fin/simple-fin.provider.service";
import { TestEntities } from "@backend/test/entities";
import { CurrencyOptions } from "@backend/user/model/user.config.model";
import { User } from "@backend/user/model/user.model";
import { UserService } from "@backend/user/user.service";
import { InternalServerErrorException } from "@nestjs/common";

describe("UserService", () => {
  let service: UserService;
  let mockProvider: Mocked<ProviderBase>;
  let mockSimpleFinProviderService: Mocked<SimpleFINProviderService>;
  const originalAuth = Configuration.server.auth;

  beforeEach(() => {
    vi.clearAllMocks();

    mockProvider = {
      config: { name: "MockProvider" },
      unlinkInstitution: vi.fn(),
    } as any;

    mockSimpleFinProviderService = {
      convertSetupToken: vi.fn(),
    } as any;

    service = new UserService([mockProvider], mockSimpleFinProviderService);
  });

  afterEach(() => {
    Configuration.server.auth = originalAuth;
  });

  describe("allowUserCreation", () => {
    it("should return oidc allowNewUsers setting when auth type is oidc", async () => {
      Configuration.server.auth = {
        type: "oidc",
        oidc: { allowNewUsers: true },
      } as any;

      const result = await service.allowUserCreation();
      expect(result).toBe(true);
    });

    it("should return false when auth type is oidc and allowNewUsers is false", async () => {
      Configuration.server.auth = {
        type: "oidc",
        oidc: { allowNewUsers: false },
      } as any;

      const result = await service.allowUserCreation();
      expect(result).toBe(false);
    });

    it("should return true if auth type is not oidc and user count is 0", async () => {
      Configuration.server.auth = {
        type: "local",
      } as any;
      vi.spyOn(User, "count").mockResolvedValue(0);

      const result = await service.allowUserCreation();
      expect(result).toBe(true);
    });

    it("should return false if auth type is not oidc and user count is greater than 0", async () => {
      Configuration.server.auth = {
        type: "local",
      } as any;
      vi.spyOn(User, "count").mockResolvedValue(1);

      const result = await service.allowUserCreation();
      expect(result).toBe(false);
    });
  });

  describe("syncEncryptedFields", () => {
    it("should replace hidden values with existing values for encrypted properties", async () => {
      const existing = TestEntities.userConfig;
      existing.simpleFinToken = "encrypted_existing_token";

      const incoming = TestEntities.userConfig;
      incoming.simpleFinToken = EncryptionTransformer.HIDDEN_VALUE;

      vi.spyOn(EncryptionTransformer, "propertyIsEncrypted").mockImplementation((_obj, prop) => prop === "simpleFinToken");

      await service.syncEncryptedFields(incoming, existing);

      expect(incoming.simpleFinToken).toBe("encrypted_existing_token");
      expect(mockSimpleFinProviderService.convertSetupToken).not.toHaveBeenCalled();
    });

    it("should convert setup token for simpleFinToken if dynamic value is provided", async () => {
      const existing = TestEntities.userConfig;
      existing.simpleFinToken = "old_token";

      const incoming = TestEntities.userConfig;
      incoming.simpleFinToken = "new_setup_token";

      vi.spyOn(EncryptionTransformer, "propertyIsEncrypted").mockImplementation((_obj, prop) => prop === "simpleFinToken");
      mockSimpleFinProviderService.convertSetupToken.mockResolvedValue("converted_access_token");

      await service.syncEncryptedFields(incoming, existing);

      expect(mockSimpleFinProviderService.convertSetupToken).toHaveBeenCalledWith("new_setup_token");
      expect(incoming.simpleFinToken).toBe("converted_access_token");
    });

    it("should do nothing for non-encrypted properties or unhandled conditions", async () => {
      const existing = TestEntities.userConfig;
      existing.currency = CurrencyOptions.USD;

      const incoming = TestEntities.userConfig;
      incoming.currency = CurrencyOptions.EUR;

      vi.spyOn(EncryptionTransformer, "propertyIsEncrypted").mockReturnValue(false);

      await service.syncEncryptedFields(incoming, existing);

      expect(incoming.currency).toBe(CurrencyOptions.EUR);
      expect(mockSimpleFinProviderService.convertSetupToken).not.toHaveBeenCalled();
    });
  });

  describe("deleteUser", () => {
    let mockUser: User;

    beforeEach(() => {
      mockUser = TestEntities.user;
      mockUser.remove = vi.fn().mockResolvedValue(undefined);
    });

    it("should successfully unlink institutions and delete user", async () => {
      const mockInstitution = TestEntities.institution;
      vi.spyOn(Institution, "find").mockResolvedValue([mockInstitution]);
      mockProvider.unlinkInstitution.mockResolvedValue(true);

      await service.deleteUser(mockUser);

      expect(mockProvider.unlinkInstitution).toHaveBeenCalledWith(mockUser, mockInstitution.id);
      expect(mockUser.remove).toHaveBeenCalled();
    });

    it("should abort deletion if provider unlink returns false and forceDelete is false", async () => {
      const mockInstitution = TestEntities.institution;
      vi.spyOn(Institution, "find").mockResolvedValue([mockInstitution]);
      mockProvider.unlinkInstitution.mockResolvedValue(false);

      await expect(service.deleteUser(mockUser, false)).rejects.toThrow(InternalServerErrorException);
      expect(mockUser.remove).not.toHaveBeenCalled();
    });

    it("should proceed with deletion if provider unlink returns false but forceDelete is true", async () => {
      const mockInstitution = TestEntities.institution;
      vi.spyOn(Institution, "find").mockResolvedValue([mockInstitution]);
      mockProvider.unlinkInstitution.mockResolvedValue(false);

      await service.deleteUser(mockUser, true);

      expect(mockUser.remove).toHaveBeenCalled();
    });

    it("should rethrow InternalServerErrorException if thrown during unlink when forceDelete is false", async () => {
      const mockInstitution = TestEntities.institution;
      vi.spyOn(Institution, "find").mockResolvedValue([mockInstitution]);
      mockProvider.unlinkInstitution.mockRejectedValue(new InternalServerErrorException("API error"));

      await expect(service.deleteUser(mockUser, false)).rejects.toThrow(InternalServerErrorException);
      expect(mockUser.remove).not.toHaveBeenCalled();
    });

    it("should handle generic exception, log error, and abort deletion when forceDelete is false", async () => {
      const mockInstitution = TestEntities.institution;
      vi.spyOn(Institution, "find").mockResolvedValue([mockInstitution]);
      mockProvider.unlinkInstitution.mockRejectedValue(new Error("Network crash"));

      await expect(service.deleteUser(mockUser, false)).rejects.toThrow(InternalServerErrorException);
      expect(mockUser.remove).not.toHaveBeenCalled();
    });

    it("should handle generic exception and proceed with deletion when forceDelete is true", async () => {
      const mockInstitution = TestEntities.institution;
      vi.spyOn(Institution, "find").mockResolvedValue([mockInstitution]);
      mockProvider.unlinkInstitution.mockRejectedValue(new Error("Network crash"));

      await service.deleteUser(mockUser, true);

      expect(mockUser.remove).toHaveBeenCalled();
    });
  });
});
