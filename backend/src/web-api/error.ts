/** Extension upon the error class so we can add codes */
export class EndpointError extends Error {
  /** Error code that occurred to help the developer find out what they did wrong. */
  code: number;

  constructor(message: string, code: number = 400) {
    super(message);
    this.code = code;
  }
}
