# =============================================================================
# 06_question_scoping.R - evidence used to choose the three report questions
# Screens every candidate response in both datasets (16 Nov 2026).
# Summary of conclusions is in notes/decision notes.md.
# =============================================================================
source("code/00_setup.R")
library(ordinal)   # clm / clmm: ordinal models with random effects
p <- players
m <- matches

# =============================================================================
# CANDIDATE Q1: injury (binary) -> binomial GLM            [weeks 3, 4, 10]
# =============================================================================
m_main <- glm(injured ~ age + training_load + prev_injuries, family = binomial, data = p)

# Screen all two-way interactions one at a time (LRT)
base <- glm(injured ~ age + training_load + prev_injuries + position, family = binomial, data = p)
for (t in c("age:training_load", "age:prev_injuries", "training_load:prev_injuries",
            "position:training_load", "position:prev_injuries", "position:age",
            "minutes_played", "bmi")) {
  a <- anova(base, update(base, as.formula(paste(". ~ . +", t))), test = "Chisq")
  cat(sprintf("%-28s LRT = %6.2f on %d df, p = %.4f\n", t, a$Deviance[2], a$Df[2], a$`Pr(>Chi)`[2]))
}
# BIC-based stepwise search over all 2-way terms keeps ONLY age:training_load
full <- glm(injured ~ (age + training_load + prev_injuries + position + bmi + minutes_played)^2,
            family = binomial, data = p)
step(glm(injured ~ age + training_load + prev_injuries + position + bmi + minutes_played,
         family = binomial, data = p),
     scope = list(lower = ~ 1, upper = formula(full)), k = log(nrow(p)), trace = 0)

m_int <- glm(injured ~ age * training_load + prev_injuries, family = binomial, data = p)
anova(m_main, m_int, test = "Chisq")

# Raw evidence for the interaction: injury rate by age band x load band
with(p, round(tapply(injured, list(cut(age, c(16, 22, 26, 30, 37)),
                                   cut(training_load, c(0, 2, 3, 5), labels = c("1-2", "3", "4-5"))),
                     mean), 2))

# Odds ratio per +1 training load level at different ages
b <- coef(m_int); V <- vcov(m_int)
for (a in c(20, 25, 30, 34)) {
  L <- c(0, 0, 1, 0, a); est <- sum(L * b); se <- sqrt(drop(t(L) %*% V %*% L))
  cat("age", a, ": OR per load level", round(exp(c(est, est - 1.96 * se, est + 1.96 * se)), 2), "\n")
}

# Hosmer-Lemeshow-type check; goalkeeper-specific age effect as a sensitivity analysis
hl <- function(fit, y, g = 10) {
  f <- fitted(fit); bins <- cut(f, quantile(f, 0:g / g), include.lowest = TRUE)
  o <- tapply(y, bins, sum); e <- tapply(f, bins, sum); n <- table(bins)
  H <- sum((o - e)^2 / (e * (1 - e / n))); c(HL = H, p = 1 - pchisq(H, g - 2))
}
hl(m_int, p$injured)
m_int_gk <- update(m_int, . ~ . + I(position == "GK") * age)
anova(m_int, m_int_gk, test = "Chisq"); hl(m_int_gk, p$injured)

# Club effect: random intercept for team (estimated variance = 0)
glmer(injured ~ age * training_load + prev_injuries + (1 | team), family = binomial, data = p)

# =============================================================================
# CANDIDATE Q2: Ashford goals for AND against -> Poisson log-linear  [weeks 5, 8-10]
# =============================================================================
# Stack the data: one row per (match, side), 92 rows
long <- rbind(
  data.frame(match = 1:46, goals = m$goals_scored,   side = "for",     home = m$home_away, rank = m$opponent_rank),
  data.frame(match = 1:46, goals = m$goals_conceded, side = "against", home = m$home_away, rank = m$opponent_rank))
long$side <- factor(long$side, levels = c("against", "for"))
g_full <- glm(goals ~ side * (home + rank), family = poisson, data = long)          # 6 parameters
# Symmetric model: home/rank effects equal and opposite for goals for vs against (4 parameters)
long$home_s <- ifelse(long$side == "for", 1, -1) * (long$home == "Home")
long$rank_s <- ifelse(long$side == "for", 1, -1) * long$rank
g_sym <- glm(goals ~ side + home_s + rank_s, family = poisson, data = long)
anova(g_sym, g_full, test = "Chisq"); AIC(g_full, g_sym)
round(exp(cbind(rate_ratio = coef(g_sym), confint(g_sym))), 3)
gof(g_sym)
# Robustness: refit without the 8-0 (home effect stays clearly > 1)
g_sym_no8 <- update(g_sym, data = subset(long, !(match %in% which(m$goals_scored == 8))))
round(exp(cbind(coef(g_sym_no8), confint(g_sym_no8))), 3)
# Compare: goals scored alone is NOT robust to the 8-0
s1 <- glm(goals_scored ~ home_away + opponent_rank, family = poisson, data = m)
s1_no8 <- update(s1, data = subset(m, goals_scored < 8))
round(cbind(all = coef(s1), without_8_0 = coef(s1_no8)), 3)
# Opponent random effect (each opponent met twice) - small
glmer(goals ~ side + home_s + rank_s + (1 | rank), family = poisson, data = long)
# Matched pairs: home vs away goal difference against the SAME opponent
gd <- with(m, goals_scored - goals_conceded)
wilcox.test(gd[m$home_away == "Home"][order(m$opponent_rank[m$home_away == "Home"])],
            gd[m$home_away == "Away"][order(m$opponent_rank[m$home_away == "Away"])],
            paired = TRUE, exact = FALSE)

# =============================================================================
# CANDIDATE Q3: training load (ordinal 1-5) -> proportional odds    [weeks 6/8, 9, 10]
# =============================================================================
p$tl <- factor(p$training_load, ordered = TRUE); p$mins1000 <- p$minutes_played / 1000
table(p$position, p$training_load)                               # contingency view
round(prop.table(table(cut(p$age, c(16, 22, 26, 30, 37)), p$training_load), 1), 2)
c_full <- clm(tl ~ position + mins1000 + age + bmi + prev_injuries, data = p)
c_red  <- clm(tl ~ position + mins1000, data = p)
anova(c_red, c_full)                                             # age, bmi, prev not needed
summary(c_red)
nominal_test(c_red)                                              # proportional-odds check
c_mix <- clmm(tl ~ position + mins1000 + (1 | team), data = p)   # club-to-club variation
summary(c_mix)
anova(c_red, c_mix)

# =============================================================================
# REJECTED candidates (kept for the record)
# =============================================================================
# prev_injuries as a count: overdispersed, excess zeros, but no covariate matters
pp <- glm(prev_injuries ~ age + position + bmi + training_load, family = poisson, data = p)
drop1(pp, test = "Chisq"); sum(residuals(pp, "pearson")^2) / df.residual(pp)
# minutes_played: plain normal linear model (week 1 material), driven by position and load
anova(lm(minutes_played ~ position + training_load + age + bmi + prev_injuries, data = p))
# match result L/D/W (ordinal): largely a re-expression of the goals analysis
summary(polr(result ~ home_away + opponent_rank, data = m, Hess = TRUE))
