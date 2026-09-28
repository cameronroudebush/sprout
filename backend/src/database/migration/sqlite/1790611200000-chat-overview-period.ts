import { MigrationInterface, QueryRunner } from "typeorm";

export class ChatOverviewPeriod1790611200000 implements MigrationInterface {
  name = "ChatOverviewPeriod1790611200000";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "chat_overview" RENAME TO "temporary_chat_overview"`);
    await queryRunner.query(
      `CREATE TABLE "chat_overview" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "text" varchar NOT NULL, "type" varchar NOT NULL, "userId" varchar, "model" varchar, "year" integer NOT NULL DEFAULT (0), "month" integer NOT NULL DEFAULT (0), CONSTRAINT "UQ_59025734825a79c2b90afbcdc7c" UNIQUE ("month", "type", "userId", "year"), CONSTRAINT "FK_48687a6fe8f81d7993b1ead980b" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "chat_overview"("id", "time", "text", "type", "userId", "model", "year", "month") SELECT "id", "time", "text", "type", "userId", "model", CASE WHEN "type" = 'budgets' THEN CAST(strftime('%Y', "time") AS integer) ELSE 0 END, CASE WHEN "type" = 'budgets' THEN CAST(strftime('%m', "time") AS integer) ELSE 0 END FROM "temporary_chat_overview"`);
    await queryRunner.query(`DROP TABLE "temporary_chat_overview"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "chat_overview" RENAME TO "temporary_chat_overview"`);
    await queryRunner.query(`CREATE TABLE "chat_overview" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "text" varchar NOT NULL, "type" varchar NOT NULL, "userId" varchar, "model" varchar, CONSTRAINT "UQ_7bfcba7a8bad25bf9a1ac023c27" UNIQUE ("userId", "type"), CONSTRAINT "FK_48687a6fe8f81d7993b1ead980b" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "chat_overview"("id", "time", "text", "type", "userId", "model") SELECT "id", "time", "text", "type", "userId", "model" FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY "userId", "type" ORDER BY "year" DESC, "month" DESC, "time" DESC) AS "row_number" FROM "temporary_chat_overview") WHERE "row_number" = 1`);
    await queryRunner.query(`DROP TABLE "temporary_chat_overview"`);
  }
}
