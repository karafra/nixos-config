{ config, lib, pkgs, ... }:

let
  cfg = config.local.calendar;
  secret = name: [ "cat" config.sops.secrets.${name}.path ];
in
{
  options.local.calendar = {
    enable = lib.mkEnableOption "Google Calendar sync via vdirsyncer and khal";
    basePath = lib.mkOption {
      type = lib.types.str;
      default = ".local/share/calendars";
      description = "Calendar storage directory, relative to the home directory.";
    };
    clientIdSecret = lib.mkOption {
      type = lib.types.str;
      default = "data/google_oauth_client_id";
      description = "sops secret holding the Google OAuth client ID.";
    };
    clientSecretSecret = lib.mkOption {
      type = lib.types.str;
      default = "data/google_oauth_client_secret";
      description = "sops secret holding the Google OAuth client secret.";
    };
    syncInterval = lib.mkOption {
      type = lib.types.int;
      default = 900;
      description = "Seconds between vdirsyncer runs.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.${cfg.clientIdSecret} = { };
    sops.secrets.${cfg.clientSecretSecret} = { };

    accounts.calendar = {
      inherit (cfg) basePath;
      accounts.gmail = {
        primary = true;
        remote.type = "google_calendar";
        local = {
          type = "filesystem";
          fileExt = ".ics";
        };
        vdirsyncer = {
          enable = true;
          collections = [ "from b" ];
          metadata = [ "color" "displayname" ];
          tokenFile = "${config.xdg.dataHome}/vdirsyncer/google_calendar_token";
          clientIdCommand = secret cfg.clientIdSecret;
          clientSecretCommand = secret cfg.clientSecretSecret;
        };
        khal = {
          enable = true;
          type = "discover";
        };
      };
    };

    programs.vdirsyncer.enable = true;
    programs.khal.enable = true;

    launchd.agents.vdirsyncer = {
      enable = true;
      config = {
        ProgramArguments = [ "${pkgs.vdirsyncer}/bin/vdirsyncer" "sync" ];
        StartInterval = cfg.syncInterval;
        RunAtLoad = true;
      };
    };
  };
}
