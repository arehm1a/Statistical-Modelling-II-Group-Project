# =============================================================================
# 02_eda_matches.R - exploratory analysis of ashford_matches.csv
# 46 matches: each of 23 opponents played once home, once away.
# =============================================================================
source("code/00_setup.R")

str(matches)
summary(matches)
setdiff(1:24, matches$opponent_rank)          # Ashford's own final rank

# ---- Counts: goals scored / conceded --------------------------------------------
aggregate(cbind(goals_scored, goals_conceded) ~ home_away, data = matches,
          FUN = function(x) c(mean = mean(x), var = var(x)))   # Poisson: mean ~ variance?
table(matches$goals_scored); table(matches$goals_conceded)
matches[matches$goals_scored >= 5, ]          # the 8-0: check its influence later

# ---- Result (ordinal W/D/L) ----------------------------------------------------------
table(matches$home_away, matches$result)
chisq.test(table(matches$home_away, matches$result))   # small counts -> consider fisher.test
fisher.test(table(matches$home_away, matches$result))

# ---- Plots ---------------------------------------------------------------------------
save_png("matches_goals_vs_rank", {
  par(mfrow = c(1, 2))
  cols <- ifelse(matches$home_away == "Home", "black", "grey55")
  pchs <- ifelse(matches$home_away == "Home", 16, 1)
  plot(goals_scored ~ opponent_rank, data = matches, col = cols, pch = pchs,
       xlab = "Opponent final rank (1 = best)", ylab = "Goals scored", main = "Goals scored")
  legend("topleft", c("Home", "Away"), pch = c(16, 1), col = c("black", "grey55"), bty = "n")
  plot(goals_conceded ~ opponent_rank, data = matches, col = cols, pch = pchs,
       xlab = "Opponent final rank (1 = best)", ylab = "Goals conceded", main = "Goals conceded")
})
