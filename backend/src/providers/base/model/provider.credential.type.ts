/** Credential scope supported by a provider. */
export enum ProviderCredentialsMode {
  /** Credentials configured once for the system and shared across users. */
  SYSTEM = "system",
  /** Credentials configured separately by each user. */
  USER = "user",
}
