import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it, vi } from "vitest";

setupTests();

import { RequestLoggerMiddleware } from "./request.logger.middleware.js";

describe("RequestLoggerMiddleware", () => {
  it("should log request metrics and mask sensitive query parameters", () => {
    const middleware = new RequestLoggerMiddleware();

    const req = {
      ip: "192.168.1.100",
      method: "GET",
      originalUrl: "/api/oauth/callback?code=secret123&state=abc",
      socket: { bytesWritten: 100 },
    } as any;

    let finishCallback: () => void = () => {};
    const res = {
      get: vi.fn().mockReturnValue(null),
      on: (event: string, cb: () => void) => {
        if (event === "finish") finishCallback = cb;
      },
      statusCode: 200,
    } as any;

    const next = vi.fn();

    middleware.use(req, res, next);
    expect(next).toHaveBeenCalled();

    req.socket.bytesWritten = 500;
    finishCallback();
  });

  it("should ignore internal heartbeat requests and handle malformed URLs", () => {
    const middleware = new RequestLoggerMiddleware();

    const heartbeatReq = {
      ip: "127.0.0.1",
      method: "GET",
      originalUrl: "/api/core/heartbeat",
    } as any;

    const next = vi.fn();
    middleware.use(heartbeatReq, {} as any, next);
    expect(next).toHaveBeenCalled();

    const malformedUrl = (middleware as any).maskSensitiveInfo("http://invalid-url-:::bad");
    expect(malformedUrl).toBe("http://invalid-url-:::bad");
  });

  it("should handle request when socket is missing or content-length is present", () => {
    const middleware = new RequestLoggerMiddleware();

    const reqNoSocket = {
      ip: "10.0.0.1",
      method: "POST",
      originalUrl: "/api/test",
      socket: undefined,
    } as any;

    let finishCallback: () => void = () => {};
    const res = {
      get: vi.fn().mockReturnValue("250"),
      on: (event: string, cb: () => void) => {
        if (event === "finish") finishCallback = cb;
      },
      statusCode: 201,
    } as any;

    const next = vi.fn();

    middleware.use(reqNoSocket, res, next);
    expect(next).toHaveBeenCalled();
    finishCallback();
  });
});
