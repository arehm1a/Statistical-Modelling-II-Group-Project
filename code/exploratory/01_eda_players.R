# =============================================================================
# 01_eda_players.R - exploratory analysis of league_players.csv
# Data brief weeks 2-3: summaries, plots, variable types, natural responses.
# =============================================================================
source("code/00_setup.R")

# ---- Variable types -------------------------------------------------------------
# team          : categorical (24 clubs)          -> grouping factor (random effect?)
# position      : categorical (GK/DEF/MID/FWD)
# age           : continuous
# minutes_played: continuous (bounded above by 46 x 90 = 4140)
# training_load : ordinal 1-5 (treat as numeric OR factor - a decision to test)
# prev_injuries : count 0-4
# bmi           : continuous
# injured       : binary (natural response)
str(players)
summary(players)

# ---- Response: injured -----------------------------------------------------------
mean(players$injured)                                   # overall injury rate
prop_by <- function(v) round(tapply(players$injured, players[[v]], mean), 3)
for (v in c("position", "training_load", "prev_injuries")) {
  cat("\nInjury rate by", v, "\n"); print(prop_by(v)); print(table(players[[v]]))
}

# Team-level variation (is a random effect worth it later?)
team_rate <- sort(tapply(players$injured, players$team, mean))
round(team_rate, 2)
chisq.test(table(players$team, players$injured))        # small expected counts -> treat with care

# ---- Plots -------------------------------------------------------------------------
save_png("players_injury_rates", {
  par(mfrow = c(2, 2))
  barplot(prop_by("prev_injuries"), main = "Injury rate by previous injuries",
          xlab = "Previous injuries (3 prior seasons)", ylab = "Proportion injured")
  barplot(prop_by("training_load"), main = "Injury rate by training load",
          xlab = "Training load (1 = low, 5 = high)", ylab = "Proportion injured")
  barplot(prop_by("position"), main = "Injury rate by position", ylab = "Proportion injured")
  boxplot(age ~ injured, data = players, names = c("Not injured", "Injured"),
          main = "Age by injury status", ylab = "Age (years)", xlab = "")
})

save_png("players_continuous", {
  par(mfrow = c(1, 3))
  hist(players$age, main = "Age", xlab = "Years")
  hist(players$minutes_played, main = "Minutes played", xlab = "Minutes")
  hist(players$bmi, main = "BMI", xlab = "BMI")
})

# Possible confounding: do covariates move together?
round(cor(players[, c("age", "minutes_played", "training_load", "prev_injuries", "bmi")]), 2)
round(tapply(players$minutes_played, players$position, mean))
