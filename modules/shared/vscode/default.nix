{ config, lib, pkgs, ... }:

let
  cfg = config.local.vscode;
in
{
  options.local.vscode = {
    enable = lib.mkEnableOption "managing VS Code user settings";

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Extra VS Code user settings, merged over the defaults.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = null;
      profiles.default.userSettings = {
        "files.autoSave" = "onFocusChange";
        "security.workspace.trust.untrustedFiles" = "open";
        "git.confirmSync" = false;
      } // cfg.settings;
    };
  };
}
