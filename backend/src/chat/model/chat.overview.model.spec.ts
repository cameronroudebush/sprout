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
    expect(overview.year).toBe(0);
    expect(overview.month).toBe(0);
  });

  it("should create a month-specific budget overview", () => {
    const overview = new ChatOverview(user, "Summary text", ChatOverviewType.budgets, new Date(), "model", 2025, 4);
    expect(overview.year).toBe(2025);
    expect(overview.month).toBe(4);
  });
});
