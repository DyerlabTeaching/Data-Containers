# ── Dyerlab ggplot2 theme ─────────────────────────────────────
# Usage:
#   source("_extensions/dyerlab/theme_dyerlab.R")
#   theme_set(theme_dyerlab())               # uses active theme
#   theme_set(theme_dyerlab("positron"))     # explicit override
#   ggplot(...) + scale_color_dyerlab()      # discrete color scale

# ── Theme palettes ────────────────────────────────────────────
# Mirror of themes/*.scss — update in both places when changing a palette.

.dyerlab_themes <- list(

  academy = list(
    background = "#121929",
    foreground = "#DCE5F0",
    h1         = "#FF0000",   # Darjeeling1[1]
    h2         = "#F2AD00",   # Darjeeling1[3] — gold, every slide title
    h3         = "#00A08A",   # Darjeeling1[2] — teal, column heads
    h4         = "#F98400",   # Darjeeling1[4]
    h5         = "#DCE5F0",   # = fg (blends with body text)
    accent     = "#5BBCD6"    # em, links, inline code, borders — Darjeeling1[5]
  ),

  positron = list(
    background = "#0d1117",
    foreground = "#c9d1d9",
    h1         = "#ff7b72",   # muted coral
    h2         = "#ffa657",   # warm amber
    h3         = "#79c0ff",   # soft blue
    h4         = "#f0883e",   # orange
    h5         = "#c9d1d9",   # = fg (blends with body text)
    accent     = "#a5d6ff"    # em, links, inline code, borders — pale blue
  ),

  `dyerlab-base` = list(
    background = "#ffffff",    # White: Petals
    foreground = "#050505",   # Near-black: High contrast text
    h1         = "#1a2d42",   # Deep Sapphire Blue: Dark sky
    h2         = "#3a5d7d",   # Deep Sky Blue: Classic professional
    h3         = "#5282b2",   # Cerulean: Lighter sky
    h4         = "#6b7a5e",   # Muted Olive/Sage: Flower sepals
    h5         = "#c3D898",   # H5  — tea grean
    accent     = "#96262b"    # Sepal-tip Red
  )

)

# Active theme — must mirror current-theme.scss
.dyerlab_active <- "dyerlab-base"

.brand <- function(theme = NULL) {
  t <- if (is.null(theme)) .dyerlab_active else theme
  p <- .dyerlab_themes[[t]]
  if (is.null(p)) stop("Unknown dyerlab theme: ", t,
                        ". Choose from: ",
                        paste(names(.dyerlab_themes), collapse = ", "))
  p
}

.brand_palette <- function(theme = NULL) {
  p <- .brand(theme)
  c(p$h2, p$h4, p$h3, p$accent, p$h1)
}

# ── theme_dyerlab() ───────────────────────────────────────────
#' Dyerlab ggplot2 theme
#'
#' @param theme Theme name: "academy" (default) or "positron".
#' @param base_size Base font size in pts. Default 14 suits slides;
#'   use 11-12 for narrative HTML.
#' @param grid One of "both" (default), "x", "y", or "none".
#' @return A ggplot2 theme object.
theme_dyerlab <- function(theme = NULL, base_size = 14, grid = "both") {

  p         <- .brand(theme)
  half_line <- base_size / 2
  grid_col  <- paste0(p$foreground, "18")

  t <- ggplot2::theme(
    # ── Canvas ─────────────────────────────────────────────────
    plot.background  = ggplot2::element_rect(fill  = p$background, color = NA),
    panel.background = ggplot2::element_rect(fill  = p$background, color = NA),

    # ── Grid ───────────────────────────────────────────────────
    panel.grid.major   = ggplot2::element_line(color = grid_col, linewidth = 0.4),
    panel.grid.minor   = ggplot2::element_line(color = grid_col, linewidth = 0.2),
    panel.border       = ggplot2::element_blank(),
    axis.line          = ggplot2::element_line(color = p$foreground, linewidth = 0.4),

    # ── Text ───────────────────────────────────────────────────
    text = ggplot2::element_text(family = "sans", color = p$foreground,
                                 size = base_size),
    plot.title = ggplot2::element_text(
      color  = p$h2,
      size   = base_size * 1.2,
      face   = "bold",
      hjust  = 0,
      margin = ggplot2::margin(b = half_line)
    ),
    plot.subtitle = ggplot2::element_text(
      color  = p$h3,
      size   = base_size * 0.9,
      hjust  = 0,
      margin = ggplot2::margin(b = half_line)
    ),
    plot.caption = ggplot2::element_text(
      color  = paste0(p$foreground, "99"),
      size   = base_size * 0.75,
      hjust  = 1,
      margin = ggplot2::margin(t = half_line)
    ),

    # ── Axes ───────────────────────────────────────────────────
    axis.title = ggplot2::element_text(color = p$foreground, size = base_size * 0.9),
    axis.text  = ggplot2::element_text(color = paste0(p$foreground, "CC"),
                                       size = base_size * 0.8),
    axis.ticks = ggplot2::element_line(color = grid_col, linewidth = 0.4),

    # ── Legend ─────────────────────────────────────────────────
    legend.background = ggplot2::element_rect(fill = p$background, color = NA),
    legend.key        = ggplot2::element_rect(fill = p$background, color = NA),
    legend.title = ggplot2::element_text(color = p$h2, size = base_size * 0.85,
                                         face = "bold"),
    legend.text  = ggplot2::element_text(color = p$foreground, size = base_size * 0.8),

    # ── Facets ─────────────────────────────────────────────────
    strip.background = ggplot2::element_rect(fill  = paste0(p$foreground, "18"),
                                             color = NA),
    strip.text = ggplot2::element_text(color = p$h3, size = base_size * 0.85,
                                       face = "bold"),

    # ── Margins ────────────────────────────────────────────────
    plot.margin = ggplot2::margin(half_line, half_line, half_line, half_line)
  )

  if (grid == "x") {
    t <- t + ggplot2::theme(panel.grid.major.y = ggplot2::element_blank(),
                             panel.grid.minor.y = ggplot2::element_blank())
  } else if (grid == "y") {
    t <- t + ggplot2::theme(panel.grid.major.x = ggplot2::element_blank(),
                             panel.grid.minor.x = ggplot2::element_blank())
  } else if (grid == "none") {
    t <- t + ggplot2::theme(panel.grid = ggplot2::element_blank())
  }

  t
}

# ── Color scales ──────────────────────────────────────────────

#' Dyerlab discrete color scale
scale_color_dyerlab <- function(theme = NULL, ...) {
  ggplot2::scale_color_manual(values = .brand_palette(theme), ...)
}

#' Dyerlab discrete fill scale
scale_fill_dyerlab <- function(theme = NULL, ...) {
  ggplot2::scale_fill_manual(values = .brand_palette(theme), ...)
}

#' Dyerlab sequential color scale (background → h3)
scale_color_dyerlab_seq <- function(theme = NULL, ...) {
  p <- .brand(theme)
  ggplot2::scale_color_gradient(low = p$background, high = p$h3, ...)
}

#' Dyerlab diverging color scale (h1 ← background → h3)
scale_color_dyerlab_div <- function(theme = NULL, ...) {
  p <- .brand(theme)
  ggplot2::scale_color_gradient2(low = p$h1, mid = p$background,
                                  high = p$h3, ...)
}
