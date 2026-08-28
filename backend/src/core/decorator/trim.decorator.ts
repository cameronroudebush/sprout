import { Transform } from "class-transformer";

/** Generic string trim transformer */
export const Trim = () => Transform(({ value }) => value?.trim());
