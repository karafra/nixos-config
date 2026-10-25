{ config, lib, pkgs, ... }:

let
  d = config.xdg.dataHome;
  c = config.xdg.configHome;
  cache = config.xdg.cacheHome;
in
{
  home.sessionVariables = {
    LESSHISTFILE = cache + "/less/history";
    LESSKEY = c + "/less/lesskey";
    XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";
    DELTA_PAGER = "less -R";
    EDITOR = "nvim";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    STARSHIP_CACHE = "${config.xdg.cacheHome}/starship";
  };

  home.sessionPath = [
    "$HOME/bin"
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ./starship.toml);
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    autocd = false;
    dotDir = "${config.xdg.configHome}/zsh";
    history = {
      expireDuplicatesFirst = true;
      path = "${config.xdg.dataHome}/zsh_history";
      size = 100000;
      save = 100000;
      share = true;
    };
    historySubstringSearch = {
      enable = true;
    };
    sessionVariables = {
      ZSH_CACHE_DIR = "$HOME/.cache/zsh";
      # Empty values disable the default bold/magenta match highlight.
      HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND = "";
      HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND = "";
    };
    initContent = lib.mkMerge [
      (lib.mkOrder 500 ''
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
      '')
      ''
        _newline_between_prompts() { _newline_between_prompts() { print; }; }
        precmd_functions+=(_newline_between_prompts)

        if command -v , >/dev/null 2>&1; then
          command_not_found_handler() { , "$@"; }
        fi
      ''
    ];
    shellAliases = {
      grep = "grep --color=auto";
      ip = "ip --color=auto";
      ll = "ls -la";
      la = "ls -la";
      md = "mkdir -p";
      update = "sudo nixos-rebuild switch --flake ~/nixos";
    };
  };

  home.packages = with pkgs; [
    bat
    eza
    fd
    ripgrep
    zoxide
  ];
}
