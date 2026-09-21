import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { SSEData, SSEEvent, SSEEventType } from "@backend/sse/model/event.model.js";
import { TestEntities } from "@backend/test/entities.js";

describe("SSE event models", () => {
  it("should instantiate SSEData and SSEEvent", () => {
    const data = new SSEData(SSEEventType.SYNC);
    expect(data.event).toBe(SSEEventType.SYNC);
    expect(data.payload).toBeUndefined();

    const user = TestEntities.user;
    const event = new SSEEvent(user, data);
    expect(event.user).toBe(user);
    expect(event.data).toBe(data);
  });
});
