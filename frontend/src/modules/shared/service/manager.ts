import { Injectable, Injector } from "@angular/core";

/** This service manager provides base capabilities that can handle functionality for other registered services */
@Injectable({
  providedIn: "root",
})
export class ServiceManager {
  constructor(private injector: Injector) {}
}
