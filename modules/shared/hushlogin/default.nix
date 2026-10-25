{ config, lib, ... }:

{
  options.local.hushlogin.enable = lib.mkEnableOption "an empty ~/.hushlogin to suppress the login banner";

  config = lib.mkIf config.local.hushlogin.enable {
    home.file.".hushlogin".text = "";
  };
}
