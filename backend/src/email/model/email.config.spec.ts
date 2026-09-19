import { setupTests } from "@backend/test/helpers";
setupTests();

import { EmailConfig } from "@backend/email/model/email.config";

describe("EmailConfig", () => {
  it("should validate and construct properly", () => {
    const config = new EmailConfig();
    config.enabled = false;
    config.from = "test@sprout.local";

    expect(config.from).toBe("test@sprout.local");
  });
});
