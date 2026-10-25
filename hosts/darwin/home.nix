{ config, pkgs, lib, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.11";

  imports = [
    ../../modules/shared/home-manager.nix
    ../../modules/shared/dev
    ../../modules/shared/accounts
    ../../modules/aspects/features/shell/default.nix
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
  };

  sops.secrets."data/git_email" = {
    sopsFile = ../../secrets/secrets.yaml;
  };

  sops.secrets."data/ssh_public_key" = {
    sopsFile = ../../secrets/secrets.yaml;
  };

  programs.home-manager.enable = true;

  # Enable mail, calendar and the GitHub token once their keys exist in secrets/secrets.yaml.
  local.mail = {
    enable = false;
    address = "mtoth575@gmail.com";
    realName = "Matus Toth";
  };

  local.calendar.enable = false;

  local.gh.user = "karafra";
  # local.gh.tokenSecret = "data/github_token";

  home.sessionPath = [ "$HOME/.local/bin" "$HOME/go/bin" ];

  programs.git.enable = true;

  programs.zsh = {
    shellAliases.update = lib.mkForce "nix run .#build-switch";

    # Keep the existing history file rather than starting a new one under XDG.
    history = {
      path = lib.mkForce "${config.home.homeDirectory}/.zsh_history";
      ignoreAllDups = true;
      ignoreSpace = true;
    };

    historySubstringSearch = {
      searchUpKey = [ "^[[A" ];
      searchDownKey = [ "^[[B" ];
    };

    setOptions = [
      "INC_APPEND_HISTORY_TIME"
      "APPEND_HISTORY"
      "HIST_REDUCE_BLANKS"
      "HIST_VERIFY"
    ];

    profileExtra = ''
      [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
    '';
  };

}
