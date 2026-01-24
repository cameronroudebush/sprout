import { DevicePlatform } from "@backend/user/model/user.device.type";
import { IsEnum, IsNotEmpty, IsOptional, IsString } from "class-validator";

export class RegisterDeviceDto {
  @IsString()
  @IsNotEmpty()
  token!: string;

  @IsEnum(DevicePlatform)
  @IsOptional()
  platform?: DevicePlatform;

  @IsString()
  @IsOptional()
  deviceName?: string;
}
