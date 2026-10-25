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

  config.programs.gh = {
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
