#-------------------------------------------------------------------------------
#                           Descriptive Statistics
#-------------------------------------------------------------------------------

gc() # Clear cache
rm(list = ls()) # Remove objects

path = "/Users/bianca/Desktop/X/Policy in Action"

# install.packages("archive")
# install.packages("stringi")
# install.packages("stringr")
library(dplyr)
library(archive)
library(sf)
library(janitor)
library(stringi)
library(stringr)

#--Import Datasets--------------------------------------------------------------

sae_2024 = read.csv2(paste0(path, "/Data/Processed/SAE/2024/SAE_final_2024.csv"))
communes_pop = read.csv2(paste0(path, "/Data/Raw/SAE/Geography/Population Communes.csv"))
communes_geo = st_read(paste0(path, "/Data/Raw/SAE/Geography/Communes/communes-20220101.shp"))

#--Merge Datasets---------------------------------------------------------------

# Check column names
colnames(sae_2024)
colnames(communes_pop)
colnames(communes_geo)

# Remove row indices column in sae_2024
sae_2024 = sae_2024 %>%
  select(-"X")
colnames(sae_2024)

# Change column headers in communes_pop
communes_pop = communes_pop %>%
  row_to_names(row_number = 2, remove_rows_above = TRUE)

# Clean column names
communes_pop = clean_names(communes_pop)
communes_pop = communes_pop %>%
  rename("population" = "population_au_dernier_recensement_2022")
colnames(communes_pop)

# Clean commune names
## Define cleaning function
clean_communes = function(x){
  x %>%
    stringr::str_to_upper() %>%
    stringi::stri_trans_general("Latin-ASCII") %>%
    stringr::str_replace_all("-", " ")
}

## Apply to all datasets
sae_2024$town_name = clean_communes(sae_2024$town_name)
communes_pop$libelle = clean_communes(communes_pop$libelle)
communes_geo$nom = clean_communes(communes_geo$nom)

# Check commune code correspondence
## Keep relevant columns
sae_codes = sae_2024 %>%
  select(town_name, postal_code) %>%
  rename("name_commune" = "town_name")

pop_codes = communes_pop %>%
  select(libelle, code) %>%
  rename("name_commune" = "libelle")

geo_codes = communes_geo %>%
  select(nom, insee) %>%
  rename("name_commune" = "nom")

## Merge code datasets
merged_codes = sae_codes %>%
  full_join(pop_codes, by = "name_commune") %>%
  full_join(geo_codes, by = "name_commune")

## Check whether all codes match
merged_codes = merged_codes %>%
  mutate(code_match = 
           postal_code  == code & 
           postal_code == insee)

mismatches = merged_codes %>%
  filter(is.na(code_match) | code_match == FALSE)
nrow(mismatches)
nrow(merged_codes)

# Add INSEE codes to sae_codes
## Import dataset
insee_codes = read.csv2(paste0(path, "/Data/Raw/SAE/Geography/Code Communes.csv"),
                        fileEncoding = "latin1")

## Clean column names
insee_codes = insee_codes %>%
  rename("postal_code" = "Code_postal") %>%
  clean_names()
  
## Clean commune names
insee_codes$nom_de_la_commune = clean_communes(insee_codes$nom_de_la_commune)

## Merge datasets
### Merge by postal code + commune name
sae_insee = sae_codes %>%
  left_join(insee_codes %>%
              select(postal_code, nom_de_la_commune, x_code_commune_insee), 
            by = c("postal_code", "name_commune" = "nom_de_la_commune"))

### Merge by name only
sae_insee = sae_insee %>%
  left_join(insee_codes %>%
              select(nom_de_la_commune, x_code_commune_insee) %>% 
              distinct(),
            by = c("name_commune" = "nom_de_la_commune"),
            suffix = c("", "_byname")) %>%
  mutate(x_code_commune_insee = ifelse(is.na(x_code_commune_insee), 
                                       x_code_commune_insee_byname, 
                                       x_code_commune_insee)) %>%
  select(-x_code_commune_insee_byname)

### Merge by code only
sae_insee = sae_insee %>%
  left_join(insee_codes %>%
              select(postal_code, x_code_commune_insee) %>% 
              distinct(),
            by = "postal_code",
            suffix = c("", "_bypostal")) %>%
  mutate(x_code_commune_insee = ifelse(is.na(x_code_commune_insee), 
                                       x_code_commune_insee_bypostal, 
                                       x_code_commune_insee)) %>%
  select(-x_code_commune_insee_bypostal)

# Identify communes with more than one INSEE code
problem_communes = sae_insee %>%
  rename(
    town_name = name_commune,
    insee_code = x_code_commune_insee
  ) %>%
  group_by(town_name) %>%
  summarise(n_codes = n_distinct(insee_code), .groups = "drop") %>%
  filter(n_codes > 1) %>%
  pull(town_name)

# Add INSEE codes to sae_2024
sae_2024_insee = sae_2024 %>%
  left_join(
    sae_insee %>%
      rename(
        town_name = name_commune,
        insee_code = x_code_commune_insee
      ) %>%
      distinct(town_name, .keep_all = TRUE),
    by = c("town_name", "postal_code")
  ) %>%
  # Problem communes have INSEE codes set to NA
  mutate(
    insee_code = if_else(town_name %in% problem_communes, NA_character_, insee_code)
  ) %>%
  select(
    year,
    establishment_name,
    finess,
    region_number,
    region_name,
    dep_number,
    dep_name,
    town_name,
    postal_code,
    insee_code,
    everything()
  )

# Merge sae_2024_insee with communes_pop and communes_geo
## Split dataset: normal communes vs problematic communes
normal_communes = sae_2024_insee %>%
  filter(!town_name %in% problem_communes)

problematic_communes = sae_2024_insee %>%
  filter(town_name %in% problem_communes)

## Merge normal communes by INSEE code
normal_merged = normal_communes %>%
  left_join(communes_pop %>%
              rename(insee_code = code), 
            by = "insee_code") %>%
  left_join(communes_geo %>%
              rename(insee_code = insee),
            by = "insee_code")

## Merge problematic communes by commune name
problem_merged = problematic_communes %>%
  # Join by town_name
  left_join(communes_pop 
            %>% rename(town_name = libelle), 
            by = "town_name", suffix = c("", "_pop")) %>%
  left_join(communes_geo 
            %>% rename(town_name = nom) 
            %>% select(-wikipedia) %>% 
              st_drop_geometry(),
            by = "town_name", suffix = c("", "_geo")) %>%
  # After merging, collapse duplicates by FINESS
  group_by(finess) %>%
  slice(1) %>%
  ungroup()

## Combine all together
sae_2024_final = bind_rows(normal_merged, problem_merged) %>%
  # Drop duplicate and irrelevant columns
  select(-c("libelle", "nom", "wikipedia", "surf_ha", "code", "insee"))

# Export merged dataset
## GeoPackage
st_write(
  sae_2024_final,
  paste0(path, "/Data/Processed/SAE/2024/sae_2024_communes.gpkg"),
  layer = "sae_2024_final",
  delete_layer = TRUE
)
## CSV file
sae_2024_final %>%
  mutate(geometry = st_as_text(geometry)) %>%
  st_drop_geometry() %>%                     
  write.csv(paste0(path, "/Data/Processed/SAE/2024/sae_2024_communes.csv"), 
            row.names = FALSE)