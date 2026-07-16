#### BUILD ITEM CODE -> INTEGER LOOKUP ####

data_raw_file <- file.path(raw_dir, "data_raw.csv")
data_raw <- read_csv(data_raw_file, show_col_types = FALSE, guess_max = Inf)

item_order <- c(
  "1", "2a", "2b", "3a", "3b", "4", "5a", "5b",
  "6a", "6b", "6c", "6d", "7", "8a", "8b", "attn_check"
)

item_text_lookup <- data_raw |>
  filter(!is.na(phase) & phase == "likert") |>
  distinct(item_code = item_number, item_text)

item_lookup <- tibble(item_code = item_order) |>
  left_join(item_text_lookup, by = "item_code") |>
  mutate(item = row_number())

write_csv(item_lookup, file.path(raw_dir, "item_lookup.csv"))

cat("Saved item lookup (", nrow(item_lookup), "items ) to",
    file.path(raw_dir, "item_lookup.csv"), "\n")
