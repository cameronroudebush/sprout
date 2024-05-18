import { Component, OnInit } from "@angular/core";
import { AdminSetupComponent } from "@frontend/modules/setup/component/home/steps/admin/admin.component";
import { WelcomeSetupComponent } from "@frontend/modules/setup/component/home/steps/welcome/welcome.component";

type StepType = { step: string; component: any };
/** Available steps to progress through */
const steps: StepType[] = [
  { step: "welcome", component: WelcomeSetupComponent },
  { step: "admin-creation", component: AdminSetupComponent },
];

/** This component is the central spot that renders the first time setup content for sprout. */
@Component({
  selector: "setup-home",
  templateUrl: "./home.component.html",
  styleUrls: ["./home.component.scss"],
})
export class HomeSetupComponent implements OnInit {
  /** The current step that is being rendered. */
  currentStep: Pick<StepType, "step">["step"] = "welcome";

  constructor() {}

  ngOnInit() {}

  get steps() {
    return steps;
  }

  setCurrentStep(newStep?: Pick<StepType, "step">["step"]) {
    if (newStep) this.currentStep = newStep;
  }
}
