{ config, pkgs, lib, username, hostname, ... }:

let
  host = import ../../lib/hostname.nix { };
  locale = import ../../lib/locale.nix { };
in

{
  imports = [
    ../../modules/system/touchid
    ../../modules/system/darwin-upgrade
    ../../modules/system/sops-key
    ../../modules/system/warp
  ];

  local.sopsKey.enable = true;
  local.warp = {
    enable = false;
    team = "karafra-net";
  };
  networking = host.networking hostname;

  system.primaryUser = username;
  system.stateVersion = 5;

  users.users.${username} = {
    home = "/Users/${username}";
    uid = 501;
  };

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" username ];
  };

  programs.zsh.enable = true;

  local.darwinUpgrade = {
    enable = true;
    user = username;
    flake = "github:karafra/nixos-config/main#darwin";
  };

  system.defaults.CustomUserPreferences = locale.preferences {
    languages = [ "en-SK" ];
    layout = { id = 252; name = "ABC"; };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit username; };
    users.${username} = {
      imports = [ ./home.nix ] ++ lib.optional (builtins.pathExists ./${username}) ./${username};
      local.slack.enable = true;
      targets.darwin.copyApps.enable = true;
      targets.darwin.linkApps.enable = false;
    };
  };

  environment.systemPackages = with pkgs; [
    age
    git
    jq
    jsonnet-bundler
    jsonnet
    yq
    comma
    helm-docs
    sops
    jetbrains.rust-rover
    vscode
  ];

  fonts.packages = [ pkgs.nerd-fonts.fira-code ];

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.secrets."data/git_email" = { };
  sops.secrets."data/ssh_public_key" = { };
}
