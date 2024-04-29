import { NgModule } from "@angular/core";
import { BrowserModule } from "@angular/platform-browser";
import { BrowserAnimationsModule } from "@angular/platform-browser/animations";
import { RouterModule } from "@angular/router";
import { ChartsModule } from "@frontend/modules/charts/charts.module";
import { CommunicationModule } from "@frontend/modules/communication/communication.module";
import { FinanceModule } from "@frontend/modules/finance/finance.module";
import { MaterialModule } from "@frontend/modules/material/material.module";
import { RoutingModule } from "@frontend/modules/routing/routing.module";
import { SharedModule } from "@frontend/modules/shared/shared.module";
import { UserModule } from "@frontend/modules/user/user.module";
import { StoreModule } from "@ngrx/store";
import { DashboardComponent } from "./component/dashboard/dashboard.component";
import { AppComponent } from "./core.component";
import { ConfigService } from "./service/config.service";

const COMPONENTS = [AppComponent, DashboardComponent];

@NgModule({
  declarations: COMPONENTS,
  exports: COMPONENTS,
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    MaterialModule,
    StoreModule.forRoot(),
    RouterModule,
    RoutingModule,
    CommunicationModule,
    UserModule,
    SharedModule,
    FinanceModule,
    ChartsModule,
  ],
  providers: [ConfigService],
  bootstrap: [AppComponent],
})
export class AppModule {}
