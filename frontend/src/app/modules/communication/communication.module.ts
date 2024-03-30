import { CommonModule } from "@angular/common";
import { HttpClientModule } from "@angular/common/http";
import { NgModule } from "@angular/core";
import { RestService } from "./services/rest.service";

@NgModule({
  declarations: [],
  imports: [CommonModule, HttpClientModule],
  providers: [RestService],
  bootstrap: [],
})
export class CommunicationModule {}
