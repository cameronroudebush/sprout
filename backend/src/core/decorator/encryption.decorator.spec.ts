import { setupTests } from "@backend/test/helpers";
setupTests();

import { EncryptionTransformer } from "@backend/core/decorator/encryption.decorator";

describe("EncryptionTransformer", () => {
  let transformer: EncryptionTransformer;

  beforeEach(() => {
    transformer = new EncryptionTransformer();
  });

  it("should encrypt plain string to cipher text and decrypt back", () => {
    const plain = "mySecretToken123";
    const encrypted = transformer.to(plain);
    expect(encrypted).not.toBe(plain);

    const decrypted = transformer.from(encrypted);
    expect(decrypted).toBe(plain);
  });

  it("should return null/undefined unchanged", () => {
    expect(transformer.to(null as any)).toBeNull();
    expect(transformer.from(null as any)).toBeNull();
  });
});
