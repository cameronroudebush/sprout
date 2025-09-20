---
title: Backups
description: Learn how to backups work in Sprout.
---

# Backing Up Your Data

Your financial data is important. Sprout helps protect your data by creating automatic backups for you. While Sprout handles the creation of backups, you are still responsible for ensuring these backups are stored securely in an external location.

## Automatic Backups

Sprout automatically creates a compressed backup of your entire database. This process runs at two specific times:

-   Daily at **4:00 AM**, based on the [timezone](./configuration.md) set for the container.
-   Every time the container starts up.

This ensures you always have a recent backup available with no manual intervention required.

## Backup Location

The automatic backups are stored in the backups sub-folder within your main Sprout data directory. Based on our installation examples, you would find the backup files here on your host machine:

`/appdata/sprout/backups/`

This is why we recommend mapping a volume to the entire /sprout directory in the container, as it ensures both your live database and your backups are saved to your host machine.

## How to Secure Your Backups

While Sprout creates the backups, you should periodically copy them to a separate, secure location. This protects you from hardware failure or other issues with your host machine.

Simply navigate to the backup location on your host and copy the most recent backup files to another drive, a network share, or a cloud storage folder (like Google Drive or Dropbox).
