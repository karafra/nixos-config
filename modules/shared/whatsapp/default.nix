{ config, lib, pkgs, ... }:
let
  cfg = config.local.whatsapp;
in
{
  options.local.whatsapp.enable = lib.mkEnableOption "WhatsApp";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.whatsapp-for-mac ];
  };
}
