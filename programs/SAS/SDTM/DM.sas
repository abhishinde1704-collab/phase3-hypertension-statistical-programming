/*==========================================================
Program: Dm.sas
Domain : Demographics (DM)
Study  : HTN101-301
==========================================================*/

data DM1;
length STUDYID $12. DOMAIN $2. USUBJID $20. SUBJID $10. SITEID $10.
       BRTHDTC $10. AGEU $6. SEX $1. RACE $40. ETHNIC $40. ;
set raw.demographics;

/* VARIABLES FROM RAW DM DATASET */
  STUDYID = "&STUDYID";
  DOMAIN  = "DM";
  SUBJID  = SUBJECT;
  USUBJID = catx("-",STUDYID,SITEID,SUBJID);
  BRTHDTC = PUT(BIRTH_DATE,IS8601DA.); 
  AGEU    = "YEARS";
  SEX     = Upcase(Substr(Gender,1,1));
  ETHNIC  = ETHNICITY;

/* RACE */
  if index(RACE,"/") then
     RACE="MULTIPLE";
  Else
    RACE=UPCASE(RACE);
    
  if missing(RACE) or RACE = "" then
    RACE = "OTHER";
run;


/* Sorting the Data to get the data in Ascending Sequence */
proc sort data=raw.ex out=EX1;
by SUBJECT DOSE_DTM;
run;

/* First & Last exposure of Treatment */
data EX2;
set EX1;
by SUBJECT;
length RFSTDTC $19. RFXSTDTC $19. RFENDTC $19. RFXENDTC $19.
       ACTARM $20. ACTARMCD $8.;
retain RFSTDTC RFXSTDTC ACTARM ACTARMCD;
SUBJID = SUBJECT;

/* First Exposure */
if first.SUBJECT then do;

   RFSTDTC =DOSE_DTM;
   RFXSTDTC = RFSTDTC;
   
/* Actual Treatment based on first exposure */
  select(upcase(strip(TREATMENT)));

   when("HTN-101")do;
     ACTARMCD="HTN101";
     ACTARM  ="HTN-101 50 mg";
   end;

   when("PLACEBO")do;
     ACTARMCD="PBO";
     ACTARM  ="Placebo";
   end;

   otherwise do;
      ACTARMCD = "";
      ACTARM   = "";
   end;
  end;
end;

/* Last Exposure */
IF last.SUBJECT then do;

   RFENDTC=DOSE_DTM;
   RFXENDTC=RFENDTC;
   output;
end;

keep SUBJID RFSTDTC RFXSTDTC RFENDTC RFXENDTC ACTARM ACTARMCD;
run;

/* ARM & ARMCD */
data RNDM;
set raw.randomization;
length SUBJID $10. ARM $20. ARMCD $8.;
SUBJID=SUBJECT;

select(upcase(strip(RAND_GROUP)));

 when("HTN-101")do;
     ARMCD="HTN101";
     ARM  ="HTN-101 50 mg";
 end;

 when("PLACEBO")do;
     ARMCD="PBO";
     ARM  ="Placebo";
 end;

 otherwise do;
      ARMCD = "";
      ARM   = "";
 end;
end;

keep SUBJID ARM ARMCD;
run;

/* Sorting the Datasets */
proc sort data=DM1;
    by SUBJID;
run;

proc sort data=EX2;
    by SUBJID;
run;
 
proc sort data=RNDM;
    by SUBJID;
run;


/* Merging Raw DATASETS */
data final;
merge DM1 EX2 RNDM;
by SUBJID;
run;

/* Creating the final dataset */
data SDTM.DM  (label="Demographics");

retain STUDYID DOMAIN USUBJID SUBJID RFSTDTC RFENDTC RFXSTDTC 
       RFXENDTC SITEID BRTHDTC AGE AGEU SEX RACE ETHNIC COUNTRY 
       ARMCD ARM ACTARMCD ACTARM;
       
       set final;
       
label STUDYID  = "Study Identifier"
	  DOMAIN   = "Domain Abbreviation" 
	  USUBJID  = "Unique Subject Identifier"
	  SUBJID   = "Subject Identifier for the Study"
	  RFSTDTC  = "Subject Reference Start Date/Time"
	  RFENDTC  = "Subject Reference End Date/Time" 
	  RFXSTDTC = "Date/Time of First Study Treatment"
	  RFXENDTC = "Date/Time of Last Study Treatment"
	  SITEID   = "Study Site Identifier"
	  BRTHDTC  = "Date/Time of Birth"
	  AGE      = "Age"
	  AGEU     = "Age Units"
	  SEX      = "Sex"
	  RACE     = "Race" 
	  ETHNIC   = "Ethnicity"
	  COUNTRY  = "Country"
	  ARMCD    = "Planned Arm Code"
	  ARM      = "Description of Planned Arm"
	  ACTARMCD = "Actual Arm Code"
	  ACTARM   = "Description of Actual Arm";

keep  STUDYID DOMAIN USUBJID SUBJID RFSTDTC RFENDTC RFXSTDTC 
      RFXENDTC SITEID BRTHDTC AGE AGEU SEX RACE ETHNIC COUNTRY 
      ARMCD ARM ACTARMCD ACTARM;

run;