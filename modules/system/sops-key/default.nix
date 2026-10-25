{ config, lib, username, ... }:

let
  cfg = config.local.sopsKey;
in
{
  options.local.sopsKey = {
    enable = lib.mkEnableOption "importing the sops age key into the system key location";

    source = lib.mkOption {
      type = lib.types.str;
      default = "/Users/${username}/key.txt";
      description = "Plain age key file to import when it differs from the installed key.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Runs as root before sops-nix decrypts secrets.
    system.activationScripts.preActivation.text = ''
      src="${cfg.source}"
      dest="${config.sops.age.keyFile}"
      if [ -r "$src" ] && ! cmp -s "$src" "$dest"; then
        echo "importing sops age key from $src" >&2
        mkdir -p "$(dirname "$dest")"
        install -m 600 -o root -g wheel "$src" "$dest"
      fi
    '';
  };
}
