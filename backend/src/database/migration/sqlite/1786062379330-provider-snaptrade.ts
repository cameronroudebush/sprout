import { MigrationInterface, QueryRunner } from "typeorm";

export class ProviderSnaptrade1786062379330 implements MigrationInterface {
    name = 'ProviderSnaptrade1786062379330'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "snap_trade_asset" ("id" varchar PRIMARY KEY NOT NULL, "snapTradeAccountId" varchar NOT NULL, "accountId" varchar, CONSTRAINT "REL_ad4b8cf3e68e68b2c76d123eff" UNIQUE ("accountId"))`);
        await queryRunner.query(`CREATE TABLE "snap_trade_institution_asset" ("id" varchar PRIMARY KEY NOT NULL, "authorizationId" varchar NOT NULL, "institutionId" varchar, CONSTRAINT "REL_44421bffb260bdfd080bd7b2ab" UNIQUE ("institutionId"))`);
        await queryRunner.query(`CREATE TABLE "snap_trade_user" ("id" varchar PRIMARY KEY NOT NULL, "userSecret" varchar, "userId" varchar, CONSTRAINT "REL_edd190148d68b512879f67e866" UNIQUE ("userId"))`);
        await queryRunner.query(`CREATE TABLE "temporary_snap_trade_asset" ("id" varchar PRIMARY KEY NOT NULL, "snapTradeAccountId" varchar NOT NULL, "accountId" varchar, CONSTRAINT "REL_ad4b8cf3e68e68b2c76d123eff" UNIQUE ("accountId"), CONSTRAINT "FK_ad4b8cf3e68e68b2c76d123eff5" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
        await queryRunner.query(`INSERT INTO "temporary_snap_trade_asset"("id", "snapTradeAccountId", "accountId") SELECT "id", "snapTradeAccountId", "accountId" FROM "snap_trade_asset"`);
        await queryRunner.query(`DROP TABLE "snap_trade_asset"`);
        await queryRunner.query(`ALTER TABLE "temporary_snap_trade_asset" RENAME TO "snap_trade_asset"`);
        await queryRunner.query(`CREATE TABLE "temporary_snap_trade_institution_asset" ("id" varchar PRIMARY KEY NOT NULL, "authorizationId" varchar NOT NULL, "institutionId" varchar, CONSTRAINT "REL_44421bffb260bdfd080bd7b2ab" UNIQUE ("institutionId"), CONSTRAINT "FK_44421bffb260bdfd080bd7b2ab7" FOREIGN KEY ("institutionId") REFERENCES "institution" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
        await queryRunner.query(`INSERT INTO "temporary_snap_trade_institution_asset"("id", "authorizationId", "institutionId") SELECT "id", "authorizationId", "institutionId" FROM "snap_trade_institution_asset"`);
        await queryRunner.query(`DROP TABLE "snap_trade_institution_asset"`);
        await queryRunner.query(`ALTER TABLE "temporary_snap_trade_institution_asset" RENAME TO "snap_trade_institution_asset"`);
        await queryRunner.query(`CREATE TABLE "temporary_snap_trade_user" ("id" varchar PRIMARY KEY NOT NULL, "userSecret" varchar, "userId" varchar, CONSTRAINT "REL_edd190148d68b512879f67e866" UNIQUE ("userId"), CONSTRAINT "FK_edd190148d68b512879f67e8662" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
        await queryRunner.query(`INSERT INTO "temporary_snap_trade_user"("id", "userSecret", "userId") SELECT "id", "userSecret", "userId" FROM "snap_trade_user"`);
        await queryRunner.query(`DROP TABLE "snap_trade_user"`);
        await queryRunner.query(`ALTER TABLE "temporary_snap_trade_user" RENAME TO "snap_trade_user"`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "snap_trade_user" RENAME TO "temporary_snap_trade_user"`);
        await queryRunner.query(`CREATE TABLE "snap_trade_user" ("id" varchar PRIMARY KEY NOT NULL, "userSecret" varchar, "userId" varchar, CONSTRAINT "REL_edd190148d68b512879f67e866" UNIQUE ("userId"))`);
        await queryRunner.query(`INSERT INTO "snap_trade_user"("id", "userSecret", "userId") SELECT "id", "userSecret", "userId" FROM "temporary_snap_trade_user"`);
        await queryRunner.query(`DROP TABLE "temporary_snap_trade_user"`);
        await queryRunner.query(`ALTER TABLE "snap_trade_institution_asset" RENAME TO "temporary_snap_trade_institution_asset"`);
        await queryRunner.query(`CREATE TABLE "snap_trade_institution_asset" ("id" varchar PRIMARY KEY NOT NULL, "authorizationId" varchar NOT NULL, "institutionId" varchar, CONSTRAINT "REL_44421bffb260bdfd080bd7b2ab" UNIQUE ("institutionId"))`);
        await queryRunner.query(`INSERT INTO "snap_trade_institution_asset"("id", "authorizationId", "institutionId") SELECT "id", "authorizationId", "institutionId" FROM "temporary_snap_trade_institution_asset"`);
        await queryRunner.query(`DROP TABLE "temporary_snap_trade_institution_asset"`);
        await queryRunner.query(`ALTER TABLE "snap_trade_asset" RENAME TO "temporary_snap_trade_asset"`);
        await queryRunner.query(`CREATE TABLE "snap_trade_asset" ("id" varchar PRIMARY KEY NOT NULL, "snapTradeAccountId" varchar NOT NULL, "accountId" varchar, CONSTRAINT "REL_ad4b8cf3e68e68b2c76d123eff" UNIQUE ("accountId"))`);
        await queryRunner.query(`INSERT INTO "snap_trade_asset"("id", "snapTradeAccountId", "accountId") SELECT "id", "snapTradeAccountId", "accountId" FROM "temporary_snap_trade_asset"`);
        await queryRunner.query(`DROP TABLE "temporary_snap_trade_asset"`);
        await queryRunner.query(`DROP TABLE "snap_trade_user"`);
        await queryRunner.query(`DROP TABLE "snap_trade_institution_asset"`);
        await queryRunner.query(`DROP TABLE "snap_trade_asset"`);
    }

}
