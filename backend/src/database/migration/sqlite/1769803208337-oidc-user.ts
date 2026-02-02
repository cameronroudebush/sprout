import { MigrationInterface, QueryRunner } from "typeorm";

export class OidcUser1769803208337 implements MigrationInterface {
    name = 'OidcUser1769803208337'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "temporary_user" ("id" varchar PRIMARY KEY NOT NULL, "firstName" varchar, "lastName" varchar, "username" varchar NOT NULL, "admin" boolean NOT NULL DEFAULT (0), "password" varchar NOT NULL, "configId" varchar, CONSTRAINT "UQ_ba8b1b73ff0a6b15ae34619d944" UNIQUE ("configId"), CONSTRAINT "FK_2a91dde35c5a0668f32b39f49c5" FOREIGN KEY ("configId") REFERENCES "user_config" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
        await queryRunner.query(`INSERT INTO "temporary_user"("id", "firstName", "lastName", "username", "admin", "password", "configId") SELECT "id", "firstName", "lastName", "username", "admin", "password", "configId" FROM "user"`);
        await queryRunner.query(`DROP TABLE "user"`);
        await queryRunner.query(`ALTER TABLE "temporary_user" RENAME TO "user"`);
        await queryRunner.query(`CREATE TABLE "temporary_user" ("id" varchar PRIMARY KEY NOT NULL, "firstName" varchar, "lastName" varchar, "username" varchar NOT NULL, "admin" boolean NOT NULL DEFAULT (0), "password" varchar, "configId" varchar, CONSTRAINT "UQ_ba8b1b73ff0a6b15ae34619d944" UNIQUE ("configId"), CONSTRAINT "FK_2a91dde35c5a0668f32b39f49c5" FOREIGN KEY ("configId") REFERENCES "user_config" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
        await queryRunner.query(`INSERT INTO "temporary_user"("id", "firstName", "lastName", "username", "admin", "password", "configId") SELECT "id", "firstName", "lastName", "username", "admin", "password", "configId" FROM "user"`);
        await queryRunner.query(`DROP TABLE "user"`);
        await queryRunner.query(`ALTER TABLE "temporary_user" RENAME TO "user"`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "user" RENAME TO "temporary_user"`);
        await queryRunner.query(`CREATE TABLE "user" ("id" varchar PRIMARY KEY NOT NULL, "firstName" varchar, "lastName" varchar, "username" varchar NOT NULL, "admin" boolean NOT NULL DEFAULT (0), "password" varchar NOT NULL, "configId" varchar, CONSTRAINT "UQ_ba8b1b73ff0a6b15ae34619d944" UNIQUE ("configId"), CONSTRAINT "FK_2a91dde35c5a0668f32b39f49c5" FOREIGN KEY ("configId") REFERENCES "user_config" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
        await queryRunner.query(`INSERT INTO "user"("id", "firstName", "lastName", "username", "admin", "password", "configId") SELECT "id", "firstName", "lastName", "username", "admin", "password", "configId" FROM "temporary_user"`);
        await queryRunner.query(`DROP TABLE "temporary_user"`);
        await queryRunner.query(`ALTER TABLE "user" RENAME TO "temporary_user"`);
        await queryRunner.query(`CREATE TABLE "user" ("id" varchar PRIMARY KEY NOT NULL, "firstName" varchar, "lastName" varchar, "username" varchar NOT NULL, "admin" boolean NOT NULL DEFAULT (0), "password" varchar NOT NULL, "configId" varchar, CONSTRAINT "UQ_ba8b1b73ff0a6b15ae34619d944" UNIQUE ("configId"), CONSTRAINT "FK_2a91dde35c5a0668f32b39f49c5" FOREIGN KEY ("configId") REFERENCES "user_config" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
        await queryRunner.query(`INSERT INTO "user"("id", "firstName", "lastName", "username", "admin", "password", "configId") SELECT "id", "firstName", "lastName", "username", "admin", "password", "configId" FROM "temporary_user"`);
        await queryRunner.query(`DROP TABLE "temporary_user"`);
    }

}
