import { setupTests } from "@backend/test/helpers";
setupTests();

import { NotificationSSEDTO } from "@backend/notification/model/api/notification.sse.dto";

describe("NotificationSSEDTO", () => {
  it("should construct with popupLatest property", () => {
    const dto = new NotificationSSEDTO(true);
    expect(dto.popupLatest).toBe(true);
  });
});
