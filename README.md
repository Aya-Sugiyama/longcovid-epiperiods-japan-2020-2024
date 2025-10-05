# Long-term Post-COVID-19 Symptoms by Epidemic Period (Japan, 2020–2024)

Reproducible materials for Turnbull interval-censored survival analyses of post-COVID-19 symptoms.  
**No individual-level data are included.** Aggregated CSVs and scripts reproduce the figures/tables.

## Contents
- `data/aggregated/` — Turnbull input tables (**long CSV**) + human-readable wide tables (UTF-8)
- `figures_underlying_data/` — CSVs actually used to draw figures (e.g., `figure2_points.csv`, `figure3_points.csv`)
- `r/` — R scripts (`icenReg`; prevalence at common times; figure generation)
- `jmp/` — JSL scripts and Journal for survival analyses
- `outputs/` — Full regression outputs (coefficients, SE, 95% CI, p, fit indices)

## How to reproduce (minimal)
1. **JMP 14+**  
   - Open `jmp/analysis.jrn` (or run `jmp/turnbull_survival.jsl`) to generate Turnbull survival curves from  
     `data/aggregated/S_Table1_turnbull_long.csv`.  
   - Export the plotted points if needed (we also provide `figures_underlying_data/figure2_points.csv`).

2. **R 4.4.1**  
   - Run:
     - `r/00_turnbull_points.R`  → common-time S(t) & CIs (Figure 2 underlying)  
     - `r/01_turnbull_prevalence_table.R`  → Supplementary Table 2  
     - `r/02_icenReg_models.R`  → interval-censored PH models (`icenReg`); writes outputs/hr_full_results.csv`      - `r/03_symptom_prevalence_3m_12m.R`  → Figure 3 (13 symptoms; 3 & 12 months)  
   - Results are written to `outputs/` and `figures_underlying_data/`.

## Environment
- **R** 4.4.1 (packages: `icenReg`, `readr`, `dplyr`, `ggplot2`)  
- **JMP** 14 (SAS Institute)

## Data availability
Aggregated minimal datasets and all analysis code are openly available at **[DOI]**.  
Individual-level data cannot be shared (no participant consent; IRB-approved protocol prohibits external release).  
Inquiries: Hiroshima University IRB office (**iryo-sinsa@office.hiroshima-u.ac.jp**).

## License
- **Code** (R scripts, JMP JSL/Journal): MIT (see `LICENSE`)  
- **Data** (aggregated CSVs): CC BY 4.0 (see `LICENSE-data`)

## Citation
Please cite the repository:  
**DOI:** [Zenodo Concept DOI]  
**URL:** [https://github.com/USER/REPO]  
(You may also use the GitHub “Cite this repository” button if `CITATION.cff` is present.)


