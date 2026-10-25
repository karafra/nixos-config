{ pkgs, ... }:

{
  programs.bat.enable = true;
  programs.fzf.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    htop
    lf
    neovim
    wezterm
  ];
}
