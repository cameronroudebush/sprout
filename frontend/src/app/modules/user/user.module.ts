import { CommonModule } from "@angular/common";
import { NgModule } from "@angular/core";
import { RouterModule } from "@angular/router";
import { MaterialModule } from "@frontend/modules/material/material.module";
import { SharedModule } from "@frontend/modules/shared/shared.module";
import { LoginComponent } from "@frontend/modules/user/login/login.component";
import { StoreModule } from "@ngrx/store";
import { UserService } from "./service/user.service";
import { userReducer } from "./store/user.reducer";
import { USER_NGRX_KEY } from "./store/user.state";

@NgModule({
  declarations: [LoginComponent],
  providers: [UserService],
  imports: [CommonModule, MaterialModule, StoreModule.forFeature(USER_NGRX_KEY, userReducer), RouterModule, SharedModule],
})
export class UserModule {}
