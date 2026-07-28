#### FILTER DEMOGRAPHICS TO THE ANALYZED SAMPLE ####

demographics_raw <- read_csv(file.path(raw_dir, "demographics_raw.csv"), show_col_types = FALSE)

retained_participants <- read_csv(
  file.path(processed_dir, "likert_processed.csv"),
  show_col_types = FALSE
) |>
  distinct(participant_id) |>
  pull(participant_id)

demographics_processed <- demographics_raw |>
  filter(participant_id %in% retained_participants) |>
  mutate(
    sex                  = factor(sex),
    ethnicity_simplified = factor(ethnicity_simplified),
    country_of_residence = factor(country_of_residence),
    student_status       = factor(student_status),
    employment_status    = factor(employment_status),
    time_taken_min       = round(time_taken / 60, 1)
  ) |>
  arrange(participant_id)

write_csv(demographics_processed, file.path(processed_dir, "demographics_processed.csv"))

#### VALIDATION SUMMARY ####

cat("demographics:", nrow(demographics_raw), "->", nrow(demographics_processed),
    "participants (", nrow(demographics_raw) - nrow(demographics_processed), "excluded )\n")
cat("age: M =", round(mean(demographics_processed$age), 1),
    ", SD =", round(sd(demographics_processed$age), 1),
    ", range", min(demographics_processed$age), "-", max(demographics_processed$age), "\n")
print(count(demographics_processed, sex))
print(count(demographics_processed, ethnicity_simplified))
