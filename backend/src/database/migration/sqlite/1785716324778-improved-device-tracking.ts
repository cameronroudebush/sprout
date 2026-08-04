import { MigrationInterface, QueryRunner } from "typeorm";

export class ImprovedDeviceTracking1785716324778 implements MigrationInterface {
  name = "ImprovedDeviceTracking1785716324778";

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS "user_device"`);
    await queryRunner.query(`
            CREATE TABLE "user_device" (
                "id" varchar PRIMARY KEY NOT NULL,
                "deviceId" varchar NOT NULL,
                "fcmToken" varchar,
                "deviceName" varchar,
                "platform" varchar NOT NULL DEFAULT ('android'),
                "lastSeenAt" datetime NOT NULL,
                "userId" varchar,
                CONSTRAINT "FK_bda1afb30d9e3e8fb30b1e90af7" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
            )
        `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS "user_device"`);
    await queryRunner.query(`
            CREATE TABLE "user_device" (
                "id" varchar PRIMARY KEY NOT NULL,
                "fcmToken" varchar NOT NULL,
                "deviceName" varchar,
                "platform" varchar NOT NULL DEFAULT ('android'),
                "lastSeenAt" datetime NOT NULL,
                "userId" varchar,
                CONSTRAINT "UQ_034f6dc930c25b5d315462ca9bf" UNIQUE ("fcmToken"),
                CONSTRAINT "FK_bda1afb30d9e3e8fb30b1e90af7" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
            )
        `);
  }
}
