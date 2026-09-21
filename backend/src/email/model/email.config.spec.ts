import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { EmailConfig } from "@backend/email/model/email.config.js";

describe("EmailConfig", () => {
  it("should validate and construct properly", () => {
    const config = new EmailConfig();
    config.enabled = false;
    expect(() => config.validate()).not.toThrow();

    config.enabled = true;
    expect(() => config.validate()).toThrow("The host must be set to use email");

    config.host = "smtp.sprout.local";
    expect(() => config.validate()).toThrow("The username must be set to use email");

    config.user = "user@sprout.local";
    expect(() => config.validate()).toThrow("The password must be set to use email");

    config.pass = "secret";
    expect(() => config.validate()).not.toThrow();
  });
});
