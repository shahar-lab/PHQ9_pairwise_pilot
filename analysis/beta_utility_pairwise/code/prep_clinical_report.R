#### PREP CLINICAL REPORT DATA ####

df_u_draws <- fit$draws("u_matrix") |>
  as_draws_df() |>
  pivot_longer(starts_with("u_matrix"), names_to = "variable", values_to = "u") |>
  mutate(idx     = str_match(variable, "u_matrix\\[(\\d+),(\\d+)\\]"),
         subject = as.integer(idx[, 2]),
         item    = as.integer(idx[, 3])) |>
  select(subject, item, u)

df_u_hdi <- df_u_draws |>
  group_by(subject, item) |>
  median_hdi(u, .width = 0.90) |>
  ungroup() |>
  left_join(df_subject_lookup, by = "subject") |>
  left_join(df_item_lookup, by = "item") |>
  left_join(df_likert |> select(participant_id, item, likert_response),
            by = c("participant_id", "item")) |>
  mutate(hdi_label = sprintf("[%.2f, %.2f]", .lower, .upper))

df_rt <- df |>
  left_join(df_u |> select(participant_id, item, u_left = u_median),
            by = c("participant_id", "left_item" = "item")) |>
  left_join(df_u |> select(participant_id, item, u_right = u_median),
            by = c("participant_id", "right_item" = "item")) |>
  mutate(abs_du = abs(u_left - u_right))
