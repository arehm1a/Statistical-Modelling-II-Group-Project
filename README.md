# Statistical-Modelling-II-Group-Project

MTH6134 Statistical Modelling II (QMUL, 2026/27) group project: a statistical analysis of the
fictional Midland Premier League 2023/24 season for Ashford United FC.
**Deadline: 23:59, 6 January 2027.**

## Folder layout
| Folder | Contents |
|---|---|
| `data/` | `league_players.csv` (620 players, 24 clubs), `ashford_matches.csv` (46 Ashford matches) |
| `code/` | All R code, including rough exploratory work and discarded models |
| `outputs/` | Plots and outputs (kept even if not used in the report) |
| `notes/` | `decision notes.md` (analytical decisions + reasons) and `who did what.md` |
| `reports/` | `group_report.Rmd` (knits to the final PDF) and final reports |
| `Project brief and writing tips/` | Briefs from QM+ |

## How to run
1. Open this folder in VS Code (or RStudio) so the working directory is the project root.
2. In R: `source("code/00_setup.R")` (installs any missing packages, loads both datasets).
3. Run any script, e.g. `source("code/q1/q1_05_interpretation.R")`. Plots and tables are saved to `outputs/`.
4. Build the report: `rmarkdown::render("reports/group_report.Rmd", knit_root_dir = getwd())`.

All paths are relative, so the project runs on any machine as submitted.

## Code layout
| Path | Purpose |
|---|---|
| `code/00_setup.R` | Shared: packages, data loading, factor baselines, helper functions (every script uses it) |
| `code/q1/` | Q1 injury risk: `q1_00_model_spec.R` (shared spec) then `q1_01`–`q1_05` (see `notes/q1-plan.md`) |
| `code/q2/`, `code/q3/` | To be created by the Q2 and Q3 owners, same pattern |
| `code/exploratory/` | Early exploration, first models and the question-scoping evidence. Kept on purpose: discarded work is part of the record |

## Group rules of thumb
- Commit little and often, with clear messages: the history is our record of who did what.
- Never delete exploratory code; move it or comment why it was abandoned.
- Log every analytical decision in `notes/decision notes.md` the same day.
- Individual-report work (shots on target / possession data) stays **out** of this repo.
