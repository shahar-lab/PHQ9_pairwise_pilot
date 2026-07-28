#### SUMMARISE POSTERIOR ####

df_u_draws <- fit$draws("u_matrix") |>
  as_draws_df() |>
  pivot_longer(starts_with("u_matrix"), names_to = "variable", values_to = "u") |>
  mutate(idx     = str_match(variable, "u_matrix\\[(\\d+),(\\d+)\\]"),
         subject = as.integer(idx[, 2]),
         item    = as.integer(idx[, 3])) |>
  select(subject, item, u)

df_beta_draws <- fit$draws("beta") |>
  as_draws_df() |>
  pivot_longer(starts_with("beta"), names_to = "variable", values_to = "beta") |>
  mutate(subject = as.integer(str_extract(variable, "\\d+"))) |>
  left_join(df_subject_lookup, by = "subject") |>
  mutate(distribution = participant_id)

df_pop_beta_draws <- fit$draws("mu_log_beta") |>
  as_draws_df() |>
  mutate(beta = exp(mu_log_beta), distribution = "population median")

df_tau_draws <- fit$draws("tau") |>
  as_draws_df() |>
  pivot_longer(starts_with("tau"), names_to = "variable", values_to = "tau") |>
  mutate(subject = as.integer(str_extract(variable, "\\d+"))) |>
  left_join(df_subject_lookup, by = "subject") |>
  mutate(distribution = participant_id)

# tau ~ normal(mu_tau, sigma_tau) is already on the natural scale, so the
# population value is mu_tau directly - no log/exp transform needed (unlike beta).
df_pop_tau_draws <- fit$draws("mu_tau") |>
  as_draws_df() |>
  mutate(tau = mu_tau, distribution = "population median")
