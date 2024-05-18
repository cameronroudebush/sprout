/**
 * An extension upon promises which provide the ability to cancel a promise mid execution by throwing an error. You
 *  should utilize `.check` before and after long running tasks.
 */
export class CancellablePromise<T> extends Promise<T> {
  /** Reference to the executors rejection */
  private rej!: { (reason: any): void };
  /** Resolver function reference */
  private res!: { (value: T | PromiseLike<T>): void };
  /** Tracks if this promise has been canceled */
  private cancelled = false;

  constructor(executor: (this: CancellablePromise<T>, resolve: CancellablePromise<T>["res"], reject: CancellablePromise<T>["rej"]) => void) {
    let rejector: CancellablePromise<T>["rej"];
    let resolver: CancellablePromise<T>["res"];
    super((res, rej) => {
      resolver = res;
      rejector = rej;
    });
    this.rej = rejector!;
    this.res = resolver!;
    executor.call(this, this.res, this.rej);
  }

  /** Cancels the promises execution */
  cancel() {
    this.cancelled = true;
    this.rej?.call(this, "Promise cancelled");
  }

  /** Checks if the promise has been canceled and if so, this will throw an error to stop execution */
  protected check() {
    if (this.cancelled) throw new Error("Promise canceled");
  }
}
