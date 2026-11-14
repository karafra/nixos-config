{ config, pkgs, lib, ... }:

let
  cfg = config.local.warp;
  plist = pkgs.writeText "com.cloudflare.warp.plist" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>organization</key>
      <string>${cfg.team}</string>
    </dict>
    </plist>
  '';
  warpApp = "${pkgs.cloudflare-warp}/Applications/Cloudflare WARP.app";
  installedWarpApp = "/Applications/Nix Apps/Cloudflare WARP.app";
  primaryUser = config.system.primaryUser;
  primaryHome = config.users.users.${primaryUser}.home;
in
{
  options.local.warp = {
    enable = lib.mkEnableOption "Cloudflare WARP";

    team = lib.mkOption {
      type = lib.types.str;
      default = "karafra-net";
      description = "Zero Trust team (organization) name WARP enrolls into.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.cloudflare-warp ];

      system.activationScripts.postActivation.text = lib.mkOrder 2000 ''
        install -d -m 755 -o root -g wheel "/Library/Managed Preferences"
        install -m 644 -o root -g wheel ${plist} "/Library/Managed Preferences/com.cloudflare.warp.plist"
        rm -f "/Library/LaunchDaemons/com.cloudflare.warp.updater.plist"

        uid="$(id -u ${lib.escapeShellArg primaryUser})"
        while read -r pid processUid command; do
          if [ "$processUid" = "$uid" ]; then
            case "$command" in
              /nix/store/*-cloudflare-warp*/Applications/Cloudflare\ WARP.app/Contents/MacOS/Cloudflare\ WARP|\
              /nix/store/*-cloudflare-warp*/Applications/Cloudflare\ WARP.app/Contents/MacOS/Cloudflare\ WARP\ *)
                kill "$pid"
                ;;
            esac
          fi
        done < <(ps -axo pid=,uid=,command=)
      '';

      launchd.daemons.cloudflare-warp-daemon = {
        serviceConfig = {
          Label = "com.cloudflare.1dot1dot1dot1.macos.warp.daemon";
          ProgramArguments = [ "${warpApp}/Contents/Resources/CloudflareWARP" ];
          KeepAlive = true;
          RunAtLoad = true;
          UserName = "root";
          SoftResourceLimits.NumberOfFiles = 32768;
        };
      };

      launchd.user.agents.cloudflare-warp = {
        serviceConfig = {
          ProgramArguments = [
            "/usr/bin/open"
            "-a"
            installedWarpApp
          ];
          RunAtLoad = true;
        };
      };
    })
    (lib.mkIf (!cfg.enable) {
      system.activationScripts.postActivation.text = lib.mkOrder 2000 ''
        preferences="/Library/Managed Preferences/com.cloudflare.warp.plist"
        app="/Applications/Nix Apps/Cloudflare WARP.app"
        user=${lib.escapeShellArg primaryUser}
        home=${lib.escapeShellArg primaryHome}
        uid="$(id -u "$user")"

        for label in org.nixos.cloudflare-warp org.nixos.warp-gui; do
          agent="$home/Library/LaunchAgents/$label.plist"
          if [ -f "$agent" ]; then
            target="$(/usr/libexec/PlistBuddy -c 'Print :ProgramArguments:2' "$agent")"
            case "$target" in
              /nix/store/*-cloudflare-warp*/Applications/Cloudflare\ WARP.app|\
              "/Applications/Nix Apps/Cloudflare WARP.app")
                if launchctl print "gui/$uid/$label" >/dev/null 2>&1; then
                  launchctl bootout "gui/$uid/$label"
                fi
                rm "$agent"
                ;;
              *)
                echo "Leaving $agent in place: it does not point to the Nix Warp app." >&2
                ;;
            esac
          fi
        done

        while read -r pid processUid command; do
          if [ "$processUid" = "$uid" ]; then
            case "$command" in
              /nix/store/*-cloudflare-warp*/Applications/Cloudflare\ WARP.app/Contents/MacOS/Cloudflare\ WARP|\
              /nix/store/*-cloudflare-warp*/Applications/Cloudflare\ WARP.app/Contents/MacOS/Cloudflare\ WARP\ *|\
              "/Applications/Nix Apps/Cloudflare WARP.app/Contents/MacOS/Cloudflare WARP"|\
              "/Applications/Nix Apps/Cloudflare WARP.app/Contents/MacOS/Cloudflare WARP "*)
                kill "$pid"
                ;;
            esac
          fi
        done < <(ps -axo pid=,uid=,command=)

        if [ -f "$preferences" ]; then
          if cmp -s ${plist} "$preferences"; then
            rm "$preferences"
          else
            echo "Leaving $preferences in place: it does not match the configured Warp preferences." >&2
          fi
        fi

        if [ -L "$app" ]; then
          case "$(readlink "$app")" in
            /nix/store/*-cloudflare-warp*/Applications/Cloudflare\ WARP.app)
              rm "$app"
              ;;
          esac
        fi
      '';
    })
  ];
}
