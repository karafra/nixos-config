{ config, lib, pkgs, ... }:

let
  cfg = config.local.mail;
in
{
  options.local.mail = {
    enable = lib.mkEnableOption "Gmail sync via mbsync and msmtp";
    address = lib.mkOption {
      type = lib.types.str;
      description = "Gmail address.";
    };
    realName = lib.mkOption {
      type = lib.types.str;
      description = "Name used in outgoing mail.";
    };
    passwordSecret = lib.mkOption {
      type = lib.types.str;
      default = "data/gmail_app_password";
      description = "sops secret holding the Gmail app password.";
    };
    appleMail.enable = lib.mkEnableOption "generating an Apple Mail configuration profile for the account (macOS)";
    syncInterval = lib.mkOption {
      type = lib.types.int;
      default = 300;
      description = "Seconds between mbsync runs.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.${cfg.passwordSecret} = { };

    accounts.email.accounts.gmail = {
      primary = true;
      flavor = "gmail.com";
      inherit (cfg) address realName;
      passwordCommand = "cat ${config.sops.secrets.${cfg.passwordSecret}.path}";
      mbsync = {
        enable = true;
        create = "maildir";
      };
      msmtp.enable = true;
    };

    programs.mbsync.enable = true;
    programs.msmtp.enable = true;

    launchd.agents.mbsync = {
      enable = true;
      config = {
        ProgramArguments = [ "${pkgs.isync}/bin/mbsync" "-a" ];
        StartInterval = cfg.syncInterval;
        RunAtLoad = true;
      };
    };

    # The password is injected at activation time so it never lands in the world-readable Nix store.
    home.activation.generateAppleMailProfile = lib.mkIf (cfg.appleMail.enable && pkgs.stdenv.hostPlatform.isDarwin) (
      lib.hm.dag.entryAfter [ "sops-nix" ] ''
        secret="${config.sops.secrets.${cfg.passwordSecret}.path}"
        out="${config.xdg.configHome}/mail/gmail.mobileconfig"
        if [ -r "$secret" ]; then
          mkdir -p "$(dirname "$out")"
          pw="$(tr -d '\n' < "$secret" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')"
          umask 077
          cat > "$out" <<EOF
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>PayloadType</key><string>Configuration</string>
          <key>PayloadVersion</key><integer>1</integer>
          <key>PayloadIdentifier</key><string>local.nixos-config.mail.gmail</string>
          <key>PayloadUUID</key><string>6F1B6C0E-2D5A-4C57-9C1E-4B7A1B6F0A11</string>
          <key>PayloadDisplayName</key><string>Gmail (${cfg.address})</string>
          <key>PayloadContent</key>
          <array>
            <dict>
              <key>PayloadType</key><string>com.apple.mail.managed</string>
              <key>PayloadVersion</key><integer>1</integer>
              <key>PayloadIdentifier</key><string>local.nixos-config.mail.gmail.account</string>
              <key>PayloadUUID</key><string>0A3C5E7F-9B1D-4F2A-8C6E-1D3B5A7C9E22</string>
              <key>PayloadDisplayName</key><string>Gmail</string>
              <key>EmailAccountType</key><string>EmailTypeIMAP</string>
              <key>EmailAccountDescription</key><string>Gmail</string>
              <key>EmailAccountName</key><string>${cfg.realName}</string>
              <key>EmailAddress</key><string>${cfg.address}</string>
              <key>IncomingMailServerAuthentication</key><string>EmailAuthPassword</string>
              <key>IncomingMailServerHostName</key><string>imap.gmail.com</string>
              <key>IncomingMailServerPortNumber</key><integer>993</integer>
              <key>IncomingMailServerUseSSL</key><true/>
              <key>IncomingMailServerUsername</key><string>${cfg.address}</string>
              <key>IncomingPassword</key><string>$pw</string>
              <key>OutgoingMailServerAuthentication</key><string>EmailAuthPassword</string>
              <key>OutgoingMailServerHostName</key><string>smtp.gmail.com</string>
              <key>OutgoingMailServerPortNumber</key><integer>587</integer>
              <key>OutgoingMailServerUseSSL</key><true/>
              <key>OutgoingMailServerUsername</key><string>${cfg.address}</string>
              <key>OutgoingPasswordSameAsIncomingPassword</key><true/>
            </dict>
          </array>
        </dict>
        </plist>
        EOF
          /usr/bin/plutil -lint "$out" >/dev/null || rm -f "$out"

          # Installing a profile always needs the user's approval; opening it raises that prompt.
          if [ -f "$out" ]; then
            stamp="${config.xdg.stateHome}/mail-profile.sha256"
            current="$(/usr/bin/shasum -a 256 "$out" | cut -d' ' -f1)"
            if ! /usr/bin/profiles list 2>/dev/null | grep -q "local.nixos-config.mail.gmail" \
              || [ "$(cat "$stamp" 2>/dev/null)" != "$current" ]; then
              mkdir -p "$(dirname "$stamp")"
              printf '%s' "$current" > "$stamp"
              echo "Opening the Apple Mail profile: approve it in System Settings > General > Device Management."
              /usr/bin/open "$out" || true
            fi
          fi
        fi
      ''
    );
  };
}
