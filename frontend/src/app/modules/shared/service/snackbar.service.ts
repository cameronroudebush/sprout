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
  open(message: string) {
    this.snackbar.open(message, "close", {
      duration: SnackbarService.DEFAULT_OPEN_TIME,
      panelClass: ["norm-snackbar"],
    });
  }

  /** Opens an error snackbar */
  openError(message: string | Error | HttpErrorResponse) {
    if (message instanceof Error) message = message.message;
    else if (message instanceof HttpErrorResponse) message = message.error;
    this.snackbar.open(message as string, "close", {
      duration: SnackbarService.DEFAULT_OPEN_TIME,
      panelClass: ["error-snackbar"],
    });
  }
}
