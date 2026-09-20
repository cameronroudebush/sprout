import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it } from "vitest";

setupTests();

import { EncryptionTransformer } from "./encryption.decorator.js";
import { Configuration } from "@backend/config/core.js";

class TestEntity {
  @EncryptionTransformer.decorateAPIProperty()
  secretField!: string;
}

describe("EncryptionTransformer", () => {
  it("should handle null/undefined values, API property decoration, and propertyIsEncrypted check", () => {
    const key = EncryptionTransformer.generateRandomEncryptionKey();
    Configuration.encryptionKey = key;

    const transformer = new EncryptionTransformer();

    expect(transformer.to(null as any)).toBeNull();
    expect(transformer.from(null as any)).toBeNull();

    const plain = "secretData";
    const encrypted = transformer.to(plain);
    expect(encrypted).not.toBe(plain);
    expect(transformer.from(encrypted)).toBe(plain);

    expect(transformer.from("invalid:encrypted:format")).toBeNull();

    const entity = new TestEntity();
    entity.secretField = "secret";
    expect(EncryptionTransformer.propertyIsEncrypted(entity, "secretField")).toBe(true);
    expect(EncryptionTransformer.propertyIsEncrypted(entity, "nonExistentField")).toBe(false);
  });
});
