#### PREPARE STAN DATA ####

df_likert   <- read_csv(file.path(data_path, "likert_processed.csv"), show_col_types = FALSE)
df_pairwise <- read_csv(file.path(data_path, "pairwise_processed.csv"), show_col_types = FALSE)

# Keep every trial except the one flagged window_status == "left": participant
# p3j7wasb's trial 96 lost window focus mid-trial (18s RT) yet still logged a
# choice - a likely focus-loss artifact, not a genuine response. Genuine
# skipped == TRUE trials are kept and coded as choice = 3 (None) below, so tau
# is estimated from real non-response/avoidance behaviour.
df <- df_pairwise |> filter(window_status != "left")

df_subject_lookup <- df |>
  distinct(participant_id) |>
  arrange(participant_id) |>
  mutate(subject = row_number())

df <- df |> left_join(df_subject_lookup, by = "participant_id")

item_ids <- sort(union(df$left_item, df$right_item))
stopifnot(identical(as.integer(item_ids), seq_along(item_ids)))

df_item_lookup <- bind_rows(
  df |> select(item = left_item, item_phq_text = left_item_phq_text),
  df |> select(item = right_item, item_phq_text = right_item_phq_text)
) |>
  distinct() |>
  arrange(item)

write_csv(df_subject_lookup, file.path(artifacts_dir, "subject_lookup.csv"))
write_csv(df_item_lookup, file.path(artifacts_dir, "item_lookup.csv"))

# Stan's categorical_logit choice coding: 1 = A (left), 2 = B (right), 3 = None (skip).
df <- df |>
  mutate(choice = case_when(
    chosen_side == "left"  ~ 1L,
    chosen_side == "right" ~ 2L,
    chosen_side == "skip"  ~ 3L
  ))

stan_data <- list(
  N_trials   = nrow(df),
  N_subjects = nrow(df_subject_lookup),
  N_options  = max(item_ids),
  subject    = df$subject,
  offer_A    = df$left_item,
  offer_B    = df$right_item,
  choice     = df$choice
)
