import { Injectable, Logger, NestMiddleware } from "@nestjs/common";
import { NextFunction, Request, Response } from "express";

/** A logging middleware that logs HTTP requests */
@Injectable()
export class RequestLoggerMiddleware implements NestMiddleware {
  private logger = new Logger("HTTP");

  use(request: Request, response: Response, next: NextFunction): void {
    const { ip, method, originalUrl } = request;
    if (originalUrl.startsWith("/api/core/heartbeat") && ip?.endsWith("127.0.0.1")) {
      // Don't log heartbeat requests if coming from internal. These are normally caused by health checks
    } else {
      const startBytes = request.socket ? request.socket.bytesWritten : 0;
      response.on("finish", () => {
        const { statusCode } = response;
        let contentLength = response.get("content-length");
        if (!contentLength && request.socket) contentLength = (request.socket.bytesWritten - startBytes).toString();
        this.logger.verbose(`${method} ${originalUrl} ${statusCode} ${contentLength ?? 0} - ${ip}`);
      });
    }

    next();
  }
}
