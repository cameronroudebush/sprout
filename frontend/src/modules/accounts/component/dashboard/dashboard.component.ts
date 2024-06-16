import { Component, OnInit } from "@angular/core";
import { AccountState } from "@frontend/modules/accounts/store/account.state";
import { SubscribingComponent } from "@frontend/modules/shared/component/subscribing-component/subscribing.component";
import { Store } from "@ngrx/store";
import { selectAccountState } from "../../store/account.selector";
import { Account } from "@common";

@Component({
  selector: "accounts-dashboard",
  templateUrl: "./dashboard.component.html",
  styleUrls: ["./dashboard.component.scss"],
})
export class AccountsDashboardComponent extends SubscribingComponent implements OnInit {
  accounts: Account[] = [];

  constructor(private store: Store<AccountState>) {
    super();
    this.addSubscription(this.store.select(selectAccountState).subscribe((x) => (this.accounts = x.accounts)));
  }

  ngOnInit() {}
}
