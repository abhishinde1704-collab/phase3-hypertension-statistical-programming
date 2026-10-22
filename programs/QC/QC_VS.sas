/*==========================================================
  Program : QC_VS.sas
  Study   : HTN101-301
  Purpose : Independent QC of SDTM VS domain
  Author  : Abhijeet Shinde
==========================================================*/

%include "&ROOT/programs/sas/00_setup.sas";

title "QC Report — SDTM VS Domain";
title2 "Study: &STUDYID";

/*==========================================================
  1. RECORD & SUBJECT COUNT
==========================================================*/
proc sql;
    title3 "1. Record & Subject Counts";
    select  count(*)                 as N_Records,
            count(distinct USUBJID)  as N_Subjects,
            count(distinct VSTESTCD) as N_Tests
    from sdtm.vs;
quit;

/*==========================================================
  2. UNIQUENESS — One record per Subject/Test/Visit
==========================================================*/
proc sql;
    title3 "2. Duplicate Subject+Test+Visit — Should be 0 rows";
    select USUBJID, VSTESTCD, VSDTC, count(*) as N
    from sdtm.vs
    group by USUBJID, VSTESTCD, VSDTC
    having count(*) > 1;
quit;

/*==========================================================
  3. VSSEQ UNIQUENESS PER SUBJECT
==========================================================*/
proc sql;
    title3 "3. Duplicate VSSEQ per Subject — Should be 0 rows";
    select USUBJID, VSSEQ, count(*) as N
    from sdtm.vs
    group by USUBJID, VSSEQ
    having count(*) > 1;
quit;

/*==========================================================
  4. REQUIRED VARIABLES — MISSING CHECK
==========================================================*/
proc freq data = sdtm.vs;
    title3 "4. Missing Value Check — Key Variables";
    tables STUDYID DOMAIN USUBJID VSSEQ VSTESTCD VSTEST
           VSORRES VSORRESU VSDTC / missing nocum;
run;

/*==========================================================
  5. STUDYID & DOMAIN CONSTANT
==========================================================*/
proc freq data = sdtm.vs;
    title3 "5. STUDYID and DOMAIN — Should be Constant";
    tables STUDYID DOMAIN / missing nocum;
run;

/*==========================================================
  6. TEST CODE & TEST NAME MAPPING
==========================================================*/
proc freq data = sdtm.vs;
    title3 "6. VSTESTCD × VSTEST — Should be 1-to-1";
    tables VSTESTCD * VSTEST / list missing;
run;

/*==========================================================
  7. CONTROLLED TERMINOLOGY — Expected Test Codes
==========================================================*/
data _check_ct;
    set sdtm.vs;
    if VSTESTCD not in ("SYSBP", "DIABP", "PULSE", "WEIGHT") then output;
run;

proc sql;
    title3 "7. VSTESTCD Outside Expected CT — Should be 0 rows";
    select distinct USUBJID, VSTESTCD from _check_ct;
quit;

/*==========================================================
  8. RESULT RANGE CHECK — Plausibility
==========================================================*/
proc means data = sdtm.vs n nmiss min max mean std;
    class VSTESTCD;
    var VSSTRESN;              
    title3 "8. VSSTRESN — Ranges by Test";
run;

/*==========================================================
  9. STUDY DAY CHECK — VSDY should never be 0
==========================================================*/
proc sql;
    title3 "9. VSDY = 0 — Should be 0 rows (no Day 0)";
    select USUBJID, VSTESTCD, VSDTC, VSDY
    from sdtm.vs
    where VSDY = 0;
quit;

/*==========================================================
  10. CROSS-DOMAIN — Every DM Subject Should Exist in VS
==========================================================*/
proc sql;
    title3 "10. Subjects in DM but Not in VS";
    select USUBJID from sdtm.dm
    where USUBJID not in (select distinct USUBJID from sdtm.vs);
quit;

/*==========================================================
  11. FINAL SUMMARY
==========================================================*/
proc sql;
    title3 "11. QC Summary — VS Domain";
    select  "Total Records"                 as Check length=35,
            put(count(*), 8.)               as Result
    from sdtm.vs
    union all
    select  "Distinct Subjects",
            put(count(distinct USUBJID), 8.)
    from sdtm.vs
    union all
    select  "Distinct Test Codes",
            put(count(distinct VSTESTCD), 8.)
    from sdtm.vs
    union all
    select  "Missing VSSTRESN",
            put(sum(VSSTRESN = .), 8.)
    from sdtm.vs
    union all
    select  "Missing VSDTC",
            put(sum(VSDTC = ""), 8.)
    from sdtm.vs
    union all
    select  "VSDY = 0 (should be 0)",
            put(sum(VSDY = 0), 8.)
    from sdtm.vs;
quit;

title; title2; title3;