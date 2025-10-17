# 02_icenReg_models.R
# Purpose:
#   Fit a proportional hazards (Cox-PH) model for interval-censored outcomes
#   using icenReg::ic_sp on individual-level data (not publicly shared).
#   Publishes only the analysis steps and HR table output.
#
# Expected input (pre-processed, UTF-8 CSV):
#   Columns:
#     L, R                   -- interval endpoints in months (use -Inf / Inf for left/right censoring)
#     age_group5             -- 5-level age group at infection
#     sex                    -- binary/nominal sex
#     severity2              -- 2-level severity (e.g., "mild", "moderate/severe")
#     epidemic_period4       -- epidemic period categories
#
# Output:
#   hr_full_results.csv  -- HRs with 95% CIs and statistics (UTF-8)

suppressPackageStartupMessages({
  library(readr)     # read_csv, write_csv
  library(dplyr)     # pipes, mutate
  library(survival)  # Surv()
  library(icenReg)   # ic_sp(), coef(), vcov()
})

# -----------------------------
# 0) Settings
# -----------------------------
input_csv  <- "individual_interval_dataset.csv"  
output_csv <- "hr_full_results.csv"

# Reproducibility for bootstrap-based SEs
set.seed(12345)

# -----------------------------
# 1) Read data (assumes UTF-8)
# -----------------------------
df <- read_csv(
  input_csv,
  na = c("", "NA", "."),
  show_col_types = FALSE
)

# Minimal column check
required_cols <- c("L","R","age_group5","sex","severity2","epidemic_period4")
stopifnot(all(required_cols %in% names(df)))

# -----------------------------
# 2) Ensure interval-censoring columns are numeric with +/-Inf as needed
#    (Assumes pre-processing already applied; this is a light guard.)
# -----------------------------
df <- df %>%
  mutate(
    L = as.numeric(L),
    R = as.numeric(R)
  )

# -----------------------------
# 3) (Optional) Set reference levels if needed
#    Uncomment and edit to match your desired references.
# -----------------------------
# df <- df %>%
#   mutate(
#     age_group5       = factor(age_group5,
#                               levels = c("<=12","13-29","30-49","50-69",">=70")),
#     sex              = factor(sex, levels = c("Female","Male")),
#     severity2        = factor(severity2, levels = c("mild","moderate/severe")),
#     epidemic_period4 = factor(epidemic_period4,
#                               levels = c("Wild-type","Alpha","Delta","Omicron"))
#   )

# -----------------------------
# 4) Build Surv object (interval2)
# -----------------------------
surv_obj <- with(df, Surv(L, R, type = "interval2"))

# -----------------------------
# 5) Fit Cox-PH model via icenReg::ic_sp
#    Note: Standard errors / CIs are bootstrap-based; adjust bs_samples as needed.
# -----------------------------
fit_ic_ph <- ic_sp(
  surv_obj ~ age_group5 + sex + severity2 + epidemic_period4,
  data       = df,
  model      = "ph",
  bs_samples = 500
)

# -----------------------------
# 6) Derive HRs and 95% CIs from coef/vcov
# -----------------------------
co <- coef(fit_ic_ph)        # log-HR
vc <- vcov(fit_ic_ph)        # variance-covariance
se <- sqrt(diag(vc))

z  <- co / se
p  <- 2 * pnorm(abs(z), lower.tail = FALSE)

HR  <- exp(co)
LCI <- exp(co - 1.96 * se)
UCI <- exp(co + 1.96 * se)

result_hr <- data.frame(
  term  = names(co),
  HR    = HR,
  LCI   = LCI,
  UCI   = UCI,
  logHR = co,
  SE    = se,
  z     = z,
  p     = p,
  row.names = NULL,
  check.names = FALSE
)

# Round numeric columns
num_cols <- vapply(result_hr, is.numeric, logical(1))
result_hr[num_cols] <- lapply(result_hr[num_cols], function(x) round(x, 3))

# -----------------------------
# 7) Save output (UTF-8)
# -----------------------------
write_csv(result_hr, output_csv)
cat("Wrote:", output_csv, "\n")

# (Optional) Console preview
print(result_hr)
