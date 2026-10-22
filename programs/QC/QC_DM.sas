/*==========================================================
  Program : QC_DM.sas
  Study   : HTN101-301
  Purpose : QC of SDTM DM domain
  Author  : Abhijeet Shinde
==========================================================*/

%include "&ROOT/programs/sas/00_setup.sas";

/*==========================================================
  1. STRUCTURE CHECK — Variables, types, lengths
==========================================================*/
proc contents data = sdtm.dm varnum;
    title "QC DM — Structure";
run;

/*==========================================================
  2. RECORD & SUBJECT COUNT
==========================================================*/
proc sql;
    title "QC DM — Counts";
    select  count(*)                 as N_Records,
            count(distinct USUBJID)  as N_Subjects
    from sdtm.dm;
quit;

/*==========================================================
  3. ONE RECORD PER SUBJECT
==========================================================*/
proc sql;
    title "QC DM — Duplicate Subjects";
    select USUBJID, count(*) as N
    from sdtm.dm
    group by USUBJID
    having count(*) > 1;
quit;

/*==========================================================
  4. USUBJID FORMAT CHECK
   USUBJID should be SITEID-SUBJID
==========================================================*/
data _check_usubjid;
    set sdtm.dm;
    length EXPECTED $40;
    EXPECTED = catx("-",STUDYID,SUBJID);
    if USUBJID ne EXPECTED then output;
run;

proc sql;
    title "QC DM — USUBJID Format Errors";
    select USUBJID, SITEID, SUBJID from _check_usubjid;
quit;

/*==========================================================
  5. MISSING VALUES — Key Variables
==========================================================*/
proc freq data = sdtm.dm;
    title "QC DM — Missing Value Check";
    tables STUDYID DOMAIN USUBJID SUBJID SITEID
           SEX RACE ARMCD ARM ACTARMCD ACTARM
           RFSTDTC
           / missing nocum;
run;

/*==========================================================
  6. CONTROLLED TERMINOLOGY
==========================================================*/
proc freq data = sdtm.dm;
    title "QC DM — Treatment & Demographics Distribution";
    tables SEX RACE ARMCD ACTARMCD / missing nocum;
run;

/*==========================================================
  7. AGE CHECK
==========================================================*/
proc means data = sdtm.dm n nmiss min max mean;
    title "QC DM — Age Summary";
    var AGE;
run;

/*==========================================================
  8. AGE DERIVATION CHECK
   AGE should match BRTHDTC vs RFSTDTC
==========================================================*/
data _check_age;
    set sdtm.dm;
    if not missing(BRTHDTC) and not missing(RFSTDTC) then do;
        BDT = input(BRTHDTC, yymmdd10.);
        RDT = datepart(input(RFSTDTC, e8601dt16.));
        CALC_AGE = floor((RDT - BDT) / 365.25);
        if abs(AGE - CALC_AGE) > 1 then output;
    end;
run;

proc sql;
    title "QC DM — Age Derivation Errors";
    select USUBJID, BRTHDTC, RFSTDTC, AGE, CALC_AGE
    from _check_age;
quit;

/*==========================================================
  9. RFSTDTC MUST MATCH FIRST EXSTDTC IN EX
==========================================================*/
proc sql;
    title "QC DM — RFSTDTC vs First EXSTDTC";
    select  d.USUBJID,
            d.RFSTDTC       as DM_RFSTDTC,
            min(e.EXSTDTC)  as FIRST_EX
    from sdtm.dm as d
    left join sdtm.ex as e
      on d.USUBJID = e.USUBJID
    group by d.USUBJID, d.RFSTDTC;
quit;
/*==========================================================
  10. TREATMENT DISTRIBUTION (Expected 50/50)
==========================================================*/
proc sql;
    title "QC DM — Treatment Distribution";
    select  ARMCD,
            count(*) as N
    from sdtm.dm
    group by ARMCD;
quit;

/*==========================================================
  11. SUMMARY DASHBOARD
==========================================================*/
proc sql;
    title "QC DM — Summary Dashboard";
    select "Total Records"     as Check length = 25,
           put(count(*), 8.)   as Value
    from sdtm.dm
    union all
    select "Distinct Subjects",
           put(count(distinct USUBJID), 8.)
    from sdtm.dm
    union all
    select "HTN-101 Subjects",
           put(sum(ARMCD = "HTN101"), 8.)
    from sdtm.dm
    union all
    select "Placebo Subjects",
           put(sum(ARMCD = "PBO"), 8.)
    from sdtm.dm
    union all
    select "Missing RFSTDTC",
           put(sum(RFSTDTC = ""), 8.)
    from sdtm.dm;
quit;

title;