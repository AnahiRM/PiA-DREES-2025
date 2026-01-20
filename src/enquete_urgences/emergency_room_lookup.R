#-------------------------------------------------------------------------------
#                         List of Emergency Room Names                             
#-------------------------------------------------------------------------------

library(dplyr)

# Open Enquète Urgences dataset
enquete_2023 = read.csv2(
  file = paste0(path, "/Data/Raw/CSV/2023 Enquête Urgences Structure (CSV).csv"),
  fileEncoding = "latin1") # Decode accented characters

# Select relevant columns
colnames(enquete_2023)
er_names = enquete_2023 %>%
  select("ID_POINT_D_ACCUEIL", "FINESS", "STR_A1") %>% # Keep ID, FINESS code, and ER name
  distinct() # Remove possible duplicates
View(er_names)

# Open dataset with list of health establishments
health_est = read.csv2(
  file = paste0(path, "/Data/Raw/CSV/Extraction FINESS.csv"),
  header = FALSE, # Read first row as data
  fileEncoding = "UTF-8", # Decode accented characters
  fill = TRUE)
View(health_est)

# Clean data
## Edit column names
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
## Remove first row
health_est = health_est[-1,]

# Missing values
sum(is.na(health_est)) # Number of missing values
unique(health_est$complrs) # Some NAs appear as ""
health_est = as.data.frame(
  lapply(health_est, function(x) {
    x = trimws(x) # Remove leading/trailing spaces
    x[x == ""] = NA # Replace empty strings with NA
    x
  }),
  stringsAsFactors = FALSE)
sum(is.na(health_est)) # Number of missing values has increased

# Merge datasets
er_data = left_join(er_names, health_est, 
                    by = c(
                      "FINESS" = "finess_et",
                      "STR_A1" = "rais_soc"
                    ))
View(er_data)

# Clean merged dataset
colnames(er_data)
er_data = er_data %>%
  select(
    "id" = "ID_POINT_D_ACCUEIL",
    "finess" = "FINESS",
    "nom_etab" = "STR_A1",
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

# Save dataset as CSV
write.csv2(er_data,  paste0(path, "/Data/Intermediate/Emergency Room Lookup.csv"))