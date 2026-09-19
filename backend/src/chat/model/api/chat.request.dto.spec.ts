import { setupTests } from "@backend/test/helpers";
setupTests();

import { ChatRequestDTO, ChatTimeframe } from "@backend/chat/model/api/chat.request.dto";

describe("ChatRequestDTO", () => {
  it("should create DTO instance with constructor", () => {
    const dto = new ChatRequestDTO("Hello AI");
    dto.timeframe = ChatTimeframe.threeMonths;
    dto.allowCharts = true;

    expect(dto.message).toBe("Hello AI");
    expect(dto.timeframe).toBe(ChatTimeframe.threeMonths);
    expect(dto.allowCharts).toBe(true);
  });
});
