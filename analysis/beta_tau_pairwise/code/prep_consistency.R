#### PREP CLINICAL REPORT: CONSISTENCY + HEADER ####

# Choice consistency: for each trial and posterior draw, evaluate the 3-way
# softmax (A / B / None) at whichever outcome the participant actually chose,
# then average across trials (per draw) and summarise across draws. This
# replaces the binary plogis(beta * abs(u_left - u_right)) formula, which does
# not generalise to the 3-way categorical likelihood.
df_consistency <- map_dfr(df_subject_lookup$subject, function(s) {
  trials  <- df |> filter(subject == s)
  u_left  <- u_draws_mat[, sprintf("u_matrix[%d,%d]", s, trials$left_item)]
  u_right <- u_draws_mat[, sprintf("u_matrix[%d,%d]", s, trials$right_item)]
  beta_s  <- as.numeric(beta_draws_mat[, sprintf("beta[%d]", s)])
  tau_s   <- as.numeric(tau_draws_mat[, sprintf("tau[%d]", s)])

  exp_A    <- exp(beta_s * u_left)
  exp_B    <- exp(beta_s * u_right)
  exp_none <- exp(tau_s)
  denom    <- exp_A + exp_B + exp_none

  prob_chosen <- matrix(NA_real_, nrow = nrow(u_left), ncol = ncol(u_left))
  for (t in seq_len(ncol(u_left))) {
    prob_chosen[, t] <- switch(trials$choice[t],
                               exp_A[, t] / denom[, t],
                               exp_B[, t] / denom[, t],
                               exp_none  / denom[, t])
  }

  cons_draws <- rowMeans(prob_chosen)
  tibble(subject     = s,
         consistency = median(cons_draws),
         cons_lo     = quantile(cons_draws, 0.05),
         cons_hi     = quantile(cons_draws, 0.95))
}) |>
  left_join(df_subject_lookup, by = "subject") |>
  mutate(verdict = case_when(
    consistency < 0.70 ~ "low - choices near random; rely on severity score and interview",
    consistency < 0.85 ~ "moderate - broad tiers informative, exact positions less so",
    TRUE               ~ "high - ordering can be discussed with confidence"))

write_csv(df_consistency |> select(participant_id, consistency, cons_lo, cons_hi, verdict),
          file.path(artifacts_dir, "consistency_summary.csv"))

df_header <- map_dfr(df_subject_lookup$participant_id, function(pid) {
  cons <- df_consistency |> filter(participant_id == pid)
  sev  <- df_severity |> filter(participant_id == pid)
  thr  <- df_threshold |> filter(participant_id == pid)

  minimal_note <- if (sev$band == "Minimal")
    "Note: minimal overall burden - ladder shows relative ranking only" else
      NULL

  tibble(participant_id = pid, header_text = paste(c(
    paste0("Participant ", pid),
    "",
    paste0("Overall severity: ", toupper(sev$band),
           "  (likert total ", sev$likert_total, "/45)"),
    paste0("Choice consistency: ", sprintf("%.0f%%", cons$consistency * 100),
           " - ", cons$verdict),
    paste0("Burden threshold: ", thr$n_above, " of ", n_items,
           " symptoms clear it [", thr$n_above_lo, "-", thr$n_above_hi, "]",
           " - ", thr$verdict),
    minimal_note), collapse = "\n"))
})
