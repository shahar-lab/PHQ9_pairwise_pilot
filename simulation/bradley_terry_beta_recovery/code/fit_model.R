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

fit$save_object(file.path(artifacts_dir, "bradley_terry_beta_recovery_fit.rds"))

diagnostics <- fit$diagnostic_summary()
saveRDS(diagnostics, file.path(artifacts_dir, "diagnostic_summary.rds"))

print(diagnostics)
