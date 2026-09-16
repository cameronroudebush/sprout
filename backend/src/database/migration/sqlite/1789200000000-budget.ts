import { MigrationInterface, QueryRunner } from "typeorm";

export class Budget1789200000000 implements MigrationInterface {
  name = "Budget1789200000000";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE "budget" ("id" varchar PRIMARY KEY NOT NULL, "userId" varchar NOT NULL, "categoryId" varchar NOT NULL, "amount" numeric NOT NULL, CONSTRAINT "UQ_budget_user_category" UNIQUE ("userId", "categoryId"), CONSTRAINT "FK_budget_user" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION, CONSTRAINT "FK_budget_category" FOREIGN KEY ("categoryId") REFERENCES "category" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(
      `CREATE TABLE "temporary_user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar, "includeAICapabilities" boolean NOT NULL DEFAULT (1), "enableBudgeting" boolean NOT NULL DEFAULT (1), "secureMode" boolean NOT NULL DEFAULT (0), "userId" varchar, "allowWidgets" boolean NOT NULL DEFAULT (0), "themeStyle" varchar NOT NULL DEFAULT ('colored'), "emailUpdateFrequency" varchar NOT NULL DEFAULT ('none'), "currency" varchar NOT NULL DEFAULT ('USD'), "coinbaseApiKey" varchar, "coinbaseApiKeyName" varchar, CONSTRAINT "UQ_99b09c9b3db3b4cd9058e313d5e" UNIQUE ("userId"), CONSTRAINT "FK_50aa50cd542e360ea75bf4eaa74" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(
      `INSERT INTO "temporary_user_config"("id", "privateMode", "netWorthRange", "simpleFinToken", "includeAICapabilities", "enableBudgeting", "secureMode", "userId", "allowWidgets", "themeStyle", "emailUpdateFrequency", "currency", "coinbaseApiKey", "coinbaseApiKeyName") SELECT "id", "privateMode", "netWorthRange", "simpleFinToken", "includeAICapabilities", 1, "secureMode", "userId", "allowWidgets", "themeStyle", "emailUpdateFrequency", "currency", "coinbaseApiKey", "coinbaseApiKeyName" FROM "user_config"`,
    );
    await queryRunner.query(`DROP TABLE "user_config"`);
    await queryRunner.query(`ALTER TABLE "temporary_user_config" RENAME TO "user_config"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE "temporary_user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar, "includeAICapabilities" boolean NOT NULL DEFAULT (1), "secureMode" boolean NOT NULL DEFAULT (0), "userId" varchar, "allowWidgets" boolean NOT NULL DEFAULT (0), "themeStyle" varchar NOT NULL DEFAULT ('colored'), "emailUpdateFrequency" varchar NOT NULL DEFAULT ('none'), "currency" varchar NOT NULL DEFAULT ('USD'), "coinbaseApiKey" varchar, "coinbaseApiKeyName" varchar, CONSTRAINT "UQ_99b09c9b3db3b4cd9058e313d5e" UNIQUE ("userId"), CONSTRAINT "FK_50aa50cd542e360ea75bf4eaa74" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(
      `INSERT INTO "temporary_user_config"("id", "privateMode", "netWorthRange", "simpleFinToken", "includeAICapabilities", "secureMode", "userId", "allowWidgets", "themeStyle", "emailUpdateFrequency", "currency", "coinbaseApiKey", "coinbaseApiKeyName") SELECT "id", "privateMode", "netWorthRange", "simpleFinToken", "includeAICapabilities", "secureMode", "userId", "allowWidgets", "themeStyle", "emailUpdateFrequency", "currency", "coinbaseApiKey", "coinbaseApiKeyName" FROM "user_config"`,
    );
    await queryRunner.query(`DROP TABLE "user_config"`);
    await queryRunner.query(`ALTER TABLE "temporary_user_config" RENAME TO "user_config"`);
    await queryRunner.query(`DROP TABLE "budget"`);
  }
}
