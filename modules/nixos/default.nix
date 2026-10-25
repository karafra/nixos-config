{ config, pkgs, ... }:

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

  system.stateVersion = "24.11";
}
