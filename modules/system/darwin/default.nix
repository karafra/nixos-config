{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    jq
    zsh
  ];

  programs.zsh.enable = true;
  system.stateVersion = 5;
}
