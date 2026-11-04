{ config, lib, pkgs, ... }:

let
  cfg = config.local.dock;
  cacheDir = "$HOME/.cache/home-manager";
  defaultsHash = builtins.hashString "sha256" (builtins.toJSON config.targets.darwin.defaults."com.apple.dock");
in
{
  options.local.dock.enable = lib.mkEnableOption "Dock management, restarting the Dock only when its preferences changed during activation";

  config = lib.mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isDarwin) {
    home.activation.restartDock = lib.hm.dag.entryAfter [ "setDarwinDefaults" ] ''
      hashFile="${cacheDir}/dock-defaults.sha256"
      expectedHash=${lib.escapeShellArg defaultsHash}
      previousHash=""
      if [ -f "$hashFile" ]; then
        previousHash=$(/bin/cat "$hashFile")
      fi

      if [ "$previousHash" != "$expectedHash" ]; then
        /bin/mkdir -p "${cacheDir}"
        /usr/bin/killall Dock || true
        printf '%s\n' "$expectedHash" > "$hashFile"
      fi
    '';
  };
}
