import { DatabaseDecorators } from "@backend/database/decorators";
import { DatabaseBase } from "@backend/database/model/database.base";

/**
 * This class is used to provide a rate limit to different providers. This is required
 *  to restrict us to only call N amount of calls per provider per day.
 */
@DatabaseDecorators.entity()
export class ProviderRateLimit extends DatabaseBase {
  /** The max number of API calls per day for this provider. */
  readonly MAX_CALLS_PER_DAY: number;

  /** The unique name of this provider */
  @DatabaseDecorators.column({ nullable: false, unique: true })
  name: string;

  /** The last day this was updated */
  @DatabaseDecorators.column({ nullable: false })
  lastUpdated: Date = new Date();

  /** The current call count for the current day of API calls. */
  @DatabaseDecorators.column({ nullable: false })
  count: number = 0;

  constructor(name: string, maxCallsPerDay: number) {
    super();
    this.name = name;
    this.MAX_CALLS_PER_DAY = maxCallsPerDay;
  }

  /** Either increments the current count and last updated date or throws an error if there will be too many calls. */
  async incrementOrError() {
    const inDb = (await this.get()) as this | undefined;
    const today = new Date();
    // No limit tracked in the db? Create one.
    if (inDb == null) {
      this.count++;
      await this.insert();
    }
    // Else handle like normally
    else if (inDb.count >= this.MAX_CALLS_PER_DAY && inDb.lastUpdated.toDateString() === today.toDateString()) {
      throw new Error(`Rate limit exceeded for provider ${this.name}. Max calls per day: ${this.MAX_CALLS_PER_DAY}`);
    } else if (inDb.lastUpdated.toDateString() !== today.toDateString()) {
      inDb.count = 1;
      inDb.lastUpdated = today;
      await inDb.update();
    } else {
      inDb.count++;
      inDb.lastUpdated = today;
      await inDb.update();
    }
  }
}
