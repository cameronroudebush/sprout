import { MigrationInterface, QueryRunner } from "typeorm";

export class UserAdditions1777056063876 implements MigrationInterface {
  name = "UserAdditions1777056063876";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE "temporary_user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar, "geminiKey" varchar, "secureMode" boolean NOT NULL DEFAULT (0), "userId" varchar, "allowWidgets" boolean NOT NULL DEFAULT (0), "themeStyle" varchar NOT NULL DEFAULT ('colored'), "emailUpdateFrequency" varchar NOT NULL DEFAULT ('none'), CONSTRAINT "UQ_99b09c9b3db3b4cd9058e313d5e" UNIQUE ("userId"), CONSTRAINT "FK_50aa50cd542e360ea75bf4eaa74" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_user_config"("id", "privateMode", "netWorthRange", "simpleFinToken", "geminiKey", "secureMode", "userId", "allowWidgets", "themeStyle") SELECT "id", "privateMode", "netWorthRange", "simpleFinToken", "geminiKey", "secureMode", "userId", "allowWidgets", "themeStyle" FROM "user_config"`);
    await queryRunner.query(`DROP TABLE "user_config"`);
    await queryRunner.query(`ALTER TABLE "temporary_user_config" RENAME TO "user_config"`);
    await queryRunner.query(`CREATE TABLE "temporary_user" ("id" varchar PRIMARY KEY NOT NULL, "firstName" varchar, "lastName" varchar, "username" varchar NOT NULL, "admin" boolean NOT NULL DEFAULT (0), "password" varchar, "email" varchar)`);
    await queryRunner.query(`INSERT INTO "temporary_user"("id", "firstName", "lastName", "username", "admin", "password") SELECT "id", "firstName", "lastName", "username", "admin", "password" FROM "user"`);
    await queryRunner.query(`DROP TABLE "user"`);
    await queryRunner.query(`ALTER TABLE "temporary_user" RENAME TO "user"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "user" RENAME TO "temporary_user"`);
    await queryRunner.query(`CREATE TABLE "user" ("id" varchar PRIMARY KEY NOT NULL, "firstName" varchar, "lastName" varchar, "username" varchar NOT NULL, "admin" boolean NOT NULL DEFAULT (0), "password" varchar)`);
    await queryRunner.query(`INSERT INTO "user"("id", "firstName", "lastName", "username", "admin", "password") SELECT "id", "firstName", "lastName", "username", "admin", "password" FROM "temporary_user"`);
    await queryRunner.query(`DROP TABLE "temporary_user"`);
    await queryRunner.query(`ALTER TABLE "user_config" RENAME TO "temporary_user_config"`);
    await queryRunner.query(
      `CREATE TABLE "user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar, "geminiKey" varchar, "secureMode" boolean NOT NULL DEFAULT (0), "userId" varchar, "allowWidgets" boolean NOT NULL DEFAULT (0), "themeStyle" varchar NOT NULL DEFAULT ('colored'), CONSTRAINT "UQ_99b09c9b3db3b4cd9058e313d5e" UNIQUE ("userId"), CONSTRAINT "FK_50aa50cd542e360ea75bf4eaa74" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "user_config"("id", "privateMode", "netWorthRange", "simpleFinToken", "geminiKey", "secureMode", "userId", "allowWidgets", "themeStyle") SELECT "id", "privateMode", "netWorthRange", "simpleFinToken", "geminiKey", "secureMode", "userId", "allowWidgets", "themeStyle" FROM "temporary_user_config"`);
    await queryRunner.query(`DROP TABLE "temporary_user_config"`);
  }
}
