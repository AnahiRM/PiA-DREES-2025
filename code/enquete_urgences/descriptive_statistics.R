#-------------------------------------------------------------------------------
#                                 Descriptive Statistics 
#-------------------------------------------------------------------------------

library(dplyr)
library(ggplot2)
library(tibble)
library(tidyr)
library(scales)

# Create grouping variables

## Create copy of dataset
df_enquete = enquete_2023

## Aggregate patient-related variables
df_enquete$patients_nb = rowSums(df_enquete[, c(
  "STR_A6", "STR_A7", "STR_A8", "STR_A9", "STR_A10",
  "STR_B6", "STR_B7", "STR_B8", "STR_B9", "STR_B10",
  "STR_C6", "STR_C7", "STR_C8", "STR_C9", "STR_C10",
  "STR_D6", "STR_D7", "STR_D8", "STR_D9", "STR_D10")],
  na.rm = TRUE)

## Aggregate staff-related variables
### Total staff
df_enquete$totstaff_nb = rowSums(df_enquete[, c(
  "STR_A11", "STR_A12",
  "STR_B11", "STR_B12",
  "STR_C11", "STR_C12",
  "STR_D11", "STR_D12",
  "STR_A13", "STR_B13", "STR_C13", "STR_D13",
  "STR_A14", "STR_A15", "STR_A16", "STR_A17", "STR_A18", "STR_A19", "STR_A20",
  "STR_B14", "STR_B15", "STR_B16", "STR_B17", "STR_B18", "STR_B19", "STR_B20",
  "STR_C14", "STR_C15", "STR_C16", "STR_C17", "STR_C18", "STR_C19", "STR_C20",
  "STR_D14", "STR_D15", "STR_D16", "STR_D17", "STR_D18", "STR_D19", "STR_D20",
  "STR_A21", "STR_A22",
  "STR_B21", "STR_B22",
  "STR_C21", "STR_C22",
  "STR_D21", "STR_D22")],
  na.rm = TRUE)
### Medical staff
df_enquete$medstaff_nb = rowSums(df_enquete[, c(
  "STR_A11", "STR_A12",
  "STR_B11", "STR_B12",
  "STR_C11", "STR_C12",
  "STR_D11", "STR_D12",
  "STR_A13", "STR_B13", "STR_C13", "STR_D13")],
  na.rm = TRUE)
### Non-permanent staff
df_enquete$noperm_totstaff_nb = rowSums(df_enquete[, c(
  "STR_A13", "STR_B13", "STR_C13", "STR_D13",
  "STR_A21", "STR_A22",
  "STR_B21", "STR_B22",
  "STR_C21", "STR_C22",
  "STR_D21", "STR_D22")],
  na.rm = TRUE)
### Non-permanent medical staff
df_enquete$noperm_medstaff_nb = rowSums(df_enquete[, c(
  "STR_A13", "STR_B13", "STR_C13", "STR_D13")],
  na.rm = TRUE)

# Compute ratios
## Patient/staff
df_enquete$pat_staff_ratio = df_enquete$patients_nb / df_enquete$totstaff_nb
## Patient/medical staff
df_enquete$pat_medstaff_ratio = df_enquete$patients_nb / df_enquete$medstaff_nb
## Non-permanent/total staff
df_enquete$noperm_totstaff_ratio = df_enquete$noperm_totstaff_nb / df_enquete$totstaff_nb
## Non-permanent/total medical staff
df_enquete$noperm_medstaff_ratio = df_enquete$noperm_medstaff_nb / df_enquete$medstaff_nb

# Histograms of ratios
## Patient-to-staff
h_patstaff = ggplot(df_enquete, aes(x = pat_staff_ratio)) +
  geom_histogram(fill = "seagreen3") +
  scale_x_continuous(n.breaks = 10) +
  labs(x = "Patient-To-Staff Ratio", y = "Counts", 
       title = "Histogram of Patient-to-Staff Ratio") +
  theme(plot.title = element_text(hjust = 0.5))
h_patstaff
ggsave(filename = paste0(path, "/Output/Graphs/h_patstaff.pdf"), # Export as pdf
       plot = h_patstaff, width = 7, height = 5)
## Patient-to-medical-staff
h_patmed = ggplot(df_enquete, aes(x = pat_medstaff_ratio)) +
  geom_histogram(fill = "seagreen3") +
  scale_x_continuous(n.breaks = 10) +
  labs(x = "Patient-To-Medical-Staff Ratio", y = "Counts", 
       title = "Histogram of Patient-to-Medical-Staff Ratio") +
  theme(plot.title = element_text(hjust = 0.5))
h_patmed
ggsave(filename = paste0(path, "/Output/Graphs/h_patmed.pdf"), # Export as pdf
       plot = h_patmed, width = 7, height = 5)
## Non-permanent-to-total-staff
h_nopermtot = ggplot(df_enquete, aes(x = noperm_totstaff_ratio)) +
  geom_histogram(fill = "seagreen3") +
  scale_x_continuous(n.breaks = 10) +
  labs(x = "Non-Permanent-To-Total-Staff Ratio", y = "Counts", 
       title = "Histogram of Non-Permanent-To-Total-Staff Ratio") +
  theme(plot.title = element_text(hjust = 0.5))
h_nopermtot
ggsave(filename = paste0(path, "/Output/Graphs/h_nopermtot.pdf"), # Export as pdf
       plot = h_nopermtot, width = 7, height = 5)
## Non-permanent-to-medical-staff
h_nopermmed = ggplot(df_enquete, aes(x = noperm_medstaff_ratio)) +
  geom_histogram(fill = "seagreen3") +
  scale_x_continuous(n.breaks = 10) +
  labs(x = "Non-Permanent-To-Medical-Staff Ratio", y = "Counts", 
       title = "Histogram of Non-Permanent-To-Medical-Staff Ratio") +
  theme(plot.title = element_text(hjust = 0.5))
h_nopermmed
ggsave(filename = paste0(path, "/Output/Graphs/h_nopermmed.pdf"), # Export as pdf
       plot = h_nopermmed, width = 7, height = 5)

# Heat-map of ratios

## Create lookup table

lookup = tibble(
  variable = c(
    paste0("STR_A", 6:10), # Patients
    paste0("STR_B", 6:10),
    paste0("STR_C", 6:10),
    paste0("STR_D", 6:10),
    paste0("STR_A", 11:12), # Permanent medical staff
    paste0("STR_B", 11:12),
    paste0("STR_C", 11:12),
    paste0("STR_D", 11:12),
    "STR_A13","STR_B13","STR_C13","STR_D13", # Non-permanent medical staff
    paste0("STR_A", 14:20), # Permanent non-medical staff
    paste0("STR_B", 14:20),
    paste0("STR_C", 14:20),
    paste0("STR_D", 14:20),
    paste0("STR_A", 21:22), # Non-permanent non-medical staff
    paste0("STR_B", 21:22),
    paste0("STR_C", 21:22),
    paste0("STR_D", 21:22)
  ),
  group = c(
    rep("Patients", 20), # Patients
    rep("Medical staff", 8), # Permanent medical staff
    rep("Medical staff", 4), # Non-permanent medical staff
    rep("Non-medical staff", 28), # Permanent non-medical staff
    rep("Non-medical staff", 8) # Non-permanent non-medical staff
  ),
  permanent = c(
    rep(NA, 20), # Patients
    rep(1, 8), # Permanent medical staff
    rep(0, 4), # Non-permanent medical staff
    rep(1, 28), # Permanent non-medical staff
    rep(0, 8) # Non-permanent non-medical staff
  ),
  hour = c(
    rep("08",5), rep("18",5), rep("22",5), rep("08_j1",5), # Patients
    rep("08",2), rep("18",2), rep("22",2), rep("08_j1",2), # Permanent medical staff
    "08","18","22","08_j1", # Non-permanent medical staff
    rep("08",7), rep("18",7), rep("22",7), rep("08_j1",7), # Permanent non-medical staff
    "08","08","18","18","22","22","08_j1","08_j1" # Non-permanent non-medical staff
  )
)

## Create long dataframe

### Create smaller dataset with relevant variables 
dfshort_enquete = df_enquete %>%
  select(ID_POINT_D_ACCUEIL, FINESS, TYPE_PA, STR_A1, pat_staff_ratio, all_of(lookup$variable))

### Pivot smaller dataset
dflong_enquete = dfshort_enquete %>%
  pivot_longer(
    cols = all_of(lookup$variable),
    names_to = "variable",
    values_to = "value"
  ) %>%
  left_join(lookup, by = "variable") %>%
  mutate(
    hour = factor(hour, levels = c("08", "18", "22", "08_j1"))
  )
#### Rename columns
dflong_enquete = dflong_enquete %>%
  rename(
    id_pa = ID_POINT_D_ACCUEIL,
    finess = FINESS,
    type_pa = TYPE_PA,
    hospital = STR_A1
  )

## Compute ratios
### Create table with hourly ratios
ratios_hourly = dflong_enquete %>%
  group_by(id_pa, hour) %>%
  summarise(
    totpat = sum(value[group == "Patients"], na.rm = TRUE),
    totstaff = sum(value[!is.na(permanent)], na.rm = TRUE),
    medstaff = sum(value[group == "Medical staff"], na.rm = TRUE),
    noperm_totstaff = sum(value[!is.na(permanent) & permanent == 0], na.rm = TRUE),
    noperm_medstaff = sum(value[group == "Medical staff" & permanent == 0], na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    pat_per_staff = totpat / totstaff,
    pat_per_medstaff = totpat / medstaff,
    noperm_per_totstaff = noperm_totstaff / totstaff,
    noperm_per_medstaff = noperm_medstaff / medstaff
  ) %>%
  pivot_longer(
    cols = matches("^(pat|noperm)_per_"),
    names_to = "ratio_type",
    values_to = "ratio"
  )
### Aggregate ratios
ratios_agg = ratios_hourly %>%
  group_by(hour, ratio_type) %>%
  summarise(
    mean_ratio = mean(ratio, na.rm = TRUE),
    median_ratio = median(ratio, na.rm = TRUE),
    .groups = "drop"
  )

## Create heat-map
htmap_ratios = ggplot(ratios_agg, aes(x = hour, y = ratio_type, fill = median_ratio)) +
  geom_tile(color = "white") +
  scale_x_discrete(labels = c(
    `08_j1` = "08 (Day After)"
  )) +
  scale_y_discrete(labels = c(
    pat_per_staff = "Patients / Total Staff",
    pat_per_medstaff = "Patients / Medical Staff",
    noperm_per_totstaff = "Non-Permanent / Total Staff",
    noperm_per_medstaff = "Non-Permanent / Medical Staff"
  )) +
  scale_fill_gradient(low = "white", high = "dodgerblue2") +
  labs(
    title = "Median Staffing Ratios by Hour",
    x = "Hour",
    y = "Ratio Type",
    fill = "Median Ratio"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 0.5))
htmap_ratios
ggsave(filename = paste0(path, "/Output/Graphs/htmap_ratios.pdf"), # Export as pdf
       plot = htmap_ratios, width = 7, height = 5)

# Spatial mapping