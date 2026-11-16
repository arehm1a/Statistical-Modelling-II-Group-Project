# Decision notes

Record every analytical decision: **what** was decided, **when**, **why**, and the **alternatives considered**.
Newest entries at the bottom. Mark open items as *Proposed* until the group agrees.

## Current position (keep this block up to date; the log below is the full history)

| | Question | Response / main model | Owners | Status |
|---|---|---|---|---|
| Q1 | Which player characteristics are associated with injury risk, and do these associations vary with age? | Injured (binary): binomial GLM with age x load interaction; GK x age sensitivity; club random effect check | Mahin + Ian | Agreed, in progress (`code/q1/`, `notes/q1-plan.md`) |
| Q2 | Which player characteristics are associated with training load, and do clubs differ in the training loads they set once position and playing time are taken into account? | Training load (ordinal): position x load contingency table, proportional odds model, club random effect | TBC | Wording to confirm |
| Q3 | How are venue and opponent strength associated with Ashford's goals scored and conceded, and how large is the home advantage when each opponent is used as its own control? | Goals for/against (counts): joint Poisson log-linear model; matched-pairs (opponent as own control) analysis | TBC | Agreed |

Open decisions: GK x age in Q1 (sensitivity vs final model); how to describe the low-load age effect in Q1.

## Decision log

| Date | Analysis | Decision | Why / evidence | Alternatives considered | Status |
|---|---|---|---|---|---|
| 2026-11-16 | Setup | Code reads data from `data/` with relative paths; every script sources `code/00_setup.R` | Brief requires the workspace to run as submitted on any machine | Absolute paths (rejected) | Agreed |
| 2026-11-16 | Setup | Baselines: position = DEF, home_away = Away | Largest group / natural reference | GK as baseline | Agreed (Q1 uses gk indicator; Q3 uses Away baseline) |
| 2026-11-16 | Injury | Candidate Q1: player characteristics vs injury (binomial GLM, logit) | Binary response; age, training load, previous injuries all associated in a first fit | - | Superseded: see Q1 wording row below |
| 2026-11-16 | Injury | Test training_load as numeric vs factor | Injury rate jumps between load 3 (16%) and 4 (26%) rather than rising evenly | Numeric (1 df) vs factor (4 df) via LRT | Resolved: numeric (factor not better, LRT p = 0.24) |
| 2026-11-16 | Injury | Team random effect: variance estimated at 0 in a first GLMM | Club adds nothing once player covariates are in; worth reporting as a check | Fixed team effects (23 df, wasteful) | Resolved: report as a check in Q1 (variance 0) |
| 2026-11-16 | Goals | Candidate Q2: goals scored / conceded vs venue and opponent rank (Poisson GLM, log link) | Count responses | Negative binomial if overdispersed | Superseded: goals is now Q3 |
| 2026-11-16 | Goals | The 8-0 home win vs rank 24 is highly influential for goals scored; must be discussed | Home effect p = 0.011 with it, about 0.06 without | Drop it / keep it / report both | Moved to Q3: handled by joint and matched-pairs models |
| 2026-11-16 | Result | Candidate Q3: match outcome L < D < W (proportional odds model) | Ordered categorical response (week 9) | Contingency table home_away x result | Rejected: re-expresses goals analysis |
| 2026-11-16 | Scoping | Screened every candidate response (`code/exploratory/06_question_scoping.R`) | Injury, goals for/against, result, training load, previous injuries, minutes all modelled | - | Done |
| 2026-11-16 | Injury | Add age x training_load interaction | LRT p = 0.0002; the only term kept by BIC stepwise over all 2-way terms; load OR/level 0.71 at age 20 vs 3.38 at 34 | Main effects only (misses the key finding) | Proposed |
| 2026-11-16 | Injury | GK x age as sensitivity only, not headline | Fixes HL lack of fit (p 0.003 -> 0.22) but rests on 62 goalkeepers | Include in final model | Open |
| 2026-11-16 | Goals | Model goals for and against jointly (92 rows) with symmetric home and rank effects | Full 6-parameter vs symmetric 4-parameter: LRT p = 0.99, lower AIC; home effect robust to the 8-0, unlike goals-scored-only model | Separate Poisson models | Proposed |
| 2026-11-16 | Load | Candidate Q3: training load (ordinal) via proportional odds, club random effect | Position and minutes associated, age NOT, which links to Q1 (older players not given lower loads) | Match result ordinal (rejected: re-expresses Q2) | Superseded: training load is now Q2 |
| 2026-11-16 | Rejected | prev_injuries count model; minutes linear model; match result as separate question | No covariate signal / week-1 method only / redundant with goals | - | Agreed |
| 2026-11-16 | Questions | Group agreed draft questions: Q1 injury risk + age x load; Q2 training load + does workload explain GK injury rate; Q3 venue/opponent and goals, home advantage with each opponent as its own control | Covers binary, ordinal and count responses across both datasets; weeks 3-10 | Match result ordinal; previous injuries count | Superseded: Q1 and Q2 reworded (rows below) |
| 2026-11-16 | Q2 check | GK excess injury is borderline before adjustment (OR 1.77, 0.97-3.23, p = 0.06; 17/62 injured) and barely changes after adjusting for load and minutes (about 1.65-1.71); excess concentrated in older GKs (GK x age p = 0.018) | Answer to Q2's second part is likely "no, workload does not explain it" | Reword Q2 to avoid presupposing a real GK effect | Open |
| 2026-11-16 | Q3 check | Opponent-as-own-control (conditional binomial = opponent fixed effects): home RR 1.97 (1.30, 3.00); 1.87 (1.20, 2.91) without the 8-0 pair; home advantage does not vary with opponent rank (p = 0.82) | Matched-pairs design robust to the outlier | - | Open |
| 2026-11-16 | Q2 wording | Proposed: "What is associated with a player's training load, and does training load account for differences in injury rates between goalkeepers and outfield players?" | Keeps the GK analysis (home for contingency tables / log-linear / graphical models, weeks 6 and 8) without presupposing a GK excess or stating a Q1 finding in the title; age-vs-load result reported in the text | 3-part version incl. "are older players given lighter loads" (too much for ~1 page) | Superseded: GK analysis moved to Q1 |
| 2026-11-16 | Q2 GK check | GK x load(3 bands) x injured table: model [PL][LI] (GK independent of injury given load) fits, G2 = 2.99 on 3 df, p = 0.39; adding GK-injury term p = 0.13; no 3-way term needed (p = 0.72). Crude OR 1.77 vs Mantel-Haenszel load-adjusted OR 1.62 (0.89, 2.98) | Load accounts for only a small part of the (borderline) GK excess; Q1 model locates it in older GKs | 4-position table: sparser, position-injury p = 0.41 | Superseded: GK analysis moved to Q1 (still valid evidence) |
| 2026-11-16 | Questions | Q1 reworded: "Which player characteristics are associated with injury risk, and do these associations vary with age?" GK-injury analysis moved from Q2 into Q1 (GK x age). Q2 becomes training load only (position, minutes, club variation) to remove overlap | Q1 is the single home for injury as a response | Previous Q2 incl. GK injury | Agreed (Q1 pair); Q2 wording to confirm with group |
| 2026-11-16 | Q1 setup | Q1 split into owned scripts code/q1/q1_00 (shared spec) to q1_05; report text in reports/sections/q1.Rmd reading saved outputs | Avoids git conflicts; numbers never typed by hand | One shared script | Agreed (A+B) |
| 2026-11-16 | Q1 check | Final model implies injury risk falls with age at load 1 (OR per 5 yrs 0.47, 0.23-0.98) but raw low-load rates are flat (11/14/11/8%; only 12 players 31+ on low load) | Linear-interaction extrapolation: describe as uncertain | Threshold-load model (AIC 537.0 vs 535.3) | Open |
| 2026-11-16 | Repo | Moved scripts 01-06 into code/exploratory/; code/ now holds 00_setup.R plus one folder per question (q1/, q2/, q3/) | Keeps exploratory and discarded work (brief: never delete it) while keeping the final analysis easy to find | Delete superseded scripts (rejected) | Done |
| 2026-11-16 | Repo | Tidied notes: added "Current position" summary; updated statuses of superseded decisions (rows kept, not deleted) | Notes must show how the analysis developed | Delete old rows (rejected) | Done |
