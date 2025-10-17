# ============================================================
# S(t) at 3m and 12m from Turnbull step curves
# Input : jmp_turnbull_steps_13symptoms.csv
# Required columns:
#   symptoms, Left_endpoint, Right_endpoint, S, SE, Epidemic_periods
# Output: 13symptom_prevalence_3m_12m.csv
# Notes:
#   - Turnbull step rule (faithful):
#       (1) Use row with Left == t (even if Right is NA)
#       (2) Else use finite interval [Left, Right] containing t
#       (3) If multiple hits, take the last
#   - Open-left intervals: treat Left as -Inf
# ============================================================

rm(list=ls())

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(purrr)
})

in_path  <- "jmp_turnbull_steps_13symptoms.csv"
out_path <- "13symptom_prevalence_3m_12m.csv"

# --- 1) Read & normalize ---
df <- read_csv(in_path, show_col_types = FALSE) %>%
  rename(
    symptom = symptoms,
    period  = Epidemic_periods,
    left    = Left_endpoint,
    right   = Right_endpoint
  ) %>%
  mutate(
    across(c(left, right, S, SE), as.numeric),
    symptom  = as.character(symptom),
    period   = as.character(period),
    # Open-left handling (same as original Japanese code)
    left_fix  = if_else(is.na(left), -Inf, left),
    right_fix = right
  ) %>%
  arrange(symptom, period, left_fix, right_fix)

# --- 2) Helper: pick S,SE at target time t (Turnbull rule) ---
pick_S_at_t <- function(d, t) {
  # (1) prioritize exact step start
  hit_exact <- which(!is.na(d$left_fix) & d$left_fix == t)
  if (length(hit_exact) > 0) {
    i <- tail(hit_exact, 1)
    return(c(S = d$S[i], SE = d$SE[i]))
  }
  # (2) otherwise finite interval containing t
  ok  <- !is.na(d$right_fix) & is.finite(d$right_fix)
  hit <- which(ok & d$left_fix <= t & t <= d$right_fix)
  if (length(hit) > 0) {
    i <- tail(hit, 1)
    return(c(S = d$S[i], SE = d$SE[i]))
  }
  c(S = NA_real_, SE = NA_real_)
}

# --- 3) Compute S(t) and 95% CI at 3m & 12m ---
times <- c(`3m` = 3, `12m` = 12)

res_long <- df %>%
  group_by(symptom, period) %>%
  group_modify(function(d, key) {
    map_dfr(times, function(tt) {
      v  <- pick_S_at_t(d, tt)
      S  <- as.numeric(v["S"])
      SE <- as.numeric(v["SE"])
      if (is.na(S) | is.na(SE)) {
        tibble(time = tt, S = NA_real_, LCI = NA_real_, UCI = NA_real_)
      } else {
        LCI <- max(0, S - 1.96 * SE)
        UCI <- min(1, S + 1.96 * SE)
        tibble(time = tt, S = S, LCI = LCI, UCI = UCI)
      }
    })
  }) %>%
  ungroup()

# --- 4) Clean keys & deduplicate (keep last non-NA) ---
out_clean <- res_long %>%
  mutate(time = dplyr::case_when(
    time %in% c("3", 3, "3m", "3 m")     ~ "3m",
    time %in% c("12", 12, "12m", "12 m") ~ "12m",
    TRUE ~ NA_character_
  )) %>%
  filter(!is.na(time)) %>%
  group_by(symptom, period, time) %>%
  summarise(
    S   = if (all(is.na(S)))   NA_real_ else dplyr::last(na.omit(S)),
    LCI = if (all(is.na(LCI))) NA_real_ else dplyr::last(na.omit(LCI)),
    UCI = if (all(is.na(UCI))) NA_real_ else dplyr::last(na.omit(UCI)),
    .groups = "drop"
  ) %>%
  arrange(symptom, period, time)

# --- 5) Robust wide: pivot each metric separately, then join ---
w_S <- out_clean %>%
  select(symptom, period, time, S) %>%
  distinct(symptom, period, time, .keep_all = TRUE) %>%
  pivot_wider(
    id_cols    = c(symptom, period),
    names_from = time,
    values_from = S,
    names_prefix = "S_"
  )

w_LCI <- out_clean %>%
  select(symptom, period, time, LCI) %>%
  distinct(symptom, period, time, .keep_all = TRUE) %>%
  pivot_wider(
    id_cols    = c(symptom, period),
    names_from = time,
    values_from = LCI,
    names_prefix = "LCI_"
  )

w_UCI <- out_clean %>%
  select(symptom, period, time, UCI) %>%
  distinct(symptom, period, time, .keep_all = TRUE) %>%
  pivot_wider(
    id_cols    = c(symptom, period),
    names_from = time,
    values_from = UCI,
    names_prefix = "UCI_"
  )

out_wide <- w_S %>%
  left_join(w_LCI, by = c("symptom","period")) %>%
  left_join(w_UCI, by = c("symptom","period")) %>%
  mutate(across(starts_with(c("S_","LCI_","UCI_")), ~ round(.x, 3))) %>%
  arrange(symptom, period)

# --- 6) Export ---
write_csv(out_wide, out_path)
message("Wrote: ", out_path)

