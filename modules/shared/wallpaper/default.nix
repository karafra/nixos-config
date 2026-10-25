{ config, lib, pkgs, ... }:

let
  cfg = config.local.wallpaper;
  target = "${config.home.homeDirectory}/Pictures/wallpaper${cfg.extension}";
in
{
  options.local.wallpaper = {
    image = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Wallpaper image to link into ~/Pictures and apply to every desktop (macOS).";
    };

    extension = lib.mkOption {
      type = lib.types.str;
      default = ".jpg";
      description = "File extension of the linked wallpaper.";
    };
  };

  config = lib.mkIf (cfg.image != null && pkgs.stdenv.hostPlatform.isDarwin) {
    home.file."Pictures/wallpaper${cfg.extension}".source = cfg.image;

    home.activation.setWallpaper = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      /usr/bin/osascript -e 'tell application "System Events" to tell every desktop to set picture to (POSIX file "${target}")' || true
    '';
  };
}
