import { MigrationInterface, QueryRunner } from "typeorm";

export class Chat1770163236598 implements MigrationInterface {
  name = "Chat1770163236598";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE TABLE "chat_history" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "text" varchar NOT NULL, "isThinking" boolean NOT NULL DEFAULT (0), "role" double NOT NULL, "userId" varchar)`);
    await queryRunner.query(`CREATE TABLE "temporary_user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar, "geminiKey" varchar)`);
    await queryRunner.query(`INSERT INTO "temporary_user_config"("id", "privateMode", "netWorthRange", "simpleFinToken") SELECT "id", "privateMode", "netWorthRange", "simpleFinToken" FROM "user_config"`);
    await queryRunner.query(`DROP TABLE "user_config"`);
    await queryRunner.query(`ALTER TABLE "temporary_user_config" RENAME TO "user_config"`);
    await queryRunner.query(`CREATE TABLE "temporary_chat_history" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "text" varchar NOT NULL, "isThinking" boolean NOT NULL DEFAULT (0), "role" double NOT NULL, "userId" varchar, CONSTRAINT "FK_6bac64204c7b416f465e17957ed" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_chat_history"("id", "time", "text", "isThinking", "role", "userId") SELECT "id", "time", "text", "isThinking", "role", "userId" FROM "chat_history"`);
    await queryRunner.query(`DROP TABLE "chat_history"`);
    await queryRunner.query(`ALTER TABLE "temporary_chat_history" RENAME TO "chat_history"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "chat_history" RENAME TO "temporary_chat_history"`);
    await queryRunner.query(`CREATE TABLE "chat_history" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "text" varchar NOT NULL, "isThinking" boolean NOT NULL DEFAULT (0), "role" double NOT NULL, "userId" varchar)`);
    await queryRunner.query(`INSERT INTO "chat_history"("id", "time", "text", "isThinking", "role", "userId") SELECT "id", "time", "text", "isThinking", "role", "userId" FROM "temporary_chat_history"`);
    await queryRunner.query(`DROP TABLE "temporary_chat_history"`);
    await queryRunner.query(`ALTER TABLE "user_config" RENAME TO "temporary_user_config"`);
    await queryRunner.query(`CREATE TABLE "user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar)`);
    await queryRunner.query(`INSERT INTO "user_config"("id", "privateMode", "netWorthRange", "simpleFinToken") SELECT "id", "privateMode", "netWorthRange", "simpleFinToken" FROM "temporary_user_config"`);
    await queryRunner.query(`DROP TABLE "temporary_user_config"`);
    await queryRunner.query(`DROP TABLE "chat_history"`);
  }
}
