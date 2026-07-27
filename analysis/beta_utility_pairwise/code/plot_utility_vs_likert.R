#### PLOT UTILITY VS LIKERT ####

df_fig1 <- df_u |>
  inner_join(df_likert |> select(participant_id, item, likert_response),
             by = c("participant_id", "item"))

df_tags <- df_fig1 |>
  distinct(participant_id) |>
  arrange(participant_id) |>
  mutate(tag = LETTERS[row_number()])

p_fig1 <- ggplot(df_fig1, aes(x = u_median, y = likert_response)) +
  geom_point(colour = "#4477AA", alpha = 0.75, size = 2) +
  geom_text(data = df_tags, aes(label = tag), x = -Inf, y = Inf,
            hjust = -0.5, vjust = 1.5, fontface = "bold", size = 5,
            inherit.aes = FALSE) +
  facet_wrap(~ participant_id) +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank(),
        axis.line  = element_line(colour = "grey30")) +
  labs(x = "median posterior utility (u)", y = "likert response")

ggsave(file.path(output_dir, "utility_vs_likert.pdf"), plot = p_fig1,
       width = 10, height = 8, bg = "white")
ggsave(file.path(output_dir, "utility_vs_likert.png"), plot = p_fig1,
       width = 10, height = 8, dpi = 300, bg = "white")
