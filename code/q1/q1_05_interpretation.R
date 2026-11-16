# =============================================================================
# q1_05_interpretation.R - Q1 results for the reader             OWNER: Mahin (A)
# Goal: turn the final model into plain-language effects WITH uncertainty.
# Output: Table (odds ratios) + Figure (predicted risk by age and load) + Ashford table.
# =============================================================================
source("code/q1/q1_00_model_spec.R")
b <- coef(m_final); names(b)
# order: (Intercept), age_c, load_c, prev_injuries, age_c:load_c

# ---- 1. Odds-ratio table -------------------------------------------------------------
ages <- c(20, 25, 30, 34)
or_load <- t(sapply(ages, function(a) or_lincomb(m_final, c(0, 0, 1, 0, a - 25))))
or_age  <- t(sapply(c(1, 3, 5), function(l) or_lincomb(m_final, c(0, 5, 0, 0, 5 * (l - 3)))))  # per 5 years
or_prev <- or_lincomb(m_final, c(0, 0, 0, 1, 0))
or_tab <- rbind(
  setNames(data.frame(paste("+1 training load level, age", ages), round(or_load, 2)), c("effect", "OR", "lower", "upper")),
  setNames(data.frame(paste("+5 years of age, load", c(1, 3, 5)), round(or_age, 2)), c("effect", "OR", "lower", "upper")),
  data.frame(effect = "+1 previous injury", OR = round(or_prev[1], 2), lower = round(or_prev[2], 2), upper = round(or_prev[3], 2)))
or_tab
write.csv(or_tab, file.path(q1_out, "odds_ratios.csv"), row.names = FALSE)
round(exp(confint(m_final)), 3)        # profile-likelihood CIs as a cross-check

# ---- 2. Predicted risk figure (with 95% CI bands) ---------------------------------------
grid <- expand.grid(age = 17:36, training_load = c(1, 3, 5), prev_injuries = 0)
grid$age_c <- grid$age - 25; grid$load_c <- grid$training_load - 3
pr <- predict(m_final, newdata = grid, type = "link", se.fit = TRUE)
grid$p  <- plogis(pr$fit)
grid$lo <- plogis(pr$fit - 1.96 * pr$se.fit); grid$hi <- plogis(pr$fit + 1.96 * pr$se.fit)
save_png("q1/predicted_risk", {
  plot(NA, xlim = c(17, 36), ylim = c(0, 1), xlab = "Age (years)",
       ylab = "Predicted probability of injury", main = "Predicted injury risk (no previous injuries)")
  for (k in 1:3) {
    l <- c(1, 3, 5)[k]; s <- grid[grid$training_load == l, ]
    polygon(c(s$age, rev(s$age)), c(s$lo, rev(s$hi)), col = adjustcolor(c("grey70", "grey50", "grey20")[k], 0.25), border = NA)
    lines(s$age, s$p, lty = k, lwd = 2)
  }
  legend("topleft", paste("Training load", c(1, 3, 5)), lty = 1:3, lwd = 2, bty = "n")
})

# ---- 3. For the client: Ashford United squad risk profile ---------------------------------
ash <- q1[q1$team == "Ashford United", ]
ash$risk <- predict(m_final, newdata = ash, type = "response")
ash_tab <- ash[order(-ash$risk), c("position", "age", "training_load", "prev_injuries", "injured", "risk")]
ash_tab$risk <- round(ash_tab$risk, 2)
head(ash_tab, 8)
write.csv(ash_tab, file.path(q1_out, "ashford_squad_risk.csv"), row.names = FALSE)
c(ashford_mean_predicted = mean(ash$risk), ashford_observed = mean(ash$injured),
  league_observed = mean(q1$injured))

# TODO (A): draft the interpretation paragraph from or_tab (no causal language).
