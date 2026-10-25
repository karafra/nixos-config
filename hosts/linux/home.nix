{ config, pkgs, lib, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";

  imports = [
    ../../modules/shared/home-manager.nix
    ../../modules/shared/dev
    ../../modules/home-manager/default.nix
    ../../modules/aspects/features/shell/default.nix
  ];

  programs.home-manager.enable = true;

  programs.git.enable = true;

  programs.zsh = {
    enable = true;
    initContent = lib.mkAfter ''
      eval "$(zoxide init zsh)"
      eval "$(starship init zsh)"
    '';
  };

  home.packages = with pkgs; [
    alacritty
    brave
    chezmoi
    discord
    firefox
    gnomeExtensions.appindicator
    htop
    lf
    neovim
    obsidian
    spotify
    vscode
    wezterm
  ];
}
