import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { formatPlaidError } from "@backend/providers/plaid/plaid.error.js";
import { AxiosError } from "axios";

describe("formatPlaidError", () => {
  it("formats the useful fields from a Plaid Axios response", () => {
    const error = Object.assign(new AxiosError("Request failed"), {
      response: {
        status: 400,
        data: {
          error_code: "INVALID_ACCESS_TOKEN",
          error_type: "ITEM_ERROR",
          error_message: "Access token is invalid",
          request_id: "request-123",
        },
      },
    });

    expect(formatPlaidError(error)).toBe("HTTP 400 INVALID_ACCESS_TOKEN ITEM_ERROR: Access token is invalid (request_id: request-123)");
  });

  it("uses the Axios message when response has no Plaid error details", () => {
    const error = Object.assign(new AxiosError("Network unavailable"), {
      response: { status: 503, data: "unstructured response" },
    });

    expect(formatPlaidError(error)).toBe("HTTP 503: Network unavailable");
  });

  it("handles Axios errors without response or message", () => {
    expect(formatPlaidError(new AxiosError(""))).toBe("Unknown Axios error");
  });

  it("formats regular errors without exposing their object", () => {
    expect(formatPlaidError(new TypeError("Unexpected value"))).toBe("TypeError: Unexpected value");
  });

  it("passes through string errors", () => {
    expect(formatPlaidError("Request timed out")).toBe("Request timed out");
  });

  it("uses a safe fallback for other values", () => {
    expect(formatPlaidError({ response: { data: { secret: "hidden" } } })).toBe("Unknown error");
    expect(formatPlaidError(null)).toBe("Unknown error");
  });
});
