import { MigrationInterface, QueryRunner } from "typeorm";

export class PlaidCursorSync1780264814499 implements MigrationInterface {
  name = "PlaidCursorSync1780264814499";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE TABLE "temporary_plaid_institution_asset" ("id" varchar PRIMARY KEY NOT NULL, "accessToken" varchar, "itemId" varchar NOT NULL, "institutionId" varchar, "syncCursor" varchar, CONSTRAINT "REL_146c0db3fa7f6cdd5f4228a568" UNIQUE ("institutionId"), CONSTRAINT "FK_146c0db3fa7f6cdd5f4228a568c" FOREIGN KEY ("institutionId") REFERENCES "institution" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_plaid_institution_asset"("id", "accessToken", "itemId", "institutionId") SELECT "id", "accessToken", "itemId", "institutionId" FROM "plaid_institution_asset"`);
    await queryRunner.query(`DROP TABLE "plaid_institution_asset"`);
    await queryRunner.query(`ALTER TABLE "temporary_plaid_institution_asset" RENAME TO "plaid_institution_asset"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "plaid_institution_asset" RENAME TO "temporary_plaid_institution_asset"`);
    await queryRunner.query(`CREATE TABLE "plaid_institution_asset" ("id" varchar PRIMARY KEY NOT NULL, "accessToken" varchar, "itemId" varchar NOT NULL, "institutionId" varchar, CONSTRAINT "REL_146c0db3fa7f6cdd5f4228a568" UNIQUE ("institutionId"), CONSTRAINT "FK_146c0db3fa7f6cdd5f4228a568c" FOREIGN KEY ("institutionId") REFERENCES "institution" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "plaid_institution_asset"("id", "accessToken", "itemId", "institutionId") SELECT "id", "accessToken", "itemId", "institutionId" FROM "temporary_plaid_institution_asset"`);
    await queryRunner.query(`DROP TABLE "temporary_plaid_institution_asset"`);
  }
}
