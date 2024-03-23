import { CommonModule } from "@angular/common";
import { NgModule } from "@angular/core";
import { FormsModule } from "@angular/forms";
import { IonicModule } from "@ionic/angular";

const MODULES = [FormsModule, IonicModule, CommonModule];

/** A module that provides the necessary material components we use across this app */
@NgModule({
  imports: MODULES,
  exports: MODULES,
})
export class MaterialModule {}
