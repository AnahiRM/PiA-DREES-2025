#-------------------------------------------------------------------------------
#                         List of Emergency Room Names                             
#-------------------------------------------------------------------------------

library(dplyr)

# Open dataset
enquete_2023 = read.csv2(
  file = paste0(path, "/Data/Raw/CSV/2023 Enquête Urgences Structure (CSV).csv"),
  fileEncoding = "latin1") # Decode accented characters

# Select relevant columns
colnames(enquete_2023)
er_names = enquete_2023 %>%
  select("ID_POINT_D_ACCUEIL", "FINESS", "STR_A1") %>% # Keep ID, FINESS code, and ER name
  distinct() # Remove possible duplicates
View(er_names)

# Save dataset
write.csv2(er_names,  paste0(path, "/Data/Emergency Room Lookup.csv")) # Save as CSV file