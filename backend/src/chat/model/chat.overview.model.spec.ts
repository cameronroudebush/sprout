import { setupTests } from "@backend/test/helpers";
setupTests();

import { ChatOverview } from "@backend/chat/model/chat.overview.model";
import { ChatOverviewType } from "@backend/chat/model/chat.overview.type";
import { TestEntities } from "@backend/test/entities";

describe("ChatOverview Model", () => {
  const user = TestEntities.user;

  it("should create chat overview instance", () => {
    const overview = new ChatOverview(user, "Summary text", ChatOverviewType.accounts);
    expect(overview.text).toBe("Summary text");
    expect(overview.type).toBe(ChatOverviewType.accounts);
  });
});
