import { Component } from "@angular/core";
import { RestService } from "@frontend/modules/communication/service/rest.service";

@Component({
  selector: "app-root",
  templateUrl: "app.component.html",
  styleUrls: ["app.component.scss"],
})
export class AppComponent {
  // TODO: Remove
  constructor(public restService: RestService) {}
}
