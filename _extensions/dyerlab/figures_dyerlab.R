# ── Dyerlab teaching figures ──────────────────────────────────
# Shared figures reused across modules, drawn with theme_dyerlab() so
# they follow the active palette.
# Usage:
#   source("_extensions/dyerlab/figures_dyerlab.R")
#   variable_types_grid(highlight = "aov")

if (!exists("theme_dyerlab")) source("_extensions/dyerlab/theme_dyerlab.R")

# ── variable_types_grid() ─────────────────────────────────────
#' Predictor × response grid of analysis approaches
#'
#' @param highlight Cell(s) to emphasize: any of "correlation",
#'   "regression", "aov", "logistic", "contingency". Correlation and
#'   regression share a cell. NULL emphasizes every cell.
#' @param later Cell(s) without a module yet; drawn dimmed. Remove a
#'   name once its module exists.
#' @param formulas Show the R model formula in each cell.
#' @param theme Dyerlab theme name; NULL uses the active theme.
#' @param base_size Base font size in pts.
#' @return A ggplot object.
variable_types_grid <- function(highlight = NULL,
                                later     = c("logistic", "contingency"),
                                formulas  = TRUE,
                                theme     = NULL,
                                base_size = 18) {

  p <- .brand(theme)

  cells <- data.frame(
    key       = c("corr_reg", "aov", "logistic", "contingency"),
    predictor = c("Continuous", "Discrete", "Continuous", "Discrete"),
    response  = c("Continuous", "Continuous", "Discrete", "Discrete"),
    label     = c("Correlation\n& Regression", "Analysis of\nVariance",
                  "Logistic\nRegression", "Contingency\nTables"),
    formula   = c("y ~ x", "y ~ group", "group ~ x", "group ~ group")
  )
  members <- list(corr_reg    = c("correlation", "regression"),
                  aov         = "aov",
                  logistic    = "logistic",
                  contingency = "contingency")

  in_set <- function(set) vapply(members, function(m) any(m %in% set), logical(1))
  cells$on    <- if (is.null(highlight)) TRUE else in_set(highlight)
  cells$later <- in_set(later)

  cells$fill <- ifelse(cells$on, p$h3, paste0(p$foreground, "14"))
  cells$text <- ifelse(cells$on, p$background,
                       ifelse(cells$later, paste0(p$foreground, "80"), p$foreground))
  cells$sub  <- if (formulas) cells$formula else ""

  cells$predictor <- factor(cells$predictor, levels = c("Continuous", "Discrete"))
  cells$response  <- factor(cells$response,  levels = c("Discrete", "Continuous"))

  ggplot2::ggplot(cells, ggplot2::aes(predictor, response)) +
    ggplot2::geom_tile(ggplot2::aes(fill = fill), color = p$background,
                       linewidth = 3) +
    ggplot2::geom_text(ggplot2::aes(label = label, color = text),
                       size = base_size / ggplot2::.pt * 1.05,
                       fontface = "bold", lineheight = 0.9, vjust = 0.2) +
    ggplot2::geom_text(ggplot2::aes(label = sub, color = text),
                       size = base_size / ggplot2::.pt * 0.85,
                       family = "mono", vjust = 3.6) +
    ggplot2::scale_fill_identity() +
    ggplot2::scale_color_identity() +
    ggplot2::scale_x_discrete(position = "top", expand = c(0, 0)) +
    ggplot2::scale_y_discrete(expand = c(0, 0)) +
    ggplot2::coord_equal() +
    ggplot2::labs(x = "Predictor", y = "Response") +
    theme_dyerlab(theme = theme, base_size = base_size, grid = "none") +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      axis.line   = ggplot2::element_blank(),
      axis.ticks  = ggplot2::element_blank(),
      axis.title  = ggplot2::element_text(color = p$h2, face = "bold"),
      axis.text   = ggplot2::element_text(color = p$foreground),
      axis.text.y = ggplot2::element_text(angle = 90, hjust = 0.5)
    )
}
