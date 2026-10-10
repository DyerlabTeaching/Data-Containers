#!/usr/bin/env bash
# render.sh — preview every Dyerlab format against the demo documents.
#
# Quarto only finds extensions under a project's _extensions/, so this copies
# the repo (minus demo/, docs/, .git) into demo/_extensions/dyerlab/ — the same
# layout a module gets from the git subtree — and renders into ../docs/.
set -euo pipefail
cd "$(dirname "$0")"
rm -rf _extensions
mkdir -p _extensions/dyerlab
rsync -a --exclude demo --exclude docs --exclude .git --exclude .quarto --exclude .DS_Store ../ _extensions/dyerlab/
quarto render "$@"
