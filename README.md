# Long-term Post-COVID-19 Symptoms by Epidemic Period (Japan, 2020–2024)

Reproducible materials for Turnbull interval-censored survival analyses of post-COVID-19 symptoms.  
No individual-level data are included. Aggregated CSV files and analysis scripts are original materials created for this study and made publicly available here.

---

## Overview of Analytic Workflow

All figures and tables can be reproduced using the aggregated CSVs and scripts provided here.  
Turnbull interval-censored survival curves were estimated in **JMP**, and subsequent calculations (e.g., prevalence at specific time points, regression analyses) were conducted in **R**.

---

## 1) Figure 2 — Estimated prevalence of post-COVID-19 symptoms over time

**Analysis tool:** JMP (Turnbull survival analysis)

**Steps:**
- Input: `data/aggregated/S_Table1_turnbull_long.csv`  
- Run: `jmp/turnbull_survival.jsl` (JMP Journal for Turnbull analysis)  
- Output files generated from JMP:  
  - `jmp_turnbull_steps_adult_any.csv`  
  - `jmp_turnbull_steps_child_any.csv`  
  - `jmp_turnbull_steps_adult_interfering.csv`  
  - `jmp_turnbull_steps_child_interfering.csv`  

Using these four CSV files, **Figure 2** can be fully reproduced.  

---

## 2) Supplementary Table 2 — Estimated prevalence with 95% CIs at selected time points, by epidemic periods

**Analysis tools:** JMP + R

**Steps:**
- Use the four CSV files generated in Step 1:  
  (`jmp_turnbull_steps_adult_any.csv`, `jmp_turnbull_steps_child_any.csv`,  
  `jmp_turnbull_steps_adult_interfering.csv`, `jmp_turnbull_steps_child_interfering.csv`)
- Run: `r/01_turnbull_prevalence_table.R`  
- Output: `outputs/supp_table2_prevalence_CI.csv`  

This R script calculates the estimated prevalence and 95% confidence intervals at predefined time points based on the Turnbull step estimates from JMP.

---

## 3) Table 2 — Adjusted hazard ratios for resolution of any post-COVID-19 symptoms

**Analysis tool:** R (interval-censored proportional hazards models using icenReg)

Individual-level data cannot be shared due to ethical restrictions, but the full analysis code and complete results are publicly available.

- Code: `r/02_icenReg_models.R`  
- Output: `outputs/hr_full_results.csv` (full regression results)

---

## 4) Figure 3 — Estimated prevalence of 13 post-COVID-19 symptoms at 3 and 12 months

**Analysis tools:** JMP + R

**Steps:**
- Input: `data/aggregated/13symptoms_turnbull_long.csv`  
- Run in JMP: `jmp/13symptoms_turnbull_survival.jsl`  
  → Output: `jmp_turnbull_steps_13symptoms.csv`  
- Then run in R: `r/03_symptom_prevalence_3m_12m.R`  
  → Output: `figure3_points.csv`  

`figure3_points.csv` contains the data required to reproduce **Figure 3**.

---

## Environment

- **R 4.4.1** (packages: *icenReg*, *readr*, *dplyr*)  
- **JMP 14** (SAS Institute Inc.)

---

## Data Availability

All aggregated datasets and analysis scripts are original outputs from this study and are openly available at [DOI].  
Individual-level data cannot be shared, as participants did not consent to external release and the IRB-approved protocol prohibits it.  

**For inquiries, please contact:**  
- **Hiroshima University IRB Office** (iryo-sinsa@office.hiroshima-u.ac.jp)  
- **Corresponding author:** Aya Sugiyama (aya-sugiyama@hiroshima-u.ac.j)
---

## License

- **Code (R scripts, JMP JSL/Journal)** — MIT License (see LICENSE)  
- **Data (aggregated CSVs)** — CC BY 4.0 License (see LICENSE-data)

---

## Citation

Please cite this repository as follows:  

**DOI:** [[![DOI](https://zenodo.org/badge/1069976469.svg)](https://doi.org/10.5281/zenodo.17375257)]  
**URL:** [https://github.com/USER/REPO]  

(Alternatively, use the **“Cite this repository”** button on GitHub if a *CITATION.cff* file is present.)
