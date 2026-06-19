import { SproutLogger } from "@backend/core/logger";

/** Defines a discrete cross-property configuration requirement rule */
export interface ConfigurationRequirement {
  name: string;
  /** Returns true if the configuration structure passes the validation rule */
  validate: () => boolean;
  /** Executed when validate returns false. Corrects the in-memory state and handles logging. */
  fix: (logger: SproutLogger) => void;
}
