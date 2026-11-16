# =============================================================================
# 04_goals_poisson.R - STARTER for candidate question 2:
#   "How do venue and opponent strength relate to Ashford's goals scored / conceded?"
# Count response -> Poisson GLM, log link (week 5).
# =============================================================================
source("code/00_setup.R")

for (y in c("goals_scored", "goals_conceded")) {
  cat("\n=====", y, "=====\n")
  f_int  <- as.formula(paste(y, "~ home_away * opponent_rank"))
  m_int  <- glm(f_int, family = poisson, data = matches)
  m_main <- update(m_int, . ~ . - home_away:opponent_rank)
  print(anova(m_main, m_int, test = "Chisq"))   # is the interaction needed?
  print(drop1(m_main, test = "Chisq"))
  print(ratio_table(m_main))                     # rate ratios with 95% CIs
  print(gof(m_main))                             # deviance GOF + dispersion

  # Influence: refit without the 8-0 home win (row with goals_scored == 8)
  m_no8 <- update(m_main, data = subset(matches, goals_scored < 8))
  print(round(cbind(all = coef(m_main), without_8_0 = coef(m_no8)), 3))
}

# Notes from a first look (verify and record in decision notes):
#  - goals_scored: the 8-0 is highly influential; home and rank effects weaken
#    without it -> must be discussed, not silently dropped.
#  - goals_conceded: dispersion well below 1 (underdispersion) -> comment on it.

m_s <- glm(goals_scored ~ home_away + opponent_rank, family = poisson, data = matches)
save_png("goals_scored_diagnostics", {
  par(mfrow = c(1, 2))
  plot(fitted(m_s), rstandard(m_s), pch = 16, xlab = "Fitted mean",
       ylab = "Std. deviance residual", main = "Residuals"); abline(h = c(-2, 0, 2), lty = c(3, 2, 3))
  plot(cooks.distance(m_s), type = "h", ylab = "Cook's distance", main = "Influence")
})
