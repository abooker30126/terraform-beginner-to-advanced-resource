#!/usr/bin/env bash
# setup-gpg.sh
# Configures the local GPG environment for signing commits and files in this
# repository.  Run this script once on your workstation before contributing.
#
# Prerequisites:
#   - gpg (GnuPG) installed
#   - git installed
#   - Your GPG private key available (exported as ASCII-armored text)
#
# Usage:
#   bash .github/scripts/setup-gpg.sh [--key-file <path-to-key.asc>]
#
# Without --key-file the script checks whether a suitable key already exists.

set -euo pipefail

log()  { echo "[setup-gpg] $*"; }
err()  { echo "[setup-gpg] ERROR: $*" >&2; exit 1; }

KEY_FILE=""

# Parse optional --key-file argument
while [[ $# -gt 0 ]]; do
  case "$1" in
    --key-file)
      KEY_FILE="$2"
      shift 2
      ;;
    *)
      err "Unknown argument: $1"
      ;;
  esac
done

# ---------------------------------------------------------------------------
# 1. Verify gpg is available
# ---------------------------------------------------------------------------
if ! command -v gpg &>/dev/null; then
  err "gpg not found. Install GnuPG (e.g. 'brew install gnupg' or 'apt install gnupg')."
fi

GPG_VERSION=$(gpg --version | head -1)
log "Using: $GPG_VERSION"

# ---------------------------------------------------------------------------
# 2. Import key if --key-file was supplied
# ---------------------------------------------------------------------------
if [[ -n "$KEY_FILE" ]]; then
  [[ -f "$KEY_FILE" ]] || err "Key file not found: $KEY_FILE"
  log "Importing key from $KEY_FILE …"
  gpg --import "$KEY_FILE"
fi

# ---------------------------------------------------------------------------
# 3. Identify the signing key
# ---------------------------------------------------------------------------
KEY_FP=$(gpg --list-secret-keys --with-colons 2>/dev/null \
           | awk -F: '/^fpr:/{print $10; exit}')

if [[ -z "$KEY_FP" ]]; then
  log ""
  log "No secret key found in your keyring."
  log "Generate a new 4096-bit RSA key with:"
  log "  gpg --full-generate-key"
  log "Then re-run this script."
  exit 1
fi

KEY_ID=$(gpg --list-secret-keys --with-colons 2>/dev/null \
           | awk -F: '/^sec:/{print $5; exit}')

log "Found secret key: ${KEY_ID}  (fingerprint: ${KEY_FP})"

# ---------------------------------------------------------------------------
# 4. Configure git to use this key for signing
# ---------------------------------------------------------------------------
# NOTE: The flags below modify your GLOBAL git configuration (~/.gitconfig).
# This affects all repositories on this machine.  If you prefer to limit
# signing to this repository only, replace '--global' with '--local' in each
# of the three commands below (the local repo must already be initialised).
git config --global user.signingkey "$KEY_FP"
git config --global commit.gpgsign true
git config --global gpg.program gpg
log "git global config updated to sign commits with key ${KEY_FP}"
log "(To limit signing to this repo only, re-run with 'git config --local' instead)"

# ---------------------------------------------------------------------------
# 5. Export the public key and print GitHub instructions
# ---------------------------------------------------------------------------
PUBLIC_KEY=$(gpg --armor --export "$KEY_FP")

log ""
log "=== Your GPG public key (add this to GitHub) ==="
echo "$PUBLIC_KEY"
log "==================================================="
log ""
log "Steps to add the key to GitHub:"
log "  1. Go to https://github.com/settings/keys"
log "  2. Click 'New GPG key'"
log "  3. Paste the public key above"
log "  4. Click 'Add GPG key'"
log ""
log "Steps to add the PRIVATE key as a GitHub Secret (for CI signing):"
log "  1. Export your private key:"
log "       gpg --armor --export-secret-keys $KEY_FP"
log "  2. Go to your repository → Settings → Secrets and variables → Actions"
log "  3. Create secret  GPG_PRIVATE_KEY  with the exported private key"
log "  4. Create secret  GPG_PASSPHRASE   with your key passphrase"
log ""
log "Setup complete."
