#### PREP CLINICAL REPORT: LADDER ####

df_u_hdi <- df_u_draws |>
  group_by(subject, item) |>
  median_hdi(u, .width = 0.90) |>
  ungroup() |>
  left_join(df_subject_lookup, by = "subject") |>
  left_join(df_item_lookup, by = "item") |>
  left_join(df_likert |> select(participant_id, item, likert_response),
            by = c("participant_id", "item")) |>
  mutate(hdi_label = sprintf("[%.2f, %.2f]", .lower, .upper))

u_draws_mat    <- fit$draws("u_matrix", format = "draws_matrix")
beta_draws_mat <- fit$draws("beta", format = "draws_matrix")
tau_draws_mat  <- fit$draws("tau", format = "draws_matrix")
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

df_ladder <- df_u_hdi |>
  left_join(df_tiers, by = c("subject", "item")) |>
  left_join(df_severity, by = "participant_id") |>
  left_join(df_item_short, by = "item")
