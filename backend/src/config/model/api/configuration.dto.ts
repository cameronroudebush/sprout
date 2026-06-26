import { Base } from "@backend/core/model/base";

/** Specifies where tile data comes from when rendering vector tiles in the frontend */
export class TileConfig {
  /** Tiles to display on maps for dark mode. Should be vector tiles. */
  light: string;
  /** Tiles to display on maps for light mode. Should be vector tiles. */
  dark: string;

  constructor(light: string, dark: string) {
    this.light = light;
    this.dark = dark;
  }
}

/**
 * This class helps correlate configuration content from the backend to the frontend.
 *
 * This config is **secure** and can only be read by authenticated users.
 */
export class APIConfig extends Base {
  /** Determines if the chat key is already provided and users shouldn't be able to set theirs then. */
  chatKeyProvidedInBackend: boolean;

  /** Tracks if email is enabled and functional */
  emailEnabled: boolean;

  /** The brandfetch client ID used for displaying logos. */
  brandFetchClientId?: string;

  /** Tile config */
  tiles: TileConfig;

  constructor(chatKeyProvidedInBackend: boolean, emailEnabled: boolean, tiles: TileConfig, brandFetchClientId?: string) {
    super();
    this.chatKeyProvidedInBackend = chatKeyProvidedInBackend;
    this.emailEnabled = emailEnabled;
    this.tiles = tiles;
    this.brandFetchClientId = brandFetchClientId;
  }
}
