import { MigrationInterface, QueryRunner } from "typeorm";

export class ChatOverviews1785518997277 implements MigrationInterface {
  name = "ChatOverviews1785518997277";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE "temporary_user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar, "includeAICapabilities" varchar, "secureMode" boolean NOT NULL DEFAULT (0), "userId" varchar, "allowWidgets" boolean NOT NULL DEFAULT (0), "themeStyle" varchar NOT NULL DEFAULT ('colored'), "emailUpdateFrequency" varchar NOT NULL DEFAULT ('none'), "currency" varchar NOT NULL DEFAULT ('USD'), CONSTRAINT "UQ_99b09c9b3db3b4cd9058e313d5e" UNIQUE ("userId"), CONSTRAINT "FK_50aa50cd542e360ea75bf4eaa74" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_user_config"("id", "privateMode", "netWorthRange", "simpleFinToken", "includeAICapabilities", "secureMode", "userId", "allowWidgets", "themeStyle", "emailUpdateFrequency", "currency") SELECT "id", "privateMode", "netWorthRange", "simpleFinToken", "geminiKey", "secureMode", "userId", "allowWidgets", "themeStyle", "emailUpdateFrequency", "currency" FROM "user_config"`);
    await queryRunner.query(`DROP TABLE "user_config"`);
    await queryRunner.query(`ALTER TABLE "temporary_user_config" RENAME TO "user_config"`);
    await queryRunner.query(`CREATE TABLE "chat_overview" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "text" varchar NOT NULL, "type" varchar NOT NULL, "userId" varchar, CONSTRAINT "UQ_7bfcba7a8bad25bf9a1ac023c27" UNIQUE ("userId", "type"))`);
    await queryRunner.query(
      `CREATE TABLE "temporary_user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar, "includeAICapabilities" boolean NOT NULL DEFAULT (1), "secureMode" boolean NOT NULL DEFAULT (0), "userId" varchar, "allowWidgets" boolean NOT NULL DEFAULT (0), "themeStyle" varchar NOT NULL DEFAULT ('colored'), "emailUpdateFrequency" varchar NOT NULL DEFAULT ('none'), "currency" varchar NOT NULL DEFAULT ('USD'), CONSTRAINT "UQ_99b09c9b3db3b4cd9058e313d5e" UNIQUE ("userId"), CONSTRAINT "FK_50aa50cd542e360ea75bf4eaa74" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_user_config"("id", "privateMode", "netWorthRange", "simpleFinToken", "includeAICapabilities", "secureMode", "userId", "allowWidgets", "themeStyle", "emailUpdateFrequency", "currency") SELECT "id", "privateMode", "netWorthRange", "simpleFinToken", "includeAICapabilities", "secureMode", "userId", "allowWidgets", "themeStyle", "emailUpdateFrequency", "currency" FROM "user_config"`);
    await queryRunner.query(`DROP TABLE "user_config"`);
    await queryRunner.query(`ALTER TABLE "temporary_user_config" RENAME TO "user_config"`);
    await queryRunner.query(`CREATE TABLE "temporary_chat_overview" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "text" varchar NOT NULL, "type" varchar NOT NULL, "userId" varchar, CONSTRAINT "UQ_7bfcba7a8bad25bf9a1ac023c27" UNIQUE ("userId", "type"), CONSTRAINT "FK_48687a6fe8f81d7993b1ead980b" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_chat_overview"("id", "time", "text", "type", "userId") SELECT "id", "time", "text", "type", "userId" FROM "chat_overview"`);
    await queryRunner.query(`DROP TABLE "chat_overview"`);
    await queryRunner.query(`ALTER TABLE "temporary_chat_overview" RENAME TO "chat_overview"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "chat_overview" RENAME TO "temporary_chat_overview"`);
    await queryRunner.query(`CREATE TABLE "chat_overview" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "text" varchar NOT NULL, "type" varchar NOT NULL, "userId" varchar, CONSTRAINT "UQ_7bfcba7a8bad25bf9a1ac023c27" UNIQUE ("userId", "type"))`);
    await queryRunner.query(`INSERT INTO "chat_overview"("id", "time", "text", "type", "userId") SELECT "id", "time", "text", "type", "userId" FROM "temporary_chat_overview"`);
    await queryRunner.query(`DROP TABLE "temporary_chat_overview"`);
    await queryRunner.query(`ALTER TABLE "user_config" RENAME TO "temporary_user_config"`);
    await queryRunner.query(
      `CREATE TABLE "user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar, "includeAICapabilities" varchar, "secureMode" boolean NOT NULL DEFAULT (0), "userId" varchar, "allowWidgets" boolean NOT NULL DEFAULT (0), "themeStyle" varchar NOT NULL DEFAULT ('colored'), "emailUpdateFrequency" varchar NOT NULL DEFAULT ('none'), "currency" varchar NOT NULL DEFAULT ('USD'), CONSTRAINT "UQ_99b09c9b3db3b4cd9058e313d5e" UNIQUE ("userId"), CONSTRAINT "FK_50aa50cd542e360ea75bf4eaa74" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "user_config"("id", "privateMode", "netWorthRange", "simpleFinToken", "includeAICapabilities", "secureMode", "userId", "allowWidgets", "themeStyle", "emailUpdateFrequency", "currency") SELECT "id", "privateMode", "netWorthRange", "simpleFinToken", "includeAICapabilities", "secureMode", "userId", "allowWidgets", "themeStyle", "emailUpdateFrequency", "currency" FROM "temporary_user_config"`);
    await queryRunner.query(`DROP TABLE "temporary_user_config"`);
    await queryRunner.query(`DROP TABLE "chat_overview"`);
    await queryRunner.query(`ALTER TABLE "user_config" RENAME TO "temporary_user_config"`);
    await queryRunner.query(
      `CREATE TABLE "user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar, "geminiKey" varchar, "secureMode" boolean NOT NULL DEFAULT (0), "userId" varchar, "allowWidgets" boolean NOT NULL DEFAULT (0), "themeStyle" varchar NOT NULL DEFAULT ('colored'), "emailUpdateFrequency" varchar NOT NULL DEFAULT ('none'), "currency" varchar NOT NULL DEFAULT ('USD'), CONSTRAINT "UQ_99b09c9b3db3b4cd9058e313d5e" UNIQUE ("userId"), CONSTRAINT "FK_50aa50cd542e360ea75bf4eaa74" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "user_config"("id", "privateMode", "netWorthRange", "simpleFinToken", "geminiKey", "secureMode", "userId", "allowWidgets", "themeStyle", "emailUpdateFrequency", "currency") SELECT "id", "privateMode", "netWorthRange", "simpleFinToken", "includeAICapabilities", "secureMode", "userId", "allowWidgets", "themeStyle", "emailUpdateFrequency", "currency" FROM "temporary_user_config"`);
    await queryRunner.query(`DROP TABLE "temporary_user_config"`);
  }
}
