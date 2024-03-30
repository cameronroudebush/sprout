import { NgModule } from "@angular/core";
import { BrowserModule } from "@angular/platform-browser";
import { RouteReuseStrategy, RouterModule } from "@angular/router";
import { CommunicationModule } from "@frontend/modules/communication/communication.module";
import { RoutingModule } from "@frontend/modules/routing/routing.module";
import { UserModule } from "@frontend/modules/user/user.module";
import { IonicModule, IonicRouteStrategy } from "@ionic/angular";
import { StoreModule } from "@ngrx/store";
import { AppComponent } from "./app.component";

@NgModule({
  declarations: [AppComponent],
  imports: [BrowserModule, IonicModule.forRoot(), StoreModule.forRoot(), RouterModule, RoutingModule, CommunicationModule, UserModule],
  providers: [{ provide: RouteReuseStrategy, useClass: IonicRouteStrategy }],
  bootstrap: [AppComponent],
})
export class AppModule {}
