{ pkgs, ... }:

{
  home.packages = with pkgs; [
    go
    nodejs
    pipx
    python3
    rustup
  ];
}
