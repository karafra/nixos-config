{ config, pkgs, lib, ... }:

{
  imports = [ ./../linux/default.nix ];

  networking.hostName = "wsl";
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    wslu
    git
    zsh
  ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
