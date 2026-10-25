{ pkgs, lib, username, ... }:

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

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit username; };
    users.${username}.imports = [ ./home.nix ] ++ lib.optional (builtins.pathExists ./${username}) ./${username};
  };

  environment.systemPackages = with pkgs; [
    age
    git
    jq
    sops
    vscode
  ];

  fonts.packages = [ pkgs.nerd-fonts.fira-code ];

  homebrew = {
    enable = true;
    casks = [
      "macs-fan-control"
      "t9s"
    ];
  };

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.secrets."data/git_email" = { };
  sops.secrets."data/ssh_public_key" = { };
}
