#-------------------------------------------------------------------------------
#                                 Merge Datasets
#-------------------------------------------------------------------------------

gc() # Clear cache
rm(list = ls()) # Remove objects

path = "/Users/bianca/Desktop/X/Policy in Action"

library(readxl)
library(dplyr)
library(tidyr)
library(readr)
library(httr)
library(jsonlite)
library(readr)
library(janitor)
library(tidyverse)
library(stringr)
library(purrr)

# 1. Open relevant datasets

identification1 = read.csv2(
  file = paste0(path, "/Data/Raw/SAE/SAE 2014/ID_2014r.csv"),
  fileEncoding = "latin1")

identification2 = read.csv2(
  file = paste0(path, "/Data/Raw/SAE/SAE 2014/IDB_2014r.csv"),
  fileEncoding = "latin1")

urgences1 = read.csv2(
  file = paste0(path, "/Data/Raw/SAE/SAE 2014/URGENCES_2014r.csv"),
  fileEncoding = "latin1")

urgences2 = read.csv2(
  file = paste0(path, "/Data/Raw/SAE/SAE 2014/URGENCES2_2014r.csv"),
  fileEncoding = "latin1")

## personnel_urg1: information on ER personnel is contained in column "HMED" of URGENCES2_2014r.csv

personnel_urg2 = read.csv2(
  file = paste0(path, "/Data/Raw/SAE/SAE 2014/URGENCES_P_2014r.csv"),
  fileEncoding = "latin1")

personnel_interns = read.csv2(
  file = paste0(path, "/Data/Raw/SAE/SAE 2014/Q22_2014r.csv"),
  fileEncoding = "latin1")

## synthesis: no comparable 2014 dataset

# 2. Clean datasets

# 2.1. identification1 & identification2

# 2.1.2. Remove unnecessary columns

## Compare column names in 2014 and 2024 dataset
### Open 2024 dataset
identification1_2024 = read.csv2(
  file = paste0(path, "/Data/Raw/SAE/SAE 2024/ID_2024r.csv"),
  fileEncoding = "latin1")
### Compare column names
list(
  cols_2014_only = setdiff(toupper(colnames(identification1)),
                           toupper(colnames(identification1_2024))),
  cols_2024_only = setdiff(toupper(colnames(identification1_2024)),
                           toupper(colnames(identification1)))
)
##### "TSANT" and "ARM" only appear in the 2014 dataset, while "COM" (2014)
##### been changed to "COMMINSEE" (2024)

### Remove columns from 2014 dataset
identification1 = identification1 %>%
  select(-c("bor", "rscom", "grp", "espic", "ccr", "nat", "sir", "reg_diff",
            "dep_diff", "ARMT", "ETAT_SAISIE", "VAGUE", "PROVENANCE", "NUMVOI", 
            "TYPVOI", "NOMVOI", "BP", "COMPD", "FILIALE0", "SIRTET", "RSTET", 
            "MODEJ", "FINRAT", "TSANT", "ARM"), 
         -starts_with(c("FIAUT", "RSAUT", "DADS_", "TYPMD", "FIFU", "SCFU", "VAL", "RESPREG")))

### Do the same for 2024 for comparison purposes
identification1_2024 = identification1_2024 %>%
  select(-c("bor", "rscom", "grp", "espic", "ccr", "nat", "sir", "reg_diff", 
            "dep_diff", "ARMT", "ETAT_SAISIE", "VAGUE", "PROVENANCE", "NUMVOI", 
            "TYPVOI", "NOMVOI", "BP", "COMPD", "FILIALE0", "SIRTET", "RSTET", 
            "MODEJ", "FINRAT"), 
         -starts_with(c("FIAUT", "RSAUT", "DADS_", "TYPMD", "FIFU", "SCFU", "VAL", "RESPREG")))
### Compare columns left in both datasets
list(
  cols_2014_only = setdiff(toupper(colnames(identification1)),
                           toupper(colnames(identification1_2024))),
  cols_2024_only = setdiff(toupper(colnames(identification1_2024)),
                           toupper(colnames(identification1)))
)
#### Both datasets contain the same columns

### Drop 2024 dataset as it is no longer useful
rm(identification1_2024)

# 2.1.2. Repeat for identification2 dataframe

identification2_2024 = read.csv2(
  file = paste0(path, "/Data/Raw/SAE/SAE 2024/IDB_2024r.csv"),
  fileEncoding = "latin1")

list(
  cols_2014_only = setdiff(toupper(colnames(identification2)),
                           toupper(colnames(identification2_2024))),
  cols_2024_only = setdiff(toupper(colnames(identification2_2024)),
                           toupper(colnames(identification2)))
)
## "TSANT" only appears in 2014

identification2 = identification2 %>%
  select(-c("BOR", "GRP", "ESPIC", "CCR", "NAT", "SIR", "ARMT", "VAGUE", 
            "NUMTEL", "COMPRS", "NUMVOI", "TYPVOI", "ADRVOIENOM", "COMPDist", 
            "ADRLIBCOM", "COMINSEE", "ADRBP", "TSANT"))

identification2_2024 = identification2_2024 %>%
  select(-c("BOR", "GRP", "ESPIC", "CCR", "NAT", "SIR", "ARMT", "VAGUE", 
            "NUMTEL", "COMPRS", "NUMVOI", "TYPVOI", "ADRVOIENOM", "COMPDist", 
            "ADRLIBCOM", "COMINSEE", "ADRBP"))

list(
  cols_2014_only = setdiff(toupper(colnames(identification2)),
                           toupper(colnames(identification2_2024))),
  cols_2024_only = setdiff(toupper(colnames(identification2_2024)),
                           toupper(colnames(identification2)))
)
## Both datasets contain the same columns

rm(identification2_2024)

# 2.1.3. Standardize column names
identification1 = janitor::clean_names(identification1)
identification2 = janitor::clean_names(identification2)

# 2.1.4. Harmonize column names and add source column
identification1 = identification1 %>%
  mutate(source = "id1")

identification2 = identification2 %>%
  rename(cpo = adrcpost) %>%
  mutate(source = "id2")

# 2.1.5. Convert cpo to character in identification2
identification2 = identification2 %>%
  mutate(cpo = as.character(cpo))

# 2.1.6. Merge identification datasets
identification = bind_rows(identification1, identification2)

# 2.2. urgences1

# 2.2.1. Remove unnecessary columns

## Compare column names in 2014 and 2024 dataset
### Open 2024 dataset
urgences1_2024 = read.csv2(
  file = paste0(path, "/Data/Raw/SAE/SAE 2024/URGENCES_2024r.csv"),
  fileEncoding = "latin1")
### Compare column names
list(
  cols_2014_only = setdiff(toupper(colnames(urgences1)),
                           toupper(colnames(urgences1_2024))),
  cols_2024_only = setdiff(toupper(colnames(urgences1_2024)),
                           toupper(colnames(urgences1)))
)
#### Only in 2014: "SPEC", "CARD", "CHIR", "NEURO", "OPHTA", "AUTRE", "RPU", "TRSPU"
#### Only in 2024: "RS", "AUTMEDURG", "EX_GEN", "EX_PED", "REOR", "REOR_MOE", "OUTIL"

### Remove columns from 2014 dataset
urgences1 = urgences1 %>%
  select(-c("BOR", "SPEC", "CARD", "CHIR", "NEURO", "OPHTA", "AUTRE", "RPU", "TRSPU"))

### Do the same for 2024 for comparison purposes
urgences1_2024 = urgences1_2024 %>%
  select(-"BOR")

### Compare columns left in both datasets
list(
  cols_2014_only = setdiff(toupper(colnames(urgences1)),
                           toupper(colnames(urgences1_2024))),
  cols_2024_only = setdiff(toupper(colnames(urgences1_2024)),
                           toupper(colnames(urgences1)))
)
#### Extra columns in 2024: "RS", "AUTMEDURG", "EX_GEN", "EX_PED", "REOR", "REOR_MOE", "OUTIL"

### Drop 2024 dataset as it is no longer useful
rm(urgences1_2024)

# 2.2.2. Standardize column names
urgences1 = janitor::clean_names(urgences1)

# 2.2.3. Check that all FINESS numbers in urgences1 are in identification
all(urgences1$fi %in% identification$fi)
## TRUE

# 2.2.4. Check that no dataset has duplicates
n_distinct(urgences1$fi, na.rm = TRUE) ==
  sum(!is.na(urgences1$fi))
n_distinct(identification$fi, na.rm = TRUE) ==
  sum(!is.na(identification$fi))
## Number of distinct values equals number of non-NAs

# 2.2.5. Check NAs
sum(is.na(urgences1$fi))
sum(is.na(identification$fi))
## 0 NAs

# 2.2.6. Print columns that are in both datasets
intersect(names(urgences1), names(identification))

# 2.2.7. Reshape urgences1
urgences1 = urgences1 %>%
  janitor::clean_names() %>%
  # Pivot on columns of actual activity
  pivot_longer(
    cols = c(autgen, autped), 
    names_to = "urg_type", 
    values_to = "passu_check"
  ) %>%
  # Harmonize so it matches urgences2 (GEN, PED)
  mutate(urg = case_when(
    urg_type == "autgen" ~ "GEN",
    urg_type == "autped" ~ "PED",
    TRUE ~ NA_character_
  )) %>%
  # Only keep rows where there is ativity
  filter(!is.na(passu_check) & passu_check > 0)

# 2.2.8. Merge urgences1 and identification datasets

## Merge and get rid of possible duplicates
SAE_main = identification %>%
  inner_join(
    urgences1 %>%
      select(-any_of(setdiff(intersect(names(urgences1), names(identification)), "fi"))),
    by = "fi"
  )

## Check that some rows have id2 source
SAE_main %>%
  filter(source == "id2") %>%
  nrow() # 0

## Remove "source" column
SAE_main = SAE_main %>%
  select(-"source")

# 2.3. urgences2

# 2.3.1. Remove unnecessary columns

## Compare column names in 2014 and 2024 dataset
### Open 2024 dataset
urgences2_2024 = read.csv2(
  file = paste0(path, "/Data/Raw/SAE/SAE 2024/URGENCES2_2024r.csv"),
  fileEncoding = "latin1")
### Compare column names
list(
  cols_2014_only = setdiff(toupper(colnames(urgences2)),
                           toupper(colnames(urgences2_2024))),
  cols_2024_only = setdiff(toupper(colnames(urgences2_2024)),
                           toupper(colnames(urgences2)))
)
#### Only in 2014: "HMED", "HIDE"
#### Only in 2024: "RS", "REG", "DTHAD", "DTHAD80", "DTHAD18", "DTTRANS", 
#### "ACCSPE_PED", "ACCSPE_PSY", "ACCSPE_GER", "ACCSPE_AUT", "IMPL_SMUR_SITE", 
#### "CONVURG24", "FICONV", "OUV_SEMAINE", "AMPL_SEMAINE", "OUV_SAM", "AMPL_SAM", 
#### "OUV_DIMFERIE", "AMPL_DIMFERIE"

colnames(urgences2)

### Remove columns from 2014 dataset
urgences2 = urgences2 %>%
  select(-"BOR")

### Do the same for 2024 for comparison purposes
urgences2_2024 = urgences2_2024 %>%
  select(-"BOR")

### Compare columns left in both datasets
list(
  cols_2014_only = setdiff(toupper(colnames(urgences2)),
                           toupper(colnames(urgences2_2024))),
  cols_2024_only = setdiff(toupper(colnames(urgences2_2024)),
                           toupper(colnames(urgences2)))
)
#### Only in 2014: "HMED", "HIDE"
#### Only in 2024: "RS", "REG", "DTHAD", "DTHAD80", "DTHAD18", "DTTRANS", 
#### "ACCSPE_PED", "ACCSPE_PSY", "ACCSPE_GER", "ACCSPE_AUT", "IMPL_SMUR_SITE", 
#### "CONVURG24", "FICONV", "OUV_SEMAINE", "AMPL_SEMAINE", "OUV_SAM", "AMPL_SAM", 
#### "OUV_DIMFERIE", "AMPL_DIMFERIE"

### Drop 2024 dataset as it is no longer useful
rm(urgences2_2024)

# 2.3.2. Standardize column names
urgences2 = janitor::clean_names(urgences2)

# 2.3.3. Check that all FINESS numbers in SAE_main are in urgences2

all(SAE_main$fi %in% urgences2$fi)
## FALSE: check how many don't match
sum(!SAE_main$fi %in% urgences2$fi)
## 2 don't match: view non-matching values
unique(SAE_main$fi[!SAE_main$fi %in% urgences2$fi])
## Get hospital names
SAE_main %>%
  filter(!fi %in% urgences2$fi) %>%
  select(fi, rs)
### urgences 2 is missing "CENTRE HOSPITALIER STE FOY LA GRANDE" and
### "C.H. EAUBONNE MONTMORENCY -SIMONE VEIL"

# 2.3.4. Print columns that are in both datasets
intersect(names(SAE_main), names(urgences2))

# 2.3.5. Merge and get rid of possible duplicates
SAE_main = SAE_main %>%
  inner_join(
    urgences2 %>%
      select(-any_of(setdiff(intersect(names(urgences2), names(SAE_main)), c("fi", "urg")))),
    by = c("fi", "urg")
  )

# 2.4. personnel_urg1: column "HMED" from URGENCES2_2014r.csv

# 2.5. personnel_urg2

# 2.5.1. Remove unnecessary columns

## Compare column names in 2014 and 2024 dataset
### Open 2024 dataset
personnel_urg2_2024 = read.csv2(
  file = paste0(path, "/Data/Raw/SAE/SAE 2024/PCAMEDURG_P_2024r.csv"),
  fileEncoding = "latin1")
### Compare column names
list(
  cols_2014_only = setdiff(toupper(colnames(personnel_urg2)),
                           toupper(colnames(personnel_urg2_2024))),
  cols_2024_only = setdiff(toupper(colnames(personnel_urg2_2024)),
                           toupper(colnames(personnel_urg2)))
)
#### Only in 2014: "EFFPL", "EFFPA", "ETP", "COMSMUR"
#### Only in 2024: "RS", "ETPSAL_TOT", "ETPSAL_URG", "ETPSAL_SMUR", "ETPSAL_SAMU", 
#### "EFFLIB_TOT", "EFFLIB_URG", "EFFLIB_SMUR", "EFFLIB_SAMU", "COM_SMUR_SU"

### Remove columns from 2014 dataset
personnel_urg2 = personnel_urg2 %>%
  select(-"BOR")

### Do the same for 2024 for comparison purposes
personnel_urg2_2024 = personnel_urg2_2024 %>%
  select(-"BOR")

### Compare columns left in both datasets
list(
  cols_2014_only = setdiff(toupper(colnames(personnel_urg2)),
                           toupper(colnames(personnel_urg2_2024))),
  cols_2024_only = setdiff(toupper(colnames(personnel_urg2_2024)),
                           toupper(colnames(personnel_urg2)))
)
#### Only in 2014: "EFFPL", "EFFPA", "ETP", "COMSMUR"
#### Only in 2024: "RS", "ETPSAL_TOT", "ETPSAL_URG", "ETPSAL_SMUR", "ETPSAL_SAMU", 
#### "EFFLIB_TOT", "EFFLIB_URG", "EFFLIB_SMUR", "EFFLIB_SAMU", "COM_SMUR_SU"

### Drop 2024 dataset as it is no longer useful
rm(personnel_urg2_2024)

# 2.5.2. Keep only rows where PERSO = "M9999" (total personnel medical)
personnel_urg2 = personnel_urg2 %>%
  filter(PERSO == "M9999")

# 2.5.3. Remove "PERSO" and "MOD" columns
personnel_urg2 = personnel_urg2 %>%
  select(-c("PERSO", "MOD"))

# 2.5.4. Standardize column names
personnel_urg2 = janitor::clean_names(personnel_urg2)

# 2.3.4. Print columns that are in both datasets
intersect(names(SAE_main), names(personnel_urg2))

# 2.3.5. Merge and get rid of possible duplicates
SAE_main <- SAE_main %>%
  left_join( # keep medical structure even if it has no personnel_urg2 data
    personnel_urg2 %>%
      select(-any_of(setdiff(intersect(names(SAE_main), names(personnel_urg2)), "fi"))),
    by = "fi"
  )

# 2.6. personnel_interns

# 2.6.1. Remove unnecessary columns

## Compare column names in 2014 and 2024 dataset
### Open 2024 dataset
personnel_interns_2024 = read.csv2(
  file = paste0(path, "/Data/Raw/SAE/SAE 2024/Q22_2024r.csv"),
  fileEncoding = "latin1")
### Compare column names
list(
  cols_2014_only = setdiff(toupper(colnames(personnel_interns)),
                           toupper(colnames(personnel_interns_2024))),
  cols_2024_only = setdiff(toupper(colnames(personnel_interns_2024)),
                           toupper(colnames(personnel_interns)))
)
#### Only in 2014: "INTTOT"
#### Only in 2024: "RS", "DOCJU_MED", "DOCJU_PHA", "DOCJU_ODO", "INTURG", 
#### "DOCJU_URG", "INT", "DOCJU", "DTSTAG"
#### Correspondence between variables: "INTTOT" = "INT"

### Remove columns from 2014 dataset
personnel_interns = personnel_interns %>%
  select(-"BOR")

### Do the same for 2024 for comparison purposes
personnel_interns_2024 = personnel_interns_2024 %>%
  select(-"BOR")

### Compare columns left in both datasets
list(
  cols_2014_only = setdiff(toupper(colnames(personnel_interns)),
                           toupper(colnames(personnel_interns_2024))),
  cols_2024_only = setdiff(toupper(colnames(personnel_interns_2024)),
                           toupper(colnames(personnel_interns)))
)
#### Only in 2014: "INTTOT"
#### Only in 2024: "RS", "DOCJU_MED", "DOCJU_PHA", "DOCJU_ODO", "INTURG", 
#### "DOCJU_URG", "INT", "DOCJU", "DTSTAG"

### Drop 2024 dataset as it is no longer useful
rm(personnel_interns_2024)

# 2.6.2. Standardize column names
personnel_interns = janitor::clean_names(personnel_interns)

# 2.6.3. Print columns that are in both datasets
intersect(names(SAE_main), names(personnel_interns))

# 2.6.4. Merge and get rid of possible duplicates
SAE_main = SAE_main %>%
  left_join( # keep medical structure even if it has no interns
    personnel_interns %>%
      select(-any_of(setdiff(intersect(names(SAE_main), names(personnel_interns)), "fi"))),
    by = "fi"
  )

# 3. Export cleaned dataset
write.csv2(SAE_main,  paste0(path, "/Data/Processed/SAE/2014/sae_2014_main.csv"))

# 4. Create less exhaustive dataset

# 4.1. Check whether 2024 columns are in 2014 dataset
cols_2024 = c("an", "fi", "rs", "catr", "stjr", "rs", "reg", "dep", "nomcom", 
              "cpo", "urg", "regulation", "passu", "dt_hosp", "stap", "lit_uhcd",
              "hmed_tot", "hmed_urg", "hide_tot", "hide_urg", "hamb_tot", "hmr_tot",
              "hmramu_tot", "arm_tot", "osnp_tot", "com_smur_su", "etpsal_tot", 
              "etpsal_urg", "efflib_tot", "efflib_urg", "intmed", "docju_med", 
              "inturg", "docju_urg", "efflib_tot", "etpsal_tot")

# 4.2. Non-coinciding columns 
cols_2024 %in% names(SAE_main)
setdiff(cols_2024, names(SAE_main))
## Missing columns in 2014 dataset: "regulation", "hmed_tot", "hmed_urg", "hide_tot", 
## "hide_urg", "hamb_tot", "hmr_tot", "hmramu_tot", "arm_tot", "osnp_tot", "com_smur_su", 
## "etpsal_tot", "etpsal_urg", "efflib_tot", "efflib_urg", "docju_med", "inturg", "docju_urg"
### Most of these come from the PCAMEDURG_2024r dataset
### Corresponding variables in 2014 dataset: "hmed_urg" = "hmed", "hide_urg" = "hide", 
### "com_smur_su" = "comsmur", "etpsal_tot" = "etpsalh" + "etpsalf", "efflib_tot" = "efflib"
### Comparable variables: "etpsal_urg" = "etp" (salaried and non-), 

# 4.3. Coinciding columns
intersect(cols_2024, names(SAE_main))

# A LOT OF COLUMNS IN SAE 2024 ARE MISSING FROM SAE 2014: SHORT DATASET MIGHT BE TOO SHORT