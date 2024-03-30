import { CommonModule } from "@angular/common";
import { NgModule } from "@angular/core";
import { StoreModule } from "@ngrx/store";
import { UserService } from "./service/user.service";
import { userReducer } from "./store/user.reducer";
import { USER_NGRX_KEY } from "./store/user.state";

@NgModule({
  declarations: [],
  providers: [UserService],
  imports: [CommonModule, StoreModule.forFeature(USER_NGRX_KEY, userReducer)],
})
export class UserModule {}
