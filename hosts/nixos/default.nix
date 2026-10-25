{ pkgs, lib, username, hostname, ... }:

# Baseline shared by every NixOS machine. Hardware and desktop settings belong
# in the machine's own module.
{
  imports = [
    ../../modules/shared/default.nix
    ../../modules/system/sops
  ];

  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  time.timeZone = lib.mkDefault "Europe/Prague";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = lib.mkDefault true;

  programs.zsh.enable = true;
  environment.systemPackages = with pkgs; [
    age
    curl
    git
    htop
    jq
    sops
    vim
  ];

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit username; };
    users.${username}.imports = [ ./home.nix ] ++ lib.optional (builtins.pathExists ./${username}) ./${username};
  };

  system.stateVersion = lib.mkDefault "24.11";
}
