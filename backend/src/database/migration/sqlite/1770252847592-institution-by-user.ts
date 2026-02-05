import { randomUUID } from "crypto";
import { MigrationInterface, QueryRunner } from "typeorm";

export class InstitutionByUser1770252847592 implements MigrationInterface {
  name = "InstitutionByUser1770252847592";

  /** Iterates over the database and corrects existing IDs to use random ones */
  async updateAccountIds(queryRunner: QueryRunner) {
    // Fetch all accounts and their current institutions
    const accounts = await queryRunner.query(`SELECT * FROM "account"`);

    for (const account of accounts) {
      const oldInstId = account.institutionId;
      const userId = account.userId;

      // Fetch the actual institution data using the old ID
      const oldInst = (await queryRunner.query(`SELECT * FROM "institution" WHERE id = $1`, [oldInstId]))[0];
      if (oldInst) {
        // Check if we have already migrated/created this institution for THIS user
        const existingNewInst = await queryRunner.query(`SELECT id FROM "institution" WHERE name = $1 AND url = $2 AND "userId" = $3`, [oldInst.name, oldInst.url, userId]);

        let finalInstId: string;

        if (existingNewInst.length > 0) {
          // If it exists, reuse that ID
          finalInstId = existingNewInst[0].id;
        } else {
          // Otherwise, create a new one with a fresh UUID
          finalInstId = randomUUID();
          await queryRunner.query(
            `INSERT INTO "institution" (id, url, name, "hasError", "userId") 
                     VALUES ($1, $2, $3, $4, $5)`,
            [finalInstId, oldInst.url, oldInst.name, oldInst.hasError, userId],
          );
        }

        // Update the account to point to the correct (new) ID
        await queryRunner.query(`UPDATE "account" SET "institutionId" = $1 WHERE id = $2`, [finalInstId, account.id]);

        // If we're not using the original institution anymore, remove it
        const otherAccountsUsingOldId = await queryRunner.query(`SELECT id FROM "account" WHERE "institutionId" = $1`, [oldInstId]);
        if (otherAccountsUsingOldId.length === 0) await queryRunner.query(`DELETE FROM "institution" WHERE id = $1`, [oldInstId]);
      }
    }
  }

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE TABLE "temporary_institution" ("id" varchar PRIMARY KEY NOT NULL, "url" varchar NOT NULL, "name" varchar NOT NULL, "hasError" boolean NOT NULL, "userId")`);
    await queryRunner.query(`INSERT INTO "temporary_institution"("id", "url", "name", "hasError") SELECT "id", "url", "name", "hasError" FROM "institution"`);
    await queryRunner.query(`DROP TABLE "institution"`);
    await queryRunner.query(`ALTER TABLE "temporary_institution" RENAME TO "institution"`);

    await this.updateAccountIds(queryRunner);

    await queryRunner.query(`CREATE TABLE "temporary_institution" ("id" varchar PRIMARY KEY NOT NULL, "url" varchar NOT NULL, "name" varchar NOT NULL, "hasError" boolean NOT NULL, "userId" varchar NOT NULL, CONSTRAINT "FK_166fa924f28750b4b9f8227ed9d" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION)`);
    await queryRunner.query(`INSERT INTO "temporary_institution"("id", "url", "name", "hasError", "userId") SELECT "id", "url", "name", "hasError", "userId" FROM "institution"`);
    await queryRunner.query(`DROP TABLE "institution"`);
    await queryRunner.query(`ALTER TABLE "temporary_institution" RENAME TO "institution"`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "institution" RENAME TO "temporary_institution"`);
    await queryRunner.query(`CREATE TABLE "institution" ("id" varchar PRIMARY KEY NOT NULL, "url" varchar NOT NULL, "name" varchar NOT NULL, "hasError" boolean NOT NULL, "userId" varchar NOT NULL)`);
    await queryRunner.query(`INSERT INTO "institution"("id", "url", "name", "hasError", "userId") SELECT "id", "url", "name", "hasError", "userId" FROM "temporary_institution"`);
    await queryRunner.query(`DROP TABLE "temporary_institution"`);
    await queryRunner.query(`ALTER TABLE "institution" RENAME TO "temporary_institution"`);
    await queryRunner.query(`CREATE TABLE "institution" ("id" varchar PRIMARY KEY NOT NULL, "url" varchar NOT NULL, "name" varchar NOT NULL, "hasError" boolean NOT NULL)`);
    await queryRunner.query(`INSERT INTO "institution"("id", "url", "name", "hasError") SELECT "id", "url", "name", "hasError" FROM "temporary_institution"`);
    await queryRunner.query(`DROP TABLE "temporary_institution"`);
  }
}
