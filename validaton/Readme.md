# Pinnacle 21 Validation Evidence

This folder contains the Pinnacle 21 Community validation reports for the SDTM datasets (DM, EX, VS, LB, AE, TS). 

## 📂 Files
*   **`01_initial_errors.xlsx`**: The first validation run. It flagged several issues including variable order (`SD1079`), label mismatches (`SD0063`), and missing expected variables (`SD0057`).
*   **`02_final_clean.xlsx`**: The final validation run after resolving the programming issues.

## 🛠️ Issues Resolved
1.  **Variable Order (`SD1079`)**: Re-ordered the `length` statements to strictly match the SDTM-IG 3.2 sequence.
2.  **Label Mismatches (`SD0063`)**: Corrected the labels for `AESDISAB` (changed "Significant" to "Signif") and `AESLIFE`.
3.  **Missing Values (`SD1088`, `SD1092`)**: Fixed the `AESTDY` and `AEENDY` derivations by ensuring `RFSTDTC` was properly extracted.
4.  **Type Mismatch (`SD0055`)**: Converted `VSORRES` from numeric to character per SDTM standards.
5.  **Data Logic (`SD0090`)**: Programmed a rule so that if `AEOUT = "FATAL"`, `AESDTH` automatically resolves to "Y".
6.  **New Domain (`SD1115`)**: Added new SDTM TS doamin by deriving some necessary variables.
7.  **Define XML (`DD0101`)**: Added Define-XML file derived from `Pinnacle 21` Software.

*Note: MedDRA and SNOMED warnings are expected in Pinnacle 21 Community Edition as they require a commercial license.*