#### PREPARE STAN DATA ####

df_likert   <- read_csv(file.path(data_path, "likert_processed.csv"), show_col_types = FALSE)
df_pairwise <- read_csv(file.path(data_path, "pairwise_processed.csv"), show_col_types = FALSE)

df <- df_pairwise |> filter(!skipped, window_status == "ok")

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

stan_data <- list(
  N_trials    = nrow(df),
  N_subjects  = nrow(df_subject_lookup),
  N_options   = max(item_ids),
  subject     = df$subject,
  offer_A     = df$left_item,
  offer_B     = df$right_item,
  is_choice_A = as.integer(df$chosen_side == "left")
)
