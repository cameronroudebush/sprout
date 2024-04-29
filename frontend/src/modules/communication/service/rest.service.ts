import { HttpClient, HttpHeaders } from "@angular/common/http";
import { Injectable, Injector } from "@angular/core";
import { Base, RestBody, RestEndpoints } from "@common";
import { UserService } from "@frontend/modules/user/service/user.service";
import { firstValueFrom } from "rxjs";
import { environment } from "src/environments/environment";

@Injectable({
  providedIn: "root",
})
export class RestService {
  /** The endpoint string that should prefix every request */
  static readonly ENDPOINT_HEADER = "/api";
  constructor(
    private httpClient: HttpClient,
    private injector: Injector,
  ) {}

  /** Attempts to guess the backend URL based on our current connection address since they normally live in the same server */
  private guessBackendURL() {
    const windowLoc = window.location;
    // Dev mode? These are ran on different ports.
    if (!environment.production) return `${windowLoc.protocol}//${windowLoc.hostname}:8001`;
    // Https is probably on the same server with API
    else return window.location.origin + "/api";
  }

  /**
   * Given some parameters, returns the get results from the given queue
   * @param queue The queue to request data from
   */
  get<ReturnType extends Base | Base[]>(queue: RestEndpoints.supportedEndpoints) {
    const realQueue = RestEndpoints.typeToActualQueue(queue);
    const combinedURL = `${this.guessBackendURL()}${realQueue}`;
    return firstValueFrom(this.httpClient.get(combinedURL, { headers: this.messageHeaders })) as Promise<RestBody<ReturnType>>;
  }

  /**
   * Given some parameters, returns the get results from the given queue
   * @param queue The queue to request data from
   */
  post<ReturnType extends Base | Base[]>(queue: RestEndpoints.supportedEndpoints, body: Base) {
    const realQueue = RestEndpoints.typeToActualQueue(queue);
    const combinedURL = `${this.guessBackendURL()}${realQueue}`;
    const adjustedBody = RestBody.fromPlain({ payload: body });
    return firstValueFrom(this.httpClient.post(combinedURL, adjustedBody.toJSONString(), { headers: this.messageHeaders })) as Promise<RestBody<ReturnType>>;
  }

  /** Returns headers to add to every message */
  get messageHeaders() {
    let headers = new HttpHeaders({
      "Content-Type": "application/json", // Let the backend know our messages are JSON format
    });
    const authToken = this.injector.get(UserService).cachedJWT; // Prevents circular dependency
    if (authToken) headers = headers.set("Authorization", `Bearer ${authToken}`);
    return headers;
  }
}
