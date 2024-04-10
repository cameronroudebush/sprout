import { Injectable } from "@angular/core";
import { Transaction, TransactionRequest } from "@common";
import { RestService } from "@frontend/modules/communication/service/rest.service";
import { UserState } from "@frontend/modules/user/store/user.state";
import { Store } from "@ngrx/store";
import { FinanceActions } from "../store/finance.actions";

@Injectable({
  providedIn: "root",
})
export class TransactionService {
  constructor(
    private store: Store<UserState>,
    private restService: RestService,
  ) {}

  /** Requests total transactions from the backend for the given index range */
  async requestTransactions(startIndex = 0, endIndex = 50) {
    const result = await this.restService.post<Transaction[]>("transaction.get", TransactionRequest.fromPlain({ startIndex, endIndex }));
    const transactions = Transaction.fromPlainArray(result.payload);
    this.store.dispatch(FinanceActions.addTransactions({ transactions }));
  }
}
