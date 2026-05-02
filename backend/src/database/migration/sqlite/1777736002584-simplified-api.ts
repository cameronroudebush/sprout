import { MigrationInterface, QueryRunner } from "typeorm";

export class SimplifiedApi1777736002584 implements MigrationInterface {
  name = "SimplifiedApi1777736002584";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE TABLE "temporary_holding" ("id" varchar PRIMARY KEY NOT NULL, "currency" varchar NOT NULL, "costBasis" double NOT NULL, "description" varchar NOT NULL, "marketValue" double NOT NULL, "purchasePrice" double NOT NULL, "shares" double NOT NULL, "symbol" varchar NOT NULL, "accountId" varchar, CONSTRAINT "FK_8c0907bcf6ceda6c72e16798097" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_holding"("id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId") SELECT "id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId" FROM "holding"`);
    await queryRunner.query(`DROP TABLE "holding"`);
    await queryRunner.query(`ALTER TABLE "temporary_holding" RENAME TO "holding"`);
    await queryRunner.query(
      `CREATE TABLE "temporary_transaction" ("id" varchar PRIMARY KEY NOT NULL, "amount" double NOT NULL, "description" varchar NOT NULL, "pending" boolean NOT NULL, "categoryId" varchar, "posted" datetime NOT NULL, "accountId" varchar, "extra" json, "manuallyEdited" json, CONSTRAINT "FK_3d6e89b14baa44a71870450d14d" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION, CONSTRAINT "FK_d3951864751c5812e70d033978d" FOREIGN KEY ("categoryId") REFERENCES "category" ("id") ON DELETE SET NULL ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_transaction"("id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra", "manuallyEdited") SELECT "id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra", "manuallyEdited" FROM "transaction"`);
    await queryRunner.query(`DROP TABLE "transaction"`);
    await queryRunner.query(`ALTER TABLE "temporary_transaction" RENAME TO "transaction"`);
    await queryRunner.query(`CREATE TABLE "temporary_holding" ("id" varchar PRIMARY KEY NOT NULL, "currency" varchar NOT NULL, "costBasis" double NOT NULL, "description" varchar NOT NULL, "marketValue" double NOT NULL, "purchasePrice" double NOT NULL, "shares" double NOT NULL, "symbol" varchar NOT NULL, "accountId" varchar)`);
    await queryRunner.query(`INSERT INTO "temporary_holding"("id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId") SELECT "id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId" FROM "holding"`);
    await queryRunner.query(`DROP TABLE "holding"`);
    await queryRunner.query(`ALTER TABLE "temporary_holding" RENAME TO "holding"`);
    await queryRunner.query(`CREATE TABLE "temporary_holding" ("id" varchar PRIMARY KEY NOT NULL, "currency" varchar NOT NULL, "costBasis" double NOT NULL, "description" varchar NOT NULL, "marketValue" double NOT NULL, "purchasePrice" double NOT NULL, "shares" double NOT NULL, "symbol" varchar NOT NULL, "accountId" varchar NOT NULL)`);
    await queryRunner.query(`INSERT INTO "temporary_holding"("id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId") SELECT "id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId" FROM "holding"`);
    await queryRunner.query(`DROP TABLE "holding"`);
    await queryRunner.query(`ALTER TABLE "temporary_holding" RENAME TO "holding"`);
    await queryRunner.query(`CREATE TABLE "temporary_transaction" ("id" varchar PRIMARY KEY NOT NULL, "amount" double NOT NULL, "description" varchar NOT NULL, "pending" boolean NOT NULL, "categoryId" varchar, "posted" datetime NOT NULL, "accountId" varchar, "extra" json, "manuallyEdited" json)`);
    await queryRunner.query(`INSERT INTO "temporary_transaction"("id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra", "manuallyEdited") SELECT "id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra", "manuallyEdited" FROM "transaction"`);
    await queryRunner.query(`DROP TABLE "transaction"`);
    await queryRunner.query(`ALTER TABLE "temporary_transaction" RENAME TO "transaction"`);
    await queryRunner.query(`CREATE TABLE "temporary_transaction" ("id" varchar PRIMARY KEY NOT NULL, "amount" double NOT NULL, "description" varchar NOT NULL, "pending" boolean NOT NULL, "categoryId" varchar, "posted" datetime NOT NULL, "accountId" varchar NOT NULL, "extra" json, "manuallyEdited" json)`);
    await queryRunner.query(`INSERT INTO "temporary_transaction"("id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra", "manuallyEdited") SELECT "id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra", "manuallyEdited" FROM "transaction"`);
    await queryRunner.query(`DROP TABLE "transaction"`);
    await queryRunner.query(`ALTER TABLE "temporary_transaction" RENAME TO "transaction"`);
    await queryRunner.query(`CREATE TABLE "temporary_holding" ("id" varchar PRIMARY KEY NOT NULL, "currency" varchar NOT NULL, "costBasis" double NOT NULL, "description" varchar NOT NULL, "marketValue" double NOT NULL, "purchasePrice" double NOT NULL, "shares" double NOT NULL, "symbol" varchar NOT NULL, "accountId" varchar NOT NULL, CONSTRAINT "FK_8c0907bcf6ceda6c72e16798097" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_holding"("id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId") SELECT "id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId" FROM "holding"`);
    await queryRunner.query(`DROP TABLE "holding"`);
    await queryRunner.query(`ALTER TABLE "temporary_holding" RENAME TO "holding"`);
    await queryRunner.query(
      `CREATE TABLE "temporary_transaction" ("id" varchar PRIMARY KEY NOT NULL, "amount" double NOT NULL, "description" varchar NOT NULL, "pending" boolean NOT NULL, "categoryId" varchar, "posted" datetime NOT NULL, "accountId" varchar NOT NULL, "extra" json, "manuallyEdited" json, CONSTRAINT "FK_d3951864751c5812e70d033978d" FOREIGN KEY ("categoryId") REFERENCES "category" ("id") ON DELETE SET NULL ON UPDATE NO ACTION, CONSTRAINT "FK_3d6e89b14baa44a71870450d14d" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_transaction"("id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra", "manuallyEdited") SELECT "id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra", "manuallyEdited" FROM "transaction"`);
    await queryRunner.query(`DROP TABLE "transaction"`);
    await queryRunner.query(`ALTER TABLE "temporary_transaction" RENAME TO "transaction"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "transaction" RENAME TO "temporary_transaction"`);
    await queryRunner.query(`CREATE TABLE "transaction" ("id" varchar PRIMARY KEY NOT NULL, "amount" double NOT NULL, "description" varchar NOT NULL, "pending" boolean NOT NULL, "categoryId" varchar, "posted" datetime NOT NULL, "accountId" varchar NOT NULL, "extra" json, "manuallyEdited" json)`);
    await queryRunner.query(`INSERT INTO "transaction"("id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra", "manuallyEdited") SELECT "id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra", "manuallyEdited" FROM "temporary_transaction"`);
    await queryRunner.query(`DROP TABLE "temporary_transaction"`);
    await queryRunner.query(`ALTER TABLE "holding" RENAME TO "temporary_holding"`);
    await queryRunner.query(`CREATE TABLE "holding" ("id" varchar PRIMARY KEY NOT NULL, "currency" varchar NOT NULL, "costBasis" double NOT NULL, "description" varchar NOT NULL, "marketValue" double NOT NULL, "purchasePrice" double NOT NULL, "shares" double NOT NULL, "symbol" varchar NOT NULL, "accountId" varchar NOT NULL)`);
    await queryRunner.query(`INSERT INTO "holding"("id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId") SELECT "id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId" FROM "temporary_holding"`);
    await queryRunner.query(`DROP TABLE "temporary_holding"`);
    await queryRunner.query(`ALTER TABLE "transaction" RENAME TO "temporary_transaction"`);
    await queryRunner.query(`CREATE TABLE "transaction" ("id" varchar PRIMARY KEY NOT NULL, "amount" double NOT NULL, "description" varchar NOT NULL, "pending" boolean NOT NULL, "categoryId" varchar, "posted" datetime NOT NULL, "accountId" varchar, "extra" json, "manuallyEdited" json)`);
    await queryRunner.query(`INSERT INTO "transaction"("id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra", "manuallyEdited") SELECT "id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra", "manuallyEdited" FROM "temporary_transaction"`);
    await queryRunner.query(`DROP TABLE "temporary_transaction"`);
    await queryRunner.query(`ALTER TABLE "transaction" RENAME TO "temporary_transaction"`);
    await queryRunner.query(`CREATE TABLE "transaction" ("id" varchar PRIMARY KEY NOT NULL, "amount" double NOT NULL, "description" varchar NOT NULL, "pending" boolean NOT NULL, "categoryId" varchar, "posted" datetime NOT NULL, "accountId" varchar, "extra" json, "manuallyEdited" json, CONSTRAINT "FK_3d6e89b14baa44a71870450d14d" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "transaction"("id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra", "manuallyEdited") SELECT "id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra", "manuallyEdited" FROM "temporary_transaction"`);
    await queryRunner.query(`DROP TABLE "temporary_transaction"`);
    await queryRunner.query(`ALTER TABLE "holding" RENAME TO "temporary_holding"`);
    await queryRunner.query(`CREATE TABLE "holding" ("id" varchar PRIMARY KEY NOT NULL, "currency" varchar NOT NULL, "costBasis" double NOT NULL, "description" varchar NOT NULL, "marketValue" double NOT NULL, "purchasePrice" double NOT NULL, "shares" double NOT NULL, "symbol" varchar NOT NULL, "accountId" varchar)`);
    await queryRunner.query(`INSERT INTO "holding"("id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId") SELECT "id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId" FROM "temporary_holding"`);
    await queryRunner.query(`DROP TABLE "temporary_holding"`);
    await queryRunner.query(`ALTER TABLE "holding" RENAME TO "temporary_holding"`);
    await queryRunner.query(`CREATE TABLE "holding" ("id" varchar PRIMARY KEY NOT NULL, "currency" varchar NOT NULL, "costBasis" double NOT NULL, "description" varchar NOT NULL, "marketValue" double NOT NULL, "purchasePrice" double NOT NULL, "shares" double NOT NULL, "symbol" varchar NOT NULL, "accountId" varchar, CONSTRAINT "FK_8c0907bcf6ceda6c72e16798097" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "holding"("id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId") SELECT "id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId" FROM "temporary_holding"`);
    await queryRunner.query(`DROP TABLE "temporary_holding"`);
    await queryRunner.query(`ALTER TABLE "transaction" RENAME TO "temporary_transaction"`);
    await queryRunner.query(
      `CREATE TABLE "transaction" ("id" varchar PRIMARY KEY NOT NULL, "amount" double NOT NULL, "description" varchar NOT NULL, "pending" boolean NOT NULL, "categoryId" varchar, "posted" datetime NOT NULL, "accountId" varchar, "extra" json, "manuallyEdited" json, CONSTRAINT "FK_3d6e89b14baa44a71870450d14d" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION, CONSTRAINT "FK_d3951864751c5812e70d033978d" FOREIGN KEY ("categoryId") REFERENCES "category" ("id") ON DELETE SET NULL ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "transaction"("id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra", "manuallyEdited") SELECT "id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra", "manuallyEdited" FROM "temporary_transaction"`);
    await queryRunner.query(`DROP TABLE "temporary_transaction"`);
    await queryRunner.query(`ALTER TABLE "holding" RENAME TO "temporary_holding"`);
    await queryRunner.query(`CREATE TABLE "holding" ("id" varchar PRIMARY KEY NOT NULL, "currency" varchar NOT NULL, "costBasis" double NOT NULL, "description" varchar NOT NULL, "marketValue" double NOT NULL, "purchasePrice" double NOT NULL, "shares" double NOT NULL, "symbol" varchar NOT NULL, "accountId" varchar, CONSTRAINT "FK_8c0907bcf6ceda6c72e16798097" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "holding"("id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId") SELECT "id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId" FROM "temporary_holding"`);
    await queryRunner.query(`DROP TABLE "temporary_holding"`);
  }
}
