import { isAxiosError } from "axios";

/** Formats Plaid/Axios errors without logging Axios request or response objects. */
export function formatPlaidError(error: unknown): string {
  if (isAxiosError(error)) {
    const responseData = error.response?.data;
    const plaidError = typeof responseData === "object" && responseData !== null ? (responseData as Record<string, unknown>) : undefined;
    const details = [
      error.response?.status ? `HTTP ${error.response.status}` : undefined,
      typeof plaidError?.error_code === "string" ? plaidError.error_code : undefined,
      typeof plaidError?.error_type === "string" ? plaidError.error_type : undefined,
    ].filter((detail): detail is string => !!detail);
    const message = typeof plaidError?.error_message === "string" ? plaidError.error_message : error.message;
    const requestId = typeof plaidError?.request_id === "string" ? plaidError.request_id : undefined;

    const summary = [details.join(" "), message].filter(Boolean).join(": ");
    return `${summary}${requestId ? ` (request_id: ${requestId})` : ""}` || "Unknown Axios error";
  }

  if (error instanceof Error) return `${error.name}: ${error.message}`;
  if (typeof error === "string") return error;
  return "Unknown error";
}
