{ ... }:

{
  programs.k9s = {
    enable = true;
    skins.transparent = ./transparent.yaml;
    settings.k9s.ui.skin = "transparent";
  };
}
