/*==========================================================
  Program : 00_setup.sas
  Study   : HTN101-301
  Purpose : Project setup — options, libraries, folders
  Author  : Abhijeet Shinde
==========================================================*/

/*----------------------------------------------------------
  1. Global SAS options
----------------------------------------------------------*/
options
    linesize   = 200
    pagesize   = 500
    nodate
    nonumber
    validvarname = v7
    mprint
;

/*----------------------------------------------------------
  2. Study information
----------------------------------------------------------*/
%let STUDYID = HTN101-301;

/*----------------------------------------------------------
  3. Project root
----------------------------------------------------------*/
%let ROOT = /home/u64305129/Project/HTN101;

/*----------------------------------------------------------
  4. library folders 
----------------------------------------------------------*/
options dlcreatedir;
libname RAW  "&ROOT/data/raw";
libname SDTM "&ROOT/data/sdtm";
libname ADAM "&ROOT/data/adam";
libname OUT  "&ROOT/output";
options nodlcreatedir;

/*----------------------------------------------------------
  5. Output folder paths
----------------------------------------------------------*/
%let TABLEDIR = &ROOT/output/tables;
%let LISTDIR  = &ROOT/output/listings;
%let FIGDIR   = &ROOT/output/figures;

/* Create output folders */
options dlcreatedir;
libname _T1 "&TABLEDIR";
libname _T2 "&LISTDIR";
libname _T3 "&FIGDIR";
options nodlcreatedir;

/*----------------------------------------------------------
  6. Print setup confirmation in the log
----------------------------------------------------------*/
%put NOTE: ============================================;
%put NOTE: Study ID  : &STUDYID;
%put NOTE: Root      : &ROOT;
%put NOTE: SDTM lib  : &ROOT/data/sdtm;
%put NOTE: ADaM lib  : &ROOT/data/adam;
%put NOTE: QC lib    : &ROOT/validation/QC;
%put NOTE: Tables    : &TABLEDIR;
%put NOTE: Listings  : &LISTDIR;
%put NOTE: Figures   : &FIGDIR;
%put NOTE: ============================================;
