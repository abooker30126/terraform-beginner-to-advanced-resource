# Security Keys & GPG Signing

This document explains how cryptographic GPG signatures are used in this repository, how to verify them, and how to configure your local environment or CI pipeline.

---

## Table of Contents

1. [Overview](#overview)
2. [How It Works](#how-it-works)
3. [Setting Up GPG Locally](#setting-up-gpg-locally)
4. [Verifying Signatures](#verifying-signatures)
5. [GitHub Secrets Configuration](#github-secrets-configuration)
6. [Exporting Your GPG Key for CI](#exporting-your-gpg-key-for-ci)
7. [Troubleshooting](#troubleshooting)

---

## Overview

Every pull request that modifies a `.sh`, `.py`, `.yml`, or `.tf` file triggers the **GPG Sign Modified Files** workflow.  The workflow:

1. Identifies the files changed in the PR.
2. Signs each file with a detached ASCII-armored GPG signature.
3. Commits the resulting `<file>.gpg.sig` signature files back to the PR branch.
4. Posts a summary comment on the PR listing the signed files.

---

## How It Works

```
PR opened / updated
        │
        ▼
  Identify changed files
  (.sh | .py | .yml | .tf)
        │
        ▼
  Import GPG_PRIVATE_KEY secret
        │
        ▼
  For each file:
    gpg --detach-sign --armor → <file>.gpg.sig
    gpg --verify <file>.gpg.sig <file>
        │
        ▼
  git commit & push signatures
        │
        ▼
  Post PR comment with report
```

Signature files live **alongside** the source file and use the `.gpg.sig` extension, e.g. `scripts/deploy.sh.gpg.sig`.

---

## Setting Up GPG Locally

Run the provided helper script once on your workstation:

```bash
# Using an existing key in your keyring
bash .github/scripts/setup-gpg.sh

# Importing a key from a file first
bash .github/scripts/setup-gpg.sh --key-file /path/to/my-key.asc
```

The script will:
- Confirm GnuPG is installed.
- Import the key (if `--key-file` is supplied).
- Configure `git` to sign commits automatically.
- Print your public key and step-by-step instructions for GitHub.

### Generate a new key (if needed)

```bash
gpg --full-generate-key
# Choose: RSA and RSA, 4096 bits, no expiry (or set one), enter name/email
```

---

## Verifying Signatures

### Verify a single file

```bash
# Import the repository's signing public key first (one-time step)
gpg --import <public-key.asc>

# Then verify
gpg --verify path/to/file.sh.gpg.sig path/to/file.sh
```

A successful verification outputs:

```
gpg: Signature made ...
gpg: Good signature from "Anthony Booker <...>"
```

### Verify all signature files in the repo

```bash
find . -name '*.gpg.sig' | while read sig; do
  original="${sig%.gpg.sig}"
  if gpg --verify "$sig" "$original" 2>/dev/null; then
    echo "OK: $original"
  else
    echo "FAIL: $original"
  fi
done
```

---

## GitHub Secrets Configuration

The workflow requires two repository secrets:

| Secret | Description |
|--------|-------------|
| `GPG_PRIVATE_KEY` | ASCII-armored GPG private key (see below) |
| `GPG_PASSPHRASE` | Passphrase protecting the private key |

Add them at:
**Repository → Settings → Secrets and variables → Actions → New repository secret**

---

## Exporting Your GPG Key for CI

1. **List your keys** to find the fingerprint:

   ```bash
   gpg --list-secret-keys --keyid-format=long
   ```

2. **Export the private key** (keep this safe!):

   ```bash
   gpg --armor --export-secret-keys <FINGERPRINT>
   ```

   Copy the entire output (including `-----BEGIN PGP PRIVATE KEY BLOCK-----`) and paste it as the `GPG_PRIVATE_KEY` secret.

3. **Export the public key** for verification:

   ```bash
   gpg --armor --export <FINGERPRINT>
   ```

   You can add this to your GitHub profile at <https://github.com/settings/keys>.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `No GPG secret key found` | Ensure `GPG_PRIVATE_KEY` secret is set and contains a valid key. |
| `Signature verification FAILED` | The file may have been tampered with, or the wrong key was used. |
| Workflow fails with `gpg: decryption failed` | Check that `GPG_PASSPHRASE` matches the imported key. |
| Committed `.gpg.sig` files are missing | Confirm the workflow has `contents: write` permission and the branch is not protected against direct pushes. |

For further assistance, open an issue in this repository.
