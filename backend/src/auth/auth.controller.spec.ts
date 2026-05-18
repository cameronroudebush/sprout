import { User } from "@backend/user/model/user.model";
import { Test, TestingModule } from "@nestjs/testing";
import { Request, Response } from "express";
import { AuthController } from "./auth.controller";
import { AuthService } from "./auth.service";
import { UsernamePasswordLoginRequest } from "./model/api/login.request.dto";

describe("AuthController", () => {
  let controller: AuthController;
  let authService: jest.Mocked<AuthService>;

  const mockResponse = () => {
    const res = {} as Partial<Response>;
    res.status = jest.fn().mockReturnThis();
    res.json = jest.fn().mockReturnThis();
    return res as Response;
  };

  const mockRequest = () => ({}) as Request;

  beforeEach(async () => {
    const mockAuthService = {
      login: jest.fn(),
      setCookieTokens: jest.fn(),
      clearAllCookieTokens: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [
        {
          provide: AuthService,
          useValue: mockAuthService,
        },
      ],
    }).compile();

    controller = module.get<AuthController>(AuthController);
    authService = module.get(AuthService);
  });

  it("should be defined", () => {
    expect(controller).toBeDefined();
  });

  describe("login", () => {
    const loginDto = UsernamePasswordLoginRequest.fromPlain({
      username: "testuser",
      password: "password123",
    });
    const mockUser = { id: "1", username: "testuser" } as User;
    const mockJwt = { accessToken: "abc", refreshToken: "xyz" };

    it("should successfully log in a user and set cookies", async () => {
      authService.login.mockResolvedValue({ user: mockUser, jwt: mockJwt.accessToken });
      const res = mockResponse();
      const req = mockRequest();

      const result = await controller.login(loginDto, res, req);

      expect(authService.login).toHaveBeenCalledWith(loginDto);
      expect(authService.setCookieTokens).toHaveBeenCalledWith(res, mockJwt.accessToken);
      expect(result).toEqual(mockUser);
    });

    it("should propagate errors thrown by authService.login", async () => {
      authService.login.mockRejectedValue(new Error("Unauthorized"));
      const res = mockResponse();
      const req = mockRequest();

      await expect(controller.login(loginDto, res, req)).rejects.toThrow("Unauthorized");
      expect(authService.setCookieTokens).not.toHaveBeenCalled();
    });
  });

  describe("logout", () => {
    it("should clear cookies and return success", async () => {
      const res = mockResponse();

      const result = await controller.logout(res);

      expect(authService.clearAllCookieTokens).toHaveBeenCalledWith(res);
      expect(result).toEqual({ success: true });
    });
  });
});
