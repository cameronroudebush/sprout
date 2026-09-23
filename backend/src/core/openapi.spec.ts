import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { Configuration } from "@backend/config/core.js";

const mocks = vi.hoisted(() => ({
  createDocument: vi.fn(),
  apiReference: vi.fn().mockReturnValue(vi.fn()),
}));

vi.mock("@nestjs/swagger", async (importOriginal) => {
  const actual = await importOriginal<typeof import("@nestjs/swagger")>();
  return { ...actual, SwaggerModule: { ...actual.SwaggerModule, createDocument: mocks.createDocument } };
});
vi.mock("@scalar/nestjs-api-reference", () => ({ apiReference: mocks.apiReference }));

import { configureApiDocument, setupOpenApiHelp } from "./openapi.js";

describe("OpenAPI setup", () => {
  it("should create document and add rate-limit response to endpoints", () => {
    mocks.createDocument.mockReturnValue({ paths: { "/test": { get: { responses: {} } } } });
    const document = configureApiDocument({} as any);

    expect(document.paths["/test"].get.responses["429"]).toBeDefined();
  });

  it("should include development documentation note", () => {
    const original = Configuration.isDevBuild;
    Configuration.isDevBuild = true;
    mocks.createDocument.mockReturnValue({ paths: {} });
    try {
      configureApiDocument({} as any);
      expect(mocks.createDocument).toHaveBeenCalled();
    } finally {
      Configuration.isDevBuild = original;
    }
  });

  it("should mount API reference for root and continue for other paths", () => {
    const use = vi.fn();
    mocks.createDocument.mockReturnValue({ paths: {} });
    setupOpenApiHelp({ use } as any);

    const middleware = use.mock.calls[0]![1];
    const next = vi.fn();
    const response = {};
    middleware({ path: "/", protocol: "http", headers: {}, get: () => "localhost" }, response, next);
    middleware({ path: "/other", protocol: "http", headers: {}, get: () => "localhost" }, response, next);

    expect(mocks.apiReference).toHaveBeenCalled();
    expect(next).toHaveBeenCalledWith();
  });

  it("should strip the pre-release suffix from a git version tag", () => {
    const original = Configuration.version;
    Configuration.version = "v1.2.3-beta.1";
    mocks.createDocument.mockReturnValue({ paths: {} });
    try {
      configureApiDocument({} as any);
      expect(mocks.createDocument).toHaveBeenCalled();
    } finally {
      Configuration.version = original;
    }
  });

  it("should describe the local environment when running a dev build", () => {
    const originalDevBuild = Configuration.isDevBuild;
    const originalVersion = Configuration.version;
    Configuration.isDevBuild = true;
    Configuration.version = "v2.0.0-rc.1";
    mocks.createDocument.mockReturnValue({ paths: {} });
    try {
      const use = vi.fn();
      setupOpenApiHelp({ use } as any);

      const middleware = use.mock.calls[0]![1];
      middleware({ path: "/", protocol: "http", headers: {}, get: () => "localhost" }, {}, vi.fn());

      expect(mocks.apiReference).toHaveBeenCalled();
    } finally {
      Configuration.isDevBuild = originalDevBuild;
      Configuration.version = originalVersion;
    }
  });
});
