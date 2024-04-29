import { User } from "@backend/model/user";

/** This class implements capabilities that allow for first time setup configuration */
export class FirstTimeSetup {
  /**
   * Returns if this is the first time this application has been ran requiring the user to set some default values for setup
   */
  static async isFirstTimeSetup() {
    // We base this off of if at-least one admin user exists
    return (await User.find({ where: { admin: true } })).length === 0;
  }
}
