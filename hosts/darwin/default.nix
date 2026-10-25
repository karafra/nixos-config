{ pkgs, lib, username, hostname, ... }:

let
  host = import ../../lib/hostname.nix { };
  locale = import ../../lib/locale.nix { };
in

{
  networking = host.networking hostname;

  system.primaryUser = username;
  system.stateVersion = 5;

  users.users.${username}.home = "/Users/${username}";

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" username ];
  };

  programs.zsh.enable = true;

  system.defaults.CustomUserPreferences = locale.preferences {
    languages = [ "en-SK" ];
    layout = { id = 252; name = "ABC"; };
  };

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

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.secrets."data/git_email" = { };
  sops.secrets."data/ssh_public_key" = { };
}
