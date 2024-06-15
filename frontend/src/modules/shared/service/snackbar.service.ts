import { HttpErrorResponse } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { MatSnackBar } from "@angular/material/snack-bar";

/**
 * Provides a central location for snackbar configuration for opening them
 * @see [This file for panel class styling](../../material/themes/snackbar.scss)
 */
@Injectable({
  providedIn: "root",
})
export class SnackbarService {
  /** How many milliseconds to leave a snackbar open for */
  static readonly DEFAULT_OPEN_TIME = 8000;

  constructor(private snackbar: MatSnackBar) {}

  /** Opens a standard snackbar */
  open(message: string, time = SnackbarService.DEFAULT_OPEN_TIME) {
    this.snackbar.open(message, "close", {
      duration: time,
      panelClass: ["norm-snackbar"],
    });
  }

  /** Opens an error snackbar */
  openError(message: string | Error | HttpErrorResponse, time = SnackbarService.DEFAULT_OPEN_TIME) {
    if (message instanceof Error) message = message.message;
    else if (message instanceof HttpErrorResponse) message = message.error;
    this.snackbar.open(message as string, "close", {
      duration: time,
      panelClass: ["error-snackbar"],
    });
  }
}
