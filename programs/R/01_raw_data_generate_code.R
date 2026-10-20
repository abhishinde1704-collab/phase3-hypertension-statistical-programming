# ============================================================
# Phase III Hypertension Clinical Trial
# Raw Data Generation Script
# ============================================================
# Purpose : Generate realistic mock raw clinical data
# Study   : HTN-101 vs Placebo
# Subjects: 100 (50 HTN-101, 50 Placebo)
# Output  : data/raw/*.csv
# Author  : [Your Name]
# ============================================================

# ---- 0. Setup ----------------------------------------------
set.seed(20240101)  # Reproducible

# Create output directory if it doesn't exist
if (!dir.exists("data/raw")) {
  dir.create("data/raw", recursive = TRUE)
}

# Helper functions
rand_date <- function(n, start, end) {
  start <- as.Date(start)
  end   <- as.Date(end)
  sample(seq(start, end, by = "day"), n, replace = TRUE)
}

rand_dt <- function(n, start, end) {
  start <- as.POSIXct(start, tz = "UTC")
  end   <- as.POSIXct(end, tz = "UTC")
  sample(seq(start, end, by = "hour"), n, replace = TRUE)
}

fmt_dtc  <- function(x) format(x, "%Y-%m-%d")
fmt_dttm <- function(x) format(x, "%Y-%m-%dT%H:%M")

# ============================================================
# 1. DEMOGRAPHICS
# ============================================================
# One record per subject
# Variables: SUBJECT, SITEID, BIRTH_DATE, AGE, GENDER, RACE, ETHNICITY, COUNTRY

n_subj <- 100
subjects <- sprintf("%03d", 1:n_subj)

sites <- c("101", "102", "103", "104", "105")
countries <- c("USA", "USA", "USA", "CAN", "GBR", "DEU", "IND")

demographics <- data.frame(
  SUBJECT     = subjects,
  SITEID      = sample(sites, n_subj, replace = TRUE),
  BIRTH_DATE  = rand_date(n_subj, "1945-01-01", "1990-12-31"),
  GENDER      = sample(c("M", "F"), n_subj, replace = TRUE, prob = c(0.55, 0.45)),
  RACE        = sample(
    c("WHITE", "BLACK OR AFRICAN AMERICAN", "ASIAN", "OTHER"),
    n_subj, replace = TRUE, prob = c(0.60, 0.20, 0.15, 0.05)
  ),
  ETHNICITY   = sample(
    c("HISPANIC OR LATINO", "NOT HISPANIC OR LATINO", ""),
    n_subj, replace = TRUE, prob = c(0.20, 0.75, 0.05)
  ),
  COUNTRY     = sample(countries, n_subj, replace = TRUE),
  stringsAsFactors = FALSE
)

# AGE derived from BIRTH_DATE at screening (assume screening = 2024-01-15)
screening_date <- as.Date("2024-01-15")
demographics$AGE <- as.integer(
  floor(as.numeric(difftime(screening_date, demographics$BIRTH_DATE, units = "days")) / 365.25)
)

# Introduce a few missing values (realistic)
demographics$RACE[sample(1:n_subj, 3)] <- ""
demographics$ETHNICITY[sample(1:n_subj, 5)] <- ""

# Reorder columns
demographics <- demographics[, c("SUBJECT", "SITEID", "BIRTH_DATE", "AGE",
                                 "GENDER", "RACE", "ETHNICITY", "COUNTRY")]

# ============================================================
# 2. RANDOMIZATION
# ============================================================
# One record per subject
# Variables: SUBJECT, RAND_GROUP, TREATMENT_CODE

randomization <- data.frame(
  SUBJECT        = subjects,
  RAND_GROUP     = rep(c("HTN-101", "PLACEBO"), each = 50),
  TREATMENT_CODE = rep(c("HTN101", "PBO"), each = 50),
  RAND_DATE      = rand_date(n_subj, "2024-01-15", "2024-03-31"),
  stringsAsFactors = FALSE
)

# Shuffle so it's not grouped
randomization <- randomization[sample(1:n_subj), ]
rownames(randomization) <- NULL

# ============================================================
# Fix EX raw data: rewrite ex.csv with ISO 8601 DOSE_DTM
# ============================================================
# Purpose : Rebuild data/raw/ex.csv so DOSE_DTM is character
#           in ISO 8601 format ("2024-02-01T08:00").
#           SAS will then read it as CHAR and can convert
#           it in SDTM using input(DOSE_DTM, e8601dt16.).
# ============================================================

set.seed(20240101)   # Same seed as original script

# ---- 1. Locate project root -------------------------------
# Adjust this if your project lives elsewhere:
ROOT    <- "D:/Data Analysis"   # <-- CHANGE ME
RAW_DIR <- file.path(ROOT, "data", "raw")
EX_CSV  <- file.path(RAW_DIR, "ex.csv")

if (!dir.exists(RAW_DIR)) {
  stop("Raw data folder not found: ", RAW_DIR)
}

# ---- 2. Rebuild subject list & randomization --------------
n_subj   <- 100
subjects <- sprintf("%03d", 1:n_subj)

# Match the original randomization exactly (same seed → same order)
randomization <- data.frame(
  SUBJECT    = subjects,
  RAND_GROUP = rep(c("HTN-101", "PLACEBO"), each = 50),
  TREATMENT_CODE = rep(c("HTN101", "PBO"), each = 50),
  stringsAsFactors = FALSE
)
randomization <- randomization[sample(1:n_subj), ]
rownames(randomization) <- NULL

# ---- 3. Rebuild EX with character DOSE_DTM ----------------
ex_list <- list()

for (i in 1:n_subj) {
  subj  <- subjects[i]
  trt   <- randomization$RAND_GROUP[randomization$SUBJECT == subj]
  n_rec <- sample(1:4, 1, prob = c(0.15, 0.50, 0.25, 0.10))
  
  start_dt <- as.POSIXct("2024-02-01 08:00:00", tz = "UTC") +
    sample(0:60, 1) * 86400
  
  dose_dtm <- start_dt + (0:(n_rec - 1)) * 28 * 86400
  
  ex_list[[i]] <- data.frame(
    SUBJECT   = subj,
    DOSE_DTM  = format(dose_dtm, "%Y-%m-%dT%H:%M"),   # <-- CHAR, ISO 8601
    TREATMENT = trt,
    DOSE      = ifelse(trt == "HTN-101", 50, 0),
    DOSE_UNIT = "mg",
    stringsAsFactors = FALSE
  )
}

ex <- do.call(rbind, ex_list)
rownames(ex) <- NULL

# ---- 4. Overwrite ex.csv ----------------------------------
write.csv(ex, EX_CSV, row.names = FALSE, na = "")

cat("============================================================\n")
cat("ex.csv rewritten successfully\n")
cat("Path   :", EX_CSV, "\n")
cat("Rows   :", nrow(ex), "\n")
cat("Columns:", paste(names(ex), collapse = ", "), "\n")
cat("============================================================\n")
cat("Sample rows:\n")
print(head(ex, 5))

# ============================================================
# 4. VITAL SIGNS (VS)
# ============================================================
# Multiple records per subject per visit
# Variables: SUBJECT, VISIT, VISITNUM, VSTEST, VSORRES, VSORRESU, VSDTC

visits <- data.frame(
  VISIT    = c("SCREENING", "BASELINE", "WEEK 4", "WEEK 8", "WEEK 12"),
  VISITNUM = c(1, 2, 3, 4, 5),
  DAY_OFF  = c(-14, 0, 28, 56, 84),
  stringsAsFactors = FALSE
)

vs_tests <- data.frame(
  VSTEST   = c("Systolic Blood Pressure", "Diastolic Blood Pressure",
               "Pulse Rate", "Weight"),
  VSTESTCD = c("SYSBP", "DIABP", "PULSE", "WEIGHT"),
  VSORRESU = c("mmHg", "mmHg", "beats/min", "kg"),
  BASE_MEAN = c(150, 95, 72, 85),
  BASE_SD   = c(12, 8, 10, 15),
  stringsAsFactors = FALSE
)

vs_list <- list()
for (i in 1:n_subj) {
  subj <- subjects[i]
  trt  <- randomization$RAND_GROUP[randomization$SUBJECT == subj]
  
  for (v in 1:nrow(visits)) {
    visit_date <- as.Date("2024-01-15") + visits$DAY_OFF[v]
    
    for (t in 1:nrow(vs_tests)) {
      # Treatment effect for SBP/DBP in HTN-101
      trt_effect <- 0
      if (trt == "HTN-101" && vs_tests$VSTESTCD[t] %in% c("SYSBP", "DIABP")) {
        trt_effect <- -visits$DAY_OFF[v] * 0.15
      }
      
      val <- round(rnorm(1, vs_tests$BASE_MEAN[t] + trt_effect, vs_tests$BASE_SD[t]), 1)
      
      vs_list[[length(vs_list) + 1]] <- data.frame(
        SUBJECT   = subj,
        VISIT     = visits$VISIT[v],
        VISITNUM  = visits$VISITNUM[v],
        VSTEST    = vs_tests$VSTEST[t],
        VSTESTCD  = vs_tests$VSTESTCD[t],
        VSORRES   = val,
        VSORRESU  = vs_tests$VSORRESU[t],
        VSDTC     = fmt_dtc(visit_date),
        stringsAsFactors = FALSE
      )
    }
  }
}
vs <- do.call(rbind, vs_list)
rownames(vs) <- NULL

# Introduce missing values (subjects miss some visits)
miss_idx <- sample(1:nrow(vs), 40)
vs$VSORRES[miss_idx] <- NA

# Add a few outliers
outlier_idx <- sample(1:nrow(vs), 10)
vs$VSORRES[outlier_idx] <- vs$VSORRES[outlier_idx] * 1.5

# ============================================================
# 5. LABORATORY (LB)
# ============================================================
# Variables: SUBJECT, VISIT, VISITNUM, LBTEST, LBORRES, LBORRESU, LBDTC

lb_tests <- data.frame(
  LBTEST   = c("Sodium", "Potassium", "Creatinine", "Glucose", "Alanine Aminotransferase", "Aspartate Aminotransferase"),
  LBTESTCD = c("SODIUM", "K", "CREAT", "GLUC", "ALT", "AST"),
  LBORRESU = c("mmol/L", "mmol/L", "mg/dL", "mg/dL", "U/L", "U/L"),
  MEAN     = c(140, 4.2, 1.0, 95, 25, 28),
  SD       = c(3, 0.4, 0.2, 15, 10, 9),
  LBSTNRLO  = c(135, 3.5, 0.6, 70, 7, 10),      # Lower limit of normal
  LBSTNRHI  = c(145, 5.1, 1.2, 100, 56, 40),     # Upper limit of normal
  stringsAsFactors = FALSE
)

lb_visits <- data.frame(
  VISIT    = c("SCREENING", "BASELINE", "WEEK 4", "WEEK 8", "WEEK 12"),
  VISITNUM = c(1, 2, 3, 4, 5),
  DAY_OFF  = c(-14, 0, 28, 56, 84),
  stringsAsFactors = FALSE
)

lb_list <- list()
for (i in 1:n_subj) {
  subj <- subjects[i]
  
  for (v in 1:nrow(lb_visits)) {
    visit_date <- as.Date("2024-01-15") + lb_visits$DAY_OFF[v]
    
    for (t in 1:nrow(lb_tests)) {
      val <- round(rnorm(1, lb_tests$MEAN[t], lb_tests$SD[t]), 2)
      
      lb_list[[length(lb_list) + 1]] <- data.frame(
        SUBJECT   = subj,
        VISIT     = lb_visits$VISIT[v],
        VISITNUM  = lb_visits$VISITNUM[v],
        LBTEST    = lb_tests$LBTEST[t],
        LBTESTCD  = lb_tests$LBTESTCD[t],
        LBORRES   = val,
        LBORRESU  = lb_tests$LBORRESU[t],
        LBSTNRLO  = lb_tests$LBSTNRLO[t],
        LBSTNRHI  = lb_tests$LBSTNRHI[t],
        LBDTC     = fmt_dtc(visit_date),
        stringsAsFactors = FALSE
      )
    }
  }
}
lb <- do.call(rbind, lb_list)
rownames(lb) <- NULL

# Missing values
lb$LBORRES[sample(1:nrow(lb), 50)] <- NA

# Reorder columns for clarity
lb <- lb[, c("SUBJECT", "VISIT", "VISITNUM", "LBTEST", "LBTESTCD",
             "LBORRES", "LBORRESU", "LBSTNRLO", "LBSTNRHI", "LBDTC")]

# ============================================================
# 6. ADVERSE EVENTS (AE)
# ============================================================
# Variables: SUBJECT, AETERM, AESTDTC, AEENDTC, AESEV, AESER,
#            AEREL, AEOUT, AEACN,
#            AESDTH, AESLIFE, AESHOSP, AESDISAB, AESCONG, AESMIE

ae_terms <- data.frame(
  AETERM = c("Headache", "Dizziness", "Fatigue", "Nausea",
             "Back Pain", "Cough", "Insomnia", "Diarrhea",
             "Hypertension Worsening", "Chest Pain"),
  WEIGHT = c(0.15, 0.12, 0.10, 0.09, 0.08, 0.08, 0.07, 0.07, 0.05, 0.03),
  stringsAsFactors = FALSE
)

ae_list <- list()
for (i in 1:n_subj) {
  subj <- subjects[i]
  n_ae <- sample(0:4, 1, prob = c(0.30, 0.35, 0.20, 0.10, 0.05))
  
  if (n_ae == 0) next
  
  for (a in 1:n_ae) {
    ae_idx <- sample(1:nrow(ae_terms), 1, prob = ae_terms$WEIGHT)
    start  <- as.Date("2024-02-01") + sample(0:80, 1)
    dur    <- sample(1:14, 1)
    end    <- start + dur
    
    # --- Severity ---
    aeser_val <- sample(c("N", "Y"), 1, prob = c(0.92, 0.08))
    
    # --- Seriousness criteria (only if serious) ---
    if (aeser_val == "Y") {
      criterion <- sample(
        c("DEATH", "LIFE", "HOSP", "DISAB", "CONG", "MIE"),
        1,
        prob = c(0.05, 0.10, 0.55, 0.10, 0.05, 0.15)
      )
      aesdth   <- ifelse(criterion == "DEATH", "Y", "N")
      aeslife  <- ifelse(criterion == "LIFE",  "Y", "N")
      aeshosp  <- ifelse(criterion == "HOSP",  "Y", "N")
      aesdisab <- ifelse(criterion == "DISAB", "Y", "N")
      aescong  <- ifelse(criterion == "CONG",  "Y", "N")
      aesmie   <- ifelse(criterion == "MIE",   "Y", "N")
    } else {
      aesdth   <- "N"
      aeslife  <- "N"
      aeshosp  <- "N"
      aesdisab <- "N"
      aescong  <- "N"
      aesmie   <- "N"
    }
    
    # --- Outcome (AEOUT) — aligned with ongoing flag below ---
    aeout_val <- sample(
      c("RECOVERED/RESOLVED",
        "RECOVERING/RESOLVING",
        "NOT RECOVERED/NOT RESOLVED",
        "FATAL",
        "UNKNOWN"),
      1,
      prob = c(0.70, 0.10, 0.12, 0.03, 0.05)
    )
    
    # --- Action Taken (AEACN) ---
    aeacn_val <- sample(
      c("DOSE NOT CHANGED",
        "DRUG WITHDRAWN",
        "DOSE REDUCED",
        "DOSE INCREASED",
        "DRUG INTERRUPTED",
        "UNKNOWN"),
      1,
      prob = c(0.60, 0.05, 0.10, 0.05, 0.15, 0.05)
    )
    
    ae_list[[length(ae_list) + 1]] <- data.frame(
      SUBJECT  = subj,
      AETERM   = ae_terms$AETERM[ae_idx],
      AESTDTC  = fmt_dtc(start),
      AEENDTC  = fmt_dtc(end),
      AESEV    = sample(c("MILD", "MODERATE", "SEVERE"), 1,
                        prob = c(0.60, 0.30, 0.10)),
      AESER    = aeser_val,
      AEREL    = sample(c("NOT RELATED", "POSSIBLY RELATED", "RELATED"),
                        1, prob = c(0.50, 0.35, 0.15)),
      AEOUT    = aeout_val,
      AEACN    = aeacn_val,
      AESDTH   = aesdth,
      AESLIFE  = aeslife,
      AESHOSP  = aeshosp,
      AESDISAB = aesdisab,
      AESCONG  = aescong,
      AESMIE   = aesmie,
      stringsAsFactors = FALSE
    )
  }
}
ae <- do.call(rbind, ae_list)
rownames(ae) <- NULL

# Some ongoing AEs (no end date) — also align AEOUT
ongoing_idx <- sample(1:nrow(ae), 5)
ae$AEENDTC[ongoing_idx] <- ""
ae$AEOUT[ongoing_idx]   <- "NOT RECOVERED/NOT RESOLVED"

# ============================================================
# 7. CONCOMITANT MEDICATIONS (CM)
# ============================================================
# Variables: SUBJECT, CMTRT, CMDOSE, CMDOSU, CMROUTE, CMSTDTC, CMENDTC

cm_terms <- data.frame(
  CMTRT   = c("Aspirin", "Metformin", "Atorvastatin", "Omeprazole",
              "Amlodipine", "Lisinopril", "Ibuprofen", "Paracetamol"),
  CMDOSE  = c(81, 500, 20, 20, 5, 10, 400, 500),
  CMDOSU  = c("mg", "mg", "mg", "mg", "mg", "mg", "mg", "mg"),
  CMROUTE = c("ORAL", "ORAL", "ORAL", "ORAL", "ORAL", "ORAL", "ORAL", "ORAL"),
  stringsAsFactors = FALSE
)

cm_list <- list()
for (i in 1:n_subj) {
  subj <- subjects[i]
  n_cm <- sample(0:3, 1, prob = c(0.40, 0.35, 0.20, 0.05))
  
  if (n_cm == 0) next
  
  for (m in 1:n_cm) {
    cm_idx <- sample(1:nrow(cm_terms), 1)
    start  <- as.Date("2024-01-01") + sample(0:60, 1)
    
    cm_list[[length(cm_list) + 1]] <- data.frame(
      SUBJECT  = subj,
      CMTRT    = cm_terms$CMTRT[cm_idx],
      CMDOSE   = cm_terms$CMDOSE[cm_idx],
      CMDOSU   = cm_terms$CMDOSU[cm_idx],
      CMROUTE  = cm_terms$CMROUTE[cm_idx],
      CMSTDTC  = fmt_dtc(start),
      CMENDTC  = fmt_dtc(start + sample(7:90, 1)),
      stringsAsFactors = FALSE
    )
  }
}
cm <- do.call(rbind, cm_list)
rownames(cm) <- NULL

# ============================================================
# 8. DISPOSITION (DS)
# ============================================================
# Variables: SUBJECT, DSCAT, DSTERM, DSDTC

ds_list <- list()
for (i in 1:n_subj) {
  subj <- subjects[i]
  
  # Every subject has a "COMPLETED" or "DISCONTINUED" record
  status <- sample(c("COMPLETED", "DISCONTINUED"), 1, prob = c(0.85, 0.15))
  
  if (status == "COMPLETED") {
    ds_list[[length(ds_list) + 1]] <- data.frame(
      SUBJECT = subj,
      DSCAT   = "DISPOSITION EVENT",
      DSTERM  = "COMPLETED",
      DSDTC   = fmt_dtc(as.Date("2024-05-01") + sample(0:30, 1)),
      stringsAsFactors = FALSE
    )
  } else {
    reason <- sample(c("ADVERSE EVENT", "LOST TO FOLLOW-UP",
                       "WITHDRAWAL OF CONSENT", "PROTOCOL VIOLATION"),
                     1, prob = c(0.4, 0.2, 0.3, 0.1))
    ds_list[[length(ds_list) + 1]] <- data.frame(
      SUBJECT = subj,
      DSCAT   = "DISPOSITION EVENT",
      DSTERM  = "DISCONTINUED",
      DSDTC   = fmt_dtc(as.Date("2024-03-01") + sample(0:60, 1)),
      stringsAsFactors = FALSE
    )
    ds_list[[length(ds_list) + 1]] <- data.frame(
      SUBJECT = subj,
      DSCAT   = "DISCONTINUATION REASON",
      DSTERM  = reason,
      DSDTC   = fmt_dtc(as.Date("2024-03-01") + sample(0:60, 1)),
      stringsAsFactors = FALSE
    )
  }
}
ds <- do.call(rbind, ds_list)
rownames(ds) <- NULL

# ============================================================
# 9. WRITE CSV FILES
# ============================================================

write.csv(demographics,  "data/raw/demographics.csv",  row.names = FALSE, na = "")
write.csv(randomization, "data/raw/randomization.csv", row.names = FALSE, na = "")
write.csv(ex,            "data/raw/ex.csv",            row.names = FALSE, na = "")
write.csv(vs,            "data/raw/vital_signs.csv",   row.names = FALSE, na = "")
write.csv(lb,            "data/raw/laboratory.csv",    row.names = FALSE, na = "")
write.csv(ae,            "data/raw/adverse_events.csv",row.names = FALSE, na = "")
write.csv(cm,            "data/raw/medications.csv",   row.names = FALSE, na = "")
write.csv(ds,            "data/raw/disposition.csv",   row.names = FALSE, na = "")

# ============================================================
# 10. SUMMARY
# ============================================================

cat("============================================================\n")
cat("RAW DATA GENERATION COMPLETE\n")
cat("============================================================\n")
cat(sprintf("Demographics   : %d records\n", nrow(demographics)))
cat(sprintf("Randomization  : %d records\n", nrow(randomization)))
cat(sprintf("Exposure (EX)  : %d records\n", nrow(ex)))
cat(sprintf("Vital Signs    : %d records\n", nrow(vs)))
cat(sprintf("Laboratory     : %d records\n", nrow(lb)))
cat(sprintf("Adverse Events : %d records\n", nrow(ae)))
cat(sprintf("Medications    : %d records\n", nrow(cm)))
cat(sprintf("Disposition    : %d records\n", nrow(ds)))
cat("============================================================\n")
cat("Files written to: data/raw/\n")
cat("============================================================\n")


