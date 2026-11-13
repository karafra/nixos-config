{ config, lib, pkgs, ... }:

let
  cfg = config.local.spotify;
in
{
  options.local.spotify.enable = lib.mkEnableOption "Spotify";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.spotify ];
  };
}
