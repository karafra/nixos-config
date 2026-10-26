{ config, lib, ... }:

let
  dock = import ../../../lib/dock.nix { inherit lib; };
in
{
  targets.darwin.defaults."com.apple.dock" = {
    orientation = "bottom";
    tilesize = 50;
    show-recents = false;
    persistent-apps = map dock.app [
      "/System/Applications/Apps.app"
      "/System/Applications/App Store.app"
      "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"
      "/System/Applications/Messages.app"
      "/System/Applications/Mail.app"
      "/System/Applications/Maps.app"
      "/System/Applications/Photos.app"
      "/System/Applications/Calendar.app"
      "/System/Applications/Contacts.app"
      "/System/Applications/Reminders.app"
      "/System/Applications/TV.app"
    ];
  };

  home.activation.restartDock = lib.hm.dag.entryAfter [ "setDarwinDefaults" ] ''
    /usr/bin/killall Dock || true
  '';

  local.wallpaper.image = ./wallpaper.jpg;
  local.desktop.iconArrangement = "grid";
  local.hushlogin.enable = true;
  local.vscode.enable = true;

  local.neovim.enable = true;

  local.gitSigning.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = "Karafra";
      user.email = "55988328+karafra@users.noreply.github.com";
    };
  };
}
