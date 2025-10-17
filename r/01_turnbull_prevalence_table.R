# 01_turnbull_prevalence_table.R
# Create wide tables of S(t) and 95% CIs at common months from Turnbull step estimates.
# Inputs (same 5 columns): Left_endpoint_months, Right_endpoint_months, S, Epidemic_periods, SE
# Files to process:
#   - jmp_turnbull_steps_adult_any.csv
#   - jmp_turnbull_steps_children_any.csv
#   - jmp_turnbull_steps_adult_interfering.csv
#   - jmp_turnbull_steps_children_interfering.csv
# Outputs (UTF-8):
#   - turnbull_prevalence_table_adult_any.csv
#   - turnbull_prevalence_table_child_any.csv
#   - turnbull_prevalence_table_adult_interfering.csv
#   - turnbull_prevalence_table_child_interfering.csv

rm(list=ls())

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(tools)
})

# Common time points (months) and period order
target_times <- c(0, 1, 2, 3, 6, 12, 18, 24, 36, 48)
period_levels <- c(
  "Wild-type period",
  "Alpha period",
  "Delta period",
  "Omicron period-2022",
  "Omicron period-2024"
)

required_cols <- c("Left_endpoint_months", "Right_endpoint_months", "S", "Epidemic_periods", "SE")

# ---- Helper: step interpolation faithful to Turnbull rules ----
get_step_S_SE_at_t <- function(d, t) {
  hit_exact <- which(!is.na(d$Left_fix) & d$Left_fix == t)
  if (length(hit_exact) > 0) {
    idx <- tail(hit_exact, 1)
    return(c(S = d$S[idx], SE = d$SE[idx]))
  }
  ok  <- !is.na(d$Right_fix) & is.finite(d$Right_fix)
  hit <- which(ok & d$Left_fix <= t & t <= d$Right_fix)
  if (length(hit) > 0) {
    idx <- tail(hit, 1)
    return(c(S = d$S[idx], SE = d$SE[idx]))
  }
  c(S = NA_real_, SE = NA_real_)
}

# ---- Core processor for one file ----
process_turnbull_file <- function(input_csv) {
  message("\n[Start] ", input_csv)
  if (!file.exists(input_csv)) stop("File not found: ", input_csv)
  
  dat_raw <- read_csv(input_csv, na = c("", ".", "NA"), show_col_types = FALSE)
  if (!all(required_cols %in% names(dat_raw))) {
    stop("Missing required columns in ", input_csv, ": ",
         paste(setdiff(required_cols, names(dat_raw)), collapse = ", "))
  }
  
  df <- dat_raw %>%
    mutate(
      Left  = as.numeric(Left_endpoint_months),
      Right = as.numeric(Right_endpoint_months),
      S     = as.numeric(S),
      SE    = as.numeric(SE),
      Left_fix  = ifelse(is.na(Left), -Inf, Left),
      Right_fix = Right,
      Epidemic_periods = factor(Epidemic_periods, levels = period_levels)
    ) %>%
    arrange(Epidemic_periods, Left_fix, Right_fix)
  
  res_long <- df %>%
    group_by(Epidemic_periods) %>%
    group_modify(function(d, key) {
      map_dfr(target_times, function(tt) {
        v  <- get_step_S_SE_at_t(d, tt)
        S  <- as.numeric(v["S"]); SE <- as.numeric(v["SE"])
        if (is.na(S) || is.na(SE)) {
          tibble(Month = tt, S = NA_real_, LCI = NA_real_, UCI = NA_real_)
        } else {
          tibble(
            Month = tt,
            S  = S,
            LCI = max(0, S - 1.96 * SE),
            UCI = min(1, S + 1.96 * SE)
          )
        }
      })
    }) %>%
    ungroup() %>%
    mutate(across(c(S, LCI, UCI), ~ round(.x, 3)))
  
  res_wide <- res_long %>%
    mutate(Epidemic_periods = factor(Epidemic_periods, levels = period_levels)) %>%
    arrange(Month, Epidemic_periods) %>%
    pivot_wider(
      id_cols = Month,
      names_from  = Epidemic_periods,
      values_from = c(S, LCI, UCI),
      names_glue  = "{Epidemic_periods}_{.value}"
    ) %>%
    arrange(Month)
  
  # Derive output name: turnbull_prevalence_table_<suffix>.csv
  # suffix = input without leading "jmp_turnbull_steps_" and without extension
  base_in   <- file_path_sans_ext(basename(input_csv))
  suffix    <- sub("^jmp_turnbull_steps_", "", base_in)
  output_csv <- paste0("turnbull_prevalence_table_", suffix, ".csv")
  
  write_csv(res_wide, output_csv)
  message("[Wrote] ", output_csv)
  invisible(output_csv)
}

# ---- Files to run (edit as needed) ----
files_to_run <- c(
  "jmp_turnbull_steps_adult_any.csv",
  "jmp_turnbull_steps_children_any.csv",
  "jmp_turnbull_steps_adult_interfering.csv",
  "jmp_turnbull_steps_children_interfering.csv"
)

# ---- Execute ----
out_files <- purrr::map_chr(files_to_run, process_turnbull_file)
message("\nAll done:\n", paste0(" - ", out_files, collapse = "\n"))
