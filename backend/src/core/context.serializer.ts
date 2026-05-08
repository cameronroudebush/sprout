import { User } from "@backend/user/model/user.model";
import { ClassSerializerContextOptions, ClassSerializerInterceptor, ExecutionContext, Injectable } from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { ClassTransformOptions } from "class-transformer";

/** Class transformer user context */
export type ClassTransformerContext = ClassSerializerContextOptions & { context: ({ user: User | undefined } & { [key: string]: any }) | undefined };

/** This serializer extends the base {@link ClassSerializerInterceptor} to auto convert to JSON as necessary for our messages + add the ability for the user to be seen from the context.*/
@Injectable()
export class ContextSerializerInterceptor extends ClassSerializerInterceptor {
  constructor(reflector: Reflector) {
    super(reflector);
  }

  protected override getContextOptions(context: ExecutionContext): ClassTransformOptions {
    const defaultOptions = super.getContextOptions(context) || {};
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    const customOptions: Record<string, any> = {
      ...defaultOptions,
      context: {
        ...(defaultOptions as any).context,
        user: user,
      },
    };
    return customOptions as ClassTransformOptions;
  }
}
