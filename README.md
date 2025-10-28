## Shortages of Medical Personnel in Emergency Departments and Unexpected Closures (DREES – Policy in Action 2025/26)

Repository for the Policy in Action project conducted in collaboration between École Polytechnique (MSc Data & Economics for Public Policy) and DREES (Direction de la Recherche, des Études, de l’Évaluation et des Statistiques).

The project investigates how staffing levels in French emergency departments relate to partial or full closures, using administrative data (SAE, Enquête Urgences, RPU) and a newly built Emergency Department Closures Database (EDCD) assisted by an LLM-based web collection pipeline.

Main objectives:
* Analyze the evolution of emergency staffing (2014–2024) using DREES data.
* Develop and validate a semi-automated pipeline to detect ER closures (EDCD).
* Assess determinants of closures through descriptive and risk analyses.

Deliverables:
* Data management scripts (R & Python)
* Analytical notebooks (EDA, validation, modeling)
* Final report and presentation materials


```
PiA-DREES-2025/
│
├── README.md                <- Overview of the project, data, and usage.
├── LICENSE                  <- Repository license (default: MIT).
├── requirements.txt          <- Python dependencies for reproducibility.
│
├── data/
│   ├── raw/                 <- Original datasets (SAE, Urgences, RPU, ARS/EDCD).
│   ├── intermediate/        <- Cleaned or merged datasets.
│   └── processed/           <- Final validated datasets ready for analysis.
│
├── docs/
│   ├── meeting_notes/       <- Meeting summaries and project documentation.
│   └── examples/            <- Jupyter notebooks showing how to use the code.
│
├── src/                     <- Core code for data processing and analysis.
│   ├── exploratory/         <- Exploratory data analysis and initial checks.
│   ├── features/            <- Scripts to generate derived variables (ratios, indicators).
│   ├── models/              <- Statistical models, regressions, and risk analysis.
│   └── validation/          <- Scripts for cross-checks (EDCD vs RPU vs Urgences).
│
├── reports/
│   ├── figures/             <- Plots and visualizations.
│   ├── tables/              <- Exported summary tables.
│   └── outputs/             <- Generated reports (PDF, HTML, LaTeX).
│
├── edcd_pipeline/           <- LLM-assisted data collection pipeline.
│   ├── scraper/             <- Scripts to query ARS websites and extract closure info.
│   ├── parser/              <- Scripts to clean and structure extracted text.
│   └── utils/               <- Helper functions (e.g., validation, logging).
│
└── app/                     <- (Optional) Dash or Streamlit app for visual exploration.
```
