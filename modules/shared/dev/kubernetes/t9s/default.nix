{ pkgs, lib, ... }:

let
  version = "0.2.0";
  platforms = {
    aarch64-darwin = { name = "darwin_arm64"; sha256 = "c5569a1b3a113e632137188cfb02027d271842d2c939e641d22f2259814d2517"; };
    x86_64-darwin = { name = "darwin_amd64"; sha256 = "e14ad826fcb965e5c632a6f32eb93c0cab680dd055075e6ab12582ba873a4b27"; };
    x86_64-linux = { name = "linux_amd64"; sha256 = "544d2deac104ebf2ec0fb2a77e24744601f47e62ca9d71d7bf4cbca253594d5b"; };
    aarch64-linux = { name = "linux_arm64"; sha256 = "45852b34c6b00c4dfdd1a1b9cb8a2f98ef3222f026b8e92f98e3fd628a3b38ff"; };
  };
  platform = platforms.${pkgs.stdenv.hostPlatform.system};

  t9s = pkgs.stdenvNoCC.mkDerivation {
    pname = "t9s";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/florianspk/t9s/releases/download/v${version}/t9s_${version}_${platform.name}.tar.gz";
      inherit (platform) sha256;
    };

    sourceRoot = ".";
    installPhase = ''
      install -Dm755 t9s $out/bin/t9s
    '';

    meta = {
      description = "k9s-inspired TUI for managing Talos Linux clusters via talosctl";
      homepage = "https://github.com/florianspk/t9s";
      license = lib.licenses.unfree;
      mainProgram = "t9s";
      platforms = builtins.attrNames platforms;
    };
  };
in
{
  home.packages = [ t9s ];
}
