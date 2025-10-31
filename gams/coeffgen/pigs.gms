********************************************************************************
$ontext

   FARMDYN project

   GAMS file : PIGS.GMS

   @purpose  :
   @author   :
   @date     : 02.07.13
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************
*
* --- The production cycle of the fattners is partitioned into 4 months to account for different feeding patterns and excretion values over time.
*     Hence, the production of fattners/finishing pigs take 4 months with 3 production cycles each year.
*
$iftheni.fattners "%farmBranchFattners%"=="on"

 p_prodLength("pigletsBought","")  = 1;
 p_prodLength("earlyfattners","")  = 1;
 p_prodLength("midfattners","")    = 1;
 p_prodLength("latefattners","")   = 1;
 p_prodLength("fattners","")       = 1;

$endif.fattners


$iftheni.sows     "%farmBranchSows%"=="on"
*
* --- The production cycle of sows/piglets is organized in a way that the sows have an average output of piglets each year and the young piglets are
*     transferred to raising piglets after a months and piglets sold after 2 months
*
 p_prodLength("sows","")           = round(12 * p_lifeTimeSow);
 p_prodLength("youngSows","")      = 1;
 p_prodLength("oldSows","")        = 1;
 p_prodLength("slgtSows","")       = 1;
 p_prodLength("piglets","")        = 2 ;
 p_prodLength("youngPiglets","")   = 1;

$endif.sows
