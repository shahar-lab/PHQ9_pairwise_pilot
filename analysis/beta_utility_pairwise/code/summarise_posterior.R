#### SUMMARISE POSTERIOR ####

df_u <- fit$summary("u_matrix", u_median = ~ median(.x)) |>
  mutate(idx     = str_match(variable, "u_matrix\\[(\\d+),(\\d+)\\]"),
         subject = as.integer(idx[, 2]),
         item    = as.integer(idx[, 3])) |>
  select(subject, item, u_median) |>
  left_join(df_subject_lookup, by = "subject") |>
  left_join(df_item_lookup, by = "item")

df_beta_draws <- fit$draws("beta") |>
  as_draws_df() |>
  pivot_longer(starts_with("beta"), names_to = "variable", values_to = "beta") |>
  mutate(subject = as.integer(str_extract(variable, "\\d+"))) |>
  left_join(df_subject_lookup, by = "subject") |>
  mutate(distribution = participant_id)

df_pop_beta_draws <- fit$draws("mu_log_beta") |>
  as_draws_df() |>
  mutate(beta = exp(mu_log_beta), distribution = "population median")

write_csv(df_u, file.path(artifacts_dir, "u_median_summary.csv"))
