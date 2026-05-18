import { UsernamePasswordLoginRequest } from "@backend/auth/model/api/login.request.dto";
import { OIDCTokens } from "@backend/auth/model/oidc.tokens";
import { User } from "@backend/user/model/user.model";
import { HttpService } from "@nestjs/axios";
import { HttpException, Logger, UnauthorizedException } from "@nestjs/common";
import { Test, TestingModule } from "@nestjs/testing";
import { Request, Response } from "express";
import jwt from "jsonwebtoken";
import { of, throwError } from "rxjs";
import { AuthService } from "./auth.service";

jest.mock("@backend/config/core", () => ({
  Configuration: {
    isDevBuild: false,
    server: {
      auth: {
        secretKey: "test-secret",
        local: { jwtExpirationTime: "1h" },
        oidc: {
          issuer: "https://identity.provider",
          authHeader: "mockAuthHeader",
        },
      },
    },
    encryptionKey: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
  },
}));

jest.mock("jsonwebtoken");
jest.mock("@backend/user/model/user.model");

describe("AuthService", () => {
  let service: AuthService;
  let httpService: jest.Mocked<HttpService>;

  const mockResponse = () => {
    const res = {} as Partial<Response>;
    res.cookie = jest.fn().mockReturnThis();
    res.clearCookie = jest.fn().mockReturnThis();
    return res as Response;
  };

  const mockRequest = (cookies = {}, headers = {}) => ({ cookies, headers }) as unknown as Request;

  beforeAll(() => {
    jest.spyOn(Logger.prototype, "log").mockImplementation(() => {});
    jest.spyOn(Logger.prototype, "error").mockImplementation(() => {});
    jest.spyOn(Logger.prototype, "warn").mockImplementation(() => {});
    jest.spyOn(Logger.prototype, "debug").mockImplementation(() => {});
  });

  beforeEach(async () => {
    const mockHttpService = { post: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [AuthService, { provide: HttpService, useValue: mockHttpService }],
    }).compile();

    service = module.get<AuthService>(AuthService);
    httpService = module.get(HttpService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe("getCookie", () => {
    it("should resolve id token cookie correctly", () => {
      const req = mockRequest({ id: "id-val" });
      expect(service.getCookie("id", req)).toBe("id-val");
    });

    it("should resolve access token cookie correctly", () => {
      const req = mockRequest({ at: "at-val" });
      expect(service.getCookie("access", req)).toBe("at-val");
    });

    it("should resolve refresh token from cookie or fall back to x-refresh-token header", () => {
      const reqWithCookie = mockRequest({ r: "refresh-cookie" });
      const reqWithHeader = mockRequest({}, { "x-refresh-token": "refresh-header" });

      expect(service.getCookie("refresh", reqWithCookie)).toBe("refresh-cookie");
      expect(service.getCookie("refresh", reqWithHeader)).toBe("refresh-header");
    });
  });

  describe("clearAllCookieTokens", () => {
    it("should clear id, access, and refresh tokens from response object", () => {
      const res = mockResponse();
      service.clearAllCookieTokens(res);
      expect(res.clearCookie).toHaveBeenCalledWith("id");
      expect(res.clearCookie).toHaveBeenCalledWith("at");
      expect(res.clearCookie).toHaveBeenCalledWith("r");
    });
  });

  describe("setCookieTokens", () => {
    it("should write token cookies with strict flags and omit undefined parameters", () => {
      const res = mockResponse();
      service.setCookieTokens(res, "id-val");
      expect(res.cookie).toHaveBeenCalledTimes(1);
      expect(res.cookie).toHaveBeenCalledWith("id", "id-val", { httpOnly: true, secure: true, sameSite: "strict" });
    });

    it("should write all cookies when all parameters are provided", () => {
      const res = mockResponse();
      service.setCookieTokens(res, "id-val", "at-val", "r-val");
      expect(res.cookie).toHaveBeenCalledTimes(3);
    });
  });

  describe("login", () => {
    const loginDto = UsernamePasswordLoginRequest.fromPlain({ username: "user", password: "pwd" });

    it("should throw UnauthorizedException if matching user entity does not exist", async () => {
      (User.findOne as jest.Mock).mockResolvedValue(null);
      await expect(service.login(loginDto)).rejects.toThrow(UnauthorizedException);
    });

    it("should throw UnauthorizedException if password validation routine fails", async () => {
      const mockUserInstance = { password: "hashed_password", verifyPassword: jest.fn().mockReturnValue(false) };
      (User.findOne as jest.Mock).mockResolvedValue(mockUserInstance);

      await expect(service.login(loginDto)).rejects.toThrow(UnauthorizedException);
    });

    it("should log in user and return signed token upon valid password evaluation", async () => {
      const mockUserInstance = { username: "user", password: "hashed_password", verifyPassword: jest.fn().mockReturnValue(true) };
      (User.findOne as jest.Mock).mockResolvedValue(mockUserInstance);
      (jwt.sign as jest.Mock).mockReturnValue("signed-jwt");

      const result = await service.login(loginDto);
      expect(result.user).toBe(mockUserInstance);
      expect(result.jwt).toBe("signed-jwt");
    });
  });

  describe("loginWithJWT", () => {
    it("should throw UnauthorizedException if input token verification throws", async () => {
      (jwt.verify as jest.Mock).mockImplementation(() => {
        throw new Error();
      });
      await expect(service.loginWithJWT("bad-jwt")).rejects.toThrow(UnauthorizedException);
    });

    it("should extract username, find user entity, and return a freshly signed token", async () => {
      (jwt.verify as jest.Mock).mockReturnValue({});
      (jwt.decode as jest.Mock).mockReturnValue({ username: "user" });
      const mockUserInstance = { username: "user", password: "pwd" };
      (User.findOne as jest.Mock).mockResolvedValue(mockUserInstance);
      (jwt.sign as jest.Mock).mockReturnValue("new-jwt");

      const result = await service.loginWithJWT("old-jwt");
      expect(result.user).toBe(mockUserInstance);
      expect(result.jwt).toBe("new-jwt");
    });

    it("should fail validation if verification works but database entity lookup returns null", async () => {
      (jwt.verify as jest.Mock).mockReturnValue({});
      (jwt.decode as jest.Mock).mockReturnValue({ username: "ghost" });
      (User.findOne as jest.Mock).mockResolvedValue(null);

      await expect(service.loginWithJWT("old-jwt")).rejects.toThrow(UnauthorizedException);
    });
  });

  describe("verifyJWT", () => {
    it("should throw basic error if parameter is null or empty", () => {
      expect(() => service.verifyJWT("")).toThrow("Invalid JWT");
    });
  });

  describe("isValidRedirectUrl", () => {
    const publicUrl = "https://app.mysite.com";

    it("should match against permitted patterns and return correct booleans", () => {
      expect(service.isValidRedirectUrl("", publicUrl)).toBe(false);
      expect(service.isValidRedirectUrl("/relative-path", publicUrl)).toBe(true);
      expect(service.isValidRedirectUrl("net.croudebush.sprout://callback", publicUrl)).toBe(true);
      expect(service.isValidRedirectUrl("https://app.mysite.com/dashboard", publicUrl)).toBe(true);
      expect(service.isValidRedirectUrl("https://malicious.com/dashboard", publicUrl)).toBe(false);
      expect(service.isValidRedirectUrl("invalid-url-string", publicUrl)).toBe(false);
    });
  });

  describe("getPlatform", () => {
    it("should fetch platform metadata out of the incoming custom client platform headers", () => {
      const req = mockRequest({}, { "x-client-platform": "mobile" });
      expect(service.getPlatform(req)).toBe("mobile");
    });
  });

  describe("performOIDCRefresh", () => {
    beforeEach(() => {
      // Force all tests in this block to use fake timers natively
      jest.useFakeTimers();
    });

    afterEach(() => {
      // Instantly resolve the 10-second setTimeout in the finally block to prevent memory leaks
      jest.runAllTimers();
      jest.useRealTimers();
    });

    it("should throw UnauthorizedException if query yields no usable refresh token asset", async () => {
      const req = mockRequest();
      await expect(service.performOIDCRefresh(req)).rejects.toThrow(UnauthorizedException);
    });

    it("should execute HTTP exchange pipeline and commit parsed data payloads into cookies", async () => {
      const req = mockRequest({ r: "refresh-token-123" });
      const res = mockResponse();
      httpService.post.mockReturnValue(
        of({
          status: 200,
          data: { id_token: "id", access_token: "at", refresh_token: "r" },
        } as any),
      );

      const result = await service.performOIDCRefresh(req, res);
      expect(result).toBeInstanceOf(OIDCTokens);
      expect(res.cookie).toHaveBeenCalledWith("id", "id", expect.any(Object));
    });

    it("should deduplicate simultaneous execution paths and bind callers to a shared pending promise", async () => {
      const req = mockRequest({ r: "refresh-token-concurrent" });
      httpService.post.mockReturnValue(
        of({
          status: 200,
          data: { id_token: "shared-id" },
        } as any),
      );

      const [res1, res2] = await Promise.all([service.performOIDCRefresh(req), service.performOIDCRefresh(req)]);

      expect(httpService.post).toHaveBeenCalledTimes(1);
      expect(res1.idToken).toBe("shared-id");
      expect(res2.idToken).toBe("shared-id");
    });

    it("should flush promise entries cleanly out of tracking structures after the 10-second buffer phase", async () => {
      const req = mockRequest({ r: "refresh-token-cleanup" });
      httpService.post.mockReturnValue(of({ status: 200, data: {} } as any));

      await service.performOIDCRefresh(req);
      httpService.post.mockClear();

      jest.advanceTimersByTime(10000);

      await service.performOIDCRefresh(req);
      expect(httpService.post).toHaveBeenCalledTimes(1);
    });

    it("should throw error if underlying target server responds with non-200 transaction signals", async () => {
      const req = mockRequest({ r: "refresh-token-fail" });
      httpService.post.mockReturnValue(of({ status: 400, statusText: "Bad Request" } as any));

      await expect(service.performOIDCRefresh(req)).rejects.toThrow(HttpException);
    });

    it("should normalize and bubble up Axios network transaction failures into standardized auth faults", async () => {
      const req = mockRequest({ r: "refresh-token-axios-fail" });
      const axiosError = { isAxiosError: true, response: { data: { error_description: "Invalid Token" } }, message: "Axios Error" };
      httpService.post.mockReturnValue(throwError(() => axiosError));

      await expect(service.performOIDCRefresh(req)).rejects.toThrow(UnauthorizedException);
    });
  });

  describe("introspectToken", () => {
    it("should parse and return remote provider introspection states upon connectivity success", async () => {
      httpService.post.mockReturnValue(of({ data: { active: true, exp: 200000 } } as any));
      const result = await service.introspectToken("token");
      expect(result.isExpired).toBe(true);
    });

    it("should handle error conditions cleanly and return an inactive fallback configuration object", async () => {
      httpService.post.mockReturnValue(throwError(() => new Error("Network Down")));
      const result = await service.introspectToken("token");
      expect(result.isExpired).toBe(true);
    });
  });
});
