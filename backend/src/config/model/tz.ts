import { formatInTimeZone } from "date-fns-tz";

/** Timezone related functionality for use with this app */
export class TimeZone {
  /** Returns the timezone configured by the env variables. Defaults to UTC. */
  static get timeZone() {
    return process.env["TZ"] ?? "America/New_York";
  }

  /** Given a date, returns a string formatted in the timezone as configured. */
  static formatDate(date: Date, format = "yyyy-MM-dd HH:mm:ss zzz") {
    return formatInTimeZone(date, this.timeZone, format);
  }
}
