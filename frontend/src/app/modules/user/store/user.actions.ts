import { User } from "@common";
import { createActionGroup, props } from "@ngrx/store";

export const UserActions = createActionGroup({
  source: "User",
  events: {
    AddUser: props<{ user: User }>(),
    SetCurrentUser: props<{ user: User }>(),
  },
});
