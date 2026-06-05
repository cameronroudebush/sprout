import { MigrationInterface, QueryRunner } from "typeorm";

export class BatchSync1780629454074 implements MigrationInterface {
  name = "BatchSync1780629454074";

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Clean up invalid old style SYNC's that don't populate a provider which is now the required style.
    await queryRunner.query(`DELETE FROM "sync" WHERE "provider" IS NULL OR "provider" = ''`);

    await queryRunner.query(`CREATE TABLE "temporary_sync" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "status" varchar NOT NULL, "failureReason" varchar, "userId" varchar, "provider" varchar, "notified" boolean NOT NULL DEFAULT (0), CONSTRAINT "FK_955332e7ec672ab3ac8fdc028d3" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_sync"("id", "time", "status", "failureReason", "userId", "provider") SELECT "id", "time", "status", "failureReason", "userId", "provider" FROM "sync"`);
    await queryRunner.query(`DROP TABLE "sync"`);
    await queryRunner.query(`ALTER TABLE "temporary_sync" RENAME TO "sync"`);
    await queryRunner.query(`CREATE TABLE "temporary_sync" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "status" varchar NOT NULL, "failureReason" varchar, "userId" varchar, "provider" varchar NOT NULL, "notified" boolean NOT NULL DEFAULT (0), CONSTRAINT "FK_955332e7ec672ab3ac8fdc028d3" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_sync"("id", "time", "status", "failureReason", "userId", "provider", "notified") SELECT "id", "time", "status", "failureReason", "userId", "provider", "notified" FROM "sync"`);
    await queryRunner.query(`DROP TABLE "sync"`);
    await queryRunner.query(`ALTER TABLE "temporary_sync" RENAME TO "sync"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "sync" RENAME TO "temporary_sync"`);
    await queryRunner.query(`CREATE TABLE "sync" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "status" varchar NOT NULL, "failureReason" varchar, "userId" varchar, "provider" varchar, "notified" boolean NOT NULL DEFAULT (0), CONSTRAINT "FK_955332e7ec672ab3ac8fdc028d3" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "sync"("id", "time", "status", "failureReason", "userId", "provider", "notified") SELECT "id", "time", "status", "failureReason", "userId", "provider", "notified" FROM "temporary_sync"`);
    await queryRunner.query(`DROP TABLE "temporary_sync"`);
    await queryRunner.query(`ALTER TABLE "sync" RENAME TO "temporary_sync"`);
    await queryRunner.query(`CREATE TABLE "sync" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "status" varchar NOT NULL, "failureReason" varchar, "userId" varchar, "provider" varchar, CONSTRAINT "FK_955332e7ec672ab3ac8fdc028d3" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "sync"("id", "time", "status", "failureReason", "userId", "provider") SELECT "id", "time", "status", "failureReason", "userId", "provider" FROM "temporary_sync"`);
    await queryRunner.query(`DROP TABLE "temporary_sync"`);
  }
}
