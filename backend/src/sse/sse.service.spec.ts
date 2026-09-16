import { setupTests } from "@backend/test/helpers";
setupTests();

import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { TestEntities } from "@backend/test/entities";
import { User } from "@backend/user/model/user.model";

describe("SSEService", () => {
  let service: SSEService;
  const user1 = TestEntities.user;
  const user2 = User.fromPlain({ ...TestEntities.user, id: "user-2" });

  beforeEach(() => {
    jest.clearAllMocks();
    service = new SSEService();
  });

  describe("subscribe & sendToUser", () => {
    it("should emit SSE messages to the correct subscribed user", (done) => {
      service.subscribe(user1).subscribe({
        next: (event) => {
          expect(event.data).toBe(JSON.stringify({ event: SSEEventType.SYNC, payload: { id: "123" } }));
          done();
        },
      });

      // Send to another user (should be filtered out)
      service.sendToUser(user2, SSEEventType.SYNC, { id: "456" } as any);

      // Send to user1 (should be received)
      service.sendToUser(user1, SSEEventType.SYNC, { id: "123" } as any);
    });
  });
});
