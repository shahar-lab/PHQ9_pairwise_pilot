#### PLOT BETA VS CHOICE PROBABILITY SD ####

df_beta_median <- fit$summary("beta", beta_median = ~ median(.x)) |>
  mutate(subject = as.integer(str_extract(variable, "\\d+"))) |>
  left_join(df_subject_lookup, by = "subject") |>
  select(participant_id, beta_median)

df_fig4 <- df |>
  left_join(df_u |> select(participant_id, item, u_left = u_median),
            by = c("participant_id", "left_item" = "item")) |>
  left_join(df_u |> select(participant_id, item, u_right = u_median),
            by = c("participant_id", "right_item" = "item")) |>
  left_join(df_beta_median, by = "participant_id") |>
  mutate(p_choose_left = plogis(beta_median * (u_left - u_right))) |>
  group_by(participant_id, beta_median) |>
  summarise(choice_prob_sd = sd(p_choose_left), .groups = "drop")

p_fig4 <- ggplot(df_fig4, aes(x = choice_prob_sd, y = beta_median)) +
  geom_point(colour = "#4477AA", alpha = 0.75, size = 3) +
  geom_text(aes(label = participant_id), vjust = -1, size = 3.2, colour = "grey30") +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank(),
        axis.line  = element_line(colour = "grey30")) +
  scale_x_continuous(expand = expansion(mult = 0.15)) +
  scale_y_continuous(expand = expansion(mult = 0.15)) +
  labs(x = "SD of model-implied choice probabilities",
       y = "median posterior beta")

ggsave(file.path(output_dir, "beta_vs_choice_prob_sd.pdf"), plot = p_fig4,
       width = 10, height = 8, bg = "white")
ggsave(file.path(output_dir, "beta_vs_choice_prob_sd.png"), plot = p_fig4,
       width = 10, height = 8, dpi = 300, bg = "white")
