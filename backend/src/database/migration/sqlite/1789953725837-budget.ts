import { MigrationInterface, QueryRunner } from "typeorm";

export class Budget17899537258371789953725837 implements MigrationInterface {
  name = "Budget17899537258371789953725837";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE TABLE "budget" ("id" varchar PRIMARY KEY NOT NULL, "userId" varchar NOT NULL, "categoryId" varchar NOT NULL, "amount" double NOT NULL, CONSTRAINT "UQ_0262d5276654d090b0b225ec41f" UNIQUE ("userId", "categoryId"))`);
    await queryRunner.query(
      `CREATE TABLE "temporary_user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar, "includeAICapabilities" boolean NOT NULL DEFAULT (1), "secureMode" boolean NOT NULL DEFAULT (0), "userId" varchar, "allowWidgets" boolean NOT NULL DEFAULT (0), "themeStyle" varchar NOT NULL DEFAULT ('colored'), "emailUpdateFrequency" varchar NOT NULL DEFAULT ('none'), "currency" varchar NOT NULL DEFAULT ('USD'), "coinbaseApiKey" varchar, "coinbaseApiKeyName" varchar, "enableBudgeting" boolean NOT NULL DEFAULT (1), CONSTRAINT "UQ_99b09c9b3db3b4cd9058e313d5e" UNIQUE ("userId"), CONSTRAINT "FK_50aa50cd542e360ea75bf4eaa74" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(
      `INSERT INTO "temporary_user_config"("id", "privateMode", "netWorthRange", "simpleFinToken", "includeAICapabilities", "secureMode", "userId", "allowWidgets", "themeStyle", "emailUpdateFrequency", "currency", "coinbaseApiKey", "coinbaseApiKeyName") SELECT "id", "privateMode", "netWorthRange", "simpleFinToken", "includeAICapabilities", "secureMode", "userId", "allowWidgets", "themeStyle", "emailUpdateFrequency", "currency", "coinbaseApiKey", "coinbaseApiKeyName" FROM "user_config"`,
    );
    await queryRunner.query(`DROP TABLE "user_config"`);
    await queryRunner.query(`ALTER TABLE "temporary_user_config" RENAME TO "user_config"`);
    await queryRunner.query(
      `CREATE TABLE "temporary_budget" ("id" varchar PRIMARY KEY NOT NULL, "userId" varchar NOT NULL, "categoryId" varchar NOT NULL, "amount" double NOT NULL, CONSTRAINT "UQ_0262d5276654d090b0b225ec41f" UNIQUE ("userId", "categoryId"), CONSTRAINT "FK_8ed65c868c97a5fb471d85efb01" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION, CONSTRAINT "FK_4aeadf37446801c8f4d2d26441b" FOREIGN KEY ("categoryId") REFERENCES "category" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_budget"("id", "userId", "categoryId", "amount") SELECT "id", "userId", "categoryId", "amount" FROM "budget"`);
    await queryRunner.query(`DROP TABLE "budget"`);
    await queryRunner.query(`ALTER TABLE "temporary_budget" RENAME TO "budget"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "budget" RENAME TO "temporary_budget"`);
    await queryRunner.query(`CREATE TABLE "budget" ("id" varchar PRIMARY KEY NOT NULL, "userId" varchar NOT NULL, "categoryId" varchar NOT NULL, "amount" double NOT NULL, CONSTRAINT "UQ_0262d5276654d090b0b225ec41f" UNIQUE ("userId", "categoryId"))`);
    await queryRunner.query(`INSERT INTO "budget"("id", "userId", "categoryId", "amount") SELECT "id", "userId", "categoryId", "amount" FROM "temporary_budget"`);
    await queryRunner.query(`DROP TABLE "temporary_budget"`);
    await queryRunner.query(`ALTER TABLE "user_config" RENAME TO "temporary_user_config"`);
    await queryRunner.query(
      `CREATE TABLE "user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar, "includeAICapabilities" boolean NOT NULL DEFAULT (1), "secureMode" boolean NOT NULL DEFAULT (0), "userId" varchar, "allowWidgets" boolean NOT NULL DEFAULT (0), "themeStyle" varchar NOT NULL DEFAULT ('colored'), "emailUpdateFrequency" varchar NOT NULL DEFAULT ('none'), "currency" varchar NOT NULL DEFAULT ('USD'), "coinbaseApiKey" varchar, "coinbaseApiKeyName" varchar, CONSTRAINT "UQ_99b09c9b3db3b4cd9058e313d5e" UNIQUE ("userId"), CONSTRAINT "FK_50aa50cd542e360ea75bf4eaa74" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(
      `INSERT INTO "user_config"("id", "privateMode", "netWorthRange", "simpleFinToken", "includeAICapabilities", "secureMode", "userId", "allowWidgets", "themeStyle", "emailUpdateFrequency", "currency", "coinbaseApiKey", "coinbaseApiKeyName") SELECT "id", "privateMode", "netWorthRange", "simpleFinToken", "includeAICapabilities", "secureMode", "userId", "allowWidgets", "themeStyle", "emailUpdateFrequency", "currency", "coinbaseApiKey", "coinbaseApiKeyName" FROM "temporary_user_config"`,
    );
    await queryRunner.query(`DROP TABLE "temporary_user_config"`);
    await queryRunner.query(`DROP TABLE "budget"`);
  }
}
