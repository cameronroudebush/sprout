import { setupTests } from "@backend/test/helpers";
setupTests();

import { RequestLoggerMiddleware } from "@backend/core/middleware/request.logger.middleware";

describe("RequestLoggerMiddleware", () => {
  let middleware: RequestLoggerMiddleware;

  beforeEach(() => {
    middleware = new RequestLoggerMiddleware();
  });

  describe("use", () => {
    it("should log request and invoke next function", () => {
      const req = { method: "GET", originalUrl: "/api/test", ip: "127.0.0.1", socket: { bytesWritten: 500 } };
      const res = { statusCode: 200, get: jest.fn().mockReturnValue("100"), on: jest.fn((_event, cb) => cb()) };
      const next = jest.fn();

      middleware.use(req as any, res as any, next);

      expect(next).toHaveBeenCalled();
      expect(res.on).toHaveBeenCalledWith("finish", expect.any(Function));
    });
  });
});
