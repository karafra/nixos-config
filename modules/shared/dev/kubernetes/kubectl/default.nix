{ pkgs, ... }:

{
  home.packages = [ pkgs.kubectl ];
  home.file.".kube/kuberc".source = ./kuberc.yaml;
}
