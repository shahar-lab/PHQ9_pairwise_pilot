#### LOAD PROLIFIC EXPORT ####

demographic_file <- list.files(
  collected_dir,
  pattern    = "^prolific_demographic_export.*\\.csv$",
  full.names = TRUE
)

prolific_export <- read_csv(demographic_file, show_col_types = FALSE)

participant_key <- read_csv(
  file.path(raw_dir, "data_raw.csv"),
  show_col_types = FALSE,
  guess_max      = Inf
) |>
  distinct(participant_id, prolific_pid)

#### BUILD DEMOGRAPHICS ####

demographics_raw <- prolific_export |>
  select(
    prolific_pid         = `Participant id`,
    age                  = Age,
    sex                  = Sex,
    ethnicity_simplified = `Ethnicity simplified`,
    country_of_residence = `Country of residence`,
    student_status       = `Student status`,
    employment_status    = `Employment status`,
    time_taken           = `Time taken`
  ) |>
  inner_join(participant_key, by = "prolific_pid") |>
  select(participant_id, prolific_pid, everything()) |>
  arrange(participant_id)

demographics_file <- file.path(raw_dir, "demographics_raw.csv")
write_csv(demographics_raw, demographics_file)

#### VALIDATION SUMMARY ####

unmatched_pid <- setdiff(prolific_export$`Participant id`, participant_key$prolific_pid)
missing_task_demographics <- setdiff(participant_key$participant_id, demographics_raw$participant_id)

cat("demographics_raw.csv:", nrow(demographics_raw), "participants of",
    nrow(prolific_export), "Prolific submissions\n")
cat("Prolific submissions with no session data:", length(unmatched_pid), "\n")
cat("Session participants with no demographics:", length(missing_task_demographics), "\n")
print(colSums(is.na(demographics_raw)))
