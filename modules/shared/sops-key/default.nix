{ config, lib, ... }:

let
  cfg = config.local.sopsUserKey;
in
{
  options.local.sopsUserKey = {
    enable = lib.mkEnableOption "a user-readable copy of the sops age key for home-manager secrets";

    source = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/key.txt";
      description = "Plain age key file to import.";
    };

    keyFile = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      description = "Where home-manager's sops-nix reads the age key from (the system key is root-only).";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.age.keyFile = cfg.keyFile;

    home.activation.importSopsUserKey = lib.hm.dag.entryBetween [ "sops-nix" ] [ "writeBoundary" ] ''
      if [ -r "${cfg.source}" ] && ! cmp -s "${cfg.source}" "${cfg.keyFile}"; then
        mkdir -p "$(dirname "${cfg.keyFile}")"
        install -m 600 "${cfg.source}" "${cfg.keyFile}"
      fi
    '';
  };
}
