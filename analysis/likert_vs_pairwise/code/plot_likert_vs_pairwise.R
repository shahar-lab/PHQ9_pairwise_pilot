#### PLOT LIKERT VS PAIRWISE CHOICE PROPORTION ####

df_r <- df |>
  group_by(participant_id) |>
  summarise(r = cor(choice_proportion, likert_response, method = "pearson"))

x_limits <- c(0, 1)
y_limits <- range(df$likert_response)
x_breaks <- seq(x_limits[1], x_limits[2], length.out = 4)
y_breaks <- seq(y_limits[1], y_limits[2], length.out = 4)

p <- ggplot(df, aes(x = choice_proportion, y = likert_response)) +
  geom_point(colour = "#4477AA", alpha = 0.75, size = 2) +
  geom_smooth(method = "lm", se = FALSE, colour = "#EE6677", linewidth = 0.8) +
  geom_text(data = df_r,
            aes(x = Inf, y = Inf, label = sprintf("[Pearson r = %.2f]", r)),
            hjust = 1.05, vjust = 1.4, size = 3, colour = "grey30") +
  scale_x_continuous(breaks = x_breaks, labels = \(x) sprintf("%.2f", x)) +
  scale_y_continuous(breaks = y_breaks) +
  coord_fixed(ratio = diff(x_limits) / diff(y_limits),
              xlim = x_limits, ylim = y_limits, clip = "off") +
  facet_wrap(~ participant_id) +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank(),
        axis.line  = element_line(colour = "grey40", linewidth = 0.3)) +
  labs(x = "Pairwise choice proportion (chosen / presented)",
       y = "Likert rating")

plot_name <- "likert_vs_pairwise_choice_proportion"

ggsave(file.path(output_dir, paste0(plot_name, ".pdf")),
       plot = p, width = 10, height = 8, bg = "white")

ggsave(file.path(output_dir, paste0(plot_name, ".png")),
       plot = p, width = 10, height = 8, dpi = 300, bg = "white")
