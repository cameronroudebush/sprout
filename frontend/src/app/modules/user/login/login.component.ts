import { Component, OnInit } from "@angular/core";
import { FormControl, FormGroup, Validators } from "@angular/forms";
import { User } from "@common";
import { RouteURLs } from "@frontend/modules/routing/models/url";
import { RedirectService } from "@frontend/modules/routing/service/redirect.service";
import { UserService } from "@frontend/modules/user/service/user.service";

@Component({
  selector: "user-login",
  templateUrl: "./login.component.html",
  styleUrls: ["./login.component.scss"],
})
export class LoginComponent implements OnInit {
  /** Form group for login information */
  form = new FormGroup({
    username: new FormControl("", [Validators.required]),
    password: new FormControl("", [Validators.required]),
  });
  /** Boolean to track if we are currently doing some processing for the login request */
  processing = false;
  /** Headers to display above the login form */
  loginStatus: { type: "error" | "normal" | "success"; message: string } | undefined;

  constructor(
    private userService: UserService,
    private redirectService: RedirectService,
  ) {}

  ngOnInit() {}

  /** Submits the login request */
  async submit() {
    this.processing = true;
    this.loginStatus = undefined;
    if (this.form.valid) {
      const result = await this.userService.login(this.form.controls.username.value!, this.form.controls.password.value!);
      if (!(result instanceof User)) this.loginStatus = { type: "error", message: result.message };
      else {
        this.loginStatus = { type: "success", message: "Login Successful" };
        this.redirectService.redirectTo(RouteURLs.default_route);
      }
    }
    this.processing = false;
  }
}
