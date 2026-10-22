/*==========================================================
  Program : 01_import_raw.sas
  Study   : HTN101-301
  Purpose : Import synthetic raw clinical data (CSV → SAS)
  Author  : Abhijeet Shinde
==========================================================*/

/*----------------------------------------------------------
  1. Include setup 
----------------------------------------------------------*/
%let ROOT = /home/u64305129/Project/HTN101;
%include "&ROOT/programs/sas/00_setup.sas";

%put NOTE: =========================================;
%put NOTE: Importing raw data from &ROOT/data/raw;
%put NOTE: =========================================;

/*----------------------------------------------------------
  2. Import demographics (DM)
----------------------------------------------------------*/
proc import
    datafile     = "&ROOT/data/raw/demographics.csv"
    out          = raw.dm
    dbms         = csv
    replace;
    guessingrows = max;
    getnames     = yes;
run;

/*----------------------------------------------------------
  3. Import randomization
----------------------------------------------------------*/
proc import
    datafile     = "&ROOT/data/raw/randomization.csv"
    out          = raw.randomization
    dbms         = csv
    replace;
    guessingrows = max;
    getnames     = yes;
run;

/*----------------------------------------------------------
  4. Import exposure (EX)
----------------------------------------------------------*/
proc import
    datafile     = "&ROOT/data/raw/exposure.csv"
    out          = raw.ex
    dbms         = csv
    replace;
    guessingrows = max;
    getnames     = yes;
run;

/*----------------------------------------------------------
  5. Import vital signs (VS)
----------------------------------------------------------*/
proc import
    datafile     = "&ROOT/data/raw/vital_signs.csv"
    out          = raw.vs
    dbms         = csv
    replace;
    guessingrows = max;
    getnames     = yes;
run;

/*----------------------------------------------------------
  6. Import laboratory (LB)
----------------------------------------------------------*/
proc import
    datafile     = "&ROOT/data/raw/laboratory.csv"
    out          = raw.lb
    dbms         = csv
    replace;
    guessingrows = max;
    getnames     = yes;
run;

/*----------------------------------------------------------
  7. Import adverse events (AE)
----------------------------------------------------------*/
proc import
    datafile     = "&ROOT/data/raw/adverse_events.csv"
    out          = raw.ae
    dbms         = csv
    replace;
    guessingrows = max;
    getnames     = yes;
run;

/*----------------------------------------------------------
  8. Import concomitant medications (CM)
----------------------------------------------------------*/
proc import
    datafile     = "&ROOT/data/raw/medications.csv"
    out          = raw.cm
    dbms         = csv
    replace;
    guessingrows = max;
    getnames     = yes;
run;

/*----------------------------------------------------------
  9. Import disposition (DS)
----------------------------------------------------------*/
proc import
    datafile     = "&ROOT/data/raw/disposition.csv"
    out          = raw.ds
    dbms         = csv
    replace;
    guessingrows = max;
    getnames     = yes;
run;

/*----------------------------------------------------------
  10. Verify — Contents of all raw datasets
----------------------------------------------------------*/
proc contents data = raw._all_ nods;
    title "Raw Datasets — Contents Summary";
run;

/*----------------------------------------------------------
  11. Verify — Record counts per dataset
----------------------------------------------------------*/
proc sql;
    title "Raw Datasets — Record Counts";

    select "dm"  as Dataset length=20, count(*) as N from raw.dm
    union all
    select "randomization",      count(*)     from raw.randomization
    union all
    select "ex",                 count(*)     from raw.ex
    union all
    select "vs",                 count(*)     from raw.vs
    union all
    select "lb",                 count(*)     from raw.lb
    union all
    select "ae",                 count(*)     from raw.ae
    union all
    select "cm",                 count(*)     from raw.cm
    union all
    select "ds",                 count(*)     from raw.ds;
quit;

%put NOTE: =========================================;
%put NOTE: Import complete;
%put NOTE: =========================================;