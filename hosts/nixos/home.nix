{ lib, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";

  imports = [
    ../../modules/shared/home-manager.nix
    ../../modules/aspects/features/shell/default.nix
  ];

  programs.home-manager.enable = true;
  programs.git.enable = true;
  programs.zsh.enable = true;

  programs.zsh.shellAliases.update = lib.mkForce "nix run .#build-switch";
}
