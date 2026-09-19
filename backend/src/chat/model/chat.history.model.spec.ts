import { setupTests } from "@backend/test/helpers";
setupTests();

import { ChatHistory } from "@backend/chat/model/chat.history.model";
import { TestEntities } from "@backend/test/entities";

describe("ChatHistory Model", () => {
  const user = TestEntities.user;

  it("should create chat history instance", () => {
    const history = new ChatHistory(user, "Hello AI", "user");
    expect(history.text).toBe("Hello AI");
    expect(history.role).toBe("user");
  });

  it("should deidentify text using map", () => {
    const history = new ChatHistory(user, "My account is Acc_Real", "user");
    const map = new Map([["Acc_Real", "Acc_Anon"]]);
    const deidentified = history.deIdentifyText(map);

    expect(deidentified).toBe("My account is Acc_Anon");
  });
});
