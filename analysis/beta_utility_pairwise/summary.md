# Analysis Notebook: Beta-Utility Bradley-Terry Model (Pairwise PHQ Pilot)

**Model:** `models/bradley_terry_model/beta_utility.stan` (hierarchical Bradley-Terry with subject-level utilities and choice sensitivity beta)
**Date Created:** 2026-07-16

## 1. Hypotheses
* Posterior item utilities recovered from pairwise choices should track participants' likert responses to the same PHQ items.
* Item-level utility should predict the empirical rate at which an item is chosen when offered.

## 2. Data & Stan Structure
* Reads `data/processed/pairwise_processed.csv` and `data/processed/likert_processed.csv` (no data copied locally).
* Trials with `skipped == TRUE` or `window_status != "ok"` are excluded (in the current data all 411 trials pass).
* `subject` = 1..4 alphabetical index of `participant_id` (lookup saved to `artifacts/subject_lookup.csv`).
* Items 1..15 are contiguous in the pairwise data; `N_options = 15` (lookup with PHQ text saved to `artifacts/item_lookup.csv`). Likert item 16 has no pairwise counterpart and drops from joins.
* `offer_A = left_item`, `offer_B = right_item`, `is_choice_A = 1` when `chosen_side == "left"`.
* Sampling: cmdstanr, 4 chains, 1000 warmup / 1000 sampling; fit saved to `artifacts/beta_utility_fit.rds`.

## 3. Figures (output/)
* `utility_vs_likert` — per-participant panels: median posterior utility of each item vs. that participant's likert response.
* `beta_posteriors` — subject-level beta posteriors plus the population median beta, `exp(mu_log_beta)` (via /plot-posterior skill).
* `utility_vs_choice_rate` — one point per item: median posterior utility (averaged across participants) vs. pooled empirical choice rate (chosen / presented), labeled by PHQ text.

## 4. Findings / Summary
* (Fill in after inspection; see sampling diagnostics printed by `fit_model.R`.)
