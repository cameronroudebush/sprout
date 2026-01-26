import { Request } from "express";

/** This extractor tries to grab the authorization from the cookie and falls back to the authorization bearer */
export function extractJwtFromHeaderOrCookie(req: Request): string | null {
  // Check Cookie - Web
  if (req.cookies && req.cookies["id_token"]) return req.cookies["id_token"];
  // Check Auth Header - Mobile
  const authHeader = req.headers.authorization;
  if (authHeader && authHeader.split(" ")[0] === "Bearer") return authHeader.split(" ")[1] ?? null;

  return null;
}
