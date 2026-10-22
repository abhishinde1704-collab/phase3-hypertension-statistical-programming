/*==========================================================
  Program : QC_EX.sas
  Study   : HTN101-301
  Purpose : Independent QC of SDTM EX domain
  Author  : Abhijeet Shinde
==========================================================*/

%include "&ROOT/programs/sas/00_setup.sas";

title "QC Report — SDTM EX Domain";
title2 "Study: &STUDYID";

/*==========================================================
  1. RECORD & SUBJECT COUNT
==========================================================*/
proc sql;
    title3 "1. Record & Subject Counts";
    select  count(*)                 as N_Records,
            count(distinct USUBJID)  as N_Subjects
    from sdtm.ex;
quit;

/*==========================================================
  2. ONE RECORD PER EXSEQ PER SUBJECT (uniqueness)
==========================================================*/
proc sql;
    title3 "2. Duplicate EXSEQ per Subject - Should be 0 rows";
    select USUBJID, EXSEQ, count(*) as N
    from sdtm.ex
    group by USUBJID, EXSEQ
    having count(*) > 1;
quit;

/*==========================================================
  3. REQUIRED VARIABLES — MISSING CHECK
==========================================================*/
proc freq data = sdtm.ex;
    title3 "3. Missing Value Check — Key Variables";
    tables STUDYID DOMAIN USUBJID EXSEQ EXTRT EXDOSE EXDOSU
           EXSTDTC / missing nocum;
run;

/*==========================================================
  4. STUDYID & DOMAIN CONSTANT
==========================================================*/
proc freq data = sdtm.ex;
    title3 "4. STUDYID and DOMAIN — Should be Constant";
    tables STUDYID DOMAIN / missing nocum;
run;

/*==========================================================
  5. TREATMENT DISTRIBUTION (EXTRT)
==========================================================*/
proc freq data = sdtm.ex;
    title3 "5. Actual Treatment Distribution (EXTRT)";
    tables EXTRT / missing nocum;
run;

/*==========================================================
  6. DOSE CONSISTENCY — HTN-101 should be 50 mg, Placebo = 0
==========================================================*/
proc freq data = sdtm.ex;
    title3 "6. Dose Consistency — EXTRT × EXDOSE × EXDOSU";
    tables EXTRT * EXDOSE * EXDOSU / list missing;
run;

/*==========================================================
  7. DATE LOGIC — EXSTDTC ≤ EXENDTC
==========================================================*/
data _check_dates;
    set sdtm.ex;
    if not missing(EXSTDTC) and not missing(EXENDTC) then do;
        EXSTDT = input(EXSTDTC, e8601dt16.);
        EXENDT = input(EXENDTC, e8601dt16.);
        if EXSTDT > EXENDT then output;
    end;
run;

proc sql;
    title3 "7. EXSTDTC > EXENDTC — Should be 0 rows";
    select USUBJID, EXSEQ, EXSTDTC, EXENDTC from _check_dates;
quit;

/*==========================================================
  8. STUDY DAY CHECK — EXSTDY should never be 0
==========================================================*/
proc sql;
    title3 "8. EXSTDY = 0 — Should be 0 rows (no Day 0)";
    select USUBJID, EXSEQ, EXSTDTC, EXSTDY
    from sdtm.ex
    where EXSTDY = 0;
quit;

/*==========================================================
  9. CROSS-DOMAIN — Every DM Subject Should Exist in EX
==========================================================*/
proc sql;
    title3 "9. Subjects in DM but Not in EX";
    select USUBJID from sdtm.dm
    where USUBJID not in (select distinct USUBJID from sdtm.ex);
quit;

/*==========================================================
  10. RFXSTDTC (DM) should match min(EXSTDTC) per subject
==========================================================*/
proc sql;
    create table ex_min as
    select USUBJID, min(EXSTDTC) as MIN_EXSTDTC
    from sdtm.ex
    group by USUBJID;

    create table _check_rfx as
    select d.USUBJID, d.RFXSTDTC, e.MIN_EXSTDTC
    from sdtm.dm as d
    left join ex_min as e
      on d.USUBJID = e.USUBJID
    where d.RFXSTDTC ne e.MIN_EXSTDTC;

    title3 "10. DM.RFXSTDTC ≠ min(EX.EXSTDTC) — Should be 0 rows";
    select * from _check_rfx;
quit;

/*==========================================================
  11. FINAL SUMMARY
==========================================================*/
proc sql;
    title3 "11. QC Summary — EX Domain";
    select  "Total Records"             as Check length=30,
            put(count(*), 8.)           as Result
    from sdtm.ex
    union all
    select  "Distinct Subjects",
            put(count(distinct USUBJID), 8.)
    from sdtm.ex
    union all
    select  "HTN-101 Records",
            put(sum(EXTRT = "HTN-101"), 8.)
    from sdtm.ex
    union all
    select  "Placebo Records",
            put(sum(EXTRT = "PLACEBO"), 8.)
    from sdtm.ex
    union all
    select  "Missing EXSTDTC",
            put(sum(EXSTDTC = ""), 8.)
    from sdtm.ex
    union all
    select  "EXSTDY = 0 (should be 0)",
            put(sum(EXSTDY = 0), 8.)
    from sdtm.ex;
quit;

title; title2; title3;