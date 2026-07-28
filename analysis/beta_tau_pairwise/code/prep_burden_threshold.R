#### PREP CLINICAL REPORT: BURDEN THRESHOLD ####

# An item beats "None" iff beta * u > tau, so u_star = tau / beta is the burden
# threshold expressed in the ladder's own utility units - it can be drawn straight
# onto panel B. Because u is standardised within person (mean 0, sd 1 across their
# 15 symptoms), u_star = 0 sits at that person's average symptom: below it the bar
# is permissive, above it selective. The headline is how many symptoms clear the
# bar, counted per draw so it inherits the posterior uncertainty of both tau and
# beta rather than being read off the medians.

df_skip_counts <- df |>
  group_by(subject) |>
  summarise(n_skip = sum(choice == 3L), n_trials = n(), .groups = "drop")

df_threshold <- map_dfr(df_subject_lookup$subject, function(s) {
  beta_s <- as.numeric(beta_draws_mat[, sprintf("beta[%d]", s)])
  tau_s  <- as.numeric(tau_draws_mat[, sprintf("tau[%d]", s)])
  U_s    <- as.matrix(u_draws_mat[, sprintf("u_matrix[%d,%d]", s, seq_len(n_items))])

  # distinct names from the tibble columns below: tibble() evaluates its
  # arguments in order, so reusing a name would summarise the scalar median
  # instead of the draws vector and silently collapse the interval.
  thr_draws <- tau_s / beta_s
  cnt_draws <- rowSums(U_s > thr_draws)

  # cnt_draws is integer-valued (a count out of 15); type = 1 keeps quantiles
  # and the median landing on an actually-observed integer rather than
  # interpolating to e.g. "8.5 of 15 symptoms"
  tibble(subject     = s,
         thr         = median(thr_draws),
         thr_lo      = unname(quantile(thr_draws, 0.05)),
         thr_hi      = unname(quantile(thr_draws, 0.95)),
         n_above     = quantile(cnt_draws, 0.50, type = 1),
         n_above_lo  = unname(quantile(cnt_draws, 0.05, type = 1)),
         n_above_hi  = unname(quantile(cnt_draws, 0.95, type = 1)),
         n_at_median = quantile(rowSums(U_s > 0), 0.50, type = 1))
}) |>
  left_join(df_subject_lookup, by = "subject") |>
  left_join(df_skip_counts, by = "subject") |>
  mutate(
    never_skipped = n_skip == 0,
    verdict = case_when(
      never_skipped ~ "never declined a pair - bar sits below every symptom, lower bound only",
      n_above >= 13 ~ "permissive - nearly every symptom clears the bar",
      n_above >= 8  ~ "balanced - concern reaches past their average symptom",
      n_above >= 4  ~ "selective - only the most burdensome symptoms clear the bar",
      TRUE          ~ "highly selective - concern confined to a few symptoms"))

write_csv(df_threshold |>
            select(participant_id, thr, thr_lo, thr_hi, n_above, n_above_lo,
                   n_above_hi, n_at_median, n_skip, n_trials, never_skipped, verdict),
          file.path(artifacts_dir, "burden_threshold_summary.csv"))
