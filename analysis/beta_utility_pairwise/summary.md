# Analysis Notebook: Bradley-Terry Beta Model (Pairwise PHQ Pilot)

**Model:** `models/bradley_terry_beta/bradley_terry_beta.stan` (hierarchical Bradley-Terry Beta model with subject-level utilities and choice sensitivity beta)
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
* `utility_vs_choice_rate` — per-participant panels: median posterior utility of each item vs. that participant's empirical choice rate (chosen / presented within their trials).
* `beta_vs_choice_prob_sd` — one point per participant: SD of model-implied choice probabilities, plogis(median beta * (median u_left - median u_right)) across that participant's trials, vs. median posterior beta.
* `clinical_report` — multi-page PDF, one page per participant: (A) item table with median utility, 90% HDI from u_matrix draws, and likert rating, sorted by utility; (B) that participant's beta posterior (/plot-posterior style); (C) trial-level absolute utility difference vs. rt with a trend line. Per-page PNGs exported alongside.
* `clinical_report2` — clinician-communicative multi-page PDF, one page per participant: (A) plain-language header (top-3 burdensome symptoms by utility, 'not a problem' items, consistency verdict); (B) symptom ladder — items sorted by median utility with 90% HDI, points colored by likert rating, zones (Major concerns / Moderate / Not a problem) anchored on likert (>=2 / 1 / 0); (C) differentiation gauge — choice consistency = mean plogis(median beta * abs utility difference) across trials, 50% = random to 100% = perfect, with threshold-based verdict (<60% low, 60-80% moderate, >80% high). Utilities are within-participant standardized (relative only); likert anchors absolute severity.
* `clinical_report3` — v3 clinician report designed jointly by a clinical-psychologist and data-scientist review (multi-page PDF + per-page PNGs, one page per participant): (A) minimal header — overall severity band, choice consistency verdict, reframing note for minimal-severity responders; (B) burden ladder — short 1-3 word item labels, sorted strictly by posterior median utility (high to low) with 90% HDI, burden tiers from a successive-difference cut on the joint posterior (boundary where P(u_(k) > u_(k+1)) >= 0.90; within-tier items treated as tied; adjacent-pair rule, not all-pairs) shown as colored background bands (red-to-blue ramp), plus a per-item likert tile strip (annotation only — likert does not drive sorting); (C) overall-depression thermometer — likert sum over the 15 pairwise items (0-45) against severity bands (PHQ-9 cutoffs rescaled x15/9: 0-8 minimal, 9-16 mild, 17-24 moderate, 25-33 moderately severe, 34-45 severe; non-validated), score marker with a normal-approximation uncertainty gradient (se = sqrt(15 * item variance)); (D) consistency gauge — full-posterior consistency (per-draw beta and u), median dot with 90% CI band, verdict bands <70% low / 70-85% moderate / >=85% high. Likert item 16 is an attention check and is excluded from the severity total.

## 4. Findings / Summary
* (Fill in after inspection; see sampling diagnostics printed by `fit_model.R`.)
