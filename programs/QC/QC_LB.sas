/*==========================================================
  Program : QC_LB.sas
  Study   : HTN101-301
  Purpose : Independent QC of SDTM LB domain
  Author  : Abhijeet Shinde
==========================================================*/

%include "&ROOT/programs/sas/00_setup.sas";

title "QC Report — SDTM LB Domain";
title2 "Study: &STUDYID";

/*==========================================================
  1. RECORD & SUBJECT COUNT
==========================================================*/
proc sql;
    title3 "1. Record & Subject Counts";
    select  count(*)                 as N_Records,
            count(distinct USUBJID)  as N_Subjects,
            count(distinct LBTESTCD) as N_Tests
    from sdtm.lb;
quit;

/*==========================================================
  2. UNIQUENESS — One record per Subject/Test/Visit
==========================================================*/
proc sql;
    title3 "2. Duplicate Subject+Test+Date — Should be 0 rows";
    select USUBJID, LBTESTCD, LBDTC, count(*) as N
    from sdtm.lb
    group by USUBJID, LBTESTCD, LBDTC
    having count(*) > 1;
quit;

/*==========================================================
  3. LBSEQ UNIQUENESS PER SUBJECT
==========================================================*/
proc sql;
    title3 "3. Duplicate LBSEQ per Subject — Should be 0 rows";
    select USUBJID, LBSEQ, count(*) as N
    from sdtm.lb
    group by USUBJID, LBSEQ
    having count(*) > 1;
quit;

/*==========================================================
  4. REQUIRED VARIABLES — MISSING CHECK
==========================================================*/
proc freq data = sdtm.lb;
    title3 "4. Missing Value Check — Key Variables";
    tables STUDYID DOMAIN USUBJID LBSEQ LBTESTCD LBTEST
           LBCAT LBORRES LBORRESU LBDTC / missing nocum;
run;

/*==========================================================
  5. STUDYID & DOMAIN CONSTANT
==========================================================*/
proc freq data = sdtm.lb;
    title3 "5. STUDYID and DOMAIN — Should be Constant";
    tables STUDYID DOMAIN / missing nocum;
run;

/*==========================================================
  6. TEST CODE & TEST NAME MAPPING
==========================================================*/
proc freq data = sdtm.lb;
    title3 "6. LBTESTCD × LBTEST — Should be 1-to-1";
    tables LBTESTCD * LBTEST / list missing;
run;

/*==========================================================
  7. CONTROLLED TERMINOLOGY — Expected Test Codes
==========================================================*/
data _check_ct;
    set sdtm.lb;
    if LBTESTCD not in ("SODIUM", "K", "CREAT",
                        "GLUC", "ALT", "AST") then output;
run;

proc sql;
    title3 "7. LBTESTCD Outside Expected CT — Should be 0 rows";
    select distinct USUBJID, LBTESTCD from _check_ct;
quit;

/*==========================================================
  8. LBCAT / LBSCAT ASSIGNMENT
==========================================================*/
proc freq data = sdtm.lb;
    title3 "8a. LBCAT Distribution — Expected Only CHEMISTRY";
    tables LBCAT / missing nocum;
run;

proc freq data = sdtm.lb;
    title3 "8b. LBCAT × LBTESTCD — Should be 1-to-1";
    tables LBCAT * LBTESTCD / list missing;
run;

proc freq data = sdtm.lb;
    title3 "8c. LBCAT Distribution";
    tables LBCAT / missing nocum;
run;

/*==========================================================
  9. RESULT RANGE CHECK — Plausibility
==========================================================*/
proc means data = sdtm.lb n nmiss min max mean std;
    class LBTESTCD;
    var LBORRES;              /* if LBORRES is numeric */
    title3 "9. LBORRES — Ranges by Test";
run;

/*==========================================================
  10. STUDY DAY CHECK — LBDY should never be 0
==========================================================*/
proc sql;
    title3 "10. LBDY = 0 — Should be 0 rows (no Day 0)";
    select USUBJID, LBTESTCD, LBDTC, LBDY
    from sdtm.lb
    where LBDY = 0;
quit;

/*==========================================================
  11. CROSS-DOMAIN — Every DM Subject Should Exist in LB
==========================================================*/
proc sql;
    title3 "11. Subjects in DM but Not in LB";
    select USUBJID from sdtm.dm
    where USUBJID not in (select distinct USUBJID from sdtm.lb);
quit;

/*==========================================================
  12. FINAL SUMMARY
==========================================================*/
proc sql;
    title3 "12. QC Summary — LB Domain";
    select  "Total Records"                 as Check length=35,
            put(count(*), 8.)               as Result
    from sdtm.lb
    union all
    select  "Distinct Subjects",
            put(count(distinct USUBJID), 8.)
    from sdtm.lb
    union all
    select  "Distinct Test Codes",
            put(count(distinct LBTESTCD), 8.)
    from sdtm.lb
    union all
    select  "Distinct Categories",
            put(count(distinct LBCAT), 8.)
    from sdtm.lb
    union all
    select  "Missing LBORRES",
            put(sum(missing(LBORRES)), 8.)     
    from sdtm.lb
    union all
    select  "Missing LBDTC",
            put(sum(missing(LBDTC)), 8.)       
    from sdtm.lb
    union all
    select  "LBDY = 0 (should be 0)",
            put(sum(LBDY = 0), 8.)
    from sdtm.lb;
quit;

title; title2; title3;