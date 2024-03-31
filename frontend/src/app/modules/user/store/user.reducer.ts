import { User } from "@common";
import { UserActions } from "@frontend/modules/user/store/user.actions";
import { UserState } from "@frontend/modules/user/store/user.state";
import { EntityAdapter, createEntityAdapter } from "@ngrx/entity";
import { createReducer, on } from "@ngrx/store";

export const UserAdapter: EntityAdapter<User> = createEntityAdapter<User>();

export const userReducer = createReducer(
  UserAdapter.getInitialState({
    // additional entity state properties
    selectedUserId: undefined,
  } as UserState),
  on(UserActions.addUser, (state, { user }) => {
    return UserAdapter.addOne(user, state);
  }),
  on(UserActions.setCurrentUser, (state, { user }) => {
    return { ...state, selectedUserId: user?.id };
  }),
);
