$ontext
********************************************************************************

   FARMDYN project

   GAMS file : REQU.GMS

   @purpose  : Define requirements of different animals, maximal/minimum
               bounds for feed input coefficients and auxiliary params like DAYS
   @author   : W. Britz, I.Perez, P Witzke, F Weiss
   @date     : 22.04.10
   @since    : 1999
   @refDoc   :
   @calledBy :

$offtext
********************************************************************************
* ----------------------------------------------------------------------------------------
*
*  PART I:  Requirement functions
*
*           Define requirements per head of each animal category
*           for energy, protein etc. according to SPEL definitions
*
*           i.e. for PORK and POUL per slaughtered head, period =
*                fattening period
*
*                otherwise per year (but internally less days may be
*                calculated)
*
*  The following requirements are calculated:
*
*
*  EN..  are different energy measurement used for the animals.
*  CRPR  is crude protein
*  LISI  is lysine aminoacid.
*  NDF   is neutral detergent fiber
*  DRMA  is dry matter.
*  DRMN  is minimum dry matter.
*  DMMX  is maximum dry matter.
*  FICO  is max intake dairy and suckler cows
*  FICT  is max intake growing and fattening bovines
*  FISF  is max intake sheep
*  FISM  is max intake goat
*
* ----------------------------------------------------------------------------------------
*
$iftheni.cattle %cattle% == true
parameter
  p_startWgt(herds,breeds)
  p_finalWgt(herds,breeds)
  p_reqsTot(*,feedAttr)                               "Total requirements, given per year for cows and for total production length for bulls and others"
  p_avDailyWgtGain(herds,breeds)
  p_curDailyWgtGain(herds,breeds)
  p_MlkCont(*)
  p_fatCorMlk(herds,breeds,reqsPhase)                 "Fat corrected milk"
  start(herds)
  p_fatCorMlk(herds,breeds,reqsPhase)                 "Fat corrected milk"
;

option kill = p_reqsPhase;
option kill = p_reqsPhaseStart;
option kill = p_reqsPhaseStart;

set LC30(phase) / LC30_1,LC30_2,LC30_3,LC30_4,LC30_5,LC30_6 /;
set LC92(phase) / LC92_1,LC92_2,LC92_3,LC92_4,LC92_5,LC92_6 /;
set LC213(phase) / LC213_1,LC213_2,LC213_3,LC213_4,LC213_5,LC213_6 /;
set LC305(phase) / LC305_1,LC305_2,LC305_3,LC305_4,LC305_5,LC305_6 /;
set dry(phase) / dry_1,dry_2,dry_3,dry_4,dry_5,dry_6 /;

set cycles /
 $$iftheni.compStat "%dynamics%" == "Comparative-static"
     c1
 $$else.compStat
     c1*c6
 $$endif.compstat
  /;


*
* (1) ------------------ Calves ------------------------------------------------
*

parameter p_avLiveWgt(*,allBreeds);

p_startWgt(calvs,curBreeds) $ p_prodLength(calvs,curBreeds) = p_calvsParam(calvs,curBreeds,"startWgt");
p_finalWgt(calvs,curBreeds) $ p_prodLength(calvs,curBreeds) = p_calvsParam(calvs,curBreeds,"finalWgt");
p_reqsPhaseLength(calvs,curBreeds,"gen") $ p_prodLength(calvs,curBreeds) = p_calvsParam(calvs,curBreeds,"days");
p_avLiveWgt(calvs,curBreeds) = (p_startWgt(calvs,curBreeds) + p_finalWgt(calvs,curBreeds)) / 2;
p_avDailyWgtGain(calvs,curBreeds) $ p_reqsPhaseLength(calvs,curBreeds,"gen") = (p_finalWgt(calvs,curBreeds) - p_startWgt(calvs,curBreeds)) / p_reqsPhaseLength(calvs,curBreeds,"gen");

*
*   --- energy requirements resulting from a regression provided by LfL Bayern Zifo 2
*
p_reqsPhase(calvs,curBreeds,"gen","ME") $ p_prodLength(calvs,curBreeds)
  = [0.4270093829
  + 0.1108131429 * p_avLiveWgt(calvs,curBreeds)
  + 0.0002110913 * p_avLiveWgt(calvs,curBreeds) * p_avLiveWgt(calvs,curBreeds)
  + 0.0112966404 * (p_avDailyWgtGain(calvs,curBreeds) * 1000)
  + 0.0000006541 * (p_avDailyWgtGain(calvs,curBreeds) * 1000) * (p_avDailyWgtGain(calvs,curBreeds) * 1000)
  + 0.0000617451 * (p_avDailyWgtGain(calvs,curBreeds) * 1000) * p_avLiveWgt(calvs,curBreeds)]
  * p_reqsPhaseLength(calvs,curBreeds,"gen")
;

*
*   --- protein requirements resulting from a regression provided by LfL Bayern Zifo 2
*
p_reqsPhase(calvs,curBreeds,"gen","XP") $ p_prodLength(calvs,curBreeds)
  = [39.04424098
  + 0.96444886 * p_avLiveWgt(calvs,curBreeds)
  + 0.00389292 * p_avLiveWgt(calvs,curBreeds) * p_avLiveWgt(calvs,curBreeds)
  + 0.11610342 * (p_avDailyWgtGain(calvs,curBreeds) * 1000)
  + 0.00008088 * (p_avDailyWgtGain(calvs,curBreeds) * 1000) * (p_avDailyWgtGain(calvs,curBreeds) * 1000)
  + 0.00013937 * (p_avDailyWgtGain(calvs,curBreeds) * 1000) * p_avLiveWgt(calvs,curBreeds)]
  / 1000
  * p_reqsPhaseLength(calvs,curBreeds,"gen")
;

*
*   --- maximum dry matter intake resulting from a regression provided by LfL Bayern Zifo 2
*
p_reqsPhase(calvs,curBreeds,"gen","DMMX") $ p_prodLength(calvs,curBreeds)
  = -[-400
  + 23 * p_avLiveWgt(calvs,curBreeds)
  - 0.036 * p_avLiveWgt(calvs,curBreeds) * p_avLiveWgt(calvs,curBreeds)
  + 0.003 * p_avLiveWgt(calvs,curBreeds) * (p_avDailyWgtGain(calvs,curBreeds) * 1000)
  + 0.00012 * p_avLiveWgt(calvs,curBreeds) * p_avLiveWgt(calvs,curBreeds) * p_avLiveWgt(calvs,curBreeds)
  + 0.0006 * (p_avDailyWgtGain(calvs,curBreeds) * 1000) * (p_avDailyWgtGain(calvs,curBreeds) * 1000)]
  / 1000
  * p_reqsPhaseLength(calvs,curBreeds,"gen")
;

*
*   --- minimum dry matter intake from roughages according to suggestion from LfL Bayern
*
p_reqsPhase(calvs, curBreeds, "gen", "DMR") $ p_prodLength(calvs,curBreeds)
  = (1 - ((105.714 - 0.32143 * p_avLiveWgt(calvs,curBreeds)) / 100)) * (-p_reqsPhase(calvs,curBreeds,"gen","DMMX"));

$iftheni.dh %cowHerd%==true
*
* (2) ------------------ Heifers -----------------------------------------------
*
p_startWgt(heifs,curBreeds) $ p_prodLength(heifs,curBreeds) = p_fParam(heifs,curBreeds,"startWgt");
p_finalWgt(heifs,curBreeds) $ p_prodLength(heifs,curBreeds) = p_fParam(heifs,curBreeds,"finalWgt");
p_reqsPhaseLength(heifs,curBreeds,"gen") $ p_prodLength(heifs,curBreeds) = p_fParam(heifs,curBreeds,"days");
p_avLiveWgt(heifs,curBreeds) $ p_prodLength(heifs,curBreeds) = (p_startWgt(heifs,curBreeds) + p_finalWgt(heifs,curBreeds)) / 2;
p_avDailyWgtGain(heifs,curBreeds) $ p_prodLength(heifs,curBreeds) = (p_finalWgt(heifs,curBreeds) - p_startWgt(heifs,curBreeds)) / p_reqsPhaseLength(heifs,curBreeds,"gen");


*
*   --- energy requirements according to regression from LfL Bayern Zifo 2 .
*
p_reqsPhase(heifs,curBreeds,"gen","ME") $ p_prodLength(heifs,curBreeds)
  =[-1.768981841
  + 0.155794598 * p_avLiveWgt(heifs,curBreeds)
  - 0.000081673 * p_avLiveWgt(heifs,curBreeds) * p_avLiveWgt(heifs,curBreeds)
  + 0.021791319 * (p_avDailyWgtGain(heifs,curBreeds) * 1000)
  - 0.000002146 * (p_avDailyWgtGain(heifs,curBreeds) * 1000) * (p_avDailyWgtGain(heifs,curBreeds) * 1000)
  + 0.000022217 * p_avLiveWgt(heifs,curBreeds) * (p_avDailyWgtGain(heifs,curBreeds) * 1000)]
  * p_reqsPhaseLength(heifs,curBreeds,"gen")
;

*
*   --- maximum dry matter intake according to regression from LfL Bayern Zifo 2 .
*
p_reqsPhase(heifs,curBreeds,"gen","DMMX") $ p_prodLength(heifs,curBreeds)
  = -[-1264.160647
  + 34.6 * p_avLiveWgt(heifs,curBreeds)
  - 0.053 * p_avLiveWgt(heifs,curBreeds) * p_avLiveWgt(heifs,curBreeds)
  + 0.00105 * (p_avDailyWgtGain(heifs,curBreeds) * 1000) * (p_avDailyWgtGain(heifs,curBreeds) * 1000)
  + 0.000053 * p_avLiveWgt(heifs,curBreeds) * p_avLiveWgt(heifs,curBreeds) * p_avLiveWgt(heifs,curBreeds)
  - 0.00000002815 * p_avLiveWgt(heifs,curBreeds) * p_avLiveWgt(heifs,curBreeds) * p_avLiveWgt(heifs,curBreeds) * p_avLiveWgt(heifs,curBreeds)]
  / 1000
  * p_reqsPhaseLength(heifs,curBreeds,"gen")
;

*
*   --- the required amount of dry matter used from roughaghes is derived from Haenel et al (2018), p. 162
*
p_reqsPhase(heifs,curBreeds,"gen","DMR") $ p_prodLength(heifs,curBreeds)
  = -p_reqsPhase(heifs,curBreeds,"gen","DMMX")
    * (1 - (0.353 - 7.798 * 10 ** (-5) * p_finalWgt(heifs,curBreeds)))
;
*
*   --- Protein requirements according to regression from LfL Bayern Zifo 2.
*
p_reqsPhase(heifs,curBreeds,"gen","XP") $ p_prodLength(heifs,curBreeds)
  =[-116.8074712
  + 2.7259682 * p_avLiveWgt(heifs,curBreeds)
  - 0.0018363 * p_avLiveWgt(heifs,curBreeds) * p_avLiveWgt(heifs,curBreeds)
  + 0.1946959 * (p_avDailyWgtGain(heifs,curBreeds) * 1000)
  + 0.0000433 * (p_avDailyWgtGain(heifs,curBreeds) * 1000) * (p_avDailyWgtGain(heifs,curBreeds) * 1000)
  + 0.0000827 * (p_avDailyWgtGain(heifs,curBreeds) * 1000) * p_avLiveWgt(heifs,curBreeds)]
  / 1000
  * p_reqsPhaseLength(heifs,curBreeds,"gen")
  ;

*
* (3) ------------------ Dairy and Mother cows ---------------------------------
*

*
*  --- Please do not change these requirement lengths!
*      They need to add up to a year in order for the herdsBal_
*      to work correctly. Differences in the inter-calving
*      period are accounted for by prolonging the dry period,
*      which is done by linearly increasing/decreasing the dry period herd
*      requirements
*
start(cows) = 0;
p_reqsPhaseLength(cows,curBreeds,"LC30")  = 30;
p_reqsPhaseLength(cows,curBreeds,"LC92")  = 92-30+1;
p_reqsPhaseLength(cows,curBreeds,"LC213") = 213-92+1;
p_reqsPhaseLength(cows,curBreeds,"LC305") = 305-213+1;
p_reqsPhaseLength(cows,curBreeds,"dry")   = 365 - 305+1;

Parameter p_reqsPhaseStartDay(cows,breeds,reqsPhase)            "Lactationday";

p_reqsPhaseStartDay(cows,curBreeds,"LC30")  = 30;
p_reqsPhaseStartDay(cows,curBreeds,"LC92")  = 92;
p_reqsPhaseStartDay(cows,curBreeds,"LC213") = 213;
p_reqsPhaseStartDay(cows,curBreeds,"LC305") = 305;
p_reqsPhaseStartDay(cows,curBreeds,"dry")   = 360;

  loop(cycles,
     p_reqsPhaseStart(cows,curBreeds,LC30)  $ (LC30.pos  eq cycles.pos)   = 1  + start(cows);
     p_reqsPhaseStart(cows,curBreeds,LC92)  $ (LC92.pos eq cycles.pos)    = 2  + start(cows);
     p_reqsPhaseStart(cows,curBreeds,LC213) $ (LC213.pos eq cycles.pos)   = 4  + start(cows);
     p_reqsPhaseStart(cows,curBreeds,LC305) $ (LC305.pos eq cycles.pos)   = 8  + start(cows);
     p_reqsPhaseStart(cows,curBreeds,dry)   $ (dry.pos   eq cycles.pos)   = 11 + start(cows);

     start(cows) = sum(curBreeds $ herds_breeds(cows,curBreeds), round(start(cows) + p_reqsPhaseLength(cows,curBreeds,"dry")/30.5 + 10));


  );

p_mlkCont("FAT") = 4.0;

* average live weight of cows and mothercows from GUI
p_avLiveWgt(cows,curBreeds) $ herds_breeds(cows,curBreeds)
  = sum((cowTypes) $ herds_cowTypes(cows,cowTypes), p_cowAttr(cowTypes,"avgCowWeigth"));

*
*   --- milk "cows" are 365 days a year in production process
*       milk prod. per lactation day for dairy cows
*

 parameter p_mlkPerDay(cows,breeds,reqsPhase)                    "milk amount of specific cow lactated on one day in phase" ;

p_mlkPerDay(dcows,curBreeds,"LC30")  $ herds_breeds(dcows,curBreeds) = 0.003555556 * sum(t $ (t.pos eq 1), p_OCoeff(dcows,"milk",curBreeds,t) * 1000);
p_mlkPerDay(dcows,curBreeds,"LC92")  $ herds_breeds(dcows,curBreeds) = 0.004333333 * sum(t $ (t.pos eq 1), p_OCoeff(dcows,"milk",curBreeds,t) * 1000);
p_mlkPerDay(dcows,curBreeds,"LC213") $ herds_breeds(dcows,curBreeds) = 0.003333333 * sum(t $ (t.pos eq 1), p_OCoeff(dcows,"milk",curBreeds,t) * 1000);
p_mlkPerDay(dcows,curBreeds,"LC305") $ herds_breeds(dcows,curBreeds) = 0.002333333 * sum(t $ (t.pos eq 1), p_OCoeff(dcows,"milk",curBreeds,t) * 1000);

*
*   --- milk prod. per lactation day for mother cows
*
p_mlkPerDay(mCows,curBreeds,"LC30")  $ herds_breeds(mcows,curBreeds) = 0.003555556 * sum(t $ (t.pos eq 1), p_OCoeff("motherCow","milkFed",curBreeds,t) * 1000);
p_mlkPerDay(mCows,curBreeds,"LC92")  $ herds_breeds(mcows,curBreeds) = 0.004333333 * sum(t $ (t.pos eq 1), p_OCoeff("motherCow","milkFed",curBreeds,t) * 1000);
p_mlkPerDay(mCows,curBreeds,"LC213") $ herds_breeds(mcows,curBreeds) = 0.003333333 * sum(t $ (t.pos eq 1), p_OCoeff("motherCow","milkFed",curBreeds,t) * 1000);
p_mlkPerDay(mCows,curBreeds,"LC305") $ herds_breeds(mcows,curBreeds) = 0.002333333 * sum(t $ (t.pos eq 1), p_OCoeff("motherCow","milkFed",curBreeds,t) * 1000);

alias(reqsPhase,reqsPhase1);

*
* --- reflect the intercalving period: a higher inter-calving period implies that the same ammount of milk per year
*                                      requires a higher output per day
*
p_mlkPerDay(cows,curBreeds,reqsPhase) $ (herds_breeds(cows,curBreeds))
  = p_mlkPerDay(cows,curBreeds,reqsPhase) * (417-60)/305;
*
*  --- fat corrected milk
*
p_fatCorMlk(cows,curBreeds,reqsPhase) $ (herds_breeds(cows,curBreeds))
  = p_mlkPerDay(cows,curBreeds,reqsPhase) * ( 0.4 + 0.15 * p_mlkCont("FAT") );

*
* --- Net Energy calculation from Kirchgessner 2014 p. 362
*
p_reqsPhase(cows,curBreeds,reqsPhase,"NEL") $ (herds_breeds(cows,curBreeds))
* energy for maintenance
 = (0.293 * p_avLiveWgt(cows,curBreeds) ** 0.75
* energy for lactation
   + (0.41 * p_mlkCont("fat") + 1.51) * p_mlkPerDay(cows,curBreeds,reqsPhase)
* energy for pregnancy
   + (3.4 / 0.2) $ sameas(reqsPhase, "dry"))
* multiplied with requirement phase lenght
   * p_reqsPhaseLength(cows,curBreeds,reqsPhase)
;

*
* --- dry matter intake of according to Herd Health and Production Management in Dairy Practice"
*     von A. Brand, J.P.T.M. Noordhuizen und Y.H. Schukken, Wageningen Pers, Wageningen
*     1997, The Netherlands
*https://www.lfl.bayern.de/mam/cms07/ite/dateien/17883_sch__tzgleichungen_dlg_futteraufnahme.pdf
parameter p_breedEff(cowTypes)
/
 HF -0.898
 SI -1.391
 MC -2.169
/;

p_reqsPhase(cows,curBreeds,reqsPhase,"DMMX") $ (herds_breeds(cows,curBreeds) $ p_reqsPhaseLength(cows,curBreeds,reqsPhase))
* correction factor a
   = - {0.71 +
* intercept
   [2.274
* effect of cow breed
   + p_breedEff("%cowType%") $ (sum(dCows $ sameas(cows,dCows),1))
   + p_breedEff("%motherCowType%") $ (sum(mCows $ sameas(cows,mCows),1))
   + 0.236
   + (-5.445 + 5.298 * (1 - EXP(-0.01838 * p_reqsPhaseStartDay(cows,curBreeds,reqsPhase))))
   + ((0.0173 - 0.0000514 * p_reqsPhaseStartDay(cows,curBreeds,reqsPhase) + 0.0000000999 * p_reqsPhaseStartDay(cows,curBreeds,reqsPhase) * p_reqsPhaseStartDay(cows,curBreeds,reqsPhase)) * p_avLiveWgt(cows,curBreeds))
   + ((0.201 + 0.000808 * p_reqsPhaseStartDay(cows,curBreeds,reqsPhase) - 0.000001299 * p_reqsPhaseStartDay(cows,curBreeds,reqsPhase) * p_reqsPhaseStartDay(cows,curBreeds,reqsPhase)) * p_mlkPerDay(cows,curBreeds,reqsPhase))
   + ((0.0631 - 0.0002096 * p_reqsPhaseStartDay(cows,curBreeds,reqsPhase) + 0.0000001213 * p_reqsPhaseStartDay(cows,curBreeds,reqsPhase) * p_reqsPhaseStartDay(cows,curBreeds,reqsPhase)) * 25)
   + (6.3 * 0.609)]
   * 0.92
   * p_reqsPhaseLength(cows,curBreeds,reqsPhase)
 }
;

p_reqsPhase(cows,curBreeds,reqsPhase,"DMR") $ (herds_breeds(cows,curBreeds))
  = -0.5 $(%milkYield%<86)
    -0.2 $(%milkYield%<100)
    * p_reqsPhase(cows,curBreeds,reqsPhase,"DMMX")
;

* --- crude protein according to Kirchgessner 2014, p. 365

p_reqsPhase(cows,curBreeds,reqsPhase,"nXP") $ (herds_breeds(cows,curBreeds))
  = (431 + 81 * p_mlkPerDay(cows,curBreeds,reqsPhase)
* requrirement during dry phase
    + 669 $ sameas(reqsPhase, "dry"))
    * p_reqsPhaseLength(cows,curBreeds,reqsPhase) / 1000;
;

*
*   --- maximum intake of starch and sugar is limited to 25% of the maximum dry matter
*
p_reqsPhase(cows,curBreeds,reqsPhase,"XS+XZ") $ (herds_breeds(cows,curBreeds))
  = p_reqsPhase(cows,curBreeds,reqsPhase,"DMMX") * 0.25;

*
*   --- maximum and minimum RNB
*
p_reqsPhase(cows,curBreeds,reqsPhase,"RNBmax") $ ( herds_breeds(cows,curBreeds) $ p_reqsPhase(cows,curBreeds,reqsPhase,"DMMX"))
  = -30 * p_reqsPhaseLength(cows,curBreeds,reqsPhase);

p_reqsPhase(cows,curBreeds,reqsPhase,"RNBmin") $ ( herds_breeds(cows,curBreeds) $ p_reqsPhase(cows,curBreeds,reqsPhase,"DMMX"))
  = -30 * p_reqsPhaseLength(cows,curBreeds,reqsPhase);

$endif.dh

*
* (4) ------------------ Bulls -------------------------------------------------
*
$iftheni.beef  "%farmBranchBeef%"=="on"

p_reqsPhaseLength(bulls,curBreeds,"gen") $ p_prodLength(bulls,curBreeds) = p_mParam(bulls,curBreeds,"days");

p_avLiveWgt(bulls,curBreeds) $ p_prodLength(bulls,curBreeds)
  = (p_mParam(bulls,curBreeds,"startwgt") + p_mParam(bulls,curBreeds,"finalWgt"))/2;

p_finalWgt(bulls,curBreeds) $ p_prodLength(bulls,curBreeds) = p_mParam(bulls,curBreeds,"finalWgt");

p_avDailyWgtGain(bulls, curBreeds) $ p_prodLength(bulls,curBreeds)
  = p_mParam(bulls,curBreeds,"dailyWgtGain")/1000;

*
* --- current daily weight gain
*
p_curDailyWgtGain(bulls,curBreeds) $ p_prodLength(bulls,curBreeds)
  = -777.016268
    + (6.1792265 * p_avLiveWgt(bulls,curBreeds))
    + (p_avDailyWgtGain(bulls,curBreeds) * 1000)
    - (0.0123838 * p_avLiveWgt(bulls,curBreeds) * p_avLiveWgt(bulls,curBreeds))
    + (0.0000068 * p_avLiveWgt(bulls,curBreeds) * p_avLiveWgt(bulls,curBreeds) * p_avLiveWgt(bulls,curBreeds))
  ;

*
*   --- energy requirements according to regression from LfL Bayern Zifo 2 .
*
p_reqsPhase(bulls,curBreeds,"gen","ME") $ p_prodLength(bulls,curBreeds)
  = [2.166432385
    + (0.131719517 * p_avLiveWgt(bulls,curBreeds))
    + (- 0.000038324 * p_avLiveWgt(bulls,curBreeds) * p_avLiveWgt(bulls,curBreeds))
    + (0.013942077  * p_curDailyWgtGain(bulls,curBreeds))
    + (0.000000483 * p_curDailyWgtGain(bulls,curBreeds) * p_curDailyWgtGain(bulls,curBreeds))
    + (0.000039207 * p_avLiveWgt(bulls,curBreeds) * p_curDailyWgtGain(bulls,curBreeds))]
*    adjust to phase length
    * p_reqsPhaseLength(bulls,curBreeds,"gen")
;


*
*   --- maximum dry matter intake according to regression from LfL Bayern Zifo 2 .
*
p_reqsPhase(bulls,curBreeds,"gen","DMMX") $ p_prodLength(bulls,curBreeds)
  = - [916.6285451
    + (15.9 * p_avLiveWgt(bulls,curBreeds))
    - (0.0095801 * p_avLiveWgt(bulls,curBreeds) * p_avLiveWgt(bulls,curBreeds))
    + (0.0028583 * p_avLiveWgt(bulls,curBreeds) * p_curDailyWgtGain(bulls,curBreeds))
    + (0.00025 * p_curDailyWgtGain(bulls,curBreeds) * p_curDailyWgtGain(bulls,curBreeds))
    + (0.0000029 * p_avLiveWgt(bulls,curBreeds) * p_avLiveWgt(bulls,curBreeds) * p_avLiveWgt(bulls,curBreeds))]
  /1000
*    adjust to phase length
  * p_reqsPhaseLength(bulls,curBreeds,"gen")
;

*
*   --- the required amount of dry matter used from roughaghes is derived from Haenel et al (2018), p. 162
*
*p_reqsPhase(bulls,curBreeds,"gen","DMR") $ p_prodLength(bulls,curBreeds)
*  = 0.65 * (- p_reqsPhase(bulls,curBreeds,"gen","DMMX"));

*
*   --- a minium share of 28% structured fibre
*
*p_reqsPhase(bulls,curBreeds,"gen","aNDF") $ p_prodLength(bulls,curBreeds)
*  = 0.28 * (- p_reqsPhase(bulls,curBreeds,"gen","DMMX"));

*   --- Protein requirements according to regression from LfL Bayern Zifo 2.
*
p_reqsPhase(bulls,curBreeds,"gen","XP") $ p_prodLength(bulls,curBreeds)
  = [7.345226361
  + (1.261657512 * p_avLiveWgt(bulls,curBreeds))
  + (0.252650459 * p_curDailyWgtGain(bulls,curBreeds))
  - (0.000126837 * p_avLiveWgt(bulls,curBreeds) * p_avLiveWgt(bulls,curBreeds))
  + (0.000023266 * p_curDailyWgtGain(bulls,curBreeds) * p_curDailyWgtGain(bulls,curBreeds))
  + (0.000211880 * p_avLiveWgt(bulls,curBreeds) * p_curDailyWgtGain(bulls,curBreeds))]
*    adjust to phase length
  /1000
  * p_reqsPhaseLength(bulls,curBreeds,"gen")
  ;

*
*   --- maximum intake of starch and sugars
*
  p_reqsPhase(bulls,curBreeds,"gen","XS+XZ") $ p_prodLength(bulls,curBreeds)
    = - [256.6559926
      + (4.452 * p_avLiveWgt(bulls,curBreeds))
      - (0.002682428 * p_avLiveWgt(bulls,curBreeds) * p_avLiveWgt(bulls,curBreeds))
      + (0.000800324 * p_avLiveWgt(bulls,curBreeds) * p_curDailyWgtGain(bulls,curBreeds))
      + (0.00007 * p_curDailyWgtGain(bulls,curBreeds) * p_curDailyWgtGain(bulls,curBreeds))
      + (0.000000812 * p_avLiveWgt(bulls,curBreeds) * p_avLiveWgt(bulls,curBreeds) * p_avLiveWgt(bulls,curBreeds))]
    /1000
    * p_reqsPhaseLength(bulls,curBreeds,"gen")
    ;

*
*   --- maximum and minimum RNB
*
 p_reqsPhase(bulls,curBreeds,reqsPhase,"RNBmax") $ p_reqsPhase(bulls,curBreeds,reqsPhase,"DMMX")
   = -30 * p_reqsPhaseLength(bulls,curBreeds,reqsPhase);

 p_reqsPhase(bulls,curBreeds,reqsPhase,"RNBmin") $ p_reqsPhase(bulls,curBreeds,reqsPhase,"DMMX")
   = -30 * p_reqsPhaseLength(bulls,curBreeds,reqsPhase);
$endif.beef
*
* (5) ------------------ Final calculations -----------------------------------------------------------
*


*
*   --- Checking parameters to investigate total requirements of animals
*
*p_reqsTot(calvs,feedAttr) = p_reqsPhase(calvs,curBreeds,"gen",feedAttr);
*p_reqsTot(cows,feedAttr) = sum(reqsPhase, p_reqsPhase(cows,curBreeds,reqsPhase,feedAttr)) * (365/sum(reqsPhase, p_reqsPhaseLength(cows,curBreeds,reqsPhase)));
*p_reqsTot("bulls",feedAttr) = sum(bulls, p_reqsPhase(bulls,curBreeds,"gen",feedAttr));

*
* end of requirement calculation
*
  p_reqsPhase(herds,curBreeds,reqsPhase,feedAttr) $ (not reqs(feedAttr)) = 0;
*
* --- convert requirements for whole phase into monthly ones
*
*    (1) from days to month, rounded
*
  p_reqsPhaseLengthMonths(herds,curBreeds,reqsPhase) = round(p_reqsPhaseLength(herds,curBreeds,reqsPhase)/30.5);

*
*    (2) convert into requirements per month
*        (will enter the equation reqsPhase_ for cattle with phase differentiation)
*
   p_reqsPhaseMonths(herds,curBreeds,feedRegime,reqsPhase,reqs) $ p_reqsPhaseLength(herds,curBreeds,reqsPhase)
      = p_reqsPhase(herds,curBreeds,reqsPhase,reqs)/p_reqsPhaseLength(herds,curBreeds,reqsPhase) * 30.5;
*
*      --- take into account differences in inter-calving periods, assume affects only dry period,
*          keeps it length (conceptually), but change the daily requirements according to change in length
*
   $$iftheni.calvs defined herds_cowTypes
     p_reqsPhaseMonths(cows,curBreeds,feedRegime,"dry",reqs)
        = p_reqsPhaseMonths(cows,curBreeds,feedRegime,"dry",reqs)
              * sum(herds_cowTypes(cows,cowTypes), (p_calvAttr(cowTypes,"daysBetweenBirths")-305)/60);
   $$endif.calvs

* --- Required feed additive ratio to total dry matter in order to reduce entferic emissions
  $$ifi.feedAdd "%feedAddOn%" == true $$batinclude '%datdir%/enforcedMitigation.gms'
$endif.cattle

$iftheni.pigherd %pigherd% == true

**********************************************************************************************************
*
* --- PIGHERD: Feeding requirements of sows, piglets and fattners in each production stage
*
**********************************************************************************************************

* --- Different phases of pigs defined by the livemass

set massPhases /
$ifi "%farmBranchFattners%" == "on"                stg28_40, stg40_118, stg40_70, stg70_118, stg40_65, stg65_90, stg90_118
$ifi "%farmBranchSows%"     == "on"                sowPhase,pigletPhase
               /;

set massPhases_feedRegime(massPhases,feedRegime)

$iftheni.fat "%farmBranchFattners%" == "on"
                /
                 stg28_40.normFeed
                 stg40_118.normFeed
     $$iftheni.red %redNPFeed% == true
                 stg28_40.redNP
                 stg40_70.redNP
                 stg70_118.redNP

                 stg28_40.highRedNP
                 stg40_65.highRedNP
                 stg65_90.highRedNP
                 stg90_118.highRedNP
     $$endif.red
                /
$endif.fat
;

$iftheni.Sows "%farmBranchSows%" == "on"
        massPhases_feedRegime("sowPhase",feedRegime) =YES;
        massPhases_feedRegime("pigletPhase",feedRegime) =YES;
$endif.Sows


* --- Weight gain in the different phases of fattening pigs; stg28-40 = Phase in which the pig starts with a live mass of 28kg and ends with 40kg

$iftheni.fat "%farmBranchfattners%" == "on"
parameter    p_weightGainInMassPhase(massPhases)        " Weight gain in mass stages in kg"
               / stg28_40     12
                 stg40_118    78

                 stg40_70     30
                 stg70_118    48

                 stg40_65     25
                 stg65_90     25
                 stg90_118    28
               /;
$endif.fat



* --- Mass feed intake in different phases - Fattening Pigs -> kg feed intake for each phase (DLG 2014 - Bilanzierung der N�hrstoffausscheidungen landwirtschaftlicher Nutztiere - p.74)
*                                            Sows           -> kg feed intake per year       (DLG 2014 - Bilanzierung der N�hrstoffausscheidungen landwirtschaftlicher Nutztiere - p.58)
*                                            Piglets        -> kg feed intake per piglet     (DLG 2014 - Bilanzierung der N�hrstoffausscheidungen landwirtschaftlicher Nutztiere - p.58)

parameter    p_phaseMassReq(massPhases,feedRegime)                 "Phasely amount of mass feed in kg";

$iftheni.fat "%farmBranchFattners%" == "on"

             p_phaseMassReq("stg28_40", feedRegime)  = 24.3;
             p_phaseMassReq("stg40_118", feedRegime) = 225 ;

             p_phaseMassReq("stg40_70", feedRegime)  = 72.8;
             p_phaseMassReq("stg70_118", feedRegime) = 154 ;

             p_phaseMassReq("stg40_65", feedRegime)  = 59.9;
             p_phaseMassReq("stg65_90", feedRegime)  = 69.7;
             p_phaseMassReq("stg90_118", feedRegime) = 97.5;
$endif.fat

$iftheni.sows "%farmBranchSows%" == "on"

             p_phaseMassReq("sowPhase","normFeed")     = 1240 ;
             p_phaseMassReq("pigletPhase","normFeed")  = 35   ;

      $$iftheni.red        %redNPFeed% == true
             p_phaseMassReq("sowPhase","redNP")        = 1260 ;
             p_phaseMassReq("pigletPhase","redNP")     = 35   ;

             p_phaseMassReq("sowPhase","highRedNP")    = 1260 ;
             p_phaseMassReq("pigletPhase","highRedNP") = 35   ;
      $$endif.red

$endif.sows

* --- Parameters used to estimate the daily feed/nutrient intake of fattening pigs and the amount of days each pig remains in a feeding phase

$iftheni.fat "%farmBranchFattners%" == "on"
parameter    p_daysInMassPhase(massPhases)    "Assumption of 850g daily weight gain";
             p_daysInMassPhase(massPhases) =  p_weightGainInMassPhase(massPhases) / 0.85;


parameter    p_dailyMassReq(massPhases, feedRegime)       "Daily mass requirement in kg for fattening";
             p_dailyMassReq(massPhases, feedRegime) $ p_daysInMassPhase(massPhases)
              =     p_phaseMassReq(massPhases,feedRegime) / p_daysInMassPhase(massPhases);


parameter    p_dailyEnerReq(massPhases)       "Daily energy requirement under the assumption of 36.5 MJ ME / kg Weight gain and 850g daily weight gain";
             p_dailyEnerReq(massPhases)   =    36.5 *0.85;
$endif.fat

* --- Energy content in feed depending on feeding regime in piglet production

$iftheni.sows "%farmBranchSows%" == "on"
parameter    p_enerReqPhaseSows(massPhases,feedRegime)       "Energy requirement per kg feed in piglet production"
                               /
                                sowPhase.normFeed       12.8
                                pigletPhase.normFeed    13.6

               $$iftheni.red   %redNPFeed% == true
                                sowPhase.redNP          12.6
                                pigletPhase.redNP       13.6

                                sowPhase.highRedNP      12.6
                                pigletPhase.highRedNP   13.6
               $$endif.red
                               /;
$endif.sows

* --- Nutrient content in feed in different phases - Fattening Pigs -> kg feed intake for each phase (DLG 2014 - Bilanzierung der N�hrstoffausscheidungen landwirtschaftlicher Nutztiere - p.71)
*                                                    Sows           -> kg feed intake per year       (DLG 2014 - Bilanzierung der N�hrstoffausscheidungen landwirtschaftlicher Nutztiere - p.55)
*                                                    Piglets        -> kg feed intake per piglet     (DLG 2014 - Bilanzierung der N�hrstoffausscheidungen landwirtschaftlicher Nutztiere - p.55)


table p_avgNutContFeed(massPhases,feedRegime,feedAttr)                "Nutrient content of feed in pigherds in g/kg"
                                        crudeP              phosphFeed

$iftheni.fat "%farmBranchfattners%" == "on"

        stg28_40.normFeed                175                   5.3
        stg40_118.normfeed               170                   5.0

    $$iftheni.red  %redNPFeed% == true
        stg28_40.redNP                   175                   5.0
        stg40_70.redNP                   170                   4.5
        stg70_118.redNP                  160                   4.5

        stg28_40.highRedNP               175                   4.7
        stg40_65.highRedNP               165                   4.5
        stg65_90.highRedNP               155                   4.2
        stg90_118.highRedNP              140                   4.2
    $$endif.red

$endif.fat

$iftheni.sows "%farmBranchSows%" == "on"

        sowPhase.normfeed                170                   5.5
        pigletPhase.normFeed             190                   5.5

    $$iftheni.red  %redNPFeed% == true
        sowPhase.redNP                   155                   5
        pigletPhase.redNP                182.5                 5.2

        sowPhase.highRedNP               150                   4.65
        pigletPhase.highRedNP            177.5                 5.15
    $$endif.red
$endif.sows
;


* --- Resulting daily nutrient requirement for fattening pigs and monthly for sow and piglets, respectively

$iftheni.fat "%farmBranchfattners%" == "on"

parameter p_dailynutrientReqPhaseFeed(massPhases,feedRegime,feedAttr) "Daily nutrient requirements in gram";

          p_dailynutrientReqPhaseFeed(massPhases,feedRegime,feedAttr) =  p_avgNutContFeed(massPhases,feedRegime,feedAttr) * p_dailyMassReq(massPhases,feedRegime);

          p_dailynutrientReqPhaseFeed(massPhases,feedRegime,"energ") $ massPhases_feedRegime(massPhases,feedRegime)  = p_dailyEnerReq(massPhases);

          p_dailynutrientReqPhaseFeed(massPhases,feedRegime,"mass")  $ massPhases_feedRegime(massPhases,feedRegime)  = (-1) * p_dailyMassReq(massPhases,feedRegime);
$endif.fat




$iftheni.sows "%farmBranchSows%" == "on"

parameter p_animlCtgryInSowHerd(massPhases)             "Length of stay of animal category in sow herd in month"
                /
                 sowPhase 12
                 pigletphase 2
                /;

parameter p_monthlynutrientReqPhaseFeed(massPhases,feedRegime,feedAttr) "Monthly nutrient reqirements in gram";

          p_monthlynutrientReqPhaseFeed(massPhases,feedRegime,feedAttr) $ p_animlCtgryInSowHerd(massPhases)
           = (p_avgNutContFeed(massPhases,feedRegime,feedAttr) * p_phaseMassReq(massPhases,feedRegime)) / p_animlCtgryInSowHerd(massPhases)  ;

          p_monthlynutrientReqPhaseFeed(massPhases,feedRegime,"energ")
            $ (massPhases_feedRegime(massPhases,feedRegime) $ p_animlCtgryInSowHerd(massPhases))
            = (p_enerReqPhaseSows(massPhases,feedRegime) * p_phaseMassReq(massPhases,feedRegime)) / p_animlCtgryInSowHerd(massPhases)  ;

          p_monthlynutrientReqPhaseFeed(massPhases,feedRegime,"mass")
             $ (massPhases_feedRegime(massPhases,feedRegime) $ p_animlCtgryInSowHerd(massPhases))
            =  (-1) * p_phaseMassReq(massPhases,feedRegime) / p_animlCtgryInSowHerd(massPhases)  ;
$endif.sows




* --- Monthly feeding requirements for sows, piglets, fattening pigs and each of their stages.

parameter p_feedReqPigs(herds,feedRegime,feedAttr)                    "Based on daily nutrient/mass/energy uptake, monthly values accounting for different phases";

$iftheni.fat "%farmBranchFattners%" == "on"

* --- Norm feed requirements
          p_feedReqPig("earlyFattners","normFeed",feedAttr)   =  (p_dailynutrientReqPhaseFeed("stg28_40","normFeed",feedAttr) * p_daysInMassPhase("stg28_40"))
                                                                + p_dailynutrientReqPhaseFeed("stg40_118","normFeed",feedAttr)* (30- p_daysInMassPhase("stg28_40"));

          p_feedReqPig("midFattners","normFeed",feedAttr)     =    p_dailynutrientReqPhaseFeed("stg40_118","normFeed",feedAttr) * 30;

          p_feedReqPig("lateFattners","normFeed",feedAttr)    =    p_dailynutrientReqPhaseFeed("stg40_118","normFeed",feedAttr) * 30;

          p_feedReqPig("Fattners","normFeed",feedAttr)        =    p_dailynutrientReqPhaseFeed("stg40_118","normFeed",feedAttr)
                                                                 * ( sum(massPhases, p_daysInMassPhase(massPhases) $ massPhases_feedRegime(massPhases,"normFeed")) - 90 );
        $$iftheni.red %redNPFeed% == true
* --- Reduced N/P feeding
         p_feedReqPig("earlyFattners","redNP",feedAttr)       =   (p_dailynutrientReqPhaseFeed("stg28_40","redNP",feedAttr) * p_daysInMassPhase("stg28_40"))
                                                                + p_dailynutrientReqPhaseFeed("stg40_70","redNP",feedAttr)* (30- p_daysInMassPhase("stg28_40"));

         p_feedReqPig("midFattners","redNP",feedAttr)         =   (30- p_daysInMassPhase("stg28_40")) * p_dailynutrientReqPhaseFeed("stg40_70","redNP",feedAttr)
                                                                + (30 - (30- p_daysInMassPhase("stg28_40"))) * p_dailynutrientReqPhaseFeed("stg70_118","redNP",feedAttr);

         p_feedReqPig("lateFattners","redNP",feedAttr)        =  30 * p_dailynutrientReqPhaseFeed("stg70_118","redNP",feedAttr);

         p_feedReqPig("fattners","redNP",feedAttr)            =  ( sum(massPhases, p_daysInMassPhase(massPhases) $ massPhases_feedRegime(massPhases,"redNP")) - 90 ) * p_dailynutrientReqPhaseFeed("stg70_118","redNP",feedAttr);

* --- High reduced N/P feeding
         p_feedReqPig("earlyFattners","highRedNP",feedAttr)   =   (p_dailynutrientReqPhaseFeed("stg28_40","highRedNP",feedAttr) * p_daysInMassPhase("stg28_40"))
                                                                + p_dailynutrientReqPhaseFeed("stg40_65","highredNP",feedAttr)* (30- p_daysInMassPhase("stg28_40"));

         p_feedReqPig("midFattners","highRedNP",feedAttr)     = (30- p_daysInMassPhase("stg28_40")) * p_dailynutrientReqPhaseFeed("stg40_65","highRedNP",feedAttr)
                                                                + (30 - (30- p_daysInMassPhase("stg28_40"))) * p_dailynutrientReqPhaseFeed("stg65_90","highredNP",feedAttr);

         p_feedReqPig("lateFattners","highRedNP",feedAttr)    = (30 - (30- p_daysInMassPhase("stg28_40"))) * p_dailynutrientReqPhaseFeed("stg65_90","highredNP",feedAttr)
                                                                + (30 -  (30 - (30- p_daysInMassPhase("stg28_40")))) * p_dailynutrientReqPhaseFeed("stg90_118","highredNP",feedAttr);

         p_feedReqPig("Fattners","highRedNP",feedAttr)        = p_dailynutrientReqPhaseFeed("stg90_118","highRedNP",feedAttr)
                                                                 * ( sum(massPhases, p_daysInMassPhase(massPhases) $ massPhases_feedRegime(massPhases,"highRedNP")) - 90 );
        $$endif.red

$endif.fat

* --- Conversion from MJ to GJ, g nutrient to kg nutrient, kg mass intake to ton mass intake

$ifi "%farmBranchFattners%" == "on" p_feedReqPig(herds, feedRegime, feedAttr) = p_feedReqPig(herds, feedRegime, feedAttr) / 1000;

$iftheni.sows "%farmBranchSows%"     == "on"
                                   p_feedReqPig("sows", feedRegime, feedAttr) = p_monthlynutrientReqPhaseFeed("sowPhase",feedRegime,feedAttr) / 1000;
                                   p_feedReqPig("piglets", feedRegime, feedAttr) = p_monthlynutrientReqPhaseFeed("pigletPhase",feedRegime,feedAttr) / 1000;
$endif.sows

*
* ---- Define the share of different pig feeds depending on feeding regime and phase to reflect typical feed mixes. Related to days to simplify the conversion
*      to fattner phases in the herd module.
*      Used the following source for N/P reduced feeding: Stalljohann (2017): Futter: So drehen Sie an der N�hrstoffschraube, in top agra (Hrsg.) (2017): Ratgeber Neue
*      D�ngeverordnung, M�nster, p. 18 - 21.
*      For norm Feed: LWK NRW (2014): N�hrstoffangepasste F�tterung bei Sauen, Ferkeln und Mastschweinen noch intensiver nutzen, p. 49.
*
*      MinFu  [%] 19 Ca, 3 P, 8 Lys, 1 Met, 3 Thr)
*      MinFu2 [%] 20 Ca, 3 P, 8 Lys, 0 Met, 1.5 Thr)
*      MinFu3 [%] 16 Ca, 2 P, 10 Lys, 2 Met, 4 Thr)
*      MinFu4 [%] 18 Ca, 1.5 P, 10 Lys, 0 Met, 3 Thr)


$iftheni.fat "%farmBranchFattners%" == "on"

Table p_feedMinPigday(feedRegime,massPhases,feedspig)

                                   soybeanMeal     rapeSeedMeal      PlantFat     MinFu      MinFu2      MinFu3     MinFu4

        normFeed.stg28_40            0.23                             0.015       0.037
        normFeed.stg40_118           0.195                            0.015       0.032

$iftheni.red %redNPFeed% == true

        redNP.stg28_40               0.191          0.05              0.01        0.034
        redNP.stg40_70               0.15           0.075             0.01                   0.029
        redNP.stg70_118              0.0975         0.0975            0.01                   0.025

        highRedNP.stg28_40           0.16           0.045             0.01                               0.035
        highRedNP.stg40_65           0.125          0.065             0.01                                           0.03
        highRedNP.stg65_90           0.084          0.084             0.007                                          0.025
        highRedNP.stg90_118          0.075          0.075             0.006                                          0.024

$endif.red

;

*
* --- Conversion of the daily feed shares in different phases to the pig cycle in the herd module, differs for feeding regimes as the regimes are linked
*     to different numbers of phases
*

* ---- Norm feed

        p_feedMinPig("earlyFattners",feedspig,"normFeed")   = (    p_feedMinPigday("normFeed","stg28_40",feedspig)   * p_daysInMassPhase("stg28_40") +
                                                                          p_feedMinPigday("normFeed","stg40_118",feedspig) * (30- p_daysInMassPhase("stg28_40"))    )
                                                                               /  30   ;

        p_feedMinPig("midFattners",feedspig,"normFeed")    =   p_feedMinPigday("normFeed","stg40_118",feedspig) ;
        p_feedMinPig("lateFattners",feedspig,"normFeed")   =   p_feedMinPigday("normFeed","stg40_118",feedspig) ;
        p_feedMinPig("Fattners",feedspig,"normFeed")       =   p_feedMinPigday("normFeed","stg40_118",feedspig) ;

      $$iftheni.red %redNPFeed% == true


* ---  NP reduced feeding

        p_feedMinPig("earlyFattners",feedspig,"redNP")     =   (    p_feedMinPigday("redNP","stg28_40",feedspig)   * p_daysInMassPhase("stg28_40") +
                                                                      p_feedMinPigday("redNP","stg40_70",feedspig) * (30- p_daysInMassPhase("stg28_40"))    )
                                                                              /  30   ;

        p_feedMinPig("midFattners",feedspig,"redNP")       =   ( p_feedMinPigday("redNP","stg40_70",feedspig) *   (  p_daysInMassPhase("stg40_70")  - ( 30 - p_daysInMassPhase("stg28_40") ) )
                                                               +   p_feedMinPigday("redNP","stg70_118",feedspig) *  ( 30 - (  p_daysInMassPhase("stg40_70")  - ( 30 - p_daysInMassPhase("stg28_40") ) )  ))
                                                                             / 30 ;

        p_feedMinPig("lateFattners",feedspig,"redNP")      =    p_feedMinPigday("redNP","stg70_118",feedspig) ;

        p_feedMinPig("Fattners",feedspig,"redNP")          =    p_feedMinPigday("redNP","stg70_118",feedspig) ;



* --- High reduced N/P feeding


        p_feedMinPig("earlyFattners",feedspig,"highRedNP") =   (    p_feedMinPigday("highRedNP","stg28_40",feedspig)   * p_daysInMassPhase("stg28_40") +
                                                                      p_feedMinPigday("highRedNP","stg40_65",feedspig) * (30- p_daysInMassPhase("stg28_40"))    )
                                                                              /  30   ;




        p_feedMinPig("midFattners",feedspig,"highRedNP")   =   ( p_feedMinPigday("highRedNP","stg40_65",feedspig) *   (  p_daysInMassPhase("stg40_65")  - ( 30 - p_daysInMassPhase("stg28_40") ) )
                                                              +   p_feedMinPigday("highRedNP","stg65_90",feedspig) *  ( 30 - (  p_daysInMassPhase("stg40_65")  - ( 30 - p_daysInMassPhase("stg28_40") ) )  ))
                                                                             / 30 ;

        p_feedMinPig("lateFattners",feedspig,"highRedNP")  =   ( p_feedMinPigday("highRedNP","stg65_90",feedspig) *   (  p_daysInMassPhase("stg65_90")  - ( 30 - p_daysInMassPhase("stg40_65") ) )
                                                                   +   p_feedMinPigday("highRedNP","stg90_118",feedspig) * ( 30 -  (  p_daysInMassPhase("stg65_90")  - ( 30 - p_daysInMassPhase("stg40_65") ) ) ) )
                                                                              / 30 ;



        p_feedMinPig("Fattners",feedspig,"highRedNP")       =    p_feedMinPigday("highRedNP","stg90_118",feedspig) ;


       $$endif.red

;

*
* --- Assumption that Minimum and maximum are equal to force model to feed exact amount of certain feeds




*

         p_feedMaxPig("Fattners",feedspig,feedRegime)      $ p_feedMinPig("Fattners",feedspig,feedRegime)      =  p_feedMinPig("Fattners",feedspig,feedRegime)      + 0.03 ;
         p_feedMaxPig("lateFattners",feedspig,feedRegime)  $ p_feedMinPig("lateFattners",feedspig,feedRegime)  =  p_feedMinPig("lateFattners",feedspig,feedRegime)  + 0.03 ;
         p_feedMaxPig("earlyFattners",feedspig,feedRegime) $ p_feedMinPig("earlyFattners",feedspig,feedRegime) =  p_feedMinPig("earlyFattners",feedspig,feedRegime) + 0.03 ;
         p_feedMaxPig("midFattners",feedspig,feedRegime)   $ p_feedMinPig("midFattners",feedspig,feedRegime)   =  p_feedMinPig("midFattners",feedspig,feedRegime)   + 0.03 ;

         p_feedMaxPig("Fattners",feedspig,feedRegime)     $ sum(sameas(feedspig,maizCCM),1)= 0.5;
         p_feedMaxPig("lateFattners",feedspig,feedRegime) $ sum(sameas(feedspig,maizCCM),1)= 0.5;
         p_feedMaxPig("earlyFattners",feedspig,feedRegime)$ sum(sameas(feedspig,maizCCM),1)= 0.5;
         p_feedMaxPig("midFattners",feedspig,feedRegime)  $ sum(sameas(feedspig,maizCCM),1)= 0.5;

        display    p_feedMinPig,p_feedMaxPig ;
$endif.fat


* --- Feeding requirements for sows is still working with the old data

$iftheni.sows "%farmBranchSows%"     == "on"

$onmulti
    Table p_feedMinPig(herds,feedspig,feedRegime)   "feedmix requirements accounting for minerals, feed texture, digestability"

                                soybeanMeal.normFeed          soybeanOil.normFeed          minFu.normFeed






     sows                              0.01                             0.001                0.01
     piglets                           0.19                             0.001                0.01

;
$offmulti


     p_feedMaxPig(herds,cereFeedPig,feedRegime)  = 0.85;
     p_feedMaxPig(herds,"soybeanOil",feedRegime) = 0.03;
     p_feedMaxPig(herds,"minfu",feedRegime)      = 0.04;
     p_feedMaxPig(herds,"soybeanMeal",feedRegime)= 0.3;

$endif.sows




$endif.pigherd
