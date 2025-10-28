import { Injectable, Logger, NestMiddleware } from "@nestjs/common";
import { NextFunction, Request, Response } from "express";

/** A logging middleware that logs HTTP requests */
@Injectable()
export class RequestLoggerMiddleware implements NestMiddleware {
  private logger = new Logger("HTTP");

  use(request: Request, response: Response, next: NextFunction): void {
    const { ip, method, originalUrl } = request;

    response.on("close", () => {
      const { statusCode } = response;
      const contentLength = response.get("content-length");

      this.logger.verbose(`${method} ${originalUrl} ${statusCode} ${contentLength ?? 0} - ${ip}`);
    });

    next();
  }
}
