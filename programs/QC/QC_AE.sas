/*==========================================================
  Program : QC_AE.sas
  Study   : HTN101-301
  Purpose : Independent QC of SDTM AE domain
  Author  : Abhijeet Shinde
==========================================================*/

%include "&ROOT/programs/sas/00_setup.sas";

title "QC Report — SDTM AE Domain";
title2 "Study: &STUDYID";

/*==========================================================
  1. RECORD & SUBJECT COUNT
==========================================================*/
proc sql;
    title3 "1. Record & Subject Counts";
    select  count(*)                 as N_Records,
            count(distinct USUBJID)  as N_Subjects
    from sdtm.ae;
quit;

/*==========================================================
  2. AESEQ UNIQUENESS PER SUBJECT
==========================================================*/
proc sql;
    title3 "2. Duplicate AESEQ per Subject — Should be 0 rows";
    select USUBJID, AESEQ, count(*) as N
    from sdtm.ae
    group by USUBJID, AESEQ
    having count(*) > 1;
quit;

/*==========================================================
  3. REQUIRED VARIABLES — MISSING CHECK
==========================================================*/
proc freq data = sdtm.ae;
    title3 "3. Missing Value Check — Key Variables";
    tables STUDYID DOMAIN USUBJID AESEQ AETERM AESEV AESER
           AEREL AESTDTC / missing nocum;
run;

/*==========================================================
  4. STUDYID & DOMAIN CONSTANT
==========================================================*/
proc freq data = sdtm.ae;
    title3 "4. STUDYID and DOMAIN — Should be Constant";
    tables STUDYID DOMAIN / missing nocum;
run;

/*==========================================================
  5. CONTROLLED TERMINOLOGY — AESEV
==========================================================*/
proc freq data = sdtm.ae;
    title3 "5a. AESEV — Expected: MILD, MODERATE, SEVERE";
    tables AESEV / missing nocum;
run;

data _check_sev;
    set sdtm.ae;
    if AESEV not in ("MILD", "MODERATE", "SEVERE", "") then output;
run;

proc sql;
    title3 "5b. AESEV CT Violations — Should be 0 rows";
    select distinct USUBJID, AESEV from _check_sev;
quit;


/*==========================================================
  6. Seriousness Criteria Consistency
==========================================================*/

/* 6a. AESER must be Y or N */
data _check_aeser;
    set sdtm.ae;
    if AESER not in ("Y", "N", "") then output;
run;

proc sql;
    title3 "6a. AESER Invalid Values — Should Be 0 Rows";
    select distinct USUBJID, AESER from _check_aeser;
quit;

/* 6b. Serious AE must have at least one Y criterion */
proc sql;
    title3 "6b. Serious AEs Without Qualifying Criterion — Should Be 0 Rows";
    select USUBJID, AESEQ, AETERM, AESER,
           AESDTH, AESLIFE, AESHOSP, AESDISAB, AESCONG, AESMIE
    from sdtm.ae
    where AESER = "Y"
      and AESDTH   = "N"
      and AESLIFE  = "N"
      and AESHOSP  = "N"
      and AESDISAB = "N"
      and AESCONG  = "N"
      and AESMIE   = "N";
quit;

/* 6c. Non-serious AE must not have Y criterion */
proc sql;
    title3 "6c. Non-Serious AEs With Y Criterion — Should Be 0 Rows";
    select USUBJID, AESEQ, AETERM, AESER,
           AESDTH, AESLIFE, AESHOSP, AESDISAB, AESCONG, AESMIE
    from sdtm.ae
    where AESER = "N"
      and (AESDTH = "Y" or AESLIFE = "Y" or AESHOSP = "Y"
           or AESDISAB = "Y" or AESCONG = "Y" or AESMIE = "Y");
quit;

/* 6d. Criteria variables have valid values */
proc freq data = sdtm.ae;
    title3 "6d. Seriousness Criteria Frequency";
    tables AESDTH AESLIFE AESHOSP AESDISAB AESCONG AESMIE / missing;
run;

/*==========================================================
  7. CONTROLLED TERMINOLOGY — AEREL
==========================================================*/
proc freq data = sdtm.ae;
    title3 "7a. AEREL — Relationship to Study Drug";
    tables AEREL / missing nocum;
run;

data _check_rel;
    set sdtm.ae;
    if AEREL not in ("NOT RELATED", "POSSIBLY RELATED", "RELATED", "") then output;
run;

proc sql;
    title3 "7b. AEREL CT Violations — Should be 0 rows";
    select distinct USUBJID, AEREL from _check_rel;
quit;

/*==========================================================
  8. DATE LOGIC — AESTDTC ≤ AEENDTC
==========================================================*/
data _check_dates;
    set sdtm.ae;
    if not missing(AESTDTC) and not missing(AEENDTC) then do;
        AESTDT = input(AESTDTC, yymmdd10.);
        AEENDT = input(AEENDTC, yymmdd10.);
        if AESTDT > AEENDT then output;
    end;
run;

proc sql;
    title3 "8. AESTDTC > AEENDTC — Should be 0 rows";
    select USUBJID, AESEQ, AESTDTC, AEENDTC from _check_dates;
quit;

/*==========================================================
  9. STUDY DAY CHECK — AESTDY should never be 0
==========================================================*/
proc sql;
    title3 "9a. AESTDY = 0 — Should be 0 rows (no Day 0)";
    select USUBJID, AESEQ, AESTDTC, AESTDY
    from sdtm.ae
    where AESTDY = 0;
quit;

proc sql;
    title3 "9b. AEENDY = 0 — Should be 0 rows (no Day 0)";
    select USUBJID, AESEQ, AEENDTC, AEENDY
    from sdtm.ae
    where AEENDY = 0;
quit;

/*==========================================================
  10. ONGOING AE CHECK
==========================================================*/
/* Ongoing AE: AEENDTC missing AND AEENRF = "ONGOING" */
proc sql;
    title3 "10a. Ongoing AEs Missing AEENRF — Should be 0 rows";
    select USUBJID, AESEQ, AESTDTC, AEENDTC, AEENRF
    from sdtm.ae
    where missing(AEENDTC) and AEENRF ne "ONGOING";
quit;

/* AEENDTC present but AEENRF = ONGOING (contradiction) */
proc sql;
    title3 "10b. AEENDTC Present but AEENRF = ONGOING — Should be 0 rows";
    select USUBJID, AESEQ, AEENDTC, AEENRF
    from sdtm.ae
    where not missing(AEENDTC) and AEENRF = "ONGOING";
quit;

/*==========================================================
  11. CROSS-DOMAIN — Every AE Subject Must Exist in DM
==========================================================*/
proc sql;
    title3 "11. AE Subjects Not Found in DM — Should be 0 rows";
    select distinct USUBJID
    from sdtm.ae
    where USUBJID not in (select USUBJID from sdtm.dm);
quit;

/*==========================================================
  12. AE START DATE ON/AFTER FIRST DOSE (Informational)
==========================================================*/
proc sql;
    title3 "12. AEs with AESTDTC Before RFSTDTC — Preview of TEAE logic";
    select  a.USUBJID, a.AESEQ, a.AETERM, a.AESTDTC,
            d.RFSTDTC
    from sdtm.ae as a
    left join sdtm.dm as d
      on a.USUBJID = d.USUBJID
    where a.AESTDTC ne "" and d.RFSTDTC ne ""
      and input(a.AESTDTC, yymmdd10.) < input(d.RFSTDTC, yymmdd10.);
quit;

/*==========================================================
  13. FINAL SUMMARY
==========================================================*/
proc sql;
    title3 "13. QC Summary — AE Domain";
    select  "Total Records"      as Check length=40,
            put(count(*), 8.)    as Result
    from sdtm.ae
    union all
    select  "Distinct Subjects",
            put(count(distinct USUBJID), 8.)
    from sdtm.ae
    union all
    select  "Serious AEs (AESER = Y)",
            put(sum(AESER = "Y"), 8.)
    from sdtm.ae
    union all
    select  "Ongoing AEs (AEENRF = ONGOING)",
            put(sum(AEENRF = "ONGOING"), 8.)
    from sdtm.ae
    union all
    select  "Missing AETERM",
            put(sum(missing(AETERM)), 8.)
    from sdtm.ae
    union all
    select  "Missing AESTDTC",
            put(sum(missing(AESTDTC)), 8.)
    from sdtm.ae
    union all
    select  "Missing AESEV",
            put(sum(missing(AESEV)), 8.)
    from sdtm.ae
    union all
    select  "Missing AESER",
            put(sum(missing(AESER)), 8.)
    from sdtm.ae
    union all
    select  "AESTDY = 0 (should be 0)",
            put(sum(AESTDY = 0), 8.)
    from sdtm.ae;
quit;

title; title2; title3;