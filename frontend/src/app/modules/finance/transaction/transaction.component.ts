import { Component, OnInit } from "@angular/core";
import { Transaction } from "@common";
import { TransactionService } from "@frontend/modules/finance/service/transaction.service";
import { FinanceState } from "@frontend/modules/finance/store/finance.state";
import { Column } from "@frontend/modules/shared/shared-table/shared-table.component";
import { SubscribingComponent } from "@frontend/modules/shared/subscribing-component/subscribing.component";
import { Store } from "@ngrx/store";
import { selectFinanceState } from "../store/finance.selector";

@Component({
  selector: "finance-transaction",
  templateUrl: "./transaction.component.html",
  styleUrls: ["./transaction.component.scss"],
})
export class TransactionComponent extends SubscribingComponent implements OnInit {
  availableTransactions: Transaction[] = [];
  /** Columns to render in the table */
  displayColumns: Column<Transaction>[] = [new Column("account"), new Column("amount")];

  constructor(
    private store: Store<FinanceState>,
    private transactionService: TransactionService,
  ) {
    super();
    this.addSubscription(this.store.select(selectFinanceState).subscribe((state) => (this.availableTransactions = state.transactions)));
    // Grab our initial transaction set
    this.transactionService.requestTransactions();
  }

  ngOnInit() {}
}
