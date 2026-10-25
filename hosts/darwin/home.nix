{ config, pkgs, lib, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.11";

  imports = [
    ../../modules/shared/home-manager.nix
    ../../modules/shared/dev
    ../../modules/aspects/features/shell/default.nix
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
  };

  sops.secrets."data/git_email" = {
    sopsFile = ../../secrets/secrets.yaml;
  };

  sops.secrets."data/ssh_public_key" = {
    sopsFile = ../../secrets/secrets.yaml;
  };

  programs.home-manager.enable = true;

  home.sessionPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];

  programs.git.enable = true;

  programs.zsh.shellAliases.update = lib.mkForce "nix run .#build-switch";
}
