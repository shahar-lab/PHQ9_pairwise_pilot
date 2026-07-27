#### FIT MODEL ####

model <- cmdstan_model(model_path)

fit <- model$sample(
  data            = stan_data,
  chains          = 4,
  parallel_chains = 4,
  iter_warmup     = 1000,
  iter_sampling   = 1000,
  refresh         = 500
)

fit$save_object(file.path(artifacts_dir, "beta_utility_fit.rds"))

print(fit$diagnostic_summary())
print(fit$summary(c("mu_log_beta", "sigma_log_beta", "beta")))
