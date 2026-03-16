#-------------------------------------------------------------------------------
#                                 Open Dataset 
#-------------------------------------------------------------------------------

gc() # Clear cache
rm(list = ls()) # Remove objects

path = "/Users/bianca/Desktop/X/Policy in Action"

library(dplyr)
library(naniar)

# Open dataset
enquete_2023 = read.csv2(
  file = paste0(path, "/Data/Raw/CSV/2023 Enquête Urgences Structure (CSV).csv"),
  fileEncoding = "latin1") # Decode accented characters

# Get a sense of the dataset
View(enquete_2023) # View dataset
summary(enquete_2023) # Describe columns

# Missing values
## Check missing values
sum(is.na(enquete_2023)) # Number of missing values
miss_var_summary(enquete_2023) %>% # Table of missing values per variable
  print(n = Inf)
## Visualize missing values
nan_summary = miss_var_summary(enquete_2023) # Save table of missing values
View(nan_summary)
top10_nan_vars = nan_summary %>% # Select top 10 variables
           arrange(desc(n_miss)) %>%
           slice(1:10) %>%
           pull(variable)
enquete_2023 %>% # Create heat-map of missing values
  select(all_of(top10_nan_vars)) %>%
  vis_miss()
