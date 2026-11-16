# =============================================================================
# 00_setup.R - shared setup for every script
# Run every script from the PROJECT ROOT (the folder containing data/, code/ ...).
# In VS Code: open the project folder, start R (Ctrl+Shift+P > "R: Create R terminal"),
# then e.g.  source("code/q1/q1_01_eda.R")
# =============================================================================

# ---- Packages (installed automatically the first time) ----------------------
pkgs <- c("MASS",   # polr() ordinal models, glm.nb()
          "ordinal", # clm() / clmm(): ordinal models incl. random effects
          "lme4",   # glmer() mixed models (week 10)
          "rmarkdown", "knitr")  # building the report PDF
missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) install.packages(missing, repos = "https://cloud.r-project.org")
invisible(lapply(c("MASS", "lme4"), library, character.only = TRUE))

# ---- Check we are in the project root ----------------------------------------
if (!file.exists("data/league_players.csv")) {
  stop("Working directory is ", getwd(),
       ". Open the project folder in VS Code / setwd() to the project root first.")
}

# ---- Data (relative paths only) ----------------------------------------------
players <- read.csv("data/league_players.csv", stringsAsFactors = FALSE)
players$team     <- factor(players$team)
players$position <- factor(players$position, levels = c("DEF", "MID", "FWD", "GK"))  # DEF = baseline
players$injured  <- as.integer(players$injured)

matches <- read.csv("data/ashford_matches.csv", stringsAsFactors = FALSE)
matches$home_away <- factor(matches$home_away, levels = c("Away", "Home"))            # Away = baseline
matches$result <- factor(with(matches, ifelse(goals_scored > goals_conceded, "W",
                                       ifelse(goals_scored == goals_conceded, "D", "L"))),
                         levels = c("L", "D", "W"), ordered = TRUE)

# ---- Helpers -------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)

# Save the current base-R plot code to outputs/<name>.png
save_png <- function(name, expr, width = 900, height = 600) {
  png(file.path("outputs", paste0(name, ".png")), width = width, height = height, res = 120)
  on.exit(dev.off())
  expr
}

# Odds/rate ratios with 95% Wald CIs from a fitted glm
ratio_table <- function(fit, digits = 3) {
  est <- coef(fit); se <- sqrt(diag(vcov(fit)))
  round(exp(cbind(ratio = est, lower = est - 1.96 * se, upper = est + 1.96 * se)), digits)
}

# Deviance goodness-of-fit test + Pearson dispersion estimate
gof <- function(fit) {
  c(deviance = deviance(fit), df = df.residual(fit),
    p_value  = pchisq(deviance(fit), df.residual(fit), lower.tail = FALSE),
    dispersion = sum(residuals(fit, type = "pearson")^2) / df.residual(fit))
}

cat("Setup done:", nrow(players), "players,", nrow(matches), "matches loaded.\n")
