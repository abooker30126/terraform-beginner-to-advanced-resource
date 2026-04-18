#!/usr/bin/env bash
# sign-files.sh
# Usage: sign-files.sh "<newline-separated list of files>"
#
# Signs each file with GPG and stores the detached signature alongside
# the original file as <file>.gpg.sig.  Skips files listed in .gpg-ignore.
# Requires GPG_PASSPHRASE to be set in the environment.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
GPG_IGNORE="${REPO_ROOT}/.gpg-ignore"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

log()  { echo "[sign-files] $*"; }
err()  { echo "[sign-files] ERROR: $*" >&2; exit 1; }

# Build an array of exclusion patterns from .gpg-ignore (if it exists)
declare -a IGNORE_PATTERNS=()
if [[ -f "$GPG_IGNORE" ]]; then
  while IFS= read -r line; do
    # Strip inline comments, then trim leading/trailing whitespace
    line="${line%%#*}"
    line="$(echo "$line" | xargs)"
    [[ -z "$line" ]] && continue
    IGNORE_PATTERNS+=("$line")
  done < "$GPG_IGNORE"
fi

is_ignored() {
  local file="$1"
  for pattern in "${IGNORE_PATTERNS[@]+"${IGNORE_PATTERNS[@]}"}"; do
    # shellcheck disable=SC2254
    case "$file" in
      $pattern) return 0 ;;
    esac
  done
  return 1
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

MODIFIED_FILES="$1"

if [[ -z "$MODIFIED_FILES" ]]; then
  log "No files provided – nothing to sign."
  exit 0
fi

# Resolve the signing key fingerprint from the imported secret key
KEY_FP=$(gpg --list-secret-keys --with-colons 2>/dev/null \
           | awk -F: '/^fpr:/{print $10; exit}')
if [[ -z "$KEY_FP" ]]; then
  err "No GPG secret key found. Make sure GPG_PRIVATE_KEY has been imported."
fi
log "Using key fingerprint: ${KEY_FP}"

SIGNED=0
SKIPPED=0

cd "$REPO_ROOT"

while IFS= read -r file; do
  [[ -z "$file" ]] && continue

  if [[ ! -f "$file" ]]; then
    log "SKIP  $file  (file does not exist)"
    (( SKIPPED++ )) || true
    continue
  fi

  if is_ignored "$file"; then
    log "SKIP  $file  (matches .gpg-ignore pattern)"
    (( SKIPPED++ )) || true
    continue
  fi

  sig_file="${file}.gpg.sig"

  log "SIGN  $file -> ${sig_file}"
  gpg --batch --yes \
    --pinentry-mode loopback \
    --passphrase-fd 3 \
    --local-user "$KEY_FP" \
    --detach-sign \
    --armor \
    --output "$sig_file" \
    "$file" \
    3<<< "${GPG_PASSPHRASE}"

  # Verify the signature immediately after creation
  if gpg --verify "$sig_file" "$file" 2>/dev/null; then
    log "OK    Signature verified for $file"
  else
    err "Signature verification FAILED for $file"
  fi

  (( SIGNED++ )) || true
done <<< "$MODIFIED_FILES"

log "Done. Signed: ${SIGNED}  Skipped: ${SKIPPED}"
