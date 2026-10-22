/* Export DM */
libname xptdm xport "/home/u64305129/Project/HTN101/Pinnacle 21/dm.xpt";

data xptdm.dm;
    set sdtm.dm;
run;

libname xptdm clear;


/* Export AE */
libname xptae xport "/home/u64305129/Project/HTN101/Pinnacle 21/ae.xpt";

data xptae.ae;
    set sdtm.ae;
run;

libname xptae clear;


/* Export EX */
libname xptex xport "/home/u64305129/Project/HTN101/Pinnacle 21/ex.xpt";

data xptex.ex;
    set sdtm.ex;
run;

libname xptex clear;


/* Export VS */
libname xptvs xport "/home/u64305129/Project/HTN101/Pinnacle 21/vs.xpt";

data xptvs.vs;
    set sdtm.vs;
run;

libname xptvs clear;


/* Export LB */
libname xptlb xport "/home/u64305129/Project/HTN101/Pinnacle 21/lb.xpt";

data xptlb.lb;
    set sdtm.lb;
run;

libname xptlb clear;

/* Export TS */
libname xptts xport "/home/u64305129/Project/HTN101/Pinnacle 21/ts.xpt";

data xptts.dm;
    set sdtm.ts;
run;

libname xptts clear;