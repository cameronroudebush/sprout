import { NgModule } from "@angular/core";
import { BrowserModule } from "@angular/platform-browser";
import { BrowserAnimationsModule } from "@angular/platform-browser/animations";
import { RouterModule } from "@angular/router";
import { CommunicationModule } from "@frontend/modules/communication/communication.module";
import { RoutingModule } from "@frontend/modules/routing/routing.module";
import { SharedModule } from "@frontend/modules/shared/shared.module";
import { UserModule } from "@frontend/modules/user/user.module";
import { StoreModule } from "@ngrx/store";
import { AppComponent } from "./app.component";

@NgModule({
  declarations: [AppComponent],
  imports: [BrowserModule, BrowserAnimationsModule, StoreModule.forRoot(), RouterModule, RoutingModule, CommunicationModule, UserModule, SharedModule],
  providers: [],
  bootstrap: [AppComponent],
})
export class AppModule {}
