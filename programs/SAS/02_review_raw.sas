/*==========================================================
  Program : 02_review_raw.sas
  Project : Phase III Hypertension Clinical Trial
  Purpose : Review raw datasets before SDTM programming
==========================================================*/

%let ROOT = /home/u64305129/Project/HTN101;
%include "&ROOT/programs/sas/00_setup.sas";

/*----------------------------------------------------------
  1. CONTENTS & RECORD COUNTS (Combined)
----------------------------------------------------------*/
title "1. Raw Dataset Metadata & Record Counts";

proc sql;
    select  memname as Dataset,
            nobs as N_Records,
            nvar as N_Variables
    from dictionary.tables
    where libname = "RAW"
    order by memname;
quit;

/*----------------------------------------------------------
  2. FIRST 5 RECORDS (Using a Macro Loop)
----------------------------------------------------------*/
%macro print_obs(dsn, n=5);
    title "2. Preview: %upcase(&dsn)";
    proc print data=raw.&dsn(obs=&n);
    run;
%mend;

%print_obs(dm);
%print_obs(randomization);
%print_obs(ex);
%print_obs(vs);
%print_obs(lb);
%print_obs(ae);
%print_obs(cm);
%print_obs(ds);

/*----------------------------------------------------------
  3. UNIQUE SUBJECT COUNTS ACROSS ALL DATASETS
----------------------------------------------------------*/
title "3. Unique Subjects per Dataset (Expected: 100 for DM/Rand, <100 for others)";
proc sql;
    select "DM" as Dataset, count(distinct SUBJECT) as N_Subjects from raw.dm
    union all
    select "Randomization", count(distinct SUBJECT) from raw.randomization
    union all
    select "Exposure", count(distinct SUBJECT) from raw.ex
    union all
    select "Vital Signs", count(distinct SUBJECT) from raw.vs
    union all
    select "Laboratory", count(distinct SUBJECT) from raw.lb
    union all
    select "Adverse Events", count(distinct SUBJECT) from raw.ae
    union all
    select "Medications", count(distinct SUBJECT) from raw.cm
    union all
    select "Disposition", count(distinct SUBJECT) from raw.ds;
quit;

/*----------------------------------------------------------
  4. DEMOGRAPHICS PROFILE
----------------------------------------------------------*/
title "4. Demographics: Gender & Race";
proc freq data=raw.dm;
    tables GENDER RACE ETHNICITY / missing nocum;
run;

title "4b. Demographics: Age Summary";
proc means data=raw.dm n nmiss min max mean median;
    var AGE;
run;

/*----------------------------------------------------------
  5. TREATMENT DISTRIBUTIONS
----------------------------------------------------------*/
title "5. Treatment Distributions";
proc freq data=raw.randomization;
    tables RAND_GROUP / missing nocum;
run;

proc freq data=raw.ex;
    tables TREATMENT / missing nocum;
run;

/*----------------------------------------------------------
  6. EXPOSURE DATE CHECK
----------------------------------------------------------*/
title "6. Exposure Date Range";
proc sql;
    select  count(*)                         as N_Records,
            count(distinct SUBJECT)          as N_Subjects,
            count(distinct DOSE_DTM)         as N_Distinct_DTM,
            sum(DOSE_DTM is missing)         as N_Missing_DTM,
            min(DOSE_DTM)                    as Earliest_Exposure,
            max(DOSE_DTM)                    as Latest_Exposure
    from raw.ex;
quit;

/*----------------------------------------------------------
  7. EXPOSURE RECORDS PER SUBJECT
----------------------------------------------------------*/
title "7. Exposure Records per Subject";
proc sql;
    select  SUBJECT, count(*) as N_EX_RECORDS
    from raw.ex
    group by SUBJECT
    having N_EX_RECORDS > 1
    order by N_EX_RECORDS desc;
quit;

/*----------------------------------------------------------
  8. KEY TERMS (VS, LB, AE, CM)
----------------------------------------------------------*/
title "8. Key Test/Term Distributions";
proc freq data=raw.vs; tables VSTEST / missing nocum; run;
proc freq data=raw.lb; tables LBTEST / missing nocum; run;
proc freq data=raw.ae; tables AETERM / missing nocum; run;
proc freq data=raw.cm; tables CMTRT / missing nocum; run;

/*----------------------------------------------------------
  9. RECONCILIATION CHECKS (Duplicates & Missing)
----------------------------------------------------------*/
title "9. Data Reconciliation Checks";

/* Duplicates */
proc sql;
    select  "Duplicate DM Subjects" as Check length=30, count(*) as Count
    from (select SUBJECT from raw.dm group by SUBJECT having count(*) > 1)
    union all
    select  "Duplicate Rand Subjects", count(*) 
    from (select SUBJECT from raw.randomization group by SUBJECT having count(*) > 1)
    union all
    select  "DM but not in Rand", count(*) 
    from raw.dm where SUBJECT not in (select SUBJECT from raw.randomization)
    union all
    select  "Rand but not in DM", count(*) 
    from raw.randomization where SUBJECT not in (select SUBJECT from raw.dm);
quit;

title;