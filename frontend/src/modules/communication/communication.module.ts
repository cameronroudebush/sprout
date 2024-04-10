import { CommonModule } from "@angular/common";
import { HttpClientModule } from "@angular/common/http";
import { NgModule } from "@angular/core";
import { UserModule } from "@frontend/modules/user/user.module";
import { RestService } from "./service/rest.service";

@NgModule({
  declarations: [],
  imports: [CommonModule, HttpClientModule, UserModule],
  providers: [RestService],
  bootstrap: [],
})
export class CommunicationModule {}
