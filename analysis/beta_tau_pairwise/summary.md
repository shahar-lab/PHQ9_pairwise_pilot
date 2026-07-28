# Analysis Notebook: Bradley-Terry Beta-Tau Model (Pairwise PHQ Pilot, Real Data)

**Model:** `models/bradley_terry_beta_tau/bradley_terry_beta_tau.stan` (hierarchical Bradley-Terry model with subject-level utilities, choice sensitivity beta, and a subject-level no-choice/burden threshold tau)
**Date Created:** 2026-07-25

## 1. Hypotheses
* Extends `analysis/beta_utility_pairwise` (binary A/B choice) to the real 3-way choice data (A / B / None), so that genuine non-response/avoidance ("skip") trials inform a subject-level burden threshold tau rather than being discarded.
* Posterior item utilities and beta should behave consistently with the 2-choice model; tau should separate subjects who skip more/less often after accounting for utility and beta.

## 2. Data & Stan Structure
* Reads `data/processed/pairwise_processed.csv` (840 trials) and `data/processed/likert_processed.csv` (no data copied locally).
* Exactly one trial is dropped: participant `p3j7wasb`, trial 96, `window_status == "left"` (an 18s-RT trial where the window lost focus mid-trial but a choice was still logged) - judged a focus-loss artifact, not a genuine response or skip. Every other trial is kept (839 trials), including all `skipped == TRUE` trials (125 of them), which are coded `choice = 3` (None) rather than dropped.
* `choice` coding for Stan's `categorical_logit`: 1 = A (`chosen_side == "left"`), 2 = B (`chosen_side == "right"`), 3 = None (`chosen_side == "skip"`).
* `subject` = 1..8 alphabetical index of `participant_id` (lookup saved to `artifacts/subject_lookup.csv`); all 8 pilot participants are included (unlike `beta_utility_pairwise`, which only retained 4 after its stricter filter).
* Items 1..15 are contiguous in the pairwise data; `N_options = 15` (lookup with PHQ text saved to `artifacts/item_lookup.csv`). Likert item 16 is an attention check, excluded from the severity total.
* `offer_A = left_item`, `offer_B = right_item`.
* Sampling: cmdstanr, 4 chains, 1000 warmup / 1000 sampling; fit saved to `artifacts/beta_tau_fit.rds`; `fit$diagnostic_summary()` saved to `artifacts/diagnostic_summary.rds`.

## 3. Figures (output/)
* `beta_posteriors` - subject-level beta posteriors plus the population median beta, `exp(mu_log_beta)`, combined in one ggdist plot (population + all 8 subjects). Paul Tol muted palette used (9 distributions exceeds Okabe-Ito's 8-group ceiling).
* `tau_posteriors` - subject-level tau posteriors plus the population value `mu_tau` (already on the natural/normal scale, no transform), combined in one ggdist plot in the same style.
* `clinical_report` - adapted from `beta_utility_pairwise`'s v3 clinical report design (multi-page PDF + per-page PNGs, one page per participant): (A) minimal header - overall severity band, choice consistency verdict, burden threshold verdict; (B) burden ladder - items sorted by posterior median utility with 90% HDI, tiered by a successive-difference cut (P(u_(k) > u_(k+1)) >= 0.90), likert tile strip, **plus the burden threshold drawn as a dashed vertical line with its 90% CI shaded**; (C) overall-depression thermometer (likert sum, PHQ-9-rescaled severity bands); (D) consistency gauge; (E) burden threshold gauge.

* **Burden threshold (tau) - the clinician-facing transform.** Raw tau is an unbounded log-weight on the "None" option and means nothing to a clinician. Two facts make it presentable. First, an item beats "None" iff `beta * u > tau`, so **`u* = tau / beta` is a threshold expressed in the ladder's own utility units** - it can be drawn straight onto panel B, and the clinician literally sees which symptoms rise above this person's bar for "worth flagging". Second, because `u` is hard-standardised within person (mean 0, sd 1 across their 15 symptoms), **`u* = 0` is a meaningful anchor: the bar sitting exactly at that person's average symptom** - below it the person is permissive, above it selective. This is the direct analogue of 50% being the chance floor for choice consistency.
  * **Headline number:** how many of the 15 symptoms clear the bar, counted **per posterior draw** (`rowSums(u_draws > tau_draws/beta_draws)`) so it inherits the joint uncertainty of tau and beta rather than being read off the medians. Reported as median [90% CI]. Per-subject values in `artifacts/burden_threshold_summary.csv`.
  * **Why not just show P(skip):** the model-implied skip rate reproduces the *observed* skip rate almost exactly (ty6pnexp 0.526 vs 0.533; lqeojjlx 0.396 vs 0.400; pc4u2ske 0.0190 vs 0.0190), so a skip-probability gauge would restate a number obtainable by counting skips. The threshold-on-the-ladder framing instead says *which* symptoms clear the bar, which the skip count cannot.
  * **Zero-skip degradation:** `75y1tqf2` and `7v1pxg3v` never skipped, so tau is identified only as an upper bound and `u*` runs off the left of the ladder (75y1tqf2: -6.21 [-12.99, -3.28], a CI that wide because 2.5% of its beta posterior sits below 0.5 and inflates `tau/beta`). For these two the report draws **no threshold line** - panel B prints the italic note "burden threshold sits below every symptom", and the panel E gauge pins at 15 of 15 with the caveat "never declined a pair - lower bound only".
  * **Standardisation caveat:** the count is a statement about the person's *internal* ranking, not absolute severity - `ty6pnexp` has a MINIMAL likert total (5/45) yet still has 4 symptoms above their own bar. Panel B's existing caption ("positions are relative to this person's own symptoms") carries this.
* **Consistency metric (the one part that had to change from `beta_utility_pairwise`):** the binary formula `mean(plogis(beta * abs(u_left - u_right)))` does not generalise to the 3-way categorical likelihood. Replaced with: per trial and posterior draw, evaluate the 3-way softmax `{beta*u_A, beta*u_B, tau}` at whichever outcome (A/B/None) the participant actually chose (including skips), average across trials within each draw, then summarise across draws as median + 90% interval - mirroring the original's posterior-summary convention (median + 5-95% quantiles), just with the corrected trial-level formula. Per-subject values saved to `artifacts/consistency_summary.csv`.

## 4. Findings / Summary

**Sampling diagnostics (real fit, 4 chains x 1000 warmup / 1000 sampling = 4000 post-warmup draws):**
* Divergent transitions: 0 / 4000.
* Max treedepth hits: 0 / 4000.
* E-BFMI per chain: 0.756, 0.679, 0.724, 0.685 (all > 0.2, no low-energy concern).
* R-hat: max 1.008 across all 261 monitored parameters (`u_raw[6,13]`); 0 parameters with R-hat > 1.01. Group-level hyperparameters: `mu_log_beta` 1.00, `sigma_log_beta` 1.00, `mu_tau` 1.00, `sigma_tau` 1.00.
* ESS: minimum bulk-ESS 834 (`lp__`), minimum tail-ESS 1596; all substantive parameters comfortably above the 400 rule-of-thumb.
* No diagnostic flags to raise - the fit is clean.

**Group-level hyperparameter estimates (posterior mean [90% CI]):**
* `mu_log_beta` = 1.04 [0.49, 1.59] -> population median beta = exp(1.04) ~ 2.83.
* `sigma_log_beta` = 0.90 [0.56, 1.38].
* `mu_tau` = -2.30 [-3.93, -0.57] -> negative population tau means the "None" option is disfavoured on average relative to a typical item pair, consistent with skips being the minority outcome (125 / 839 trials, ~15%).
* `sigma_tau` = 3.14 [2.13, 4.44] - wide between-subject spread in skip propensity.

**Per-subject choice consistency** (posterior-mean probability assigned to the trial's actual outcome, median [90% CI]):
* `7v1pxg3v` 87% [83, 91] - high; `p3j7wasb` 94% [91, 97] - high; `s2tddlj3` 88% [84, 91] - high.
* `pc4u2ske` 84% [79, 87] - moderate; `ty6pnexp` 83% [79, 86] - moderate.
* `75y1tqf2` 62% [58, 66] - low; `lqeojjlx` 55% [51, 59] - low; `sdf2mq45` 54% [50, 58] - low.
* Full per-subject values in `artifacts/consistency_summary.csv`.

**Per-subject burden threshold** (`u* = tau/beta` in ladder units; symptoms clearing the bar, median [90% CI]):

| participant | u* | symptoms clearing bar | skips | verdict |
|---|---|---|---|---|
| `75y1tqf2` | -6.21 [-12.99, -3.28] | 15 [15, 15] | 0/105 | never declined - lower bound only |
| `7v1pxg3v` | -1.82 [-3.17, -1.19] | 15 [13, 15] | 0/105 | never declined - lower bound only |
| `pc4u2ske` | -1.40 [-2.03, -0.97] | 14 [12, 15] | 2/105 | permissive |
| `sdf2mq45` | -1.21 [-2.10, -0.68] | 13 [11, 15] | 12/105 | permissive |
| `p3j7wasb` | -0.55 [-0.86, -0.21] | 11 [11, 11] | 6/104 | balanced |
| `s2tddlj3` | -0.71 [-0.97, -0.44] | 10 [10, 12] | 7/105 | balanced |
| `lqeojjlx` | +0.34 [+0.08, +0.59] | 4 [3, 6] | 42/105 | selective |
| `ty6pnexp` | +0.77 [+0.60, +0.93] | 4 [4, 5] | 56/105 | selective |

* Only `lqeojjlx` and `ty6pnexp` have a bar sitting *above* their own average symptom (`u* > 0`) - both are the heavy skippers, and for both the threshold cleanly separates their Tier 1 (`ty6pnexp`) or Tier 1 boundary (`lqeojjlx`) from everything below it on the ladder. `p3j7wasb`'s bar falls exactly on the Tier 3/Tier 4 boundary.
* The count is genuinely uncertain for several subjects (`lqeojjlx` 4 [3, 6], `sdf2mq45` 13 [11, 15]) and must be reported with its interval - summarising the count from the *median* threshold instead of per draw collapses the interval to a point and reports false precision.
* **Review note:** Tomer's first pass caught a real bug - the "no threshold line for never-skipped participants" guard checked `thr > x_lo` (whether the *median* fell on-panel) instead of `!never_skipped`, so `7v1pxg3v` (median `u* = -1.82`, on-panel) still got a confident-looking dashed line despite tau being unidentified for it. Fixed to gate on `never_skipped` directly; `75y1tqf2` and `7v1pxg3v` now both correctly show only the italic degradation note. Also fixed on that pass: the shaded CI band was clamped to the ladder's left edge but not its right edge (could stretch the x-axis for an unseen future participant), the threshold colour `#994455` collided with panel C's "Severe" band fill, and `n_above`/its CI used the default quantile type (interpolates, can print non-integer counts) instead of `type = 1`.
