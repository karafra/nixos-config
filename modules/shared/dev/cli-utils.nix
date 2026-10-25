{ pkgs, ... }:

{
  home.packages = with pkgs; [
    charm-freeze
    gh
    jq
    netcat
    ttyd
    vhs
    watch
    yq-go
  ];
}
