#### PLOT UTILITY VS CHOICE RATE ####

df_presented <- df |>
  pivot_longer(c(left_item, right_item), values_to = "item") |>
  count(participant_id, item, name = "n_presented")

df_chosen <- df |>
  count(participant_id, chosen_item, name = "n_chosen") |>
  rename(item = chosen_item)

df_fig3 <- df_u |>
  inner_join(df_presented, by = c("participant_id", "item")) |>
  left_join(df_chosen, by = c("participant_id", "item")) |>
  mutate(n_chosen    = replace_na(n_chosen, 0),
         choice_rate = n_chosen / n_presented)

df_fig3_tags <- df_fig3 |>
  distinct(participant_id) |>
  arrange(participant_id) |>
  mutate(tag = LETTERS[row_number()])

p_fig3 <- ggplot(df_fig3, aes(x = u_median, y = choice_rate)) +
  geom_smooth(method = "lm", se = FALSE, colour = "#EE6677", linewidth = 0.8) +
  geom_point(colour = "#4477AA", alpha = 0.75, size = 2.5) +
  geom_text(data = df_fig3_tags, aes(label = tag), x = -Inf, y = Inf,
            hjust = -0.5, vjust = 1.5, fontface = "bold", size = 5,
            inherit.aes = FALSE) +
  facet_wrap(~ participant_id) +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank(),
        axis.line  = element_line(colour = "grey30")) +
  labs(x = "median posterior utility (u)",
       y = "empirical choice rate (chosen / presented)")

ggsave(file.path(output_dir, "utility_vs_choice_rate.pdf"), plot = p_fig3,
       width = 10, height = 8, bg = "white")
ggsave(file.path(output_dir, "utility_vs_choice_rate.png"), plot = p_fig3,
       width = 10, height = 8, dpi = 300, bg = "white")
