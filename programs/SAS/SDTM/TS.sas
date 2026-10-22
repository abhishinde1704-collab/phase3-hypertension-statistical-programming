
/*==========================================================
  Study  : HTN101-301
  Domain : TS - Trial Summary
  Purpose: Create the SDTM TS dataset
 ==========================================================*/

data TS1;
length  STUDYID  $12. DOMAIN $2. TSPARMCD $8. TSPARM $30. TSVAL $178. TSVALNF $20.
        TSVALCD $20. TSVDTC $20. TSVCDREF $20. TSVCDVER $20.;

    /* Study-level identifiers */
    STUDYID = "HTN101-301";
    DOMAIN  = "TS";

    /* Parameter: planned number of subjects */
    TSPARMCD = "PLANSUB";
    TSPARM   = "Planned Number of Subjects";
    TSVAL    = "100";
    output;

    /* Parameter: study phase */
    TSPARMCD = "PHASE";
    TSPARM   = "Trial Phase";
    TSVAL    = "Phase III";
    output;

    /* Parameter: indication */
    TSPARMCD = "INDIC";
    TSPARM   = "Trial Indication";
    TSVAL    = "Hypertension";
    output;

    /* Parameter: planned treatment */
    TSPARMCD = "TRT";
    TSPARM   = "Planned Treatment";
    TSVAL    = "HTN-101 50 mg";
    output;

    TSPARMCD = "TRT";
    TSPARM   = "Planned Treatment";
    TSVAL    = "Placebo";
    output;

    /* Parameter: planned study duration */
    TSPARMCD = "DUR";
    TSPARM   = "Planned Trial Duration";
    TSVAL    = "12 Weeks";
    output;

    /* Parameter: allocation */
    TSPARMCD = "RANDOM";
    TSPARM   = "Trial Type";
    TSVAL    = "Randomized";
    output;

    /* Parameter: blinding */
    TSPARMCD = "BLIND";
    TSPARM   = "Trial Blinding Schema";
    TSVAL    = "Double-Blind";
    output;

    /* Sequence number */
    TSSEQ = _N_;
    

    /*--- Study Start Date ---*/
    TSPARMCD = "SSTDTC";
    TSPARM   = "Study Start Date";
    TSVAL    = "2024-01-15";
    output;

    /*--- Study End Date ---*/
    TSPARMCD = "SENDTC";
    TSPARM   = "Study End Date";
    TSVAL    = "2024-06-30";
    output;

    /*--- Sex of Participants ---*/
    TSPARMCD = "SEX";
    TSPARM   = "Sex of Participants";
    TSVAL    = "BOTH";
    output;

    keep STUDYID DOMAIN TSSEQ TSPARMCD TSPARM TSVAL
         TSVALNF TSVALCD TSVDTC TSVCDREF TSVCDVER
         TSPARMCD TSPARM TSVAL;
run;

/* Creating the final dataset */
data SDTM.TS  (label="Trial Summary");

retain STUDYID DOMAIN TSSEQ TSPARMCD TSPARM TSVAL
       TSVALNF TSVALCD TSVDTC TSVCDREF TSVCDVER
       TSPARMCD TSPARM TSVAL;
       
       set TS1;
       
label STUDYID  = "Study Identifier"
	  DOMAIN   = "Domain Abbreviation" 
	  TSSEQ    = "Sequence Number"
	  TSPARMCD = "Trial Summary Parameter Short Name"
	  TSPARM   = "Trial Summary Parameter"
	  TSVAL    = "Parameter Value"
	  TSVALNF  = "Parameter Null Flavor"
	  TSVALCD  = "Parameter Value Code"
	  TSVDTC   = "Date/Time of Value"
	  TSVCDREF = "Name of Reference Terminology"
	  TSVCDVER = "Version of Reference Terminology"
	  TSPARMCD = "Trial Summary Parameter Short Name"
	  TSPARM   = "Trial Summary Parameter Name"
	  TSVAL    = "Trial Summary Value"
	  ;

keep  STUDYID DOMAIN TSSEQ TSPARMCD TSPARM TSVAL
      TSVALNF TSVALCD TSVDTC TSVCDREF TSVCDVER
      TSPARMCD TSPARM TSVAL;

run;