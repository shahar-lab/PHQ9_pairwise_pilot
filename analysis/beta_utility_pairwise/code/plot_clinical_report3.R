#### PLOT CLINICAL REPORT 3 ####

pal_likert3 <- c("Not at all"              = "#DDDDDD",
                 "Several days"            = "#88CCEE",
                 "More than half the days" = "#4477AA",
                 "Nearly every day"        = "#AA3377")
likert_labels3 <- c("0" = "Not at all", "1" = "Several days",
                    "2" = "More than half the days", "3" = "Nearly every day")
pal_band <- c("Minimal"           = "#B8B8B8",
              "Mild"              = "#CCBB44",
              "Moderate"          = "#EE8866",
              "Moderately severe" = "#EE6677",
              "Severe"            = "#994455")

pages3 <- list()

for (pid in df_subject_lookup$participant_id) {

  df_l <- df_ladder3 |>
    filter(participant_id == pid) |>
    arrange(position) |>
    mutate(y = n() - position + 1,
           likert_label = factor(likert_labels3[as.character(likert_response)],
                                 levels = likert_labels3))

  df_tier_bands <- df_l |>
    group_by(tier) |>
    summarise(ymin = min(y) - 0.5, ymax = max(y) + 0.5, .groups = "drop") |>
    mutate(fill = colorRampPalette(c("#EE6677", "#CCBB44", "#4477AA"))(n()),
           label = if_else(tier == 1, "Tier 1\n(most\nburdensome)",
                           paste0("Tier ", tier)))

  cons <- df_consistency3 |> filter(participant_id == pid)
  sev  <- df_severity |> filter(participant_id == pid)
  header_text <- df_header3 |>
    filter(participant_id == pid) |>
    pull(header_text)

  x_lo    <- min(df_l$.lower)
  x_hi    <- max(df_l$.upper)
  strip_x <- x_lo - 0.10 * (x_hi - x_lo)
  tier_x  <- x_hi + 0.10 * (x_hi - x_lo)

  p_a <- ggplot() +
    annotate("text", x = 0, y = 1, label = header_text,
             hjust = 0, vjust = 1, size = 3.4, lineheight = 1.3) +
    coord_cartesian(xlim = c(0, 1), ylim = c(0, 1.05), clip = "off") +
    theme_void()

  p_b <- ggplot(df_l) +
    geom_rect(data = df_tier_bands,
              aes(xmin = -Inf, xmax = Inf, ymin = ymin, ymax = ymax),
              fill = df_tier_bands$fill, alpha = 0.10) +
    geom_segment(aes(x = .lower, xend = .upper, y = y, yend = y),
                 colour = "grey55", linewidth = 1) +
    geom_point(aes(x = u, y = y), colour = "grey20", size = 3) +
    geom_tile(aes(x = strip_x, y = y, fill = likert_label),
              width = 0.05 * (x_hi - x_lo), height = 0.8) +
    geom_text(data = df_tier_bands,
              aes(x = tier_x, y = (ymin + ymax) / 2, label = label),
              hjust = 0, size = 3, fontface = "bold", colour = "grey35",
              lineheight = 0.9) +
    scale_fill_manual(values = pal_likert3, drop = FALSE,
                      name = "self-rated\nfrequency") +
    scale_y_continuous(breaks = df_l$y, labels = df_l$item_short) +
    scale_x_continuous(breaks = NULL,
                       expand = expansion(mult = c(0.08, 0.24))) +
    theme_minimal(base_size = 12) +
    theme(panel.grid      = element_blank(),
          axis.line.x     = element_line(colour = "grey30"),
          axis.title.y    = element_blank(),
          legend.position = "bottom",
          legend.title    = element_text(size = 9)) +
    labs(x = "relative burden (median, 90% HDI)",
         caption = "positions are relative to this person's own symptoms; items within a tier are statistically tied")

  df_bands_rect <- severity_bands |>
    mutate(band = factor(band, levels = severity_bands$band))
  df_grad <- if (sev$total_se > 0) {
    tibble(yy = seq(max(0, sev$likert_total - 3 * sev$total_se),
                    min(45, sev$likert_total + 3 * sev$total_se),
                    length.out = 200)) |>
      mutate(a = dnorm(yy, sev$likert_total, sev$total_se),
             a = a / max(a) * 0.85)
  } else NULL

  p_d <- ggplot() +
    geom_rect(data = df_bands_rect,
              aes(xmin = 0.7, xmax = 1.3, ymin = lower - 0.5,
                  ymax = upper + 0.5),
              fill = pal_band[as.character(df_bands_rect$band)],
              alpha = 0.30) +
    geom_text(data = df_bands_rect,
              aes(x = 1.38, y = (lower + upper) / 2, label = band),
              hjust = 0, size = 2.8, colour = "grey40") +
    {if (!is.null(df_grad))
      geom_tile(data = df_grad,
                aes(x = 1, y = yy, alpha = a),
                width = 0.6, fill = "#4477AA")} +
    scale_alpha_identity() +
    annotate("segment", x = 0.7, xend = 1.3, y = sev$likert_total,
             yend = sev$likert_total, colour = "grey10", linewidth = 1.1) +
    annotate("text", x = 0.62, y = sev$likert_total,
             label = sev$likert_total, hjust = 1, fontface = "bold",
             size = 3.6) +
    scale_y_continuous(limits = c(-0.5, 45.5), breaks = c(0, 45),
                       expand = c(0, 0)) +
    coord_cartesian(xlim = c(0.35, 2.35), clip = "off") +
    theme_minimal(base_size = 12) +
    theme(panel.grid   = element_blank(),
          axis.text.x  = element_blank(),
          axis.title.x = element_blank()) +
    labs(y = "overall depression (likert sum score)")

  p_c <- ggplot() +
    annotate("segment", x = 0.5, xend = 1, y = 0, yend = 0,
             colour = "grey85", linewidth = 6, lineend = "round") +
    annotate("segment", x = cons$cons_lo, xend = cons$cons_hi, y = 0, yend = 0,
             colour = "#4477AA", linewidth = 6, lineend = "round") +
    annotate("point", x = cons$consistency, y = 0, size = 4, colour = "grey20") +
    annotate("text", x = cons$consistency, y = 0.75,
             label = sprintf("%.0f%%", cons$consistency * 100),
             fontface = "bold", size = 4) +
    annotate("text", x = 0.5, y = -0.85, label = "random\n(50%)",
             size = 2.9, colour = "grey40", lineheight = 0.9) +
    annotate("text", x = 1, y = -0.85, label = "perfect\nconsistency (100%)",
             size = 2.9, colour = "grey40", lineheight = 0.9) +
    annotate("text", x = 0.75, y = 1.7, label = "Choice consistency",
             size = 3.4, colour = "grey20") +
    coord_cartesian(xlim = c(0.46, 1.04), ylim = c(-1.4, 2.1)) +
    theme_void()

  pages3[[pid]] <- (p_a / (p_b + p_d + plot_layout(widths = c(3.2, 1))) / p_c) +
    plot_layout(heights = c(1.05, 4, 1)) +
    plot_annotation(tag_levels = "A") &
    theme(plot.tag = element_text(face = "bold", size = 14))
}

pdf(file.path(output_dir, "clinical_report3.pdf"), width = 11, height = 8)
for (pid in names(pages3)) print(pages3[[pid]])
dev.off()

for (pid in names(pages3)) {
  ggsave(file.path(output_dir, paste0("clinical_report3_", pid, ".png")),
         plot = pages3[[pid]], width = 11, height = 8, dpi = 300, bg = "white")
}
