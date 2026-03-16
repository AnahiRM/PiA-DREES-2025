# EDCD Pipeline Overview

The EDCD pipeline follows two main stages.

## 1. Information Retrieval

Relevant documents mentioning emergency department disruptions are retrieved from the web using the **Tavily API**. 

Search queries target combinations of:

- hospital names  
- emergency department terminology  
- disruption keywords (closure, regulation, restriction, etc.)

Retrieved documents may include:

- ARS announcements  
- hospital communications  
- local press articles  

Results are stored as structured JSON entries containing:

- title  
- URL  
- content snippet  
- publication metadata 


**Notebook**  
`01_information_retrieval.ipynb`

**Output example**  
[View Retrieved Data](https://github.com/AnahiRM/PiA-DREES-2025/blob/main/data/intermediate/raw_edcd_database_atomic.jsonl)

---

## 2. Event Information Extraction

The retrieved documents are then processed using a locally hosted **Mistral-7B-Instruct** model served through **vLLM**.

The model extracts structured attributes describing the disruption event.

The extraction schema includes:

- hospital name  
- disruption status  
- disruption type  
- start date  
- end date  
- reason for disruption  

Results are saved as structured JSON records.


**Notebook**  
`02_data_collection.ipynb`

**Output example**  
[View Processed Data](https://raw.githubusercontent.com/AnahiRM/PiA-DREES-2025/main/data/intermediate/llm_output.jsonl)

---

# Known Challenges

Extracting structured information from public reports presents several challenges:

- documents may mention **multiple hospitals**
- dates may be **relative or implicit** (e.g. "this weekend")
- disruption terminology varies across sources
- generative models may produce **inconsistent output formats**

These challenges motivate the use of **schema-constrained extraction or specialized information extraction models** in future iterations of the pipeline.
