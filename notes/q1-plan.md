# Q1 plan: player characteristics and injury risk

**Question:** Which player characteristics are associated with injury risk, and do these associations vary with age?
**Team:** Mahin (A) + Ian (B)
**Output:** about 1.1 pages of the group report (`reports/sections/q1.Rmd`), plus all code in `code/q1/`.

---

## 1. What a top-mark Q1 looks like (mapped to the marking scheme)

| Mark component | What Q1 must show |
|---|---|
| Exploratory analysis (15) | Injury rate by age band × load band (the interaction, visible in raw data); rates by previous injuries |
| Model choice, selection, fit (20) | Why binomial/logit; every keep/drop decision backed by LRT, with AIC/BIC as a cross-check; grouped goodness-of-fit (not residual deviance); influence; club random effect |
| Interpretation (30) | Odds ratios **with CIs**, in plain language; how the load effect changes with age; predicted-risk figure; Ashford squad risk; no causal language |
| Presentation and code (20) | Numbered tables/figures with captions; numbers pulled from saved outputs, never typed by hand; scripts run from a clean start |

**Headline we expect to defend:** the association between training load and injury depends on age. Per extra load level, OR 0.71 (0.47, 1.07) at age 20 vs 2.17 (1.54, 3.05) at 30 and 3.38 (1.96, 5.84) at 34. Each previous injury: OR 1.69 (1.41, 2.03).

---

## 2. Who owns what

Each person **owns** files, and only the owner edits them. The other person reviews and comments. This prevents git conflicts and gives a clean record of who did what.

| File | Owner | Purpose |
|---|---|---|
| `code/q1/q1_00_model_spec.R` | **Shared** (change only after agreeing) | Data prep, candidate formulas, final model, helpers |
| `code/q1/q1_01_eda.R` | **B** | Exploratory tables and figures |
| `code/q1/q1_02_model_selection.R` | **A** | Link choice, main effects, functional form, interactions, selection table |
| `code/q1/q1_03_diagnostics.R` | **B** | Hosmer–Lemeshow, calibration, influence, AUC |
| `code/q1/q1_04_robustness.R` | **B** | Club GLMM, GK × age, load as factor, adjusted model, low-load age check |
| `code/q1/q1_05_interpretation.R` | **A** | Odds-ratio table, predicted-risk figure, Ashford squad table |
| `reports/sections/q1.Rmd` | A writes Model + Results; B writes Data + Diagnostics | Report text |

The split balances the work: A owns the model and what it means, and B owns the evidence that it's sound. Both write report text and review each other's work. That gives both of you a clear, substantial contribution for the contribution factor.

---

## 3. Workflow

### Every working session
1. **Pull first** (VS Code: Source Control → `...` → Pull). Never start on a stale copy.
2. Work **only in your own files**.
3. Run your script from a clean R session (`source("code/q1/q1_0X_....R")`). It must finish without errors.
4. **Commit small**, with a clear message: `Q1 diagnostics: add HL test and calibration plot`.
5. **Push** before you stop.
6. Add a line to `notes/who did what.md` and any decision to `notes/decision notes.md`. Pull before editing these two shared files, and push straight after.

### Handover between A and B
- A changes the final model only in `q1_00_model_spec.R`, and only after B agrees. Write in the commit message what changed.
- B re-runs `q1_03` and `q1_04` whenever the spec changes.
- Review = read the other person's script and outputs, and leave comments as a GitHub Issue or in the group chat. Log agreed outcomes in the decision notes.

### Rules that protect the mark
- **Never delete code.** Discarded models stay, with a comment saying why they were dropped.
- **No hand-typed numbers in the report.** Scripts write CSVs/PNGs to `outputs/q1/`, and `q1.Rmd` reads them.
- **No individual-report data** (shots on target / possession) anywhere in the repo.
- **Language:** "is associated with", never "causes", "leads to" or "increases risk of".

---

## 4. Stages and checklists

### Stage 1: Exploratory analysis (B, A reviews)
- [ ] Injury rate by previous injuries, load, position, age band (`q1_01`)
- [ ] Key table: rate by age band × load band, with cell counts
- [ ] Key figure: injury rate vs age group, one line per load band
- [ ] Correlations between covariates (no collinearity issue)
- [ ] Choose ONE figure or table for the report with A

### Stage 2: Model selection (A, B reviews)
- [ ] Justify binomial GLM + logit (binary response, odds ratios); link comparison by AIC
- [ ] Main effects: drop BMI, minutes, position (joint LRT p ≈ 0.69); record each in decision notes
- [ ] Functional form: load and previous injuries linear vs factor; age quadratic
- [ ] Pre-specified age interactions: age × load (LRT p = 0.0002) kept; others not
- [ ] BIC search confirms only age × load is kept
- [ ] Selection table saved (`outputs/q1/model_selection.csv`)

### Stage 3: Fit and robustness (B, A reviews)
- [ ] Hosmer–Lemeshow with 10 groups, plus 5/8/12 groups as a robustness check; AUC ≈ 0.72
- [ ] Calibration plot with error bars; influence plot; refit without the top 5 Cook's distance
- [ ] Club random effect: variance ≈ 0, so fixed effects are unchanged
- [ ] GK × age: improves fit (HL p 0.003 → 0.22) but rests on 62 goalkeepers. **Agree as a group:** report as sensitivity, or include in the final model?
- [ ] Low-load age effect: raw rates are flat (11/14/11/8%), so describe the model's decline at load 1 as uncertain, not as a finding
- [ ] Adding the dropped covariates back doesn't change the headline

### Stage 4: Interpretation (A, B reviews)
- [ ] Odds-ratio table: load effect at ages 20/25/30/34; age effect at loads 1/3/5; previous injuries
- [ ] Profile-likelihood CIs as a cross-check of the Wald CIs
- [ ] Predicted-risk figure with CI bands
- [ ] Ashford squad risk table (highest-risk players; predicted vs observed squad rate)
- [ ] Plain-language paragraph for the executive summary (2–3 sentences)

### Stage 5: Write-up (both)
- [ ] **Data** (B): 3–4 sentences + one table/figure
- [ ] **Model and justification** (A): one short paragraph + selection table
- [ ] **Results** (A): interpretation with CIs + predicted-risk figure
- [ ] **Diagnostics** (B): HL, calibration, influence, club effect, GK sensitivity, in about 5 sentences
- [ ] Swap and edit each other's text; check every number against the outputs
- [ ] Section fits in ~1.1 pages; figures are combined where possible (e.g. a 2-panel figure)

### Stage 6: Final checks (both)
- [ ] Fresh R session → `rmarkdown::render("reports/group_report.Rmd", knit_root_dir = getwd())` runs end to end
- [ ] Every table/figure is numbered, captioned and referenced in the text
- [ ] Contribution entries for A and B in `who did what.md` are accurate and specific

---

## 5. Report budget for Q1 (~1.1 pages)
| Part | Space |
|---|---|
| Data + EDA figure/table | ~0.25 page |
| Model + selection table | ~0.25 page |
| Results + OR table + predicted-risk figure | ~0.4 page |
| Diagnostics | ~0.2 page |

Most likely cut if space is short: drop the selection table and state it in one sentence.

---

## 6. Open analytical decisions (log the outcomes in decision notes)
1. GK × age: sensitivity analysis or part of the final model?
2. Training load: numeric (1 df, current choice) vs factor. The factor version isn't significantly better (p ≈ 0.24).
3. How to present the low-load age effect (flat in raw data; model extrapolation).
4. Whether to centre age at 25 and load at 3 in reported coefficients (current spec), so main effects read at a typical player.
