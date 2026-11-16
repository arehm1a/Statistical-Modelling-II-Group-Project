# Who did what

Running record of each member's contribution (analysis, modelling, code, writing, coordination).
Keep entries specific and dated. This feeds the one-page Group Contribution Summary.

| Date | Member | What they did | Where (files / commits) |
|---|---|---|---|
| 2026-10-09 | arehm1a | Created the GitHub repository and folder structure (code, outputs, notes, reports) | Repo history |
| 2026-11-11 | arehm1a | Uploaded the project brief, data brief and writing tips | `Project brief and writing tips/` |
| 2026-11-16 | Mahin | Set up the R / VS Code project: shared data in `data/`, setup script, starter exploratory scripts for both datasets, starter model scripts for three candidate questions, report template (R Markdown). AI-assisted (Claude) | `code/00_setup.R`, `code/exploratory/01-05`, `data/`, `reports/group_report.Rmd`, `.vscode/` |
| 2026-11-16 | Mahin | Screened every candidate response with Ian in both datasets to compare possible questions (injury, goals, result, training load, previous injuries, minutes); found the age x training load interaction. | `code/exploratory/06_question_scoping.R`, decision notes |
| 2026-11-16 | Mahin | Checked the group's draft questions with Ian: tested the GK premise in Q2 (contingency tables / log-linear models) and the matched-pairs design in Q3; proposed rewording to remove Q1/Q2 overlap | decision notes |
| 2026-11-16 | Mahin | Set up the Q1 workstream with Ian: plan and file ownership (`notes/q1-plan.md`), shared model spec, script structure, report section `reports/sections/q1.Rmd`, auto-generated code appendix; drafted model-selection (q1_02) and interpretation (q1_05) scripts. AI-assisted (Claude) | `code/q1/`, `notes/q1-plan.md`, `reports/` |
| 2026-11-16 | Mahin | Reorganised `code/` (shared setup + one folder per question + `exploratory/`); updated READMEs and decision notes | `code/`, `README.md`, `notes/` |
| 2026-11-16 | Ian | Set up local environment: cloned the repo, configured Git, installed R packages via `code/00_setup.R`; confirmed the setup and `code/q1/q1_01_eda.R` run without errors. AI-assisted (Claude) | `notes/who did what.md` |
