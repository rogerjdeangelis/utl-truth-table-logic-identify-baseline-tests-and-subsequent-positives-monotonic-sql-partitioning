%let pgm=utl-truth-table-logic-identify-baseline-tests-and-subsequent-positives-monotonic-sql-partitioning;

%stop_submission;

Truth table logic identify baseline tests and subsequent positives monotonic sql partitioning


IMPLEMENT THIS PROGRAM THIS LOGIC

 LOGIC                                      STATE                  TRUTH

 first.patient       and test='P'  THEN  BASELINE POSITIVE           11
 first.patient       and test='N'  THEN  BASELINE NEGATIVE           10
 not (first.patient) and test='P'  THEN  SUBSEQUENT POSITIVE         01
 not (first.patient) and test='N'  THEN  SUBSEQUENT NEGATIVES        00

github
https://tinyurl.com/epmvk7kw
https://github.com/rogerjdeangelis/utl-truth-table-logic-identify-baseline-tests-and-subsequent-positives-monotonic-sql-partitioning

https://tinyurl.com/24xj52bs
https://github.com/rogerjdeangelis/utl-using-a-bolean-truth-table-for-complex-filtering-in-sql-sas-r-and-pythom-multi-language

related to
https://communities.sas.com/t5/SAS-Programming/Incidence-of-a-new-event-in-SAS-table/m-p/848750#M335555


   CONTENTS

      1 sas datastep
      2 sas sqlpartition monotonic
      3 sas sql without monotonic
      4 r sql
      5 python sql
      6 excel sql
      7 related repos


SOAPBOX ON

    Perhaps is is a good idea to have a primary key, like _n_, for proc sql, especially
    when there is no other primary single ot compound primary key

    In SQL, the ROW_NUMBER() function is widely used in modern relational databases
    to assign a unique sequential integer to each row in a result set.
    This function is particularly useful for ranking rows,
    implementing pagination, removing duplicates, and generating unique identifiers.

    Most modern databases like SQLlite, SQL Server, PostgreSQL, MySQL, and Oracle support this function.

    While SAS's PROC SQL does not natively support _N_, alternatives like the monotonic()
    function or using views with _N_ can mimic row numbering, though they may have limitations


    SQL's ROW_NUMBER() is more robust and optimized for tasks like ranking and pagination
    across large datasets.
   It supports grouping via PARTITION BY, allowing row numbering within specific categories.

   While SAS's PROC SQL does not natively support _N_, alternatives like the
   monotonic() function or using views with _N_ can mimic row
   numbering, though they may have limitations

SOAPBOX OFF


/*               _     _
 _ __  _ __ ___ | |__ | | ___ _ __ ___
| `_ \| `__/ _ \| `_ \| |/ _ \ `_ ` _ \
| |_) | | | (_) | |_) | |  __/ | | | | |
| .__/|_|  \___/|_.__/|_|\___|_| |_| |_|
|_|
*/

/**************************************************************************************************************************/
/*       INPUT               |             PROCESS                            |             OUTPUT                        */
/*       =====               |             =======                            |             ======                        */
/*                           |                                                |                                           */
/*  PATIENT     TEST    DOSE | 1 SAS DATASTEP                                 |                                I          */
/*                           | ==============                                 |    S                           N          */
/*  Patient1     N      1mg  |                                                |    E       P                   C          */
/*  Patient1     P      3mg  | data want;                                     |    Q       A                   I          */
/*  Patient1     P      6mg  |   retain seq seqbypat 0 patient test dose;     |    B       T                   D          */
/*  Patient1     N      6mg  |   set sd1.have;                                |    Y       I     T  D          E          */
/*  Patient1     P      9mg  |   by patient;                                  |  S P       E     E  O          N          */
/*  Patient1     N      9mg  |   seq=_n_;                                     |  E A       N     S  S          C          */
/*  Patient1     P      5mg  |   seqBypat=ifn(first.patient,1,seqByPat+1);    |  Q T       T     T  E          E          */
/*  Patient2     P      3mg  |   select;                                      |                                           */
/*  Patient2     P      3mg  |    when (first.patient       and test='P'  )   |  1 1    Patient1 N 1mg BASELINE NEGATIVE  */
/*  Patient2     N      3mg  |      incidence='BASELINE POSITIVE ';           |  2 2    Patient1 P 3mg SECONDARY POSITIVE */
/*  Patient2     N      9mg  |    when (first.patient       and test='N'  )   |  3 3    Patient1 P 6mg SECONDARY POSITIVE */
/*  Patient2     P      2mg  |      incidence='BASELINE NEGATIVE ';           |  4 4    Patient1 N 6mg SECONDARY NEGATIVE */
/*                           |    when (not (first.patient) and test='P'  )   |  5 5    Patient1 P 9mg SECONDARY POSITIVE */
/*                           |      incidence='SECONDARY POSITIVE';           |  6 6    Patient1 N 9mg SECONDARY NEGATIVE */
/* options                   |    when (not (first.patient) and test='N'  )   |  7 7    Patient1 P 5mg SECONDARY POSITIVE */
/*   validvarname=upcase;    |      incidence='SECONDARY NEGATIVE';           |                                           */
/* libname sd1 "d:/sd1";     |   end; /*---- LEAVE OFF FORCE ERROR ----*/     |  8 1    Patient2 P 3mg BASELINE POSITIVE  */
/* data sd1.have;            | run;quit;                                      |  9 2    Patient2 P 3mg SECONDARY POSITIVE */
/*  informat patient $8.     |                                                | 10 3    Patient2 N 3mg SECONDARY NEGATIVE */
/*  test $1. dose $3.;       |                                                | 11 4    Patient2 N 9mg SECONDARY NEGATIVE */
/*  input patient            |                                                | 12 5    Patient2 P 2mg SECONDARY POSITIVE */
/*    test dose;             |                                                |                                           */
/* datalines;                | -----------------------------------------------|-------------------------------------------*/
/* Patient1 N 1mg            |                                                |                                           */
/* Patient1 P 3mg            | 2 SAS SQLPARTITION WITH MONOTONIC              | SEQ PATIENT TEST DOSE     INCIDENCE       */
/* Patient1 P 6mg            | =================================              |                                           */
/* Patient1 N 6mg            |                                                |  1 Patient1 N   1mg  BASELINE NEGATIVE    */
/* Patient1 P 9mg            | proc sql;                                      |  2 Patient1 P   3mg  SECONDARY POSITIVE   */
/* Patient1 N 9mg            |  create                                        |  3 Patient1 P   6mg  SECONDARY POSITIVE   */
/* Patient1 P 5mg            |    table sqlsas as                             |  4 Patient1 N   6mg  SECONDARY NEGATIVE   */
/* Patient2 P 3mg            |  select                                        |  5 Patient1 P   9mg  SECONDARY POSITIVE   */
/* Patient2 P 3mg            |    partition                                   |  6 Patient1 N   9mg  SECONDARY NEGATIVE   */
/* Patient2 N 3mg            |   ,patient                                     |  7 Patient1 P   5mg  SECONDARY POSITIVE   */
/* Patient2 N 9mg            |   ,test                                        |                                           */
/* Patient2 P 2mg            |   ,dose                                        |  1 Patient2 P   3mg  BASELINE POSITIVE    */
/* ;;;;                      |   ,case                                        |  2 Patient2 P   3mg  SECONDARY POSITIVE   */
/* run;quit;                 |     when partition=1 and      test="P"         |  3 Patient2 N   3mg  SECONDARY NEGATIVE   */
/*                           |        then "BASELINE POSITIVE "               |  4 Patient2 N   9mg  SECONDARY NEGATIVE   */
/*                           |     when partition=1 and      test="N"         |  5 Patient2 P   2mg  SECONDARY POSITIVE   */
/*                           |        then "BASELINE NEGATIVE "               |                                           */
/*                           |     when not(partition=1) and test="P"         |                                           */
/*                           |        then "SECONDARY POSITIVE"               |                                           */
/*                           |     when not(partition=1) and test="N"         |                                           */
/*                           |        then "SECONDARY NEGATIVE"               |                                           */
/*                           |     else "ERROR"                               |                                           */
/*                           |   end as incidence                             |                                           */
/*                           |  from                                          |                                           */
/*                           |   %sqlpartitionx(sd1.have,by=patient)          |                                           */
/*                           | ;quit;                                         |                                           */
/*                           |                                                |                                           */
/*                           | -----------------------------------------------|-------------------------------------------*/
/*                           |                                                |                                           */
/*                           | 2 SAS SQL WITHOUT MONOTONIC                    |                 P            I            */
/*                           | ===========================                    |                 A  S         N            */
/*                           |                                                |    P            R  E         C            */
/*                           | %let seq=0;                                    |    A            T  Q         I            */
/*                           | proc sql;                                      |    T            I  B         D            */
/*                           |  create                                        |    I     T   D  T  Y         E            */
/*                           |    table seq(drop=t) as                        |    E     E   O  I  P         N            */
/*                           |  select                                        |    N     S   S  O  A         C            */
/*                           |    resolve('%let seq=%eval(&seq+1);') as t     |    T     T   E  N  T         E            */
/*                           |   ,input(symget('seq'),8.) as partition        |                                           */
/*                           |   ,patient                                     | Patient1 N  1mg 1  1 BASELINE NEGATIVE    */
/*                           |   ,test                                        | Patient1 P  3mg 2  2 SECONDARY POSITIVE   */
/*                           |   ,dose                                        | Patient1 P  6mg 3  3 SECONDARY POSITIVE   */
/*                           |  from                                          | Patient1 N  6mg 4  4 SECONDARY NEGATIVE   */
/*                           |   sd1.have                                     | Patient1 P  9mg 5  5 SECONDARY POSITIVE   */
/*                           | ;quit;                                         | Patient1 N  9mg 6  6 SECONDARY NEGATIVE   */
/*                           |                                                | Patient1 P  5mg 7  7 SECONDARY POSITIVE   */
/*                           | proc sql;                                      | Patient2 P  3mg 8  1 BASELINE POSITIVE    */
/*                           |  create                                        | Patient2 P  3mg 9  2 SECONDARY POSITIVE   */
/*                           |   table pat1st as                              | Patient2 N  3mg 10 3 SECONDARY NEGATIVE   */
/*                           |  select                                        | Patient2 N  9mg 11 4 SECONDARY NEGATIVE   */
/*                           |   patient                                      | Patient2 P  2mg 12 5 SECONDARY POSITIVE   */
/*                           |  ,test                                         |                                           */
/*                           |  ,dose                                         |                                           */
/*                           |  ,partition                                    |                                           */
/*                           |  ,partition-min(partition)+1 as seqbypat       |                                           */
/*                           |  ,case                                         |                                           */
/*                           |    when calculated seqbypat=1                  |                                           */
/*                           |      and test="P" then "BASELINE POSITIVE "    |                                           */
/*                           |    when calculated seqbypat=1                  |                                           */
/*                           |      and test="N" then "BASELINE NEGATIVE "    |                                           */
/*                           |    when not(calculated seqbypat=1)             |                                           */
/*                           |      and test="P" then "SECONDARY POSITIVE"    |                                           */
/*                           |    when not(calculated seqbypat=1)             |                                           */
/*                           |      and test="N" then "SECONDARY NEGATIVE"    |                                           */
/*                           |    else "ERROR"                                |                                           */
/*                           |   end as incidence                             |                                           */
/*                           |  from                                          |                                           */
/*                           |     seq                                        |                                           */
/*                           |  group                                         |                                           */
/*                           |     by patient                                 |                                           */
/*                           |  order                                         |                                           */
/*                           |     by partition                               |                                           */
/*                           | ;quit;                                         |                                           */
/*                           |                                                |                                           */
/*                           | -----------------------------------------------|-------------------------------------------*/  
/*                           |                                                |                                           */
/*                           | 4  SQL R PYTHON EXCEL (SAME SQL CODE)          | Seq PATIENT TEST DOSE          incidence  */
/*                           |    HERE IS THE R SQLLITE SOLUTION              |                                           */
/*                           | =====================================          |  1 Patient1    N  1mg BASELINE NEGATIVE   */
/*                           |                                                |  2 Patient1    P  3mg SECONDARY POSITIVE  */
/*                           | %utl_rbeginx;                                  |  3 Patient1    P  6mg SECONDARY POSITIVE  */
/*                           | parmcards4;                                    |  4 Patient1    N  6mg SECONDARY NEGATIVE  */
/*                           | library(haven)                                 |  5 Patient1    P  9mg SECONDARY POSITIVE  */
/*                           | library(sqldf)                                 |  6 Patient1    N  9mg SECONDARY NEGATIVE  */
/*                           | source("c:/oto/fn_tosas9x.R")                  |  7 Patient1    P  5mg SECONDARY POSITIVE  */
/*                           | have<-read_sas("d:/sd1/have.sas7bdat")         |                                           */
/*                           | want<-sqldf('                                  |  1 Patient2    P  3mg BASELINE POSITIVE   */
/*                           |  select                                        |  2 Patient2    P  3mg SECONDARY POSITIVE  */
/*                           |   partition                                    |  3 Patient2    N  3mg SECONDARY NEGATIVE  */
/*                           |  ,patient                                      |  4 Patient2    N  9mg SECONDARY NEGATIVE  */
/*                           |  ,test                                         |  5 Patient2    P  2mg SECONDARY POSITIVE  */
/*                           |  ,dose                                         |                                           */
/*                           |  ,case                                         |                                           */
/*                           |    when partition=1 and      test="P"          |                                           */
/*                           |     then "BASELINE POSITIVE "                  |                                           */
/*                           |    when partition=1 and      test="N"          |                                           */
/*                           |     then "BASELINE NEGATIVE "                  |                                           */
/*                           |    when not(partition=1) and test="P"          |                                           */
/*                           |     then "SECONDARY POSITIVE"                  |                                           */
/*                           |    when not(partition=1) and test="N"          |                                           */
/*                           |     then "SECONDARY NEGATIVE"                  |                                           */
/*                           |    else "ERROR"                                |                                           */
/*                           |   end as incidence                             |                                           */
/*                           | from                                           |                                           */
/*                           |   (select *, row_number()                      |                                           */
/*                           |      over (partition by patient)               |                                           */
/*                           |         as partition from have)                |                                           */
/*                           | ')                                             |                                           */
/*                           | want                                           |                                           */
/*                           | fn_tosas9x(                                    |                                           */
/*                           |       inp    = want                            |                                           */
/*                           |      ,outlib ="d:/sd1/"                        |                                           */
/*                           |      ,outdsn ="want"                           |                                           */
/*                           |      )                                         |                                           */
/*                           | ;;;;                                           |                                           */
/*                           | %utl_rendx;                                    |                                           */
/**************************************************************************************************************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

 options
   validvarname=upcase;
 libname sd1 "d:/sd1";
 data sd1.have;
  informat patient $8.
  test $1. dose $3.;
  input patient
    test dose;
 datalines;
 Patient1 N 1mg
 Patient1 P 3mg
 Patient1 P 6mg
 Patient1 N 6mg
 Patient1 P 9mg
 Patient1 N 9mg
 Patient1 P 5mg
 Patient2 P 3mg
 Patient2 P 3mg
 Patient2 N 3mg
 Patient2 N 9mg
 Patient2 P 2mg
 ;;;;
 run;quit;


/**************************************************************************************************************************/
/* PATIENT     TEST    DOSE                                                                                               */
/*                                                                                                                        */
/* Patient1     N      1mg                                                                                                */
/* Patient1     P      3mg                                                                                                */
/* Patient1     P      6mg                                                                                                */
/* Patient1     N      6mg                                                                                                */
/* Patient1     P      9mg                                                                                                */
/* Patient1     N      9mg                                                                                                */
/* Patient1     P      5mg                                                                                                */
/* Patient2     P      3mg                                                                                                */
/* Patient2     P      3mg                                                                                                */
/* Patient2     N      3mg                                                                                                */
/* Patient2     N      9mg                                                                                                */
/* Patient2     P      2mg                                                                                                */
/**************************************************************************************************************************/

/*                       _       _            _
/ |  ___  __ _ ___    __| | __ _| |_ __ _ ___| |_ ___ _ __
| | / __|/ _` / __|  / _` |/ _` | __/ _` / __| __/ _ \ `_ \
| | \__ \ (_| \__ \ | (_| | (_| | || (_| \__ \ ||  __/ |_) |
|_| |___/\__,_|___/  \__,_|\__,_|\__\__,_|___/\__\___| .__/
                                                     |_|
*/

data want;
  retain seq seqbypat 0 patient test dose;
  set sd1.have;
  by patient;
  seq=_n_;
  seqBypat=ifn(first.patient,1,seqByPat+1);
  select;
   when (first.patient       and test='P'  )
     incidence='BASELINE POSITIVE ';
   when (first.patient       and test='N'  )
     incidence='BASELINE NEGATIVE ';
   when (not (first.patient) and test='P'  )
     incidence='SECONDARY POSITIVE';
   when (not (first.patient) and test='N'  )
     incidence='SECONDARY NEGATIVE';
  end; /*---- LEAVE OFF FORCE ERROR ----*/
run;quit;


/**************************************************************************************************************************/
/* SEQ    SEQBYPAT    PATIENT     TEST    DOSE        INCIDENCE                                                           */
/*                                                                                                                        */
/*   1        1       Patient1     N      1mg     BASELINE NEGATIVE                                                       */
/*   2        2       Patient1     P      3mg     SECONDARY POSITIVE                                                      */
/*   3        3       Patient1     P      6mg     SECONDARY POSITIVE                                                      */
/*   4        4       Patient1     N      6mg     SECONDARY NEGATIVE                                                      */
/*   5        5       Patient1     P      9mg     SECONDARY POSITIVE                                                      */
/*   6        6       Patient1     N      9mg     SECONDARY NEGATIVE                                                      */
/*   7        7       Patient1     P      5mg     SECONDARY POSITIVE                                                      */
/*                                                                                                                        */
/*   8        1       Patient2     P      3mg     BASELINE POSITIVE                                                       */
/*   9        2       Patient2     P      3mg     SECONDARY POSITIVE                                                      */
/*  10        3       Patient2     N      3mg     SECONDARY NEGATIVE                                                      */
/*  11        4       Patient2     N      9mg     SECONDARY NEGATIVE                                                      */
/*  12        5       Patient2     P      2mg     SECONDARY POSITIVE                                                      */
/**************************************************************************************************************************/

/*___                              _                  _   _ _   _                                          _              _
|___ \   ___  __ _ ___   ___  __ _| |_ __   __ _ _ __| |_(_) |_(_) ___  _ __   _ __ ___   ___  _ __   ___ | |_ ___  _ __ (_) ___
  __) | / __|/ _` / __| / __|/ _` | | `_ \ / _` | `__| __| | __| |/ _ \| `_ \ | `_ ` _ \ / _ \| `_ \ / _ \| __/ _ \| `_ \| |/ __|
 / __/  \__ \ (_| \__ \ \__ \ (_| | | |_) | (_| | |  | |_| | |_| | (_) | | | || | | | | | (_) | | | | (_) | || (_) | | | | | (__
|_____| |___/\__,_|___/ |___/\__, |_| .__/ \__,_|_|   \__|_|\__|_|\___/|_| |_||_| |_| |_|\___/|_| |_|\___/ \__\___/|_| |_|_|\___|
                                |_| |_|
*/

proc sql;
 create
   table sqlsas as
 select
   partition
  ,patient
  ,test
  ,dose
  ,case
    when partition=1 and      test="P"
       then "BASELINE POSITIVE "
    when partition=1 and      test="N"
       then "BASELINE NEGATIVE "
    when not(partition=1) and test="P"
       then "SECONDARY POSITIVE"
    when not(partition=1) and test="N"
       then "SECONDARY NEGATIVE"
    else "ERROR"
  end as incidence
 from
  %sqlpartitionx(sd1.have,by=patient)
;quit;

/**************************************************************************************************************************/
/* PARTITION    PATIENT     TEST    DOSE        INCIDENCE                                                                 */
/*                                                                                                                        */
/*     1        Patient1     N      1mg     BASELINE NEGATIVE                                                             */
/*     2        Patient1     P      3mg     SECONDARY POSITIVE                                                            */
/*     3        Patient1     P      6mg     SECONDARY POSITIVE                                                            */
/*     4        Patient1     N      6mg     SECONDARY NEGATIVE                                                            */
/*     5        Patient1     P      9mg     SECONDARY POSITIVE                                                            */
/*     6        Patient1     N      9mg     SECONDARY NEGATIVE                                                            */
/*     7        Patient1     P      5mg     SECONDARY POSITIVE                                                            */
/*                                                                                                                        */
/*     1        Patient2     P      3mg     BASELINE POSITIVE                                                             */
/*     2        Patient2     P      3mg     SECONDARY POSITIVE                                                            */
/*     3        Patient2     N      3mg     SECONDARY NEGATIVE                                                            */
/*     4        Patient2     N      9mg     SECONDARY NEGATIVE                                                            */
/*     5        Patient2     P      2mg     SECONDARY POSITIVE                                                            */
/**************************************************************************************************************************/

/*____                             _            _ _   _                 _                                _              _
|___ /   ___  __ _ ___   ___  __ _| | __      _(_) |_| |__   ___  _   _| |_  _ __ ___   ___  _ __   ___ | |_ ___  _ __ (_) ___
  |_ \  / __|/ _` / __| / __|/ _` | | \ \ /\ / / | __| `_ \ / _ \| | | | __|| `_ ` _ \ / _ \| `_ \ / _ \| __/ _ \| `_ \| |/ __|
 ___) | \__ \ (_| \__ \ \__ \ (_| | |  \ V  V /| | |_| | | | (_) | |_| | |_ | | | | | | (_) | | | | (_) | || (_) | | | | | (__
|____/  |___/\__,_|___/ |___/\__, |_|   \_/\_/ |_|\__|_| |_|\___/ \__,_|\__||_| |_| |_|\___/|_| |_|\___/ \__\___/|_| |_|_|\___|
                                |_|
*/

%let seq=0;
proc sql;
 create
   table seq(drop=t) as
 select
   resolve('%let seq=%eval(&seq+1);') as t
  ,input(symget('seq'),8.) as partition
  ,patient
  ,test
  ,dose
 from
  sd1.have
;quit;

proc sql;
 create
  table pat1st as
 select
  patient
 ,test
 ,dose
 ,partition
 ,partition-min(partition)+1 as seqbypat
 ,case
   when calculated seqbypat=1
     and test="P" then "BASELINE POSITIVE "
   when calculated seqbypat=1
     and test="N" then "BASELINE NEGATIVE "
   when not(calculated seqbypat=1)
     and test="P" then "SECONDARY POSITIVE"
   when not(calculated seqbypat=1)
     and test="N" then "SECONDARY NEGATIVE"
   else "ERROR"
  end as incidence
 from
    seq
 group
    by patient
 order
    by partition
;quit;

/**************************************************************************************************************************/
/*  PATIENT     TEST    DOSE    PARTITION    SEQBYPAT        INCIDENCE                                                    */
/*                                                                                                                        */
/*  Patient1     N      1mg          1           1       BASELINE NEGATIVE                                                */
/*  Patient1     P      3mg          2           2       SECONDARY POSITIVE                                               */
/*  Patient1     P      6mg          3           3       SECONDARY POSITIVE                                               */
/*  Patient1     N      6mg          4           4       SECONDARY NEGATIVE                                               */
/*  Patient1     P      9mg          5           5       SECONDARY POSITIVE                                               */
/*  Patient1     N      9mg          6           6       SECONDARY NEGATIVE                                               */
/*  Patient1     P      5mg          7           7       SECONDARY POSITIVE                                               */
/*                                                                                                                        */
/*  Patient2     P      3mg          8           1       BASELINE POSITIVE                                                */
/*  Patient2     P      3mg          9           2       SECONDARY POSITIVE                                               */
/*  Patient2     N      3mg         10           3       SECONDARY NEGATIVE                                               */
/*  Patient2     N      9mg         11           4       SECONDARY NEGATIVE                                               */
/*  Patient2     P      2mg         12           5       SECONDARY POSITIVE                                               */
/**************************************************************************************************************************/

/*  _                      _
| || |    _ __   ___  __ _| |
| || |_  | `__| / __|/ _` | |
|__   _| | |    \__ \ (_| | |
   |_|   |_|    |___/\__, |_|
                        |_|
*/

libname sd1 "d:/sd1";

%utl_rbeginx;
parmcards4;
library(haven)
library(sqldf)
source("c:/oto/fn_tosas9x.R")
have<-read_sas("d:/sd1/have.sas7bdat")
want<-sqldf('
 select
  partition
 ,patient
 ,test
 ,dose
 ,case
   when partition=1 and      test="P"
    then "BASELINE POSITIVE "
   when partition=1 and      test="N"
    then "BASELINE NEGATIVE "
   when not(partition=1) and test="P"
    then "SECONDARY POSITIVE"
   when not(partition=1) and test="N"
    then "SECONDARY NEGATIVE"
   else "ERROR"
  end as incidence
from
  (select *, row_number()
     over (partition by patient)
        as partition from have)
')
want
fn_tosas9x(
      inp    = want
     ,outlib ="d:/sd1/"
     ,outdsn ="want"
     )
;;;;
%utl_rendx;

proc print data=sd1.want /*heading=vertical*/;
run;quit;

/**************************************************************************************************************************/
/* R                                               |  SAS                                                                 */
/* partition  PATIENT TEST DOSE          INCIDENCE |  ROWNAMES PARTITION    PATIENT  TEST    DOSE        INCIDENCE        */
/*                                                 |                                                                      */
/*         1 Patient1    N  1mg BASELINE NEGATIVE  |      1        1        Patient1  N      1mg     BASELINE NEGATIVE    */
/*         2 Patient1    P  3mg SECONDARY POSITIVE |      2        2        Patient1  P      3mg     SECONDARY POSITIVE   */
/*         3 Patient1    P  6mg SECONDARY POSITIVE |      3        3        Patient1  P      6mg     SECONDARY POSITIVE   */
/*         4 Patient1    N  6mg SECONDARY NEGATIVE |      4        4        Patient1  N      6mg     SECONDARY NEGATIVE   */
/*         5 Patient1    P  9mg SECONDARY POSITIVE |      5        5        Patient1  P      9mg     SECONDARY POSITIVE   */
/*         6 Patient1    N  9mg SECONDARY NEGATIVE |      6        6        Patient1  N      9mg     SECONDARY NEGATIVE   */
/*         7 Patient1    P  5mg SECONDARY POSITIVE |      7        7        Patient1  P      5mg     SECONDARY POSITIVE   */
/*                                                 |                                                                      */
/*         1 Patient2    P  3mg BASELINE POSITIVE  |      8        1        Patient2  P      3mg     BASELINE POSITIVE    */
/*         2 Patient2    P  3mg SECONDARY POSITIVE |     19        2        Patient2  P      3mg     SECONDARY POSITIVE   */
/*         3 Patient2    N  3mg SECONDARY NEGATIVE |     10        3        Patient2  N      3mg     SECONDARY NEGATIVE   */
/*         4 Patient2    N  9mg SECONDARY NEGATIVE |     11        4        Patient2  N      9mg     SECONDARY NEGATIVE   */
/*         5 Patient2    P  2mg SECONDARY POSITIVE |      2        5        Patient2  P      2mg     SECONDARY POSITIVE   */
/**************************************************************************************************************************/

/*___                _   _                             _
| ___|   _ __  _   _| |_| |__   ___  _ __    ___  __ _| |
|___ \  | `_ \| | | | __| `_ \ / _ \| `_ \  / __|/ _` | |
 ___) | | |_) | |_| | |_| | | | (_) | | | | \__ \ (_| | |
|____/  | .__/ \__, |\__|_| |_|\___/|_| |_| |___/\__, |_|
        |_|    |___/                                |_|
*/

proc datasets lib=sd1 nolist nodetails;
 delete pywant;
run;quit;

%utl_pybeginx;
parmcards4;
exec(open('c:/oto/fn_python.py').read());
have,meta = ps.read_sas7bdat('d:/sd1/have.sas7bdat');
want=pdsql('''
 select                                \
  partition                            \
 ,patient                              \
 ,test                                 \
 ,dose                                 \
 ,case                                 \
   when partition=1 and      test="P"  \
    then "BASELINE POSITIVE "          \
   when partition=1 and      test="N"  \
    then "BASELINE NEGATIVE "          \
   when not(partition=1) and test="P"  \
    then "SECONDARY POSITIVE"          \
   when not(partition=1) and test="N"  \
    then "SECONDARY NEGATIVE"          \
   else "ERROR"                        \
  end as incidence                     \
from                                   \
  (select *, row_number()              \
     over (partition by patient)       \
        as partition from have)
   ''');
print(want);
fn_tosas9x(want,outlib='d:/sd1/',outdsn='pywant',timeest=3);
;;;;
%utl_pyendx;

proc print data=sd1.pywant;
run;quit;

/**************************************************************************************************************************/
/* PYTHON                                                 | SAS                                                           */
/*     partition   PATIENT TEST DOSE           INCIDENCE  | PARTITION    PATIENT     TEST    DOSE        INCIDENCE        */
/*                                                        |                                                               */
/* 0           1  Patient1    N  1mg  BASELINE NEGATIVE   |     1        Patient1     N      1mg     BASELINE NEGATIVE    */
/* 1           2  Patient1    P  3mg  SECONDARY POSITIVE  |     2        Patient1     P      3mg     SECONDARY POSITIVE   */
/* 2           3  Patient1    P  6mg  SECONDARY POSITIVE  |     3        Patient1     P      6mg     SECONDARY POSITIVE   */
/* 3           4  Patient1    N  6mg  SECONDARY NEGATIVE  |     4        Patient1     N      6mg     SECONDARY NEGATIVE   */
/* 4           5  Patient1    P  9mg  SECONDARY POSITIVE  |     5        Patient1     P      9mg     SECONDARY POSITIVE   */
/* 5           6  Patient1    N  9mg  SECONDARY NEGATIVE  |     6        Patient1     N      9mg     SECONDARY NEGATIVE   */
/* 6           7  Patient1    P  5mg  SECONDARY POSITIVE  |     7        Patient1     P      5mg     SECONDARY POSITIVE   */
/*                                                        |                                                               */
/* 7           1  Patient2    P  3mg  BASELINE POSITIVE   |     1        Patient2     P      3mg     BASELINE POSITIVE    */
/* 8           2  Patient2    P  3mg  SECONDARY POSITIVE  |     2        Patient2     P      3mg     SECONDARY POSITIVE   */
/* 9           3  Patient2    N  3mg  SECONDARY NEGATIVE  |     3        Patient2     N      3mg     SECONDARY NEGATIVE   */
/* 10          4  Patient2    N  9mg  SECONDARY NEGATIVE  |     4        Patient2     N      9mg     SECONDARY NEGATIVE   */
/* 11          5  Patient2    P  2mg  SECONDARY POSITIVE  |     5        Patient2     P      2mg     SECONDARY POSITIVE   */
/**************************************************************************************************************************/

/*__                       _             _
 / /_     _____  _____ ___| |  ___  __ _| |
| `_ \   / _ \ \/ / __/ _ \ | / __|/ _` | |
| (_) | |  __/>  < (_|  __/ | \__ \ (_| | |
 \___/   \___/_/\_\___\___|_| |___/\__, |_|
                                      |_|
*/

%utlfkil(d:/xls/wantxl.xlsx);

%utl_rbeginx;
parmcards4;
library(openxlsx)
library(sqldf)
library(haven)
have<-read_sas("d:/sd1/have.sas7bdat")
wb <- createWorkbook()
addWorksheet(wb, "have")
writeData(wb, sheet = "have", x = have)
saveWorkbook(
    wb
   ,"d:/xls/wantxl.xlsx"
   ,overwrite=TRUE)
;;;;
%utl_rendx;

%utl_rbeginx;
parmcards4;
library(openxlsx)
library(sqldf)
source("c:/oto/fn_tosas9x.R")
 wb<-loadWorkbook("d:/xls/wantxl.xlsx")
 have<-read.xlsx(wb,"have")
 addWorksheet(wb, "want")
 want<-sqldf('
 select
  partition
 ,patient
 ,test
 ,dose
 ,case
   when partition=1 and      test="P"
    then "BASELINE POSITIVE "
   when partition=1 and      test="N"
    then "BASELINE NEGATIVE "
   when not(partition=1) and test="P"
    then "SECONDARY POSITIVE"
   when not(partition=1) and test="N"
    then "SECONDARY NEGATIVE"
   else "ERROR"
  end as incidence
from
  (select *, row_number()
     over (partition by patient)
        as partition from have)
  ')
 print(want)
 writeData(wb,sheet="want",x=want)
 saveWorkbook(
     wb
    ,"d:/xls/wantxl.xlsx"
    ,overwrite=TRUE)
fn_tosas9x(
      inp    = want
     ,outlib ="d:/sd1/"
     ,outdsn ="want"
     )
;;;;
%utl_rendx;

proc print data=sd1.want;
run;quit;


/**************************************************************************************************************************/
/* EXCEL                                           |  SAS                                                                 */
/* partition  PATIENT TEST DOSE          INCIDENCE |  ROWNAMES PARTITION    PATIENT  TEST    DOSE        INCIDENCE        */
/*                                                 |                                                                      */
/*         1 Patient1    N  1mg BASELINE NEGATIVE  |      1        1        Patient1  N      1mg     BASELINE NEGATIVE    */
/*         2 Patient1    P  3mg SECONDARY POSITIVE |      2        2        Patient1  P      3mg     SECONDARY POSITIVE   */
/*         3 Patient1    P  6mg SECONDARY POSITIVE |      3        3        Patient1  P      6mg     SECONDARY POSITIVE   */
/*         4 Patient1    N  6mg SECONDARY NEGATIVE |      4        4        Patient1  N      6mg     SECONDARY NEGATIVE   */
/*         5 Patient1    P  9mg SECONDARY POSITIVE |      5        5        Patient1  P      9mg     SECONDARY POSITIVE   */
/*         6 Patient1    N  9mg SECONDARY NEGATIVE |      6        6        Patient1  N      9mg     SECONDARY NEGATIVE   */
/*         7 Patient1    P  5mg SECONDARY POSITIVE |      7        7        Patient1  P      5mg     SECONDARY POSITIVE   */
/*                                                 |                                                                      */
/*         1 Patient2    P  3mg BASELINE POSITIVE  |      8        1        Patient2  P      3mg     BASELINE POSITIVE    */
/*         2 Patient2    P  3mg SECONDARY POSITIVE |     19        2        Patient2  P      3mg     SECONDARY POSITIVE   */
/*         3 Patient2    N  3mg SECONDARY NEGATIVE |     10        3        Patient2  N      3mg     SECONDARY NEGATIVE   */
/*         4 Patient2    N  9mg SECONDARY NEGATIVE |     11        4        Patient2  N      9mg     SECONDARY NEGATIVE   */
/*         5 Patient2    P  2mg SECONDARY POSITIVE |      2        5        Patient2  P      2mg     SECONDARY POSITIVE   */
/**************************************************************************************************************************/

/*____            _       _           _
|___  |  _ __ ___| | __ _| |_ ___  __| |  _ __ ___ _ __   ___  ___
   / /  | `__/ _ \ |/ _` | __/ _ \/ _` | | `__/ _ \ `_ \ / _ \/ __|
  / /   | | |  __/ | (_| | ||  __/ (_| | | | |  __/ |_) | (_) \__ \
 /_/    |_|  \___|_|\__,_|\__\___|\__,_| |_|  \___| .__/ \___/|___/
                                                  |_|
*/
https://github.com/rogerjdeangelis/utl-add-sequence-numbers-to-a-sas-table-with-and-without-sas-monotonic
https://github.com/rogerjdeangelis/utl-adding-sequence-numbers-and-partitions-in-SAS-sql-without-using-monotonic
https://github.com/rogerjdeangelis/utl-lags-in-proc-sql-monotonic-datastep-is-preferred
https://github.com/rogerjdeangelis/utl-sas-keep-only-monotonic-increasing-sequences-by-group

https://github.com/rogerjdeangelis/utl-adding-sequence-numbers-and-partitions-in-SAS-sql-without-using-monotonic
https://github.com/rogerjdeangelis/utl-create-equally-spaced-values-using-partitioning-in-sql-wps-r-python
https://github.com/rogerjdeangelis/utl-create-primary-key-for-duplicated-records-using-sql-partitionaling-and-pivot-wide-sas-python-r
https://github.com/rogerjdeangelis/utl-find-first-n-observations-per-category-using-proc-sql-partitioning
https://github.com/rogerjdeangelis/utl-flag-second-duplicate-using-base-sas-and-sql-sas-python-and-r-partitioning-multi-language
https://github.com/rogerjdeangelis/utl-incrementing-by-one-for-each-new-group-of-records-sas-r-python-sql-partitioning
https://github.com/rogerjdeangelis/utl-macro-to-enable-sql-partitioning-by-groups-montonic-first-and-last-dot
https://github.com/rogerjdeangelis/utl-maintaining-the-orginal-order-while-partitioning-groups-using-sql-partitioning
https://github.com/rogerjdeangelis/utl-pivot-long-pivot-wide-transpose-partitioning-sql-arrays-wps-r-python
https://github.com/rogerjdeangelis/utl-pivot-transpose-by-id-using-wps-r-python-sql-using-partitioning
https://github.com/rogerjdeangelis/utl-sql-partitioning-increase-in-investment-when-interest-rates-change-over-time-compound-interest
https://github.com/rogerjdeangelis/utl-top-four-seasonal-precipitation-totals--european-cities-sql-partitions-in-wps-r-python
https://github.com/rogerjdeangelis/utl-transpose-pivot-wide-using-sql-partitioning-in-wps-r-python
https://github.com/rogerjdeangelis/utl-transposing-rows-to-columns-using-proc-sql-partitioning
https://github.com/rogerjdeangelis/utl-transposing-words-into-sentences-using-sql-partitioning-in-r-and-python
https://github.com/rogerjdeangelis/utl-using-DOW-loops-to-identify-different-groups-and-partition-data
https://github.com/rogerjdeangelis/utl-using-sql-in-wps-r-python-select-the-four-youngest-male-and-female-students-partitioning

/*___              _ _ _ _                       _                _        _   _     _   _
 ( _ )   ___  __ _| | (_) |_ ___    ___  _ __ __| | ___ _ __  ___| |_ __ _| |_(_)___| |_(_) ___ ___
 / _ \  / __|/ _` | | | | __/ _ \  / _ \| `__/ _` |/ _ \ `__|/ __| __/ _` | __| / __| __| |/ __/ __|
| (_) | \__ \ (_| | | | | ||  __/ | (_) | | | (_| |  __/ |   \__ \ || (_| | |_| \__ \ |_| | (__\__ \
 \___/  |___/\__, |_|_|_|\__\___|  \___/|_|  \__,_|\___|_|   |___/\__\__,_|\__|_|___/\__|_|\___|___/
                |_|
*/

 GROUP_CONCAT(name,',')  combines rows base on group by  John,Alice,Mike
                         pne observation per department
 PARTITION (seq within group as one example, very useful)
 ROW_NUMBER()
 RANK()
 DENSE_RANK()
 PERCENT_RANK()
 CUME_DIST()
 NTILE(N)
 LAG(expr)
 LEAD(expr)
 FIRST_VALUE(expr)
 LAST_VALUE(expr)
 NTH_VALUE(expr, N)


/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
