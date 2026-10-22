/*==========================================================
 Program: LB.sas
 Domain : Laboratory (LB)
 Study  : HTN101-301
==========================================================*/

data LB1;
length STUDYID $12. DOMAIN $2. SUBJID $10. USUBJID $20. LBTESTCD $8. LBTEST $40.
       LBCAT $40. LBORRESU $15. LBSTRESC $20. LBSTRESU $15. LBSTAT $10.
       LBSPEC $40. LBMETHOD $40. VISIT $40. ;
       
set raw.lb;

/* VARIABLES FROM RAW LB DATASETS */
STUDYID = "&STUDYID";
DOMAIN ="LB";
SUBJID = SUBJECT;

/* Category Variable */
select (LBTESTCD);
    when ("SODIUM", "K", "CREAT", "GLUC",
          "ALT", "AST", "BUN", "ALBUMIN", "BILIRUBIN")
        LBCAT = "CHEMISTRY";

    when ("HGB", "HCT", "WBC", "RBC", "PLT", "MCV", "MCH", "MCHC")
        LBCAT = "HEMATOLOGY";

    when ("PROTEIN", "GLUCOSE_URINE", "PH", "SPGRAV")
        LBCAT = "URINALYSIS";

    when ("PT", "APTT", "INR")
        LBCAT = "COAGULATION";

    otherwise LBCAT = "OTHER";
end;

/* Standard Result or Findings Variable */
LBSTRESC = strip(LBORRES);
LBSTRESN = LBORRES;
LBSTRESU = LBORRESU;

if missing(LBORRES) then do;
    LBORRESU = "";
    LBSTAT = "NOT DONE";
end;
else do;
    LBSTAT = "";
end;

/* Specimen, Method, and Test Number — test-level constants */
select (LBTESTCD);

    /* CHEMISTRY (SERUM) */
    when ("SODIUM") do;
        LBSPEC   = "SERUM";
        LBMETHOD = "ION-SELECTIVE ELECTRODE";
        LBTPTNUM = 1;
    end;

    when ("K") do;
        LBSPEC   = "SERUM";
        LBMETHOD = "ION-SELECTIVE ELECTRODE";
        LBTPTNUM = 2;
    end;

    when ("CREAT") do;
        LBSPEC   = "SERUM";
        LBMETHOD = "ENZYMATIC";
        LBTPTNUM = 3;
    end;

    when ("GLUC") do;
        LBSPEC   = "SERUM";
        LBMETHOD = "HEXOKINASE";
        LBTPTNUM = 4;
    end;

    when ("ALT") do;
        LBSPEC   = "SERUM";
        LBMETHOD = "ENZYMATIC";
        LBTPTNUM = 5;
    end;

    when ("AST") do;
        LBSPEC   = "SERUM";
        LBMETHOD = "ENZYMATIC";
        LBTPTNUM = 6;
    end;

    when ("BUN") do;
        LBSPEC   = "SERUM";
        LBMETHOD = "UREASE";
        LBTPTNUM = 7;
    end;

    when ("ALBUMIN") do;
        LBSPEC   = "SERUM";
        LBMETHOD = "BCG";
        LBTPTNUM = 8;
    end;

    when ("BILIRUBIN") do;
        LBSPEC   = "SERUM";
        LBMETHOD = "COLORIMETRIC";
        LBTPTNUM = 9;
    end;

    /* HEMATOLOGY (WHOLE BLOOD) */
    when ("HGB", "HCT", "WBC", "RBC", "PLT", "MCV", "MCH", "MCHC") do;
        LBSPEC   = "WHOLE BLOOD";
        LBMETHOD = "AUTOMATED COUNT";
        LBTPTNUM = 1;      /* restarts within its own panel */
    end;

    /* URINALYSIS */
    when ("PROTEIN", "GLUCOSE_URINE", "PH", "SPGRAV") do;
        LBSPEC   = "URINE";
        LBMETHOD = "DIPSTICK";
        LBTPTNUM = 1;
    end;

    /* COAGULATION (PLASMA) */
    when ("PT")   do; LBSPEC="PLASMA"; LBMETHOD="COAGULOMETRY"; LBTPTNUM=1; end;
    when ("APTT") do; LBSPEC="PLASMA"; LBMETHOD="COAGULOMETRY"; LBTPTNUM=2; end;
    when ("INR")  do; LBSPEC="PLASMA"; LBMETHOD="COAGULOMETRY"; LBTPTNUM=3; end;

    otherwise do;
        LBSPEC   = "SERUM";
        LBMETHOD = "UNKNOWN";
        LBTPTNUM = 99;
    end;
end;

keep STUDYID DOMAIN SUBJID LBTESTCD LBTEST LBCAT LBORRES LBORRESU
     LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBSTAT LBSPEC 
     LBMETHOD VISITNUM VISIT LBDTC LBTPTNUM;
run;

/* Study Day Variable and USUBJID */

/* Step 1: Sort raw LB */
proc sort data=LB1;
    by STUDYID SUBJID;
run;

/* Step 2: Prepare subject identifiers and RFSTDTC from DM */
proc sort data=sdtm.dm
          (keep=STUDYID SUBJID USUBJID RFSTDTC)
          out=DM1;
    by STUDYID SUBJID;
run;

/* Step 3: Merge DM identifiers and reference start date into LB */
data LB2;
    merge LB1(in=a)
          DM1(in=b);
    by STUDYID SUBJID;

    if a;

    length EPOCH $40;
    format LBDT RFSTDT yymmdd10.;

    /* Convert collection date */
    if not missing(LBDTC) then
        LBDT = input(substr(strip(LBDTC),1,10), yymmdd10.);

    /* Convert reference start date */
    if not missing(RFSTDTC) then
        RFSTDT = input(substr(strip(RFSTDTC),1,10), yymmdd10.);

    /* Derive study day */
    if not missing(LBDT) and not missing(RFSTDT) then do;
        if LBDT >= RFSTDT then
            LBDY = LBDT - RFSTDT + 1;
        else
            LBDY = LBDT - RFSTDT;
    end;
    else call missing(LBDY);

    /* Illustrative epoch derivation */
    if not missing(LBDT) and not missing(RFSTDT) then do;
        if LBDT < RFSTDT then
            EPOCH = "SCREENING";
        else
            EPOCH = "TREATMENT";
    end;
    else call missing(EPOCH);

    drop LBDT RFSTDT RFSTDTC;
run;

/* Sequence Variable */
data final;
set LB2;

if first.USUBJID then LBSEQ = 1;
else LBSEQ + 1;
run;

/* Final Dataset */
data sdtm.lb (LABEL= "Laboratory") ;

retain STUDYID DOMAIN USUBJID LBSEQ LBTESTCD LBTEST LBCAT LBORRES
       LBORRESU LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBSTAT 
       LBSPEC LBMETHOD VISITNUM VISIT EPOCH LBDTC LBDY LBTPTNUM;
       
       set final;
       
       label STUDYID  = "Study Identifier"
             DOMAIN   = "Domain Abbreviation"
             USUBJID  = "Unique Subject Identifier"
             LBSEQ    = "Sequence Number"
             LBTESTCD = "Lab Test or Examination Short Name"
             LBTEST   = "Lab Test or Examination Name"
             LBCAT    = "Category for Lab Test"
             LBORRES  = "Result or Finding in Original Units"
             LBORRESU = "Original Units"
             LBSTRESC = "Character Result/Finding in Std Format"
             LBSTRESN = "Numeric Result/Finding in Standard Units"
             LBSTRESU = "Standard Units"
             LBSTNRLO = "Reference Range Lower Limit-Std Units"
             LBSTNRHI = "Reference Range Upper Limit-Std Units"
             LBSTAT   = "Completion Status"
             LBSPEC   = "Specimen Type"
             LBMETHOD = "Method of Test or Examination"
             VISITNUM = "Visit Number"
             VISIT    = "Visit Name"
             EPOCH    = "Epoch"
             LBDTC    = "Date/Time of Specimen Collection"
             LBDY     = "Study Day of Specimen Collection"
             LBTPTNUM = "Planned Time Point Number"
         ;
             
keep STUDYID DOMAIN USUBJID LBSEQ LBTESTCD LBTEST LBCAT LBORRES
     LBORRESU LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBSTAT
     LBSPEC LBMETHOD VISITNUM VISIT EPOCH LBDTC LBDY LBTPTNUM;
       
run;