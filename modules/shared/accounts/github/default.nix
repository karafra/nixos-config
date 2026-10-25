{ config, lib, ... }:

let
  cfg = config.local.gh;
in
{
  options.local.gh.tokenSecret = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "sops secret holding a GitHub token, exported as GH_TOKEN in zsh.";
  };

  config = lib.mkIf (cfg.tokenSecret != null) {
    sops.secrets.${cfg.tokenSecret} = { };
    programs.zsh.initContent = ''
      [ -r "${config.sops.secrets.${cfg.tokenSecret}.path}" ] && export GH_TOKEN="$(< "${config.sops.secrets.${cfg.tokenSecret}.path}")"
    '';
  };
}
