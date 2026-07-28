#### PLOT CLINICAL REPORT 2 ####

pal_likert <- c("Not at all"              = "#999999",
                "Several days"            = "#88CCEE",
                "More than half the days" = "#4477AA",
                "Nearly every day"        = "#AA3377")
pal_zone   <- c("Major concerns" = "#EE6677",
                "Moderate"       = "#CCBB44",
                "Not a problem"  = "#4477AA")

pages2 <- list()

for (pid in df_subject_lookup$participant_id) {

  df_l <- df_ladder |>
    filter(participant_id == pid) |>
    arrange(zone, desc(u)) |>
    mutate(y = n() - row_number() + 1)

  df_zones <- df_l |>
    group_by(zone) |>
    summarise(ymin = min(y) - 0.5, ymax = max(y) + 0.5, .groups = "drop")

  cons    <- df_consistency |> filter(participant_id == pid)
  top3    <- df_l |> slice_max(u, n = 3) |> pull(item_phq_text)
  no_prob <- df_l |> filter(likert_response == 0) |> pull(item_phq_text)

  no_prob_text <- if (length(no_prob) == 0) {
    "none"
  } else if (length(no_prob) == nrow(df_l)) {
    paste0("all ", nrow(df_l), " items (ladder shows relative burden only)")
  } else if (length(no_prob) > 5) {
    paste0(length(no_prob), " of ", nrow(df_l), " items (see ladder)")
  } else {
    paste(no_prob, collapse = ";  ")
  }

  header_text <- paste0(
    "Participant ", pid, "\n\n",
    "Most burdensome symptoms:  ",
    str_wrap(paste(top3, collapse = ";  "), 95), "\n",
    "Not a problem (rated 'Not at all'):  ", str_wrap(no_prob_text, 95), "\n",
    "Choice consistency: ", sprintf("%.0f%%", cons$consistency * 100),
    " - ", cons$verdict)

  p_a <- ggplot() +
    annotate("text", x = 0, y = 1, label = header_text,
             hjust = 0, vjust = 1, size = 3.3, lineheight = 1.25) +
    coord_cartesian(xlim = c(0, 1), ylim = c(0, 1.05), clip = "off") +
    theme_void()

  p_b <- ggplot(df_l) +
    geom_rect(data = df_zones,
              aes(xmin = -Inf, xmax = Inf, ymin = ymin, ymax = ymax, fill = zone),
              alpha = 0.10) +
    geom_segment(aes(x = .lower, xend = .upper, y = y, yend = y),
                 colour = "grey55", linewidth = 1) +
    geom_point(aes(x = u, y = y, colour = likert_label), size = 3.2) +
    geom_text(data = df_zones,
              aes(x = max(df_l$.upper) + 0.28, y = (ymin + ymax) / 2,
                  label = str_wrap(zone, 10), colour = NULL),
              size = 3, fontface = "bold", colour = "grey40", lineheight = 0.9) +
    scale_fill_manual(values = pal_zone, guide = "none") +
    scale_colour_manual(values = pal_likert, drop = FALSE, name = "likert rating") +
    scale_y_continuous(breaks = df_l$y, labels = str_trunc(df_l$item_phq_text, 36)) +
    scale_x_continuous(expand = expansion(mult = c(0.05, 0.16))) +
    theme_minimal(base_size = 12) +
    theme(panel.grid      = element_blank(),
          axis.line.x     = element_line(colour = "grey30"),
          axis.title.y    = element_blank(),
          legend.position = "bottom") +
    labs(x = "relative utility (median, 90% HDI) - higher = more burdensome")

  p_c <- ggplot() +
    annotate("segment", x = 0.5, xend = 1, y = 0, yend = 0,
             colour = "grey85", linewidth = 6, lineend = "round") +
    annotate("segment", x = 0.5, xend = cons$consistency, y = 0, yend = 0,
             colour = "#4477AA", linewidth = 6, lineend = "round") +
    annotate("point", x = cons$consistency, y = 0, size = 4, colour = "grey20") +
    annotate("text", x = cons$consistency, y = 0.75,
             label = sprintf("%.0f%%", cons$consistency * 100),
             fontface = "bold", size = 4) +
    annotate("text", x = 0.5, y = -0.85, label = "random\n(50%)",
             size = 2.9, colour = "grey40", lineheight = 0.9) +
    annotate("text", x = 1, y = -0.85, label = "perfect\nconsistency (100%)",
             size = 2.9, colour = "grey40", lineheight = 0.9) +
    annotate("text", x = 0.75, y = 1.7,
             label = paste("Differentiation gauge:", cons$verdict),
             size = 3.3, colour = "grey20") +
    coord_cartesian(xlim = c(0.46, 1.04), ylim = c(-1.4, 2.1)) +
    theme_void()

  pages2[[pid]] <- (p_a / p_b / p_c) +
    plot_layout(heights = c(1.15, 4, 1.05)) +
    plot_annotation(tag_levels = "A") &
    theme(plot.tag = element_text(face = "bold", size = 14))
}

pdf(file.path(output_dir, "clinical_report2.pdf"), width = 10, height = 8)
for (pid in names(pages2)) print(pages2[[pid]])
dev.off()

for (pid in names(pages2)) {
  ggsave(file.path(output_dir, paste0("clinical_report2_", pid, ".png")),
         plot = pages2[[pid]], width = 10, height = 8, dpi = 300, bg = "white")
}
