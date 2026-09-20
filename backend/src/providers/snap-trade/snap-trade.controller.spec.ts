import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { SnapTradeProviderController } from "@backend/providers/snap-trade/snap-trade.controller.js";
import { TestEntities } from "@backend/test/entities.js";

describe("SnapTradeProviderController", () => {
  let controller: SnapTradeProviderController;
  let mockSnapTradeService: any;
  let mockSseService: any;

  beforeEach(() => {
    vi.clearAllMocks();

    mockSnapTradeService = {
      generateLinkToken: vi.fn().mockResolvedValue("https://snaptrade.com/link"),
      exchangeAndCreateAccounts: vi.fn().mockResolvedValue([{ account: TestEntities.account }]),
    };

    mockSseService = {
      sendToUser: vi.fn(),
    };

    controller = new SnapTradeProviderController(mockSnapTradeService, mockSseService);
  });

  it("should generate connection link", async () => {
    const res = await controller.generateLink(TestEntities.user, "https://sprout.local/redirect");
    expect(res).toBe("https://snaptrade.com/link");
    expect(mockSnapTradeService.generateLinkToken).toHaveBeenCalledWith(TestEntities.user, { redirectUrl: "https://sprout.local/redirect" });
  });

  it("should perform post-link sync and trigger SSE update", async () => {
    const accounts = await controller.postLink(TestEntities.user);
    expect(accounts.length).toBe(1);
    expect(mockSseService.sendToUser).toHaveBeenCalled();
  });
});
