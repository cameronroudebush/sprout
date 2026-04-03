import { MigrationInterface, QueryRunner } from "typeorm";

export class Plaid1775180891340 implements MigrationInterface {
  name = "Plaid1775180891340";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE TABLE "plaid_asset" ("id" varchar PRIMARY KEY NOT NULL, "accessToken" varchar, "itemId" varchar NOT NULL, "institutionId" varchar, CONSTRAINT "REL_a6866913bb3686b3a7143c0e6b" UNIQUE ("institutionId"))`);
    await queryRunner.query(`CREATE TABLE "temporary_plaid_asset" ("id" varchar PRIMARY KEY NOT NULL, "accessToken" varchar, "itemId" varchar NOT NULL, "institutionId" varchar, CONSTRAINT "REL_a6866913bb3686b3a7143c0e6b" UNIQUE ("institutionId"), CONSTRAINT "FK_a6866913bb3686b3a7143c0e6b8" FOREIGN KEY ("institutionId") REFERENCES "institution" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_plaid_asset"("id", "accessToken", "itemId", "institutionId") SELECT "id", "accessToken", "itemId", "institutionId" FROM "plaid_asset"`);
    await queryRunner.query(`DROP TABLE "plaid_asset"`);
    await queryRunner.query(`ALTER TABLE "temporary_plaid_asset" RENAME TO "plaid_asset"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "plaid_asset" RENAME TO "temporary_plaid_asset"`);
    await queryRunner.query(`CREATE TABLE "plaid_asset" ("id" varchar PRIMARY KEY NOT NULL, "accessToken" varchar, "itemId" varchar NOT NULL, "institutionId" varchar, CONSTRAINT "REL_a6866913bb3686b3a7143c0e6b" UNIQUE ("institutionId"))`);
    await queryRunner.query(`INSERT INTO "plaid_asset"("id", "accessToken", "itemId", "institutionId") SELECT "id", "accessToken", "itemId", "institutionId" FROM "temporary_plaid_asset"`);
    await queryRunner.query(`DROP TABLE "temporary_plaid_asset"`);
    await queryRunner.query(`DROP TABLE "plaid_asset"`);
  }
}
