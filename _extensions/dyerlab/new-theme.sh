#!/usr/bin/env bash
# Create a new Dyerlab theme from a coolors.co URL.
#
# Usage:
#   ./_extensions/dyerlab/new-theme.sh <coolors-url> <theme-name>
#
# Example:
#   ./_extensions/dyerlab/new-theme.sh \
#     https://coolors.co/6e675f-edebd7-e3b23c-423e37-a39594 warmstone

set -e

URL="${1}"
NAME="${2}"
DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Validate args ─────────────────────────────────────────────
if [ -z "$URL" ] || [ -z "$NAME" ]; then
  echo "Usage: new-theme.sh <coolors-url-or-hex-string> <theme-name>"
  echo "  URL:  https://coolors.co/aabbcc-ddeeff-..."
  echo "  Name: single word, lowercase (e.g. warmstone)"
  exit 1
fi

# ── Extract hex codes from URL ────────────────────────────────
# Works with full URL or bare hex string (e.g. "aabbcc-ddeeff-...")
HEX_STRING="${URL##*/}"   # strip everything up to last /
IFS='-' read -ra COLORS <<< "$HEX_STRING"

if [ "${#COLORS[@]}" -ne 5 ]; then
  echo "Error: expected 5 colors in URL, got ${#COLORS[@]}"
  echo "URL path: $HEX_STRING"
  exit 1
fi

# ── Python: luminance, contrast, lighten, assign roles ────────
python3 - "${COLORS[@]}" "$NAME" "$DIR" << 'PYEOF'
import sys, os, colorsys

colors = sys.argv[1:6]   # 5 hex strings (no #)
name   = sys.argv[6]
outdir = sys.argv[7]

def luminance(h):
    r, g, b = int(h[0:2],16)/255, int(h[2:4],16)/255, int(h[4:6],16)/255
    def lin(c): return c/12.92 if c <= 0.04045 else ((c+0.055)/1.055)**2.4
    return 0.2126*lin(r) + 0.7152*lin(g) + 0.0722*lin(b)

def contrast(h1, h2):
    l1, l2 = luminance(h1), luminance(h2)
    lighter, darker = max(l1,l2), min(l1,l2)
    return (lighter + 0.05) / (darker + 0.05)

def lighten(h, amount):
    """Increase HSL lightness by amount (0-1)."""
    r, g, b = int(h[0:2],16)/255, int(h[2:4],16)/255, int(h[4:6],16)/255
    hh, s, l = colorsys.rgb_to_hls(r, g, b)
    l = min(1.0, l + amount)
    r2, g2, b2 = colorsys.hls_to_rgb(hh, l, s)
    return f"{int(r2*255):02X}{int(g2*255):02X}{int(b2*255):02X}"

def wcag(ratio, large=True):
    threshold = 3.0 if large else 4.5
    return "✓ pass" if ratio >= threshold else f"✗ FAIL (need {threshold}:1)"

# Sort by luminance
lums = [(c, luminance(c)) for c in colors]
lums.sort(key=lambda x: x[1])

bg  = lums[0][0]   # darkest
fg  = lums[4][0]   # lightest
mid = [lums[1][0], lums[2][0], lums[3][0]]   # remaining 3

# Sort remaining by contrast against bg (highest first) → h1, h2, h3
mid.sort(key=lambda c: contrast(c, bg), reverse=True)
h1, h2, h3 = mid

# Derive h4 and h5_em
h4    = lighten(h1, 0.15)
h5_em = lighten(h2, 0.12)

# ── Print assignment table ────────────────────────────────────
print(f"\n  Theme: {name}")
print(f"  Source: {' '.join('#'+c for c in colors)}\n")
print(f"  {'Role':<12} {'Hex':<10} {'Contrast vs bg':<18} {'WCAG large'}")
print(f"  {'-'*58}")
for role, c in [("bg", bg), ("fg", fg), ("h1", h1), ("h2", h2),
                ("h3", h3), ("h4 (derived)", h4), ("h5-em (derived)", h5_em)]:
    r = contrast(c, bg)
    note = wcag(r) if role not in ("bg",) else "—"
    print(f"  {role:<16} #{c:<9} {r:<18.1f} {note}")

# ── Write theme file ──────────────────────────────────────────
out = os.path.join(outdir, "themes", f"{name}.scss")
with open(out, "w") as f:
    f.write(f"// ── {name.title()} theme {'─' * (45 - len(name))}\n")
    f.write(f"// Generated from coolors.co palette.\n")
    f.write(f"// Sync hex values with: theme_dyerlab.R (.dyerlab_themes${name})\n\n")
    f.write(f"$brand-bg:    #{bg};\n")
    f.write(f"$brand-fg:    #{fg};\n")
    f.write(f"$brand-h1:    #{h1};   // H1 — highest contrast accent\n")
    f.write(f"$brand-h2:    #{h2};   // H2 — every slide title\n")
    f.write(f"$brand-h3:    #{h3};   // H3 — column heads\n")
    f.write(f"$brand-h4:    #{h4};   // H4 — derived: lightened h1\n")
    f.write(f"$brand-h5-em: #{h5_em};   // H5 / em — derived: lightened h2\n")

print(f"\n  Written: {out}")
print(f"\n  To activate:  ./_extensions/dyerlab/switch-theme.sh {name}")
print(f"  To add to R:  add '{name}' entry to .dyerlab_themes in theme_dyerlab.R\n")

# ── Warn on any WCAG failures ─────────────────────────────────
failures = []
for role, c in [("h1", h1), ("h2", h2), ("h3", h3),
                ("h4", h4), ("h5-em", h5_em), ("fg", fg)]:
    if contrast(c, bg) < 3.0:
        failures.append(f"  ⚠  {role} (#{c}) contrast {contrast(c,bg):.1f}:1 — below 3:1 for large text")
if failures:
    print("  WCAG warnings:")
    for w in failures: print(w)
    print()

PYEOF
