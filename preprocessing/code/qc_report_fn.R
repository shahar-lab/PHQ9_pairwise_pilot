#### QC REPORT FUNCTION: PER-SUBJECT TRIAL COUNTS AND RT SUMMARIES ####

qc_report <- function(df, data_type, suffix) {

  trial_counts <- df |>
    group_by(participant_id) |>
    summarise(
      n_trials         = n(),
      n_skipped        = if ("skipped" %in% names(df)) sum(skipped, na.rm = TRUE) else NA_integer_,
      n_window_aborted = sum(window_status != "ok", na.rm = TRUE),
      .groups = "drop"
    )

  rt_summary <- df |>
    group_by(participant_id) |>
    summarise(
      min_rt    = min(rt, na.rm = TRUE),
      median_rt = median(rt, na.rm = TRUE),
      mean_rt   = mean(rt, na.rm = TRUE),
      max_rt    = max(rt, na.rm = TRUE),
      sd_rt     = sd(rt, na.rm = TRUE),
      .groups = "drop"
    ) |>
    mutate(across(where(is.numeric), \(x) round(x, 0)))

  overall_rt <- df |>
    summarise(
      participant_id = "ALL",
      min_rt    = min(rt, na.rm = TRUE),
      median_rt = median(rt, na.rm = TRUE),
      mean_rt   = mean(rt, na.rm = TRUE),
      max_rt    = max(rt, na.rm = TRUE),
      sd_rt     = sd(rt, na.rm = TRUE)
    ) |>
    mutate(across(where(is.numeric), \(x) round(x, 0)))

  rt_summary <- bind_rows(rt_summary, overall_rt)

  pdf_file <- file.path(output_dir, paste0("qc_", data_type, "_", suffix, ".pdf"))
  pdf(pdf_file, width = 8.5, height = 11)

  grid.newpage()
  grid.table(trial_counts, rows = NULL)

  grid.newpage()
  grid.table(rt_summary, rows = NULL)

  dev.off()

  cat("Saved:", pdf_file, "\n")
}
