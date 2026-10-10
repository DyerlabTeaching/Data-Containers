# Dyerlab-Branding

The single source of formatting for every Dyerlab teaching module and every
book compiled from them. Change colors, fonts, logos, or format options here,
push, and each module picks up the change on its next render.

## Formats

| Format | Used for | Key settings |
|---|---|---|
| `dyerlab-html` | `homework.qmd`, `in-class.qmd`, `log.qmd` | self-contained, `code-tools: true` so students can download the source |
| `dyerlab-revealjs` | `slides.qmd` | self-contained, contour title background |
| `dyerlab-narrative-html` | `narrative.qmd`; HTML edition of books | not self-contained, no code-tools, TOC depth 3 |
| `dyerlab-narrative-pdf` | PDF edition of books | XeLaTeX, Helvetica Neue / Menlo, wrapped code + output |

Every document names exactly **one** of these in its frontmatter
(`format: dyerlab-html`, …). A module's `_quarto.yml` lists all three module
formats so it can override options for that module only:

```yaml
format:
  dyerlab-narrative-html: default
  dyerlab-html: default
  dyerlab-revealjs: default
```

A book uses `dyerlab-narrative-html` / `dyerlab-narrative-pdf` and overrides
book-specific options (document class, numbering, cover) in its own
`_quarto.yml`.

## Layout

This repo is pulled into each module as a git subtree at
`_extensions/dyerlab/`, which Quarto treats as an extension *organization*
holding two extensions:

```
_extensions/dyerlab/            ← this repo
├── dyerlab/_extension.yml            dyerlab-html, dyerlab-revealjs
├── dyerlab-narrative/_extension.yml  dyerlab-narrative-html, dyerlab-narrative-pdf
├── current-theme.scss                active palette (written by switch-theme.sh)
├── dyerlab-html.scss                 HTML rules (shared by both html formats)
├── dyerlab-revealjs.scss             slide rules
├── themes/                           palette definitions
├── assets/contour.png                slide background
├── theme_dyerlab.R                   matching ggplot2 theme
├── update-extension.sh               module pre-render hook (subtree pull)
├── switch-theme.sh / new-theme.sh    palette tools
└── demo/                             sample documents for previewing formats
```

Shared files stay at the repo root because modules reference them by path
(`_extensions/dyerlab/theme_dyerlab.R`, `_extensions/dyerlab/update-extension.sh`,
`_extensions/dyerlab/assets/contour.png`) — don't move them.

## Updating modules

Each module's `_quarto.yml` runs `_extensions/dyerlab/update-extension.sh` as a
`pre-render` hook, which `git subtree pull`s this repo. So: edit here, commit,
push, then rebuild the modules. **Never hand-edit a module's copy under
`_extensions/dyerlab/`** — a local edit makes the subtree pull conflict, and
because the hook ignores failures, that module silently stops updating.

## Previewing changes

```bash
demo/render.sh          # renders demo/*.qmd with the current working tree into demo/_site/
```

Rendered output is never committed (`demo/_site/` and `docs/` are
git-ignored): this whole repo is copied into every module, so anything
committed here is duplicated 17 times and stays in every module's history.

## Theming

The palette defines bg, fg, h1–h5, and an accent (em, links, inline code).
`switch-theme.sh <name>` activates a palette from `themes/`; `new-theme.sh
<coolors-url> <name>` creates one (palettes also mirror into
`theme_dyerlab.R` for ggplot). Palettes were tuned with
[realtimecolors.com](https://realtimecolors.com) and
[coolors.co](https://coolors.co).
