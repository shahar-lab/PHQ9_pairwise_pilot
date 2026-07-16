#### PLOT UTILITY VS CHOICE RATE ####

df_presented <- df |>
  pivot_longer(c(left_item, right_item), values_to = "item") |>
  count(item, name = "n_presented")

df_chosen <- df |>
  count(chosen_item, name = "n_chosen") |>
  rename(item = chosen_item)

df_fig3 <- df_u |>
  group_by(item, item_phq_text) |>
  summarise(u_mean_median = mean(u_median), .groups = "drop") |>
  left_join(df_presented, by = "item") |>
  left_join(df_chosen, by = "item") |>
  mutate(n_chosen    = replace_na(n_chosen, 0),
         choice_rate = n_chosen / n_presented)

p_fig3 <- ggplot(df_fig3, aes(x = u_mean_median, y = choice_rate)) +
  geom_smooth(method = "lm", se = FALSE, colour = "#EE6677", linewidth = 0.8) +
  geom_point(colour = "#4477AA", alpha = 0.75, size = 2.5) +
  geom_text(aes(label = item_phq_text,
                hjust = ifelse(u_mean_median > median(u_mean_median), 1.05, -0.05)),
            vjust = -0.6, size = 2.8, colour = "grey30") +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank(),
        axis.line  = element_line(colour = "grey30")) +
  labs(x = "median posterior utility (averaged across participants)",
       y = "empirical choice rate (pooled)")

ggsave(file.path(output_dir, "utility_vs_choice_rate.pdf"), plot = p_fig3,
       width = 10, height = 8, bg = "white")
ggsave(file.path(output_dir, "utility_vs_choice_rate.png"), plot = p_fig3,
       width = 10, height = 8, dpi = 300, bg = "white")
