{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ansible
    google-cloud-sdk
    terraform
  ];
}
