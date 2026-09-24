import { MigrationInterface, QueryRunner } from "typeorm";

export class ChatModel17902074341681790207434168 implements MigrationInterface {
  name = "ChatModel17902074341681790207434168";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE TABLE "temporary_chat_history" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "text" varchar NOT NULL, "isThinking" boolean NOT NULL DEFAULT (0), "role" double NOT NULL, "userId" varchar, "model" varchar, CONSTRAINT "FK_6bac64204c7b416f465e17957ed" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_chat_history"("id", "time", "text", "isThinking", "role", "userId") SELECT "id", "time", "text", "isThinking", "role", "userId" FROM "chat_history"`);
    await queryRunner.query(`DROP TABLE "chat_history"`);
    await queryRunner.query(`ALTER TABLE "temporary_chat_history" RENAME TO "chat_history"`);
    await queryRunner.query(`CREATE TABLE "temporary_chat_overview" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "text" varchar NOT NULL, "type" varchar NOT NULL, "userId" varchar, "model" varchar, CONSTRAINT "UQ_7bfcba7a8bad25bf9a1ac023c27" UNIQUE ("userId", "type"), CONSTRAINT "FK_48687a6fe8f81d7993b1ead980b" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_chat_overview"("id", "time", "text", "type", "userId") SELECT "id", "time", "text", "type", "userId" FROM "chat_overview"`);
    await queryRunner.query(`DROP TABLE "chat_overview"`);
    await queryRunner.query(`ALTER TABLE "temporary_chat_overview" RENAME TO "chat_overview"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "chat_overview" RENAME TO "temporary_chat_overview"`);
    await queryRunner.query(`CREATE TABLE "chat_overview" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "text" varchar NOT NULL, "type" varchar NOT NULL, "userId" varchar, CONSTRAINT "UQ_7bfcba7a8bad25bf9a1ac023c27" UNIQUE ("userId", "type"), CONSTRAINT "FK_48687a6fe8f81d7993b1ead980b" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "chat_overview"("id", "time", "text", "type", "userId") SELECT "id", "time", "text", "type", "userId" FROM "temporary_chat_overview"`);
    await queryRunner.query(`DROP TABLE "temporary_chat_overview"`);
    await queryRunner.query(`ALTER TABLE "chat_history" RENAME TO "temporary_chat_history"`);
    await queryRunner.query(`CREATE TABLE "chat_history" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "text" varchar NOT NULL, "isThinking" boolean NOT NULL DEFAULT (0), "role" double NOT NULL, "userId" varchar, CONSTRAINT "FK_6bac64204c7b416f465e17957ed" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "chat_history"("id", "time", "text", "isThinking", "role", "userId") SELECT "id", "time", "text", "isThinking", "role", "userId" FROM "temporary_chat_history"`);
    await queryRunner.query(`DROP TABLE "temporary_chat_history"`);
  }
}
