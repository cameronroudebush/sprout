import { setupTests } from "@backend/test/helpers";
setupTests();

import { AuthService } from "@backend/auth/auth.service";
import { OIDCIDTokenIntrospectionResult } from "@backend/auth/model/oidc.introspection";
import { OIDCTokens } from "@backend/auth/model/oidc.tokens";
import { OIDCStrategy } from "@backend/auth/strategy/oidc.strategy";
import { Configuration } from "@backend/config/core";
import { User } from "@backend/user/model/user.model";
import { UserSetupContext } from "@backend/user/model/user.setup.context.model";
import { HttpService } from "@nestjs/axios";
import { Cache } from "@nestjs/cache-manager";
import { HttpException, UnauthorizedException } from "@nestjs/common";
import { Request } from "express";
import { of, throwError } from "rxjs";

describe("OIDCStrategy", () => {
  let strategy: OIDCStrategy;
  let httpService: jest.Mocked<HttpService>;
  let authService: jest.Mocked<AuthService>;
  let cacheManager: jest.Mocked<Cache>;
  let mockRequest: any;
  let tokenPayload: any;

  beforeEach(() => {
    jest.clearAllMocks();

    httpService = {
      get: jest.fn(),
    } as any;

    authService = {
      performOIDCRefresh: jest.fn(),
      getCookie: jest.fn(),
    } as any;

    cacheManager = {
      get: jest.fn(),
      set: jest.fn(),
    } as any;

    mockRequest = {
      res: {},
    };

    tokenPayload = {
      issuer: "https://identity.provider.local",
      authorizedParty: "app-client-id",
    };

    strategy = new OIDCStrategy(httpService, authService, cacheManager);
  });

  describe("Constructor Configuration fallbacks", () => {
    it("should instantiate correctly with blank credentials using default string placeholders", () => {
      const originalOidc = Configuration.server.auth.oidc;
      Configuration.server.auth.oidc = {} as any;

      const fallbackStrategy = new OIDCStrategy(httpService, authService, cacheManager);
      expect(fallbackStrategy).toBeDefined();

      Configuration.server.auth.oidc = originalOidc;
    });
  });

  describe("validate", () => {
    it("should execute standard profiling validation, retrieve user info via cookie token path, and complete login flow", async () => {
      const mockProfileIntrospect = {
        issuer: "https://identity.provider.local",
        authorizedParty: "app-client-id",
        isExpired: false,
        checkIssuedState: jest.fn(),
      } as any;
      jest.spyOn(OIDCIDTokenIntrospectionResult, "fromPlain").mockReturnValue(mockProfileIntrospect);

      authService.getCookie.mockReturnValue("valid-cookie-access-token");
      cacheManager.get.mockResolvedValue({
        sub: "user-uuid",
        preferred_username: "john_doe",
        email: "john@domain.local",
      });

      const mockDbUser = User.fromPlain({ id: "user-uuid", username: "john_doe" });
      jest.spyOn(User, "findOne").mockResolvedValue(mockDbUser);

      const result = await strategy.validate(mockRequest as Request, tokenPayload);

      expect(mockProfileIntrospect.checkIssuedState).toHaveBeenCalled();
      expect(authService.getCookie).toHaveBeenCalledWith("access", mockRequest);
      expect(cacheManager.get).toHaveBeenCalledWith("oidc_user_valid-cookie-access-token");
      expect(mockRequest.setupUser).toBeInstanceOf(UserSetupContext);
      expect(result).toBe(mockDbUser);
    });

    it("should invoke refresh orchestration when token reports expired and successfully recover with updated access credentials", async () => {
      const mockProfileIntrospect = {
        issuer: "https://identity.provider.local",
        authorizedParty: "app-client-id",
        isExpired: true,
        checkIssuedState: jest.fn(),
      } as any;
      jest.spyOn(OIDCIDTokenIntrospectionResult, "fromPlain").mockReturnValue(mockProfileIntrospect);

      authService.performOIDCRefresh.mockResolvedValue(OIDCTokens.fromPlain({ accessToken: "freshly-minted-token" }));
      cacheManager.get.mockResolvedValue({
        sub: "user-uuid",
        preferred_username: "john_doe",
        email: "john@domain.local",
      });

      const mockDbUser = User.fromPlain({ id: "user-uuid", username: "john_doe" });
      jest.spyOn(User, "findOne").mockResolvedValue(mockDbUser);

      const result = await strategy.validate(mockRequest as Request, tokenPayload);

      expect(authService.performOIDCRefresh).toHaveBeenCalledWith(mockRequest, mockRequest.res);
      expect(cacheManager.get).toHaveBeenCalledWith("oidc_user_freshly-minted-token");
      expect(result).toBe(mockDbUser);
    });

    it("should throw UnauthorizedException if refresh process triggers an unexpected downstream internal failure", async () => {
      const mockProfileIntrospect = {
        issuer: "https://identity.provider.local",
        authorizedParty: "app-client-id",
        isExpired: true,
        checkIssuedState: jest.fn(),
      } as any;
      jest.spyOn(OIDCIDTokenIntrospectionResult, "fromPlain").mockReturnValue(mockProfileIntrospect);

      authService.performOIDCRefresh.mockRejectedValue(new Error("Network drop"));

      await expect(strategy.validate(mockRequest as Request, tokenPayload)).rejects.toThrow(new UnauthorizedException("Session expired."));
    });

    it("should throw UnauthorizedException if fetched profile payload contains an empty username descriptor", async () => {
      const mockProfileIntrospect = {
        issuer: "https://identity.provider.local",
        authorizedParty: "app-client-id",
        isExpired: false,
        checkIssuedState: jest.fn(),
      } as any;
      jest.spyOn(OIDCIDTokenIntrospectionResult, "fromPlain").mockReturnValue(mockProfileIntrospect);

      authService.getCookie.mockReturnValue("token");
      cacheManager.get.mockResolvedValue({ sub: "user-uuid" });

      await expect(strategy.validate(mockRequest as Request, tokenPayload)).rejects.toThrow(
        new UnauthorizedException("Could not determine username from token."),
      );
    });

    it("should throw UnauthorizedException if client profile details are sound but database profile linkage is missing", async () => {
      const mockProfileIntrospect = {
        issuer: "https://identity.provider.local",
        authorizedParty: "app-client-id",
        isExpired: false,
        checkIssuedState: jest.fn(),
      } as any;
      jest.spyOn(OIDCIDTokenIntrospectionResult, "fromPlain").mockReturnValue(mockProfileIntrospect);

      authService.getCookie.mockReturnValue("token");
      cacheManager.get.mockResolvedValue({
        sub: "user-absent",
        preferred_username: "ghost_rider",
        email: "ghost@domain.local",
      });

      jest.spyOn(User, "findOne").mockResolvedValue(null);

      await expect(strategy.validate(mockRequest as Request, tokenPayload)).rejects.toThrow(new UnauthorizedException("User ghost_rider not found"));
    });
  });

  describe("getUserInfo", () => {
    it("should hit remote identity provider endpoints to query user data on cache misses and commit records to store", async () => {
      const mockProfileIntrospect = {
        issuer: "https://identity.provider.local",
        authorizedParty: "app-client-id",
        isExpired: false,
        checkIssuedState: jest.fn(),
      } as any;
      jest.spyOn(OIDCIDTokenIntrospectionResult, "fromPlain").mockReturnValue(mockProfileIntrospect);

      authService.getCookie.mockReturnValue("fetch-token");
      cacheManager.get.mockResolvedValue(null);

      const apiPayload = {
        sub: "user-uuid",
        preferred_username: "john_doe",
        email: "john@domain.local",
      };
      httpService.get.mockReturnValue(of({ status: 200, data: apiPayload } as any));
      jest.spyOn(User, "findOne").mockResolvedValue(User.fromPlain({}));

      await strategy.validate(mockRequest as Request, tokenPayload);

      expect(httpService.get).toHaveBeenCalledWith("https://identity.provider.local/api/oidc/userinfo", {
        headers: { Authorization: "Bearer fetch-token" },
      });
      expect(cacheManager.set).toHaveBeenCalledWith("oidc_user_fetch-token", apiPayload, 300000);
    });

    it("should throw HttpException when upstream network responds with non-200 operational feedback", async () => {
      const mockProfileIntrospect = {
        issuer: "https://identity.provider.local",
        authorizedParty: "app-client-id",
        isExpired: false,
        checkIssuedState: jest.fn(),
      } as any;
      jest.spyOn(OIDCIDTokenIntrospectionResult, "fromPlain").mockReturnValue(mockProfileIntrospect);

      authService.getCookie.mockReturnValue("bad-token");
      cacheManager.get.mockResolvedValue(null);

      await expect(strategy.validate(mockRequest as Request, tokenPayload)).rejects.toThrow(
        new UnauthorizedException("Could not determine username from token."),
      );
    });

    it("should capture and process remote Axios exceptions gracefully passing error particulars up the call stack", async () => {
      const mockProfileIntrospect = {
        issuer: "https://identity.provider.local",
        authorizedParty: "app-client-id",
        isExpired: false,
        checkIssuedState: jest.fn(),
      } as any;
      jest.spyOn(OIDCIDTokenIntrospectionResult, "fromPlain").mockReturnValue(mockProfileIntrospect);

      authService.getCookie.mockReturnValue("axios-fail-token");
      cacheManager.get.mockResolvedValue(null);

      const axiosErrorObj = {
        isAxiosError: true,
        message: "Forbidden endpoint access",
        status: 403,
        response: { status: 403 },
      };
      httpService.get.mockReturnValue(throwError(() => axiosErrorObj));

      await expect(strategy.validate(mockRequest as Request, tokenPayload)).rejects.toThrow(new HttpException("Forbidden endpoint access", 403));
    });

    it("should ignore and swallow outer generic non-Axios communication crash loops without blowing up mapping handlers", async () => {
      const mockProfileIntrospect = {
        issuer: "https://identity.provider.local",
        authorizedParty: "app-client-id",
        isExpired: false,
        checkIssuedState: jest.fn(),
      } as any;
      jest.spyOn(OIDCIDTokenIntrospectionResult, "fromPlain").mockReturnValue(mockProfileIntrospect);

      authService.getCookie.mockReturnValue("generic-fail-token");
      cacheManager.get.mockResolvedValue(null);

      httpService.get.mockReturnValue(throwError(() => new Error("Fatal hardware drop")));

      await expect(strategy.validate(mockRequest as Request, tokenPayload)).rejects.toThrow(
        new UnauthorizedException("Could not determine username from token."),
      );
    });
  });
});
