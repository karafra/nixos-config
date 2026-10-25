{ config, lib, ... }:

let
  cfg = config.local.touchid;
in
{
  options.local.touchid = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Allow Touch ID to authenticate sudo.";
    };

    reattach = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Make Touch ID for sudo also work inside tmux and screen.";
    };
  };

  config = lib.mkIf cfg.enable {
    security.pam.services.sudo_local = {
      touchIdAuth = true;
      reattach = cfg.reattach;
    };
  };
}
