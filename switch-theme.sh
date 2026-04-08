#!/usr/bin/env bash
# Usage: ./_extensions/dyerlab/switch-theme.sh <name>
# Example: ./_extensions/dyerlab/switch-theme.sh positron

set -e

THEME="${1}"
DIR="$(cd "$(dirname "$0")" && pwd)"
THEMES_DIR="$DIR/themes"
CURRENT="$DIR/current-theme.scss"

if [ -z "$THEME" ]; then
  echo "Usage: switch-theme.sh <name>"
  echo "Available: $(ls "$THEMES_DIR"/*.scss | xargs -n1 basename | sed 's/\.scss//' | tr '\n' ' ')"
  exit 1
fi

if [ ! -f "$THEMES_DIR/$THEME.scss" ]; then
  echo "Unknown theme: $THEME"
  echo "Available: $(ls "$THEMES_DIR"/*.scss | xargs -n1 basename | sed 's/\.scss//' | tr '\n' ' ')"
  exit 1
fi

# Write current-theme.scss:
#   1. Quarto layer marker
#   2. Brand palette (from themes/<name>.scss, comments stripped)
#   3. RevealJS derived variables (static — always reference $brand-* vars)
cat > "$CURRENT" << 'SCSS_EOF'
/*-- scss:defaults --*/

// ── Active theme: THEME_PLACEHOLDER ──────────────────────────
// To switch: run _extensions/dyerlab/switch-theme.sh <name>
// Available themes: AVAILABLE_PLACEHOLDER

SCSS_EOF

# Patch in the actual theme name and available list
AVAILABLE="$(ls "$THEMES_DIR"/*.scss | xargs -n1 basename | sed 's/\.scss//' | tr '\n' ' ')"
sed -i '' "s/THEME_PLACEHOLDER/$THEME/" "$CURRENT"
sed -i '' "s/AVAILABLE_PLACEHOLDER/$AVAILABLE/" "$CURRENT"

# Append brand palette variables (strip comment-only lines)
grep -v '^//' "$THEMES_DIR/$THEME.scss" >> "$CURRENT"

# Append RevealJS derived variables (these never change — always ref $brand-*)
cat >> "$CURRENT" << 'SCSS_EOF'

// ── RevealJS variables (derived from brand palette above) ─────
$backgroundColor:          $brand-bg;
$mainColor:                $brand-fg;
$headingColor:             $brand-h2;
$linkColor:                $brand-accent;
$linkColorHover:           lighten($brand-accent, 12%);
$selectionColor:           $brand-bg;
$selectionBackgroundColor: $brand-h3;

$mainFont:             -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
                       "Helvetica Neue", Arial, sans-serif;
$headingFont:          $mainFont;
$codeFont:             "SFMono-Regular", Consolas, "Liberation Mono",
                       Menlo, Courier, monospace;

$mainFontSize:         32px;
$headingTextTransform: none;
$headingTextShadow:    none;
$headingFontWeight:    600;
$headingLetterSpacing: -0.01em;
SCSS_EOF

echo "Switched to theme: $THEME"
echo "Re-render to apply: quarto render"
