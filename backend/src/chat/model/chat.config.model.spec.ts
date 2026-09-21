import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { ChatConfig, GeminiConfig } from "@backend/chat/model/chat.config.model.js";

describe("ChatConfig", () => {
  it("should evaluate enabled correctly depending on key", () => {
    const config = new ChatConfig();
    expect(config.enabled).toBe(false);

    config.gemini.key = "";
    expect(config.enabled).toBe(false);

    config.gemini.key = "test-key";
    expect(config.enabled).toBe(true);
  });

  it("should default values properly", () => {
    const gemini = new GeminiConfig();
    expect(gemini.chatModel).toBe("gemini-flash-latest");
    expect(gemini.overviewModel).toBe("gemini-flash-lite-latest");

    const chat = new ChatConfig();
    expect(chat.maxChatHistory).toBe(10);
    expect(chat.type).toBe("gemini");
  });
});
