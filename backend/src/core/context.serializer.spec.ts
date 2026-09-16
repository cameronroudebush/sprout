import { setupTests } from "@backend/test/helpers";
setupTests();

import { ContextSerializerInterceptor } from "@backend/core/context.serializer";
import { ExecutionContext } from "@nestjs/common";

describe("ContextSerializerInterceptor", () => {
  let interceptor: ContextSerializerInterceptor;
  let reflector: any;

  beforeEach(() => {
    reflector = {
      get: jest.fn(),
      getAllAndOverride: jest.fn(),
    };
    interceptor = new ContextSerializerInterceptor(reflector);
  });

  describe("getContextOptions", () => {
    it("should attach user request context to transform options", () => {
      const mockUser = { id: "u-1" };
      const mockRequest = { user: mockUser };
      const executionContext: Partial<ExecutionContext> = {
        getHandler: jest.fn(),
        getClass: jest.fn(),
        switchToHttp: () =>
          ({
            getRequest: () => mockRequest,
          }) as any,
      };

      const options = (interceptor as any).getContextOptions(executionContext);

      expect(options.context.user).toBe(mockUser);
    });
  });
});
