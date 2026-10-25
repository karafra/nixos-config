{ pkgs, username, ... }:

{
  system.primaryUser = username;
  system.stateVersion = 5;

  users.users.${username}.home = "/Users/${username}";

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" username ];
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    age
    git
    jq
    sops
  ];

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.secrets."data/git_email" = { };
  sops.secrets."data/ssh_public_key" = { };
}
