import { setupTests } from "@backend/test/helpers";
setupTests();

import { ChatModule } from "@backend/chat/chat.module";

describe("ChatModule", () => {
  it("should define ChatModule class", () => {
    expect(ChatModule).toBeDefined();
  });
});
