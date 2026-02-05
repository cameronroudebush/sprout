import { MigrationInterface, QueryRunner } from "typeorm";

export class AccountSubTypes1759423770056 implements MigrationInterface {
  name = "AccountSubTypes1759423770056";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE "temporary_account" ("id" varchar PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "provider" varchar NOT NULL, "currency" varchar NOT NULL, "balance" double NOT NULL, "availableBalance" double NOT NULL, "type" varchar NOT NULL, "institutionId" varchar, "userId" varchar, "extra" json, "subType" varchar, CONSTRAINT "UQ_414d4052f22837655ff312168cb" UNIQUE ("name"), CONSTRAINT "FK_60328bf27019ff5498c4b977421" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION, CONSTRAINT "FK_b0d9c345163894d7476574eaf84" FOREIGN KEY ("institutionId") REFERENCES "institution" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "temporary_account"("id", "name", "provider", "currency", "balance", "availableBalance", "type", "institutionId", "userId", "extra") SELECT "id", "name", "provider", "currency", "balance", "availableBalance", "type", "institutionId", "userId", "extra" FROM "account"`);
    await queryRunner.query(`DROP TABLE "account"`);
    await queryRunner.query(`ALTER TABLE "temporary_account" RENAME TO "account"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "account" RENAME TO "temporary_account"`);
    await queryRunner.query(
      `CREATE TABLE "account" ("id" varchar PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "provider" varchar NOT NULL, "currency" varchar NOT NULL, "balance" double NOT NULL, "availableBalance" double NOT NULL, "type" varchar NOT NULL, "institutionId" varchar, "userId" varchar, "extra" json, CONSTRAINT "UQ_414d4052f22837655ff312168cb" UNIQUE ("name"), CONSTRAINT "FK_60328bf27019ff5498c4b977421" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION, CONSTRAINT "FK_b0d9c345163894d7476574eaf84" FOREIGN KEY ("institutionId") REFERENCES "institution" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION)`,
    );
    await queryRunner.query(`INSERT INTO "account"("id", "name", "provider", "currency", "balance", "availableBalance", "type", "institutionId", "userId", "extra") SELECT "id", "name", "provider", "currency", "balance", "availableBalance", "type", "institutionId", "userId", "extra" FROM "temporary_account"`);
    await queryRunner.query(`DROP TABLE "temporary_account"`);
  }
}
