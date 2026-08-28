import { setupTests } from "@backend/test/helpers";
setupTests();

import { SSEController } from "@backend/sse/sse.controller";
import { SSEService } from "@backend/sse/sse.service";
import { TestEntities } from "@backend/test/entities";
import { of } from "rxjs";

describe("SSEController", () => {
  let controller: SSEController;
  let sseService: jest.Mocked<SSEService>;
  const user = TestEntities.user;

  beforeEach(() => {
    jest.clearAllMocks();

    sseService = {
      subscribe: jest.fn(),
    } as any;

    controller = new SSEController(sseService);
  });

  describe("sse", () => {
    it("should call sseService.subscribe for current user", () => {
      const mockObservable = of({} as MessageEvent);
      sseService.subscribe.mockReturnValue(mockObservable as any);

      const res = controller.sse(user);

      expect(sseService.subscribe).toHaveBeenCalledWith(user);
      expect(res).toBe(mockObservable);
    });
  });
});
