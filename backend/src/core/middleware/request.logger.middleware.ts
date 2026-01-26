import { Injectable, Logger, NestMiddleware } from "@nestjs/common";
import { NextFunction, Request, Response } from "express";

/** A logging middleware that logs HTTP requests */
@Injectable()
export class RequestLoggerMiddleware implements NestMiddleware {
  private logger = new Logger("HTTP");
  private readonly sensitiveParams = ["code", "access_token", "id_token", "state", "refresh_token"];

  use(request: Request, response: Response, next: NextFunction): void {
    const { ip, method, originalUrl } = request;
    const sanitizedUrl = this.maskSensitiveInfo(originalUrl);

    response.on("close", () => {
      const { statusCode } = response;
      const contentLength = response.get("content-length");

      this.logger.verbose(`${method} ${sanitizedUrl} ${statusCode} ${contentLength ?? 0} - ${ip}`);
    });

    next();
  }

  /** Used to mask potentially sensitive information in the URL's */
  private maskSensitiveInfo(url: string): string {
    try {
      // We use a dummy base URL because originalUrl is usually a relative path
      const urlObj = new URL(url, "http://localhost");
      let changed = false;

      this.sensitiveParams.forEach((param) => {
        if (urlObj.searchParams.has(param)) {
          urlObj.searchParams.set(param, "*****");
          changed = true;
        }
      });
      return changed ? `${urlObj.pathname}${urlObj.search}` : url;
    } catch (e) {
      return url;
    }
  }
}
