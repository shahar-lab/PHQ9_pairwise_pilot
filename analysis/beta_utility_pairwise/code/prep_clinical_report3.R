#### PREP CLINICAL REPORT 3 ####

u_draws_mat    <- fit$draws("u_matrix", format = "draws_matrix")
beta_draws_mat <- fit$draws("beta", format = "draws_matrix")
n_items        <- nrow(df_item_lookup)
tier_threshold <- 0.90

severity_bands <- tibble(
  band  = c("Minimal", "Mild", "Moderate", "Moderately severe", "Severe"),
  lower = c(0, 9, 17, 25, 34),
  upper = c(8, 16, 24, 33, 45))

df_severity <- df_likert |>
  filter(item <= n_items) |>
  group_by(participant_id) |>
  summarise(likert_total = sum(likert_response),
            total_se     = sqrt(n_items * var(likert_response)),
            .groups = "drop") |>
  rowwise() |>
  mutate(band = severity_bands$band[likert_total >= severity_bands$lower &
                                      likert_total <= severity_bands$upper]) |>
  ungroup()

df_item_short <- tibble(
  item = 1:15,
  item_short = c("Little interest", "Feeling down", "Hopeless", "Insomnia",
                 "Oversleeping", "Fatigue", "Poor appetite", "Overeating",
                 "Bad about self", "Feeling a failure", "Let self down",
                 "Let family down", "Concentration", "Slowed down",
                 "Restless"))

df_tiers <- map_dfr(df_subject_lookup$subject, function(s) {
  U      <- u_draws_mat[, sprintf("u_matrix[%d,%d]", s, seq_len(n_items))]
  ord    <- order(apply(U, 2, median), decreasing = TRUE)
  Uo     <- U[, ord]
  p_next <- sapply(seq_len(n_items - 1), function(k) mean(Uo[, k] > Uo[, k + 1]))
  ranks  <- t(apply(Uo, 1, function(x) rank(-x)))
  tibble(subject  = s,
         item     = ord,
         position = seq_len(n_items),
         tier     = cumsum(c(1, as.integer(p_next >= tier_threshold))),
         rank_lo  = apply(ranks, 2, quantile, 0.05, type = 1),
         rank_hi  = apply(ranks, 2, quantile, 0.95, type = 1))
})

df_ladder3 <- df_u_hdi |>
  left_join(df_tiers, by = c("subject", "item")) |>
  left_join(df_severity, by = "participant_id") |>
  left_join(df_item_short, by = "item")

df_consistency3 <- map_dfr(df_subject_lookup$subject, function(s) {
  trials     <- df |> filter(subject == s)
  u_left     <- u_draws_mat[, sprintf("u_matrix[%d,%d]", s, trials$left_item)]
  u_right    <- u_draws_mat[, sprintf("u_matrix[%d,%d]", s, trials$right_item)]
  beta_s     <- as.numeric(beta_draws_mat[, sprintf("beta[%d]", s)])
  cons_draws <- rowMeans(plogis(beta_s * abs(u_left - u_right)))
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

df_header3 <- map_dfr(df_subject_lookup$participant_id, function(pid) {
  cons <- df_consistency3 |> filter(participant_id == pid)
  sev  <- df_severity |> filter(participant_id == pid)

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
    minimal_note), collapse = "\n"))
})
