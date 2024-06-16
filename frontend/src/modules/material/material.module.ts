import { CommonModule } from "@angular/common";
import { NgModule } from "@angular/core";
import { FormsModule, ReactiveFormsModule } from "@angular/forms";
import { MatButtonModule } from "@angular/material/button";
import { MatCardModule } from "@angular/material/card";
import { MatFormFieldModule } from "@angular/material/form-field";
import { MatIconModule } from "@angular/material/icon";
import { MatInputModule } from "@angular/material/input";
import { MatMenuModule } from "@angular/material/menu";
import { MatPaginatorModule } from "@angular/material/paginator";
import { MatProgressSpinnerModule } from "@angular/material/progress-spinner";
import { MatSelectModule } from "@angular/material/select";
import { MatStepperModule } from "@angular/material/stepper";
import { MatTableModule } from "@angular/material/table";
import { IonicModule } from "@ionic/angular";
import {MatExpansionModule} from '@angular/material/expansion'; 

const MODULES = [
  FormsModule,
  IonicModule,
  CommonModule,
  FormsModule,
  ReactiveFormsModule,
  MatFormFieldModule,
  MatInputModule,
  MatButtonModule,
  MatProgressSpinnerModule,
  MatIconModule,
  MatMenuModule,
  MatTableModule,
  MatCardModule,
  MatStepperModule,
  MatPaginatorModule,
  MatSelectModule,
  MatExpansionModule
];

/** A module that provides the necessary material components we use across this app */
@NgModule({
  imports: MODULES,
  exports: MODULES,
})
export class MaterialModule {}
