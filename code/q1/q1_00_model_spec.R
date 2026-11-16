# =============================================================================
# q1_00_model_spec.R - SHARED single source of truth for Q1 (injury risk)
# Q1: Which player characteristics are associated with injury risk,
#     and do these associations vary with age?
#
# Every Q1 script sources this file, so both of us always use the same data
# preparation and the same final model. Change it only after agreeing, and log the
# change in notes/decision notes.md.
# =============================================================================
source("code/00_setup.R")

q1_out <- "outputs/q1"
dir.create(q1_out, showWarnings = FALSE, recursive = TRUE)

# ---- Data preparation ---------------------------------------------------------
q1 <- players
q1$gk       <- as.integer(q1$position == "GK")          # goalkeeper indicator
q1$age_c    <- q1$age - 25                              # centred: main effects readable at age 25
q1$load_c   <- q1$training_load - 3                     # centred at the middle load level
q1$mins1000 <- q1$minutes_played / 1000                 # minutes in thousands

# ---- Candidate models (agreed menu; selection evidence in q1_02) ---------------
f_full_main <- injured ~ age_c + load_c + prev_injuries + position + bmi + mins1000
f_main      <- injured ~ age_c + load_c + prev_injuries
f_final     <- injured ~ age_c * load_c + prev_injuries          # CURRENT final model
f_gk_sens   <- injured ~ age_c * load_c + prev_injuries + gk * age_c   # sensitivity model

# Builds the glm call with the formula written in, so update() works on the result
fit_q1 <- function(f) eval(bquote(glm(.(f), family = binomial, data = q1)))
m_final <- fit_q1(f_final)

# ---- Shared helpers -------------------------------------------------------------
# Odds ratio (95% Wald CI) for a linear combination L of the coefficients
or_lincomb <- function(fit, L) {
  b <- coef(fit); V <- vcov(fit)
  est <- sum(L * b); se <- sqrt(drop(t(L) %*% V %*% L))
  exp(c(OR = est, lower = est - 1.96 * se, upper = est + 1.96 * se))
}
# Hosmer-Lemeshow-type test with g groups of fitted probability
hl_test <- function(fit, y = fit$y, g = 10) {
  f <- fitted(fit); bins <- cut(f, unique(quantile(f, 0:g / g)), include.lowest = TRUE)
  o <- tapply(y, bins, sum); e <- tapply(f, bins, sum); n <- as.vector(table(bins))
  H <- sum((o - e)^2 / (e * (1 - e / n))); k <- length(n)
  c(HL = H, df = k - 2, p = pchisq(H, k - 2, lower.tail = FALSE))
}
# Area under the ROC curve (rank formula, no extra package)
auc <- function(fit, y = fit$y) {
  r <- rank(fitted(fit)); n1 <- sum(y); n0 <- sum(1 - y)
  (sum(r[y == 1]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}
