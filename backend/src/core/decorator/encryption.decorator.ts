import { Configuration } from "@backend/config/core";
import { applyDecorators, Logger } from "@nestjs/common";
import { Transform } from "class-transformer";
import { createCipheriv, createDecipheriv, randomBytes } from "crypto";
import { ValueTransformer } from "typeorm";

/**
 * This transformer works as a typeorm transformer to
 *  automatically encrypt data going into and out of the database
 *  on a specific column
 */
export class EncryptionTransformer implements ValueTransformer {
  readonly logger = new Logger(EncryptionTransformer.name);

  /** How long of an encryption key we need */
  static readonly REQUIRED_KEY_LENGTH = 32;

  /** The algorithm to use for our encryption keys */
  private static readonly ALGORITHM = "aes-256-gcm";

  /** The text that is displayed when the property is of a hidden value */
  static readonly HIDDEN_VALUE = "***";

  /** IV length for the encryption algorithm */
  private static readonly IV_LENGTH = 12;

  /** The key that tracks if a property has encryption transformer applied to it */
  private static readonly METADATA_KEY = "encryption:transformer";

  /** Decorates whatever property is using the encryption transformer so if it somehow is serialized to the API, it will be fake data */
  static decorateAPIProperty() {
    return applyDecorators(
      (target: Object, key: string | symbol) => Reflect.defineMetadata(EncryptionTransformer.METADATA_KEY, true, target, key),
      Transform(({ value }) => (value ? EncryptionTransformer.HIDDEN_VALUE : ""), {
        /** Only do the hidden value converting when going to plain so it's not leaked into the API */
        toPlainOnly: true,
      }),
    );
  }

  /** Returns if the given property of an object is an encrypted field. */
  static propertyIsEncrypted<T extends Object>(obj: T, key: keyof T | string) {
    const target = obj.constructor ? obj.constructor.prototype : obj;
    const hasMetadata = Reflect.getMetadata(EncryptionTransformer.METADATA_KEY, target, key as string);
    return hasMetadata === true;
  }

  /** Generates a random encryption key of the proper length */
  static generateRandomEncryptionKey() {
    return randomBytes(this.REQUIRED_KEY_LENGTH).toString("hex");
  }

  /** The key for use in this encryption transformer */
  private readonly key: Buffer;

  constructor() {
    this.key = Buffer.from(Configuration.encryptionKey, "hex");
  }

  /** Encrypts data going into the database */
  to(value: string | null | undefined): string | null {
    if (!value) return null;
    const iv = randomBytes(EncryptionTransformer.IV_LENGTH);
    const cipher = createCipheriv(EncryptionTransformer.ALGORITHM, this.key, iv);
    const encrypted = Buffer.concat([cipher.update(value, "utf8"), cipher.final()]);
    const authTag = cipher.getAuthTag();
    return `${iv.toString("hex")}:${authTag.toString("hex")}:${encrypted.toString("hex")}`;
  }

  from(value: string | null | undefined): string | null {
    if (!value) return null;
    try {
      const [ivHex, authTagHex, encryptedHex] = value.split(":");
      if (!ivHex || !authTagHex || !encryptedHex) throw new Error("Invalid encrypted format");
      const iv = Buffer.from(ivHex, "hex");
      const authTag = Buffer.from(authTagHex, "hex");
      const encryptedText = Buffer.from(encryptedHex, "hex");
      const decipher = createDecipheriv(EncryptionTransformer.ALGORITHM, this.key, iv);
      decipher.setAuthTag(authTag);
      // If the data was tampered with, this will throw an error immediately
      const decrypted = Buffer.concat([decipher.update(encryptedText), decipher.final()]);
      return decrypted.toString("utf8");
    } catch (error) {
      this.logger.error("Decryption failed. Did the key change?", error);
      return null;
    }
  }
}
