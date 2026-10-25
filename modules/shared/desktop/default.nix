{ config, lib, pkgs, ... }:

let
  cfg = config.local.desktop;
in
{
  options.local.desktop.iconArrangement = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum [ "none" "grid" "name" "kind" "dateModified" "dateCreated" "size" "label" ]);
    default = null;
    description = "How Finder arranges desktop icons (\"grid\" is Snap to Grid).";
  };

  config = lib.mkIf (cfg.iconArrangement != null && pkgs.stdenv.hostPlatform.isDarwin) {
    home.activation.setDesktopIconArrangement = lib.hm.dag.entryAfter [ "setDarwinDefaults" ] ''
      plist="$HOME/Library/Preferences/com.apple.finder.plist"
      /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy ${cfg.iconArrangement}" "$plist" 2>/dev/null \
        || /usr/libexec/PlistBuddy -c "Add :DesktopViewSettings:IconViewSettings:arrangeBy string ${cfg.iconArrangement}" "$plist" 2>/dev/null \
        || true
      /usr/bin/killall cfprefsd Finder 2>/dev/null || true
    '';
  };
}
