# Phase III Hypertension Clinical Programming Portfolio

## 📌 Project Overview
This repository contains an end-to-end clinical statistical programming portfolio project. It simulates the workflow of a Statistical Programmer on a **Phase III, Randomized, Double-Blind, Placebo-Controlled trial (HTN101-301)** evaluating HTN-101 50 mg in 100 subjects with essential hypertension.

**Goal:** Demonstrate proficiency in SAS, R, CDISC standards (SDTM & ADaM), TLF generation, and Pinnacle 21 validation.

## 🛠️ Technology Stack
*   **Languages:** SAS (v9.4), R
*   **Standards:** CDISC SDTM-IG 3.2, ADaM-IG 1.3, Define-XML 2.1
*   **Validation:** Pinnacle 21 Community
*   **Tools:** VS Code, Git, Excel

## 📂 Repository Structure
*   `docs/`: Protocol, SAP, aCRF, and specifications.
*   `data/`: Raw CSVs, SDTM XPTs, and ADaM XPTs.
*   `logs/`: Log files of sdtm,adam and tlf.
*   `programs/`: 
    *   `r/`: Raw data generation QC and programs.
    *   `sas/sdtm/`: SDTM domain programs (DM, EX, VS, LB, AE, TS).
    *   `sas/adam/`: ADaM dataset programs (ADSL, ADAE, ADVS, ADLB).
    *   `sas/tlf/`: Table, Listing, and Figure programs.
    *   `sas/qc/`: Independent validation programs.
*   `validation/`: 
    *    `Logs/`: QC log files.
    *    `Pinnacle 21 report/`: Report files.
*   `output/`: Final TLFs (PDF) and Define-XML.

## 🚀 Key Deliverables
*   **Raw Data Generation:** Synthetic data generated in R mimicking real EDC output.
*   **SDTM:** 6 domains mapped and programmed with standard controlled terminology.
*   **ADaM:** Analysis datasets built with derivations (e.g., baseline, change from baseline, population flags, TEAE flags).
*   **Define-XML:** Metadata generated for Pinnacle 21 validation.
*   **Validation:** Logs and summaries of Pinnacle 21 compliance runs.

## 🏃 How to Run
1. Clone the repository.
2. Run `programs/r/01_generate_raw_data.R` to recreate raw CSVs.
3. Run `programs/sas/admin/00_setup.sas` to initialize libraries.
4. Run the pipeline or individual programs in `programs/sas/`.

## ⚠️ Disclaimer
This is a simulated educational portfolio project. The data, sponsor, and trial are fictional. It is not intended for regulatory submission.