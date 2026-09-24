import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { ChatConfig, GeminiConfig, OpenCodeConfig } from "@backend/chat/model/chat.config.model.js";

describe("ChatConfig", () => {
  it("should evaluate enabled correctly depending on the active provider key", () => {
    const config = new ChatConfig();
    expect(config.enabled).toBe(false);

    config.gemini.key = "";
    expect(config.enabled).toBe(false);

    config.gemini.key = "test-key";
    expect(config.enabled).toBe(true);

    config.type = "opencode-zen";
    expect(config.enabled).toBe(false);
    config.openCode.key = "zen-key";
    expect(config.enabled).toBe(true);
    expect(config.openCode.key).toBe("zen-key");

    config.type = "opencode-go";
    expect(config.enabled).toBe(true);
  });

  it("should resolve the provider block for every supported type", () => {
    const config = new ChatConfig();

    config.type = "gemini";
    expect(config.provider).toBe(config.gemini);

    config.type = "opencode-zen";
    expect(config.provider).toBe(config.openCode);

    config.type = "opencode-go";
    expect(config.provider).toBe(config.openCode);

    config.type = "invalid" as any;
    expect(config.provider).toBeUndefined();
    expect(config.enabled).toBe(false);
  });

  it("should default values properly", () => {
    const gemini = new GeminiConfig();
    expect(gemini.chatModel).toBe("gemini-flash-latest");
    expect(gemini.overviewModel).toBe("gemini-flash-lite-latest");

    const openCode = new OpenCodeConfig();
    expect(openCode.chatModel).toBe("glm-5.3-flash");
    expect(openCode.overviewModel).toBe("glm-5.3-flash");

    const chat = new ChatConfig();
    expect(chat.maxChatHistory).toBe(10);
    expect(chat.type).toBe("gemini");
    expect(chat.openCode).toBeInstanceOf(OpenCodeConfig);
  });
});
