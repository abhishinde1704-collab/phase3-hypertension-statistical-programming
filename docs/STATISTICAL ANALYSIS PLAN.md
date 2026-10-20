STATISTICAL ANALYSIS PLAN

Protocol Number: HTN101-301
A Phase III, Randomized, Double-Blind, Placebo-Controlled, Parallel-Group, Multicentre Study to Evaluate the Efficacy and Safety of HTN-101 50 mg Once Daily in Adult Subjects with Essential Hypertension

Sponsor: XXX Pharmaceuticals, Inc.
SAP Version: Version 1.0
Version Date: 29 January 2024
Associated Protocol Version: Version 2.0 (Amendment 1), 15 January 2024
Statistical Software: SAS® Version 9.4 or higher

Prepared by: Abhijeet Shinde — Statistical Programmer

Prepared as part of a statistical programming portfolio project. This SAP, the sponsor, investigators, sites, and all subject data are fictional and were created solely to demonstrate clinical statistical programming and analysis-planning workflow.

================================================================================
TABLE OF CONTENTS
================================================================================
1. Introduction
2. Study Objectives and Endpoints
3. Study Design Overview
4. Sample Size Determination
5. Analysis Populations
6. General Statistical Considerations
7. Disposition, Demographics, and Baseline Characteristics
8. Efficacy Analyses
9. Safety Analyses
10. Handling of Missing Data
11. Interim Analyses and Data Monitoring
12. Changes from Protocol-Planned Analyses
Appendix A: Table, Listing, and Figure Shells

================================================================================
1. INTRODUCTION
================================================================================
This Statistical Analysis Plan (SAP) describes the planned statistical analyses for Protocol HTN101-301, a Phase III study of HTN-101 50 mg once daily versus placebo in adult subjects with essential hypertension. This SAP is based on Protocol HTN101-301, Version 2.0 (Amendment 1), and takes precedence over the statistical section of the protocol for the conduct of the final analysis.

================================================================================
2. STUDY OBJECTIVES AND ENDPOINTS
================================================================================
2.1 Primary Endpoint
Change from baseline in seated systolic blood pressure (SBP) at Week 12.

2.2 Secondary Endpoint
Change from baseline in seated diastolic blood pressure (DBP) at Week 12.

2.3 Safety Endpoints
Incidence of treatment-emergent adverse events (TEAEs) and serious adverse events (SAEs). Change from baseline in clinical laboratory parameters (potassium, creatinine). Change from baseline in vital signs (pulse, weight) and incidence of AE-related discontinuation.

================================================================================
3. STUDY DESIGN OVERVIEW
================================================================================
Randomized, double-blind, placebo-controlled, parallel-group, multicentre study. Approximately 50 subjects will be randomized 1:1 to HTN-101 50 mg once daily or matching placebo across approximately 6 sites, with a 12-week double-blind treatment period. Assessments occur at Screening (Day -14), Baseline (Day 0), Week 4 (Day 28), Week 8 (Day 56), and Week 12 (Day 84), with additional Early Termination and Unscheduled visits as needed.

================================================================================
4. SAMPLE SIZE DETERMINATION
================================================================================
Assuming a between-group difference in mean change from baseline SBP of 12 mmHg, a common standard deviation of 15 mmHg, and a two-sided significance level of 0.05, a sample size of 25 evaluable subjects per treatment arm (50 total) provides approximately 80% power using a two-sample t-test approximation. No formal adjustment for multiplicity is required for the sample size calculation, as only one primary endpoint is specified.

================================================================================
5. ANALYSIS POPULATIONS
================================================================================
Population                        Definition
--------------------------------------------------------------------------------
Intent-to-Treat (ITT) / FAS       All randomized subjects who receive at least one dose of study drug, analysed according to randomized treatment.
                                  Primary Use: Primary and secondary efficacy analyses.
                                  
Per-Protocol (PP)                 ITT subjects without major protocol deviations judged to materially affect the primary endpoint.
                                  Primary Use: Sensitivity efficacy analysis.

================================================================================
6. GENERAL STATISTICAL CONSIDERATIONS
================================================================================
6.1 Statistical Software
All statistical analyses, tables, listings, and figures (TLFs) will be produced using SAS® Version 9.4 or higher, based on validated CDISC SDTM and ADaM datasets.

6.2 Significance Level and Multiplicity
All statistical tests will be two-sided at the 0.05 significance level unless otherwise specified. The secondary endpoint (DBP) will be tested only if the primary endpoint (SBP) achieves statistical significance, using a fixed-sequence gatekeeping procedure to control the family-wise Type I error rate.

6.3 Baseline Definition
Baseline is defined as the last non-missing assessment recorded on or before the date of the first dose of study drug (typically the Day 0 Baseline/Randomization visit).

6.4 Visit Windows
Scheduled post-baseline assessments will be mapped to the nearest protocol-defined visit (Week 4, Week 8, Week 12) using pre-specified visit windows. Unscheduled visit data will be flagged and excluded from by-visit summaries but retained in subject-level listings.

================================================================================
7. DISPOSITION, DEMOGRAPHICS, AND BASELINE CHARACTERISTICS
================================================================================
Subject disposition (screened, randomized, completed, discontinued, and reason for discontinuation) will be summarized by treatment group and overall, for the ITT Population, based on the DS domain.

Demographic and baseline characteristics (age, sex, race, ethnicity, baseline SBP/DBP, weight, BMI) will be summarized descriptively by treatment group for the ITT Population, based on the DM, VS, and derived ADSL variables. Continuous variables will be summarized using n, mean, standard deviation, median, minimum, and maximum; categorical variables will be summarized using frequencies and percentages.

================================================================================
8. EFFICACY ANALYSES
================================================================================
8.1 Primary Efficacy Analysis
Change from baseline in SBP at each post-baseline visit will be analysed using a mixed model for repeated measures (MMRM) with fixed effects for treatment, visit, treatment-by-visit interaction, and baseline SBP as a covariate, and an unstructured covariance structure to model within-subject correlation across visits. The Kenward-Roger method will be used to estimate denominator degrees of freedom.
The primary comparison of interest is the least-squares (LS) mean difference between HTN-101 and placebo in change from baseline SBP at Week 12, presented with a two-sided 95% confidence interval and p-value.

8.2 Secondary Efficacy Analysis
Change from baseline in DBP at Week 12 will be analysed using the same MMRM approach specified for the primary endpoint, conditional on the primary endpoint reaching statistical significance (see Section 6.2).

8.3 Sensitivity Analyses
- Repeat of the primary MMRM analysis restricted to the Per-Protocol Population.
- Analysis of covariance (ANCOVA) on Week 12 change from baseline using last observation carried forward (LOCF) as a sensitivity check on the MMRM missing-data assumption.
- Multiple imputation under a missing-not-at-random (MNAR, 'jump to reference') scenario for subjects discontinuing due to lack of efficacy or adverse events.

8.4 Subgroup Analyses
The primary endpoint will additionally be summarized by subgroups of age (<65 vs. >=65 years) and sex, using the same MMRM model with the corresponding subgroup-by-treatment interaction term, for exploratory purposes only.

================================================================================
9. SAFETY ANALYSES
================================================================================
9.1 Extent of Exposure
Duration of study drug exposure and average daily dose will be summarized descriptively by treatment group using the EX domain. Dosing interruptions will be summarized by treatment group and reason.

9.2 Adverse Events
Adverse events will be coded and treatment-emergent adverse events (TEAEs) — defined as events with onset on or after the first dose of study drug — will be summarized by System Organ Class and Preferred Term, treatment group, maximum severity, seriousness, and relationship to study drug, for the Safety Population. Overall, AE incidence, SAEs, and AEs leading to study drug discontinuation will each be summarized separately.

9.3 Clinical Laboratory Evaluations
Potassium and creatinine will be summarized descriptively by visit and treatment group, including change from baseline and shift tables relative to the normal reference range (Low/Normal/High), based on the LB domain.

9.4 Vital Signs
Pulse rate and weight will be summarized descriptively by visit and treatment group, including change from baseline, based on the VS domain. SBP and DBP are addressed as efficacy endpoints in Section 8 but will also be reviewed descriptively for safety context (e.g., incidence of hypotension).

================================================================================
10. HANDLING OF MISSING DATA
================================================================================
The primary MMRM analysis accommodates intermittently and monotonically missing post-baseline data under a missing-at-random (MAR) assumption without explicit imputation. Sensitivity analyses described in 8.3 will assess the robustness of the primary conclusion to departures from the MAR assumption. No imputation will be applied to safety data; safety summaries are based on observed data only.

================================================================================
11. INTERIM ANALYSES AND DATA MONITORING
================================================================================
No formal interim efficacy analysis is planned for this study. Safety data will be reviewed periodically by the Sponsor's medical monitor on an ongoing, unblinded-by-treatment-group basis as part of routine safety surveillance.

================================================================================
12. CHANGES FROM PROTOCOL-PLANNED ANALYSES
================================================================================
There are no changes from the statistical analyses planned in Protocol HTN101-301, Section 8, at the time of this SAP version. Any subsequent changes will be documented in an SAP amendment prior to database lock.

================================================================================
APPENDIX A: TABLE, LISTING, AND FIGURE SHELLS
================================================================================
The table below lists the planned Tables, Listings, and Figures (TLFs) supporting this SAP, numbered per convention (Section 14 = Tables/Figures, Section 16 = Listings), consistent with ICH E3.

TLF No.           Title                                                                                         Population
------------------------------------------------------------------------------------------------------------------------------
Table 14.1.1      Subject Disposition                                                                           ITT
Table 14.1.2      Analysis Populations                                                                          All Randomized
Table 14.2.1      Demographic and Baseline Characteristics                                                      ITT
Table 14.3.1      Primary Efficacy Analysis — Change from Baseline in SBP at Week 12 (MMRM)                       ITT
Table 14.3.2      Secondary Efficacy Analysis — Change from Baseline in DBP at Week 12 (MMRM)                     ITT
Table 14.3.3      Sensitivity Analysis — Primary Endpoint (Per-Protocol, ANCOVA/LOCF)                           PP
Figure 14.3.1     Mean (SE) SBP by Visit and Treatment Group                                                     ITT
Table 14.4.1      Extent of Exposure to Study Drug                                                               Safety
Table 14.5.1      Overview of Adverse Events                                                                    Safety
Table 14.5.2      Treatment-Emergent Adverse Events by System Organ Class and Preferred Term                    Safety
Table 14.5.3      Treatment-Emergent Adverse Events by Maximum Severity                                         Safety
Table 14.5.4      Serious Adverse Events                                                                        Safety
Table 14.5.5      Adverse Events Leading to Study Drug Discontinuation                                          Safety
Table 14.6.1      Clinical Laboratory Values — Shift from Baseline (Potassium, Creatinine)                       Safety
Table 14.7.1      Vital Signs — Summary and Change from Baseline by Visit                                       Safety
Listing 16.2.1    Subject Disposition Listing                                                                   All Randomized
Listing 16.2.2    Adverse Event Listing                                                                         Safety
Listing 16.2.3    Protocol Deviation Listing                                                                    ITT