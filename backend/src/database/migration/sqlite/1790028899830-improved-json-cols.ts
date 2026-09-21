import { MigrationInterface, QueryRunner } from "typeorm";

export class ImprovedJsonCols17900288998301790028899830 implements MigrationInterface {
  name = "ImprovedJsonCols17900288998301790028899830";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE TABLE "temporary_institution" ("id" varchar PRIMARY KEY NOT NULL, "url" varchar NOT NULL, "name" varchar NOT NULL, "hasError" boolean NOT NULL, "userId" varchar NOT NULL, "iconType" varchar CHECK( "iconType" IN ('icon','symbol') ) NOT NULL DEFAULT ('icon'), "extra" jsonb, CONSTRAINT "FK_166fa924f28750b4b9f8227ed9d" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_institution"("id", "url", "name", "hasError", "userId", "iconType") SELECT "id", "url", "name", "hasError", "userId", "iconType" FROM "institution"`);
    await queryRunner.query(`DROP TABLE "institution"`);
    await queryRunner.query(`ALTER TABLE "temporary_institution" RENAME TO "institution"`);
    await queryRunner.query(
      `CREATE TABLE "temporary_account" ("id" varchar PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "provider" varchar NOT NULL, "currency" varchar NOT NULL, "balance" double NOT NULL, "availableBalance" double NOT NULL, "type" varchar NOT NULL, "institutionId" varchar, "userId" varchar, "extra" jsonb, "subType" varchar, "interestRate" jsonb, "providerAccountId" varchar NOT NULL, "isArchived" boolean NOT NULL DEFAULT (0), CONSTRAINT "FK_60328bf27019ff5498c4b977421" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION, CONSTRAINT "FK_b0d9c345163894d7476574eaf84" FOREIGN KEY ("institutionId") REFERENCES "institution" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_account"("id", "name", "provider", "currency", "balance", "availableBalance", "type", "institutionId", "userId", "extra", "subType", "interestRate", "providerAccountId", "isArchived") SELECT "id", "name", "provider", "currency", "balance", "availableBalance", "type", "institutionId", "userId", "extra", "subType", "interestRate", "providerAccountId", "isArchived" FROM "account"`);
    await queryRunner.query(`DROP TABLE "account"`);
    await queryRunner.query(`ALTER TABLE "temporary_account" RENAME TO "account"`);
    await queryRunner.query(
      `CREATE TABLE "temporary_transaction" ("id" varchar PRIMARY KEY NOT NULL, "amount" double NOT NULL, "description" varchar NOT NULL, "pending" boolean NOT NULL, "categoryId" varchar, "posted" datetime NOT NULL, "accountId" varchar NOT NULL, "extra" jsonb, "manuallyEdited" boolean, "providerId" varchar, CONSTRAINT "FK_d3951864751c5812e70d033978d" FOREIGN KEY ("categoryId") REFERENCES "category" ("id") ON DELETE SET NULL ON UPDATE NO ACTION, CONSTRAINT "FK_3d6e89b14baa44a71870450d14d" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`
      INSERT INTO "temporary_transaction"("id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra", "manuallyEdited", "providerId") 
      SELECT 
        "id", 
        "amount", 
        "description", 
        "pending", 
        "categoryId", 
        "posted", 
        "accountId", 
        "extra", 
        CASE 
          WHEN "manuallyEdited" = 'true' OR "manuallyEdited" = 1 OR "manuallyEdited" = '1' THEN 1 
          WHEN "manuallyEdited" = 'false' OR "manuallyEdited" = 0 OR "manuallyEdited" = '0' THEN 0 
          ELSE NULL 
        END, 
        "providerId" 
      FROM "transaction"
    `);
    await queryRunner.query(`DROP TABLE "transaction"`);
    await queryRunner.query(`ALTER TABLE "temporary_transaction" RENAME TO "transaction"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE "temporary_transaction" ("id" varchar PRIMARY KEY NOT NULL, "amount" double NOT NULL, "description" varchar NOT NULL, "pending" boolean NOT NULL, "categoryId" varchar, "posted" datetime NOT NULL, "accountId" varchar NOT NULL, "extra" json, "manuallyEdited" json, "providerId" varchar, CONSTRAINT "FK_d3951864751c5812e70d033978d" FOREIGN KEY ("categoryId") REFERENCES "category" ("id") ON DELETE SET NULL ON UPDATE NO ACTION, CONSTRAINT "FK_3d6e89b14baa44a71870450d14d" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`
      INSERT INTO "temporary_transaction"("id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra", "manuallyEdited", "providerId") 
      SELECT 
        "id", 
        "amount", 
        "description", 
        "pending", 
        "categoryId", 
        "posted", 
        "accountId", 
        "extra", 
        CASE 
          WHEN "manuallyEdited" = 1 THEN 'true' 
          WHEN "manuallyEdited" = 0 THEN 'false' 
          ELSE NULL 
        END, 
        "providerId" 
      FROM "transaction"
    `);
    await queryRunner.query(`DROP TABLE "transaction"`);
    await queryRunner.query(`ALTER TABLE "temporary_transaction" RENAME TO "transaction"`);
    await queryRunner.query(
      `CREATE TABLE "temporary_account" ("id" varchar PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "provider" varchar NOT NULL, "currency" varchar NOT NULL, "balance" double NOT NULL, "availableBalance" double NOT NULL, "type" varchar NOT NULL, "institutionId" varchar, "userId" varchar, "extra" json, "subType" varchar, "interestRate" json, "providerAccountId" varchar NOT NULL, "isArchived" boolean NOT NULL DEFAULT (0), CONSTRAINT "FK_60328bf27019ff5498c4b977421" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION, CONSTRAINT "FK_b0d9c345163894d7476574eaf84" FOREIGN KEY ("institutionId") REFERENCES "institution" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_account"("id", "name", "provider", "currency", "balance", "availableBalance", "type", "institutionId", "userId", "extra", "subType", "interestRate", "providerAccountId", "isArchived") SELECT "id", "name", "provider", "currency", "balance", "availableBalance", "type", "institutionId", "userId", "extra", "subType", "interestRate", "providerAccountId", "isArchived" FROM "account"`);
    await queryRunner.query(`DROP TABLE "account"`);
    await queryRunner.query(`ALTER TABLE "temporary_account" RENAME TO "account"`);
    await queryRunner.query(`CREATE TABLE "temporary_institution" ("id" varchar PRIMARY KEY NOT NULL, "url" varchar NOT NULL, "name" varchar NOT NULL, "hasError" boolean NOT NULL, "userId" varchar NOT NULL, "iconType" varchar CHECK( "iconType" IN ('icon','symbol') ) NOT NULL DEFAULT ('icon'), "extra" json, CONSTRAINT "FK_166fa924f28750b4b9f8227ed9d" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_institution"("id", "url", "name", "hasError", "userId", "iconType", "extra") SELECT "id", "url", "name", "hasError", "userId", "iconType", "extra" FROM "institution"`);
    await queryRunner.query(`DROP TABLE "institution"`);
    await queryRunner.query(`ALTER TABLE "temporary_institution" RENAME TO "institution"`);
  }
}
