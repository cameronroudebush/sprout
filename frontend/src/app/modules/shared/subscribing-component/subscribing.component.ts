import { Directive, OnDestroy } from "@angular/core";
import { Subscription } from "rxjs";

/** A generic component that can be extended into other components that need to automatically destroy subscriptions for cleanup */
@Directive({})
export class SubscribingComponent implements OnDestroy {
  subscriptions: Subscription[] = [];

  constructor() {}

  ngOnDestroy(): void {
    for (let sub of this.subscriptions) sub.unsubscribe();
  }

  /** Add's a subscription to be tracked for auto destroy */
  addSubscription(subscription: Subscription | undefined) {
    if (subscription) this.subscriptions.push(subscription);
  }
}
