import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it } from "vitest";

setupTests();

import { EncryptionTransformer } from "./encryption.decorator.js";
import { Configuration } from "@backend/config/core.js";

describe("EncryptionTransformer", () => {
  it("should generate random key and encrypt/decrypt values", () => {
    const key = EncryptionTransformer.generateRandomEncryptionKey();
    expect(key).toHaveLength(EncryptionTransformer.REQUIRED_KEY_LENGTH * 2);

    Configuration.encryptionKey = key;
    const transformer = new EncryptionTransformer();

    const plain = "secret-data";
    const encrypted = transformer.to(plain);
    expect(encrypted).not.toBe(plain);

    const decrypted = transformer.from(encrypted);
    expect(decrypted).toBe(plain);
  });
});
