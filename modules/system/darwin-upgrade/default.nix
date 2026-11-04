{ config, lib, pkgs, ... }:

let
  cfg = config.local.darwinUpgrade;
  uid = config.users.users.${cfg.user}.uid;
in
{
  options.local.darwinUpgrade = {
    enable = lib.mkEnableOption "periodic darwin-rebuild from a flake, run inside the user's GUI session";

    user = lib.mkOption {
      type = lib.types.str;
      description = "User whose GUI session runs the rebuild; must have a fixed uid.";
    };

    flake = lib.mkOption {
      type = lib.types.str;
      description = "Flake reference to switch to, including the configuration name.";
      example = "github:karafra/nixos-config/main#darwin";
    };

    interval = lib.mkOption {
      type = lib.types.int;
      default = 600;
      description = "Seconds between upgrade attempts.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = uid != null;
      message = "local.darwinUpgrade requires users.users.${cfg.user}.uid to be set.";
    }];

    # Runs via the user's GUI session to avoid the Full Disk Access check, so it skips until they are logged in.
    launchd.daemons.darwin-upgrade = {
      command = toString (pkgs.writeShellScript "darwin-upgrade" ''
        if [ "$(/usr/bin/stat -f %Su /dev/console)" != "${cfg.user}" ]; then
          echo "$(date): ${cfg.user} is not logged in, skipping"
          exit 0
        fi
        exec /bin/launchctl asuser ${toString uid} \
          /run/current-system/sw/bin/darwin-rebuild switch --flake ${lib.escapeShellArg cfg.flake}
      '');
      serviceConfig = {
        RunAtLoad = true;
        StartInterval = cfg.interval;
        StandardOutPath = "/var/log/darwin-upgrade.log";
        StandardErrorPath = "/var/log/darwin-upgrade.log";
      };
    };
  };
}
