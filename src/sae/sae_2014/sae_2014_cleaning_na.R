#-------------------------------------------------------------------------------
#                                 Clean NAs
#-------------------------------------------------------------------------------

gc() # Clear cache
rm(list = ls()) # Remove objects

path = "/Users/bianca/Desktop/X/Policy in Action"

library(readxl)
library(dplyr)
library(tidyr)
library(readr)
library(httr)
library(readr)
library(janitor)
library(tidyverse)
library(stringr)
library(purrr)
library(ggplot2)
library(sf)
library(viridis)
library(scales)
library(tibble)
library(naniar)

# DATA CLEANING IS PERFORMED ON FULL DATASET

# 1. Import dataset
sae_2014 = read_csv2(paste0(path, "/Data/Processed/SAE/2014/sae_2014_main.csv"))
colnames(sae_2014)
sae_2014 = sae_2014 %>%
  select(-"...1") # Remove row index column

# 2. Redefine juridical status
sae_2014 = sae_2014 %>%
  # Create new variable for juridical status
  mutate(jur_status = case_match(stjr,
                                 1 ~ "Public",
                                 2 ~ "Privé non lucratif",
                                 3 ~ "Privé lucratif",)) %>%
  # Drop initial juridical status variable
  select(-stjr)

# 3. Redefine establishment capacity

# 3.1. Import dataset containing overall number of beds
usld = read.csv2(
  file = paste0(path, "/Data/Raw/SAE/SAE 2014/USLD_2014r.csv"),
  fileEncoding = "latin1")

# 3.1.1. Create temporary dataframe of joined SAE and USLD datasets
temp = sae_2014 %>%
  left_join(usld, by = c("fi" = "FI"))

# 3.3. Missing values

# 3.3.1. Compute percentage of NAs
sum(is.na(temp$LIT)) / length(temp$LIT) * 100
## 74.2025

# 3.3.2. Define function to group NAs
analyze_missing_pct = function(data, group_var, target_var) {
  data %>%
    group_by({{ group_var }}) %>%
    summarise(
      missing_percentage = sum(is.na({{ target_var }})) / n() * 100
    ) %>%
    arrange(desc(missing_percentage))
}

# 3.3.3. Apply to LIT
analyze_missing_pct(temp, jur_status, LIT)
## Privé non lucratif: 100%
## Privé lucratif: 90.7%
## Public: 67.3%

# 3.3.4. Remove temporary datasets
rm(usld)
rm(temp)

# 3.4. Capacity categorical variable

# 3.4.1. Compute thresholds
terciles = quantile(sae_2014$lit_uhcd, probs = c(0, 1/3, 2/3, 1), na.rm = TRUE)

# 3.4.2. Create categorical variable
sae_2014 = sae_2014 %>%
  mutate(capacity = case_when(
    lit_uhcd <= terciles[2] ~ "Low capacity",
    lit_uhcd <= terciles[3] ~ "Medium capacity",
    lit_uhcd >  terciles[3] ~ "High capacity"
  )) %>%
  # Set order in factor levels
  mutate(capacity = factor(capacity, 
                           levels = c("Low capacity", "Medium capacity", "High capacity")))

# 3.4.3. View establishments with NAs for number of beds
sae_2014 %>%
  #filter(is.na(lit_uhcd)) %>%
  select(rs, catr, capacity, dep, passu, lit_uhcd) %>%
  view()

# 3.4.4. Mean by catr
mean_by_catr = sae_2014 %>%
  group_by(catr) %>%
  summarise(mean_lit_uhcd_catr = mean(lit_uhcd, na.rm = TRUE), .groups = "drop")

# 3.4.5. Global mean in case one of catr has 100% of NAs
global_mean = mean(sae_2014$lit_uhcd, na.rm = TRUE)

# 3.4.6. Imputation
sae_2014 = sae_2014 %>%
  left_join(mean_by_catr, by = "catr") %>%
  mutate(
    lit_uhcd_imp = if_else(
      is.na(lit_uhcd),
      # If catr is NaN (group with no value), use global mean
      if_else(is.nan(mean_lit_uhcd_catr), global_mean, mean_lit_uhcd_catr),
      lit_uhcd
    )
  ) %>%
  select(-mean_lit_uhcd_catr)

# 3.4.7. Recompute terciles
terciles_imp = quantile(sae_2014$lit_uhcd_imp, probs = c(0, 1/3, 2/3, 1), na.rm = TRUE)

# 3.4.8. Create categorical variable
sae_2014 = sae_2014 %>%
  mutate(
    capacity = case_when(
      lit_uhcd_imp <= terciles_imp[2] ~ "Low capacity",
      lit_uhcd_imp <= terciles_imp[3] ~ "Medium capacity",
      lit_uhcd_imp >  terciles_imp[3] ~ "High capacity"
    ),
    # Set order in factor levels
    capacity = factor(capacity,
                      levels = c("Low capacity", "Medium capacity", "High capacity"))
  ) %>%
  # Drop "lit_uhcd" and "catr"
  select(-lit_uhcd) %>%
  select(-catr)

# 3.4.9. # Remove temporary datasets
rm(mean_by_catr)
rm(terciles)
rm(terciles_imp)

# 4. Merge with department and region files

# 4.1. Import geojson files
depts_geo = st_read(paste0(path, "/Data/Raw/SAE/departements.geojson"))
regs_geo = st_read(paste0(path, "/Data/Raw/SAE/regions.geojson"))

# 4.2. Prepare regions file for merging
regs_to_join = regs_geo %>% 
  rename(region_geometry = geometry) %>% 
  rename(region_name = nom) %>%
  as.data.frame()

# 4.3. Prepare departments file for merging
depts_geo = depts_geo %>%
  rename(dept_geometry = geometry) %>%
  rename(dept_name = nom)

# 4.4. Merge SAE with department and region files
sae_2014 = sae_2014 %>%
  mutate(dep = as.character(dep),
         reg = as.character(reg)) %>%
  left_join(depts_geo, by = c("dep" = "code")) %>%
  left_join(regs_to_join, by = c("reg" = "code")) %>%
  st_as_sf()

# 4.5. Remove temporary datasets
rm(depts_geo)
rm(regs_geo)
rm(regs_to_join)

# RENAMING VARIABLES: MOST RENAMED VARIABLES IN SAE 2024 ARE MISSING FROM SAE 2014

# 4.6. Overseas territories

# 4.6.1. Identify overseas territories rows
dom_indices = which(str_detect(sae_2014$dep, "^9[A-F]"))

# 4.6.2. Replace department name (NA) by region name
sae_2014$dept_name[dom_indices] = sae_2014$region_name[dom_indices]

# 4.6.3. Idem for geometry
st_geometry(sae_2014)[dom_indices] = st_geometry(sae_2014$region_geometry)[dom_indices]

# 4.6.4. Ensure that sae_2014 is recognized as spatial 
sae_2014 = sae_2014 %>%
  st_as_sf()

rm(dom_indices)

# 5. Missing values

# 5.1. Number and percentage of missing values per variable
miss_var_summary(sae_2014) %>%
  print(n = Inf)