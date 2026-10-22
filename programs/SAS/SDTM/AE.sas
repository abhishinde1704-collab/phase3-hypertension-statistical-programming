/*==========================================================
Program: AE.sas
Domain : Adverse Event (AE)
Study  : HTN101-301
==========================================================*/

/*==========================================================
  Preparing DM to get SITEID
==========================================================*/
proc sort data=sdtm.dm (keep=SUBJID SITEID) out=dm_site; 
    by SUBJID; 
run;

proc sort data=raw.ae out=ae_sorted; 
    by SUBJECT; 
run;

data AE1;
Length STUDYID $12. DOMAIN $2. USUBJID $20. SUBJID $10. AETERM $200. AEDECOD $200.
       AEBODSYS $84. AESEV $10. AEREL $40. AEACN $30. AEOUT $30. AEENRF $20.;
       
    merge ae_sorted (in=a rename=(SUBJECT=SUBJID)) 
          dm_site (in=b);
    by SUBJID;
    if a;

/* VARIABLES FROM RAW AE DATASETS */
STUDYID = "&STUDYID";
DOMAIN  = "AE";
USUBJID = catx("-",STUDYID,SITEID,SUBJID);

/* Dictionary-derived Term */
AEDECOD = upcase(AETERM);

/* Body System or Organ class */
AEBODSYS = "GENERAL DISORDER";

/* Serious Event */
AESER   = substr(upcase(strip(AESER)),1,1);
AESDTH  = substr(upcase(strip(AESDTH)),1,1);
AESLIFE = substr(upcase(strip(AESLIFE)),1,1);
AESHOSP = substr(upcase(strip(AESHOSP)),1,1);
AESDISAB= substr(upcase(strip(AESDISAB)),1,1);
AESCONG = substr(upcase(strip(AESCONG)),1,1);
AESMIE  = substr(upcase(strip(AESMIE)),1,1);

if AEOUT = "FATAL" then AESDTH = "Y";

/* Consistency rule */
if AESER = "Y" and AESDTH="N" and AESLIFE="N" and AESHOSP="N"
   and AESDISAB="N" and AESCONG="N" and AESMIE="N" then do;
    AESHOSP = "Y";   /* default to hospitalization */
end;

/* Action Taken */
if not missing(AEACN) then AEACN = upcase(AEACN);
else AEACN = "DOSE NOT CHANGED";

/* AE Outcome */
if not missing(AEOUT) then AEOUT = upcase(AEOUT);
else AEOUT = "RECOVERED/RESOLVED";

/* If AEOUT says NOT RECOVERED, blank AEENDTC */
if AEOUT = "NOT RECOVERED/NOT RESOLVED" then do;
    AEENDTC = "";
    AEENRF  = "ONGOING";
end;

/* If AEOUT says RECOVERED but no end date, set to UNKNOWN */
if AEOUT in ("RECOVERED/RESOLVED")
   and missing(AEENDTC) then do;
    AEOUT = "UNKNOWN";
end;

/* End Relative to Reference Period */
if missing(AEENDTC) THEN AEENRF = "ONGOING";
else AEENRF = "";

KEEP STUDYID DOMAIN USUBJID SUBJID AETERM AEDECOD AEBODSYS AESTDTC   
     AEENDTC AESEV AESER AESDTH AESLIFE AESHOSP
     AESDISAB AESCONG AESMIE AEREL AEACN AEOUT AEENRF;

RUN;

/* Study Day Variable*/
proc sort data=AE1;by USUBJID;run;

/* Extracting Datepart from Dm dates */
Data dm1;
SET sdtm.dm;
RFSTDT = INPUT(SUBSTR(RFSTDTC,1,10),YYMMDD10.);
RFXSTDT = INPUT(SUBSTR(RFXSTDTC,1,10),YYMMDD10.);
RFXENDT = INPUT(SUBSTR(RFXENDTC,1,10),YYMMDD10.);
keep USUBJID RFSTDT RFXSTDT RFXENDT;
RUN;

proc sort data=dm1;by USUBJID;run;

/* EPOCH */
Data AE2;
merge AE1(in=a) DM1(in=b);
by USUBJID;
if a;

length EPOCH $20.;
if missing(AESTDTC) then EPOCH = "";
else if AESTDTC < RFXSTDTC then EPOCH = "SCREENING";
else if AESTDTC <= RFXENDTC then EPOCH = "TREATMENT";
else EPOCH = "FOLLOW-UP";

/* AESTDY & AEENDY */
/* Converting ISO dates to Numeric */
if not missing(AESTDTC) then AESTDT=input(AESTDTC,yymmdd10.);
if not missing(AEENDTC) then AEENDT=input(AEENDTC,yymmdd10.);

format AESTDT AEENDT yymmdd10;

/* Study Start Day (AESTDY) */
if not missing(AESTDT) and not missing(RFSTDT) then do;
if AESTDT >= RFSTDT then AESTDY = AESTDT - RFSTDT + 1;
else AESTDY =  AESTDT - RFSTDT;
end;

/* Study End Day (AEENDY) */
if not missing(AEENDT) and not missing (RFSTDT) then do;
if AEENDT >= RFSTDT then AEENDY = AEENDT - RFSTDT + 1;
else AEENDY = AEENDT - RFSTDT;
end;

drop AESTDT AEENDT RFSTDT RFXSTDT RFXENDT;
run;

/* Sequence Variable */
proc sort data=AE2;by USUBJID;run;

data final;
set AE2;
by USUBJID;

if first.USUBJID then AESEQ = 1;
else AESEQ + 1;

run;

/* Final Dataset */
data sdtm.AE (label="Adverse Event");

retain STUDYID DOMAIN USUBJID AESEQ AETERM AEDECOD AEBODSYS EPOCH
       AESTDTC AEENDTC AESTDY AEENDY AESEV AESER AEREL AEACN AEOUT 
       AESDTH AESLIFE AESHOSP AESDISAB AESCONG AESMIE AEENRF;
       
       set final;
       
       label STUDYID  = "Study Identifier"
             DOMAIN   = "Domain Abbreviation"
             USUBJID  = "Unique Subject Identifier"
             AESEQ    = "Sequence Number"
             AETERM   = "Reported Term for the Adverse Event"
             AEDECOD  = "Dictionary-Derived Term"
             AEBODSYS = "Body System or Organ Class"
             EPOCH    = "Epoch"
             AESTDTC  = "Start Date/Time of Adverse Event"
             AEENDTC  = "End Date/Time of Adverse Event"
             AESTDY   = "Study Day of Start of Adverse Event"
             AEENDY   = "Study Day of End of Adverse Event"
             AESEV    = "Severity/Intensity"
             AESER    = "Serious Event"
             AEACN    = "Action Taken with Study Treatment"
             AEREL    = "Causality"
             AEOUT    = "Outcome of Adverse Event"
             AESDTH   = "Results in Death"
             AESLIFE  = "Life Threatening"
             AESHOSP  = "Requires or Prolongs Hospitalization"
             AESDISAB = "Persist or Signif Disability/Incapacity"
             AESCONG  = "Congenital Anomaly or Birth Defect"
             AESMIE   = "Other Medically Important Serious Event"
             AEENRF   = "End Relative to Reference Period"
        ;

keep  STUDYID DOMAIN USUBJID AESEQ AETERM AEDECOD AEBODSYS EPOCH
      AESTDTC AEENDTC AESTDY AEENDY AESEV AESER AEREL AEACN AEOUT 
      AESDTH AESLIFE AESHOSP AESDISAB AESCONG AESMIE AEENRF;

run;