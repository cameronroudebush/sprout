import { Component, OnInit } from "@angular/core";
import { AccountState } from "@frontend/modules/accounts/store/account.state";
import { SubscribingComponent } from "@frontend/modules/shared/component/subscribing-component/subscribing.component";
import { Store } from "@ngrx/store";
import { selectAccountState } from "../../store/account.selector";

@Component({
  selector: "accounts-dashboard",
  templateUrl: "./dashboard.component.html",
  styleUrls: ["./dashboard.component.scss"],
})
export class AccountsDashboardComponent extends SubscribingComponent implements OnInit {
  constructor(private store: Store<AccountState>) {
    super();
    this.addSubscription(
      this.store.select(selectAccountState).subscribe((x) => {
        console.log(x);
      }),
    );
  }

  ngOnInit() {}
}
