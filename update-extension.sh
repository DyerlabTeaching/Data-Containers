#!/usr/bin/env bash
# update-extension.sh
# Quarto pre-render script: pull the latest Dyerlab Branding extension from GitHub.
# Silently no-ops if already up to date or if offline.
#
# Referenced in each module _quarto.yml as:
#   project:
#     pre-render: _extensions/dyerlab/update-extension.sh

REMOTE="https://github.com/DyerlabTeaching/Dyerlab-Branding"
PREFIX="_extensions/dyerlab"

# Run from repo root regardless of where Quarto invokes us
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
cd "$REPO_ROOT"

git subtree pull --prefix="$PREFIX" "$REMOTE" main --squash --quiet 2>/dev/null || true
