# Analysis Notebook: Likert vs Pairwise Choice Proportion

**Analysis:** per-participant relationship between Likert ratings and pairwise choice proportions
**Date Created:** 2026-07-15

## 1. Hypotheses
* Items rated higher on the PHQ-9 Likert scale are chosen more often in the pairwise task within a participant.

## 2. Variables
* **Outcome (y):** `likert_response` — Likert rating per PHQ item (`data/processed/likert_processed.csv`).
* **Predictor (x):** `choice_proportion` — times an item was chosen divided by times it was presented (as `left_item` or `right_item`) in the pairwise task, skipped trials excluded (`data/processed/pairwise_processed.csv`).

## 3. Findings / Summary
* One faceted figure (one panel per participant): points per item, linear trend line, per-panel Pearson r.
* Figure: `output/likert_vs_pairwise_choice_proportion.pdf` / `.png`.

## 4. Deviations & Data Notes
* The plotting skill's dashed diagonal equality line is deliberately omitted: x (choice proportion, 0–1) and y (Likert rating, 0–3) are on different scales, so an x = y equality line is meaningless. Deviation approved in review.
* Likert item 16 has no presentations in the pairwise task and is therefore dropped by the inner join in `code/prep_data.R`.
