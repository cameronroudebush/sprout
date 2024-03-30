import { createFeatureSelector, createSelector } from "@ngrx/store";
import { USER_NGRX_KEY, UserState } from "./user.state";

export const selectUserState = createFeatureSelector<UserState>(USER_NGRX_KEY);

/** Grabs the currently logged in user via the store's state */
export const getCurrentUserId = createSelector(selectUserState, (state) => state.selectedUserId);
/** Selects the current user object from state */
export const selectCurrentUser = createSelector(selectUserState, getCurrentUserId, (state, userId) => {
  if (userId == null) return undefined;
  else return state.entities[userId];
});
