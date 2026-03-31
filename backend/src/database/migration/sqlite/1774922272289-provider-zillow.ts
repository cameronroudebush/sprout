import { MigrationInterface, QueryRunner } from "typeorm";

export class ProviderZillow1774922272289 implements MigrationInterface {
  name = "ProviderZillow1774922272289";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE TABLE "zillow_asset" ("id" varchar PRIMARY KEY NOT NULL, "zpid" varchar NOT NULL, "accountId" varchar, CONSTRAINT "UQ_245bfb6e0114692dbab0d034390" UNIQUE ("zpid"), CONSTRAINT "REL_9427e90f1e2d2d383ea2366cc4" UNIQUE ("accountId"))`);
    await queryRunner.query(`CREATE TABLE "temporary_zillow_asset" ("id" varchar PRIMARY KEY NOT NULL, "zpid" varchar NOT NULL, "accountId" varchar, CONSTRAINT "UQ_245bfb6e0114692dbab0d034390" UNIQUE ("zpid"), CONSTRAINT "REL_9427e90f1e2d2d383ea2366cc4" UNIQUE ("accountId"), CONSTRAINT "FK_9427e90f1e2d2d383ea2366cc4c" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_zillow_asset"("id", "zpid", "accountId") SELECT "id", "zpid", "accountId" FROM "zillow_asset"`);
    await queryRunner.query(`DROP TABLE "zillow_asset"`);
    await queryRunner.query(`ALTER TABLE "temporary_zillow_asset" RENAME TO "zillow_asset"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "zillow_asset" RENAME TO "temporary_zillow_asset"`);
    await queryRunner.query(`CREATE TABLE "zillow_asset" ("id" varchar PRIMARY KEY NOT NULL, "zpid" varchar NOT NULL, "accountId" varchar, CONSTRAINT "UQ_245bfb6e0114692dbab0d034390" UNIQUE ("zpid"), CONSTRAINT "REL_9427e90f1e2d2d383ea2366cc4" UNIQUE ("accountId"))`);
    await queryRunner.query(`INSERT INTO "zillow_asset"("id", "zpid", "accountId") SELECT "id", "zpid", "accountId" FROM "temporary_zillow_asset"`);
    await queryRunner.query(`DROP TABLE "temporary_zillow_asset"`);
    await queryRunner.query(`DROP TABLE "zillow_asset"`);
  }
}
