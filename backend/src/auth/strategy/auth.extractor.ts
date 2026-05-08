import { AuthService } from "@backend/auth/auth.service";
import { Request } from "express";

/** This extractor tries to grab the id token from the cookie. */
export function extractIdToken(req: Request): string | null {
  return req.cookies?.[AuthService.idTokenCookie];
}
