# ANNOTATED CASE REPORT FORM

## HTN101-301

**A Phase III, Randomized, Double-Blind, Placebo-Controlled, Parallel-Group, Multicenter Study to Evaluate the Efficacy and Safety of HTN-101 50 mg Once Daily in Adult Subjects with Essential Hypertension**

---

**Protocol Number:** HTN101-301
**Protocol Version:** 1.0
**aCRF Version:** 1.0
**aCRF Date:** 15 January 2024
**Sponsor:** XXX Pharmaceuticals, Inc.

**Note:** This is a simulated Annotated CRF created for a statistical programming portfolio project. All annotations reflect SDTM-IG 3.2 mapping.

---

## ANNOTATION LEGEND

| Symbol | Meaning |
|--------|---------|
| **SDTM Variable** | Mapped SDTM variable name |
| *DOMAIN* | Target SDTM domain |
| `[Origin]` | CRF / Derived / Assigned |
| `[Type]` | Char / Num / Date |

---

## FORM 1 — DEMOGRAPHICS

### Visit: Screening (Visit 1)

| Field Label | Response | SDTM Mapping | Notes |
|-------------|----------|--------------|-------|
| Subject Number | [____] | **SUBJID** (*DM*) | Site-assigned |
| Site ID | [____] | **SITEID** (*DM*) | From site registration |
| Date of Birth | [DD/MMM/YYYY] | **BRTHDTC** (*DM*) | Convert to ISO 8601 |
| Age | [___] years | **AGE**, **AGEU = "YEARS"** (*DM*) | Derived from DOB and Screening date |
| Sex | ☐ Male ☐ Female | **SEX** (*DM*) | M → "M", F → "F" |
| Race | ☐ White ☐ Black or African American ☐ Asian ☐ Other | **RACE** (*DM*) | If "/" present → "MULTIPLE" |
| Ethnicity | ☐ Hispanic or Latino ☐ Not Hispanic or Latino | **ETHNIC** (*DM*) | Uppercase |
| Country | [___] | **COUNTRY** (*DM*) | ISO 3166-1 alpha-3 |

**Annotations Summary:**
- **USUBJID** (*DM*) = Derived as `catx( "-",STUDYID,SITEID,SUBJID)`
- **STUDYID** (*DM*) = Assigned "HTN101-301"
- **DOMAIN** (*DM*) = Assigned "DM"

---

## FORM 2 — INCLUSION / EXCLUSION CRITERIA

### Visit: Screening (Visit 1)

**Inclusion Criteria**

| # | Criterion | Yes | No |
|---|-----------|:---:|:--:|
| 1 | Age 18–75 years | ☐ | ☐ |
| 2 | Diagnosis of essential hypertension | ☐ | ☐ |
| 3 | Mean sitting SBP ≥ 140 and < 180 mmHg | ☐ | ☐ |
| 4 | Mean sitting DBP ≥ 90 and < 110 mmHg | ☐ | ☐ |
| 5 | BMI 18.0–40.0 kg/m² | ☐ | ☐ |
| 6 | Willing to provide informed consent | ☐ | ☐ |

**Exclusion Criteria**

| # | Criterion | Yes | No |
|---|-----------|:---:|:--:|
| 1 | Secondary hypertension | ☐ | ☐ |
| 2 | Severe hypertension | ☐ | ☐ |
| 3 | Recent MI/stroke/TIA | ☐ | ☐ |
| 4 | Heart failure (NYHA III/IV) | ☐ | ☐ |
| 5 | Clinically significant arrhythmia | ☐ | ☐ |
| 6 | Type 1 diabetes | ☐ | ☐ |
| 7 | Uncontrolled Type 2 diabetes | ☐ | ☐ |
| 8 | CKD (eGFR < 30) | ☐ | ☐ |
| 9 | Clinically significant liver disease | ☐ | ☐ |
| 10 | Pregnant or breastfeeding | ☐ | ☐ |
| 11 | Inadequate contraception | ☐ | ☐ |
| 12 | Hypersensitivity to HTN-101 | ☐ | ☐ |
| 13 | Participation in another trial | ☐ | ☐ |
| 14 | Other condition compromising safety | ☐ | ☐ |

**Annotation:** `[Origin: CRF] [Type: Char]` — Not mapped to SDTM (used for eligibility only).

---

## FORM 3 — MEDICAL HISTORY

### Visit: Screening (Visit 1)

| Condition | Ongoing? | Start Date | End Date |
|-----------|:--------:|------------|----------|
| [________] | ☐ Yes ☐ No | [DD/MMM/YYYY] | [DD/MMM/YYYY] |

**Annotations:**
- **MHTERM** (*MH*) = Verbatim term
- **MHSTDTC** (*MH*) = Start date (ISO 8601)
- **MHENDTC** (*MH*) = End date (ISO 8601)
- **MHONGO** (*MH*) = "Y" if ongoing
- Not collected in this portfolio study (MH domain not implemented)

---

## FORM 4 — VITAL SIGNS

### Visits: Screening (V1), Baseline (V2), Week 4 (V3), Week 8 (V4), Week 12 (V5)

**Visit Date:** [DD/MMM/YYYY]

**Visit Number:** ☐ V1 ☐ V2 ☐ V3 ☐ V4 ☐ V5

**Time of Assessment:** [HH:MM]

**Position:** ☐ Sitting ☐ Standing ☐ Supine

| Measurement | Result | Unit | Time |
|-------------|--------|------|------|
| Systolic Blood Pressure | [____] | mmHg | [HH:MM] |
| Diastolic Blood Pressure | [____] | mmHg | [HH:MM] |
| Pulse Rate | [____] | beats/min | [HH:MM] |
| Weight | [____] | kg | [HH:MM] |

**Annotations:**

| CRF Field | SDTM Variable | Domain | Notes |
|-----------|---------------|--------|-------|
| Visit Date | **VSDTC** | *VS* | ISO 8601 date |
| Visit Number | **VISITNUM** | *VS* | 1–5 |
| Position | **VSPOS** | *VS* | "SITTING"/"STANDING"/"SUPINE" |
| Systolic BP | **VSTESTCD = "SYSBP"**, **VSTEST = "Systolic Blood Pressure"**, **VSORRES**, **VSORRESU = "mmHg"** | *VS* | Result as collected |
| Diastolic BP | **VSTESTCD = "DIABP"**, **VSTEST = "Diastolic Blood Pressure"**, **VSORRES**, **VSORRESU = "mmHg"** | *VS* | Result as collected |
| Pulse Rate | **VSTESTCD = "PULSE"**, **VSTEST = "Pulse Rate"**, **VSORRES**, **VSORRESU = "beats/min"** | *VS* | Result as collected |
| Weight | **VSTESTCD = "WEIGHT"**, **VSTEST = "Weight"**, **VSORRES**, **VSORRESU = "kg"** | *VS* | Result as collected |

**Derived SDTM Variables (not on CRF):**
- **USUBJID** (*VS*) = `cats(SITEID, "-", SUBJID)`
- **VSSEQ** (*VS*) = Sequential within subject
- **VSSTRESC** (*VS*) = `strip(VSORRES)`
- **VSSTRESN** (*VS*) = `input(VSORRES, best12.)`
- **VSSTRESU** (*VS*) = Same as VSORRESU
- **VSDY** (*VS*) = Study day from `RFSTDTC`
- **EPOCH** (*VS*) = Derived from `VSDTC` vs `RFSTDTC`
- **VSBLFL** (*VS*) = "Y" if VISITNUM = 2 and VSORRES populated

---

## FORM 5 — CLINICAL LABORATORY

### Visits: Screening (V1), Baseline (V2), Week 4 (V3), Week 8 (V4), Week 12 (V5)

**Collection Date:** [DD/MMM/YYYY]

**Collection Time:** [HH:MM]

**Specimen Type:** ☐ Serum ☐ Plasma ☐ Whole Blood ☐ Urine

| Test | Result | Unit | Normal Range |
|------|--------|------|--------------|
| Sodium | [____] | mmol/L | 135–145 |
| Potassium | [____] | mmol/L | 3.5–5.0 |
| Creatinine | [____] | mg/dL | 0.6–1.3 |
| Glucose | [____] | mg/dL | 70–100 |
| ALT | [____] | U/L | 7–56 |
| AST | [____] | U/L | 10–40 |

**Annotations:**

| CRF Field | SDTM Variable | Domain | Notes |
|-----------|---------------|--------|-------|
| Collection Date | **LBDTC** | *LB* | ISO 8601 date |
| Specimen Type | **LBSPEC** | *LB* | "SERUM"/"PLASMA" |
| Sodium | **LBTESTCD = "SODIUM"**, **LBTEST = "Sodium"**, **LBORRES**, **LBORRESU = "mmol/L"**, **LBORNRLO = "135"**, **LBORNRHI = "145"** | *LB* | |
| Potassium | **LBTESTCD = "POTASSIUM"**, **LBTEST = "Potassium"**, **LBORRES**, **LBORRESU = "mmol/L"**, **LBORNRLO = "3.5"**, **LBORNRHI = "5.0"** | *LB* | |
| Creatinine | **LBTESTCD = "CREAT"**, **LBTEST = "Creatinine"**, **LBORRES**, **LBORRESU = "mg/dL"**, **LBORNRLO = "0.6"**, **LBORNRHI = "1.3"** | *LB* | |
| Glucose | **LBTESTCD = "GLUCOSE"**, **LBTEST = "Glucose"**, **LBORRES**, **LBORRESU = "mg/dL"**, **LBORNRLO = "70"**, **LBORNRHI = "100"** | *LB* | |
| ALT | **LBTESTCD = "ALT"**, **LBTEST = "Alanine Aminotransferase"**, **LBORRES**, **LBORRESU = "U/L"**, **LBORNRLO = "7"**, **LBORNRHI = "56"** | *LB* | |
| AST | **LBTESTCD = "AST"**, **LBTEST = "Aspartate Aminotransferase"**, **LBORRES**, **LBORRESU = "U/L"**, **LBORNRLO = "10"**, **LBORNRHI = "40"** | *LB* | |

**Derived SDTM Variables:**
- **LBSEQ** = Sequential within subject
- **LBSTRESC** = `strip(LBORRES)`
- **LBSTRESN** = `input(LBORRES, best12.)`
- **LBSTRESU** = Same as LBORRESU
- **LBNRIND** = "LOW"/"NORMAL"/"HIGH" based on LBSTRESN vs LBORNRLO/HI
- **LBDY** = Study day from `RFSTDTC`
- **LBCAT** = "CHEMISTRY"
- **LBSCAT** = "ELECTROLYTES"/"RENAL FUNCTION"/"METABOLIC"/"LIVER FUNCTION"
- **LBMETHOD** = "ENZYMATIC"/"POTENTIOMETRY" per test
- **EPOCH** = Derived from LBDTC vs RFSTDTC

---

## FORM 6 — ADVERSE EVENTS

### Any Visit — Ongoing Log

**Instructions:** Record all adverse events (AEs) that occur from the time of informed consent through End of Study.

| Field | Response |
|-------|----------|
| AE Verbatim Term | [________________________] |
| Onset Date | [DD/MMM/YYYY] |
| Onset Time | [HH:MM] |
| End Date | [DD/MMM/YYYY] |
| End Time | [HH:MM] |
| Ongoing? | ☐ Yes ☐ No |
| Severity | ☐ Mild ☐ Moderate ☐ Severe |
| Serious? | ☐ Yes ☐ No |
| Relationship to Study Drug | ☐ Not Related ☐ Possibly Related ☐ Related |
| Action Taken | ☐ Dose Not Changed ☐ Drug Withdrawn ☐ Dose Reduced ☐ Dose Increased ☐ Unknown |
| Outcome | ☐ Recovered/Resolved ☐ Recovering/Resolving ☐ Not Recovered/Not Resolved ☐ Fatal ☐ Unknown |
| Concomitant Medication Given? | ☐ Yes ☐ No |

**If Serious, check all that apply:**

| Seriousness Criterion | Yes | No |
|-----------------------|:---:|:--:|
| Results in death | ☐ | ☐ |
| Life-threatening | ☐ | ☐ |
| Requires or prolongs hospitalization | ☐ | ☐ |
| Persistent or significant disability/incapacity | ☐ | ☐ |
| Congenital anomaly/birth defect | ☐ | ☐ |
| Other medically important serious event | ☐ | ☐ |

**Annotations:**

| CRF Field | SDTM Variable | Domain | Notes |
|-----------|---------------|--------|-------|
| AE Verbatim Term | **AETERM** | *AE* | Verbatim |
| Dictionary Term | **AEDECOD** | *AE* | MedDRA PT |
| Body System | **AEBODSYS** | *AE* | MedDRA SOC |
| Onset Date | **AESTDTC** | *AE* | ISO 8601 |
| End Date | **AEENDTC** | *AE* | ISO 8601 (blank if ongoing) |
| Ongoing | **AEENRF = "ONGOING"** | *AE* | If ongoing |
| Severity | **AESEV** | *AE* | "MILD"/"MODERATE"/"SEVERE" |
| Serious? | **AESER** | *AE* | "Y"/"N" |
| Relationship | **AEREL** | *AE* | "NOT RELATED"/"POSSIBLY RELATED"/"RELATED" |
| Action Taken | **AEACN** | *AE* | CDISC codelist |
| Outcome | **AEOUT** | *AE* | CDISC codelist |
| Results in death | **AESDTH** | *AE* | "Y"/"N" |
| Life-threatening | **AESLIFE** | *AE* | "Y"/"N" |
| Hospitalization | **AESHOSP** | *AE* | "Y"/"N" |
| Disability | **AESDISAB** | *AE* | "Y"/"N" |
| Congenital anomaly | **AESCONG** | *AE* | "Y"/"N" |
| Other medically important | **AESMIE** | *AE* | "Y"/"N" |

**Derived SDTM Variables:**
- **AESEQ** = Sequential within subject
- **AESTDY** = Study day from `AESTDTC` vs `RFSTDTC`
- **AEENDY** = Study day from `AEENDTC` vs `RFSTDTC`
- **EPOCH** = Derived from AESTDTC vs RFSTDTC

**Logic Rules:**
- If AEOUT = "FATAL" → AESDTH = "Y"
- If AESER = "Y" → at least one seriousness criterion must be "Y"

---

## FORM 7 — CONCOMITANT MEDICATIONS

### Any Visit

| Field | Response |
|-------|----------|
| Medication Name | [________________________] |
| Dose | [____] |
| Unit | [____] |
| Route | ☐ Oral ☐ IV ☐ IM ☐ Topical ☐ Other |
| Frequency | [____] |
| Start Date | [DD/MMM/YYYY] |
| End Date | [DD/MMM/YYYY] |
| Ongoing? | ☐ Yes ☐ No |
| Indication | [________________________] |

**Annotations:**

| CRF Field | SDTM Variable | Domain | Notes |
|-----------|---------------|--------|-------|
| Medication Name | **CMTRT** | *CM* | Verbatim |
| Dose | **CMDOSE** | *CM* | Numeric |
| Unit | **CMDOSU** | *CM* | CDISC codelist |
| Route | **CMROUTE** | *CM* | CDISC codelist |
| Frequency | **CMDOSFRQ** | *CM* | CDISC codelist |
| Start Date | **CMSTDTC** | *CM* | ISO 8601 |
| End Date | **CMENDTC** | *CM* | ISO 8601 |
| Indication | **CMINDC** | *CM* | Free text |

---

## FORM 8 — STUDY DRUG ADMINISTRATION (EXPOSURE)

### Visits: Baseline (V2), Week 4 (V3), Week 8 (V4)

**Study Drug Kit Number:** [________]

**Date of First Dose:** [DD/MMM/YYYY]

**Dose Administered:** [___] mg

**Unit:** mg

**Treatment:** ☐ HTN-101 50 mg ☐ Placebo

**Annotations:**

| CRF Field | SDTM Variable | Domain | Notes |
|-----------|---------------|--------|-------|
| Date of Dose | **EXSTDTC** | *EX* | ISO 8601 datetime |
| Dose Administered | **EXDOSE** | *EX* | Numeric (50 or 0) |
| Unit | **EXDOSU** | *EX* | "mg" |
| Treatment | **EXTRT** | *EX* | "HTN-101" or "PLACEBO" |
| Dose Form | **EXDOSFRM** | *EX* | "TABLET" |
| Frequency | **EXDOSFRQ** | *EX* | "QD" |
| Route | **EXROUTE** | *EX* | "ORAL" |
| Epoch | **EPOCH** | *EX* | "TREATMENT" |

**Derived SDTM Variables:**
- **EXSEQ** = Sequential per subject
- **EXSTDY** = Study day from EXSTDTC vs RFSTDTC
- **EXENDY** = Study day from EXENDTC vs RFSTDTC

---

## FORM 9 — RANDOMIZATION

### Visit: Baseline (V2)

**Randomization Date:** [DD/MMM/YYYY]

**Randomization Number:** [______]

**Treatment Assigned:** ☐ HTN-101 50 mg ☐ Placebo

**Annotations:**

| CRF Field | SDTM Variable | Domain | Notes |
|-----------|---------------|--------|-------|
| Randomization Date | **RANDDT** | *DM* | ISO 8601 |
| Treatment | **ARM**, **ARMCD** | *DM* | "HTN-101 50 mg"/"HTN101", "Placebo"/"PBO" |

**Derived SDTM Variables:**
- **RFSTDTC** = First dose date
- **RFXSTDTC** = First exposure datetime
- **ACTARM** = Actual treatment received
- **ACTARMCD** = Actual treatment code

---

## FORM 10 — DISPOSITION

### Visit: End of Study (V5) or Early Termination

**Date of Last Study Visit:** [DD/MMM/YYYY]

**Subject Status:** ☐ Completed ☐ Discontinued

**If Discontinued, Primary Reason:**
☐ Adverse Event
☐ Lost to Follow-up
☐ Withdrawal of Consent
☐ Protocol Violation
☐ Death
☐ Other: [________________________]

**Annotations:**

| CRF Field | SDTM Variable | Domain | Notes |
|-----------|---------------|--------|-------|
| Date of Last Visit | **DSSTDTC** | *DS* | ISO 8601 |
| Status | **DSTERM**, **DSDECOD** | *DS* | "COMPLETED"/"DISCONTINUED" |
| Discontinuation Reason | **DSTERM**, **DSDECOD** | *DS* | Per CDISC codelist |
| Category | **DSCAT** | *DS* | "DISPOSITION EVENT"/"DISCONTINUATION REASON" |

---

## FORM 11 — PHYSICAL EXAMINATION

### Visits: Screening (V1), End of Treatment (V5)

| System | Normal | Abnormal | If Abnormal, Specify |
|--------|:------:|:--------:|----------------------|
| General Appearance | ☐ | ☐ | [_______________] |
| Cardiovascular | ☐ | ☐ | [_______________] |
| Respiratory | ☐ | ☐ | [_______________] |
| Abdominal | ☐ | ☐ | [_______________] |
| Neurological | ☐ | ☐ | [_______________] |

**Annotation:** Not mapped to SDTM in this portfolio project.

---

## FORM 12 — 12-LEAD ECG

### Visits: Screening (V1), End of Treatment (V5)

**Date:** [DD/MMM/YYYY]

**Time:** [HH:MM]

**Interpretation:** ☐ Normal ☐ Abnormal, Not Clinically Significant ☐ Abnormal, Clinically Significant

**If Abnormal, Specify:** [________________________]

**Annotations:**

| CRF Field | SDTM Variable | Domain | Notes |
|-----------|---------------|--------|-------|
| Date | **EGDTC** | *EG* | ISO 8601 |
| Interpretation | **EGRESCAT** | *EG* | "NORMAL"/"ABNORMAL" |

**Note:** EG domain not implemented in this portfolio project.

---

## ANNOTATION SUMMARY TABLE

| CRF Form | SDTM Domain | Key Variables |
|----------|-------------|---------------|
| 1. Demographics | DM | USUBJID, BRTHDTC, AGE, SEX, RACE, ETHNIC, COUNTRY |
| 2. I/E Criteria | — | (Eligibility only) |
| 3. Medical History | MH | MHTERM, MHSTDTC, MHONGO |
| 4. Vital Signs | VS | VSTESTCD, VSORRES, VSORRESU, VSDTC, VSPOS |
| 5. Clinical Lab | LB | LBTESTCD, LBORRES, LBORNRLO/HI, LBDTC, LBSPEC |
| 6. Adverse Events | AE | AETERM, AESTDTC, AESEV, AESER, AEREL, AEOUT |
| 7. Concomitant Meds | CM | CMTRT, CMDOSE, CMROUTE, CMSTDTC |
| 8. Study Drug (Exposure) | EX | EXTRT, EXDOSE, EXDOSU, EXSTDTC |
| 9. Randomization | DM | ARM, ARMCD, RANDDT |
| 10. Disposition | DS | DSTERM, DSDECOD, DSCAT, DSSTDTC |
| 11. Physical Exam | — | (Not mapped in portfolio) |
| 12. 12-Lead ECG | EG | EGDTC, EGRESCAT (Not mapped) |

---

## CONSTANTS APPLIED IN ALL DOMAINS

| SDTM Variable | Value | Origin |
|---------------|-------|--------|
| STUDYID | "HTN101-301" | Assigned |
| DOMAIN | Per domain (DM, EX, VS, LB, AE, CM, DS, TS) | Assigned |
| USUBJID | `cats(SITEID, "-", SUBJID)` | Derived |
| EPOCH | "SCREENING" or "TREATMENT" | Derived from dates |

---

**END OF ANNOTATED CRF**

*Study HTN101-301 — Version 1.0*
*15 January 2024*