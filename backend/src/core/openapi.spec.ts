import { setupTests } from "@backend/test/helpers";
setupTests();

jest.mock("@scalar/nestjs-api-reference", () => ({
  apiReference: jest.fn().mockImplementation(() => jest.fn()),
}));

import { configureApiDocument, setupOpenApiHelp } from "@backend/core/openapi";
import { SwaggerModule } from "@nestjs/swagger";

describe("openapi.ts", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    jest.spyOn(SwaggerModule, "createDocument").mockReturnValue({
      paths: {
        "/test": {},
      },
    } as any);
  });

  it("should configure API document builder", () => {
    const mockApp: any = {};
    const config = configureApiDocument(mockApp);

    expect(config).toBeDefined();
  });

  it("should setup OpenAPI help routes on app instance", () => {
    const mockApp: any = {
      use: jest.fn(),
      get: jest.fn().mockReturnValue({
        get: jest.fn((_path, handler) => {
          handler({} as any, { send: jest.fn() } as any);
        }),
      }),
    };

    setupOpenApiHelp(mockApp);

    expect(mockApp.use).toHaveBeenCalled();
  });
});
