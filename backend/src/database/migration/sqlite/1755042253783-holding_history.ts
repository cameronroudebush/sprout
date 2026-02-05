import { MigrationInterface, QueryRunner } from "typeorm";

export class HoldingHistory1755042253783 implements MigrationInterface {
  name = "HoldingHistory1755042253783";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE TABLE "holding_history" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "costBasis" double NOT NULL, "marketValue" double NOT NULL, "purchasePrice" double NOT NULL, "shares" double NOT NULL, "holdingId" varchar)`);
    await queryRunner.query(`CREATE TABLE "temporary_holding_history" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "costBasis" double NOT NULL, "marketValue" double NOT NULL, "purchasePrice" double NOT NULL, "shares" double NOT NULL, "holdingId" varchar, CONSTRAINT "FK_47b1b6467fa4106fdb8be250f04" FOREIGN KEY ("holdingId") REFERENCES "holding" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_holding_history"("id", "time", "costBasis", "marketValue", "purchasePrice", "shares", "holdingId") SELECT "id", "time", "costBasis", "marketValue", "purchasePrice", "shares", "holdingId" FROM "holding_history"`);
    await queryRunner.query(`DROP TABLE "holding_history"`);
    await queryRunner.query(`ALTER TABLE "temporary_holding_history" RENAME TO "holding_history"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "holding_history" RENAME TO "temporary_holding_history"`);
    await queryRunner.query(`CREATE TABLE "holding_history" ("id" varchar PRIMARY KEY NOT NULL, "time" datetime NOT NULL, "costBasis" double NOT NULL, "marketValue" double NOT NULL, "purchasePrice" double NOT NULL, "shares" double NOT NULL, "holdingId" varchar)`);
    await queryRunner.query(`INSERT INTO "holding_history"("id", "time", "costBasis", "marketValue", "purchasePrice", "shares", "holdingId") SELECT "id", "time", "costBasis", "marketValue", "purchasePrice", "shares", "holdingId" FROM "temporary_holding_history"`);
    await queryRunner.query(`DROP TABLE "temporary_holding_history"`);
    await queryRunner.query(`DROP TABLE "holding_history"`);
  }
}
