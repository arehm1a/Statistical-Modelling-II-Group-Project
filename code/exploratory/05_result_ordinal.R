# =============================================================================
# 05_result_ordinal.R - STARTER for candidate question 3:
#   "How are home advantage and opponent strength associated with match outcome?"
# Ordered response L < D < W -> proportional odds model (week 9, MASS::polr).
# =============================================================================
source("code/00_setup.R")

m_po <- polr(result ~ home_away + opponent_rank, data = matches, Hess = TRUE)
summary(m_po)
m_po0 <- polr(result ~ opponent_rank, data = matches, Hess = TRUE)
anova(m_po0, m_po)                       # LRT for home/away

# Odds ratios for a BETTER result (W vs D/L, or W/D vs L), 95% CIs
round(exp(cbind(OR = coef(m_po), confint(m_po))), 3)

# Fitted outcome probabilities, home vs away, against a strong / mid / weak opponent
newd <- expand.grid(home_away = c("Away", "Home"), opponent_rank = c(2, 12, 22))
cbind(newd, round(predict(m_po, newdata = newd, type = "probs"), 3))

# TODO: check the proportional odds assumption (e.g. compare separate binary
# logistic fits for "W/D vs L" and "W vs D/L" - are the slopes similar?)
