import { MigrationInterface, QueryRunner } from "typeorm";

export class TransactionManual1768149468183 implements MigrationInterface {
  name = "TransactionManual1768149468183";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE "temporary_transaction" ("id" varchar PRIMARY KEY NOT NULL, "amount" double NOT NULL, "description" varchar NOT NULL, "pending" boolean NOT NULL, "categoryId" varchar, "posted" datetime NOT NULL, "accountId" varchar, "extra" json, "manuallyEdited" json, CONSTRAINT "FK_d3951864751c5812e70d033978d" FOREIGN KEY ("categoryId") REFERENCES "category" ("id") ON DELETE SET NULL ON UPDATE NO ACTION, CONSTRAINT "FK_3d6e89b14baa44a71870450d14d" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_transaction"("id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra") SELECT "id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra" FROM "transaction"`);
    await queryRunner.query(`DROP TABLE "transaction"`);
    await queryRunner.query(`ALTER TABLE "temporary_transaction" RENAME TO "transaction"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "transaction" RENAME TO "temporary_transaction"`);
    await queryRunner.query(
      `CREATE TABLE "transaction" ("id" varchar PRIMARY KEY NOT NULL, "amount" double NOT NULL, "description" varchar NOT NULL, "pending" boolean NOT NULL, "categoryId" varchar, "posted" datetime NOT NULL, "accountId" varchar, "extra" json, CONSTRAINT "FK_d3951864751c5812e70d033978d" FOREIGN KEY ("categoryId") REFERENCES "category" ("id") ON DELETE SET NULL ON UPDATE NO ACTION, CONSTRAINT "FK_3d6e89b14baa44a71870450d14d" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "transaction"("id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra") SELECT "id", "amount", "description", "pending", "categoryId", "posted", "accountId", "extra" FROM "temporary_transaction"`);
    await queryRunner.query(`DROP TABLE "temporary_transaction"`);
  }
}
