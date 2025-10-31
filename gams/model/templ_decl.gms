********************************************************************************
$ontext

   FARMDYN project

   GAMS file : TEMPL_DECL.GMS

   @purpose  : define sets and parameters used in coefficient generator
               and model
   @author   : Bernd Lengers
   @date     : 12.11.10
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter.gms

$offtext
********************************************************************************
$onmulti
$onempty

$setglobal calib no
$ifi not "%calibration%"=="false"    $setglobal calib yes
$ifi not "%calibRes%"=="farm_empty"  $setglobal calib yes

$iftheni.calib "%calib%"=="yes"
   $$if "%solver%"=="OSICPLEX" $abort "OSICPLEX cannot be used with calibration"
   $$setglobal parsAsVars true
$else.calib
   $$setglobal parsAsVars false
$endif.calib


* --- Introduces enforced mitigation measure globals
$ifi "%mitiMeasures%" == true $include 'ghgmac/mitOptions.gms'

* -----------------------------------------------------------------------------
*
*   Declaration of sets (= index domains)
*
* -----------------------------------------------------------------------------
*
*    --- for calculation of land values
*
$evalglobal lastFutureYear %lastYearCalc%+10
*
$evalglobal firstYearCalc  %firstYear%-5
$evalglobal firstYearM1    %firstYear%-1

$ifi not %farmBranchMotherCows%==on $setglobal nMotherCows 0

scalar p_useIncomeTax / 0 /;
$ifi "%useTax%"=="true" p_useIncomeTax = 1;

$setglobal longRun true
$ifi "%dynamics%" == "Comparative-static" $setglobal longRun false
$ifi "%dynamics%" == "Short run" $setglobal longRun false


$iftheni.compstat "%longRun%"==false
*
* --- discounting and financing etc. are irrelevant in comp-static mode
*
 $$setglobal discountRate 0
 $$SETGLOBAL householdConsumption    0
 $$SETGLOBAL householdConsumptionGR  0
 $$SETGLOBAL outputPriceGrowthRate   0
 $$SETGLOBAL initialLiquidity        0
 $$SETGLOBAL DiscountRate            0
 $$SETGLOBAL intLiquidRate           0

 $$setglobal credit2YIntRate  0
 $$SETGLOBAL credit5YIntRate  0
 $$SETGLOBAL credit10YIntRate 0
 $$SETGLOBAL credit20YIntRate 0

 $$evalglobal lastFutureYear %firstYear%
 $$evalglobal firstYearCalc  %firstYear%
 $$evalglobal LastYearCalc   %firstYear%
 $$evalglobal oldYear        %firstYear%
 $$evalglobal lastOldYear    %firstYear%
 $$evalglobal firstYearM1    %firstYear%

$$else.compStat

 $$evalglobal oldYear        1980


$$endif.compstat
$ifi "%dynamics%" == "Comparative-static"
*

    set tFut "old and new years"          / mean,%oldYear%*%lastFutureYear% /;
    alias(tFut,tFut1);

    set tAll(tFut) "old and new years"    / mean,%oldYear%*%lastYearCalc% /;

    set told(tall) "old years"            / %oldYear%*%lastOldYear% /;

    set t(tall)    "simulation years"     / %firstYearCalc%*%lastYearCalc% /;
    alias(t,t1,t2);


    set tBefore(t)   "Optimization period starts in t+2 with full program" /  %firstYearCalc%*%firstYearM1% /;

    set tCur(t)      "Optimization period starts in t+2 with full program" /  %firstYear%*%lastYear% /;

    set tFull(t)     "Optimization period starts in t+2 with full program" /  %firstYear%*%lastYearCalc% /;


   parameter p_year(tFut); p_year(tFut) = %oldyear%-1 + tFut.pos;

   $$setglobal nCur nCur
   $$setglobal nCur1 nCur1


$iftheni.sp not "%stochProg%"=="true"
*
*  --- dummy implementation of SP frameworK
*      there is one universal node, i.e. that is the deterministic version
*

   set n "Decision nodes in tree" / " " /;
   set t_n(t,n) "Link betwen year and decision node";
   t_n(t," ") = YES;

   set anc(n,n) "Is the second node the node before first one?";
   anc(" "," ") = YES;

   set isNodeBefore(n,n) "Is the second node before first one?";
   isNodeBefore(" "," ") = YES;

   set sameScen(n,n) "The two nodes belong to the same scenario";
   sameScen(" "," ") = YES;

   set leaves(n) / " " /;


   parameter p_probN(n);
   p_probN(" ") = 1;

$else.sp

   $$evalglobal nt %lastYear%-%firstYear%+1
   $$ifi "%dynamics%" == "Comparative-static" $setglobal nt 20
   $$evalGlobal nNode (%nt%-1) * %nOriScen% + 1
*
*  --- sets and parameters are population in coeffgen/stochProg.gms
*
   set n /n1*n%nNode%/;
   set t_n(t,n) "Link betwen year and decision node";
   set anc(n,n) "Is the second node the node before first one?";
   set isNodeBefore(n,n) "Is the second node before first one?";
   set sameScen(n,n) "The two nodes belong to the same scenario";
   set leaves(n);
   parameter p_probN(n);

   singleton set firstLeave(n);
   alias(firstLeave,firstLeave1);
   $$ifi "%dynamics%" == "Comparative-static" $setglobal nCur  firstLeave
   $$ifi "%dynamics%" == "Comparative-static" $setglobal nCur1 firstLeave1



$endif.sp

 set nCur(n);
 nCur(n)      = YES;
 alias(nCur,nCur1,nCur2);


 parameter p_randVar(*,n);
 alias(n,n1,n2);

 set taxSteps / taxStep1*taxStep9 /;
$ifi %incomeTax%==None parameter p_taxesNone(taxSteps,*); option kill=p_TaxesNone;

$ifthen.appl %LowNH3ApplObligatory% == true

* --- ONLY TEMPORARY needed: set "tNotLowAppA" for period from first year till year when low application technique becomes obligatory


    $$evalglobal lastyearbroadcastA  %arableYearLowEmissionImplementation%-1
    $$evalglobal lastyearbroadcastG  %grassYearLowEmissionImplementation%-1

    set tNotLowAppA(t) /%firstyear% *  %lastyearbroadcastA% /
    set tNotLowAppG(t) /%firstyear% *  %lastyearbroadcastG% /

    set tLowAppA(t) "set for year in which low NH3 application technique is obligatory for manure on arable land" /%arableYearLowEmissionImplementation% * %lastYear%/
    set tLowAppG(t) "set for year in which low NH3 application technique is obligatory for manure on grassland"   /%grassYearLowEmissionImplementation% * %lastYear%/

$endif.appl

  scalar p_cardTcur; p_cardTCur = card(tCur);

  scalar p_prolongLen;
  p_prolongLen = smax(tFull,p_year(tFull)) - smax(tCur,p_year(tCur));

  scalar p_shortRun "Flag, if 1=short run solution";

  scalar p_liquid "Flag, if 1 = liquidation of assets" / 1 /;


  scalar p_compStatHerd "Flag, if 1 = no dynamics in herds" / 0 /;

  scalar p_nCows       "Number of cows derived from GUI";
  scalar p_nFattners   "Number of fattners derived from GUI";
  scalar p_nSows       "Number of sows derived from GUI";
  scalar p_nMotherCows "Number of mother cows derived from GUI";
  scalar p_nBulls      "Number of bulls derived from GUI";
  scalar p_nHeifs      "Number of heifers derived from GUI";
  scalar p_nCalves     "Number of calves derived from GUI";
  scalar p_nFattners   "Number of fattners derived from GUI";
  scalar p_nArabLand   "Number of hectares arable land from GUI";
  scalar p_nGrasLand   "Number of hectares gras land from GUI";
  scalar p_nPastLand   "Number of hectares pasture land from GUI";
  scalar p_nTotLand    "Number of total hectares from GUI";
  scalar p_totalLand   "Number of total hectares derived from differnt GUI settings, incl. landscape elements"
  scalar p_landscapeElements "Number of landscape elements in ha from GUI";
*
*  --- short run flag
*
  p_shortRun = 1 $ (%lastYear% eq %firstYear% );
*
*  --- liquidation flag
*
  p_liquid $ (%lastYear% eq %firstYear% )   = 0;

$ifi "%dynamics%" == "Comparative-static" p_liquid = 0;
$ifi "%dynamics%" == "Comparative-static" p_compStatHerd = 1;

 p_prolongCalc $ p_shortRun = 0;



$if not setGlobal timeResolutionInv  $setGlobal timeResolutionInv 2
$evalglobal timeResolutionInv round(%timeResolutionInv%)

$if not setGlobal timeResolutionFeed $setGlobal timeResolutionFeed 2
$evalglobal timeResolutionFeed round(%timeResolutionFeed%)


 set hor "Investment horizons"/
       short   "10 years lifetime"
       middle  "15 years lifetime"
       long    "30 years lifetime"
 /;
 alias(hor,hor1);



  set climateZone "German climate zone as defined by KTBL" / cz1*cz12 /;
  set curClimateZone(climateZone);


  set depth "soil depth" / top     "0-30"
                           medium  "0-60"
                           deep    "0-90" /;

  alias(depth,depth1);


  set m "months in each year" / JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC /;
  alias(m,m1,m2);

  parameter p_daysPerMonth(m) / JAN 31, FEB 28, MAR 31, APR 30, MAY 31, JUN 30,
                                JUL 31, AUG 31, SEP 30, OCT 31, NOV 30, DEC 31 /;


  set labPeriod "Two-weekly Labour periods as defined by KTBL for field operations"
   /  jan1,jan2,
      feb1,feb2
      mar1,mar2,
      apr1,apr2,
      may1,may2,
      jun1,jun2,
      jul1,jul2,
      aug1,aug2,
      sep1,sep2,
      oct1,oct2,
      nov1,nov2
   /;


  set labPerSum "Aggregate of the KTBL labour periods over winter and march, otherwise identical"
      / winter,
        mar,
        may1,may2,
        jun1,jun2,
        jul1,jul2,
        aug1,aug2,
        sep1,sep2,
        oct1,oct2
      /;
  alias(labPerSum,labPerSum1);

  set labPeriod_to_month(labPeriod,m) /
      (jan1,jan2).jan
      (feb1,feb2).feb
      (mar1,mar2).mar
      (apr1,apr2).apr
      (may1,may2).may
      (jun1,jun2).jun
      (jul1,jul2).jul
      (aug1,aug2).aug
      (sep1,sep2).sep
      (oct1,oct2).oct
      (nov1,nov2).nov
  /;

  set labPerSum_ori(labPerSum,labPeriod);
  labPerSum_ori(labPerSum,labPeriod) $ sameas(labPerSum,labPeriod)        = YES;
  labPerSum_ori("mar","mar1") = YES;
  labPerSum_ori("mar","mar2") = YES;
  labPerSum_ori("Winter",labPeriod) $ (not sum(sameas(labPerSum1,labPeriod),1)) = YES;

  set labReqLevl / rf2,rf3 /;


  set w_m(m) "winter months in each year" / JAN,FEB,MAR,OCT,NOV,DEC /;
  set s_m(m) "winter months in each year" / APR,MAY,JUN,JUL,AUG,SEP /;

$onempty
  set inputsGDX,crops_and_prodsGDX,summerHarvestGDX,cashcropsGDX,no_cashcropsGDX,arablecropsGDX,catchcropsGDX

   $$gdxin "%datDir%/%cropsFile%.gdx"
     $$load crops_and_prodsGDX=crops
     $$load summerHarvestGDX=summerHarvest
     $$load cashcropsGDX=cashCrops
     $$load no_cashcropsGDX=no_cashcrops
     $$load arablecropsGDX=arableCrops
     $$load catchcropsGDX=ccCrops
     $$load inputsGDX=inputs
      $$iftheni.data "%database%"=="KTBL_database"
        sets inputsKTBL
             ioCategories "input categories"
             inputs_category(*,ioCategories) "list of all inputs and the respective category" ;
      $$load inputsKTBL=inputsGDX,ioCategories, inputs_category
     $$endif.data
   $$gdxin

   set set_crops_and_prods "crop and products of the same name" / set.cashcropsGDX
                                                                  Idle             "Idling arable land"
                                                               /;

   set cropsResidues_prods "Residues produced by crops which can be sold"


   $$gdxin "%datDir%/%cropsFile%.gdx"
      $$LOAD cropsResidues_prods
   $$gdxin

$$iftheni.pmp "%pmp%"=="true"
  $$setglobal nDep dep3
$$else.pmp
  $$setglobal nDep dep50
$$endif.pmp

  set cropShareLevl "Steps in yield depression function" /  dep1*%nDep% /;

  parameter p_mDist(t,m,t1,m1) "Difference in months between year t month m and year t1 and m1";

  set Mdist /d1*d240/;
  set calvingMonths(mDist);

  p_mDist(t,m,t1,m1) = (p_year(t1)-p_year(t)) * 12 + (m1.pos - m.pos);

  set set_crop_prods "crop products" / set.set_crops_and_prods
                                       $$iftheni.feedCatchCrop %feedCatchCrop%  == "true"
                                         CCclover
                                       $$endif.feedCatchCrop
                                       set.cropsResidues_prods    /;

  set set_crops "crops" /    set.no_cashcropsGDX
                             idleGras  "Idling gras land"
                             set.set_crops_and_prods
  $$ifi defined grasTypes    set.grasTypes

  /;

   set operation "Field operators as defined by KTBL"      /set_operation/;

  set soilNutSour "Different diffus N sources entering fertilizing"
      / Nmin,NAtmos,Ndepos,NasymFix / ;

  set fertSour "Different sources and nutrient need in Nutbalcrop"
      /NBcropNeed,NBOverNeed,NBbasNut,NBminFert,NBminFertLoss,NBmanure,NBmanureloss,NBpasture,NBpastureLoss,
          NBlegumes,NBlegumesSelf,NBvegetables,NBseeds,NBresiduen,NBdenitrification,NBleaching,NBSoilDelivery,NBPlantSenescence  /;

   set curFertSour(fertSour) ;

* --- Switches elements depending on branch/manure on and off - NEEDS RELOCATION IN CODE [TK 17.12.2020]

    curFertSour("NBcropNeed")    = YES;
    curFertSour("NBbasNut")      = YES;
    curFertSour("NBminFert")     = YES;
    curFertSour("NBminFertLoss") = YES;
    curFertSour("NBOverNeed")    = YES;
    curFertSour("NBlegumes")     = YES;
    curFertSour("NBvegetables")  = YES;

  $$iftheni.fert %Fertilization% == OrganicFarming
    curFertSour("NBlegumesSelf")     = YES;
    curFertSour("NBseeds")           = YES;
    curFertSour("NBresiduen")        = YES;
    curFertSour("NBdenitrification") = YES;
    curFertSour("NBleaching")        = YES;
    curFertSour("NBSoilDelivery")    = YES;
    curFertSour("NBPlantSenescence") = YES;
  $$endif.fert


$ifthen.man %manure% == true
    curFertSour("NBmanure") = YES;
    curFertSour("NBmanureloss") = YES;
$endif.man

$iftheni.dh "%cattle%" == "true"
    curFertSour("NBpasture") = YES;
    curFertSour("NBpastureLoss") = YES;
$endif.dh
*
* --- read sets related to tillage systems / crop rotations
*

* -----------------------------------------------------------------------------------
*
*   Herd definitions
*
*
* -----------------------------------------------------------------------------------

    set set_sumHerds(*)  /
        $$ifi "%cattle%"=="true"              cows,heifsSold,bullsSold,heifsBought,remonte,remonteMotherCows,maleCattle,femaleCattle,slgtCows
        $$ifi "%farmbranchSows%"=="on"        sows,oldSows,youngPiglets,piglets,slgtsows,youngsows
        $$ifi "%farmbranchFattners%"=="on"    pigletsBought,earlyFattners,midFattners,lateFattners,Fattners,pigFattened
    /;


$iftheni.cattle "%cattle%"=="true"
*
*
*  --- The label 20 to 50 expresses milk in 200 kg steps
*      all female herds carry a genetic "potential" (20 =4000 kg cow)
*
   set sort_herds / cows,remonte,remonteMotherCows,heifs,bulls,fCalvsRais,fCalvsSold,mCalvsRais,mCalvsSold /;

   $$ifi not set milkYield $setglobal milkYield 85
   set set_cows        / "cows%MilkYield%00_short","cows%MilkYield%00_long" /;
   set set_mCows       / motherCow /;
   set set_slgtCows    / slgtCowsShort,slgtCowsLong,slgtMotherCows  /;
   set set_remonte     / remonteMotherCows,remonte /;

   set breed           / %BasBreed%
                         $$ifi "%farmBranchMotherCows%"=="on" %motherCowBreed%
                         $$ifi "%crossBreeding%"=="true"  %CrossBreed%
                       /;

   $$iftheni.beef "%farmBranchBeef%"=="on"

   set set_bulls       / set.%BasBreed%_m

                         $$ifi "%farmBranchMotherCows%"=="on" set.%motherCowBreed%_m
                         $$ifi "%crossBreeding%"=="true"  set.%CrossBreed%_m
                        /;

   set set_bullsBought / set.%BasBreed%_m_bought
                         $$ifi "%farmBranchMotherCows%"=="on" set.%motherCowBreed%_m_bought
                         $$ifi "%crossBreeding%"=="true"  set.%CrossBreed%_m_bought
                       /;
   set set_bullsSold   / set.%BasBreed%_m_sold
                         $$ifi "%farmBranchMotherCows%"=="on" set.%motherCowBreed%_m_sold
                         $$ifi "%CrossBreeding%"=="true"  set.%CrossBreed%_m_sold
                       /;

      set set_males       / set.set_Bulls,set.set_bullsBought /;

   $$endif.beef


   set set_heifs       / set.%BasBreed%_f
                         $$iftheni.cow "%cowHerd%"=="true"
                         $$ifi "%farmBranchMotherCows%"=="on" set.%motherCowBreed%_f
                         $$ifi "%crossBreeding%"=="true"  set.%CrossBreed%_f
                         $$endif.cow
                        /;
   set set_heifsBought / set.%BasBreed%_f_bought
                         $$iftheni.cow "%cowHerd%"=="true"
                         $$ifi "%farmBranchMotherCows%"=="on" set.%motherCowBreed%_f_bought
                         $$ifi "%crossBreeding%"=="true"  set.%CrossBreed%_f_bought
                         $$endif.cow
                       /;
   set set_heifsSold   / set.%BasBreed%_f_sold
                         $$iftheni.cow "%cowHerd%"=="true"
                            $$ifi "%farmBranchMotherCows%"=="on" set.%motherCowBreed%_f_sold
                            $$ifi "%crossBreeding%"=="true"      set.%CrossBreed%_f_sold
                         $$endif.cow
                       /;



   set set_fcalvs      / fCalvsSold,fCalvsRais,fCalvsRaisSold /;
   set set_mCalvs      / mCalvsSold,mCalvsRais,mCalvsRaisSold /;
   set set_calvs       / set.set_fCalvs,fCalvsRaisBought,set.set_mCalvs,mCalvsRaisBought /;
   set set_calvsBought / fCalvsRaisBought,mCalvsRaisBought /;

   set set_herds /
                  set.set_cows
                  set.set_mCows
                  set.set_calvs
                  set.set_heifs,heifs
                  set.set_heifsSold
                  set.set_heifsBought
                  set.set_slgtCows
                  set.set_remonte
     $$iftheni.beef "%farmBranchBeef%"=="on"
                  set.set_bulls,bulls
                  set.set_bullsBought,bullsBought
                  set.set_bullsSold,bullsSold

     $$endif.beef

   /;

$endif.cattle


   set set_herds /
                  set.set_sumHerds
   /;
* -----------------------------------------------------------------------------------
*
*   Production activities and farm branches
*
* -----------------------------------------------------------------------------------

   set acts /
       set.set_herds
       set.set_crops
       cow7800,cow9800,cowHigh
    /;


   set possActs(acts);

   set branches /
       cap         "Work required to claim CAP premiums"
       farm
       cashCrops
    /;

   set branches_to_acts(branches,acts) /
       cashCrops.(set.cashcropsGDX)
   /;

   set branchLink_to_acts(branches,acts);

   set regPar "Coefficient to define labour management need for branches" / const,slope /;
*
*  --- crops and their relation to land types
*
   set crops(acts) /set.set_crops /;
   alias(crops,crops1,crops2);


   set curCrops(crops) "Crops currently in model";
   set curArabCrops(crops) "Crops currently in model";

  set till        / plough,minTill,noTill,org,bales,silo,hay,hayM,graz,grasM /;
  alias(till,till1);

  set sys     / conv,org /;
  alias(sys,sys1);

  set curSys(sys);

  set sys_till(sys,till)  / conv.(plough,minTill,noTill), org.org /;
  set normalIntens / normal /;
  set set_default_intens  "Default intensities" /fert80p,fert60p,fert40p,fert20p/ ;
  set set_HeynOlfs_intens "Intensities based on Heyn and Olfs" /f90p,f80p,f70p,f60p /;

  set oriIntens      / normal   "Full N fertilization"

     $$ifi "%intensoptions%"=="Default"   set.set_default_intens
     $$ifi "%intensoptions%"=="Heyn_Olfs" set.set_HeynOlfs_intens

     $$ifthen.gras defined grasTypes
                    bales
                    hay
                    silo
                    Graz
                    hayM
                    grasM
     $$endif.gras
                    /;
  set intens      / set.oriIntens /;
  set lower(intens)/  /;
  set veryLow(intens)/  /;

  alias(intens,intens1);

  set idle(crops) /     idle
                        idleGras
  /;




*--- subsets of crops, e.g. important crop data, emission data
  set
   cropsGDX(crops), cere(crops), rootCrops(crops), leg(crops), maize(crops), rapeseed(crops)
   maizSilage(crops), GPS(crops), hay(crops), vegetables(crops), grain_maize(crops), maizCCM(crops),
   grain_wheat(crops),grain_barley(crops),grain_oat(crops),grain_rye(crops),OtherGrains(crops), grainleg(crops)
   wintercere(crops),summercere(crops),other(crops),potatoes(crops),sugarbeet(crops),wintercrops(crops)
;

   $$gdxin "%datDir%/%cropsFile%.gdx"
     $$load cropsGDX=crops
     $$load cere rootCrops leg maize rapeseed maizSilage GPS vegetables maizCCM
     $$load grain_maize grain_Wheat grain_Barley grain_Oat grain_rye OtherGrains grainleg hay
     $$load wintercere summercere other potatoes sugarbeet wintercrops
   $$gdxin

 
$batinclude '%datDir%/%cropsGmsFile%.gms' decl

   set SummerHarvest(crops)
   /
       set.summerHarvestGDX
   /;

  set mainCrops(crops) "crops which are tested for non-zero yield coefficient";
  mainCrops(crops)      = yes;
  mainCrops(catchCrops) = no;

 set NoCashcrops(crops) "crops which can not be sold";
     NoCashcrops(crops) $sum(no_cashcropsGDX, sameas(crops,no_cashcropsGDX)) = YES;

  set fertCrops(crops) "crops with nutrient balances";
      fertCrops(crops)      = yes;

      set tia "Reporting sets in exploiter\store_res.gms for crops" /"", set.till /;
      set tia /set.intens /;
* -----------------------------------------------------------------------------
*
*    Set related to grassland management
*
* -----------------------------------------------------------------------------

$ifthen.gras defined grasTypes

  set gras(crops)       / set.grasTypes /;
  set grassCrops(crops) / IdleGras,set.grasTypes  / ;
  set past(crops);
  set mixPast(crops)    / set.grasTypes /;

  set pastOutputs(grasOutputs) / earlyGraz,middleGraz,lateGraz /;
  set noPastOutputs(grasOutputs) / earlyGrasSil,middleGrasSil,lateGrasSil,hay, hayM, grasM /;

  set grasCrops_outputs(crops,grasOutputs);
      grasCrops_outputs(grassCrops,grasOutputs)$(sum(m,p_grasattr(grassCrops,grasoutputs,m))) = YES;

  past(gras) $ (   sum( (grasTypes,pastOutputs,m) $ sameas(gras,grasTypes),
                                                         p_grasAttr(grasTypes,pastOutputs,m))
                 $ (not sum( (grasTypes,noPastOutputs,m) $ sameas(gras,grasTypes),
                                   p_grasAttr(grasTypes,noPastOutputs,m)))) = YES;

  gras(crops)  $ sum( (grasTypes,pastOutputs,m) $ sameas(crops,grasTypes),
                                                           p_grasAttr(grasTypes,pastOutputs,m)) = no;

  set rotGrazTypes(p_grasAttrGui_dim3) /gra8,gra9,gra10/;
  set rotationalGraz(crops);
  rotationalGraz(crops) = NO;
  rotationalGraz(past)
    $ sum((grasTypes,rotGrazTypes)
      $ (sameas(past,grasTypes)
      $ (sum(gras_grasN(grasTypes,rotGrazTypes),1))),1) = YES;

  mixPast(crops) $(sum(past $sameas(crops,past),1)) = no;
  mixPast(crops) $(sum(gras $sameas(crops,gras),1)) = no;


  set pastCrops(crops)/set.grasscrops/;
      pastCrops(crops) $(sum(gras $sameas(crops,gras),1)) = no;
      pastCrops(crops) $sameas(crops,"idlegras") = no;

$else.gras

       set grassCrops(crops) //;
       set gras(crops) //;
       set past(crops) //;
       set mixpast(crops) //;

$endif.gras


  set landType /
      arab
      gras
      past
  /;


  set crops_t_landType(crops,landType);

*
* --- all crops on arable, exemptions: idling gras and grazing
*
  crops_t_landType(crops,"arab")      = yes;
  crops_t_landType("idleGras","arab") = no;
  crops_t_landType(grassCrops,"arab") = no;
*
* --- all types of grassland management on permanent grasslnad
*
  crops_t_landType(grassCrops,"gras")  = yes;
*
* --- only pasture on grasslands where machine work is impossible
*
  crops_t_landType(past,"past")         = yes;
  crops_t_landType(gras,"past")         = no;
  crops_t_landType(mixPast,"past")      = no;
  crops_t_landType("idleGras","past")   = yes;

  set arabCrops(crops);
  arabCrops(crops) $ crops_t_landType(crops,"arab") = YES;
  arabCrops(crops) $ crops_t_landType(crops,"gras") = No;

  set grasCrops(crops);
  grasCrops(crops) $ crops_t_landType(crops,"gras") = YES;

  set arablecrops(crops)/ set.arablecropsGDX,set.catchcrops/;




 set cropsResidueRemo(crops) "Crops which generally allow the removal of residues";

 $$gdxin "%datDir%/%cropsFile%.gdx"
   $$load cropsResidueRemo
 $$gdxin

  set soil  /
              l "light",
              m "middle",
              h "heavy"
              /;
  alias(soil,soilType,soil1);



$iftheni.nPlot %nPlot% == 1

    $$evalglobal maxPlot card(soil)*card(landType)
    set plot / plot1*plot%maxPlot% /;
    
$$iftheni.PlotEndo not "%landEndo%" == "Land endowment per plot"

set plotOutNO3zone(plot)  /plot1, plot4, plot7/;
set plotInNO3zone(plot)  /plot2, plot5, plot8/;

$$endif.PlotEndo

$else.nPlot

    set plot / plot1*plot%nPlot% /;

$endif.nPlot
  alias(plot,plot1);

  set plot_soil(plot,soil);

  set plot_lt_soil(plot,*,soil);

  set plot_landType(plot,landType);

  set soil_plot(soil,plot);
  set c_p_t_i(crops,plot,till,intens) "Allowed combination of crops, plot, tillage type and intensity level";

  set monthHarvestBlock(crops,m) ;

* -----------------------------------------------------------------------------------
*
*   Sets relating to the herd module
*
* -----------------------------------------------------------------------------------

$$iftheni.herd "%herd%"=="true"


   set feedRegime(*) / /;
   alias(feedRegime,feedRegime1);

   set duevHerds(acts)  / set.set_herds,cow7800,cow9800,cowHigh /;

   set herds(duevHerds) / set.set_herds /;
   alias(herds,herds1,herds2);

   set possHerds(herds) "Herds possible in current farm";

   set sumHerds(herds)    /
        set.set_sumHerds
   /;
   alias(sumHerds,sumherds1);

$endif.herd

$$iftheni.cattle "%cattle%"=="true"

   set branches /
       $$ifi "%farmBranchDairy%"=="on"       dairy
       $$ifi "%farmBranchMotherCows%"=="on"  motherCows
       $$ifi "%farmBranchBeef%"=="on"        beef
   /;

   set animBranches(branches) /
       $$ifi "%farmBranchDairy%"=="on"       dairy
       $$ifi "%farmBranchMotherCows%"=="on"  motherCows
       $$ifi "%farmBranchBeef%"=="on"        beef
    /;

   set branches_to_acts(branches,acts) /
       $$ifi "%farmBranchDairy%"=="on"       dairy.cows
       $$ifi "%farmBranchMotherCows%"=="on"  motherCows.motherCow
       $$ifi "%farmBranchBeef%"=="on"        beef.bulls
   /;
*
*  --- take arable crops used for fodder production on arabale
*      land from cashCrops (such that the cash crop branch can be
*      abandoned, freeing management labour)
*

   branches_to_acts("cashCrops",acts) $sum(sameas(acts,maizSilage),1) = NO;
   branches_to_acts("cashCrops",acts) $sum(sameas(acts,GPS),1)        = NO;

   set feedRegime /
                                          ""         "Aggregator position for summary herds without feed regime differentiation"
                                          fullGraz   "Full grazing, no stable time"
                                          partGraz   "Partial grazing, over night in stables"
                                          noGraz     "No grazing"
   /;

   set dummFeedRegime "Not used, but label needed" / normFeed /;


   set cowTypes / HF,SI,MC /;

   set feedRegimeCattle(feedRegime) /
       fullGraz   "Full grazing, no stable time"
       partGraz   "Partial grazing, over night in stables"
       noGraz     "No grazing"
   /;
   set grazRegime(feedRegime) /
       fullGraz   "Full grazing, no stable time"
       partGraz   "Partial grazing, over night in stables"
   /;


  set dummyBullsBought / bullsBought /;

  set sumHerds(herds)    /
        fCalvsRais,fCalvsSold,mCalvsRais,mCalvsSold,heifs,mCalvsRaisBought,fCalvsRaisBought
        motherCow
        $$ifi "%farmBranchBeef%"=="on" bulls,bullsBought
   /;

  set sumHerdsY(sumHerds) "Herds aggregated from monthly to yearly resolution" /
      slgtCows,heifsSold,heifsBought,
      $$ifi "%farmBranchBeef%"=="on" bullsBought,bullsSold,
      fCalvsSold,mCalvsSold,remonteMotherCows/;


  set cows(herds)     "All cows"        / set.set_Cows,set.set_mCows /;
  set dcows(cows)     "Dairy cows with different lactations length"  / set.set_Cows /;
  alias(dcows,dcows1)
  set mcows(cows)     "Mother cows"  / set.set_mCows /;
  alias(mcows,mcows1)

  set aggHerds(sumHerds) /

                           cows,
                           heifs,
                           femaleCattle
           $$iftheni.bulls "%farmBranchBeef%"=="on"
                           bulls
                           maleCattle
           $$endif.bulls
                            /;

  set slgtCows(herds) "slaughtered cows"  / set.set_slgtCows /;
  alias(cows,cows1);


  set fCalvsSold(herds)  "Female calves sold to market"    / fcalvsSold /;
  set calvsSold(herds)   "Calves sold to market" /fcalvsSold,mCalvsSold/;
  set fCalvsRais(herds)  "Female calves raised to 300 kgt" / fCalvsRais /;
  set calvsRaisSold(herds) "Raise calves sold to market" /fCalvsRaisSold, mCalvsRaisSold/;
  set calvs(herds) / set.set_calvs /;
  set calvesBought(calvs) /fCalvsRaisBought,mCalvsRaisBought/;
  set fcalvs(herds) /set.set_fcalvs/;
  set mcalvs(herds) /set.set_mcalvs/;
  set calvsRais(herds)   "Calves older than 7 weeks raised to GUI settings (default 180kg)" /fCalvsRais,mCalvsRais /;
  alias(calvsRais,calvsRais1);

  $$iftheni.heifs "%cowHerd%"=="true"

    set herds_cowTypes(cows,cowTypes);
    herds_cowTypes(dcows,"%cowType%")       = YES;
    herds_cowTypes(mcows,"%motherCowType%") = YES;

  set heifs(herds)       "Heifers for herd replacement of specific genetic potential"/ set.set_heifs  /;
    alias(heifs,heifs1,heifs2);
  set heifsBase(heifs)   /set.%BasBreed%_f/;

  set heifsSold(herds)   "Breeding heifers sold of specific genetic potential"/ set.set_heifsSold  /;
  alias(heifsSold,heifsSold1);

  set heifsBought(herds) "Breeding Heifers bought of specific genetic potential"/ set.set_heifsBought  /;

    $$iftheni.base defined p_heifsAttrGuiBas

       set heifsSoldHF(heifsSold) / set.%BasBreed%_f_sold /;
       set heifsBoughtHF(heifsBought) / set.%BasBreed%_f_bought /;

    set set_heifBeef_prods_HF / heifMeat_Type1_%basBreed%,
                                heifMeat_Type2_%basBreed%,
                                heifMeat_Type3_%basBreed%,
                                heifMeat_Type4_%basBreed%,
                                heifMeat_Type5_%basBreed%,
                                heifMeat_Type6_%basBreed%
                           /;

    $$endif.base


    $$iftheni.mc "%farmBranchMotherCows%"=="on"

       set heifsMC(heifs)  /set.%motherCowBreed%_f/;
       set heifsSoldMC(heifsSold)     / set.%motherCowBreed%_f_sold /;
       set heifsBoughtMC(heifsBought) / set.%motherCowBreed%_f_bought /;

       set set_heifBeef_prods_MC / heifMeat_Type1_%motherCowBreed%,
                               heifMeat_Type2_%motherCowBreed%,
                               heifMeat_Type3_%motherCowBreed%,
                               heifMeat_Type4_%motherCowBreed%,
                               heifMeat_Type5_%motherCowBreed%,
                               heifMeat_Type6_%motherCowBreed%
                               /;
    $$endif.mc

    $$iftheni.cb "%CrossBreeding%"=="true"

        set heifsCross(heifs) /set.%CrossBreed%_f/;
        set heifsSoldSI(heifsSold) / set.%CrossBreed%_f_sold /;
        set heifsBoughtSI(heifsBought) / set.%CrossBreed%_f_bought /;

        set set_heifBeef_prods_SI / heifMeat_Type1_%crossBreed%
                                heifMeat_Type2_%crossBreed%
                                heifMeat_Type3_%crossBreed%
                                heifMeat_Type4_%crossBreed%
                                heifMeat_Type5_%crossBreed%
                                heifMeat_Type6_%crossBreed%
                              /;

    $$endif.cb

    set sum_herds(sumHerds,herds) /
         heifs.(set.heifs)
         heifsBought.(set.heifsBought)
         heifsSold.(set.heifsSold)
         femaleCattle.(set.heifs,set.heifsBought,set.heifsSold)
    /;
  $$endif.heifs


  set remonte(herds)     "Breeding heifers sued for herd replacement of specific genetic potential"/ set.set_remonte  /;

  set adults(herds) / set.cows
      $$ifi defined heifs set.heifs
   /;


 $$iftheni.bulls "%farmBranchBeef%"=="on"

  set bulls(herds)       "Bulls for fattening of specific genetic potential" / set.set_bulls /;
  set bullsBase(bulls)  /set.%BasBreed%_m/;

  set bullsBought(herds) "Fattened bulls bought of specific genetic potential" / set.set_bullsBought /;

  set bullsSold(herds)   "Fattened bulls sold of specific genetic potential" / set.set_bullsSold /;

  set sum_herds(sumHerds,herds) /
                                 bulls.(set.bulls)
                                 bullsBought.(set.bullsBought)
                                 bullsSold.(set.bullsSold)
                                 maleCattle.(set.bulls,set.bullsbought,set.bullsSold)
                               /;

  set adults(herds) / set.bulls /;
  alias(bulls,bulls1,bulls2);

    $$ifthen.bas defined p_bullsAttrGuiBas

      set bullsHF(bulls)             / set.%basBreed%_m /;
      set bullsSoldHF(bullsSold)     / set.%basBreed%_m_sold /;
      set bullsBoughtHF(bullsBought) / set.%basBreed%_m_bought /;

    set set_beef_prods_HF / bullMeat_Type1_%basBreed%,
                            bullMeat_Type2_%basBreed%,
                            bullMeat_Type3_%basBreed%,
                            bullMeat_Type4_%basBreed%,
                            bullMeat_Type5_%basBreed%,
                            bullMeat_Type6_%basBreed%
                       /;

   $$endif.bas
   $$iftheni.mc "%farmBranchMotherCows%"=="on"

      set bullsMC(bulls)             / set.%motherCowBreed%_m/;
      set bullsSoldMC(bullsSold)     / set.%motherCowBreed%_m_sold /;
      set bullsBoughtMC(bullsBought) / set.%motherCowBreed%_m_bought /;

      set set_beef_prods_MC / bullMeat_Type1_%motherCowBreed%,
                              bullMeat_Type2_%motherCowBreed%,
                              bullMeat_Type3_%motherCowBreed%,
                              bullMeat_Type4_%motherCowBreed%,
                              bullMeat_Type5_%motherCowBreed%,
                              bullMeat_Type6_%motherCowBreed%
                            /;
   $$endif.mc

   $$iftheni.cb "%crossBreeding%"=="true"

      set bullsCross(bulls)           /set.%CrossBreed%_m/;
      set bullsSoldSI(bullsSold)      / set.%CrossBreed%_m_sold /;
      set bullsBoughtSI(bullsBought)  / set.%CrossBreed%_m_bought /;

      set set_beef_prods_SI  / bullMeat_Type1_%crossBreed%
                               bullMeat_Type2_%crossBreed%
                               bullMeat_Type3_%crossBreed%
                               bullMeat_Type4_%crossBreed%
                               bullMeat_Type5_%crossBreed%
                               bullMeat_Type6_%crossBreed%
                         /;
    $$endif.cb

    branchLink_to_acts("beef",maizSilage)        = YES;
    branchLink_to_acts("beef",GPS)       = YES;
    branchLink_to_acts("beef",calvs)            = YES;
    branchLink_to_acts("beef",grassCrops)       = YES;
 $$endif.bulls


  set sum_herds(sumHerds,herds) /
                                 remonte.(set.remonte)
                                 remonteMotherCows.remonteMotherCows
                                 cows.(set.cows)
                                 slgtcows.(set.slgtCows)

                                 maleCattle.(mCalvsSold,mCalvsRais,mCalvsRaisSold)
                                 femaleCattle.(fCalvsSold,fCalvsRais,fCalvsRaisSold)
                               /;

  $$iftheni.dairy "%farmBranchDairy%"=="on"

      branchLink_to_acts("dairy",maizSilage)      = YES;
      branchLink_to_acts("dairy",calvs)           = YES;
      branchLink_to_acts("dairy","heifs")         = YES;
      branchLink_to_acts("dairy",GPS)             = YES;
      branchLink_to_acts("dairy",grassCrops)      = YES;
  $$endif.dairy

  $$iftheni.mc "%farmBranchMotherCows%"=="on"

      branchLink_to_acts("motherCows",GPS)          = YES;
      branchLink_to_acts("motherCows",maizSilage)   = YES;
      branchLink_to_acts("motherCows",grassCrops)   = YES;

     sum_herds("cows","motherCow")                      = NO;
     sum_herds("motherCow","motherCow")                 = YES;
     sum_herds("remonte","remonteMotherCows")           = no;
     sum_herds("remonteMotherCows","remonteMotherCows") = yes;

  $$endif.mc

  set allBreeds "All possible breeds in the model" /
    " "       "Herds with no breed differentiation, e.g. pigs"
    %basBreed%
   $$if set motherCowBreed %motherCowBreed%
    $$iftheni.cross "%crossBreeding%"=="true"
      %CrossBreed%
    $$endif.cross
  /;


  set breeds(allBreeds) "Current breeds in model as set by user" / set.allBreeds /;

  set curBreeds(breeds);curBreeds(" ") = YES;
  set crossBreeds(breeds);crossBreeds(breeds) = NO;
  set dairyBreeds(breeds);dairyBreeds("%BasBreed%") = YES;
  set remonte_breed(remonte,breeds);
  $$if set motherCowBreed remonte_breed("remonteMotherCows","%motherCowBreed%") = YES;
  remonte_breed("remonte","%basBreed%") = YES;

  $$iftheni.dh "%farmBranchDairy%"=="ON"
  curBreeds("%BasBreed%") = YES;
  $$setglobal crossBreedBase %BasBreed%
  $$elseifi.dh "%farmBranchMotherCows%"=="ON"
      $$setglobal crossBreedBase %motherCowBreed%
  $$endif.dh

$$iftheni.mc "%farmBranchMotherCows%"=="ON"
 curBreeds("%motherCowBreed%") = YES;
 dairyBreeds("%motherCowBreed%") = YES;
$$elseifi.mc "%farmBranchBeef%"=="ON"
 curBreeds("%BasBreed%") = YES;
$$endif.mc

$$iftheni.cross "%crossBreeding%"=="true"
      curBreeds("%crossBreed%") = YES;
      dairyBreeds("%crossBreed%") = YES;
      crossBreeds("%CrossBreed%") = YES;
$$endif.cross


  set herds_breeds(herds,breeds);

  set dairyHerd(herds) /
    set.calvs
    set.dcows
*
*   ---- heifers (generated names from interface)
*
    set.%basBreed%_f,
    set.%basBreed%_f_bought
    set.%basBreed%_f_sold
  /;

  $$iftheni.mc "%farmBranchMotherCows%"=="ON"

    set mcHerd(herds) "Mothercow herds" /
       set.calvs
       set.mcows
*
*      --- heifers (generated names from interface)
*
       set.%motherCowBreed%_f,
       set.%motherCowBreed%_f_bought,
       set.%motherCowBreed%_f_sold,
*
*      --- bulls(generated names from interface)
*
       set.%motherCowBreed%_m,
       set.%motherCowBreed%_m_bought,
       set.%motherCowBreed%_m_sold
    /;
  $$endif.mc

  $$iftheni.cross "%crossBreeding%"=="true"

    set crossHerd(herds) /
       set.calvs
*
*      --- heifers (generated names from interface)
*
       $$iftheni.cow  "%cowHerd%"=="on"
          set.%crossBreed%_f
          set.%crossBreed%_f_bought
          set.%crossBreed%_f_sold
       $$endif.cow
*
*      --- bulls(generated names from interface)
*
       $$iftheni.beef "%farmBranchBeef%"=="on"
          set.%crossBreed%_m
          set.%crossBreed%_m_bought
          set.%crossBreed%_m_sold
       $$endif.beef
    /;
  $$endif.cross

  $$ifi "%farmBranchBeef%"=="on" set bullsHerd(herds) / set.%basBreed%_m, set.%basBreed%_m_bought, set.%basBreed%_m_sold /;


  $$iftheni.dh "%farmbranchDairy%"=="on"

    herds_breeds(dairyHerd,"%BasBreed%") = YES;
    herds_breeds("cows","%BasBreed%") = YES;
    herds_breeds("heifs","%BasBreed%") = YES;
    herds_breeds("remonte","%BasBreed%") = YES;
    herds_breeds("slgtCowsShort","%BasBreed%") = YES;
    herds_breeds("slgtCowsLong","%BasBreed%") = YES;
    herds_breeds("heifsbought","%BasBreed%") = YES;
    herds_breeds("HeifsSold","%BasBreed%")     = YES;

   $$iftheni.cross "%crossBreeding%"=="true"
    herds_breeds(crossHerd,"%crossBreed%") = YES;
   $$endif.cross

  $$endif.dh

  $$iftheni.mc "%farmBranchMotherCows%"=="ON"

    herds_breeds(mcHerd,"%motherCowBreed%") = YES;
    herds_breeds("slgtMotherCows","%motherCowBreed%") = YES;
    herds_breeds("remonteMotherCows","%motherCowBreed%") = YES;
    herds_breeds("heifsbought","%motherCowBreed%") = YES;
    herds_breeds("bulls","%motherCowBreed%") = YES;
    herds_breeds("bullsSold","%motherCowBreed%") = YES;
     herds_breeds("HeifsSold","%motherCowBreed%"        ) = YES;

   $$iftheni.cross "%crossBreeding%"=="true"

    herds_breeds(crossHerd,"%crossBreed%") = YES;
    herds_breeds("bulls","%crossBreed%") = YES;
    herds_breeds("bullsSold","%crossBreed%") = YES;
        herds_breeds("heifsSold","%crossBreed%")   = YES;
    herds_breeds(bullsBoughtSI,"%crossBreed%") = YES;
   $$endif.cross

  $$else.mc

  $$iftheni.beef "%farmBranchBeef%"=="ON"

    herds_breeds(bullsHerd,"%basBreed%") = YES;
    herds_breeds("bulls","%basBreed%") = YES;
    herds_breeds("bullsSold","%basBreed%") = YES;

   $$iftheni.by "%buyCalvs%"=="true"
    herds_breeds(mcalvs,"%basBreed%") = YES;
    herds_breeds("mCalvsRaisBought","%basBreed%") = YES;

   $$endif.by

  $$endif.beef

  $$endif.mc

$else.cattle

  set allBreeds "Current breeds in model as set by user" / "" /;
  set breeds(allBreeds) "Current breeds in model as set by user" / "" /;

$endif.cattle

$iftheni.herd %herd% == true
  set sold_comp_herds(herds,breeds,herds);
  set herds_from_herds(herds,herds,breeds);
  set bought_to_herds(herds,breeds,herds);
$endif.herd

* -----------------------------------------------------------------------------------
*
*   Sets relating to buildings and stables
*
* -----------------------------------------------------------------------------------

$iftheni.herd "%herd%"=="true"

  $$batinclude "%datDir%/%stableFile%.gms" decl

  set stableStyles / "Slatted_floor", "Cubicle_House", "Tie_Stall", "Shed", "Deep_Litter"/;

$endif.herd


* -----------------------------------------------------------------------------------
*
*   sets related to cattle
*
* -----------------------------------------------------------------------------------

$iftheni.cattle "%cattle%"=="true"


  set actHerds(herds,breeds,feedRegime,t,m)          "Indicator set: has the farm a herd of that potential in the year and month?";

  set balHerds(herds) /
      set.fCalvsRais,mCalvsRais,

      $$ifi defined heifs set.heifs,heifsSold,heifsBought,set.heifsBought,set.heifsSold

      set.cows,fCalvsSold,mCalvsSold,mCalvsRaisSold
      remonte,remonteMotherCows,slgtCows

      $$ifi defined bulls set.bulls,set.bullsBought,set.bullsSold

  /;

  $$ifi defined heifs set heifsBal(balHerds) / set.heifs /;

  set herds_from_herds(herds,herds,breeds);
  set bought_to_herds(herds,breeds,herds);

  set stableTypes / milkCow,youngCattle,calves,motherCow/;

  set herd_stableTypes(herds,stableTypes) /
    $$ifi defined bulls (set.bulls,bulls).youngCattle
    $$ifi defined heifs (set.heifs,heifs).youngCattle
    (set.calvs).calves
   /;


  set herd_stableStyle(herds, stableStyles) /



    $$ifi set cowStableInv       (set.dcows)."%cowStableInv%"
    $$ifi set motherCowStableInv (set.mcows)."%motherCowStableInv%"

    $$iftheni.bulls defined bulls

        $$ifi not %cowHerd% == true    (set.bulls,bulls)."%bullsStableInv%"
        $$ifi %cowHerd% == true        (set.bulls,bulls)."%heifersStableInv%"
    $$endif.bulls

    $$iftheni.heifs defined heifs
      (set.heifs,heifs)."%heifersStableInv%"
      (set.calvs)."%calvesStableInv%"
    $$endif.heifs
  /;

  set stables(*) /
         set.set_youngStables
         set.set_cowStables
         set.set_calvStables
         set.set_motherCowStables
                   /;

   set strawStables(stableStyles) / "Cubicle_House", "Tie_Stall", "Shed", "Deep_Litter" /;
   set cowStables(stables) "Stable for dairy cows"  / set.set_cowStables /;
   alias(cowStables,cowStables1,cowStables2);

   set motherCowStables(stables) "Stable for mother cow" / set.set_motherCowStables /;

   set calvStables(stables)  "Stable for calves up to 6 months" / set.set_calvStables /;
   alias(calvStables,calvStables1);
   set youngStables(stables) "Stable for cattle older than 6 months" / set.set_youngStables /;
   alias(youngStables,youngStables1);

   set stableTypes_to_stables(stableTypes,stables) /
       milkCow.(set.cowStables)
       youngCattle.(set.youngStables)
       calves.(set.set_calvStables)
       motherCow.(set.motherCowStables)
    /;


   set cattleStables(stables) /
     set.set_youngStables
     set.set_cowStables
     set.set_calvStables
     set.set_motherCowStables
   /;

  set herd_stables(herds,stables) /
    $$ifi "%farmBranchDairy"=="on"          (set.dcows).(set.set_cowStables)
    $$ifi "%farmBranchMotherCows%"=="on"    (set.mcows).(set.set_motherCowStables)
    $$ifi defined bulls (set.bulls,bulls).(set.set_youngStables)
    $$ifi defined heifs (set.heifs,heifs).(set.set_youngStables)
                        (set.calvs).(set.set_calvStables)
  /;
   alias(stables,stables1);

   set stableTypes_to_branches(stableTypes,branches) /
        $$ifi "%farmBranchDairy"=="on"         (milkCow,youngCattle,calves).dairy
        $$ifi "%farmBranchBeef%"=="on"         (youngCattle).beef
        $$ifi "%farmBranchMotherCows%"=="on"   (motherCow,youngCattle,calves).motherCows
   /;

   set stables_to_stableStyles(stables,stableStyles) /

      $$ifi "%farmBranchMotherCows%"=="on"  (set.set_motherCowStables)     ."%motherCowStableInv%"
     $$ifi "%farmBranchDairy"=="on"         (set.set_cowStables)           ."%cowStableInv%"
     (set.set_calvStables)          ."%calvesStableInv%"
*
*    --- for farms with cows, use heifers stable type also for males
*
     $$ifi %cowHerd% == true        (set.set_youngStables)."%heifersStableInv%"
*
*    --- for beef fattening farms, use bull stable type for males
*
     $$ifi not %cowHerd% == true    (set.set_youngStables)."%bullsStableInv%"
   /;

$endif.cattle

* -----------------------------------------------------------------------------------
*
*   sets related to pig
*
* -----------------------------------------------------------------------------------

$iftheni.fattners "%farmBranchFattners%"=="on"

   set feedRegime /
                         normFeed
      $$iftheni.red %redNPFeed% == true
                         redNP
                         highRedNP
      $$endif.red
   /;

   set curBreeds(breeds);curBreeds(" ") = YES;
   set fattners(herds)   / earlyFattners,midFattners,lateFattners,fattners /;
   set pigHerds(herds)   / set.fattners /;
   set fatHerd(pigHerds) / set.fattners /;
   set balHerds(herds)   / set.fattners /;

   set acts / set.fattners /;

   set herds_breeds(herds,breeds);
   herds_breeds(fatHerd," ") = YES;
   herds_breeds("pigFattened"," ") = YES;
   herds_breeds("pigletsBought"," ") = yes;

   set actHerds(herds,breeds,feedRegime,t,m) "Indicator set: has the farm a herd of that potential in the year and month?";

   set sum_herds(sumHerds,herds) / pigFattened.(set.Fattners)/;
   set aggHerds(sumHerds)        / pigFattened /;

   set branches / fatPig /;
   set animBranches(branches) / fatPig /;
   set branches_to_acts(branches,acts) / fatPig.fattners  /;

   set stableTypes / fattners/;
   set stableTypes_to_branches(stableTypes,branches) / fattners.fatPig /;
   set herd_stableTypes(herds,stableTypes) / (set.pigHerds).fattners   /;

   set stables(*)          / set.set_fatStables /;
   set fatStables(stables) / set.set_fatStables /;
   set stableTypes_to_stables(stableTypes,stables) / fattners.(set.fatStables) /;

   set herd_stables(herds,stables) / (set.fattners).(set.set_fatStables) /;
   set herd_stableStyle(herds, stableStyles) / (set.fattners)."slatted_floor" /;

   set feedRegimePigs(feedRegime) /       normFeed
      $$iftheni.red %redNPFeed% == true
                                          redNP
                                          highRedNP
      $$endif.red
   /;

$endif.fattners

$$iftheni.sows "%farmBranchSows%"=="on"

    set feedRegime /
                         normFeed
      $$iftheni.red %redNPFeed% == true
                         redNP
                         highRedNP
      $$endif.red
   /;

   set curBreeds(breeds);curBreeds(" ") = YES;


   set sows(herds)     / sows,oldSows,youngPiglets,piglets,slgtsows,youngsows/;
   set pigHerds(herds) / set.sows /;
   set balHerds(herds) / piglets,sows /;
   set acts            / set.sows /;

   set herds_breeds(herds,breeds);
   herds_breeds(sows," ") = YES;

   set actHerds(herds,breeds,feedRegime,t,m)          "Indicator set: has the farm a herd of that potential in the year and month?";

   set branches / sowPig /;
   set animBranches(branches) / sowPig /;
   set branches_to_acts(branches,acts) / sowPig.sows /;


   set stableTypes / sows,piglets/;
   set stableTypes_to_branches(stableTypes,branches) / (sows,piglets).sowPig
    /;
   set herd_stableTypes(herds,stableTypes) /
     (set.sows).sows
      piglets.piglets
   /;

   set stables(*) /
     set.set_sowStables
     set.set_pigletStables
   /;

   set herd_stables(herds,stables) /
    (set.sows).(set.set_sowStables)
    piglets.(set.set_pigletStables)
   /;

   set herd_stableStyle(herds, stableStyles) /
    (set.sows)."slatted_floor"
   /;

   set sowStables(stables)    / set.set_sowStables /;
   set pigletStables(stables) / set.set_pigletStables /;

   set stableTypes_to_stables(stableTypes,stables) /
       sows.(set.sowStables)
       piglets.(set.pigletStables)
   /;

   set feedRegimePigs(feedRegime) /       normFeed
      $$iftheni.red %redNPFeed% == true
                                          redNP
                                          highRedNP
      $$endif.red
   /;

  set sum_herds(sumHerds,herds) /

  /;
 $$endif.sows

 $$iftheni.herd "%herd%"=="true"

   set cattle(herds) / set.herds /;
   $$ifi defined pigHerds cattle(pigHerds) = no;

   alias(stables,stables1,stables2);

   alias(curBreeds,curBreeds1);
   $$ifi defined pigHerds cattle(pigHerds) = no;

   set singleHerds(herds);
   singleHerds(herds)    $ (not sumherds(herds)) = yes;
   singleHerds(sumHerds) $ (sum(sum_herds(sumHerds,herds),1) le 1) = yes;

   $$ifi "%cowHerd%"=="true" singleHerds("remonte")           = no;
   $$ifi "%cowHerd%"=="true" singleHerds("remonteMotherCows") = no;
 $$endif.herd

 branchLink_to_acts(branches,acts) $ branches_to_acts(branches,acts) = yes;

* -----------------------------------------------------------------------------------
*
*   Sets relating to buildings and stables
*
* -----------------------------------------------------------------------------------


  $$batinclude "%datdir%/%buildingsFile%.gms" decl

  set bunkerSilos(buildings) /
      set.S_bunkerSilos
  /;
  alias(bunkerSilos,bunkerSilos1);

  alias(buildings,buildings1);
  set curBuildings(buildings);

  set buildType / potaStore,bunkerSilo/;
  set curBuildType(buildType);
  set buildType_buildings(buildType,buildings) / potastore.(set.s_potaStores)
                                                 bunkerSilo.(set.s_bunkerSilos)
                                                  /;

  set buildAttr / invSum    "Investment sum"
                  capac_t   "Storage capacity in tons"
                  capac_m3  "Storage capacity in m3"
                  lifeTime  "Lifetime in years"
                  varCost   "Variable costs per year"
              /;


  set buildCapac(buildAttr) / capac_t,capac_m3 /;
  parameter p_building(buildings,buildAttr);

*  --------------------------------------------------------------------------------------------------
*
*    Sets relating synthetic fertilizers and crop nutrients
*
*  --------------------------------------------------------------------------------------------------

  set allNut / N    "total N"
               Norg "organic N"
               NTan "total ammoniacal N"
               P  /;

  set nut(allNut) "Nutrients in organic and mineral fertilizers used by crops " /
                        N "nitrogen"
                        P "Phospate"
      /;
 set  nut2(allNut) "nutrients with differentiation between NOrg and NTan" /Norg,NTan,P/  ;

 set  nut2_nut(nut2,nut) / (Norg,Ntan).n,p.p /;
 set  nut2N(nut2) /Norg,Ntan /;

 set nutLosses / NH3Min,NH3Man,N2O,NRun,NLeach,PLeach /;
 alias(nutlosses,nutlosses1);

 set nutLosses_nut(nutLosses,nut) / (NH3Min,NH3Man,N2O,NRun,NLeach).N
                                    (PLeach).P
 /;


set Nemissions "different kind of emissions "/ NH3, N2O, NOx, N2, N2Oind /;


*  --------------------------------------------------------------------------------------------------
*
*    Sets relating to stables, silos, manure
*
*  --------------------------------------------------------------------------------------------------

   set invTypes /stables,stableTypes,buildings,silos,machines /;

$iftheni.manure "%manure%"=="true"

   $$batinclude "%datDir%/%SiloFile%.gms" decl
   alias(silos,silos1);

*  --- sets related to manure storage type:

   set ManStorage / storsub    "sub floor storage"
                    stornocov  "silo storage without coverage"
                    storstraw  "silo storage with straw cover"
                    storfoil   "silo storage with foil coverage"
                 /;

   set siloCover(ManStorage) /  stornocov  "silo storage without coverage"
                                storstraw  "silo storage with straw cover"
                                storfoil   "silo storage with foil coverage"

   /;

   set manStorage_siloFloor(ManStorage,*) /
              storSub.storSub
              (stornocov,storstraw,storFoil).(set.silos) /;


*  --- sets related to manure application type:

   $$iftheni.pig "%pigHerd%"=="true"
      set set_ManApplicTypePig /
                       applSpreadPig "manure applicated broad spread"
                       applTailhPig  "manure applilcated with tail hose (Schleppschlauch)"
                       applInjecPig  "manure injected"
                       applTShoePig  "manure applicated with trailing shoe (Schleppschuh)"
      /;
   $$endif.pig

   $$iftheni.cattle "%cattle%"=="true"
      set set_ManApplicTypeCattle /
                       applSpreadCattle "manure applicated broad spread"
                       applTailhCattle  "manure applilcated with tail hose (Schleppschlauch)"
                       applInjecCattle  "manure injected"
                       applTShoeCattle  "manure applicated with trailing shoe (Schleppschuh)"
      /;
   $$endif.cattle

   $$iftheni.straw "%strawManure%"=="true"
      set set_ManApplicTypeSolid /
                       applSolidSpread "solid cattle manure spreaded with a manrue spreader (Miststreuer)"
      /;
      set set_ManApplicTypeLightCattle /
                       applSpreadLightCattle "manure applicated broad spread"
                       applTailhLightCattle  "manure applilcated with tail hose (Schleppschlauch)"
                       applInjecLightCattle  "manure injected"
                       applTShoeLightCattle  "manure applicated with trailing shoe (Schleppschuh)"
      /;
   $$endif.straw

   $$iftheni.biogas "%biogas%"=="true"
      set set_ManApplicTypeBiogas /
                       applSpreadBiogas "manure applicated broad spread"
                       applTailhBiogas  "manure applilcated with tail hose (Schleppschlauch)"
                       applInjecBiogas  "manure injected"
                       applTShoeBiogas  "manure applicated with trailing shoe (Schleppschuh)"
      /;
   $$endif.biogas

   $$iftheni.import "%AllowManureImport%"=="true"
      set set_ManApplicTypeImport /
                       applSpreadImport "manure applicated broad spread"
                       applTailhImport  "manure applilcated with tail hose (Schleppschlauch)"
                       applInjecImport  "manure injected"
                       applTShoeImport  "manure applicated with trailing shoe (Schleppschuh)"
                     /;
   $$endif.import



   set ManApplicType /
     $$ifi "%pigHerd%"=="true"            set.set_ManApplicTypePig
     $$ifi "%cattle%"=="true"             set.set_ManApplicTypeCattle

     $$iftheni.straw "%strawManure%"=="true"
                                          set.set_ManApplicTypeSolid
                                          set.set_ManApplicTypeLightCattle
     $$endif.straw
     $$ifi "%biogas%"=="true"             set.set_ManApplicTypeBiogas
     $$ifi "%AllowManureImport%"=="true"  set.set_ManApplicTypeImport
                    /;

   $$ifi "%pigHerd%"=="true"           set ManApplicTypePig        (manApplicType) / set.set_ManApplicTypePig         /;
   $$ifi "%cattle%"=="true"            set ManApplicTypeCattle     (manApplicType) / set.set_ManApplicTypeCattle      /;

   $$iftheni.straw "%strawManure%"=="true"
                                       set ManApplicTypeSolid      (manApplicType) / set.set_ManApplicTypeSolid       /;
                                       set ManApplicTypeLightCattle(ManApplicType) / set.set_ManApplicTypeLightCattle /;
   $$endif.straw

   $$ifi "%biogas%"=="true"            set ManApplicTypeBiogas     (ManApplicType) / set.set_ManApplicTypeBiogas      /;
   $$ifi "%AllowManureImport%"=="true" set ManApplicTypeImport     (ManApplicType) / set.set_ManApplicTypeImport      /;

   set nutManApplicType(*) /
       $$iftheni.pig "%pigHerd%"=="true"
                          NApplSpreadPig "nitrogen in in manure applicated broad spread"
                          NApplTailhPig  "nitrogen in manure applicated with tail hose (Schleppschlauch)"
                          NApplInjecPig  "nitrogen in manure injected"
                          NApplTShoePig  "nitrogen in manure applicated with trailing shoe (Schleppschuh)"
       $$endif.pig

       $$iftheni.cattle "%cattle%"=="true"
                          NApplSpreadCattle "nitrogen in in manure applicated broad spread"
                          NApplTailhCattle  "nitrogen in manure applicated with tail hose (Schleppschlauch)"
                          NApplInjecCattle  "nitrogen in manure injected"
                          NApplTShoeCattle  "nitrogen in manure applicated with trailing shoe (Schleppschuh)"
       $$endif.cattle

       $$iftheni.straw "%strawManure%"=="true"
                          NApplSolidSpread "nitrogen solid cattle manure spreaded with a manrue spreader (Miststreuer)"
                          PApplSolidSpread "Phosphate solid cattle manure spreaded with a manrue spreader (Miststreuer)"

                          NApplSpreadLightCattle "nitrogen in in manure applicated broad spread"
                          NApplTailhLightCattle  "nitrogen in manure applicated with tail hose (Schleppschlauch)"
                          NApplInjecLightCattle  "nitrogen in manure injected"
                          NApplTShoeLightCattle  "nitrogen in manure applicated with trailing shoe (Schleppschuh)"
       $$endif.straw

       $$iftheni.import "%AllowManureImport%"=="true"
                          NApplSpreadImport "nitorgen in manure applicated broad spread"
                          NApplTailhImport  "nitorgen in manure applilcated with tail hose (Schleppschlauch)"
                          NApplInjecImport  "nitorgen in manure injected"
                          NApplTShoeImport  "nitorgen in manure applicated with trailing shoe (Schleppschuh)"
       $$endif.import


       $$iftheni.pig "%pigHerd%"=="true"
                          PApplSpreadPig "Phosphate in in manure applicated broad spread"
                          PApplTailhPig  "Phosphate in manure applicated with tail hose (Schleppschlauch)"
                          PApplInjecPig  "Phosphate in manure injected"
                          PApplTShoePig  "Phosphate in manure applicated with trailing shoe (Schleppschuh)"
       $$endif.pig

       $$iftheni.cattle "%cattle%"=="true"
                          PApplSpreadCattle "Phosphate in in manure applicated broad spread"
                          PApplTailhCattle  "Phosphate in manure applicated with tail hose (Schleppschlauch)"
                          PApplInjecCattle  "Phosphate in manure injected"
                          PApplTShoeCattle  "Phosphate in manure applicated with trailing shoe (Schleppschuh)"
       $$endif.cattle

       $$iftheni.straw "%strawManure%"=="true"
                          PApplSpreadLightCattle "Phosphate in in manure applicated broad spread"
                          PApplTailhLightCattle  "Phosphate in manure applicated with tail hose (Schleppschlauch)"
                          PApplInjecLightCattle  "Phosphate in manure injected"
                          PApplTShoeLightCattle  "Phosphate in manure applicated with trailing shoe (Schleppschuh)"
       $$endif.straw

       $$iftheni.import "%AllowManureImport%"=="true"
                          PApplSpreadImport "Phospahte in manure applicated broad spread"
                          PApplTailhImport  "Phospahte in manure applilcated with tail hose (Schleppschlauch)"
                          PApplInjecImport  "Phospahte in manure injected"
                          PApplTShoeImport  "Phospahte in manure applicated with trailing shoe (Schleppschuh)"
       $$endif.import
                        /;

   set nutManApplicType_manApplicType(nutManApplicType,ManApplicType) /

       $$iftheni.pig "%pigHerd%"=="true"
                          NapplSpreadPig    . applSpreadPig
                          NapplTailhPig     . applTailhPig
                          NapplInjecPig     . applInjecPig
                          NapplTShoePig     . applTShoePig

                          PapplSpreadPig    . applSpreadPig
                          PapplTailhPig     . applTailhPig
                          PapplInjecPig     . applInjecPig
                          PapplTShoePig     . applTShoePig
       $$endif.pig

       $$iftheni.cattle "%cattle%"=="true"
                          NapplSpreadCattle . applSpreadCattle
                          NapplTailhCattle  . applTailhCattle
                          NapplInjecCattle  . applInjecCattle
                          NapplTShoeCattle  . applTShoeCattle

                          PapplSpreadCattle . applSpreadCattle
                          PapplTailhCattle  . applTailhCattle
                          PapplInjecCattle  . applInjecCattle
                          PapplTShoeCattle  . applTShoeCattle
       $$endif.cattle

       $$iftheni.straw "%strawManure%"=="true"
                          PApplSolidSpread  . applSolidSpread
                          NApplSolidSpread  . applSolidSpread

                          NapplSpreadLightCattle . applSpreadLightCattle
                          NapplTailhLightCattle  . applTailhLightCattle
                          NapplInjecLightCattle  . applInjecLightCattle
                          NapplTShoeLightCattle  . applTShoeLightCattle

                          PapplSpreadLightCattle . applSpreadLightCattle
                          PapplTailhLightCattle  . applTailhLightCattle
                          PapplInjecLightCattle  . applInjecLightCattle
                          PapplTShoeLightCattle  . applTShoeLightCattle
      $$endif.straw

      $$iftheni.import "%AllowManureImport%"=="true"
                          NApplSpreadImport      . applSpreadImport
                          NApplTailhImport       . applTailhImport
                          NApplInjecImport       . applInjecImport
                          NApplTShoeImport       . applTShoeImport

                          PApplSpreadImport      . applSpreadImport
                          PApplTailhImport       . applTailhImport
                          PApplInjecImport       . applInjecImport
                          PApplTShoeImport       . applTShoeImport
      $$endif.import
   /;

   set nutManApplicType_nut(nutManApplicType,nut) /

       $$iftheni.pig "%pigHerd%"=="true"
                          NapplSpreadPig    .  N
                          NapplTailhPig     .  N
                          NapplInjecPig     .  N
                          NapplTShoePig     .  N

                          PapplSpreadPig    .  P
                          PapplTailhPig     .  P
                          PapplInjecPig     .  P
                          PapplTShoePig     .  P
       $$endif.pig

       $$iftheni.cattle "%cattle%"=="true"
                          NapplSpreadCattle .  N
                          NapplTailhCattle  .  N
                          NapplInjecCattle  .  N
                          NapplTShoeCattle  .  N

                          PapplSpreadCattle .  P
                          PapplTailhCattle  .  P
                          PapplInjecCattle  .  P
                          PapplTShoeCattle  .  P
       $$endif.cattle

       $$iftheni.straw "%strawManure%"=="true"
                          NApplSolidSpread  .  N
                          PApplSolidSpread  .  P
       $$endif.straw

       $$iftheni.import "%AllowManureImport%"=="true"
                          NApplSpreadImport .  N
                          NApplTailhImport  .  N
                          NApplInjecImport  .  N
                          NApplTShoeImport  .  N

                          PApplSpreadImport .  P
                          PApplTailhImport  .  P
                          PApplInjecImport  .  P
                          PApplTShoeImport  .  P
      $$endif.import
  /;

* ---- Subsets to summarize different application techniques for manure types

   set ManApplicSpread(ManApplicType) /
       $$ifi "%pigHerd%"=="true"                applSpreadPig         "Pig manure applicated broad spread"
       $$ifi "%cattle%"=="true"                 applSpreadCattle      "Cattle manure applicated broad spread"
       $$ifi "%strawManure%"=="true"            applSpreadLightCattle "Light cattle manure applicated broad spread"
       $$ifi "%biogas%"=="true"                 applSpreadBiogas      "Biogas manure applicated broad spread"
       $$ifi "%AllowManureImport%"=="true"      applSpreadImport      "Import manure applicated broad spread"
                     /;

   set ManApplicTailh(ManApplicType) /
       $$ifi "%pigHerd%"=="true"                applTailhPig          "Pig manure applicated with tail hose (Schleppschlauch)"
       $$ifi "%cattle%"=="true"                 applTailhCattle       "Cattle manure applicated with tail hose (Schleppschlauch)"
       $$ifi "%strawManure%"=="true"            applTailhLightCattle  "Light manure applicated with tail hose (Schleppschlauch)"
       $$ifi "%biogas%"=="true"                 applTailhBiogas       "Biogas digestate applicated with tail hose (Schleppschlauch)"
       $$ifi "%AllowManureImport%"=="true"      applTailhImport       "Imported manure applicated with tail hose (Schleppschlauch)"
                     /;

   set ManApplicInjec(ManApplicType) /
       $$ifi "%pigHerd%"=="true"                applInjecPig          "Pig manure injected"
       $$ifi "%cattle%"=="true"                 applInjecCattle       "Cattle manure injected"
       $$ifi "%strawManure%"=="true"            applInjecLightCattle  "Light cattle manure injected"
       $$ifi "%biogas%"=="true"                 applInjecBiogas       "Biogas digestate injected"
       $$ifi "%AllowManureImport%"=="true"      applInjecImport       "Imported manure injected"
                     /;

   set ManApplicShoe(ManApplicType) /
        $$ifi "%pigHerd%"=="true"               applTShoePig          "manure applicated with trailing shoe (Schleppschuh)"
        $$ifi "%cattle%"=="true"                applTShoeCattle       "manure applicated with trailing shoe (Schleppschuh)"
        $$ifi "%strawManure%"=="true"           applTShoeLightCattle  "manure applicated with trailing shoe (Schleppschuh)"
        $$ifi "%biogas%"=="true"                applTShoeBiogas       "manure applicated with trailing shoe (Schleppschuh)"
        $$ifi "%AllowManureImport%"=="true"     applTShoeImport       "manure applicated with trailing shoe (Schleppschuh)"
                     /;

*  --------------------------------------------------------------------------------------------------
*
*    Sets relating to nutrient content of manure in and after storage
*
*  --------------------------------------------------------------------------------------------------

  set set_manChain "Manure chain" /
                              $$ifi "%pigherd%"=="true"           LiquidPig
                              $$ifi "%cattle%"=="true"            LiquidCattle
                              $$ifi "%strawManure%"=="true"       LightLiquidCattle,SolidCattle
                              $$ifi "%biogas%"=="true"            LiquidBiogas
                              $$ifi "%AllowManureImport%"=="true" LiquidImport
                            /;

  set chain / set.set_manChain,"" /;

  set manChain(chain) "Manure chain" /set.set_manChain /;


  $$iftheni.cattle "%cattle%"=="true"
      set cattleManureChain(manChain) "Cattle manure chain" /
                                       LiquidCattle
                                       $$ifi "%strawManure%"=="true"  LightLiquidCattle,SolidCattle
  /;
  $$endif.cattle
  set curManChain(manChain);
  option kill=curManChain;
*
*   --- Definition of manure types with minimum and maximum nutrient content for different herds + biogas
*
  set set_manType /
                                                   cows
    $$ifi "%farmBranchMotherCows%" == "on"         MC
    $$ifi  %cattle% == true                        heifs,fcalvsRais,mcalvsRais
    $$ifi "%farmBranchBeef%"       == "on"         bulls
    $$ifi "%farmBranchSows%"       == "on"         sow,piglet

    $$iftheni.fat "%farmBranchfattners%"   == "on" fattner
      $$ifi %redNPFeed% == true                    fattnerRed,fattnerHighRed
    $$endif.fat

    $$ifi %biogas%  == true                        digMaizSil,digWheatGPS,digGrasSil,manCattPurch,manPigPurch
  /;

  $$iftheni.straw "%strawManure%"=="true"

  set set_manTypeSolid /
    cowsSolid
    McSolid
    heifsSolid,fcalvsRaisSolid,mcalvsRaisSolid
    bullsSolid
  /;

  set set_manTypeLight /
    cowsLight
    McLight
    heifsLight
    fcalvsRaisLight,mcalvsRaisLight
    bullsLight
  /;

  $$endif.straw

  set manType(*) "Manure types, characterized by N:P ratio" /
* ---  sets are definded for
*      (1) environmental accounting on,
*      (2) environmental accounting off and reduced N/P feeding off
*      (3) environmental accounting off and reduced N/P feeding on
    set.set_manType

    $$iftheni.straw "%strawManure%"=="true"
      set.set_manTypeSolid
      set.set_manTypeLight
    $$endif.straw
$$iftheni.im "%AllowManureImport%" == "true"
    $$ifi "%AllowBiogasExchange%" == "false"   manImport
    $$ifi "%AllowBiogasExchange%" == "true"    manBiogasImport
$endif.im

  /;

  set curManType(manType); curManType(manType) = YES;

  set manChain_Type(manChain,manType);
  option kill=manChain_Type;
  $$ifi defined herds set manChain_herd(manChain,herds);

  set manChain_applic(manChain,ManApplicType) /

  $$iftheni.pig "%pigHerd%"=="true"
     "liquidPig".            applSpreadPig "Pig manure applicated broad spread"
     "liquidPig".            applTailhPig  "Pig manure applilcated with tail hose (Schleppschlauch)"
     "liquidPig".            applInjecPig  "Pig manure injected"
     "liquidPig".            applTShoePig  "Pig manure applicated with trailing shoe (Schleppschuh)"
 $$endif.pig

 $$iftheni.cattle "%cattle%"=="true"
    "liquidCattle".         applSpreadCattle "Cattle manure applicated broad spread"
    "liquidCattle".         applTailhCattle  "Cattle manure applicated with tail hose (Schleppschlauch)"
    "liquidCattle".         applInjecCattle  "Cattle manure injected"
    "liquidCattle".         applTShoeCattle  "Cattle manure applicated with trailing shoe (Schleppschuh)"
 $$endif.cattle

 $$iftheni.straw "%strawManure%"=="true"
    "lightLiquidCattle".    applSpreadLightCattle "Light cattle manure applicated broad spread"
    "lightLiquidCattle".    applTailhLightCattle  "Light cattle manure applicated with tail hose (Schleppschlauch)"
    "lightLiquidCattle".    applInjecLightCattle  "Light cattle manure injected"
    "lightLiquidCattle".    applTShoeLightCattle  "Light cattle manure applicated with trailing shoe (Schleppschuh)"

    "solidCattle".          applSolidSpread  "Solid cattle manure applicated with a manure spreader (Miststreuer)"
 $$endif.straw

  $$iftheni.biogas "%biogas%"=="true"
    "LiquidBiogas".         applSpreadBiogas "Biogas digestate with applicated broad spread"
    "LiquidBiogas".         applTailhBiogas  "Biogas digestate with applilated with tail hose (Schleppschlauch)"
    "LiquidBiogas".         applInjecBiogas  "Biogas digestate with injected"
    "LiquidBiogas".         applTShoeBiogas  "Biogas digestate with applicated with trailing shoe (Schleppschuh)"
  $$endif.biogas

  $$iftheni.import "%AllowManureImport%"=="true"
    "LiquidImport".         applSpreadImport "Imported manure applicated broad spread"
    "LiquidImport".         applTailhImport  "Imported manure applicated with tail hose (Schleppschlauch)"
    "LiquidImport".         applInjecImport  "Imported manure injected"
    "LiquidImport".         applTShoeImport  "Imported manure applicated with trailing shoe (Schleppschuh)"
  $$endif.import

  /;

  set manApplicType_manType(manApplicType,manType);
     option kill=manApplicType_manType;

  set usedManTypeApplType(manApplicType,manType);

* --- subsets for mantypes of pigs and dairy

$iftheni.cattle "%cattle%"=="true"

  set manCattlePro(manType)   "summarizes manure types for cattle"   /
  $$ifi   %cattle% == true                 cows
  $$ifi "%farmBranchMotherCows%" == "on"   MC
                                           heifs
                                           fcalvsRais,mcalvsRais
  $$ifi "%farmBranchBeef%" == "on"         bulls
  /;

  set manDairyPro(manCattlePro) / cows /;

     manChain_type("liquidCattle",manCattlePro)     = YES;
     manChain_herd("LiquidCattle",cattle)           = YES;

     manApplicType_manType(ManApplicTypeCattle,manCattlePro) = YES;

*
*   --- Link herds that are on straw to straw manure chains (solid, light liquid), manure types and application techniques
*
 $$iftheni.straw "%strawManure%"=="true"
*
*   --- define herds that are on a straw stable
*
      set strawHerds(herds);
      strawHerds(herds) = NO;

      $$iftheni.cowHerd "%cowHerd%"=="true"

        $$ifi not "%cowStableInv%"       =="slatted_floor" strawHerds(dcows)     = YES;
        $$ifi not "%motherCowStableInv%" =="slatted_floor" strawHerds(mcows)     = YES;
        $$ifi not "%heifersStableInv%"   =="slatted_floor" strawHerds(heifs)     = YES;
        $$ifi not "%calvesStableInv%"    =="slatted_floor" strawHerds(calvsRais) = YES;

*       --- strawherds bulls relies on strawherds heifs as they compete for the same stable (L.K. 28.11.2019)
          $$ifi defined bulls strawherds(bulls) $ sum(heifs $ strawherds(heifs),1) = yes;
      $$elseif.cowHerd defined bulls
         $$ifi not "%bullsStableInv%"      =="slatted_floor" strawHerds(bulls) = YES;
      $$endif.cowHerd


      set manDairyStrawSolid(manType) / set.set_manTypeSolid /;
      set manDairyStrawLight(manType) / set.set_manTypeLight /;

     manChain_herd("solidCattle",strawHerds) = YES;
     manChain_herd("lightLiquidCattle", strawHerds) = YES;
     manChain_type("solidCattle", manDairyStrawSolid) = YES;
     manChain_type("lightLiquidCattle", manDairyStrawLight) = YES;

     manApplicType_manType(ManApplicTypeLightCattle, manDairyStrawLight) = YES;
     manApplicType_manType(ManApplicTypeSolid, manDairyStrawSolid) = YES;

 $$endif.straw

set manChain_stableStyle(manChain,stableStyles) ;

 manChain_stableStyle(manChain,stableStyles)
     = sum( manChain_herd(manChain,herds) $ herd_stableStyle(herds,stableStyles),1);

$endif.cattle


$iftheni.pig %pigherd% == true

  set manPigPro(manType)   "summarizes manure types for pig production"   /

           $$ifi  "%farmBranchSows%"     == "on"     sow,piglet
           $$iftheni.fat  "%farmBranchfattners%" == "on"     fattner
             $$ifi %redNPFeed% == true fattnerRed,fattnerHighRed
           $$endif.fat
      /;

     manChain_type("liquidPig",manPigPro)              = YES;
     manChain_herd("liquidPig",pigHerds)               = YES;
     manApplicType_manType(ManApplicTypePig,manPigPro) = YES;

$endif.pig

$iftheni.im "%AllowManureImport%" == "true"
*  --- set defining differnet manure types that can be imported
     set ManImports(manType) /
$$ifi  "%AllowBiogasExchange%"     == "false"    manImport
$$ifi  "%AllowBiogasExchange%"     == "true"     manBiogasImport
                       /;
   manApplicType_manType(ManApplicTypeImport,ManImports) =  YES;
   manChain_type("LiquidImport",ManImports)   = YES;
   curmanchain("LiquidImport") = YES;

$endif.im

*  --- Sets defining manure type (has to be active for biogas when no herd is active, hence, not included in %herd% part)

$iftheni.biogas %biogas%    == true

   set branches / biogas /;

      set digestate(mantype)  /
        digMaizSil,digWheatGPS,digGrasSil,manCattPurch,manPigPurch
      /;

      alias (digestate,manBiogasPro);

      manChain_type("liquidBiogas",manBiogasPro) = Yes ;

      manApplicType_manType(ManApplicTypeBiogas,digestate) = YES;

      curmanchain("liquidbiogas") = YES;

   set curDigestate(digestate);
   option kill = curDigestate;

   set feedRegime / normFeed /;


$endif.biogas
$endif.manure

*  --------------------------------------------------------------------------------------------------
*
*    Sets relating to inputs and outputs
*
*  --------------------------------------------------------------------------------------------------

  set set_syntFertilizer / AHL       "ammoniumharnstoffloesung"
                           ASS       "ammoniumsulfatsalpeter"
*                          superP    "SuperPhospate with 18% P2O5"
                           PK_18_10  "PK 18 10"
                           dolophos  "soft rock phosphat, as required in organic production"
                           KAS
                           KaliMag
*LK: Dont know why this is here leads to strange results, buying spreading (work and machneed) are regulated via cropha and NOT v_syntDist
*                           Lime      "Lime fertilizer"
                     /;


  set set_pesticides /
                       Herb                "Herbicide"
                       Fung                "Fungicides"
                       Insect              "Insecticides"
                       growthContr         "Growth controller for cereals"
                     /;

  set set_crop_inputs / seed
                        set.set_syntFertilizer
                        set.set_pesticides
                        hailIns             "Hail insurance"
                        diesel              "diesel"
                        lime
               $$iftheni.data "%database%"=="KTBL_database"
                        set.inputsKTBL
               $$endif.data
            /;


*
*  --- products in the model
*

 set prodsAll "all products - input and outputs" /

*
*    --- output/input related to cattle module
*
     $$ifi defined set_beef_prods_HF set.set_beef_prods_HF
     $$ifi defined set_beef_prods_MC set.set_beef_prods_MC
     $$ifi defined set_beef_prods_SI set.set_beef_prods_SI

$iftheni.cows  "%cowHerd%"=="true"

     set_heifBeef_prods_HF set.set_heifBeef_prods_HF
     $$ifi defined set_heifBeef_prods_MC set.set_heifBeef_prods_MC
     $$ifi defined set_heifBeef_prods_SI set.set_heifBeef_prods_SI

     set.set_heifsSold,

     milk,
     oldCow,
     youngCow,
     mCalv,
     fCalv,
     mCalvRaisSold,

     mCalv_HF,fCalv_HF,mCalvsRais_HF,
     mCalv_SI,fCalv_SI,mCalvsRais_SI,

$endif.cows

$iftheni.cattle "%cattle%"=="true"

     set.set_calvsBought
     set.set_heifsBought,

$endif.cattle
$iftheni.beef "%farmBranchBeef%"=="on"
     set.set_bullsBought,bullsBought,
$endif.beef
*
*    --- output/input related to pig module
*
$iftheni.pig  "%pigherd%"=="true"
     pigMeat,oldSow,fattners,pigletsSold,
     youngPiglet,piglet,pigletsBought
$endif.pig
*
*    --- general output and input
*
     set.set_crop_prods,grasPast

     other,fixedMach,manCost,buildCost
     $$ifi "%allowHiring%"=="true" hiredLabour
     contractWork
     dolophos
 /;

 $$iftheni.mi "%AllowManureImport%" == "true"

    set prodsAll /
        set.ManImports
$$ifi "%AllowBiogasExchange%"=="true" ManNetImport
 /;

set inputs(prodsAll) "All inputs in the model" /
     set.ManImports
$$ifi "%AllowBiogasExchange%"=="true" ManNetImport
 /;

 $$endif.mi

$iftheni.stochYields "%stochYields%"=="true"
    set prodsAll /
        CropIns
    /;

    set inputs(prodsAll) "All inputs in the model" /
        CropIns
    /;
$endif.stochYields

$onmulti


 set prodsAll "all products - input and outputs" /
    $$ifi defined grasOutputs set.grasOutputs
 /;
 set prodsAll "all products - input and outputs" /
     set.inputsGDX
 /;

$batinclude '%datdir%/%feedsFile%.gms' decl
$onmulti
 set prodsAll "all products - input and outputs" /
     set.set_feeds
 /;

 set inputs(prodsAll) "All inputs in the model" /

 $$iftheni.cattle "%cattle%"=="true"
     set.set_calvsBought
     set.set_heifsBought
 $$endif.cattle
 $$iftheni.beef "%farmBranchBeef%"=="on"
     set.set_bullsBought
 $$endif.beef

     $$ifi defined grasOutputs set.grasOutputs
     other,fixedMach,manCost,buildCost
     $$ifi "%allowHiring%"=="true" hiredLabour
     contractWork
 /;
 set inputs(prodsAll) "All inputs in the model" /
     set.inputsGDX
 /;


$iftheni.pig  "%pigherd%"=="true"

 set inputs(prodsAll) "All inputs in the model" /
     youngPiglet,piglet,pigletsBought
 /;

$endif.pig


 set youngAnim(inputs) /

    $$iftheni.cattle "%cattle%"=="true"
     set.set_calvsBought
     set.set_heifsBought
    $$endif.cattle
    $$iftheni.beef "%farmBranchBeef%"=="on"
     set.set_bullsBought
    $$endif.beef
    $$iftheni.pig  "%pigherd%"=="true"
     youngPiglet,piglet,pigletsBought
    $$endif.pig
 /;

 set cropInputs(prodsAll) / set.set_crop_inputs /;
 set curInputs(inputs);

 set syntFertilizer(inputs) / set.set_syntFertilizer /;
 set pesticides(inputs)     / herb,fung,insect /;
 alias(pesticides,pesticides1);

 set N_fertilizer(syntFertilizer) /ASS,AHL,KAS/;
 set P_fertilizer(syntFertilizer) /PK_18_10, dolophos/;


 set set_prodsMonthly / grasPast,earlyGraz,middleGraz,lateGraz/;

 set meatTypes / "Type1" ,"Type2" ,"Type3" ,"Type4" ,"Type5" ,"Type6" /;




$iftheni.cattle "%cattle%"=="true"
 set set_dairy_prods   /
     milk,oldCow,
     mCalv,fCalv,mCalvRaisSold,set.set_heifsSold
     mCalv_HF,fCalv_HF,mCalvRais_HF
     mCalv_MC,fCalv_MC,mCalvRais_MC
     mCalv_SI,fCalv_SI,mCalvRais_SI
  /;

 set calv_prods(set_dairy_prods) /mCalv,fCalv, mCalv_HF,fCalv_HF, mCalv_MC,fCalv_MC, mCalv_SI,fCalv_SI/;
 set mcalv_prods(set_dairy_prods) /mCalv_HF,mCalv_MC,mCalv_SI/;
 set fcalv_prods(set_dairy_prods) /fCalv_HF,fCalv_MC,fCalv_SI/;

$endif.cattle

 set  set_pig_prods /  pigMeat,youngPiglet,pigletsSold,oldSow,fattners /;

 set set_prodsYearly  /
*
*   --- outputs relating to the cattle herd
*
     $$ifi defined set_dairy_prods       set.set_dairy_prods

     $$ifi defined set_beef_prods_HF     set.set_beef_prods_HF
     $$ifi defined set_beef_prods_MC     set.set_beef_prods_MC
     $$ifi defined set_beef_prods_SI     set.set_beef_prods_SI

     $$ifi defined set_heifBeef_prods_HF set.set_heifBeef_prods_HF
     $$ifi defined set_heifBeef_prods_MC set.set_heifBeef_prods_MC
     $$ifi defined set_heifBeef_prods_SI set.set_heifBeef_prods_SI
*
*   --- outputs relating to the pig herd
*
     $$ifi defined set_pig_prods set.set_pig_prods
*
*   --- outputs relating to crops
*
     set.set_crop_prods
     earlyGrasSil,middleGrasSil,lateGrasSil,hay,hayM,grasM,milkFed 
  /;


 set prods "All outputs in model"    / set.set_prodsYearly,set.set_prodsMonthly /;

$iftheni.beef "%farmBranchBeef%"=="on"


    set allBeef_outputs(prods) /
                                 $$ifi defined set_beef_prods_HF set.set_beef_prods_HF
                              $$ifi defined set_beef_prods_MC set.set_beef_prods_MC
                              $$ifi defined set_beef_prods_SI set.set_beef_prods_SI
                            /;

 set beef_outputs(prods)    / set.allBeef_outputs /;
 alias(beef_outputs,beef_outputs1);

    $$ifi defined set_beef_prods_HF     set beef_HF_outputs(beef_outputs) / set.set_beef_prods_HF /;
 $$ifi defined set_beef_prods_MC     set beef_MC_outputs(beef_outputs) / set.set_beef_prods_MC /;
 $$ifi defined set_beef_prods_SI     set beef_SI_outputs(beef_outputs) / set.set_beef_prods_SI /;

    $$ifi defined set_beef_prods_HF set bullsSold_HF_beefOutputs(bullsSold, beef_outputs);
    $$ifi defined set_beef_prods_HF bullsSold_HF_beefOutputs(bullsSoldHF, beef_HF_outputs) $ (bullsSoldHF.pos eq beef_HF_outputs.pos) = YES;

$endif.beef

$iftheni.heif "%cowHerd%"=="true"

   set allheifBeef_outputs(prods) /
       $$ifi defined  set_heifBeef_prods_HF set.set_heifBeef_prods_HF
       $$ifi defined  set_heifBeef_prods_MC set.set_heifBeef_prods_MC
       $$ifi defined  set_heifBeef_prods_Si set.set_heifBeef_prods_SI
   /;

   set heifBeef_outputs(prods) /set.allheifBeef_outputs/;

   set allbeef_outputs(prods)  /set.allheifBeef_outputs /;

   set beef_outputs(prods)     /set.allbeef_outputs /;
   alias(beef_outputs,beef_outputs1);

   $$ifi defined  set_heifBeef_prods_HF set heifBeef_HF_outputs(heifBeef_outputs) / set.set_heifBeef_prods_HF /;
   $$ifi defined  set_heifBeef_prods_MC set heifBeef_MC_outputs(heifBeef_outputs) / set.set_heifBeef_prods_MC /;
   $$ifi defined  set_heifBeef_prods_SI set heifBeef_SI_outputs(heifBeef_outputs) / set.set_heifBeef_prods_SI /;

   $$ifi defined  set_heifBeef_prods_HF set heifsSold_HF_beefOutputs(heifsSold, heifBeef_outputs);
   $$ifi defined  set_heifBeef_prods_HF heifsSold_HF_beefOutputs(heifsSoldHF, heifBeef_HF_outputs) $ (heifsSoldHF.pos eq heifBeef_HF_outputs.pos) = YES;

$endif.heif

 $$iftheni.mc "%farmBranchMotherCows%"=="on"
   set bullsSold_MC_beefOutputs(bullsSold, beef_outputs);
   set heifsSold_MC_beefOutputs(heifsSold, heifBeef_outputs);

   bullsSold_MC_beefOutputs(bullsSoldMC, beef_MC_outputs) $ (bullsSoldMC.pos eq beef_MC_outputs.pos) = YES;
   heifsSold_MC_beefOutputs(heifsSoldMC, heifBeef_MC_outputs) $ (heifsSoldMC.pos eq heifBeef_MC_outputs.pos) = YES;
 $$endif.mc

 $$iftheni.cross "%crossBreeding%"=="true"

   $$iftheni.bulls "%farmBranchBeef%"=="on"
   set bullsSold_SI_beefOutputs(bullsSold, beef_outputs);
      bullsSold_SI_beefOutputs(bullsSoldSI, beef_SI_outputs) $ (bullsSoldSI.pos eq beef_SI_outputs.pos) = YES;
   $$endif.bulls

   $$iftheni.cow "%cowHerd%"=="true"
   set heifsSold_SI_beefOutputs(heifsSold, heifBeef_outputs);
   heifsSold_SI_beefOutputs(heifsSoldSI, heifBeef_SI_outputs) $ (heifsSoldSI.pos eq heifBeef_SI_outputs.pos) = YES;
   $$endif.cow
 $$endif.cross


 set grasOutput(prods)      /
  $$if.a defined grasOutputs set.grasOutputs
  /;
 set pastOutput(prods)      /
  $$if defined pastoutputs set.pastOutputs
   /;

 set prodsYearly(prods)  "Products with a yearly resolution" / set.set_prodsYearly /;
 alias(prodsyearly,prodsyearly1);
 set prodsResidues(prodsYearly) / set.cropsResidues_prods/;

 set grasSil(prodsYearly) / earlyGrasSil,middleGrasSil,lateGrasSil,hay, hayM, grasM/;

 set prodsMonthly(prods) "products with a monthly resolution" / set.set_prodsMonthly /;

 set curProds(prods);

 set randProbs(*);

 set animalProds(prods)
 /
     $$if defined set_dairy_prods        set.set_dairy_prods
     $$if defined set_beef_prods_HF      set.set_beef_prods_HF
     $$if defined set_beef_prods_MC      set.set_beef_prods_MC
     $$if defined set_beef_prods_SI      set.set_beef_prods_SI

     $$if defined set_heifbeef_prods_HF  set.set_heifBeef_prods_HF
     $$if defined set_heifbeef_prods_MC  set.set_heifBeef_prods_MC
     $$if defined set_heifbeef_prods_SI  set.set_heifBeef_prods_SI
/;
alias(animalProds,animalProds1);

* -----------------------------------------------------------------------------
*
*   Sets for p_res (SustainBeef specific LK 29.10.2019)
*
* -----------------------------------------------------------------------------
* set combining all bought synthetic fertilizers including lime
set syntfert(inputs)
/AHL
 ASS
 PK_18_10
 dolophos
 KAS
 KaliMag
 Lime
/;

*set combining all bought phytosanitary measures
set phytosani(inputs)
/Herb
 Fung
 Insect
 growthContr
 water
/;

*set combinig all beef outputs

$iftheni.cattle "%cattle%"=="true"

set beefout(prods)
/OldCow
 $$ifi defined allBeef_outputs set.allBeef_outputs
 mCalv
 fCalv
 mCalvRaisSold
 mCalv_HF
 fCalv_HF
 mCalv_SI
 fCalv_SI
 mCalvRais_HF
 mCalv_MC
 fCalv_MC
 mCalvRais_MC
 mCalvRais_SI
/;

$endif.cattle



* -----------------------------------------------------------------------------
*
*   Sets specific for dairies and pigs
*
* -----------------------------------------------------------------------------


    set feeds(prodsall) / set.set_feeds /;

    set feedsM(feeds) "feeds products on a monthly basis";
    set feedsY(feeds) "feeds products on a yearly basis";
    feedsM(feeds)   $ sum(sameas(feeds,prodsMonthly),1) = yes;
    feedsY(feeds)   $ (not feedsM(feeds)) = yes;
    set curFeeds(feeds); curFeeds(feeds) = yes;

$iftheni.pigherd "%pigherd%"=="true"

    set cerefeedspigGDX "crops which can be feeded to pigs";
    $$gdxin "%datDir%/%cropsFile%.gdx"
      $$load cerefeedspigGDX
    $$gdxin

    set feedsPig(prodsall) /
                 set.cerefeedspigGDX
                 soybeanMeal
                 soybeanOil
                 rapeSeedMeal
                 PlantFat
                 minFu
                 minFu2
                 minFu3
                 minFu4
    /;

    set cereFeedPig(feedspig)  "Crops which can be feeded to pigs"
     /
        set.cerefeedspigGDX
     /;


   set feedsRestricted(feedspig) /
                  soybeanMeal
                  rapeSeedMeal
                  PlantFat
                  MinFu
                  MinFu2
                  MinFu3
                  MinFu4
                   /;

    set feedAttr /

                 energ
                 crudeP
                 Lysin
                 phosphFeed
                 kalium
                 mass
                     /;

$endif.pigHerd

$iftheni.cattle "%cattle%"=="true"

      set grasfeed(feeds)/ set.pastOutput /;

      set roughages(feeds) /
          set.grasOutput
          set.roughagesGDX
*          Straw
       $$iftheni.feedCatchCrop "%feedCatchCrop%"=="true"
            CCclover
            set.feed_ccCrops "catchcrops used as feed"
       $$endif.feedCatchCrop
          
        /;

set concentrates(feeds);
   concentrates(feeds) $ (not sum(roughages $ sameas(roughages,feeds),1))  = YES;

   set feedRegime_feeds(feedRegime,feeds);
   feedRegime_feeds(feedRegime,feeds) $ (not sameas(feedRegime,"normFeed")) = YES;
   feedRegime_feeds("noGraz",grasFeed)                        = NO;
   feedRegime_feeds("fullGraz",feeds) $ (not grasFeed(feeds)) = NO;

* --- Feed additives
    set feedAdd(feeds) /
$$ifi "%vegetableOil%" =="true"    feedAdd_VegOil
$$ifi "%Bovaer%"       =="true"    feedAdd_Bovaer
    /;
$endif.cattle

    set animProds(prods)  /

$iftheni.dh "%cowHerd%"=="true"
                           milk,oldCow,
                           mCalv,fCalv
$endif.dh

$ifi %pigHerd%   == true    pigMeat,pigletsSold,oldSow
    /;

    set cropProds(prods)  / set.set_crop_prods /;

    set workOpp / workOpp1*workOpp10 /;

    set allWorkType                                    / hourly,set.workOpp /;
    set    workType(allWorkType) "Binary decisions"    / set.workOpp /;

    set LeisLevl "Leisure levels" /LeisLevl_01*LeisLevl_10 /;


    set workOpps(workType);
    alias(workOpps,workOpps1);

    set creditType / 2years,5years,10years,20years /;

    set machVar  / 45kW,67kw,83kW,102Kw,120kW,200kW,230kW /;
    set plotSize / 1*40  /;
    set plotDist / 1*20 /;

    set actMachVar(machVar)   / %machVar% /;

    set actPlotSize(plotsize) /%plotSize%/;
    parameter p_actPlotSize / %plotSize% /;

    set actPlotDist(plotsize) / %plotDist% /;
    parameter p_actPlotDist / %plotDist% /;
*build a set with rounded plot size to keep plot size effects of grass and other crops not included in KTBL database
    set rounded_plotSize / "1","2","5","20" /;
    set act_rounded_plotsize(rounded_plotsize);
    act_rounded_plotsize("1")  =YES $ (p_actPlotSize lt 1.5);
    act_rounded_plotsize("2")  =YES $ ((p_actPlotSize ge 1.5) and (p_actPlotSize lt 2.5));
    act_rounded_plotsize("5")  =YES $ ((p_actPlotSize ge 2.5) and (p_actPlotSize lt 12.5));
    act_rounded_plotsize("20") =YES $ (p_actPlotSize ge 12.5);




*
* --- include list of machines
*


$$batinclude "%datdir%/%machFile%.gms" decl
set machType/set.set_machtype/;
$iftheni.data "%database%"=="KTBL_database"
   set machTypeID/set.set_machTypeID/;
   set machTypeID_machType(machTypeID,machType)/set.set_machTypeID_machType/;
   set machType_machineType(machType,machineType) /set.set_machType_machineType /;
$endif.data

set opAttr "Attributes for the different appplications" / labTime,Diesel,fixCost,varCost,nPers,Amount,services,contractLab,deprec /;


set machattr / price
            hour
            ha
            m3
            t
            years
            varCost_ha
            varCost_t
            varCost_h
            varCost_m3
            varCost_year
            fixCost_t
            fixCost_h
            diesel_h
            depCost_ha
            depCost_hour
           /;

    set curMachines(machType);

    set mach_to_branch(machType,branches);

    $$ifi defined stables set stables_to_mach(stables,machType) /set.set_stables_to_mach/;

$offempty

    set inv / set.machType,
       $$ifi defined stables   set.stables,set.stableTypes
       $$ifi defined buildings set.buildings
       $$ifi defined silos     set.silos
    /;
    set curInv(*); curInv(inv) = yes;

    set machLifeUnit / hour,ha,m3,t,years,invCost/;

    set feedAttr /
      DM "Dry matter / Trockenmasse"
      XF "Raw fibre / Rohfaser"
      aNDF "Neutral Detergent Fibre/Neutrale Detergentien Faser"
      ADF "Acid Detergent Fibre/Säure Detergentien Faser"
      XP "Raw protein / Rohprotein"
      nXP "Usable raw protein / nutzbares Rohprotein"
      UDP "undigested protein in the rumen in % of the raw protein"
      RNB "Ruminal nitrogen balance / Ruminale N-Bilanz"
      NEL "Net energy for lactation / Netto-Energie-Laktation"
      ME "Metabolisable Energy / Umsetzbare Energie"
      GE "Gross energy"
      XS+XZ "Sugar and Starch"
      bSX "beständige Stärke"
      XL "Raw fat / Rohfett"
      Ca "Calcium"
      P "Phosphate"
      Mg "Potassium"
      Na "Sodium"
      K "Kalium"
      RNBmin "Maximum RNB"
      RNBmax "Minimum RNB"
      DMR "Minimum dry matter from roughages / Trockenmasse aus Raufutter"
      DMRMX "Maximum dry matter from rougaghes"
      DMMX "Maximum Dry matter / Maximale Trockenmasse aufnahme"
      FMMX "Maximum fresh matter intake"
      NFE "N-free extracts / N-freie Extraktstoffe"
     /;

    set reqs(feedAttr) "animal requirements in model " /  DMR, DMRMX, DMMX, FMMX,XP, nXP, RNBmin,RNBmax, XS+XZ, aNDF, NEL, ME /;

    set cropPos  / yield,varCost,maxRotShare /;



    set NFromTToMean /     nApplied,NManApplied,NMinApplied,NlossesStorage,NLossesApplic,NInStorage,NManure,
                           pApplied,pManApplied,PMinApplied,PlossesStorage,PLossesApplic,PInStorage,PManure,
                           inStorage,ManStorage,

$iftheni.herd      "%herd%"=="true"
                           set.manStorage,
                           set.manApplicType,
                           set.nutManApplicType,
$endif.herd
                           set.nutLosses /;


    set meanForActs   / hours,labHour,yield,reve,vCost,vCostO,inputs,fCost,fNmCost,remonte,gm,prodLength /;
    meanForActs(prods)  = YES;
    meanForActs(inputs) = YES;

    set nMeanForCrops  /   nNeed,nMin,nMan,NGraz,NBas,nAtmDep,NMineral,NLeach,NH3Min,NPrev,NEnd
                           pNeed,pMin,pMan,pGraz,pBas/;
    set meanForCrops  /    set.nMeanForCrops,
$ifi "%herd%"=="true"          set.nutManApplicType,
                           set.intens

                      /;
    set meanForCrops  /    set.till

                      /;

    set itemsForAggHerds / set.meanForActs,nLac/;


* -----------------------------------------------------------------------------
*
*   Sets related to environmental accounting module
*
* -----------------------------------------------------------------------------

$iftheni.envAcc "%envAcc%"=="true"

   set emissions / NO3,NH3,N2O,NOx,N2,N2Oind,CH4,CO2,TSP,PM25,PM10,P
$iftheni.upstream "%upstreamEF%" == "true"
                  m2aA_eq,CO2_eq,oil_eq,FETP_DCB_eq,P_eq,HTP_DCB_eq,
                  U235_eq,METP_DCB_eq,N_eq,Fe_eq,m2_eq,CFC11_eq,
                  PM10_eq,NMVOC_eq,SO2_eq,TETP_DCB_eq,m2aU_eq,m3_eq
$endif.upStream
               /;

   set NiEmissions(emissions) / NH3,N2O,NOx,N2 / ;

   set source
   /
                                             entFerm
                                             staSto
                                             past
                                             manAppl
                                             minAppl
                                             field
                                             input
    $$iftheni.upStream "%upstreamEF%" == "true"
                                             machine
                                             building
                                             stable
                                             silo
                                             straw
    $$endif.upStream
    /;

   set source_emissions(source,emissions) /
                                           staSto.(NH3,N2O,NOx,N2,N2Oind,CH4,TSP,PM25,PM10)
                                           past.(NH3,N2O,NOx,N2,N2Oind,CH4)
                                           manAppl.(NH3,N2O,NOx,N2,N2Oind)
                                           minAppl.(NH3,N2O,NOx,N2,N2Oind)
                                           field.(NO3,N2Oind,CO2, N2O,TSP,PM25,PM10,P)
                                           entFerm.CH4

  $$iftheni.upStream "%upstreamEF%" == "true"
                                            input.(m2aA_eq,CO2_eq,oil_eq,FETP_DCB_eq,P_eq,HTP_DCB_eq,
                                                   U235_eq,METP_DCB_eq,N_eq,Fe_eq,m2_eq,CFC11_eq,
                                                   PM10_eq,NMVOC_eq,SO2_eq,TETP_DCB_eq,m2aU_eq,m3_eq)
                                          machine.(m2aA_eq,CO2_eq,oil_eq,FETP_DCB_eq,P_eq,HTP_DCB_eq,
                                                   U235_eq,METP_DCB_eq,N_eq,Fe_eq,m2_eq,CFC11_eq,
                                                   PM10_eq,NMVOC_eq,SO2_eq,TETP_DCB_eq,m2aU_eq,m3_eq)
                                         building.(m2aA_eq,CO2_eq,oil_eq,FETP_DCB_eq,P_eq,HTP_DCB_eq,
                                                   U235_eq,METP_DCB_eq,N_eq,Fe_eq,m2_eq,CFC11_eq,
                                                   PM10_eq,NMVOC_eq,SO2_eq,TETP_DCB_eq,m2aU_eq,m3_eq)
                                           stable.(m2aA_eq,CO2_eq,oil_eq,FETP_DCB_eq,P_eq,HTP_DCB_eq,
                                                   U235_eq,METP_DCB_eq,N_eq,Fe_eq,m2_eq,CFC11_eq,
                                                   PM10_eq,NMVOC_eq,SO2_eq,TETP_DCB_eq,m2aU_eq,m3_eq)
                                             silo.(m2aA_eq,CO2_eq,oil_eq,FETP_DCB_eq,P_eq,HTP_DCB_eq,
                                                   U235_eq,METP_DCB_eq,N_eq,Fe_eq,m2_eq,CFC11_eq,
                                                   PM10_eq,NMVOC_eq,SO2_eq,TETP_DCB_eq,m2aU_eq,m3_eq)
                                            straw.(m2aA_eq,CO2_eq,oil_eq,FETP_DCB_eq,P_eq,HTP_DCB_eq,
                                                   U235_eq,METP_DCB_eq,N_eq,Fe_eq,m2_eq,CFC11_eq,
                                                   PM10_eq,NMVOC_eq,SO2_eq,TETP_DCB_eq,m2aU_eq,m3_eq)
$$endif.upStream
                                           / ;
set source_emiHerd(source,emissions) /
                                     staSto.(NH3,N2O,NOx,N2,N2Oind,CH4,TSP,PM25,PM10)
                                     entFerm.CH4
            $$iftheni.upStream "%upstreamEF%" == "true"
                                     input.(m2aA_eq,CO2_eq,oil_eq,FETP_DCB_eq,P_eq,HTP_DCB_eq,
                                            U235_eq,METP_DCB_eq,N_eq,Fe_eq,m2_eq,CFC11_eq,
                                            PM10_eq,NMVOC_eq,SO2_eq,TETP_DCB_eq,m2aU_eq,m3_eq)
                                     machine.(m2aA_eq,CO2_eq,oil_eq,FETP_DCB_eq,P_eq,HTP_DCB_eq,
                                            U235_eq,METP_DCB_eq,N_eq,Fe_eq,m2_eq,CFC11_eq,
                                            PM10_eq,NMVOC_eq,SO2_eq,TETP_DCB_eq,m2aU_eq,m3_eq)
                                     building.(m2aA_eq,CO2_eq,oil_eq,FETP_DCB_eq,P_eq,HTP_DCB_eq,
                                            U235_eq,METP_DCB_eq,N_eq,Fe_eq,m2_eq,CFC11_eq,
                                            PM10_eq,NMVOC_eq,SO2_eq,TETP_DCB_eq,m2aU_eq,m3_eq)
                                     stable.(m2aA_eq,CO2_eq,oil_eq,FETP_DCB_eq,P_eq,HTP_DCB_eq,
                                            U235_eq,METP_DCB_eq,N_eq,Fe_eq,m2_eq,CFC11_eq,
                                            PM10_eq,NMVOC_eq,SO2_eq,TETP_DCB_eq,m2aU_eq,m3_eq)
                                     straw.(m2aA_eq,CO2_eq,oil_eq,FETP_DCB_eq,P_eq,HTP_DCB_eq,
                                            U235_eq,METP_DCB_eq,N_eq,Fe_eq,m2_eq,CFC11_eq,
                                            PM10_eq,NMVOC_eq,SO2_eq,TETP_DCB_eq,m2aU_eq,m3_eq)
                                     silo.(m2aA_eq,CO2_eq,oil_eq,FETP_DCB_eq,P_eq,HTP_DCB_eq,
                                            U235_eq,METP_DCB_eq,N_eq,Fe_eq,m2_eq,CFC11_eq,
                                            PM10_eq,NMVOC_eq,SO2_eq,TETP_DCB_eq,m2aU_eq,m3_eq)
            $$endif.upStream
                                     / ;

set source_emiCrops(source,emissions) /
                                      past.(NH3,N2O,NOx,N2,N2Oind,CH4)
                                      manAppl.(NH3,N2O,NOx,N2,N2Oind)
                                      minAppl.(NH3,N2O,NOx,N2,N2Oind)
                                      field.(NO3,N2Oind,CO2,N2O,TSP,PM25,PM10,P)
      $$iftheni.upStream "%upstreamEF%" == "true"
                                      input.(m2aA_eq,CO2_eq,oil_eq,FETP_DCB_eq,P_eq,HTP_DCB_eq,
                                             U235_eq,METP_DCB_eq,N_eq,Fe_eq,m2_eq,CFC11_eq,
                                             PM10_eq,NMVOC_eq,SO2_eq,TETP_DCB_eq,m2aU_eq,m3_eq)
                                      machine.(m2aA_eq,CO2_eq,oil_eq,FETP_DCB_eq,P_eq,HTP_DCB_eq,
                                             U235_eq,METP_DCB_eq,N_eq,Fe_eq,m2_eq,CFC11_eq,
                                             PM10_eq,NMVOC_eq,SO2_eq,TETP_DCB_eq,m2aU_eq,m3_eq)
                                      building.(m2aA_eq,CO2_eq,oil_eq,FETP_DCB_eq,P_eq,HTP_DCB_eq,
                                             U235_eq,METP_DCB_eq,N_eq,Fe_eq,m2_eq,CFC11_eq,
                                             PM10_eq,NMVOC_eq,SO2_eq,TETP_DCB_eq,m2aU_eq,m3_eq)
      $$endif.upStream
                                      / ;


$ifi not defined chain set chain /""/;

   set curChain(chain);
   option kill=curChain;

   set chain_source(chain,source) /

$iftheni.manure "%manure%"=="true"
                                           (set.manChain).staSto
                                           (set.manChain).manAppl
$endif.manure
                                           "".past
                                           "".minAppl
                                           "".field
                                           "".entFerm
   $$iftheni.upStream "%upstreamEF%" == "true"
                                           "".input
                                           "".machine
                                           "".building
                                           "".stable
                                           "".silo
                                           "".straw
   $$endif.upStream
                                           / ;

  set emCat "Emission categories according to ReCiPe(2016)"
  /
       ALOP           "agricultural land occupation"
       GWP            "climate change"
       FDP            "fossil depletion"
       FETPinf        "freshwater ecotoxicity"
       FEP            "freshwater eutrophication"
       HTPinf         "human toxicity"
       IRP_HE         "ionising radiation"
       METPinf        "marine ecotoxicity"
       MEP            "marine eutrophication"
       MDP            "metal depletion"
       NLTP           "natural land transformation"
       ODPinf         "ozone depletion"
       PMFP           "particulate matter formation"
       POFP           "photochemical oxidant formation"
       TAP            "terrestrial acidification"
       TETPinf        "terrestrial ecotoxicity"
       ULOP           "urban land occupation"
       WDP            "water depletion"
/;

  set resiEle "elements for calculation of emissions from crop residues"

/
                                           duration  "Duration of cropped system"
                                           freqHarv  "frequency of harvesting"
                                           DMyield   "Dry matter content of yield"
                                           DMresi    "Dry matter content of  above ground residues"
                                           aboveRat  "Ratio of above ground crop residues to yield"
                                           aboveN    "Nitrogen content of the above-ground crop residues"
                                           belowRat  "Ratio of below ground crop residues to above ground biomass"
                                           belowN    "Nitrogen content of below ground crop residues"
                                          /;

$endif.envAcc


* -----------------------------------------------------------------------------
*
*   Sets related to social accounting module
*
* -----------------------------------------------------------------------------

   set soci "unit of feed/food indicator" /protein,calories/;

*-------------------------------------------------------------------------------
*
*  Sets related to biomass quantification as indicator
*
*-------------------------------------------------------------------------------

   set bioMassUnit "Different units for biomass quantification" /mass,cerealUnit/;

* -----------------------------------------------------------------------------
*
*   Sets corresponding to biomas exchange with external biogas plant
*
* -----------------------------------------------------------------------------

$iftheni.biogasex "%AllowBiogasExchange%" == "true"

   set biogas_exchangeKTBL(prods) "crops that can be exported to external biogas plant"
$gdxin "%datDir%/%cropsFile%.gdx"
  $$load biogas_exchangeKTBL = biogas_feed
$gdxin
     set biogas_exchange(prods) "all possible biogas inputs"

                               /
                               set.prodsResidues
                               set.biogas_exchangeKTBL
                               set.grasSil
                               /;

$endif.biogasex

* -----------------------------------------------------------------------------
*
*   Sets corresponding to only biogas production
*
* -----------------------------------------------------------------------------

$iftheni.biogas %biogas% == true

set biogas_feed(crops)
$gdxin "%datDir%/%cropsFile%.gdx"
  $$load biogas_feed
$gdxin
     set biogasFeedM(*) "all possible biogas inputs"

                               /
                               set.biogas_feed
                               set.cropsResidues_prods
                                set.grasSil
                               /;

     set crM(biogasFeedM)     "all possible crop inputs for biogas"
                              /
                              set.biogas_feed
                              set.cropsResidues_prods
                                set.grasSil
                              /;

     set maM        "all possible manure inputs for biogas"
                              /
                              manCatt
                              manpig
                              /;

     set curmaM(maM);
         option kill = curMaM;
     set Chain / LiquidPig,LiquidCattle /;
     set manChain / LiquidPig,LiquidCattle /;

     set manchain_maM(manchain,maM);
   $$ifi "%pigherd%"=="true"      manchain_maM("LiquidPig","manPig")     = YES;
   $$ifi "%cattle%"=="true"       manchain_maM("LiquidCattle","manCatt") = YES;

set bhkw "different bhkw sizes" /
                                 150KW       "150kW engine"
                                 250kW       "250kW engine"
                                 500KW       "500kW engine"
                                /;

set inputClass "different inputClasses according to EEG 2012"
                                /
                                 inputCl1
                                 inputCl2
                                /;

set curBhkw(bhkw)               /
                                 set.selBhkws
                                /;

alias(curBhkw,curBhkw1);

set eeg "All EEGs"              /
                                 E2004   "EEG 2004"
                                 E2009   "EEG 2009"
                                 EM2009  "EEG 2009 with manure boni"
                                 E2012   "EEG 2012"
                                 EDM2012 "EEG 2012 with direct marketing"
                                 EDM2014 "EEG 2014 with direct marketing"
                                 ESPEM0914  "EEG 2014 with scrapping premium based on 2009 payment"
                                 ESPEDM0914 "EEG 2014 with scrapping premium based on 2009 payment with manure"
                                 ESPE1214  "EEG 2014 with scrapping premium based on 2012 payment"
                                 ESPEDM1214 "EEG 2014 with scrapping premium based on 2012 payment with direct marketing"

                                /;
alias(eeg,eeg1);

set curEeg(eeg)                  /
                                 set.selEEgs
                                /;
   alias(curEeg,curEeg1);

set
       eegDeg(eeg)     "For EEGs with degression of base rate"             / E2009, EM2009, E2012 /
       eegDif(eeg)     "For EEG s which consider different input classes"  / E2012, EDM2012, ESPE1214, ESPEDM1214 /
       eegMan(eeg)     "For EEG's based on EEG 2009 with manure"           / EM2009, ESPEM0914, ESPEDM0914/
       eegDM(eeg)      "Includes all EEG direct marketing options"         / EDM2012, EDM2014, ESPEDM0914, ESPEDM1214/
       eegScen(eeg)    "Includes all EEG's with Scrapping premium"         / ESPEM0914, ESPEDM0914, ESPE1214, ESPEDM1214/
       eegRated(eeg)   "Includes all EEGs based on rated output"           / E2009, EM2009, E2012, EDM2014,EDM2012,ESPEDM0914,ESPEM0914, ESPE1214, ESPEDM1214/
       spot            "Time of selling electricity on the market"         / lp "times of low prices",
                                                                             hp "times of high prices"/
       effic           "efficiency of conversion for heat and electricity" /he,el/
       iH              "investment horizon"       /
                                                  iH7      "reinvestment after seven years",
                                                  iH10     "reinvestment after ten years",
                                                  iH20     "reinvestment after twenty years"
                                                  /
          iH20(iH)        "Investment horizon of biogas fermenter"            /iH20/
   ;

   $$iftheni.herd %herd% == true
      set maM_herds(maM,herds) "set to define connection of manure and herds"  /

*  ---- Manure and herd connection for pig herds
        $$iftheni.sow "%farmBranchSows%" == "on"
         manPig.sows
         manPig.piglets
        $$endif.sow

        $$iftheni.fat "%farmBranchFattners%" == "on"
         manPig.earlyFattners
         manPig.midFattners
         manPig.lateFattners
         manPig.Fattners
        $$endif.fat

*  ---- Manure and herd connection for dairy herds
         $$iftheni.ch "%cowherd%"=="true"
         manCatt.cows
         manCatt.heifsSold
         manCatt.heifsBought
         manCatt.Remonte
         $$endif.ch
         $$iftheni.c "%cattle%"=="true"
            $$if declared bulls  manCatt.(set.bulls)
         $$endif.c

        /;
   $$endif.herd

   $$iftheni.dyn not "%dynamics%" == "Comparative-static"
set eeg_t(eeg,tAll) /

       $$ife %firstYear%<2008    e2004.(%firstYear%*2008)
                         e2009.(2009*2012)
                         em2009.(2009*2012)
                         e2012.(2012*2013)
                         edm2012.(2012*2013)
                         edm2014.(2014*2015)

                         espem0914.(2014*%lastYear%)
                         espedm0914.(2014*%lastYear%)
                         espe1214.(2014*%lastYear%)
                         espedm1214.(2014*%lastYear%)
                 /;
   $$endif.dyn

set newEeg_oldEeg(eeg,eeg1);
newEeg_oldEeg(eeg,eeg)             = YES;
newEeg_oldEeg("e2009","e2004")     = YES;
newEeg_oldEeg("em2009","e2004")    = YES;
newEeg_oldEeg("em2009","e2009")    = YES;
newEeg_oldEeg("e2012","e2009")     = YES;
newEeg_oldEeg("e2012","em2009")    = YES;
newEeg_oldEeg("edm2012","e2009")   = YES;
newEeg_oldEeg("edm2012","em2009")  = YES;
newEeg_oldEeg("edm2014","e2012")   = YES;
newEeg_oldEeg("edm2014","edm2012") = YES;
newEeg_oldEeg("espem0914","em2009") = YES;
newEeg_oldEeg("espedm0914","em2009") = YES;
newEeg_oldEeg("espedm0914","e2009") = YES;
newEeg_oldEeg("espe1214","e2012") = YES;
newEeg_oldEeg("espedm1214","e2012") = YES;
newEeg_oldEeg("espedm1214","edm2012") = YES;

   $$iftheni.exist %existBio% == true

     set   iniBhkW(bhkw) / %curBhkwSize% /;
     set   iniEEG(eeg)  / %iniEEG%      /;
     set   iniConstr(tOld) / %biogasYear% /;

   $$endif.exist

$endif.biogas

* -----------------------------------------------------------------------------
*
*   Parameters used in coefficient generator and model equations
*   (Note: some are defined as variables. These are used during
*          the bi-level programming based calibration and controlled
*          by the outer estimator. They are fixed in normal simulation)
*
* -----------------------------------------------------------------------------

$ondotl

    parameter
              p_iniLand(landType,soil)                        "Available land"

$ifi "%parsAsVars%"=="true"         variable
$ifi defined herds  p_vCost(herds,breeds,t)                         "Variable costs not covered by restrictions, herds"
              p_vCostC(crops,till,intens,t)                   "Variable costs not covered by restrictions, crops"
         parameter
              p_contractLab(crops,till,intens)                "Contract labour requirements of crops, hours per year"
              p_hcon(t)                                       "Yearly household consumption in Euro"
              p_pland(plot,tFut)                              "Price for additional land in Euro"
              p_landRent(plot,tFut)                           "Rent rate per ha"
              p_outputPrices(prods,sys)                         "output prices (from interface or regional data"

              p_OCoeff(acts,prods,allBreeds,t)                "Output coefficients, yearly"
$ifi "%parsAsVars%"=="true" variable
              p_OCoeffC(crops,soil,till,intens,prods,t)       "Crop output coefficients, yearly"
              p_OCoeffM(crops,soil,till,intens,prods,m,t)     "Crop output coefficients, monthly and yearly"
         parameter
              p_storageLoss(*)                                 "Post harvest losses of roughages"
              p_OCoeffResidues(crops,soil,till,intens,prods,t) "Crop residue output coefficient"
              p_yieldReducN(crops,intens)                      "Yield reduction for different N-reductions"


              p_monthlyLabh(t,m)                              "Monthly max. labour hours from family labour (exceeds yearly to allow for peaks"
              p_iniLiquid                                     "Initial liquidity"
              p_machAttr(machType,machAttr)                   "Machine attributes"
              p_iniMach(machType,machLifeUnit)                "Initial machinery in operating time/ha/m3"
              p_lifeTimeM(machType,machLifeUnit)              "Physical lifetime of machines in operating time/ha/m3"
              p_machNeed(*,till,intens,*,*)                   "Demand by specific crop ha or kg N applied"
              p_priceMach(machType,t)                         "Price of machinery"
              p_opInputReq(Crops,till,opAttr,*)               "input requirements of KTBL operations as calcualted in regression"

$ifi "%parsAsVars%"=="true" variable
              p_vPriceInv(invTypes)                           "Price level for investments, used in calibration"
              p_price(*,sys,t)                                "Product price, specific for year and state of nature"
              p_InputPrice(inputs,sys,t)                       "Input price, specific for year and state of nature"
         parameter

              p_interest(creditType)                          "Interest in %"
              p_disCountRate                                  "Private discount rate for EMV in %"
              p_interestGain                                  "Interest gained on accumulated liquidity in %"

              p_nutNeed(crops,soil,till,intens,nut,t)           "Nutrient need for each crop,soil, tillage, intensity"
              p_pastNeed(crops,soil,till,intens,nut,t)          "Nutrient need for grazing for each crop,soil, tillage, intensity"

              p_nutInSynt(syntFertilizer,nut)                   "Nutrient content of different fertilizers"
              p_NfromLegumes(Crops,sys)                         " N fixation from legumes for different crops, enters nutrient balance and fertilizer planning"
              p_NfromVegetables(Crops)                         " N fixation from vegetables for different crops, enters nutrient balance and fertilizer planning"
              p_nutContent(crops,prods,sys,nut)                 "Nutrientcontent per unit of harvested material"

$iftheni.fert %Fertilization% == "OrganicFarming"
              p_NfixLeg(crops,soil,till,intens,t)               "Nitrogen fixed by each legume in kg/ha"
              p_NSaldoLeg(crops,soil,till,intens,t)             "Nitrogen Saldo for each legume in kg/ha"

              p_NcontShoot(crops,sys)                           "N content in kg N /dt FM in main and by-product (without residues and roots)"
              p_NcontPlant(crops,sys)                           "N content in kg N /dt FM in main and by-product, residues and roots"
              p_Nroots(crops,soil,till,intens,t)                "Nitrogen in crop residues and roots"
              p_Nbyproduct(crops,soil,till,intens,t)            "Nitrogen in non harvested byproduct"
              p_Nresidues(crops,soil,till,intens,t)             "N in crop resiudes remaining on field"
              p_NPlantSenescence(crops,soil,till,intens,t)      "Nitrogen loss through plant senescence"
              p_legshare(leg)                                   "legume share of legume crops"
              p_Ndfa(leg)                                       "share of nitrogen derived from atmosphere"
              p_NExtractShoot(crops,soil,till,intens,t)         "N extraction of main product and by-product"
              p_NExtractPlant(crops,soil,till,intens,t)         "N extraction of total plant (main product, by-product, resiudes and roots)"
              p_Nresidues(crops,soil,till,intens,t)             "N in crop resiudes remaining on field"
              p_NUpCoeffRes(crops,soil)                         "Uptake coefficient of N from crop residues, subject to C/N in crop residues and length of vegetation period"
              p_NfromCropRes(crops,soil,till,intens,t)          "Uptake of N from crop residues"
              p_nutSeeds(crops)                                 "Nitrogen content of seeds (kg N/dt)"
              p_NfromSeeds(Crops,till,intens)                   "N provision by seeds (kg N/ha)"
              p_NSoilDelivery(crops)                            "N delivery from soil during vegetation periode"
              p_NDenitrification(crops)                         "Amount of N (kg N/ha) lost through denitrification"

$endif.fert
              p_nutCont(inputs,nut)                           "N and P2O5 content of inputs according to farmgate balance"
              p_nutContInput(inputs,nut)                      "N and P2O5 content of inputs in relation to v_buy"
              p_nutContOutput(prodsYearly,nut)                "N and P2O5 content of outputs in relation to v_saleQuant"

              p_nutSurplusMax(crops,plot,till,intens,nut,t)   "Max N losses per crop and year"
              p_plotSize(plot)                                   "Plot sizes in hectare"
              p_buyPlotSize                                      "Additional land bought with one buying plot activity"
              p_LegPoolItself(crops,soil,till,intens,nut,t)

              p_negDevPen                                                   "Relative penalty for negative deviations"   / 0 /
              p_expShortFall                                                 "Expected shortfall trigger" / 0 /

              p_costQuant(crops,till,intens,inputs)                 "Input costs per ha of crop (in EUR/ha), water in m3/ha"
              p_inputQuant(crops,till,intens,inputs,*)              "Input quantity demand per ha of crop"
$ifi "%parsAsVars%"=="true"         variable
              v_costQuant(crops,inputs)                             "Multiplier for input demand used in calibration"
         parameter
              p_shareFood(*,soci)
              p_NutFromSoil(crops,soil,till,nut,t)               "Nutrient delivered from soil for fertilizing planning"

$iftheni.manure "%manure%"=="true"


              p_EFapplMan(crops,manType,ManApplicType,nut2,m)       "Share of NTAN,NORG and P in manure usable for crops"
              p_nutEffFOPlan(mantype,crops,m,nut)                   "defines share of N that is accounted in fertilizer planning for dairy and cattle manure"
              p_iniSilos(manChain,silos,tOld)                       "Initial silos for manure"
              p_lossFactorSto(mantype,nut2,manChain)                 "Loss factor from storage for calculation of p_nut2inman depending on losses"
              p_nut2inMan(*,manType,manChain)                        "Different compositions of manure to empty storage"

              p_EFSta(Nemissions,manChain)                           "EF for emissions from stable"
              p_EFSto(Nemissions,manChain)                           "EF for emissions from storage"
              p_EFStaSto(Nemissions,manChain)                        "EF for combined emissions from stable and storage"
              p_ManureStorageNeed                                    "Need of manure storage capacity, calculated as share of annual manure excretion"
$endif.manure


$iftheni.herds defined herds

         parameter
              p_nutExcreDueV(duevHerds,feedRegime,allNut)           "defines N(kg N/head) and P in manure according to DueV"
              p_iniHerd(herds,breeds)                               "Initial herds"
              p_prodLength(herds,breeds)                            "Production length of animal processes in month"
              p_age(herds,breeds)                                   "Age of different herds used to calculate more detailed LU (in days)"
              p_manQuantMonth(herds,manChain)                       "Manure output, m3 per month"
              p_NTANshare(duevHerds)                                "Share of NTAN from total N by different herds"
$endif.herds
*
* --- this also required for the bio-gas branch
*
$ifi defined feedRegime p_nut2inManNoLoss(nut2,feedRegime,manType)  "Different composition of manure without any losses from stable and storage"


$ifthen.stables defined stables

              p_iniStables(stables,hor,tOld)                        "Initial stable in specific vintage category"
              p_stableSize(stables,stableTypes)                     "Stables and related stable places for different herds"
              p_priceStables(stables,hor,t)                         "Price of stables"
              p_minInvStableCost(stableTypes,hor,t)                    "Minimum cost of investments in stable"
              p_stableLab(stables,m)                                "Working time per type of stable (fix, independent of herd)"


              p_manStorCap(manChain,stables)                        "manure storage capacity of different stables subfloor"
              p_replaceYear(stableTypes,hor)                        "Year when the lifetime of existing stable is over"

$endif.stables

              p_nutEffectivPastDueVNv                               "defines share of N in manure excreted on pasture that has to enter crop balance according to DueV"
              p_nutEffectivDueVAl                                   "defines share of N in manure that is considered for limit of organic N application in FO"

              p_feedContFMton(feeds,feedAttr)                       "Nutrient contet (kg) per ton FM of feed"

              p_densM                                               "Density of methane"
              p_avLiveWgt(*,allBreeds)                              "Average life weight of specific animal category"
              p_nutEffectivDueVAlPast                               "Defines share of N in manure that is considered for limit of organic N application in FO on pasture"

              p_carbonTax                                            "Carbon tax in Euro per ton"
              p_EFApplMinNH3(syntFertilizer)                         "EF NH3 from min fertilizer application"
              p_EFApplMin(*)                                         "EF N-emissions from N apllication (manure + min fert)"
              p_LowEmiTechFD07                                       "Binary for having low-emissions manure application techniques under FO 2007"
              p_crop_op_per_till(crops,operation,labPeriod,till,intens)"crop operations per labperiod"
              p_EFN2Oind                                             "EF for emissions from reactive N-species"
              p_EFpasture(Nemissions)                                "EF for emissions from pasture"

$iftheni.envAcc "%envAcc%"=="true"

              p_Ym(*,*)                                             "methane conversion factor, as fraction of gross energy in feed converted to methane (0.065 means 6.5%)"
              p_MCFPast                                             "Methane conversion factors for manure excreted on pasture"
              p_EFN2OindLeach                                        "EF for emissions from leached reactive N-species"
$ifi "%feedAddon%" == true p_feedAdd(feeds)                                      "Emission reduction of the feed additive "
           $$iftheni.manure "%manure%"=="true"

              p_MCF(manStorage,manChain)                            "Methane conversion factors for each manure management system"
              p_oTSMan(manChain)                                    "Share of volatile solids as share from total dry matter"
              p_avDmMan(manChain)                                   "Average dry matter content of cattle manure"
              p_Bo(manChain)                                        "Maximum methane producing capacity for manure produced by livestock in m�CH4/kg"
              p_humfact(ManApplicType)                               "Humus factor of organic fertilizers Humusäquivalent per t"
           $$endif.manure


           $$iftheni.upStream "%upstreamEF%" == "true"
              p_EFInput(inputs,emissions)                            "EF for provision of inputs"
              p_EFInputAnimal(inputs,emissions,source)               "EF for provision of inputs"
              P_transport(emissions,source)                          "EF for animals transport in kgkm"
              p_EFInputCrops(crops,till,intens,inputs,emissions)     "EF for provision of crop specific inputs"
              p_EFoperations(crops,plot,till,intens,operation,emissions,t)  "EF for crop operations"
              p_EFBuild(buildings,buildType,emissions)               "EF for buildings related to cropping (silos, storage)"
              $$iftheni.herd "%herd%" == "true"
                p_EFSilo(silos,manStorage,emissions)                   "EF for manure storage outside from stable"
                p_EFStable(stables,hor,emissions)                      "EF for emissions from building a stable"
                $$endif.herd
              p_EFmachines(machType,machLifeUnit,emissions)          "EF for emissions from buying a machine"
           $$endif.upStream

              p_EFLime(inputs)                                       "EF for CO2 emissions from lime application"
              p_efDiesel(inputs)
              p_EfLeachFert(crops,m)                                 "Leached N from N fertilization (manure and fertilizer)"
              p_cropResi(crops,resiEle)                              "Parameters for calculation of cropresidue emissions"
              p_LeachNorm(m)                                         "Average leaching per month from N mineralization"
              p_CfIntensTill(m,crops)                                "Month and crops with intensive cultivation"
              p_CfNLeachTill(m)                                      "Additional mineralization in month with intense cultivation in kg N per ha"
              p_CfNLeachGrass(crops)                                 "Reduced mineralization under grassland"
              p_leachPast(m)                                         "Leaching losses from manure excreta on pastures"
              p_humCrop(crops)                                       "Humus degradation through crop cultivation in Humusäquivalent pro ha"
              p_resiCrop(crops,soil,till,intens,t)                    "Amount of crop residues per crop in dt per ha"
              p_resiInc(crops)                                       "Effect of crop residues on humus in Humusäquivalent pro dt"
  $$ifi "%herd%"=="true" p_EFpmfHerds(herds,feedregime,manchain,emissions)"Emission factor for particulate matter emission from stables "
              p_EFpmfCrops(crops,operation,emissions)                "Emission factor for particulatematter emission from cropping"
              p_erosion                                              "Average soil loss per year in kg P per ha"
              p_lossfactor                                           "share of eroded soil reaching surface waters"
              p_PContSoil                                            "P content of the eroded soil in kg P per t"
              p_PAccuSoil                                            "P accumaulation in eroded soil"
              p_PLossLeach(*)                                        "Average amount of P lost through leaching"
              p_soilFactLeach                                        "Correction factor for P leaching for soil types"
              p_PSoilClass                                           "Correction factor for P content classes "
              p_PLossFert(*)                                         "P fertilization factor"
              p_PLossRun(*)                                          "Average amount of P lost through runoff"
              p_soilFactRun                                          "Correction factor for P runoff for soil types"
              p_slopeFactor                                          "Correction factor for P runoff for different slopes"
              p_corMass(emissions)                                   "Correction of atomic weight of N emissions"
              p_emCat(emCat,emissions)                               "Characterizationfactor for emissions"
              p_cerealUnit(prods)                                    "Cereal units for different prodcuts"
              p_MonthAfterLeg(crops,m)                               "Mineralisation of Legumes, six month after harvest in month with Mineralisation"

$endif.envAcc

      ;

       $$ifi defined p_prodLength option kill=p_prodLength;
       $$ifi declared herds_from_herds option kill=herds_from_herds;

$offmulti
