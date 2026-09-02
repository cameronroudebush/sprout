import { MigrationInterface, QueryRunner } from "typeorm";

export class ProviderCoinbase1788305048512 implements MigrationInterface {
  name = "ProviderCoinbase1788305048512";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE "temporary_user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar, "includeAICapabilities" boolean NOT NULL DEFAULT (1), "secureMode" boolean NOT NULL DEFAULT (0), "userId" varchar, "allowWidgets" boolean NOT NULL DEFAULT (0), "themeStyle" varchar NOT NULL DEFAULT ('colored'), "emailUpdateFrequency" varchar NOT NULL DEFAULT ('none'), "currency" varchar NOT NULL DEFAULT ('USD'), "coinbaseApiKey" varchar, "coinbaseApiKeyName" varchar, CONSTRAINT "UQ_99b09c9b3db3b4cd9058e313d5e" UNIQUE ("userId"), CONSTRAINT "FK_50aa50cd542e360ea75bf4eaa74" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_user_config"("id", "privateMode", "netWorthRange", "simpleFinToken", "includeAICapabilities", "secureMode", "userId", "allowWidgets", "themeStyle", "emailUpdateFrequency", "currency") SELECT "id", "privateMode", "netWorthRange", "simpleFinToken", "includeAICapabilities", "secureMode", "userId", "allowWidgets", "themeStyle", "emailUpdateFrequency", "currency" FROM "user_config"`);
    await queryRunner.query(`DROP TABLE "user_config"`);
    await queryRunner.query(`ALTER TABLE "temporary_user_config" RENAME TO "user_config"`);

    await queryRunner.query(
      `CREATE TABLE "temporary_account" ("id" varchar PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "provider" varchar NOT NULL, "currency" varchar NOT NULL, "balance" double NOT NULL, "availableBalance" double NOT NULL, "type" varchar NOT NULL, "institutionId" varchar, "userId" varchar, "extra" json, "subType" varchar, "interestRate" json, "providerAccountId" varchar NOT NULL, CONSTRAINT "FK_60328bf27019ff5498c4b977421" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION, CONSTRAINT "FK_b0d9c345163894d7476574eaf84" FOREIGN KEY ("institutionId") REFERENCES "institution" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION)`,
    );

    // Migrate accounts and map providerAccountId from asset tables or fallback to account.id
    await queryRunner.query(`
            INSERT INTO "temporary_account"(
                "id", "name", "provider", "currency", "balance", "availableBalance", 
                "type", "institutionId", "userId", "extra", "subType", "interestRate", "providerAccountId"
            ) 
            SELECT 
                a."id", a."name", a."provider", a."currency", a."balance", a."availableBalance", 
                a."type", a."institutionId", a."userId", a."extra", a."subType", a."interestRate",
                COALESCE(pa."plaidAccountId", sta."snapTradeAccountId", za."zpid", a."id") AS "providerAccountId"
            FROM "account" a
            LEFT JOIN "plaid_asset" pa ON pa."accountId" = a."id"
            LEFT JOIN "snap_trade_asset" sta ON sta."accountId" = a."id"
            LEFT JOIN "zillow_asset" za ON za."accountId" = a."id"
        `);

    // Drop old account table and rename temporary_account
    await queryRunner.query(`DROP TABLE "account"`);
    await queryRunner.query(`ALTER TABLE "temporary_account" RENAME TO "account"`);

    // Clean up old asset tables that are no longer needed
    await queryRunner.query(`DROP TABLE IF EXISTS "plaid_asset"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "snap_trade_asset"`);
    await queryRunner.query(`DROP TABLE IF EXISTS "zillow_asset"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Recreate asset tables
    await queryRunner.query(`CREATE TABLE "plaid_asset" ("id" varchar PRIMARY KEY NOT NULL, "plaidAccountId" varchar NOT NULL UNIQUE, "accountId" varchar UNIQUE, CONSTRAINT "FK_plaid_asset_account" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE)`);
    await queryRunner.query(`CREATE TABLE "snap_trade_asset" ("id" varchar PRIMARY KEY NOT NULL, "snapTradeAccountId" varchar NOT NULL, "accountId" varchar UNIQUE, CONSTRAINT "FK_snap_trade_asset_account" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE)`);
    await queryRunner.query(`CREATE TABLE "zillow_asset" ("id" varchar PRIMARY KEY NOT NULL, "zpid" varchar NOT NULL UNIQUE, "accountId" varchar UNIQUE, CONSTRAINT "FK_zillow_asset_account" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE)`);

    // Restore provider IDs to asset tables
    await queryRunner.query(`INSERT INTO "plaid_asset"("id", "plaidAccountId", "accountId") SELECT "id", "providerAccountId", "id" FROM "account" WHERE "provider" = 'plaid'`);
    await queryRunner.query(`INSERT INTO "snap_trade_asset"("id", "snapTradeAccountId", "accountId") SELECT "id", "providerAccountId", "id" FROM "account" WHERE "provider" = 'snapTrade'`);
    await queryRunner.query(`INSERT INTO "zillow_asset"("id", "zpid", "accountId") SELECT "id", "providerAccountId", "id" FROM "account" WHERE "provider" = 'zillow'`);

    // Revert account table structure
    await queryRunner.query(`ALTER TABLE "account" RENAME TO "temporary_account"`);
    await queryRunner.query(
      `CREATE TABLE "account" ("id" varchar PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "provider" varchar NOT NULL, "currency" varchar NOT NULL, "balance" double NOT NULL, "availableBalance" double NOT NULL, "type" varchar NOT NULL, "institutionId" varchar, "userId" varchar, "extra" json, "subType" varchar, "interestRate" json, CONSTRAINT "FK_60328bf27019ff5498c4b977421" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION, CONSTRAINT "FK_b0d9c345163894d7476574eaf84" FOREIGN KEY ("institutionId") REFERENCES "institution" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "account"("id", "name", "provider", "currency", "balance", "availableBalance", "type", "institutionId", "userId", "extra", "subType", "interestRate") SELECT "id", "name", "provider", "currency", "balance", "availableBalance", "type", "institutionId", "userId", "extra", "subType", "interestRate" FROM "temporary_account"`);
    await queryRunner.query(`DROP TABLE "temporary_account"`);

    // Revert user_config table
    await queryRunner.query(`ALTER TABLE "user_config" RENAME TO "temporary_user_config"`);
    await queryRunner.query(
      `CREATE TABLE "user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar, "includeAICapabilities" boolean NOT NULL DEFAULT (1), "secureMode" boolean NOT NULL DEFAULT (0), "userId" varchar, "allowWidgets" boolean NOT NULL DEFAULT (0), "themeStyle" varchar NOT NULL DEFAULT ('colored'), "emailUpdateFrequency" varchar NOT NULL DEFAULT ('none'), "currency" varchar NOT NULL DEFAULT ('USD'), CONSTRAINT "UQ_99b09c9b3db3b4cd9058e313d5e" UNIQUE ("userId"), CONSTRAINT "FK_50aa50cd542e360ea75bf4eaa74" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "user_config"("id", "privateMode", "netWorthRange", "simpleFinToken", "includeAICapabilities", "secureMode", "userId", "allowWidgets", "themeStyle", "emailUpdateFrequency", "currency") SELECT "id", "privateMode", "netWorthRange", "simpleFinToken", "includeAICapabilities", "secureMode", "userId", "allowWidgets", "themeStyle", "emailUpdateFrequency", "currency" FROM "temporary_user_config"`);
    await queryRunner.query(`DROP TABLE "temporary_user_config"`);
  }
}
