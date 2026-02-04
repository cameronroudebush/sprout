import { Base } from "@backend/core/model/base";
import { User } from "@backend/user/model/user.model";
import { ApiProperty } from "@nestjs/swagger";
import { IsEnum } from "class-validator";

/** This enum represents the different types of SSE events that can be sent to clients. */
export enum SSEEventType {
  /** Used to tell the app when a manual sync has completed */
  SYNC = "sync",
  /** Tells the app to forcible update all of it's data */
  FORCE_UPDATE = "force-update",
  /** Used to inform that the app needs to grab updated notification info */
  NOTIFICATION = "notification",
  /** Used to inform that the app that a new LLM response is ready for our user */
  CHAT = "chat",
}

/** This represents the SSE data that will be sent to clients */
export class SSEData {
  @ApiProperty({ enum: SSEEventType })
  @IsEnum(SSEEventType)
  event: SSEEventType;

  payload?: Base;

  constructor(event: SSEEventType, payload?: Base) {
    this.event = event;
    this.payload = payload;
  }
}

/** This interface shows what an SSE event will contain when informing clients from the backend. */
export class SSEEvent {
  user: User;
  data: SSEData;

  constructor(user: User, data: SSEData) {
    this.user = user;
    this.data = data;
  }
}
