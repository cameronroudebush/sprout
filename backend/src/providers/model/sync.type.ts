export enum SyncTriggerType {
  /** Scheduled 6 AM / 6 PM batches */
  SCHEDULED = "scheduled",
  /** Spontaneous background webhooks (e.g., Plaid) */
  WEBHOOK = "webhook",
  /**  User manually tapped "Sync Now" in the app */
  MANUAL = "manual",
}
