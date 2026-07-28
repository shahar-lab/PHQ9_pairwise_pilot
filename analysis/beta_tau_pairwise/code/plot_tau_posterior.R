#### PLOT TAU POSTERIORS ####

df_fig_tau <- bind_rows(
  df_tau_draws |> select(tau, distribution),
  df_pop_tau_draws |> select(tau, distribution))

tol_muted <- c("#332288", "#117733", "#44AA99", "#88CCEE", "#DDCC77",
               "#CC6677", "#AA4499", "#882255", "#999933", "#44BB99")
pal <- setNames(tol_muted[seq_along(unique(df_fig_tau$distribution))],
                sort(unique(df_fig_tau$distribution)))

tau_range <- range(df_fig_tau$tau)
tau_span  <- diff(tau_range)
xlims     <- c(tau_range[1] - 0.2 * tau_span, tau_range[2] + 0.2 * tau_span)

p_tau <- ggplot(df_fig_tau,
                aes(x = tau, y = 0, fill = distribution, colour = distribution)) +
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
  labs(x = "tau (no-choice / burden threshold)", fill = NULL) +
  coord_cartesian(xlim = xlims, ylim = c(0, 1.3))

ggsave(file.path(output_dir, "tau_posteriors.pdf"), plot = p_tau,
       width = 10, height = 8, bg = "white")
ggsave(file.path(output_dir, "tau_posteriors.png"), plot = p_tau,
       width = 10, height = 8, dpi = 300, bg = "white")
