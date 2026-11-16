# =============================================================================
# q1_03_diagnostics.R - Q1 goodness of fit and diagnostics    OWNER: Ian (B)
# Goal: show the final model fits adequately and no player drives the results.
# Note: for UNGROUPED binary data the residual deviance is NOT chi-squared,
#       so use grouped checks (Hosmer-Lemeshow, calibration) instead.
# =============================================================================
source("code/q1/q1_00_model_spec.R")
m_gk <- fit_q1(f_gk_sens)

# ---- Goodness of fit ----------------------------------------------------------------
rbind(final = hl_test(m_final), gk_sensitivity = hl_test(m_gk))   # 10 groups
sapply(c(5, 8, 12), function(g) hl_test(m_final, g = g)["p"])      # robustness to grouping
c(AUC_final = auc(m_final), AUC_gk = auc(m_gk))                    # discrimination

# ---- Calibration plot (observed vs fitted by decile) -------------------------------
cal <- function(fit) {
  f <- fitted(fit); b <- cut(f, quantile(f, 0:10 / 10), include.lowest = TRUE)
  data.frame(fitted = tapply(f, b, mean), observed = tapply(fit$y, b, mean),
             n = as.vector(table(b)))
}
cal_final <- cal(m_final)
cal_final$se <- sqrt(cal_final$observed * (1 - cal_final$observed) / cal_final$n)

# ---- Residuals and influence -----------------------------------------------------------
infl <- data.frame(q1[, c("team", "position", "age", "training_load", "prev_injuries", "injured")],
                   fitted = fitted(m_final), lev = hatvalues(m_final),
                   cook = cooks.distance(m_final), rstd = rstandard(m_final))
head(infl[order(-infl$cook), ], 5)                        # most influential players
# Refit without the 5 most influential: do conclusions change?
drop5 <- order(-infl$cook)[1:5]
round(cbind(all = coef(m_final), without_top5 = coef(update(m_final, data = q1[-drop5, ]))), 3)

# Binned residuals vs age (checks the age functional form)
br <- with(q1, tapply(residuals(m_final, type = "response"), cut(age, quantile(age, 0:8 / 8), include.lowest = TRUE), mean))
round(br, 3)

save_png("q1/diagnostics", {
  par(mfrow = c(1, 2))
  plot(cal_final$fitted, cal_final$observed, pch = 16, xlim = c(0, 0.6), ylim = c(0, 0.6),
       xlab = "Mean fitted probability", ylab = "Observed proportion", main = "(a) Calibration")
  arrows(cal_final$fitted, pmax(0, cal_final$observed - 1.96 * cal_final$se), cal_final$fitted,
         cal_final$observed + 1.96 * cal_final$se, angle = 90, code = 3, length = 0.03)
  abline(0, 1, lty = 2)
  plot(infl$lev, infl$cook, xlab = "Leverage", ylab = "Cook's distance", main = "(b) Influence")
})

# TODO (B): HL rejects the final model (p ~ 0.003) but not the GK-sensitivity model:
#           write 2-3 sentences on what that means and how we report it.
