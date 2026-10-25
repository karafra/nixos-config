{ config, pkgs, lib, ... }:

{
  home.username = "matustoth";
  home.homeDirectory = "/Users/matustoth";
  home.stateVersion = "24.11";

  imports = [
    ../../modules/shared/home-manager.nix
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

  programs.git = {
    enable = true;
    signing = {
      format = "ssh";
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
    settings = {
      user.name = "karafra";
      user.email = "you@example.com";
      gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";
    };
  };

  home.activation.writeGitAllowedSigners = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/git"
    printf '%s %s\n' "you@example.com" "$(tr -d '\n' < ${config.sops.secrets."data/ssh_public_key".path})" > "$HOME/.config/git/allowed_signers"
    chmod 600 "$HOME/.config/git/allowed_signers"
  '';

  programs.zsh.shellAliases.update = lib.mkForce "nix run .#build-switch";
}
