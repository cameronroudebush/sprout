import { MigrationInterface, QueryRunner } from "typeorm";

export class ManualSync1788388281131 implements MigrationInterface {
  name = "ManualSync1788388281131";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE TABLE "temporary_sync" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "status" varchar NOT NULL, "failureReason" varchar, "userId" varchar, "provider" varchar NOT NULL, "notified" boolean NOT NULL DEFAULT (0), "isManual" boolean NOT NULL DEFAULT (0), CONSTRAINT "FK_955332e7ec672ab3ac8fdc028d3" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_sync"("id", "time", "status", "failureReason", "userId", "provider", "notified") SELECT "id", "time", "status", "failureReason", "userId", "provider", "notified" FROM "sync"`);
    await queryRunner.query(`DROP TABLE "sync"`);
    await queryRunner.query(`ALTER TABLE "temporary_sync" RENAME TO "sync"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "sync" RENAME TO "temporary_sync"`);
    await queryRunner.query(`CREATE TABLE "sync" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "status" varchar NOT NULL, "failureReason" varchar, "userId" varchar, "provider" varchar NOT NULL, "notified" boolean NOT NULL DEFAULT (0), CONSTRAINT "FK_955332e7ec672ab3ac8fdc028d3" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "sync"("id", "time", "status", "failureReason", "userId", "provider", "notified") SELECT "id", "time", "status", "failureReason", "userId", "provider", "notified" FROM "temporary_sync"`);
    await queryRunner.query(`DROP TABLE "temporary_sync"`);
  }
}
