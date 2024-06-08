import { Component, OnInit } from "@angular/core";
import { UnsecureAppConfiguration } from "@common";
import { ConfigService } from "@frontend/modules/core/service/config.service";
import { RouteURLs } from "@frontend/modules/routing/models/url";
import { RouterService } from "@frontend/modules/routing/service/router.service";
import { AdminSetupComponent } from "@frontend/modules/setup/component/home/steps/admin/admin.component";
import { CompleteSetupComponent } from "@frontend/modules/setup/component/home/steps/complete/complete.component";
import { WelcomeSetupComponent } from "@frontend/modules/setup/component/home/steps/welcome/welcome.component";

type StepType = { step: UnsecureAppConfiguration["firstTimeSetupPosition"]; component: any; header: string };
/** Available steps to progress through */
const steps: StepType[] = [
  { step: "welcome", component: WelcomeSetupComponent, header: "Welcome to Sprout!" },
  { step: "admin", component: AdminSetupComponent, header: "Admin User Creation" },
  { step: "complete", component: CompleteSetupComponent, header: "Setup Complete" },
];

/** This component is the central spot that renders the first time setup content for sprout. */
@Component({
  selector: "setup-home",
  templateUrl: "./home.component.html",
  styleUrls: ["./home.component.scss"],
})
export class HomeSetupComponent implements OnInit {
  /** The current step that is being rendered. */
  currentStep: Pick<StepType, "step">["step"];

  constructor(
    private configService: ConfigService,
    private routerService: RouterService,
  ) {
    this.currentStep = this.configService.config?.firstTimeSetupPosition ?? "welcome";
  }

  ngOnInit() {}

  getStepContentByStep(step: Pick<StepType, "step">["step"] = this.currentStep) {
    return this.steps.find((x) => x.step === step);
  }

  get steps() {
    return steps;
  }

  setCurrentStep(newStep?: Pick<StepType, "step">["step"]) {
    if (newStep) this.currentStep = newStep;
    // Redirect back to login on last step
    else this.routerService.redirectTo(RouteURLs.login);
  }
}
