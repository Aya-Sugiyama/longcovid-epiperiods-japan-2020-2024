# Long-term Post-COVID-19 Symptoms by Epidemic Period (Japan, 2020–2024)

Reproducible materials for Turnbull interval-censored survival analyses of post-COVID-19 symptoms.  
No individual-level data are included. Aggregated CSV files and scripts reproduce the figures and tables presented in the paper.

---

## Contents

**data/aggregated/** — Turnbull input tables (long-format CSVs) and human-readable wide tables (UTF-8)  
**jmp_turnbull_steps_*.csv** — JMP-derived Turnbull step estimates (columns: *t_start_month, t_end_month, S, SE, period, group, severity*)  
**figures_underlying_data/** — CSVs used to plot figures (e.g., *figure2_points.csv*, *figure3_points.csv*)  
**r/** — R scripts for analyses (Turnbull prevalence, interval-censored regression, figure generation)  
**jmp/** — JMP JSL scripts and Journal files for survival analyses  
**outputs/** — Regression and summary outputs (coefficients, SE, 95% CI, p-values, fit indices)

---

## How to Reproduce (Minimal Steps)

### In JMP (version 14 or later)

1. Open *jmp/analysis.jrn* (or run *jmp/turnbull_survival.jsl*) to generate Turnbull survival curves using  
   *data/aggregated/S_Table1_turnbull_long.csv*.
2. From the survival plot, select **“Make Into Data Table”** and save as  
   *data/aggregated/jmp_turnbull_steps_long.csv*  
   (columns: *t_start_month, t_end_month, S, SE, period, group, severity*).
3. *(Optional)* Export plotted points for Figure 2 as *figures_underlying_data/figure2_points.csv*.

### In R (version 4.4.1)

Run the following scripts sequentially:

- **r/01_turnbull_prevalence_table.R** → Generates Supplementary Table 2 (uses *jmp_turnbull_steps_long.csv*)  
- **r/02_icenReg_models.R** → Runs interval-censored proportional hazards models (icenReg); outputs *outputs/hr_full_results.csv*  
- **r/03_symptom_prevalence_3m_12m.R** → Produces Figure 3 (13 symptoms; estimates at 3 and 12 months)

Results will be written to *outputs/* and *figures_underlying_data/*.

---

## Environment

- **R 4.4.1** (packages: *icenReg*, *readr*, *dplyr*, *ggplot2*)  
- **JMP 14** (SAS Institute Inc.)

---

## Data Availability

Aggregated minimal datasets and all analysis code are openly available at [DOI].  
Individual-level data cannot be shared, as participants did not consent to external data release and the IRB-approved protocol prohibits it.  
For inquiries, please contact: **Hiroshima University IRB Office** (iryo-sinsa@office.hiroshima-u.ac.jp)

---

## License

- **Code (R scripts, JMP JSL/Journal)** — MIT License (see LICENSE)  
- **Data (aggregated CSVs)** — CC BY 4.0 License (see LICENSE-data)

---

## Citation

Please cite this repository as follows:  

**DOI:** [Zenodo Concept DOI]  
**URL:** [https://github.com/USER/REPO]  

(Alternatively, use the **“Cite this repository”** button on GitHub if a *CITATION.cff* file is present.)
