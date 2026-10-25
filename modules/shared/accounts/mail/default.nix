{ config, lib, pkgs, ... }:

let
  cfg = config.local.mail;
in
{
  options.local.mail = {
    enable = lib.mkEnableOption "Gmail sync via mbsync and msmtp";
    address = lib.mkOption {
      type = lib.types.str;
      description = "Gmail address.";
    };
    realName = lib.mkOption {
      type = lib.types.str;
      description = "Name used in outgoing mail.";
    };
    passwordSecret = lib.mkOption {
      type = lib.types.str;
      default = "data/gmail_app_password";
      description = "sops secret holding the Gmail app password.";
    };
    syncInterval = lib.mkOption {
      type = lib.types.int;
      default = 300;
      description = "Seconds between mbsync runs.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.${cfg.passwordSecret} = { };

    accounts.email.accounts.gmail = {
      primary = true;
      flavor = "gmail.com";
      inherit (cfg) address realName;
      passwordCommand = "cat ${config.sops.secrets.${cfg.passwordSecret}.path}";
      mbsync = {
        enable = true;
        create = "maildir";
      };
      msmtp.enable = true;
    };

    programs.mbsync.enable = true;
    programs.msmtp.enable = true;

    launchd.agents.mbsync = {
      enable = true;
      config = {
        ProgramArguments = [ "${pkgs.isync}/bin/mbsync" "-a" ];
        StartInterval = cfg.syncInterval;
        RunAtLoad = true;
      };
    };
  };
}
