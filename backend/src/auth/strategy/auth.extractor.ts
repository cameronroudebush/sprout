import { AuthService } from "@backend/auth/auth.service";
import { Request } from "express";

/** This extractor tries to grab the authorization from the cookie and falls back to the authorization bearer */
export function extractJwtFromHeaderOrCookie(req: Request): string | null {
  return req.cookies?.[AuthService.idTokenCookie];
}
