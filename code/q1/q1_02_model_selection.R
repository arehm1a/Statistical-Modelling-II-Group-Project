# =============================================================================
# q1_02_model_selection.R - Q1 model choice and selection      OWNER: Mahin (A)
# Goal: a defensible, documented path from the full model to f_final.
# Output: Table "model selection" (terms tested, LRT, df, p, AIC) for the report.
# =============================================================================
source("code/q1/q1_00_model_spec.R")

# ---- 1. Why a binomial GLM with logit link ------------------------------------------
# Binary response; logit gives odds ratios. Link check (AIC) for the record:
sapply(c("logit", "probit", "cloglog"),
       function(l) AIC(glm(f_main, family = binomial(link = l), data = q1)))

# ---- 2. Main effects: which characteristics matter? --------------------------------
m_full <- fit_q1(f_full_main)
drop1(m_full, test = "Chisq")                # expect: BMI, minutes, position not needed
m_main <- fit_q1(f_main)
anova(m_main, m_full, test = "Chisq")        # joint test of the dropped terms

# ---- 3. Functional form -----------------------------------------------------------------
anova(m_main, update(m_main, . ~ . - load_c + factor(training_load)), test = "Chisq") # load linear OK?
anova(m_main, update(m_main, . ~ . - prev_injuries + factor(prev_injuries)), test = "Chisq")
anova(m_main, update(m_main, . ~ . + I(age_c^2)), test = "Chisq")

# ---- 4. Interactions (pre-specified: does any effect vary with age?) ----------------
for (t in c("age_c:load_c", "age_c:prev_injuries", "load_c:prev_injuries")) {
  a <- anova(m_main, update(m_main, as.formula(paste(". ~ . +", t))), test = "Chisq")
  cat(sprintf("%-22s LRT = %5.2f, p = %.4f\n", t, a$Deviance[2], a$`Pr(>Chi)`[2]))
}
# Robustness of the choice: BIC search over all two-way terms keeps only age x load
full2 <- glm(injured ~ (age_c + load_c + prev_injuries + position + bmi + mins1000)^2,
             family = binomial, data = q1)
step(m_full, scope = list(lower = ~ 1, upper = formula(full2)), k = log(nrow(q1)), trace = 0)

# ---- 5. Final model ----------------------------------------------------------------------
anova(m_main, m_final, test = "Chisq")
summary(m_final)

# ---- 6. Selection table for the report --------------------------------------------------
sel <- data.frame(
  model = c("Full main effects", "Age + load + previous injuries",
            "+ age x load (final)", "+ GK x age (sensitivity)"),
  formula = c(deparse(f_full_main), deparse(f_main), deparse(f_final), deparse(f_gk_sens)),
  df = c(df.residual(m_full), df.residual(m_main), df.residual(m_final), df.residual(fit_q1(f_gk_sens))),
  deviance = round(c(deviance(m_full), deviance(m_main), deviance(m_final), deviance(fit_q1(f_gk_sens))), 2),
  AIC = round(c(AIC(m_full), AIC(m_main), AIC(m_final), AIC(fit_q1(f_gk_sens))), 1))
sel
write.csv(sel, file.path(q1_out, "model_selection.csv"), row.names = FALSE)

# TODO (A): record each keep/drop decision + reason in notes/decision notes.md
