import { MigrationInterface, QueryRunner } from "typeorm";

export class Init1754527327032 implements MigrationInterface {
  name = "Init1754527327032";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE TABLE "account_history" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "balance" double NOT NULL, "availableBalance" double NOT NULL, "accountId" varchar)`);
    await queryRunner.query(`CREATE TABLE "institution" ("id" varchar PRIMARY KEY NOT NULL, "url" varchar NOT NULL, "name" varchar NOT NULL, "hasError" boolean NOT NULL)`);
    await queryRunner.query(`CREATE TABLE "user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'))`);
    await queryRunner.query(`CREATE TABLE "user" ("id" varchar PRIMARY KEY NOT NULL, "firstName" varchar, "lastName" varchar, "username" varchar NOT NULL, "admin" boolean NOT NULL DEFAULT (0), "password" varchar NOT NULL, "configId" varchar, CONSTRAINT "REL_2a91dde35c5a0668f32b39f49c" UNIQUE ("configId"))`);
    await queryRunner.query(`CREATE TABLE "account" ("id" varchar PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "provider" varchar NOT NULL, "currency" varchar NOT NULL, "balance" double NOT NULL, "availableBalance" double NOT NULL, "type" varchar NOT NULL, "extra" json, "institutionId" varchar, "userId" varchar, CONSTRAINT "UQ_414d4052f22837655ff312168cb" UNIQUE ("name"))`);
    await queryRunner.query(`CREATE TABLE "transaction" ("id" varchar PRIMARY KEY NOT NULL, "amount" double NOT NULL, "description" varchar NOT NULL, "pending" boolean NOT NULL, "category" varchar, "posted" datetime NOT NULL, "extra" json, "accountId" varchar)`);
    await queryRunner.query(`CREATE TABLE "holding" ("id" varchar PRIMARY KEY NOT NULL, "currency" varchar NOT NULL, "costBasis" double NOT NULL, "description" varchar NOT NULL, "marketValue" double NOT NULL, "purchasePrice" double NOT NULL, "shares" double NOT NULL, "symbol" varchar NOT NULL, "accountId" varchar)`);
    await queryRunner.query(`CREATE TABLE "sync" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "status" varchar NOT NULL, "failureReason" varchar)`);
    await queryRunner.query(`CREATE TABLE "provider_rate_limit" ("id" varchar PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "lastUpdated" datetime NOT NULL, "count" integer NOT NULL, CONSTRAINT "UQ_36c4fa24ed498d2e31e26abea45" UNIQUE ("name"))`);
    await queryRunner.query(`CREATE TABLE "temporary_account_history" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "balance" double NOT NULL, "availableBalance" double NOT NULL, "accountId" varchar, CONSTRAINT "FK_53b71bce9f969633f6b2a8cef20" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_account_history"("id", "time", "balance", "availableBalance", "accountId") SELECT "id", "time", "balance", "availableBalance", "accountId" FROM "account_history"`);
    await queryRunner.query(`DROP TABLE "account_history"`);
    await queryRunner.query(`ALTER TABLE "temporary_account_history" RENAME TO "account_history"`);
    await queryRunner.query(`CREATE TABLE "temporary_user" ("id" varchar PRIMARY KEY NOT NULL, "firstName" varchar, "lastName" varchar, "username" varchar NOT NULL, "admin" boolean NOT NULL DEFAULT (0), "password" varchar NOT NULL, "configId" varchar, CONSTRAINT "REL_2a91dde35c5a0668f32b39f49c" UNIQUE ("configId"), CONSTRAINT "FK_2a91dde35c5a0668f32b39f49c5" FOREIGN KEY ("configId") REFERENCES "user_config" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_user"("id", "firstName", "lastName", "username", "admin", "password", "configId") SELECT "id", "firstName", "lastName", "username", "admin", "password", "configId" FROM "user"`);
    await queryRunner.query(`DROP TABLE "user"`);
    await queryRunner.query(`ALTER TABLE "temporary_user" RENAME TO "user"`);
    await queryRunner.query(
      `CREATE TABLE "temporary_account" ("id" varchar PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "provider" varchar NOT NULL, "currency" varchar NOT NULL, "balance" double NOT NULL, "availableBalance" double NOT NULL, "type" varchar NOT NULL, "extra" json, "institutionId" varchar, "userId" varchar, CONSTRAINT "UQ_414d4052f22837655ff312168cb" UNIQUE ("name"), CONSTRAINT "FK_b0d9c345163894d7476574eaf84" FOREIGN KEY ("institutionId") REFERENCES "institution" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION, CONSTRAINT "FK_60328bf27019ff5498c4b977421" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_account"("id", "name", "provider", "currency", "balance", "availableBalance", "type", "extra", "institutionId", "userId") SELECT "id", "name", "provider", "currency", "balance", "availableBalance", "type", "extra", "institutionId", "userId" FROM "account"`);
    await queryRunner.query(`DROP TABLE "account"`);
    await queryRunner.query(`ALTER TABLE "temporary_account" RENAME TO "account"`);
    await queryRunner.query(`CREATE TABLE "temporary_transaction" ("id" varchar PRIMARY KEY NOT NULL, "amount" double NOT NULL, "description" varchar NOT NULL, "pending" boolean NOT NULL, "category" varchar, "posted" datetime NOT NULL, "extra" json, "accountId" varchar, CONSTRAINT "FK_3d6e89b14baa44a71870450d14d" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_transaction"("id", "amount", "description", "pending", "category", "posted", "extra", "accountId") SELECT "id", "amount", "description", "pending", "category", "posted", "extra", "accountId" FROM "transaction"`);
    await queryRunner.query(`DROP TABLE "transaction"`);
    await queryRunner.query(`ALTER TABLE "temporary_transaction" RENAME TO "transaction"`);
    await queryRunner.query(`CREATE TABLE "temporary_holding" ("id" varchar PRIMARY KEY NOT NULL, "currency" varchar NOT NULL, "costBasis" double NOT NULL, "description" varchar NOT NULL, "marketValue" double NOT NULL, "purchasePrice" double NOT NULL, "shares" double NOT NULL, "symbol" varchar NOT NULL, "accountId" varchar, CONSTRAINT "FK_8c0907bcf6ceda6c72e16798097" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_holding"("id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId") SELECT "id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId" FROM "holding"`);
    await queryRunner.query(`DROP TABLE "holding"`);
    await queryRunner.query(`ALTER TABLE "temporary_holding" RENAME TO "holding"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "holding" RENAME TO "temporary_holding"`);
    await queryRunner.query(`CREATE TABLE "holding" ("id" varchar PRIMARY KEY NOT NULL, "currency" varchar NOT NULL, "costBasis" double NOT NULL, "description" varchar NOT NULL, "marketValue" double NOT NULL, "purchasePrice" double NOT NULL, "shares" double NOT NULL, "symbol" varchar NOT NULL, "accountId" varchar)`);
    await queryRunner.query(`INSERT INTO "holding"("id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId") SELECT "id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId" FROM "temporary_holding"`);
    await queryRunner.query(`DROP TABLE "temporary_holding"`);
    await queryRunner.query(`ALTER TABLE "transaction" RENAME TO "temporary_transaction"`);
    await queryRunner.query(`CREATE TABLE "transaction" ("id" varchar PRIMARY KEY NOT NULL, "amount" double NOT NULL, "description" varchar NOT NULL, "pending" boolean NOT NULL, "category" varchar, "posted" datetime NOT NULL, "extra" json, "accountId" varchar)`);
    await queryRunner.query(`INSERT INTO "transaction"("id", "amount", "description", "pending", "category", "posted", "extra", "accountId") SELECT "id", "amount", "description", "pending", "category", "posted", "extra", "accountId" FROM "temporary_transaction"`);
    await queryRunner.query(`DROP TABLE "temporary_transaction"`);
    await queryRunner.query(`ALTER TABLE "account" RENAME TO "temporary_account"`);
    await queryRunner.query(`CREATE TABLE "account" ("id" varchar PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "provider" varchar NOT NULL, "currency" varchar NOT NULL, "balance" double NOT NULL, "availableBalance" double NOT NULL, "type" varchar NOT NULL, "extra" json, "institutionId" varchar, "userId" varchar, CONSTRAINT "UQ_414d4052f22837655ff312168cb" UNIQUE ("name"))`);
    await queryRunner.query(`INSERT INTO "account"("id", "name", "provider", "currency", "balance", "availableBalance", "type", "extra", "institutionId", "userId") SELECT "id", "name", "provider", "currency", "balance", "availableBalance", "type", "extra", "institutionId", "userId" FROM "temporary_account"`);
    await queryRunner.query(`DROP TABLE "temporary_account"`);
    await queryRunner.query(`ALTER TABLE "user" RENAME TO "temporary_user"`);
    await queryRunner.query(`CREATE TABLE "user" ("id" varchar PRIMARY KEY NOT NULL, "firstName" varchar, "lastName" varchar, "username" varchar NOT NULL, "admin" boolean NOT NULL DEFAULT (0), "password" varchar NOT NULL, "configId" varchar, CONSTRAINT "REL_2a91dde35c5a0668f32b39f49c" UNIQUE ("configId"))`);
    await queryRunner.query(`INSERT INTO "user"("id", "firstName", "lastName", "username", "admin", "password", "configId") SELECT "id", "firstName", "lastName", "username", "admin", "password", "configId" FROM "temporary_user"`);
    await queryRunner.query(`DROP TABLE "temporary_user"`);
    await queryRunner.query(`ALTER TABLE "account_history" RENAME TO "temporary_account_history"`);
    await queryRunner.query(`CREATE TABLE "account_history" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "balance" double NOT NULL, "availableBalance" double NOT NULL, "accountId" varchar)`);
    await queryRunner.query(`INSERT INTO "account_history"("id", "time", "balance", "availableBalance", "accountId") SELECT "id", "time", "balance", "availableBalance", "accountId" FROM "temporary_account_history"`);
    await queryRunner.query(`DROP TABLE "temporary_account_history"`);
    await queryRunner.query(`DROP TABLE "provider_rate_limit"`);
    await queryRunner.query(`DROP TABLE "sync"`);
    await queryRunner.query(`DROP TABLE "holding"`);
    await queryRunner.query(`DROP TABLE "transaction"`);
    await queryRunner.query(`DROP TABLE "account"`);
    await queryRunner.query(`DROP TABLE "user"`);
    await queryRunner.query(`DROP TABLE "user_config"`);
    await queryRunner.query(`DROP TABLE "institution"`);
    await queryRunner.query(`DROP TABLE "account_history"`);
  }
}
