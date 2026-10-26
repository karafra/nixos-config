{ config, lib, nvim-config, pkgs, ... }:

let
  cfg = config.local.neovim;

  delanceShim = pkgs.writeShellScriptBin "delance-langserver" ''
    exec ${pkgs.basedpyright}/bin/basedpyright-langserver "$@"
  '';

  erlangLsShim = pkgs.writeShellScriptBin "erlang_ls" ''
    exec ${pkgs.erlang-language-platform}/bin/elp server
  '';

  python = pkgs.python3.withPackages (ps: [ ps.pynvim ]);

  nvim = pkgs.symlinkJoin {
    name = "neovim-with-tools";
    paths = [ pkgs.neovim ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nvim --prefix PATH : ${lib.makeBinPath cfg.extraPackages}
    '';
  };
in
{
  options.local.neovim = {
    enable = lib.mkEnableOption "Neovim using karafra/nvim-config";

    source = lib.mkOption {
      type = lib.types.path;
      default = nvim-config;
      description = "Neovim configuration to install as ~/.config/nvim.";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        git
        ripgrep
        fd
        tree-sitter
        nodejs
        gopls
        golangci-lint
        golangci-lint-langserver
        lua-language-server
        ruff
        black
        stylua
        bash-language-server
        yaml-language-server
        vim-language-server
        typos-lsp
        basedpyright
        delanceShim
        nixd
        rust-analyzer
        erlang-language-platform
        erlangLsShim
      ];
      description = "Tools made available on PATH to Neovim only (language servers, formatters, search).";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ (lib.hiPrio nvim) ];
    xdg.configFile."nvim" = {
      source = lib.cleanSourceWith {
        src = cfg.source;
        filter = path: _type: baseNameOf path != "lazy-lock.json";
      };
      recursive = true;
    };
    xdg.configFile."nvim/.venv/bin/python3".source = "${python}/bin/python3";
  };
}
