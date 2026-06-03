import { setupTests } from "@backend/test/helpers";
setupTests();

import { extractIdToken } from "@backend/auth/strategy/auth.extractor";
import { Request } from "express";

jest.mock("@backend/auth/auth.service", () => ({
  AuthService: {
    idTokenCookie: "id_token_cookie_key",
  },
}));

describe("extractIdToken", () => {
  it("should extract the token value from the request cookie object when the key is populated", () => {
    const mockRequest = {
      cookies: {
        id_token_cookie_key: "extracted-jwt-string",
      },
    } as unknown as Request;

    const result = extractIdToken(mockRequest);

    expect(result).toBe("extracted-jwt-string");
  });

  it("should return undefined if the cookies container is populated but lacks the expected token identifier key", () => {
    const mockRequest = {
      cookies: {
        some_other_cookie: "some-value",
      },
    } as unknown as Request;

    const result = extractIdToken(mockRequest);

    expect(result).toBeUndefined();
  });

  it("should return undefined safely without executing crash loops if the cookies property is missing from the request", () => {
    const mockRequest = {} as unknown as Request;

    const result = extractIdToken(mockRequest);

    expect(result).toBeUndefined();
  });
});
