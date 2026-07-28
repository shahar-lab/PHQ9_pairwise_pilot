#### PLOT UTILITY RECOVERY ####

plot_df <- data.frame(
  u_true      = df_u_recovery$u_true,
  u_recovered = df_u_recovery$u_recovered
)

plot_df <- plot_df[complete.cases(plot_df), ]
stopifnot(length(plot_df$u_true) == length(plot_df$u_recovered))

shared_limits <- range(c(plot_df$u_true, plot_df$u_recovered), na.rm = TRUE)
axis_breaks   <- seq(shared_limits[1], shared_limits[2], length.out = 4)
pearson_r_u   <- cor(plot_df$u_true, plot_df$u_recovered, method = "pearson")

p_u_recovery <- ggplot(plot_df, aes(x = u_true, y = u_recovered)) +
  geom_point(colour = "#4477AA", alpha = 0.75, size = 2) +
  geom_smooth(method = "lm", se = FALSE, colour = "#EE6677", linewidth = 0.8) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "grey60") +
  annotate(
    "text", x = Inf, y = Inf,
    label = sprintf("[Pearson r = %.2f]", pearson_r_u),
    hjust = 1.05, vjust = 1.4, size = 3.5, colour = "grey30"
  ) +
  scale_x_continuous(breaks = axis_breaks) +
  scale_y_continuous(breaks = axis_breaks) +
  coord_equal(xlim = shared_limits, ylim = shared_limits, clip = "off") +
  theme_minimal(base_size = 13) +
  theme(panel.grid.minor = element_blank()) +
  labs(x = "True utility (u)", y = "Recovered utility (posterior mean)")

ggsave(file.path(output_dir, "u_recovery.pdf"), plot = p_u_recovery, width = 10, height = 8, bg = "white")
ggsave(file.path(output_dir, "u_recovery.png"), plot = p_u_recovery, width = 10, height = 8, dpi = 300, bg = "white")

message(sprintf("u recovery Pearson r = %.3f", pearson_r_u))
