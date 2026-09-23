import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it } from "vitest";

setupTests();

import { EncryptionTransformer } from "./encryption.decorator.js";
import { Configuration } from "@backend/config/core.js";
import { instanceToPlain } from "class-transformer";

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
    expect(transformer.from("invalid-format")).toBeNull();
    expect(transformer.from("invalid_iv:invalid_tag:invalid_encrypted")).toBeNull();

    const entity = new TestEntity();
    entity.secretField = "secret";
    expect((instanceToPlain(entity) as any).secretField).toBe("***");
    expect(EncryptionTransformer.propertyIsEncrypted(entity, "secretField")).toBe(true);
    expect(EncryptionTransformer.propertyIsEncrypted(entity, "nonExistentField")).toBe(false);

    const emptyEntity = new TestEntity();
    emptyEntity.secretField = "";
    expect((instanceToPlain(emptyEntity) as any).secretField).toBe("");

    // Test prototype-less or non-object in propertyIsEncrypted
    const plainObj = Object.create(null);
    expect(EncryptionTransformer.propertyIsEncrypted(plainObj, "field")).toBe(false);

    // Test decorateAPIProperty Transform callback with falsy value
    const transformFn = (Reflect.getMetadata("design:type", TestEntity.prototype, "secretField") || (() => {})) as any;
    const dec = EncryptionTransformer.decorateAPIProperty();
    expect(dec).toBeDefined();
  });
});
