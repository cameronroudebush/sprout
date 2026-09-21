import { MigrationInterface, QueryRunner } from "typeorm";

export class ExtraHoldingData17898497889801789849788980 implements MigrationInterface {
  name = "ExtraHoldingData17898497889801789849788980";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE "temporary_holding" ("id" varchar PRIMARY KEY NOT NULL, "currency" varchar NOT NULL, "costBasis" double NOT NULL, "description" varchar NOT NULL, "marketValue" double NOT NULL, "purchasePrice" double NOT NULL, "shares" double NOT NULL, "symbol" varchar NOT NULL, "accountId" varchar NOT NULL, "extra" jsonb, CONSTRAINT "FK_8c0907bcf6ceda6c72e16798097" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_holding"("id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId") SELECT "id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId" FROM "holding"`);
    await queryRunner.query(`DROP TABLE "holding"`);
    await queryRunner.query(`ALTER TABLE "temporary_holding" RENAME TO "holding"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "holding" RENAME TO "temporary_holding"`);
    await queryRunner.query(`CREATE TABLE "holding" ("id" varchar PRIMARY KEY NOT NULL, "currency" varchar NOT NULL, "costBasis" double NOT NULL, "description" varchar NOT NULL, "marketValue" double NOT NULL, "purchasePrice" double NOT NULL, "shares" double NOT NULL, "symbol" varchar NOT NULL, "accountId" varchar NOT NULL, CONSTRAINT "FK_8c0907bcf6ceda6c72e16798097" FOREIGN KEY ("accountId") REFERENCES "account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "holding"("id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId") SELECT "id", "currency", "costBasis", "description", "marketValue", "purchasePrice", "shares", "symbol", "accountId" FROM "temporary_holding"`);
    await queryRunner.query(`DROP TABLE "temporary_holding"`);
  }
}
