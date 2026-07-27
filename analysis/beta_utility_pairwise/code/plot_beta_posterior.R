#### PLOT BETA POSTERIORS ####

df_fig2 <- bind_rows(
  df_beta_draws |> select(beta, distribution),
  df_pop_beta_draws |> select(beta, distribution)
)

okabe_ito <- c("#E69F00", "#56B4E9", "#009E73", "#0072B2", "#000000")
pal       <- setNames(okabe_ito[seq_along(unique(df_fig2$distribution))],
                      sort(unique(df_fig2$distribution)))

beta_range <- range(df_fig2$beta)
beta_span  <- diff(beta_range)
xlims      <- c(max(0, beta_range[1] - 0.2 * beta_span),
                beta_range[2] + 0.2 * beta_span)

p_fig2 <- ggplot(df_fig2,
                 aes(x = beta, y = 0, fill = distribution, colour = distribution)) +
  stat_slab(alpha = 0.50) +
  stat_pointinterval(.width = c(0.80, 0.90), point_size = 3) +
  scale_fill_manual(values = pal,
                    guide = guide_legend(override.aes = list(alpha = 0.7))) +
  scale_colour_manual(values = pal, guide = "none") +
  theme_minimal(base_size = 13) +
  theme(panel.grid           = element_blank(),
        axis.title.y         = element_blank(),
        axis.text.y          = element_blank(),
        axis.ticks.y         = element_blank(),
        axis.line.y          = element_blank(),
        axis.line.x          = element_line(colour = "grey30"),
        legend.position      = c(1, 0.95),
        legend.justification = c("right", "top"),
        legend.background    = element_blank(),
        legend.key           = element_blank()) +
  labs(x = "beta (choice sensitivity)", fill = NULL) +
  coord_cartesian(xlim = xlims, ylim = c(0, 1.3))

ggsave(file.path(output_dir, "beta_posteriors.pdf"), plot = p_fig2,
       width = 10, height = 8, bg = "white")
ggsave(file.path(output_dir, "beta_posteriors.png"), plot = p_fig2,
       width = 10, height = 8, dpi = 300, bg = "white")
