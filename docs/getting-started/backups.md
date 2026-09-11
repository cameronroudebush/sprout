---
title: Backups
description: Learn how backups work in Sprout.
---

<style>
.md-footer__link--next { display: none; }
</style>

# Backing Up Your Data

Your financial data is important. Sprout helps protect your data by creating automatic backups for you. While Sprout handles the creation of backups, you are still responsible for ensuring these backups are stored securely in an external location.

## Retention Strategy (Grandfather-Father-Son)

Sprout utilizes an extended **Grandfather-Father-Son (GFS)** retention policy to balance point-in-time recovery options with efficient storage usage. Rather than keeping a simple flat pool of recent snapshots, backups are automatically categorized into daily, weekly, monthly, quarterly, and yearly tiers.

Because a single backup file can satisfy multiple tier requirements simultaneously (for example, Sunday's backup serves as both a daily and a weekly snapshot), the system retains a maximum of **23 to 26 total backup files** on disk at any given time.

| Tier          | Retention Count | Description                                                                           |
| :------------ | :-------------- | :------------------------------------------------------------------------------------ |
| **Daily**     | **7**           | Retains a daily snapshot for each of the last 7 days for fast point-in-time recovery. |
| **Weekly**    | **4**           | Retains 1 snapshot per week for the last 4 weeks.                                     |
| **Monthly**   | **12**          | Retains 1 snapshot per month for the last 12 months.                                  |
| **Quarterly** | **4**           | Retains 1 snapshot per quarter for historical quarterly milestones.                   |
| **Yearly**    | **3**           | Retains 1 snapshot per year for the past 3 years for long-term archiving.             |

## Automatic Backups

Sprout automatically creates a backup of your entire database. This process runs at two specific times:

- Daily at **7:00 AM**, based on the [timezone](./configuration.md) set for the container (shortly after the morning sync).

This ensures you always have a recent backup available with no manual intervention required. Outdated backups outside of the GFS retention policy are automatically pruned during each run.

## Backup Location

The automatic backups are stored in the `backups` sub-folder within your main Sprout data directory. Based on our installation examples, you would find the backup files here on your host machine:

`/appdata/sprout/backups/`

This is why we recommend mapping a volume to the entire `/sprout` directory in the container, as it ensures both your live database and your backups are saved to your host machine.

## How to Secure Your Backups

While Sprout creates the backups, you should periodically copy them to a separate, secure location. This protects you from hardware failure or other issues with your host machine.

Simply navigate to the backup location on your host and copy the most recent backup files to another drive, a network share, or a cloud storage folder (like Google Drive or Dropbox).
