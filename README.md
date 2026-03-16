## Emergency Department Closures and Staffing Shortages in France (DREES – Policy in Action 2025/26)

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
├── README.md                <- Overview of the project, pipeline, and repository structure.
├── LICENSE                  <- Repository license.
├── enquete_analysis.Rproj   <- RStudio project configuration.
│
├── data/
│   ├── raw/                 <- Original datasets (SAE administrative data, population data, geographic files).
│   ├── intermediate/        <- Intermediate outputs generated during the EDCD pipeline (web retrieval and LLM extraction) and the SAE data cleaning.
│   │   ├── raw_edcd_database_atomic.jsonl
│   │   ├── llm_output.jsonl
│   │   └── sae_2024         <- Intermediate datasets generated during data processing.
│   └── processed/           <- Cleaned datasets used for analysis.
│
├── docs/
│   ├── admin/               <- Administrative documents and Policy-in-Action project material.
│   ├── examples/            <- Example documentation and usage notes.
│   └── SAE_2024/            <- Documentation and metadata for the SAE hospital dataset.
│
├── edcd_pipeline/           <- Notebooks implementing the EDCD data collection pipeline.
│   ├── information_retrieval.ipynb   <- Web search pipeline using Tavily.
│   ├── data_collection.ipynb         <- LLM extraction pipeline using Mistral-7B.
│   └── example/                      <- Example notebook demonstrating the web retrieval process.
│
├── code/                    <- Scripts for data cleaning and statistical analysis.
│   ├── sae_2024             <- RMarkdown scripts for cleaning and analyzing the SAE 2024 dataset.
│   ├── sae_2014             <- R scripts for SAE 2014 data processing.
│   └── enquete_urgences/    <- Scripts for emergency department survey analysis.
│
├── outputs/
│   ├── SAE_2024_v2           <- Figures and visual outputs generated during the 2nd version of the SAE analysis.
│   └── SAE_2024_v3           <- Figures and visual outputs generated during the 3rd version of the SAE analysis.
│
└── presentations/           <- Project presentation materials.
    └── Staffing_Shortages_and_Emergency_Department_Closures_in_France.pdf 
```
