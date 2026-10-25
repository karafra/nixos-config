{ config, lib, pkgs, ... }:

let
  cfg = config.local.terminal;
in
{
  options.local.terminal = {
    font = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.nerd-fonts.fira-code;
        description = "Nerd font package (from the nerd-fonts overlay) to install.";
      };

      family = lib.mkOption {
        type = lib.types.str;
        default = "FiraCode Nerd Font Mono";
        description = "Font family used by WezTerm.";
      };

      postscriptName = lib.mkOption {
        type = lib.types.str;
        default = "FiraCodeNFM-Light";
        description = "PostScript name used by macOS Terminal.app.";
      };

      weight = lib.mkOption {
        type = lib.types.str;
        default = "Light";
        description = "Font weight used by WezTerm.";
      };

      size = lib.mkOption {
        type = lib.types.int;
        default = 12;
        description = "Font size in points.";
      };
    };
  };

  config = {
    home.packages = [ cfg.font.package ];

    programs.wezterm = {
      enable = true;
      extraConfig = ''
        return {
          font = wezterm.font("${cfg.font.family}", { weight = "${cfg.font.weight}" }),
          font_size = ${toString cfg.font.size}.0,
        }
      '';
    };

    home.activation.setTerminalFont = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
      lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        /usr/bin/osascript -e 'tell application "Terminal"
          set font name of settings set (name of default settings) to "${cfg.font.postscriptName}"
          set font size of settings set (name of default settings) to ${toString cfg.font.size}
        end tell' || true
      ''
    );
  };
}
