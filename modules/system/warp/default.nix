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

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.cloudflare-warp ];

    system.activationScripts.postActivation.text = lib.mkOrder 2000 ''
      install -d -m 755 -o root -g wheel "/Library/Managed Preferences"
      install -m 644 -o root -g wheel ${plist} "/Library/Managed Preferences/com.cloudflare.warp.plist"
    '';

    launchd.user.agents.cloudflare-warp = {
      serviceConfig = {
        ProgramArguments = [
          "/usr/bin/open"
          "-a"
          warpApp
        ];
        RunAtLoad = true;
      };
    };
  };
}
