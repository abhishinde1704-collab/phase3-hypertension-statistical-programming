/*==========================================================
Program: VS.sas
Domain : Vital Sign (VS)
Study  : HTN101-301
==========================================================*/

data VS1;
length STUDYID $12. DOMAIN $2. SUBJID $10. USUBJID $20. VSTESTCD $8. VSTEST $40.
       VSCAT $20. VSPOS $20. VSORRES $20. VSORRESU $15. VSSTRESC $20. 
       VSSTRESU $15. VSSTAT $10. VSBLFL $1. VISIT $31.;
set raw.vs(rename=(VSORRES=_VSORRES_NUM));

/* VARIABLES FROM RAW VS DATASETS */
STUDYID = "&STUDYID";
DOMAIN  = "VS" ;
SUBJID  = SUBJECT;

/* Category Variable */
If VSTEST in ("HEIGHT","WEIGHT","BMI") then VSCAT="BODY MEASUREMENTS";
else VSCAT = "VITAL SIGNS";

/* Result/Finding Variables */
if not missing(_VSORRES_NUM) then do;
    VSORRES   = strip(put(_VSORRES_NUM, best12.));
    VSSTRESC  = strip(VSORRES);
    VSSTRESN  = _VSORRES_NUM;
    VSSTRESU  = VSORRESU;
    VSSTAT    = "";
end;
else do;
    VSORRES   = "";
    VSORRESU  = "";
    VSSTRESC  = "";        
    VSSTRESN  = .;
    VSSTRESU  = "";
    VSSTAT    = "NOT DONE";
    
end;
drop _VSORRES_NUM;    

/* Standard Units */
VSSTRESU = VSORRESU;

/* Completion Status */
if missing(VSORRES) then do;
    VSORRESU = "";
    VSSTAT = "NOT DONE";
end;
else do;
    VSSTAT = "";
end;

/* Baseline Flag */
if VISITNUM = 2 and not missing(VSORRES) and VSORRES ne "" then
    VSBLFL = "Y";
else
    VSBLFL = "";

/* Date/Time Variable */
VSDTC = VSDTC ;

/* Position of Subject */
if VSTESTCD in ("SYSBP", "DIABP") then VSPOS = "SITTING";

keep STUDYID DOMAIN SUBJID VSTESTCD VSTEST VSCAT VSORRES VSORRESU
     VSSTRESC VSSTRESN VSSTRESU VSBLFL VISITNUM VISIT VSDTC VSPOS 
     VSSTAT;
run;

/* Study Day Variable*/

proc sort data=VS1 out=VS_SORT;
    by STUDYID SUBJID;
run;

proc sort data=sdtm.dm
    (keep=STUDYID SUBJID USUBJID RFSTDTC)
    out=DM_SORT;
    by STUDYID SUBJID;
run;

data VS_ID;
    merge VS_SORT(in=a)
          DM_SORT(in=b);
    by STUDYID SUBJID;

    if a;

run;

data DM_DATE;
    set DM_SORT;

    format RFSTDT yymmdd10.;

    if not missing(RFSTDTC) then
    RFSTDT = input(substr(strip(RFSTDTC), 1, 10),yymmdd10.);

    keep USUBJID RFSTDT;
run;

proc sort data=DM_DATE;
    by USUBJID;
run;

proc sort data=VS_ID;
    by USUBJID;
run;

data VS2;
    merge VS_ID(in=a)
          DM_DATE(in=b);
    by USUBJID;

    if a;

    length EPOCH $40;
    format VSDT yymmdd10.;

    /* Convert VS collection date */
    if not missing(VSDTC) then
        VSDT = input(
            substr(strip(VSDTC), 1, 10),
            yymmdd10.
        );

    /* Derive study day */
    if not missing(VSDT) and not missing(RFSTDT) then do;
        if VSDT >= RFSTDT then
            VSDY = VSDT - RFSTDT + 1;
        else
            VSDY = VSDT - RFSTDT;
    end;
    else call missing(VSDY);

    /* Illustrative epoch derivation */
    if not missing(VSDT) and not missing(RFSTDT) then do;
        if VSDT < RFSTDT then
            EPOCH = "SCREENING";
        else
            EPOCH = "TREATMENT";
    end;
    else call missing(EPOCH);

    drop VSDT RFSTDT;
run;


/* Sequence Variable */
data final;
set VS2;
by USUBJID;

if first.USUBJID then VSSEQ = 1;
else VSSEQ +1;
run;

/* Final Dataset */
data sdtm.vs (label="Vital Sign");
     retain STUDYID DOMAIN USUBJID VSSEQ VSTESTCD VSTEST VSCAT 
     VSPOS VSORRES VSORRESU VSSTRESC VSSTRESN VSSTRESU VSSTAT 
     VSBLFL VISITNUM VISIT EPOCH VSDTC VSDY;
     
    set final;
    
    label
       STUDYID  = "Study Identifier"
       DOMAIN   = "Domain Abbreviation"
       USUBJID  = "Unique Subject Identifier"
       VSSEQ    = "Sequence Number"
       VSTESTCD = "Vital Signs Test Short Name"
       VSTEST   = "Vital Signs Test Name"
       VSCAT    = "Category for Vital Signs"
       VSPOS    = "Vital Signs Position of Subject"
       VSORRES  = "Result or Finding in Original Units"
       VSORRESU = "Original Units"
       VSSTRESC = "Character Result/Finding in Std Format"
       VSSTRESN = "Numeric Result/Finding in Standard Units"
       VSSTRESU = "Standard Units"
       VSSTAT   = "Completion Status"
       VSBLFL   = "Baseline Flag"
       VISITNUM = "Visit Number"
       VISIT    = "Visit Name"
       EPOCH    = "Epoch"
       VSDTC    = "Date/Time of Measurements"
       VSDY     = "Study Day of Vital Signs"       
       ;
keep STUDYID DOMAIN USUBJID VSSEQ VSTESTCD VSTEST VSCAT 
     VSPOS VSORRES VSORRESU VSSTRESC VSSTRESN VSSTRESU VSSTAT 
     VSBLFL VISITNUM VISIT EPOCH VSDTC VSDY;
run;   