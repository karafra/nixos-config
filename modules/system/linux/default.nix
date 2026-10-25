{ config, pkgs, lib, ... }:

{
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ bash zsh ];

  environment.systemPackages = with pkgs; [
    age
    bat
    curl
    fd
    git
    htop
    jq
    ripgrep
    sops
    tmux
    unzip
    wget
    yq
    zoxide
  ];

  security.sudo.wheelNeedsPassword = false;
  services.openssh.enable = true;
  networking.networkmanager.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    trusted-users = [ "root" "@wheel" ];
  };
}
