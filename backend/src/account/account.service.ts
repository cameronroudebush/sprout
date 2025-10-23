import { Injectable } from "@nestjs/common";

/**
 * This service provides injectable capabilities for handling data involving Accounts.
 */
@Injectable()
export class AccountService {
  getHello(): string {
    return "Hello World!";
  }
}
