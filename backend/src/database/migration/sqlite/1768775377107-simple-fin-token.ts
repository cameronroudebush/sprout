import { MigrationInterface, QueryRunner } from "typeorm";

export class SimpleFinToken1768775377107 implements MigrationInterface {
    name = 'SimpleFinToken1768775377107'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "temporary_user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar)`);
        await queryRunner.query(`INSERT INTO "temporary_user_config"("id", "privateMode", "netWorthRange") SELECT "id", "privateMode", "netWorthRange" FROM "user_config"`);
        await queryRunner.query(`DROP TABLE "user_config"`);
        await queryRunner.query(`ALTER TABLE "temporary_user_config" RENAME TO "user_config"`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "user_config" RENAME TO "temporary_user_config"`);
        await queryRunner.query(`CREATE TABLE "user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'))`);
        await queryRunner.query(`INSERT INTO "user_config"("id", "privateMode", "netWorthRange") SELECT "id", "privateMode", "netWorthRange" FROM "temporary_user_config"`);
        await queryRunner.query(`DROP TABLE "temporary_user_config"`);
    }

}
