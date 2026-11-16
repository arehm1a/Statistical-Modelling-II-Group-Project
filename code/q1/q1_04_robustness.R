# =============================================================================
# q1_04_robustness.R - Q1 sensitivity analyses              OWNER: Ian (B)
# Goal: show the headline is not an artefact. Each check = one sentence in report.
# =============================================================================
source("code/q1/q1_00_model_spec.R")

# ---- 1. Club effect: random intercept for team (week 10) ----------------------------
f_final_re <- update(f_final, . ~ . + (1 | team))
g_team <- glmer(f_final_re, family = binomial, data = q1)
summary(g_team)                       # expect variance ~ 0 (singular fit)
round(cbind(glm = coef(m_final), glmm = fixef(g_team)), 3)   # fixed effects unchanged?

# ---- 2. Goalkeepers: does the age effect differ for GKs? ------------------------------
m_gk <- fit_q1(f_gk_sens)
anova(m_final, m_gk, test = "Chisq")
summary(m_gk)
table(q1$gk, cut(q1$age, c(16, 23, 27, 37)))   # how many older GKs? (small n caveat)

# ---- 3. Training load as a factor inside the interaction ---------------------------------
m_fac <- glm(injured ~ age_c * factor(training_load) + prev_injuries, family = binomial, data = q1)
anova(fit_q1(update(f_main, . ~ . - load_c + factor(training_load))), m_fac, test = "Chisq")

# ---- 4. Adding back the dropped covariates does not change the headline ----------------
m_adj <- fit_q1(update(f_final, . ~ . + position + bmi + mins1000))
round(cbind(final = coef(m_final), adjusted = coef(m_adj)[names(coef(m_final))]), 3)

# TODO (B): one-line summary of each check for the report + decision notes

# ---- 5. Is the age effect at LOW load real, or an artefact of a linear interaction? -----
# Final model implies risk FALLS with age at load 1 (OR per 5 yrs ~0.47). Check raw data:
with(q1, table(cut(age, c(16, 22, 26, 30, 37)), training_load <= 2))
with(q1[q1$training_load <= 2, ], round(tapply(injured, cut(age, c(16, 22, 26, 30, 37)), mean), 2))
# Alternative: age effect only at higher loads (no negative slope forced at load 1)
m_alt <- glm(injured ~ age_c + age_c:I(training_load >= 4) + I(training_load >= 4) + prev_injuries,
             family = binomial, data = q1)
AIC(m_final, m_alt)
# TODO (B): report whether the low-load decline is supported or should be described as uncertain
