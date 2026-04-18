#!/usr/bin/env bash
# setup-gpg.sh
# Configures a local GPG environment for signing files and git commits.
# Run this script once on your local machine before signing files or opening PRs.

set -euo pipefail

echo "=== GPG Local Setup Script ==="
echo ""

# ── 1. Check prerequisites ────────────────────────────────────────────────────
for cmd in gpg git; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "❌ '$cmd' is not installed. Please install it and re-run this script."
    exit 1
  fi
done
echo "✅ Prerequisites satisfied (gpg, git)"

# ── 2. List existing secret keys ─────────────────────────────────────────────
echo ""
echo "=== Existing GPG secret keys ==="
gpg --list-secret-keys --keyid-format=long || true

# ── 3. Optionally import a key from file ─────────────────────────────────────
echo ""
read -rp "Do you want to import a GPG private key from a file? [y/N] " IMPORT_KEY
if [[ "$IMPORT_KEY" =~ ^[Yy]$ ]]; then
  read -rp "Path to the key file: " KEY_FILE
  if [ ! -f "$KEY_FILE" ]; then
    echo "❌ File not found: $KEY_FILE"
    exit 1
  fi
  gpg --import "$KEY_FILE"
  echo "✅ Key imported."
fi

# ── 4. Choose a key for signing ───────────────────────────────────────────────
echo ""
echo "=== Available secret keys ==="
gpg --list-secret-keys --keyid-format=long

echo ""
read -rp "Enter the GPG key ID (long format, e.g. B732B308C0FE0BB3) to use for signing: " GPG_KEY_ID

if [ -z "$GPG_KEY_ID" ]; then
  echo "❌ No key ID provided. Exiting."
  exit 1
fi

# ── 5. Configure git to use this key ─────────────────────────────────────────
git config --global user.signingkey "$GPG_KEY_ID"
git config --global commit.gpgsign true
git config --global tag.gpgsign true
echo "✅ git configured to sign commits and tags with key: $GPG_KEY_ID"

# ── 6. Export the public key (for uploading to GitHub) ───────────────────────
echo ""
echo "=== Your GPG public key (add this to GitHub → Settings → SSH and GPG keys) ==="
echo ""
gpg --armor --export "$GPG_KEY_ID"

# ── 7. Export the private key (for the GPG_PRIVATE_KEY GitHub Secret) ────────
echo ""
read -rp "Do you want to export the private key for use as a GitHub Secret? [y/N] " EXPORT_PRIVATE
if [[ "$EXPORT_PRIVATE" =~ ^[Yy]$ ]]; then
  echo ""
  echo "=== GPG private key (store this in the GPG_PRIVATE_KEY GitHub Secret) ==="
  echo "⚠️  Keep this value secret – do NOT commit it to source control."
  echo ""
  gpg --armor --export-secret-keys "$GPG_KEY_ID"
fi

echo ""
echo "=== Setup complete ==="
echo "Next steps:"
echo "  1. Add your PUBLIC key to GitHub: https://github.com/settings/keys"
echo "  2. Add GPG_PRIVATE_KEY and GPG_PASSPHRASE to your repository secrets:"
echo "     https://github.com/<owner>/<repo>/settings/secrets/actions"
echo "  3. Open a PR with .sh/.py/.yml/.tf changes to trigger automatic signing."
