{ config, lib, ... }:

let
  cfg = config.local.gh;
in
{
  options.local.gh.user = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "GitHub user name for github.com.";
  };

  options.local.gh.tokenSecret = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "sops secret holding a GitHub token, exported as GH_TOKEN in zsh.";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.tokenSecret != null) {
      sops.secrets.${cfg.tokenSecret} = { };
      programs.zsh.initContent = ''
        [ -r "${config.sops.secrets.${cfg.tokenSecret}.path}" ] && export GH_TOKEN="$(< "${
          config.sops.secrets.${cfg.tokenSecret}.path
        }")"
      '';
    })
    {
      programs.gh = {
        enable = true;
        settings = {
          git_protocol = "https";
          prompt = "enabled";
          prefer_editor_prompt = "disabled";
          aliases.co = "pr checkout";
        };
        hosts."github.com" = {
          git_protocol = "ssh";
        }
        // lib.optionalAttrs (cfg.user != null) { inherit (cfg) user; };
      };
    }
  ];
}
