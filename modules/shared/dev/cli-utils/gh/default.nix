{ config, lib, pkgs, ... }:

let
  cfg = config.local.gh;
in
{
  options.local.gh.user = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "GitHub user name for github.com.";
  };

  config.programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      prompt = "enabled";
      prefer_editor_prompt = "disabled";
      aliases.co = "pr checkout";
    };
    hosts."github.com" = {
      git_protocol = "ssh";
    }
    // lib.optionalAttrs (cfg.user != null) { inherit (cfg) user; };
  };

  # Not packaged in nixpkgs, so install it imperatively; failures (offline, unauthenticated) are non-fatal.
  config.home.activation.installGhExtensions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${lib.makeBinPath [ pkgs.gh pkgs.git ]}:$PATH"
    if ! gh extension list 2>/dev/null | grep -q 'github/gh-actions-lock'; then
      run gh extension install github/gh-actions-lock || echo "warning: could not install gh-actions-lock" >&2
    fi
  '';
}
