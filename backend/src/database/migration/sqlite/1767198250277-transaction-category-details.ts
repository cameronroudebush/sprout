import { MigrationInterface, QueryRunner } from "typeorm";

export class TransactionCategoryDetails1767198250277 implements MigrationInterface {
  name = "TransactionCategoryDetails1767198250277";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE "temporary_category" ("id" varchar PRIMARY KEY NOT NULL, "userId" varchar NOT NULL, "name" varchar NOT NULL, "type" varchar NOT NULL, "parentCategoryId" varchar, "icon" varchar, CONSTRAINT "UQ_0634179a4275a9ed86e3dae060c" UNIQUE ("name", "userId", "parentCategoryId"), CONSTRAINT "FK_32b856438dffdc269fa84434d9f" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION, CONSTRAINT "FK_9e5435ba76dbc1f1a0705d4db43" FOREIGN KEY ("parentCategoryId") REFERENCES "category" ("id") ON DELETE SET NULL ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_category"("id", "userId", "name", "type", "parentCategoryId") SELECT "id", "userId", "name", "type", "parentCategoryId" FROM "category"`);
    await queryRunner.query(`DROP TABLE "category"`);
    await queryRunner.query(`ALTER TABLE "temporary_category" RENAME TO "category"`);
    await queryRunner.query(
      `CREATE TABLE "temporary_transaction_rule" ("id" varchar PRIMARY KEY NOT NULL, "type" varchar NOT NULL, "value" varchar NOT NULL, "strict" boolean NOT NULL, "matches" integer NOT NULL, "order" integer NOT NULL, "enabled" boolean NOT NULL, "userId" varchar, "categoryId" varchar, "accountId" varchar, CONSTRAINT "FK_e77340b6f79dfede390b7180cfb" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION, CONSTRAINT "FK_abb14d310ab5925f7e067423fb6" FOREIGN KEY ("categoryId") REFERENCES "category" ("id") ON DELETE SET NULL ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_transaction_rule"("id", "type", "value", "strict", "matches", "order", "enabled", "userId", "categoryId") SELECT "id", "type", "value", "strict", "matches", "order", "enabled", "userId", "categoryId" FROM "transaction_rule"`);
    await queryRunner.query(`DROP TABLE "transaction_rule"`);
    await queryRunner.query(`ALTER TABLE "temporary_transaction_rule" RENAME TO "transaction_rule"`);
    await queryRunner.query(
      `CREATE TABLE "temporary_transaction_rule" ("id" varchar PRIMARY KEY NOT NULL, "type" varchar NOT NULL, "value" varchar NOT NULL, "strict" boolean NOT NULL, "matches" integer NOT NULL, "order" integer NOT NULL, "enabled" boolean NOT NULL, "userId" varchar, "categoryId" varchar, "accountId" varchar, CONSTRAINT "FK_e77340b6f79dfede390b7180cfb" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION, CONSTRAINT "FK_abb14d310ab5925f7e067423fb6" FOREIGN KEY ("categoryId") REFERENCES "category" ("id") ON DELETE SET NULL ON UPDATE NO ACTION, CONSTRAINT "FK_cfd1724978b35059307ca37ecbe" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE SET NULL ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_transaction_rule"("id", "type", "value", "strict", "matches", "order", "enabled", "userId", "categoryId", "accountId") SELECT "id", "type", "value", "strict", "matches", "order", "enabled", "userId", "categoryId", "accountId" FROM "transaction_rule"`);
    await queryRunner.query(`DROP TABLE "transaction_rule"`);
    await queryRunner.query(`ALTER TABLE "temporary_transaction_rule" RENAME TO "transaction_rule"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "transaction_rule" RENAME TO "temporary_transaction_rule"`);
    await queryRunner.query(
      `CREATE TABLE "transaction_rule" ("id" varchar PRIMARY KEY NOT NULL, "type" varchar NOT NULL, "value" varchar NOT NULL, "strict" boolean NOT NULL, "matches" integer NOT NULL, "order" integer NOT NULL, "enabled" boolean NOT NULL, "userId" varchar, "categoryId" varchar, "accountId" varchar, CONSTRAINT "FK_e77340b6f79dfede390b7180cfb" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION, CONSTRAINT "FK_abb14d310ab5925f7e067423fb6" FOREIGN KEY ("categoryId") REFERENCES "category" ("id") ON DELETE SET NULL ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "transaction_rule"("id", "type", "value", "strict", "matches", "order", "enabled", "userId", "categoryId", "accountId") SELECT "id", "type", "value", "strict", "matches", "order", "enabled", "userId", "categoryId", "accountId" FROM "temporary_transaction_rule"`);
    await queryRunner.query(`DROP TABLE "temporary_transaction_rule"`);
    await queryRunner.query(`ALTER TABLE "transaction_rule" RENAME TO "temporary_transaction_rule"`);
    await queryRunner.query(
      `CREATE TABLE "transaction_rule" ("id" varchar PRIMARY KEY NOT NULL, "type" varchar NOT NULL, "value" varchar NOT NULL, "strict" boolean NOT NULL, "matches" integer NOT NULL, "order" integer NOT NULL, "enabled" boolean NOT NULL, "userId" varchar, "categoryId" varchar, CONSTRAINT "FK_e77340b6f79dfede390b7180cfb" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION, CONSTRAINT "FK_abb14d310ab5925f7e067423fb6" FOREIGN KEY ("categoryId") REFERENCES "category" ("id") ON DELETE SET NULL ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "transaction_rule"("id", "type", "value", "strict", "matches", "order", "enabled", "userId", "categoryId") SELECT "id", "type", "value", "strict", "matches", "order", "enabled", "userId", "categoryId" FROM "temporary_transaction_rule"`);
    await queryRunner.query(`DROP TABLE "temporary_transaction_rule"`);
    await queryRunner.query(`ALTER TABLE "category" RENAME TO "temporary_category"`);
    await queryRunner.query(
      `CREATE TABLE "category" ("id" varchar PRIMARY KEY NOT NULL, "userId" varchar NOT NULL, "name" varchar NOT NULL, "type" varchar NOT NULL, "parentCategoryId" varchar, CONSTRAINT "UQ_0634179a4275a9ed86e3dae060c" UNIQUE ("name", "userId", "parentCategoryId"), CONSTRAINT "FK_32b856438dffdc269fa84434d9f" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION, CONSTRAINT "FK_9e5435ba76dbc1f1a0705d4db43" FOREIGN KEY ("parentCategoryId") REFERENCES "category" ("id") ON DELETE SET NULL ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "category"("id", "userId", "name", "type", "parentCategoryId") SELECT "id", "userId", "name", "type", "parentCategoryId" FROM "temporary_category"`);
    await queryRunner.query(`DROP TABLE "temporary_category"`);
  }
}
