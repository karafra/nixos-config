{ config, lib, pkgs, ... }:

let
  cfg = config.local.gitSigning;
  pub = "${cfg.keyFile}.pub";
in
{
  options.local.gitSigning = {
    enable = lib.mkEnableOption "SSH commit signing, including key creation and GitHub registration";

    keyFile = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.ssh/id_ed25519";
      description = "Private SSH key used for signing; the key is generated if missing.";
    };

    registerWithGitHub = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Upload the public key to GitHub as a signing key using the authenticated gh CLI.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      signing = {
        format = "ssh";
        key = pub;
        signByDefault = true;
      };
      settings.gpg.ssh.allowedSignersFile = "${config.xdg.configHome}/git/allowed_signers";
    };

    home.activation.setupGitSigning = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="${lib.makeBinPath [ pkgs.openssh pkgs.gh pkgs.coreutils ]}:$PATH"
      key="${cfg.keyFile}"

      if [ ! -e "$key" ]; then
        mkdir -p "$(dirname "$key")" && chmod 700 "$(dirname "$key")"
        ssh-keygen -q -t ed25519 -N "" -C "${config.programs.git.settings.user.email}" -f "$key"
      fi

      mkdir -p "${config.xdg.configHome}/git"
      printf '%s %s\n' "${config.programs.git.settings.user.email}" "$(tr -d '\n' < "${pub}")" \
        > "${config.xdg.configHome}/git/allowed_signers"

      ${lib.optionalString cfg.registerWithGitHub ''
        blob="$(cut -d' ' -f2 "${pub}")"
        if existing="$(gh api user/ssh_signing_keys --jq '.[].key' 2>/dev/null)"; then
          if ! printf '%s' "$existing" | grep -qF "$blob"; then
            gh ssh-key add "${pub}" --type signing --title "$(hostname -s) signing" \
              || echo "Could not register the signing key with GitHub."
          fi
        else
          echo "GitHub signing key not registered: run 'gh auth refresh -h github.com -s admin:ssh_signing_key' once, then switch again."
        fi
      ''}
    '';
  };
}
