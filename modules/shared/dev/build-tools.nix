{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bazelisk
    cmake
    mise
  ];
}
