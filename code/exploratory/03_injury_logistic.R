# =============================================================================
# 03_injury_logistic.R - STARTER for candidate question 1:
#   "Which player characteristics are associated with the risk of injury?"
# Binary response -> binomial GLM, logit link (weeks 3-4), team effect via GLMM (week 10).
# This is a first pass to build on, not the final analysis. Log every choice in
# notes/decision notes.md.
# =============================================================================
source("code/00_setup.R")

# ---- Full main-effects model -------------------------------------------------------
m_full <- glm(injured ~ age + minutes_played + training_load + prev_injuries + bmi + position,
              family = binomial, data = players)
summary(m_full)
drop1(m_full, test = "Chisq")            # LRT for each term

# ---- Model selection (backward, LRT + AIC) --------------------------------------
m_step <- step(m_full, direction = "backward", trace = 1)   # AIC-based; confirm with LRTs
summary(m_step)
anova(m_step, m_full, test = "Chisq")

# TODO (decisions to test and record):
#  - training_load linear vs factor:  anova(<numeric version>, <factor version>, test = "Chisq")
#  - interactions, e.g. age:training_load, training_load:prev_injuries
#  - position: keep for interpretation even if not significant?

# ---- Fit and diagnostics ----------------------------------------------------------
# Ungrouped binary data: the residual deviance is NOT chi-squared, so use a
# grouped / binned check instead (e.g. compare observed vs fitted by decile).
players$fit <- fitted(m_step)
bins <- cut(players$fit, quantile(players$fit, 0:10 / 10), include.lowest = TRUE)
calib <- data.frame(observed = tapply(players$injured, bins, mean),
                    fitted   = tapply(players$fit, bins, mean),
                    n        = as.vector(table(bins)))
round(calib, 3)

save_png("injury_diagnostics", {
  par(mfrow = c(1, 2))
  plot(calib$fitted, calib$observed, pch = 16, xlab = "Mean fitted probability",
       ylab = "Observed proportion", main = "Calibration by decile")
  abline(0, 1, lty = 2)
  plot(hatvalues(m_step), cooks.distance(m_step), xlab = "Leverage",
       ylab = "Cook's distance", main = "Influence")
})

# ---- Interpretation -------------------------------------------------------------------
ratio_table(m_step)          # odds ratios with 95% CIs
exp(confint(m_step))         # profile-likelihood CIs (preferred; compare with Wald)

# ---- Team as a random effect (week 10/11) -----------------------------------------
m_glmm <- glmer(injured ~ age + training_load + prev_injuries + (1 | team),
                family = binomial, data = players)
summary(m_glmm)              # team variance near 0? -> conclusions unchanged
