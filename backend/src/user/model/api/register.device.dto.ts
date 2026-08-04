import { DevicePlatform } from "@backend/user/model/user.device.type";
import { IsEnum, IsNotEmpty, IsOptional, IsString } from "class-validator";

export class RegisterDeviceDto {
  /** Unique device ID */
  @IsString()
  @IsNotEmpty()
  deviceId!: string;

  @IsString()
  @IsOptional()
  token?: string | undefined;

  @IsEnum(DevicePlatform)
  @IsOptional()
  platform?: DevicePlatform;

  @IsString()
  @IsOptional()
  deviceName?: string;
}
