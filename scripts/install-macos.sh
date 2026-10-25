#!/bin/bash
set -euo pipefail

# FlakeHub flake (<owner>/<name>); FLAKE_VERSION may be a version or "*" for the latest release.
FLAKEHUB_FLAKE="${FLAKEHUB_FLAKE:-@FLAKEHUB_FLAKE@}"
FLAKE_VERSION="${FLAKE_VERSION:-*}"
DARWIN_HOST="${DARWIN_HOST:-darwin}"
SOPS_KEY_DIR="/var/lib/sops-nix"
SOPS_KEY_FILE="$SOPS_KEY_DIR/key.txt"
NIX_FLAGS=(--extra-experimental-features "nix-command flakes")

log() { printf '\033[1;33m==> %s\033[0m\n' "$*"; }
die() { printf '\033[1;31merror: %s\033[0m\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = "Darwin" ] || die "this script only supports macOS"
[ "$(id -u)" -ne 0 ] || die "run as your normal user, not root (sudo is requested when needed)"
case "$FLAKEHUB_FLAKE" in @*) die "FLAKEHUB_FLAKE is not set" ;; esac
FLAKE_URL="https://flakehub.com/f/${FLAKEHUB_FLAKE}/${FLAKE_VERSION}.tar.gz"

log "Requesting sudo"
sudo -v

if ! xcode-select -p >/dev/null 2>&1; then
    log "Installing Xcode Command Line Tools (finish the GUI prompt, then re-run this script)"
    xcode-select --install || true
    exit 1
fi

if ! command -v nix >/dev/null 2>&1 && [ ! -x /nix/var/nix/profiles/default/bin/nix ]; then
    log "Installing Nix"
    curl -fsSL https://nixos.org/nix/install | sh -s -- --daemon --yes
fi
# shellcheck disable=SC1091
[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] \
    && . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

if sudo test -f "$SOPS_KEY_FILE"; then
    log "Using existing sops age key"
else
    sudo mkdir -p "$SOPS_KEY_DIR"
    if [ -n "${AGE_KEY_FILE:-}" ]; then
        log "Installing age key from $AGE_KEY_FILE"
        sudo install -m 600 "$AGE_KEY_FILE" "$SOPS_KEY_FILE"
    else
        log "Generating a new sops age key"
        nix "${NIX_FLAGS[@]}" shell nixpkgs#age -c age-keygen -o /tmp/sops-key.txt
        sudo install -m 600 /tmp/sops-key.txt "$SOPS_KEY_FILE"
        rm -f /tmp/sops-key.txt
        printf '\033[1;31m'
        echo "A NEW age key was generated, so existing secrets cannot be decrypted by it."
        echo "Public key: $(sudo grep -o 'age1[a-z0-9]*' "$SOPS_KEY_FILE" | head -n1)"
        echo "Add it to .sops.yaml and run 'sops updatekeys secrets/secrets.yaml' from a checkout of the repo on a machine that has a working key."
        printf '\033[0m'
    fi
fi

# nix-darwin refuses to overwrite files it does not own.
for f in /etc/zshrc /etc/bashrc /etc/zprofile /etc/nix/nix.conf; do
    if [ -e "$f" ] && [ ! -L "$f" ] && ! grep -q "nix-darwin" "$f" 2>/dev/null; then
        log "Moving $f to $f.before-nix-darwin"
        sudo mv "$f" "$f.before-nix-darwin"
    fi
done

log "Applying ${FLAKE_URL}#${DARWIN_HOST}"
export NIXPKGS_ALLOW_UNFREE=1
if command -v darwin-rebuild >/dev/null 2>&1; then
    sudo -H darwin-rebuild switch --refresh --flake "${FLAKE_URL}#${DARWIN_HOST}"
else
    sudo -H env "PATH=$PATH" nix "${NIX_FLAGS[@]}" run nix-darwin -- switch --refresh --flake "${FLAKE_URL}#${DARWIN_HOST}"
fi

log "Done. Open a new terminal to pick up the new shell configuration."
