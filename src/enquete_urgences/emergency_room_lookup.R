#-------------------------------------------------------------------------------
#                         List of Emergency Room Names                             
#-------------------------------------------------------------------------------

gc() # Clear cache
rm(list = ls()) # Remove objects

path = "/Users/bianca/Desktop/X/Policy in Action"

library(dplyr)
library(naniar)

# 1. Open Enquète Urgences dataset

# Open dataset

enquete_2023 = read.csv2(
  file = paste0(path, "/Data/Raw/Enquête Urgences/CSV/2023 Enquête Urgences Structure (CSV).csv"),
  fileEncoding = "latin1") # Decode accented characters

# 2. Select relevant columns
colnames(enquete_2023)
er_names = enquete_2023 %>%
  select("ID_POINT_D_ACCUEIL", "FINESS", "STR_A1") %>% # Keep ID, FINESS code, and ER name
  distinct() # Remove possible duplicates
View(er_names)

# 3. Number of missing values
sum(is.na(er_names))

# 4. Open dataset with list of health establishments
health_est = read.csv2(
  file = paste0(path, "/Data/Raw/Enquête Urgences/CSV/Extraction FINESS.csv"),
  header = FALSE, # Read first row as data
  fileEncoding = "UTF-8", # Decode accented characters
  fill = TRUE)
View(health_est)

# 5. Number of missing values of main variable of interest: "Ligne d’acheminement"
sum(is.na(health_est$V16))

# 6. Clean data

# 6.1. Edit column names
head(health_est)
names(health_est) = c(
  "section", # Section
  "finess_et", # Numéro FINESS ET
  "finess_ej", # Numéro FINESS EJ
  "rais_soc", # Raison sociale
  "rais_soc_long", # Raison sociale longue
  "compl_rais_soc", # Complément de raison sociale
  "compl_distr", # Complément de distribution
  "num_voie", # Numéro de voie
  "typ_voie", # Type de voie
  "lib_voie", # Libellé de voie
  "compl_voie", # Complément de voie
  "lieudit_bp", # Lieu-dit/BP
  "comm", # Code commune
  "dept", # Département
  "lib_dept", # Libellé département
  "achemin", # Ligne d’acheminement (Code Postal + Libellé commune)
  "tel", # Téléphone
  "telecopie", # Télécopie
  "categ_etab", # Catégorie d’établissement
  "lib_categ_etab", # Libelle catégorie d’établissement
  "categ_etab_agr", # Catégorie d’agrégat d’établissement
  "lib_etab", # Libellé catégorie d’agrégat d’établissement
  "siret", # Numéro de SIRET
  "code_ape", # Code APE
  "code_mft", # Code MFT
  "lib_mft", # Libelle MFT
  "code_sph", # Code SPH
  "lib_sph", # Libelle SPH
  "date_ouv", # Date d’ouverture
  "date_autor", # Date d’autorisation
  "date_maj", # Date de mise à jour sur la structure
  "num_educ" # Numéro éducation nationale
)

# 6.2. Remove first row
health_est = health_est[-1,]

# 7. Missing values

# 7.1. Number of missing values of main variable of interest: "Ligne d’acheminement"
sum(is.na(health_est$achemin))
## 0 NAs

# 7.2. Total number of missing values
sum(is.na(health_est))

# 7.3. Table of missing values per variable
miss_var_summary(health_est) %>%
  print(n = Inf)

# 7.4. Empty strings

# 7.4.1. Number of empty strings
sum(health_est$compl_rais_soc == "", na.rm = TRUE)

# 7.4.2. Convert empty strings into NAs
health_est = as.data.frame(
  lapply(health_est, function(x) {
    x = trimws(x) # Remove leading/trailing spaces
    x[x == ""] = NA # Replace empty strings with NA
    x
  }),
  stringsAsFactors = FALSE)

# 7.4.3. Check missing values
sum(is.na(health_est)) 
## Number of missing values has increased
miss_var_summary(health_est) %>%
  print(n = Inf)

# 8. Merge datasets

# 8.1. Check dataset correspondence

# 8.1.1. Number of ER names
sum(!is.na(er_names$STR_A1)) # er_names dataframe
sum(!is.na(health_est$rais_soc)) # health_est dataframe
length(unique(health_est$rais_soc[!is.na(health_est$rais_soc)])) # Account for duplicates
## er_names has a much lower number of ERs: 715 v. 92454

# 8.1.2. Check whether FINESS codes match
setdiff(er_names$FINESS, health_est$finess_et)
## Missing FINESS code in health_est: 2A0000022

# 8.1.3. Check name of missing hospital
er_names[er_names$FINESS %in% setdiff(er_names$FINESS, health_est$finess_et), c("FINESS", "STR_A1")]
## Missing hospital in health_est: CH ND LA MISERICORDE

# 8.1.4. Check whether ER names match
setdiff(er_names$STR_A1, health_est$rais_soc)
## 127 names don't match: will only merge by FINESS code

# 9. Merge
er_data = left_join(er_names, health_est, by = c("FINESS" = "finess_et"))
View(er_data)

# 9.1. Check missing values of variable of interest
sum(is.na(er_data$achemin)) # Number
er_data[is.na(er_data$achemin), c("achemin", "FINESS")] # Corresponding FINESS code

# 10. Clean merged dataset

# 10.1. Column names
colnames(er_data)

# 10.2. Clean column names
er_data = er_data %>%
  select(
    "id" = "ID_POINT_D_ACCUEIL",
    "finess" = "FINESS",
    "nom_etab_1" = "STR_A1", # ER name from er_names dataframe
    "nom_etab_2" = "rais_soc", # ER name from health_est dataframe
    "nom_etab_long" = "rais_soc_long",
    "compl_etab" = "compl_rais_soc",
    "compl_distr",
    "achemin",
    "comm",
    "dept",
    "lib_dept",
    "num_voie",
    "typ_voie",
    "lib_voie",
    "categ_etab",
    "lib_categ_etab",
    "categ_etab_agr",
    "lib_etab",
    "siret",
    "code_ape",
    "code_mft",
    "lib_mft",
    "code_sph",
    "lib_sph",
    "date_ouv",
    "date_autor",
    "date_maj",
    "num_educ")

# 10.3. View ER names that correspond
View(er_data[er_data$nom_etab_1 != er_data$nom_etab_2, c("finess", "nom_etab_1", "nom_etab_2")])
## Lack of name correspondence is due to spelling differences or incomplete names

# 11. Save dataset as CSV
write.csv2(er_data,  paste0(path, "/Data/Intermediate/Enquête Urgences/Emergency Room Lookup.csv"))

# Save dataset
write.csv2(er_names,  paste0(path, "/Data/Emergency Room Lookup.csv")) # Save as CSV file