import { Injectable } from "@nestjs/common";

/**
 * This service provides injectable capabilities for handling data involving Transactions.
 */
@Injectable()
export class TransactionService {
  getHello(): string {
    return "Hello World!";
  }
}
