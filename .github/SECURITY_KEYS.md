# Security Keys & GPG Signing Guide

This document explains how GPG signing is implemented in this repository,
how to set up your local environment, and how to verify signatures.

---

## Table of Contents

1. [Overview](#overview)
2. [Generating a GPG Key](#generating-a-gpg-key)
3. [Local Setup](#local-setup)
4. [Configuring GitHub Secrets](#configuring-github-secrets)
5. [How the Workflow Works](#how-the-workflow-works)
6. [Verifying Signatures](#verifying-signatures)
7. [Troubleshooting](#troubleshooting)

---

## Overview

All `.sh`, `.py`, `.yml`, and `.tf` files that are modified in a pull request
are automatically signed with a detached GPG signature.  Signatures are stored
alongside the original files with a `.gpg.sig` suffix, e.g.:

```
my-script.sh      ← original file
my-script.sh.gpg.sig  ← detached armored GPG signature
```

The signing key's fingerprint is recorded in each PR comment for auditing.

---

## Generating a GPG Key

If you do not already have a GPG key, create one:

```bash
gpg --full-generate-key
```

Recommended settings:
- Key type: **RSA and RSA**
- Key size: **4096**
- Expiry: **2y** (renew regularly)
- Real name & email: match your GitHub account

List your keys to find the key ID:

```bash
gpg --list-secret-keys --keyid-format=long
```

Example output:
```
sec   rsa4096/B732B308C0FE0BB3 2024-01-01 [SC] [expires: 2026-01-01]
      C8040559438A554CAD747154B732B308C0FE0BB3
uid                 [ultimate] Your Name <you@example.com>
```

The key ID here is `B732B308C0FE0BB3`.

---

## Local Setup

Run the interactive setup script to configure your local environment:

```bash
chmod +x .github/scripts/setup-gpg.sh
.github/scripts/setup-gpg.sh
```

The script will:
1. Verify that `gpg` and `git` are installed.
2. List existing secret keys.
3. Optionally import a key from a file.
4. Configure `git` to sign commits and tags with the chosen key.
5. Print your **public key** (for uploading to GitHub).
6. Optionally export your **private key** (for the `GPG_PRIVATE_KEY` secret).

---

## Configuring GitHub Secrets

The signing workflow requires two repository secrets:

| Secret name       | Description                                      |
|-------------------|--------------------------------------------------|
| `GPG_PRIVATE_KEY` | Armored, ASCII-exported GPG private key          |
| `GPG_PASSPHRASE`  | Passphrase protecting the private key            |

### Export the private key

```bash
gpg --armor --export-secret-keys B732B308C0FE0BB3
```

Copy the entire output (including `-----BEGIN PGP PRIVATE KEY BLOCK-----`).

### Add secrets to GitHub

1. Navigate to your repository on GitHub.
2. Go to **Settings → Secrets and variables → Actions**.
3. Click **New repository secret** and add:
   - Name: `GPG_PRIVATE_KEY`, Value: paste the armored private key.
   - Name: `GPG_PASSPHRASE`, Value: your key passphrase.

### Add your public key to GitHub (optional but recommended)

1. Go to **GitHub → Settings → SSH and GPG keys**.
2. Click **New GPG key**.
3. Paste the output of:
   ```bash
   gpg --armor --export B732B308C0FE0BB3
   ```

---

## How the Workflow Works

The workflow (`.github/workflows/gpg-sign-files.yml`) is triggered on every
pull request event (`opened`, `synchronize`, `reopened`).

```
PR opened/updated
      │
      ▼
Checkout PR branch
      │
      ▼
Import GPG private key from secret
      │
      ▼
Get list of files changed vs. base branch
      │
      ▼
Filter for .sh / .py / .yml / .tf extensions
      │
      ▼
Run .github/scripts/sign-files.sh
  ├── Skip files listed in .gpg-ignore
  ├── gpg --detach-sign --armor → <file>.gpg.sig
  └── gpg --verify <file>.gpg.sig <file>
      │
      ▼
Commit & push signatures to PR branch
      │
      ▼
Post GPG Signature Report as PR comment
```

---

## Verifying Signatures

### Prerequisites

Import the signer's public key:

```bash
gpg --keyserver keyserver.ubuntu.com --recv-keys B732B308C0FE0BB3
# or import from a local file
gpg --import signer-public.asc
```

### Verify a single file

```bash
gpg --verify my-script.sh.gpg.sig my-script.sh
```

A successful verification prints:
```
gpg: Signature made Mon 18 Apr 2026 19:00:00 UTC
gpg:                using RSA key B732B308C0FE0BB3
gpg: Good signature from "Your Name <you@example.com>"
```

### Verify all signatures in the repository

```bash
find . -name '*.gpg.sig' | while read -r sig; do
  original="${sig%.gpg.sig}"
  echo "Verifying $original ..."
  gpg --verify "$sig" "$original" && echo "  ✅ OK" || echo "  ❌ FAILED"
done
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `gpg: no secret key` | Ensure `GPG_PRIVATE_KEY` secret is set and the key is not expired. |
| `gpg: Bad passphrase` | Check that `GPG_PASSPHRASE` matches the key's passphrase. |
| Workflow skips all files | Confirm the changed files have `.sh`, `.py`, `.yml`, or `.tf` extensions. |
| Signature fails verification | The file may have been modified after signing. Re-open the PR to re-sign. |
| File is ignored unexpectedly | Check `.gpg-ignore` for matching patterns. |
