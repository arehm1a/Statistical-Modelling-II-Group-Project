# =============================================================================
# q1_01_eda.R - Q1 exploratory analysis                     OWNER: Ian (B)
# Goal: show the reader WHY the model looks the way it does, before any model.
# Output: 1 figure + 1 small table for the report (more can stay in outputs/q1).
# =============================================================================
source("code/q1/q1_00_model_spec.R")

# ---- Overall and by single factors ------------------------------------------------
mean(q1$injured)                                                   # 18.5%
rate <- function(x) round(tapply(q1$injured, x, mean), 3)
rate(q1$prev_injuries); table(q1$prev_injuries)
rate(q1$training_load); table(q1$training_load)
rate(q1$position);      table(q1$position)
rate(cut(q1$age, c(16, 22, 26, 30, 37)))

# ---- KEY TABLE: injury rate by age band x load band (the interaction, raw) ------
q1$age_band  <- cut(q1$age, c(16, 22, 26, 30, 37), labels = c("17-22", "23-26", "27-30", "31-36"))
q1$load_band <- cut(q1$training_load, c(0, 2, 3, 5), labels = c("Low (1-2)", "Medium (3)", "High (4-5)"))
tab_rate <- with(q1, round(100 * tapply(injured, list(age_band, load_band), mean)))
tab_n    <- with(q1, table(age_band, load_band))
tab_rate; tab_n
write.csv(tab_rate, file.path(q1_out, "eda_rate_age_by_load.csv"))

# ---- KEY FIGURE: injury rate vs age, one line per load band ----------------------
save_png("q1/eda_age_load", {
  ages <- levels(q1$age_band); x <- seq_along(ages)
  plot(NA, xlim = c(1, 4), ylim = c(0, 0.6), xaxt = "n", xlab = "Age group",
       ylab = "Proportion injured", main = "Injury rate by age and training load")
  axis(1, at = x, labels = ages)
  for (k in 1:3) {
    lb <- levels(q1$load_band)[k]
    lines(x, tab_rate[, lb] / 100, type = "b", pch = c(1, 17, 16)[k], lty = k)
  }
  legend("topleft", levels(q1$load_band), pch = c(1, 17, 16), lty = 1:3,
         title = "Training load", bty = "n")
})

# ---- Other checks the write-up needs one sentence on ------------------------------
round(cor(q1[, c("age", "training_load", "prev_injuries", "bmi", "minutes_played")]), 2)  # no collinearity
with(q1, round(tapply(injured, list(gk = gk, age_band), mean), 2))                   # GK by age (feeds sensitivity)

# TODO (B): decide final EDA figure/table with A; keep everything else here.
