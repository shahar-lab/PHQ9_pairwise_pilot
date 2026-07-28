# Simulation Notebook: Bradley-Terry Beta Tau -- Parameter Recovery

**Model:** `models/bradley_terry_beta_tau/bradley_terry_beta_tau.stan`
**Date Created:** 2026-07-25

## 1. Hypotheses
Full parameter-recovery check for the Bradley-Terry Beta Tau model: can the hierarchical
Stan model recover per-subject utilities (u), choice sensitivity (beta), and the no-choice
burden threshold (tau) from simulated 3-way (A / B / None) choice data?

## 2. Design
* N_subjects = 20, N_options = 15, N_trials per subject = 200 (4000 trials total).
* Ground-truth group-level hyperparameters (fixed, not randomly drawn):
  `mu_log_beta = 0`, `sigma_log_beta = 0.3`, `mu_tau = 0`, `sigma_tau = 1`.
* Per-subject true utilities: `rnorm(N_options)` standardized per subject to mean 0 / sd 1.
* Per-subject true beta: `rlnorm(N_subjects, meanlog = mu_log_beta, sdlog = sigma_log_beta)`.
* Per-subject true tau: `rnorm(N_subjects, mean = mu_tau, sd = sigma_tau)`.
* No `set.seed()` used anywhere (explicit user instruction) -- each run draws fresh truth.
* Data simulated via `sim.block()` per subject, choice factor (A/B/None) recoded to
  integer 1/2/3 for Stan's `categorical_logit`.
* Fit via cmdstanr: 4 chains, parallel_chains = 4, iter_warmup = 1000, iter_sampling = 1000.
* `code/generate_truth.R` and `code/simulate_data.R` were merged into a single `code/simulated_data.R`
  (parameters defined first, then simulation) -- no behavioral change, same values as before.

## 3. Findings / Summary (latest run, post code-merge)

**Diagnostics**
* Divergent transitions: 0 / 4000
* Max treedepth hits: 0 / 4000
* E-BFMI per chain: 0.816, 0.790, 0.721, 0.792 (all comfortably > 0.2)
* Rhat: 1.00 for all group-level hyperparameters
* Group-level hyperparameters recovered close to truth: mu_log_beta ~ 0.023 (true 0),
  sigma_log_beta ~ 0.40 (true 0.3), mu_tau ~ 0.59 (true 0), sigma_tau ~ 1.27 (true 1).

**Recovery correlations (true vs. posterior-mean-recovered)**
* Utility (u), pooled across 20 subjects x 15 options (300 values): **Pearson r = 0.89**
* Beta, per-subject (20 values): **Pearson r = 0.78**
* Tau, per-subject (20 values): **Pearson r = 0.99**

No divergences and no rhat > 1.01 anywhere -- no diagnostic flags to raise. No `set.seed()` is used, so
exact numbers vary run to run; repeated runs have consistently shown clean diagnostics and strong
recovery across u, beta, and tau.

**Recovery scatter plots:** `output/u_recovery.pdf`/`.png`, `output/beta_recovery.pdf`/`.png`,
`output/tau_recovery.pdf`/`.png` (per shaharlab_plotting plot-scatter spec: coord_equal,
shared limits, 4 axis breaks, lm trend + identity line, Pearson r annotated).

**Artifacts:** simulated dataset, cmdstanr fit object, and true-vs-recovered comparison
data frames for u / beta / tau are saved to `artifacts/` as .rds.
