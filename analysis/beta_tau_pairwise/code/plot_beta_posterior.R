#### PLOT BETA POSTERIORS ####

df_fig_beta <- bind_rows(
  df_beta_draws |> select(beta, distribution),
  df_pop_beta_draws |> select(beta, distribution))

# 8 subjects + population median = 9 groups, over Okabe-Ito's 8-group ceiling,
# so use Paul Tol muted (up to 10 categories) instead.
tol_muted <- c("#332288", "#117733", "#44AA99", "#88CCEE", "#DDCC77",
               "#CC6677", "#AA4499", "#882255", "#999933", "#44BB99")
pal <- setNames(tol_muted[seq_along(unique(df_fig_beta$distribution))],
                sort(unique(df_fig_beta$distribution)))

beta_range <- range(df_fig_beta$beta)
beta_span  <- diff(beta_range)
xlims      <- c(max(0, beta_range[1] - 0.2 * beta_span),
                beta_range[2] + 0.2 * beta_span)

p_beta <- ggplot(df_fig_beta,
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

ggsave(file.path(output_dir, "beta_posteriors.pdf"), plot = p_beta,
       width = 10, height = 8, bg = "white")
ggsave(file.path(output_dir, "beta_posteriors.png"), plot = p_beta,
       width = 10, height = 8, dpi = 300, bg = "white")
