#### PREPARE DATA ####

df_likert   <- read_csv(file.path(data_path, "likert_processed.csv"), show_col_types = FALSE)
df_pairwise <- read_csv(file.path(data_path, "pairwise_processed.csv"), show_col_types = FALSE)

df_pairwise <- df_pairwise |> filter(!skipped)

df_presented <- df_pairwise |>
  pivot_longer(c(left_item, right_item), values_to = "item") |>
  count(participant_id, item, name = "n_presented")

df_chosen <- df_pairwise |>
  count(participant_id, chosen_item, name = "n_chosen") |>
  rename(item = chosen_item)

df <- df_presented |>
  left_join(df_chosen, by = c("participant_id", "item")) |>
  mutate(n_chosen = replace_na(n_chosen, 0),
         choice_proportion = n_chosen / n_presented) |>
  inner_join(df_likert |> select(participant_id, item, likert_response),
             by = c("participant_id", "item"))

stopifnot(!anyNA(df$choice_proportion), !anyNA(df$likert_response))
