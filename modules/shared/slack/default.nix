{ config, lib, pkgs, ... }:

let
  cfg = config.local.slack;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  deepLink = "slack://open" + lib.optionalString (cfg.teamId != null) "?team=${cfg.teamId}";
  slackApp = "${config.home.homeDirectory}/Applications/Home Manager Apps/Slack.app";
  marker = "${config.home.homeDirectory}/.cache/home-manager/slack-first-login";

  # Wayland screen sharing goes through PipeWire and the desktop portal.
  slackLinux = pkgs.symlinkJoin {
    name = "slack-screenshare";
    paths = [ pkgs.slack ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/slack \
        --add-flags "--enable-features=WebRTCPipeWireCapturer --ozone-platform-hint=auto"
    '';
  };
in
{
  options.local.slack = {
    enable = lib.mkEnableOption "Slack with screen sharing and automatic sign-in";

    teamId = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "T0123456789";
      description = "Workspace ID opened on login, so Slack resumes the existing (SSO) session.";
    };

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Launch Slack at login.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [ (if isDarwin then pkgs.slack else slackLinux) ];
    }

    (lib.mkIf isDarwin {
      # Open the workspace right after the first install so sign-in starts without manual steps.
      home.activation.slackFirstLogin = lib.mkIf cfg.autoStart (lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        if [ ! -e "${marker}" ]; then
          /bin/mkdir -p "$(dirname "${marker}")"
          /usr/bin/open -a "${slackApp}" || true
          /bin/sleep 3
          /usr/bin/open "${deepLink}" || true
          : > "${marker}"
        fi
      '');

      launchd.agents.slack = lib.mkIf cfg.autoStart {
        enable = true;
        config = {
          ProgramArguments = [ "/usr/bin/open" "-a" slackApp ];
          RunAtLoad = true;
        };
      };
    })

    (lib.mkIf (!isDarwin && cfg.autoStart) {
      xdg.configFile."autostart/slack.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Slack
        Exec=slack ${deepLink}
      '';
    })
  ]);
}
