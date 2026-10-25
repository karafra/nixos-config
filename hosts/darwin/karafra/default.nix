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

  programs.git = {
    enable = true;
    signing = {
      format = "ssh";
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
    settings = {
      user.name = "Karafra";
      user.email = "55988328+karafra@users.noreply.github.com";
      gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";
    };
  };

  home.activation.writeGitAllowedSigners = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/git"
    printf '%s %s\n' "you@example.com" "$(tr -d '\n' < ${config.sops.secrets."data/ssh_public_key".path})" > "$HOME/.config/git/allowed_signers"
    chmod 600 "$HOME/.config/git/allowed_signers"
  '';
}
