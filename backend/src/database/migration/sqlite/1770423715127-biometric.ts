import { MigrationInterface, QueryRunner } from "typeorm";

export class Biometric1770423715127 implements MigrationInterface {
  name = "Biometric1770423715127";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE TABLE "temporary_user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar, "geminiKey" varchar, "secureMode" boolean NOT NULL DEFAULT (0))`);
    await queryRunner.query(`INSERT INTO "temporary_user_config"("id", "privateMode", "netWorthRange", "simpleFinToken", "geminiKey") SELECT "id", "privateMode", "netWorthRange", "simpleFinToken", "geminiKey" FROM "user_config"`);
    await queryRunner.query(`DROP TABLE "user_config"`);
    await queryRunner.query(`ALTER TABLE "temporary_user_config" RENAME TO "user_config"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "user_config" RENAME TO "temporary_user_config"`);
    await queryRunner.query(`CREATE TABLE "user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar, "geminiKey" varchar)`);
    await queryRunner.query(`INSERT INTO "user_config"("id", "privateMode", "netWorthRange", "simpleFinToken", "geminiKey") SELECT "id", "privateMode", "netWorthRange", "simpleFinToken", "geminiKey" FROM "temporary_user_config"`);
    await queryRunner.query(`DROP TABLE "temporary_user_config"`);
  }
}
