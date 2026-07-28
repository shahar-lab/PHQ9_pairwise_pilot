# Simulation: Bradley-Terry Beta Parameter Recovery

**Model:** `models/bradley_terry_beta/` (hierarchical Bradley-Terry with subject-level standardized utilities and lognormal beta)
**Date Created:** 2026-07-25

## 1. Purpose

Parameter-recovery study for the Bradley-Terry Beta model: simulate choice data from known ground-truth
utilities and inverse temperatures, fit the model in Stan via cmdstanr, and check whether the posterior
means recover the true generating parameters.

## 2. Design

* N_subjects = 20, N_options (Noffer) = 15, N_trials per subject = 200 (4000 trials total).
* Ground-truth group-level hyperparameters (fixed, not randomly drawn): `mu_log_beta = 0`, `sigma_log_beta = 0.3`.
* Per-subject true utilities: `rnorm(N_options)` standardized to mean 0 / sd 1 per subject (matches the
  `u_matrix` standardization performed in the Stan model's `transformed parameters` block).
* Per-subject true beta: `rlnorm(N_subjects, meanlog = mu_log_beta, sdlog = sigma_log_beta)`.
* No `set.seed()` used anywhere, per explicit user instruction -- results will differ slightly on re-run.
* Sampling: `chains = 4`, `parallel_chains = 4`, `iter_warmup = 1000`, `iter_sampling = 1000`, `refresh = 500`.

## 3. Findings / Summary

`main.R` ran to completion. Total sampling time ~155 seconds across 4 chains.

Note: `code/generate_truth.R` and `code/simulate_data.R` were merged into a single `code/simulated_data.R`
(parameters defined first, then simulation), with the study-design constants moved in from `main.R`. This
re-run also fixed a discrepancy caught during the merge: `main.R` had hardcoded `sigma_log_beta <- 1`,
which does not match the approved/documented design value of `0.3` used below -- an earlier run against
the buggy value of 1 is superseded by these results.

### Recovery (Pearson r) -- latest run

* **Utility (u_matrix), 300 points (20 subjects x 15 options):** r = 0.874 -- strong recovery.
* **Beta, 20 points:** r = 0.887 -- strong recovery.

### Diagnostics -- latest run

* **Divergences:** 0 / 4000.
* **Max treedepth hits:** 0 / 4000.
* No diagnostic flags. Earlier runs against a since-fixed `sigma_log_beta = 1` bug (not the approved
  0.3) showed divergences and a poor beta recovery; those are superseded by this run.

**Note:** no `set.seed()` is used (per instruction), so exact recovery numbers vary run to run; repeated
runs at the corrected `sigma_log_beta = 0.3` have consistently shown r > 0.85 for both parameters with
few or no divergences.

### Artifacts produced

* `artifacts/simulated_data.rds` -- simulated choice data (4000 rows).
* `artifacts/bradley_terry_beta_recovery_fit.rds` -- full cmdstanr fit object.
* `artifacts/diagnostic_summary.rds` -- `fit$diagnostic_summary()` output.
* `artifacts/recovery_comparison.rds` -- list(u = true/recovered u data frame, beta = true/recovered beta data frame).
* `output/u_recovery.pdf`, `output/u_recovery.png` -- true vs. recovered utility scatter (300 points).
* `output/beta_recovery.pdf`, `output/beta_recovery.png` -- true vs. recovered beta scatter (20 points).
