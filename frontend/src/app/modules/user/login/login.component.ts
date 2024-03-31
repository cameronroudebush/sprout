import { Component, OnInit } from "@angular/core";
import { FormControl, FormGroup, Validators } from "@angular/forms";
import { User } from "@common";
import { RouteURLs } from "@frontend/modules/routing/models/url";
import { RouterService } from "@frontend/modules/routing/service/router.service";
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
    private routerService: RouterService,
  ) {
    this.tryJWTLogin();
  }

  ngOnInit() {}

  /** Checks with the user service for a JWT and tries to use it to login */
  async tryJWTLogin() {
    this.processing = true;
    if (this.userService.cachedJWT) {
      const result = await this.userService.loginWithJWT(this.userService.cachedJWT);
      // Wipe JWT on errors
      if (!(result instanceof User) && result.isError) {
        this.userService.cachedJWT = null;
        this.loginStatus = { type: "error", message: "Session expired" };
        this.processing = false;
      } else {
        this.loginStatus = { type: "success", message: "Restoring Session" };
        // Give a timeout so they aren't so abruptly changed pages
        setTimeout(() => {
          this.routerService.redirectTo(RouteURLs.default_route);
          this.processing = false;
        }, 800);
      }
    } else this.processing = false;
  }

  /** Submits the login request */
  async submit() {
    if (this.processing) return;
    this.processing = true;
    this.loginStatus = undefined;
    if (this.form.valid) {
      const result = await this.userService.login(this.form.controls.username.value!, this.form.controls.password.value!);
      if (!(result instanceof User)) this.loginStatus = { type: "error", message: result.message };
      else {
        this.loginStatus = { type: "success", message: "Login Successful" };
        this.routerService.redirectTo(RouteURLs.default_route);
      }
    }
    this.processing = false;
  }
}
