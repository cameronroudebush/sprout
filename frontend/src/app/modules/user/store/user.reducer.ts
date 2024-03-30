import { User } from "@common";
import { UserActions } from "@frontend/modules/user/store/user.actions";
import { EntityAdapter, createEntityAdapter } from "@ngrx/entity";
import { createReducer, on } from "@ngrx/store";

export const adapter: EntityAdapter<User> = createEntityAdapter<User>();

export const userReducer = createReducer(
  adapter.getInitialState({
    // additional entity state properties
    selectedUserId: null,
  }),
  on(UserActions.addUser, (state, { user }) => {
    return adapter.addOne(user, state);
  }),
  on(UserActions.setCurrentUser, (state, { user }) => {
    return adapter.setOne(user, state);
  }),
);
