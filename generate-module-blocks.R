#!/usr/bin/env Rscript
# generate-module-blocks.R
# Fill the generated regions of a module from its module.yml
# (Modules/module-standards.md §11):
#
#   README.md      <!-- BEGIN module:header -->              header image (+ credit)
#   README.md      <!-- BEGIN module:resources -->           the ## Content bullet list
#   narrative.qmd  <!-- BEGIN module:header -->              header image (+ credit),
#                                                            epigraph
#
# Only the lines between a BEGIN/END pair are replaced, and a file is only
# rewritten when its content changes, so re-running leaves the tree clean.
#
# Usage: Rscript generate-module-blocks.R [module-dir]
# Run from update-extension.sh (the module's pre-render hook).

args <- commandArgs(trailingOnly = TRUE)
root <- if (length(args) > 0) args[1] else "."

yml_path <- file.path(root, "module.yml")
if (!file.exists(yml_path)) quit(save = "no")
if (!requireNamespace("yaml", quietly = TRUE)) {
  message("generate-module-blocks: the yaml package is not installed; skipping")
  quit(save = "no")
}

m <- yaml::read_yaml(yml_path)
if (is.null(m$repo)) stop("module.yml has no `repo`")

base      <- sprintf("https://dyerlabteaching.github.io/%s", m$repo)
img       <- if (is.null(m$image$file)) "media/module_image.jpg" else m$image$file
alt       <- if (is.null(m$image$alt)) "" else trimws(m$image$alt)
credit    <- m$image$credit
epigraph  <- m$epigraph
resources <- unlist(m$resources)

has_inclass <- file.exists(file.path(root, "in-class.qmd"))

bullet <- function(x) paste0("- ", trimws(x, which = "right"))
html_attr <- function(x) gsub('"', "&quot;", x, fixed = TRUE)
one_line <- function(x) gsub("\\s*\n\\s*", " ", trimws(x))

# ---- README.md ---------------------------------------------------------------

readme_header <- c(
  "",
  sprintf("![%s](%s/%s)", alt, base, img),
  if (!is.null(credit)) c("", sprintf("*%s*", one_line(credit))),
  ""
)

readme_resources <- c(
  "",
  bullet(sprintf("The [slides](%s/slides.html) for this topic.", base)),
  bullet(sprintf("A longer [narrative](%s/narrative.html) that goes into more depth.", base)),
  if (has_inclass) bullet(sprintf("An [in-class](%s/in-class.html) activity.", base)),
  if (length(resources) > 0) bullet(resources),
  ""
)

# ---- narrative.qmd -----------------------------------------------------------

narrative_header <- c(
  "",
  sprintf('![](%s){fig-alt="%s"}', img, html_attr(alt)),
  if (!is.null(credit)) c("", sprintf("*%s*", one_line(credit))),
  if (!is.null(epigraph)) c("", paste0("> ", one_line(epigraph))),
  ""
)

# ---- fill regions ------------------------------------------------------------

fill <- function(file, region, body) {
  path <- file.path(root, file)
  if (!file.exists(path)) return(invisible(FALSE))
  txt <- readLines(path, warn = FALSE)
  b <- grep(sprintf("<!-- BEGIN module:%s", region), txt, fixed = TRUE)
  e <- grep(sprintf("<!-- END module:%s", region), txt, fixed = TRUE)
  if (length(b) != 1 || length(e) != 1 || e < b) {
    if (length(b) + length(e) > 0)
      message(sprintf("generate-module-blocks: %s has unmatched module:%s markers; skipped", file, region))
    return(invisible(FALSE))
  }
  # split multi-line entries (nested resource lists) so the comparison is line by line
  body <- unlist(lapply(body, function(x) if (x == "") "" else strsplit(x, "\n", fixed = TRUE)[[1]]))
  new <- c(txt[seq_len(b)], body, txt[e:length(txt)])
  if (identical(new, txt)) return(invisible(FALSE))
  writeLines(new, path)
  message(sprintf("generate-module-blocks: updated module:%s in %s", region, file))
  invisible(TRUE)
}

fill("README.md", "header", readme_header)
fill("README.md", "resources", readme_resources)
fill("narrative.qmd", "header", narrative_header)
