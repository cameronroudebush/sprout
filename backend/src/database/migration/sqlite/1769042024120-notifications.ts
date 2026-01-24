import { MigrationInterface, QueryRunner } from "typeorm";

export class Notifications1769042024120 implements MigrationInterface {
    name = 'Notifications1769042024120'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "notification" ("id" varchar PRIMARY KEY NOT NULL, "title" varchar NOT NULL, "message" varchar NOT NULL, "type" varchar NOT NULL, "createdAt" datetime NOT NULL, "isRead" boolean NOT NULL DEFAULT (0), "readAt" datetime, "userId" varchar)`);
        await queryRunner.query(`CREATE TABLE "user_device" ("id" varchar PRIMARY KEY NOT NULL, "fcmToken" varchar NOT NULL, "deviceName" varchar, "platform" varchar NOT NULL DEFAULT ('android'), "lastSeenAt" datetime NOT NULL, "userId" varchar, CONSTRAINT "UQ_034f6dc930c25b5d315462ca9bf" UNIQUE ("fcmToken"))`);
        await queryRunner.query(`CREATE TABLE "temporary_user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'), "simpleFinToken" varchar)`);
        await queryRunner.query(`INSERT INTO "temporary_user_config"("id", "privateMode", "netWorthRange") SELECT "id", "privateMode", "netWorthRange" FROM "user_config"`);
        await queryRunner.query(`DROP TABLE "user_config"`);
        await queryRunner.query(`ALTER TABLE "temporary_user_config" RENAME TO "user_config"`);
        await queryRunner.query(`CREATE TABLE "temporary_provider_rate_limit" ("id" varchar PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "lastUpdated" datetime NOT NULL, "count" integer NOT NULL, "userId" varchar, CONSTRAINT "UQ_36c4fa24ed498d2e31e26abea45" UNIQUE ("name"))`);
        await queryRunner.query(`INSERT INTO "temporary_provider_rate_limit"("id", "name", "lastUpdated", "count") SELECT "id", "name", "lastUpdated", "count" FROM "provider_rate_limit"`);
        await queryRunner.query(`DROP TABLE "provider_rate_limit"`);
        await queryRunner.query(`ALTER TABLE "temporary_provider_rate_limit" RENAME TO "provider_rate_limit"`);
        await queryRunner.query(`CREATE TABLE "temporary_notification" ("id" varchar PRIMARY KEY NOT NULL, "title" varchar NOT NULL, "message" varchar NOT NULL, "type" varchar NOT NULL, "createdAt" datetime NOT NULL, "isRead" boolean NOT NULL DEFAULT (0), "readAt" datetime, "userId" varchar, CONSTRAINT "FK_1ced25315eb974b73391fb1c81b" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION)`);
        await queryRunner.query(`INSERT INTO "temporary_notification"("id", "title", "message", "type", "createdAt", "isRead", "readAt", "userId") SELECT "id", "title", "message", "type", "createdAt", "isRead", "readAt", "userId" FROM "notification"`);
        await queryRunner.query(`DROP TABLE "notification"`);
        await queryRunner.query(`ALTER TABLE "temporary_notification" RENAME TO "notification"`);
        await queryRunner.query(`CREATE TABLE "temporary_provider_rate_limit" ("id" varchar PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "lastUpdated" datetime NOT NULL, "count" integer NOT NULL, "userId" varchar, CONSTRAINT "UQ_36c4fa24ed498d2e31e26abea45" UNIQUE ("name"), CONSTRAINT "FK_2912efb1cd8d2eda414738f9b56" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION)`);
        await queryRunner.query(`INSERT INTO "temporary_provider_rate_limit"("id", "name", "lastUpdated", "count", "userId") SELECT "id", "name", "lastUpdated", "count", "userId" FROM "provider_rate_limit"`);
        await queryRunner.query(`DROP TABLE "provider_rate_limit"`);
        await queryRunner.query(`ALTER TABLE "temporary_provider_rate_limit" RENAME TO "provider_rate_limit"`);
        await queryRunner.query(`CREATE TABLE "temporary_user_device" ("id" varchar PRIMARY KEY NOT NULL, "fcmToken" varchar NOT NULL, "deviceName" varchar, "platform" varchar NOT NULL DEFAULT ('android'), "lastSeenAt" datetime NOT NULL, "userId" varchar, CONSTRAINT "UQ_034f6dc930c25b5d315462ca9bf" UNIQUE ("fcmToken"), CONSTRAINT "FK_bda1afb30d9e3e8fb30b1e90af7" FOREIGN KEY ("userId") REFERENCES "user" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION)`);
        await queryRunner.query(`INSERT INTO "temporary_user_device"("id", "fcmToken", "deviceName", "platform", "lastSeenAt", "userId") SELECT "id", "fcmToken", "deviceName", "platform", "lastSeenAt", "userId" FROM "user_device"`);
        await queryRunner.query(`DROP TABLE "user_device"`);
        await queryRunner.query(`ALTER TABLE "temporary_user_device" RENAME TO "user_device"`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "user_device" RENAME TO "temporary_user_device"`);
        await queryRunner.query(`CREATE TABLE "user_device" ("id" varchar PRIMARY KEY NOT NULL, "fcmToken" varchar NOT NULL, "deviceName" varchar, "platform" varchar NOT NULL DEFAULT ('android'), "lastSeenAt" datetime NOT NULL, "userId" varchar, CONSTRAINT "UQ_034f6dc930c25b5d315462ca9bf" UNIQUE ("fcmToken"))`);
        await queryRunner.query(`INSERT INTO "user_device"("id", "fcmToken", "deviceName", "platform", "lastSeenAt", "userId") SELECT "id", "fcmToken", "deviceName", "platform", "lastSeenAt", "userId" FROM "temporary_user_device"`);
        await queryRunner.query(`DROP TABLE "temporary_user_device"`);
        await queryRunner.query(`ALTER TABLE "provider_rate_limit" RENAME TO "temporary_provider_rate_limit"`);
        await queryRunner.query(`CREATE TABLE "provider_rate_limit" ("id" varchar PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "lastUpdated" datetime NOT NULL, "count" integer NOT NULL, "userId" varchar, CONSTRAINT "UQ_36c4fa24ed498d2e31e26abea45" UNIQUE ("name"))`);
        await queryRunner.query(`INSERT INTO "provider_rate_limit"("id", "name", "lastUpdated", "count", "userId") SELECT "id", "name", "lastUpdated", "count", "userId" FROM "temporary_provider_rate_limit"`);
        await queryRunner.query(`DROP TABLE "temporary_provider_rate_limit"`);
        await queryRunner.query(`ALTER TABLE "notification" RENAME TO "temporary_notification"`);
        await queryRunner.query(`CREATE TABLE "notification" ("id" varchar PRIMARY KEY NOT NULL, "title" varchar NOT NULL, "message" varchar NOT NULL, "type" varchar NOT NULL, "createdAt" datetime NOT NULL, "isRead" boolean NOT NULL DEFAULT (0), "readAt" datetime, "userId" varchar)`);
        await queryRunner.query(`INSERT INTO "notification"("id", "title", "message", "type", "createdAt", "isRead", "readAt", "userId") SELECT "id", "title", "message", "type", "createdAt", "isRead", "readAt", "userId" FROM "temporary_notification"`);
        await queryRunner.query(`DROP TABLE "temporary_notification"`);
        await queryRunner.query(`ALTER TABLE "provider_rate_limit" RENAME TO "temporary_provider_rate_limit"`);
        await queryRunner.query(`CREATE TABLE "provider_rate_limit" ("id" varchar PRIMARY KEY NOT NULL, "name" varchar NOT NULL, "lastUpdated" datetime NOT NULL, "count" integer NOT NULL, CONSTRAINT "UQ_36c4fa24ed498d2e31e26abea45" UNIQUE ("name"))`);
        await queryRunner.query(`INSERT INTO "provider_rate_limit"("id", "name", "lastUpdated", "count") SELECT "id", "name", "lastUpdated", "count" FROM "temporary_provider_rate_limit"`);
        await queryRunner.query(`DROP TABLE "temporary_provider_rate_limit"`);
        await queryRunner.query(`ALTER TABLE "user_config" RENAME TO "temporary_user_config"`);
        await queryRunner.query(`CREATE TABLE "user_config" ("id" varchar PRIMARY KEY NOT NULL, "privateMode" boolean NOT NULL DEFAULT (0), "netWorthRange" varchar NOT NULL DEFAULT ('oneDay'))`);
        await queryRunner.query(`INSERT INTO "user_config"("id", "privateMode", "netWorthRange") SELECT "id", "privateMode", "netWorthRange" FROM "temporary_user_config"`);
        await queryRunner.query(`DROP TABLE "temporary_user_config"`);
        await queryRunner.query(`DROP TABLE "user_device"`);
        await queryRunner.query(`DROP TABLE "notification"`);
    }

}
