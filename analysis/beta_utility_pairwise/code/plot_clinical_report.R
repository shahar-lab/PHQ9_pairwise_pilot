#### PLOT CLINICAL REPORT ####

pages <- list()

for (pid in df_subject_lookup$participant_id) {

  df_tab <- df_u_hdi |>
    filter(participant_id == pid) |>
    arrange(desc(u)) |>
    mutate(row = rev(row_number()))

  p_table <- ggplot(df_tab) +
    geom_text(aes(x = 0.00, y = row, label = str_trunc(item_phq_text, 34)),
              hjust = 0, size = 2.9) +
    geom_text(aes(x = 1.70, y = row, label = sprintf("%.2f", u)),
              hjust = 1, size = 2.9) +
    geom_text(aes(x = 2.55, y = row, label = hdi_label), hjust = 1, size = 2.9) +
    geom_text(aes(x = 3.00, y = row, label = likert_response), hjust = 1, size = 2.9) +
    annotate("text", x = c(0.00, 1.70, 2.55, 3.00), y = max(df_tab$row) + 1,
             label = c("item", "u median", "90% HDI", "likert"),
             hjust = c(0, 1, 1, 1), fontface = "bold", size = 3) +
    coord_cartesian(xlim = c(0, 3.05), ylim = c(0, max(df_tab$row) + 1.5),
                    clip = "off") +
    theme_void()

  beta_pid <- df_beta_draws |> filter(participant_id == pid) |> pull(beta)
  med_b    <- median(beta_pid)
  pd_b     <- max(mean(beta_pid > 0), mean(beta_pid < 0)) * 100
  r_b      <- range(beta_pid)
  span_b   <- diff(r_b)

  p_beta <- ggplot(data.frame(beta = beta_pid), aes(x = beta, y = 0)) +
    stat_slab(fill = "gray80") +
    stat_pointinterval(.width = c(0.80, 0.90), point_size = 3, linewidth = c(2, 1)) +
    geom_vline(xintercept = med_b, linetype = "dashed", colour = "grey65",
               linewidth = 0.4) +
    annotate("text", x = med_b, y = Inf,
             label = sprintf("[median = %.2f, pd = %.2f%%]", med_b, pd_b),
             hjust = -0.05, vjust = 1.4, size = 3.2, colour = "grey40") +
    theme_minimal(base_size = 13) +
    theme(panel.grid   = element_blank(),
          axis.title.y = element_blank(),
          axis.text.y  = element_blank(),
          axis.ticks.y = element_blank(),
          axis.line.y  = element_blank(),
          axis.line.x  = element_line(colour = "grey30")) +
    labs(x = "beta (choice sensitivity)") +
    coord_cartesian(xlim = c(max(0, r_b[1] - 0.2 * span_b), r_b[2] + 0.2 * span_b),
                    ylim = c(0, 1.3), clip = "off")

  p_rt <- ggplot(df_rt |> filter(participant_id == pid), aes(x = abs_du, y = rt)) +
    geom_point(colour = "#4477AA", alpha = 0.75, size = 2) +
    geom_smooth(method = "lm", se = FALSE, colour = "#EE6677", linewidth = 0.8) +
    theme_minimal(base_size = 13) +
    theme(panel.grid = element_blank(),
          axis.line  = element_line(colour = "grey30")) +
    labs(x = "absolute utility difference of offered items", y = "rt (ms)")

  pages[[pid]] <- (p_table | (p_beta / p_rt)) +
    plot_annotation(tag_levels = "A", title = paste("Participant", pid)) &
    theme(plot.tag = element_text(face = "bold", size = 14))
}

pdf(file.path(output_dir, "clinical_report.pdf"), width = 10, height = 8)
for (pid in names(pages)) print(pages[[pid]])
dev.off()

for (pid in names(pages)) {
  ggsave(file.path(output_dir, paste0("clinical_report_", pid, ".png")),
         plot = pages[[pid]], width = 10, height = 8, dpi = 300, bg = "white")
}
