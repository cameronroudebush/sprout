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

  it("should deidentify category labels without replacing partial word matches", () => {
    const history = new ChatHistory(user, "Gas was high, unlike Vegas.", "user");
    const map = new Map([["Gas", "Cat_0"]]);

    expect(history.deIdentifyText(map)).toBe("Cat_0 was high, unlike Vegas.");
  });

  it("should prefer longer overlapping labels and escape regex characters case-insensitively", () => {
    const history = new ChatHistory(user, "food & dining; FOOD; C++!", "user");
    const map = new Map([
      ["Food", "Cat_0"],
      ["Food & Dining", "Cat_1"],
      ["C++", "Cat_2"],
    ]);

    expect(history.deIdentifyText(map)).toBe("Cat_1; Cat_0; Cat_2!");
  });
});
