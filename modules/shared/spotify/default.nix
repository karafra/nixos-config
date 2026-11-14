{ config, lib, pkgs, ... }:

let
  cfg = config.local.spotify;
in
{
  options.local.spotify = {
    enable = lib.mkEnableOption "Spotify";
    disableAutoStart = lib.mkEnableOption "disabling the Spotify macOS startup helper";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.spotify ];

    home.activation.disableSpotifyAutoStart =
      lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin && cfg.disableAutoStart)
        (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          $DRY_RUN_CMD /bin/launchctl disable "gui/$(/usr/bin/id -u)/com.spotify.client.startuphelper"
        '');
  };
}
