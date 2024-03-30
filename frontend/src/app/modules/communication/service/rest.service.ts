import { HttpClient, HttpHeaders } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { Base, RestBody, RestEndpoints } from "@common";
import { firstValueFrom } from "rxjs";
import { environment } from "src/environments/environment";

@Injectable({
  providedIn: "root",
})
export class RestService {
  /** The endpoint string that should prefix every request */
  static readonly ENDPOINT_HEADER = "/api";
  constructor(private httpClient: HttpClient) {}

  /** Attempts to guess the backend URL based on our current connection address since they normally live in the same server */
  private guessBackendURL() {
    // TODO: Base URL?
    const windowLoc = window.location;
    // Dev mode? These are ran on different ports.
    if (!environment.production) return `${windowLoc.protocol}//${windowLoc.hostname}:8001`;
    // Https is probably on the same server
    else return window.location.origin;
  }

  /**
   * Given some parameters, returns the get results from the given queue
   * @param queue The queue to request data from
   */
  get<ReturnType extends Base>(queue: RestEndpoints.supportedEndpoints) {
    const realQueue = RestEndpoints.typeToActualQueue(queue);
    const combinedURL = `${this.guessBackendURL()}${realQueue}`;
    return firstValueFrom(this.httpClient.get(combinedURL, { headers: this.messageHeaders })) as Promise<RestBody<ReturnType>>;
  }

  /**
   * Given some parameters, returns the get results from the given queue
   * @param queue The queue to request data from
   */
  post<ReturnType extends Base>(queue: RestEndpoints.supportedEndpoints, body: RestBody<any>) {
    const realQueue = RestEndpoints.typeToActualQueue(queue);
    const combinedURL = `${this.guessBackendURL()}${realQueue}`;
    return firstValueFrom(this.httpClient.post(combinedURL, body.toJSONString(), { headers: this.messageHeaders })) as Promise<RestBody<ReturnType>>;
  }

  /** Returns headers to add to every message */
  get messageHeaders() {
    return new HttpHeaders({
      "Content-Type": "application/json", // Let the backend know our messages are JSON format
      Authorization: `Bearer ${""}`, // TODO: JWT
    });
  }
}
