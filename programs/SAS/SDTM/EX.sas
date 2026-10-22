/*==========================================================
Program: EX.sas
Domain : Exposure (EX)
Study  : HTN101-301
==========================================================*/

/* Preparing DM to get SITEID for USUBJID */
proc sort data=sdtm.dm (keep=SUBJID SITEID RFSTDTC) out=dm1; 
    by SUBJID; 
run;

/* Preparing EX1 */
proc sort data=raw.ex out=ex_sorted;
    by SUBJECT DOSE_DTM;
run;

data EX1;
length STUDYID $12. DOMAIN $2. SUBJID $10. USUBJID $20. EXTRT $20. 
       EXDOSU $10. EXDOSFRM $20. EXDOSFRQ $20. EXROUTE $20. 
       EPOCH $20. EXSTDTC $19. EXENDTC $19.;
       
set ex_sorted(rename=(SUBJECT=SUBJID));
       
/* Variables From raw EX dataset */
STUDYID = "&STUDYID";
DOMAIN = "EX";

/* Treatment Details */
EXTRT=TREATMENT;
EXDOSE=DOSE;
EXDOSU=DOSE_UNIT;
EXDOSFRM="TABLET";
EXDOSFRQ="QD";
EXROUTE="ORAL";
EPOCH = "TREATMENT";

/* Start & End data/time of treatment */
EXSTDTC = DOSE_DTM;
EXENDTC = EXSTDTC;

run;

/* Study day varibale and USUBJID*/

data EX2;
merge EX1(in=A) DM1(in=B);
by SUBJID;
if A ;

/* Unique Subject Identifier */
USUBJID = CATX("-",STUDYID,SITEID,SUBJID);

    RFSTDT = input(RFSTDTC, is8601da.);
    EXSTDT = input(EXSTDTC, is8601da.);
    EXENDT = input(EXENDTC, is8601da.);

/* STUDY START DAY */
if EXSTDT ge RFSTDT then EXSTDY = EXSTDT - RFSTDT + 1;
else EXSTDY = EXSTDT - RFSTDT;

/* STUDY END DAY */
if EXENDT ge RFSTDT then EXENDY = EXENDT - RFSTDT + 1;
else EXENDY = EXENDT - RFSTDT;

drop EXSTDT EXENDT RFSTDT RFSTDTC ;
run;

/* SEQUENCE VARIABLE */
proc sort data=EX2;
by USUBJID EXSTDTC;
run;

data Final;
set EX2;
by USUBJID EXSTDTC;

if first.USUBJID then EXSEQ = 1;
else EXSEQ + 1;
run;


/* FINAL DATASET */

data sdtm.EX (label='EXPOSURE');
    
retain STUDYID DOMAIN USUBJID EXSEQ EXTRT
       EXDOSE EXDOSU EXDOSFRM EXDOSFRQ EXROUTE
       EPOCH EXSTDTC EXENDTC EXSTDY EXENDY ;

    set final;

    label
        STUDYID  = "Study Identifier"
        DOMAIN   = "Domain Abbreviation"
        USUBJID  = "Unique Subject Identifier"
        EXSEQ    = "Sequence Number"
        EXTRT    = "Name of Treatment"
        EXDOSE   = "Dose"
        EXDOSU   = "Dose Units"
        EXDOSFRM = "Dose Form" 
        EXDOSFRQ = "Dosing Frequency per Interval"
        EXROUTE  = "Route of Administration"
        EPOCH    = "Epoch"
        EXSTDTC  = "Start Date/Time of Treatment"
        EXENDTC  = "End Date/Time of Treatment"
        EXSTDY   = "Study Day of Start of Treatment"
        EXENDY   = "Study Day of End of Treatment"
    ;

    keep STUDYID DOMAIN USUBJID EXSEQ EXTRT
         EXDOSE EXDOSU EXDOSFRM EXDOSFRQ EXROUTE
         EPOCH EXSTDTC EXENDTC EXSTDY EXENDY ;
run;

