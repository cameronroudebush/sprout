import { OIDCController } from "@backend/auth/auth.oidc.controller";
import { MobileTokenExchangeDto } from "@backend/auth/model/api/mobile.cookie.exchange.dto";
import { OIDCTokens } from "@backend/auth/model/oidc.tokens";
import { HttpService } from "@nestjs/axios";
import { CACHE_MANAGER } from "@nestjs/cache-manager";
import { BadRequestException, Logger, UnauthorizedException } from "@nestjs/common";
import { Test, TestingModule } from "@nestjs/testing";
import { Cache } from "cache-manager";
import { createHash } from "crypto";
import { Request, Response } from "express";
import { of, throwError } from "rxjs";
import { AuthService } from "./auth.service";

jest.mock("@backend/config/core", () => ({
  Configuration: {
    isDevBuild: false,
    server: {
      basePath: "/api/v1",
      auth: {
        oidc: {
          issuer: "https://identity.provider",
          clientId: "client-123",
          scopes: ["openid", "profile"],
          authHeader: "mockAuthHeader",
        },
      },
    },
    encryptionKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
  },
}));

describe("OIDCController", () => {
  let controller: OIDCController;
  let authService: jest.Mocked<AuthService>;
  let httpService: jest.Mocked<HttpService>;
  let cacheManager: jest.Mocked<Cache>;

  const mockResponse = () => {
    const res = {} as Partial<Response>;
    res.cookie = jest.fn().mockReturnThis();
    res.clearCookie = jest.fn().mockReturnThis();
    res.redirect = jest.fn().mockReturnThis();
    return res as Response;
  };

  const mockRequest = (signedCookies = {}) => ({ signedCookies }) as unknown as Request;

  beforeAll(() => {
    // Suppress log outputs during unit tests
    jest.spyOn(Logger.prototype, "log").mockImplementation(() => {});
    jest.spyOn(Logger.prototype, "error").mockImplementation(() => {});
    jest.spyOn(Logger.prototype, "warn").mockImplementation(() => {});
    jest.spyOn(Logger.prototype, "debug").mockImplementation(() => {});
  });

  beforeEach(async () => {
    const mockAuthService = {
      isValidRedirectUrl: jest.fn(),
      setCookieTokens: jest.fn(),
    };
    const mockHttpService = { post: jest.fn() };
    const mockCacheManager = { set: jest.fn(), get: jest.fn(), del: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [OIDCController],
      providers: [
        { provide: AuthService, useValue: mockAuthService },
        { provide: HttpService, useValue: mockHttpService },
        { provide: CACHE_MANAGER, useValue: mockCacheManager },
      ],
    }).compile();

    controller = module.get<OIDCController>(OIDCController);
    authService = module.get(AuthService);
    httpService = module.get(HttpService);
    cacheManager = module.get(CACHE_MANAGER);

    (AuthService as any).ALLOWED_MOBILE_SCHEME = "myapp://";
  });

  describe("loginOIDC", () => {
    const targetUrl = "https://example.com/dashboard";
    const publicUrl = "https://api.example.com";
    const challenge = "appChallengeBase64";

    it("should initialize redirect and set secure pending cookie when redirect URL is valid", async () => {
      authService.isValidRedirectUrl.mockReturnValue(true);
      const res = mockResponse();

      await controller.loginOIDC(targetUrl, challenge, res, publicUrl);

      expect(authService.isValidRedirectUrl).toHaveBeenCalledWith(targetUrl, publicUrl);
      expect(res.cookie).toHaveBeenCalledWith(
        "oidc_pending",
        expect.any(String),
        expect.objectContaining({
          httpOnly: true,
          signed: true,
          secure: true,
        }),
      );
      expect(res.redirect).toHaveBeenCalledWith(expect.stringContaining("https://identity.provider/api/oidc/authorization"));
    });

    it("should reject login sequence with BadRequestException if redirect URL is invalid", async () => {
      authService.isValidRedirectUrl.mockReturnValue(false);
      const res = mockResponse();

      await expect(controller.loginOIDC("https://malicious.com", challenge, res, publicUrl)).rejects.toThrow(BadRequestException);
    });
  });

  describe("loginCallbackOIDC", () => {
    const publicUrl = "https://api.example.com";
    const pendingCookieData = {
      state: "state123",
      codeVerifier: "verifier123",
      targetUrl: "https://example.com/dashboard",
      redirectUri: "https://api.example.com/api/v1/auth/oidc/callback",
      appChallenge: "challenge123",
    };

    it("should throw UnauthorizedException if pending state cookie does not exist", async () => {
      const req = mockRequest({});
      const res = mockResponse();

      await expect(controller.loginCallbackOIDC("code", "state123", req, res, publicUrl)).rejects.toThrow(new UnauthorizedException("Session expired"));
    });

    it("should throw UnauthorizedException if query state does not match stored state", async () => {
      const req = mockRequest({ oidc_pending: JSON.stringify(pendingCookieData) });
      const res = mockResponse();

      await expect(controller.loginCallbackOIDC("code", "wrongState", req, res, publicUrl)).rejects.toThrow(new UnauthorizedException("State mismatch"));
    });

    it("should clear cookie, append cookies and redirect web applications successfully", async () => {
      const req = mockRequest({ oidc_pending: JSON.stringify(pendingCookieData) });
      const res = mockResponse();
      authService.isValidRedirectUrl.mockReturnValue(true);
      httpService.post.mockReturnValue(
        of({
          data: { id_token: "id", access_token: "access", refresh_token: "refresh" },
        } as any),
      );

      await controller.loginCallbackOIDC("code", "state123", req, res, publicUrl);

      expect(res.clearCookie).toHaveBeenCalledWith("oidc_pending");
      expect(authService.setCookieTokens).toHaveBeenCalledWith(res, "id", "access", "refresh");
      expect(res.redirect).toHaveBeenCalledWith("https://example.com/dashboard");
    });

    it("should set up cache handoff and redirect with handoff code when destination is mobile", async () => {
      const mobileCookieData = { ...pendingCookieData, targetUrl: "myapp://login-landing" };
      const req = mockRequest({ oidc_pending: JSON.stringify(mobileCookieData) });
      const res = mockResponse();
      authService.isValidRedirectUrl.mockReturnValue(true);
      httpService.post.mockReturnValue(
        of({
          data: { id_token: "id", access_token: "access", refresh_token: "refresh" },
        } as any),
      );

      await controller.loginCallbackOIDC("code", "state123", req, res, publicUrl);

      expect(cacheManager.set).toHaveBeenCalledWith(expect.stringContaining("handoff:"), expect.any(OIDCTokens), 30000);
      expect(res.redirect).toHaveBeenCalledWith(expect.stringContaining("myapp://login-landing?code="));
    });

    it("should intercept callback and throw if redirect URL validation fails post-token exchange", async () => {
      const req = mockRequest({ oidc_pending: JSON.stringify(pendingCookieData) });
      const res = mockResponse();
      authService.isValidRedirectUrl.mockReturnValue(false);
      httpService.post.mockReturnValue(of({ data: {} } as any));

      await expect(controller.loginCallbackOIDC("code", "state123", req, res, publicUrl)).rejects.toThrow(new UnauthorizedException("Auth failed"));
    });

    it("should raise UnauthorizedException if token endpoint returns an error", async () => {
      const req = mockRequest({ oidc_pending: JSON.stringify(pendingCookieData) });
      const res = mockResponse();
      httpService.post.mockReturnValue(throwError(() => new Error("Network Error")));

      await expect(controller.loginCallbackOIDC("code", "state123", req, res, publicUrl)).rejects.toThrow(new UnauthorizedException("Auth failed"));
    });
  });

  describe("exchange", () => {
    const appVerifier = "mySecretVerifierString";
    const appChallenge = createHash("sha256").update(appVerifier).digest("base64url");
    const mockTokens = new OIDCTokens("id", "access", "refresh", appChallenge);

    it("should throw BadRequestException if handoff code parameter is omitted", async () => {
      const dto = { appVerifier } as MobileTokenExchangeDto;
      const res = mockResponse();
      const req = mockRequest();

      await expect(controller.exchange(dto, req, res)).rejects.toThrow(BadRequestException);
    });

    it("should throw BadRequestException if appVerifier parameter is omitted", async () => {
      const dto = { code: "handoff123" } as MobileTokenExchangeDto;
      const res = mockResponse();
      const req = mockRequest();

      await expect(controller.exchange(dto, req, res)).rejects.toThrow(BadRequestException);
    });

    it("should throw UnauthorizedException if handoff code is missing or expired in cache", async () => {
      const dto = { code: "expiredCode", appVerifier };
      const res = mockResponse();
      const req = mockRequest();
      cacheManager.get.mockResolvedValue(null);

      await expect(controller.exchange(dto, req, res)).rejects.toThrow(new UnauthorizedException("Invalid or expired exchange code"));
    });

    it("should burn the handoff code and throw UnauthorizedException if crypto signature challenge validation fails", async () => {
      const dto = { code: "handoff123", appVerifier: "wrongVerifier" };
      const res = mockResponse();
      const req = mockRequest();
      cacheManager.get.mockResolvedValue(mockTokens);

      await expect(controller.exchange(dto, req, res)).rejects.toThrow(new UnauthorizedException("Invalid app verifier"));
      expect(cacheManager.del).toHaveBeenCalledWith("handoff:handoff123");
    });

    it("should successfully populate client cookies when security context verification matches", async () => {
      const dto = { code: "handoff123", appVerifier };
      const res = mockResponse();
      const req = mockRequest();
      cacheManager.get.mockResolvedValue(mockTokens);

      await controller.exchange(dto, req, res);

      expect(cacheManager.del).toHaveBeenCalledWith("handoff:handoff123");
      expect(authService.setCookieTokens).toHaveBeenCalledWith(res, "id", "access", "refresh");
    });
  });
});
