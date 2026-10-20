# ==========================================================
# Program : raw_data_qc.R
# Purpose : Independent QC Review of Raw Data
# Study   : HTN101-301
# ==========================================================

# 1. Load Libraries
library(readr)
library(dplyr)
library(tidyr)
library(janitor)
library(purrr)

# 2. Set Paths
ROOT    <- here::here() # or hardcode your path: "C:/Project/HTN101"
RAW_DIR <- file.path(ROOT, "data", "raw")

# Check if folder exists
if (!dir.exists(RAW_DIR)) {
  stop("Raw data folder not found: ", RAW_DIR)
}

# 3. Import All CSVs into a named list
files <- list.files(RAW_DIR, pattern = "\\.csv$", full.names = TRUE)
raw_data <- set_names(map(files, read_csv, show_col_types = FALSE), 
                      nm = tools::file_path_sans_ext(basename(files)))

cat("✅ Imported", length(raw_data), "datasets.\n\n")

# ==========================================================
# SECTION 1: Dataset Dimensions (Contents & Counts)
# ==========================================================
cat("--- 1. Dataset Dimensions ---\n")
dim_summary <- map_dfr(raw_data, ~ tibble(
  N_Records = nrow(.x),
  N_Columns = ncol(.x)
), .id = "Dataset")

print(dim_summary)
cat("\n")

# ==========================================================
# SECTION 2: Unique Subject Counts
# ==========================================================
cat("--- 2. Unique Subjects per Dataset ---\n")
subj_summary <- map_dfr(raw_data, ~ tibble(
  N_Subjects = n_distinct(.x$SUBJECT)
), .id = "Dataset")

print(subj_summary)
cat("\n")

# ==========================================================
# SECTION 3: Demographics Profile
# ==========================================================
cat("--- 3. Demographics Profile ---\n")

# Categorical
dm <- raw_data$demographics
cat("Gender:\n")
print(tabyl(dm, GENDER))

cat("\nRace:\n")
print(tabyl(dm, RACE))

cat("\nEthnicity:\n")
print(tabyl(dm, ETHNICITY))

# Continuous
cat("\nAge Summary:\n")
dm %>%
  summarise(
    N = sum(!is.na(AGE)),
    N_Miss = sum(is.na(AGE)),
    Min = min(AGE, na.rm = TRUE),
    Max = max(AGE, na.rm = TRUE),
    Mean = mean(AGE, na.rm = TRUE),
    Median = median(AGE, na.rm = TRUE)
  ) %>%
  print()
cat("\n")

# ==========================================================
# SECTION 4: Treatment Distributions
# ==========================================================
cat("--- 4. Treatment Distributions ---\n")
cat("Randomization:\n")
print(tabyl(raw_data$randomization, RAND_GROUP))

cat("\nActual Exposure:\n")
print(tabyl(raw_data$ex, TREATMENT))
cat("\n")

# ==========================================================
# SECTION 5: Exposure Records per Subject
# ==========================================================
cat("--- 5. Exposure Records per Subject ---\n")
raw_data$ex %>%
  count(SUBJECT, name = "N_EX_RECORDS") %>%
  filter(N_EX_RECORDS > 1) %>%
  arrange(desc(N_EX_RECORDS)) %>%
  head(10) %>% # Show top 10
  print()
cat("\n")

# ==========================================================
# SECTION 6: Duplicates & Cross-Dataset Reconciliation
# ==========================================================
cat("--- 6. Reconciliation Checks ---\n")
dm_subj  <- unique(dm$SUBJECT)
rnd_subj <- unique(raw_data$randomization$SUBJECT)

cat("Duplicate DM Subjects: ", sum(duplicated(dm$SUBJECT)), "\n")
cat("Duplicate Rand Subjects: ", sum(duplicated(raw_data$randomization$SUBJECT)), "\n")
cat("DM but not in Rand: ", sum(!dm_subj %in% rnd_subj), "\n")
cat("Rand but not in DM: ", sum(!rnd_subj %in% dm_subj), "\n\n")

# ==========================================================
# SECTION 7: Missing Values Dashboard
# ==========================================================
cat("--- 7. Missing Values Dashboard ---\n")
# We'll check the key variables known to have missing data
missing_check <- function(df, var) {
  sum(is.na(df[[var]]) | df[[var]] == "")
}

cat("Missing VS Results (VSORRES): ", missing_check(raw_data$vital_signs, "VSORRES"), "\n")
cat("Missing VS Units (VSORRESU):   ", missing_check(raw_data$vital_signs, "VSORRESU"), "\n")
cat("Missing LB Results (LBORRES): ", missing_check(raw_data$laboratory, "LBORRES"), "\n")
cat("Missing AE End Dates (AEENDTC):", missing_check(raw_data$adverse_events, "AEENDTC"), "\n")
cat("\n")

cat("✅ Raw Data QC Complete.\n")