import { User } from "@common";
import { EntityState } from "@ngrx/entity";

export const USER_NGRX_KEY = "user";

export interface UserState extends EntityState<User> {
  selectedUserId: number | undefined;
}
