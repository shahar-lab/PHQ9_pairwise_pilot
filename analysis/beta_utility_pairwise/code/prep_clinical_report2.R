#### PREP CLINICAL REPORT 2 ####

likert_labels <- c("0" = "Not at all", "1" = "Several days",
                   "2" = "More than half the days", "3" = "Nearly every day")

df_ladder <- df_u_hdi |>
  mutate(likert_label = factor(likert_labels[as.character(likert_response)],
                               levels = likert_labels),
         zone = case_when(likert_response >= 2 ~ "Major concerns",
                          likert_response == 1 ~ "Moderate",
                          TRUE                 ~ "Not a problem"),
         zone = factor(zone, levels = c("Major concerns", "Moderate", "Not a problem")))

df_beta_median <- fit$summary("beta", beta_median = ~ median(.x)) |>
  mutate(subject = as.integer(str_extract(variable, "\\d+"))) |>
  left_join(df_subject_lookup, by = "subject") |>
  select(participant_id, beta_median)

df_consistency <- df_rt |>
  left_join(df_beta_median, by = "participant_id") |>
  mutate(p_consistent = plogis(beta_median * abs_du)) |>
  group_by(participant_id, beta_median) |>
  summarise(consistency = mean(p_consistent), .groups = "drop") |>
  mutate(verdict = case_when(
    consistency < 0.60  ~ "low differentiation - interpret ranking cautiously",
    consistency <= 0.80 ~ "moderate differentiation - ranking broadly informative",
    TRUE                ~ "high differentiation - rankings reliable"))
