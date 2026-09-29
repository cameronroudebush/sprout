import { setupTests } from "@backend/test/helpers";
setupTests();

import "reflect-metadata";

import { DatabaseDecorators } from "./decorators";
import { getMetadataArgsStorage } from "typeorm";
vi.mocked(DatabaseDecorators.column).mockRestore();

describe("DatabaseDecorators.column", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("keeps TypeScript design type when explicit type is absent", () => {
    const target = {};
    const getMetadata = vi.spyOn(Reflect, "getMetadata").mockReturnValue(String);

    DatabaseDecorators.column({ nullable: false })(target, "name");

    expect(vi.isMockFunction(DatabaseDecorators.column)).toBe(false);
    expect(getMetadata).toHaveBeenCalledWith("design:type", target, "name");
  });

  it("falls back to varchar when design type metadata is missing", () => {
    class ModelWithMissingMetadata {}
    const getMetadata = vi.spyOn(Reflect, "getMetadata").mockReturnValue(undefined);
    const existingColumnCount = getMetadataArgsStorage().columns.length;

    DatabaseDecorators.column()(ModelWithMissingMetadata.prototype, "value");

    const column = getMetadataArgsStorage()
      .columns.slice(existingColumnCount)
      .find((entry) => entry.target === ModelWithMissingMetadata && entry.propertyName === "value");
    expect(getMetadata).toHaveBeenCalledWith("design:type", ModelWithMissingMetadata.prototype, "value");
    expect(column?.options.type).toBe("varchar");
  });
});
