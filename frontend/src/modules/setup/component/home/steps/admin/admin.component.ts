import { Component, Input, OnInit } from "@angular/core";
import { FormControl, FormGroup, Validators } from "@angular/forms";
import { UserCreationRequest, UserCreationResponse } from "@common";
import { RestService } from "@frontend/modules/communication/service/rest.service";
import { SnackbarService } from "@frontend/modules/shared/service/snackbar.service";

@Component({
  selector: "setup-admin",
  templateUrl: "./admin.component.html",
  styleUrls: ["./admin.component.scss"],
})
export class AdminSetupComponent implements OnInit {
  /** The on click to fire when to go to the next page */
  @Input() click!: Function;

  /** The form for the admin credentials */
  form = new FormGroup({
    username: new FormControl("", [Validators.required]),
    password: new FormControl("", [Validators.required]),
  });

  constructor(
    private restService: RestService,
    private snackbarService: SnackbarService,
  ) {}

  ngOnInit() {}

  /** Submits the admin account creation. If it succeeds, moves onto the next page, if it fails, displays the error */
  async submitAdminAccount() {
    this.form.markAllAsTouched();
    if (this.form.valid) {
      const result = await this.restService.post<UserCreationResponse>(
        "setup.createUser",
        UserCreationRequest.fromPlain({ username: this.form.get("username")?.value, password: this.form.get("password")?.value }),
      );
      if (result.payload.success == null) this.click();
      else this.snackbarService.openError(result.payload.success);
    }
  }
}
