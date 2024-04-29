import { User } from "@common";

/** This class defines base capabilities for each service to implement as they see fit */
export abstract class ServiceBase {
  /** This function will be called whenever this service gets initialized via service manager */
  async initialize(): Promise<any> {}

  /**
   * This function will be called with the current authenticated user when a new one is authenticated
   * @param user The User that has been authenticated to this app
   */
  async onUserAuthenticated(_user: User): Promise<void> {}
}
