#!/usr/bin/env bash
# sign-files.sh
# Signs a list of files with GPG and stores detached signatures (.gpg.sig).
# Usage: sign-files.sh "<newline-separated list of files>"
# Environment variables required:
#   GPG_KEY_ID      - Key ID to use for signing (set by the workflow)
#   GPG_PASSPHRASE  - Passphrase for the GPG key

set -euo pipefail

FILES="$1"

if [ -z "$FILES" ]; then
  echo "No files provided. Exiting."
  exit 0
fi

GPG_IGNORE_FILE=".gpg-ignore"

is_ignored() {
  local file="$1"
  if [ ! -f "$GPG_IGNORE_FILE" ]; then
    return 1
  fi
  while IFS= read -r pattern || [ -n "$pattern" ]; do
    # Skip blank lines and comments
    [[ -z "$pattern" || "$pattern" == \#* ]] && continue
    if [[ "$file" == $pattern ]]; then
      return 0
    fi
  done < "$GPG_IGNORE_FILE"
  return 1
}

SIGNED=0
SKIPPED=0
FAILED=0

while IFS= read -r file; do
  [ -z "$file" ] && continue

  if [ ! -f "$file" ]; then
    echo "⚠️  File not found, skipping: $file"
    (( SKIPPED++ )) || true
    continue
  fi

  if is_ignored "$file"; then
    echo "⏭️  Ignored by .gpg-ignore: $file"
    (( SKIPPED++ )) || true
    continue
  fi

  SIG_FILE="${file}.gpg.sig"

  echo "🔏 Signing: $file"
  if echo "$GPG_PASSPHRASE" | gpg \
      --batch \
      --yes \
      --pinentry-mode loopback \
      --passphrase-fd 0 \
      --detach-sign \
      --armor \
      --output "$SIG_FILE" \
      "$file"; then
    echo "✅ Signature written: $SIG_FILE"

    # Verify the freshly created signature
    if gpg --verify "$SIG_FILE" "$file" 2>/dev/null; then
      echo "✔️  Verification passed: $SIG_FILE"
      (( SIGNED++ )) || true
    else
      echo "❌ Verification failed for: $file"
      (( FAILED++ )) || true
    fi
  else
    echo "❌ Signing failed for: $file"
    (( FAILED++ )) || true
  fi
done <<< "$FILES"

echo ""
echo "──────────────────────────────"
echo "Signing summary:"
echo "  Signed:  $SIGNED"
echo "  Skipped: $SKIPPED"
echo "  Failed:  $FAILED"
echo "──────────────────────────────"

if [ "$FAILED" -gt 0 ]; then
  echo "One or more files could not be signed. Exiting with error."
  exit 1
fi
