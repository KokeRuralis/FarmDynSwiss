********************************************************************************
$ontext

   FARMDYN project

   GAMS file : SCEN_GEN.GMS

   @purpose  : Define scenarios via GAMS, execute them with exp_starter,
               collect results, filter out relevant parts for meta-modelling
               and store them in a GDX container

   @author   : Wolfgang Britz
   @date     : 07.06.12
   @since    :
   @refDoc   :
   @seeAlso  : exp_starter.gms
   @calledBy :

$offtext
********************************************************************************
$OffLISTING
$OffLog
*
$setglobal pgmName Scenario generator
*
*------------------------------------------------------------------------------
*
*   Define globals / load farm from interface or given example
*
*------------------------------------------------------------------------------
*
*   ---- define the example farm to load
*
$include 'util/global_settings.gms'
$onglobal
$include 'incgen/expInc.gms'


$ifthen not defined breed
$onempty
 set breed(*) //;
$offempty
$endif

$ifi "%Dynamics%"=="Comparative-static" $setglobal lastYearMax %lastYear%
$ifi "%Dynamics%"=="Comparative-static" $setglobal lastYear    %firstYear%
$ifi "%Dynamics%"=="Comparative-static" $setglobal lastYearMin %lastYear%

parameter p_prolongCalc;
$setglobal lastYear     %lastYear%
$setglobal lastYearCalc %lastYear%
$evalglobal lastOldYear %firstYear%-1

*
$include 'util/title1.gms'
$batinclude 'util/title.gms' "'Allow output'"

*
* --- check that certain farm branches are on/off depending on task
*
$iftheni.sows "%task%"=="Experiments sows"
 $$ifi "%farmBranchDairy%"       == "on" $abort "Dairy branch cannot be switched on with %task%"
 $$ifi not "%farmBranchSows%"    == "on" $abort "Sows branch must be switched on with %task%"
$endif.sows

$iftheni.fattners "%task%"=="Experiments fattners"
 $$ifi     "%farmBranchDairy%"    == "on" $abort "Dairy branch cannot be switched on with %task%"
 $$ifi not "%farmBranchFattners%" == "on" $abort "Fattners branch must be switched on with %task%"
$endif.fattners

$iftheni.arable "%task%"=="Experiments arable"
 $$ifi "%farmBranchDairy%"       == "on"  $abort "Dairy branch cannot be switched on with %task%"
 $$ifi "%farmBranchSows%"        == "on"  $abort "Sows branch cannot be switched on with %task%"
 $$ifi "%farmBranchFattners%"    == "on"  $abort "Fattners branch cannot be switched on with %task%"
 $$ifi not "%farmBranchArable%"  == "on"  $abort "Arable branch must be switched on with %task%"
$endif.arable

$iftheni.dairy "%task%"=="Experiments dairy"
 $$ifi "%farmBranchSows%"       == "on" $abort "Sows branch cannot be switched on with %task%"
 $$ifi "%farmBranchFattners%"   == "on" $abort "Fattners branch cannot be switched on with %task%"
 $$ifi not "%farmBranchDairy%"  == "on" $abort "Dairy branch must be switched on with %task%"
$else.dairy
 $$ifi not "%farmBranchArable%" == "on" $abort "Arable branch must be switched on with %task%"
$endif.dairy

$iftheni.beef "%task%"=="Experiments beef"
 $$ifi "%farmBranchSows%"       == "on" $abort "Sows branch cannot be switched on with %task%"
 $$ifi "%farmBranchFattners%"   == "on" $abort "Fattners branch cannot be switched on with %task%"
 $$ifi not "%farmBranchBeef%"   == "on" $abort "Beef branch must be switched on with %task%"
$endif.beef

$ifi "%farmBranchDairy%"    == "on" $setglobal herd true
$ifi "%farmBranchDairy%"    == "on" $setglobal dairyHerd true
$ifi "%farmBranchDairy%"    == "on" $setglobal cattle true
$ifi "%farmBranchDairy%"    == "on" $setglobal cowHerd true


$ifi "%farmBranchMotherCows%"    == "on" $setglobal herd true
$ifi "%farmBranchMotherCows%"    == "on" $setglobal mcHerd true
$ifi "%farmBranchMotherCows%"    == "on" $setglobal cattle true
$ifi "%farmBranchMotherCows%"    == "on" $setglobal cowHerd true

$ifi "%farmBranchSows%"     == "on" $setglobal herd         true
$ifi "%farmBranchSows%"     == "on" $setglobal pigHerd      true

$ifi "%farmBranchFattners%" == "on"  $setglobal herd         true
$ifi "%farmBranchFattners%" == "on"  $setglobal pigHerd      true

$ifi "%farmBranchBeef%" == "on"  $setglobal herd         true
$ifi "%farmBranchBeef%" == "on"  $setglobal beefHerd     true
$ifi "%farmBranchBeef%" == "on"  $setglobal cattle     true

$ifi %herd% == true     $ setglobal manure    true
$ifi "%AllowManureImport%" == "true" $ setglobal manure true

$onmulti
$iftheni.cowHerd "%dairyherd%"=="true"
   $$batinclude 'util/embedd.gms' p_heifsAttrGUIBas   p_heifsAttr %basBreed%_f
   $$ifi "%crossBreeding%"=="true" $$batinclude 'util/embedd.gms' p_heifsAttrGUICross p_heifsAttrCross %CrossBreed%_f
$endif.cowHerd
$iftheni.beef   "%farmBranchBeef%"=="on"
   $$batinclude 'util/embedd.gms' p_BullsAttrGUIBas   p_bullsAttr %basBreed%_m
   $$ifi "%crossBreeding%"=="true" $$batinclude 'util/embedd.gms' p_BullsAttrGUICross p_bullsAttrCross %CrossBreed%_m
$endif.beef
$iftheni.mc "%farmBranchMotherCows%"=="on"
   $$batinclude 'util/embedd.gms' p_bullsAttrGuiMC   p_bullsAttrMc %motherCowBreed%_m
   $$batinclude 'util/embedd.gms' p_heifsAttrGUIMC   p_heifsAttrMC %motherCowBreed%_f
$endif.mc
$ontext
* ---- Currently not working
$iftheni.cattle "%cattle%" == "true"
    $iftheni.cross "%crossBreeding%"=="false"
      $$setglobal crossBreeding false
*$$iftheni.mcn not "%farmBranchMotherCows%"=="on"
      set %basBreed%_f        /system.empty/;
      set %basBreed%_f_sold   /system.empty/;
      set %basBreed%_f_bought /system.empty/;
*  $$iftheni.beefy
      set %basBreed%_m        /system.empty/;
      set %basBreed%_m_sold   /system.empty/;
      set %basBreed%_m_bought /system.empty/;
*  $$endif.beefy
*$$endif.mcn
*  $$iftheni.mcX "%farmBranchMotherCows%"=="on"
      set %motherCowBreed%_m        /system.empty/;
      set %motherCowBreed%_m_sold   /system.empty/;
      set %motherCowBreed%_m_bought /system.empty/;
      set %motherCowBreed%_f        /system.empty/;
      set %motherCowBreed%_f_sold   /system.empty/;
      set %motherCowBreed%_f_bought /system.empty/;
*  $$endif.mcX
  $endif.cross
$endif.cattle
$offtext

$ifi "%cattle%"=="true" $batinclude 'util/grasAttr.gms'
$offmulti
$include 'model/templ_decl.gms'
 set resDummyItems / fte,sum,squant,quant,offFarm,earn,totLand,sumInv,oils,cashCrops,crops /;

 scalar p_dummy / 0/;
*
*------------------------------------------------------------------------------
*
* Count the factors
*
*------------------------------------------------------------------------------
*
  set s_selFactors "Factors as defined by user on interface" /
      set.selFactorsGene
      set.selFactorsCrops
      $$if defined selFactorsSows      set.selFactorsSows
      $$if defined selFactorsDairy     set.selFactorsDairy
      $$if defined selFactorsArab      set.selFactorsArab
      $$if defined selFactorsFattners  set.selFactorsFattners
      $$if defined SelFactorsBeef      set.selFactorsBeef

  /;
*
* -- the following defines all factors, including those
*    calculated from the chosen onces. The $onMulti allows
*    to have duplicate entries
*
  set allFactors /
      set.s_selFactors
  /;
$onmulti
  set allFactors /
     conc1Price
     conc2Price
     conc3Price
     aks
     wageRateFull
     wageRateHalf
     wageRateHourly
     lastYear
     sowsPerAk
     sowsPerHaArab
     nArabLand
     haPerAk

     milkYield
     cowsPerAk
     nCows
     CowsLUdensity

     nFattners
     maxStockingRate
     porkPrice
     pigletPrice
     minFuPrice
     soyBeanMealPrice
     soyBeanOilPrice
     maizCCMPrice
     fattnersPerAk
     fattnersPerHaArab
     WinterWheatPrice
     WinterRyePrice
     SummerTriticalePrice
     WinterBarleyPrice
     SummerCerePrice
     manExportVol




  /;
  alias(allFactors,allFactors1);

*
* --- these are factors used for the LHS as chocen by the user
*
  set factors(allFactors) /
      set.s_selFactors
  /;

 alias(factors,factors1);

  set outFactors(allFactors);
  outFactors(factors) = Yes;
*
* --- define factor ranges as edited on interface
*
 set minMax / min,max /;
 parameter p_ranges(*,minMax);
 p_ranges(selFactorsCrops,minMax)                                    = rangesFactorsCrops(selFactorsCrops,minMax);
 p_ranges(selFactorsGene ,minMax)                                    = rangesFactorsGeneral(selFactorsGene,minMax);
 $$if defined selFactorsSows     p_ranges(selFactorsSows,minMax)     = rangesFactorsSows(selFactorsSows,minMax);
 $$if defined selFactorsDairy    p_ranges(selFactorsDairy,minMax)    = rangesFactorsDairy(selFactorsDairy,minMax);
 $$if defined selFactorsArab     p_ranges(selFactorsArab,minMax)     = rangesFactorsArable(selFactorsArab,minMax);
 $$if defined selFactorsFattners p_ranges(selFactorsFattners,minMax) = rangesFactorsFattners(selFactorsFattners,minMax);
 $$if defined selFactorsBeef     p_ranges(selFactorsBeef,minMax)     = rangesFactorsBeef(selFactorsBeef,minMax);

$if not setglobal firstYear $setglobal firstYear 2011
$eval firstYear   round(%firstYear%)

  set allYears / %firstYear% * 2100 /;
  parameter calyea(allYears);
  calyea(allYears) = allYears.pos + %firstYear% -1;
  display calyea;

  set years(allYears);


$eval mDraws round(%nDraws%)

$ife %mDraws%>999 $setGlobal nDraws   %mDraws%
$ife %mDraws%<999 $setGlobal nDraws  0%mDraws%
$ife %mDraws%<99  $setGlobal nDraws 00%mDraws%


 set draws   / draws0001*draws%nDraws%/;

 scalar p_n;p_n=card(draws);

 parameter p_cor(*,*);
 display factors;
 $$setglobal outputFile   "%scrdirR%/fromR"

$iftheni.onlyCollect %onlyCollectResults% == false
*
     $$if not exist "%rexe%" $abort "R script.exe not found / emty at " %rexe%;
*
*------------------------------------------------------------------------------
*
* Use R to define the DOE
*
*------------------------------------------------------------------------------
*
 file rIncFile / "%curDir%/rBridge/incFile.r" /;
 put rIncFile;
 $$setglobal outputFileD  "%scrdir%/fromR"
 $$setglobal inputFile    "%scrdirR%/toR.gdx"

 put ' plotFile    <- "%resdirR%/scenGen/lhs_%scenDes%.pdf"; '/;
 put ' outputFile  <- "%outputFile%"; '/;
 put ' inputFile   <- "%inputFile%"; '/;
 put ' useCorr     <- "%useCorr%"; '/;
 put ' useColors   <- "true"; '/;
 put ' maxRunTime  <- %maxRunTime%; '/;
    putclose;
*
*    --- set correlation matrix
*
*        correlation coefficients are derived from data collections from AMI for prices and
*        from LWK-NRW (Milchviehreport NRW, verschiedene Jahrg�nge, 2007 bis 2011)as well as
*        a data collection of the LKV-NRW in 2012 for 5000 dairy farms in NRW. Correlation between
*        nCows and CowsPerAK stem from the Forschungsdatenzentrum des Bundes und der L�nder after
*        analysis on the "Landwirtschaftsz�hlung 2010", results were aligned with results derived
*        from KTBL (2010,p.541).

     table p_cor1(*,*)

                          WinterCerePrice SummerCerePrice MaizCornPrice WinterRapePrice SummerBeansPrice SummerPeasPrice PotatoesPrice SugarBeetPrice SummerTriticalePrice
     WinterCerePrice                            0.8            0.7            0.5            0.5                0.5          0.5             0.5             0.7
     SummerCerePrice                                           0.7            0.5            0.5                0.5          0.5             0.5             0.8
     MaizCornPrice                                                            0.5            0.5                0.5          0.5             0.5             0.7
     WinterRapePrice                                                                         0.5                0.5          0.5             0.5             0.5
     SummerBeansPrice                                                                                           0.7          0.5             0.5             0.5
     SummerPeasPrice                                                                                                         0.5             0.5             0.5
     PotatoesPrice                                                                                                                           0.5             0.5
     SugarBeetPrice                                                                                                                                          0.5
     SummerTriticalePrice
     ;
$ontext
*    p_cor(factors,factors1) = uniform(-0.5,0.5);
*    p_cor(factors,factors1)   = (p_cor(factors,factors1) + p_cor(factors1,factors))/2;

     p_cor("nCows","milkYield")              =  0.24;
     p_cor("nCows","cowsPerAk")              =  0.45;
     p_cor("nCows","stableYear")             = -0.1;
*    p_cor("maxcowsPerHa","stockingRate") =  0;
*    p_cor("stockingRate","stableYear")      = 0;
     p_cor("cowsPerAk","milkYield")          =  0.18;
     p_cor("milkPrice","conc1Price")         = 0.76;
*    p_cor("milkPrice","winterCerePrice")     = 0;
     p_cor("winterCerePrice","conc1Price")     = 0.70;
     p_cor("summerCerePrice","conc1Price")     = 0.70;

$offtext

* --- New correlation factors from LWZ 2010, different for dairy and arable


$iftheni.dairy "%task%"=="Experiments dairy"



      table p_cor(*,*)

                              nTotLand    cowsLUdensity    ShareGrassland   MonthManStore   soilSharePenriched    milkPrice    LowAppTechFD07   CostsManureExport  CostsManureExpInc
      nTotLand                                  -0.0796           -0.0322           0.0764                   0            0            0.2042                   0                  0
      cowsLUdensity                                               -0.1015          -0.0294                 0.5            0            0.0782                   0                  0
      ShareGrassland                                                               -0.0067                   0            0           -0.1859                   0                  0
      MonthManStore                                                                                          0            0                 0                   0                  0
      soilSharePenriched                                                                                                  0                 0                   0                  0
      milkPrice                                                                                                                             0                   0                  0
      LowAppTechFD07                                                                                                                                            0                  0
      CostsManureExport                                                                                                                                                            0
      CostsManureExpInc
      ;

$endif.dairy

$iftheni.fattners "%task%"=="Experiments fattners"

* --- Values are based on ASE 2016 (FDZ output from 25/01/18), only correlation between higly P-enriched soils and stocking density is guesswork

      table p_cor(*,*)

                            nArabLand   fattnersLUdensity  MonthManStore   soilSharePenriched   porkPrice    LowAppTechFD07    CostsManureExport     CostsManureExpInc
      nArabLand                                    -0.146         -0.1115                   0           0              0.32                    0                     0
      fattnersLUdensity                                           -0.0284                 0.5           0             -0.03                    0                     0
      MonthManStore                                                                         0           0                 0                    0                     0
      soilSharePenriched                                                                                0                 0                    0                     0
      porkPrice                                                                                                           0                    0                     0
      LowAppTechFD07                                                                                                                           0                     0
      CostsManureExport                                                                                                                                              0
      CostsManureExpInc
         ;


$endif.fattners



     p_cor(allFactors,allFactors1) $ p_cor1(allFactors,allFactors1) = p_cor1(allFactors,allFactors1);

     p_cor(allFactors,allFactors1) $ ( (not factors(allFactors)) or (not factors(allFactors1))) = 0;
     p_cor(factors,factors)  = 1;
*
*    --- ensure symmetry
*
     p_cor(factors,factors1) $ ( not p_cor(factors,factors1))
        = p_cor(factors1,factors);
*
*    --- replace zeros by 1.E-8
*
     p_cor(factors,factors1) $ ( not p_cor(factors,factors1)) = 1.E-8;
     display p_cor;
     set factor_name(*,*) / name.factors /;
     set scen_name(*,*) / name."%scendes%"/;

     execute_unload "%inputFile%" p_n,factor_name,scen_name,factors,p_cor;
     $$setglobal rFile "%curDir%/rbridge/lhs.r"

     $$if exist "%outputFileD%_doe.gdx" execute "rm %outputFileD%_doe.gdx"
     $$batinclude 'util/title.gms' "'execute %rexe% %rFile%'";
     $$if exist %rexe% execute "%rexe% %rFile% %curDir%/rBridge/incFile.r";

$endif.onlyCollect

*
* --- read output from LHS sampling provided by R
*
 parameter p_doe(*,*);
 execute_load "%outputFile%_doe" p_doe;
 if ( card(p_doe) eq 0, abort "Error generating doe, no data found";);
 display p_doe;

 parameter p_testDoe "Check for mean of draws";
 p_testDoe(factors) = sum(draws, p_doe(draws,factors))/card(draws);
 display p_testDoe;


*------------------------------------------------------------------------------
*
* Define scenarios to run
*
*------------------------------------------------------------------------------
*
* -- include file to generate, will be loaded by exp_starter
*
  file scenFile / "incgen/curScen.gms" /;
  alias(scenItems,allFactors);
*
* --- result related declaration
*
  PARAMETER p_res(*,*,*,*,*,*)
           p_meta;
  set resItems / mac,mean,cows,levl,margArab,margGras,margLand,herdRand,cropRand,ProfitDiff,manExportVol,profit/;


  parameter p_scenParam(draws,allFactors) "Numerical values for the scenario specific items";

*
* --- standard setting for aks
*
  p_scenParam(draws,"Aks") = %aks%;
*
* --- general mapping from DOE to factor ranges as defined on interface
*
  p_scenParam(draws,factors)   = p_doe(draws,factors) * (p_ranges(factors,"max")-p_ranges(factors,"min"))+p_ranges(factors,"min");

$iftheni.obDist %useObsDistr% == true

* --------------------------------------------------------------------------------------------------------------------------
*
*  DISTRIBUTION MAPPING
*
*  Mapping the observed distribution of the factors to the LHS sampling
*  Parameters calculated above based on uniform distribution are overwriten
*  for these factors where an empirical distribution is found
*
* --------------------------------------------------------------------------------------------------------------------------

   set percentile "percentiles for the distribution of the observed factor distribution"/ p1*p100 / ;
   parameter  p_scenParamDistD(draws,factors) "Control parameter for output with factors from empirical distribution"
*
*  --- Load csv file depending on farmtype
*      It comprises the observed distribution

   table p_dist(percentile,*) "Observed distribution for factors"

     $$ondelim
     $$ifi "%task%" == "Experiments fattners" $include 'expFarms/distribution_fattners_meta_obs.csv'
     $$ifi "%task%" == "Experiments dairy"    $include 'expFarms/distribution_dairy_meta_obs.csv'
     $$offdelim
   ;
   display p_dist;
*
*  --- define list of factor for which empirical distribution data are available
*
   set distFactors(factors);
   distFactors(factors) $ sum(perCentile, p_dist(perCentile,factors)) = yes;
*
*  --- Define the set percentileSelect which is 1 if the drawn number in LHS (0 to 1)
*      corresponds to the percentile. To do so, rounding is necessary.
*      The percentile 1 contains also LHS results in the range from 0 to 4 which are
*      deleted due to data protection reasons

   set percentileSelect(draws,percentile,factors) ;

   percentileSelect(draws,percentile,distFactors)
     $ ( round(p_doe(draws,distFactors)*100) eq perCentile.pos ) = Yes;

   percentileSelect(draws,"p1",distFactors)
     $ ( round(p_doe(draws,distFactors)*100) eq 0  ) = Yes ;

   display percentileSelect,p_doe;

*  --- For each factor, we relate the observed value for the percentile to the corresponding LHS result

   p_scenParam(draws,distFactors)
      = sum(percentileSelect(draws,percentile,distFactors), p_dist(percentile,distFactors));

*  --- Display only of the ScenParam which are derived from the observed distribution for checking

   p_scenParamDistD(draws,distFactors) =  p_scenParam(draws,distFactors);
   display p_scenParamDistD;

$endif.obDist
*
* --- wage rates are driven by wageRateFull and fixed differences
*
  p_scenParam(draws,"wageRateFull") $ (not factors("wageRateFull")) = p_inputPrices("Wage Rate full time","conv");


  p_scenParam(draws,"wageRateHalf"   ) = p_scenParam(draws,"wageRateFull") + (%wageDiffHalfToFull%);
  p_scenParam(draws,"wageRateHourly")  = p_scenParam(draws,"wageRateFull") + (%wageDiffHourlyToFull%);

* --------------------------------------------------------------------------------------------------------------------------
*
*     Settings for dairy farms
*
* --------------------------------------------------------------------------------------------------------------------------

$iftheni.task "%task%" == "Experiments dairy"
*
*  --- milk yields go in 200 kg steps and are shown as 50,52,54 ... round accordingly
*
   p_scenParam(draws,"milkYield")        = round( p_scenParam(draws,"milkYield")/2)*2;

 $$iftheni "%DefineHerdSize%" == "number"

   p_scenParam(draws,"nCows") $ (not factors("nCows")) = %nCows%;

 $$endif

 $$iftheni "%DefineHerdSize%" == "LU per ha"

   p_scenParam(draws,"CowsLUdensity") $ (not factors("CowsLUdensity")) = %CowsLUdensity%;

 $$endif

*
*  --- Aks: derived from number of cows and Cows per AK
*


   p_scenParam(draws,"Aks") $ factors("cowsPerAk")
     = p_scenParam(draws,"nCows") / p_scenParam(draws,"CowsPerAk");
   outFactors("Aks") $ factors("cowsPerAk") = YES;
*
*  --- concentrate prices 2 and 3 are defined from conc1 price plus a fixed difference
*
   p_scenParam(draws,"conc2Price") $ factors("conc1Price")  = p_scenParam(draws,"conc1Price") + %concPriceDiff2to1%;
   p_scenParam(draws,"conc3Price") $ factors("conc1Price")  = p_scenParam(draws,"conc1Price") + %concPriceDiff3to1%;

   outFactors("conc2Price") $ factors("conc1Price") = YES;
   outFactors("conc3Price") $ factors("conc1Price") = YES;

$endif.task

* --------------------------------------------------------------------------------------------------------------------------
*
*     Settings for arable farms
*
* --------------------------------------------------------------------------------------------------------------------------

$iftheni.task "%task%" == "Experiments arable"
*
*  --- aks follow hectares
*
   p_scenParam(draws,"nArabLand") $ (not factors("nArabLand")) = %nArabLand%;

   p_scenParam(draws,"Aks") $ factors("haPerAk")
          = p_scenParam(draws,"nArabLand") / p_scenParam(draws,"HaPerAk");
   outFactors("aks") $ factors("haPerAk") = yes;

$endif.task

* --------------------------------------------------------------------------------------------------------------------------
*
*     Settings for fattners farms
*
* --------------------------------------------------------------------------------------------------------------------------

$iftheni.task1 "%task%" == "Experiments fattners"

 $$iftheni "%DefineHerdSize%" == "number"

   p_scenParam(draws,"nFattners") $ (not factors("nFattners")) = %nFattners%;

 $$endif

 $$iftheni "%DefineHerdSize%" == "LU per ha"

   p_scenParam(draws,"FattnersLUdensity") $ (not factors("FattnersLUdensity")) = %FattnersLUdensity%;

 $$endif


*
*  --- Aks: derived from number of fattners and fattners per AK
*
   p_scenParam(draws,"Aks") $ factors("fattnersPerAk")
     = p_scenParam(draws,"nFattners")/p_scenParam(draws,"fattnersPerAk");

   outFactors("aks") $ factors("fattnersPerAk") = yes;
*
   p_scenParam(draws,"Aks")  $ (not p_scenParam(draws,"Aks")) = %aks%;
*
*  --- add 10 hours per hectar of land
*
   p_scenParam(draws,"Aks") $ factors("fattnersPerHaArab")
      = p_scenParam(draws,"Aks")
           + p_scenParam(draws,"nFattners")/p_scenParam(draws,"fattnersPerHaArab")*10/2000;

   p_scenParam(draws,"nArabLand") $ p_scenParam(draws,"fattnersPerHaArab")
    = p_scenParam(draws,"nFattners")/p_scenParam(draws,"fattnersPerHaArab");
   outFactors("nArabland") $ factors("fattnersPerHaArab") = yes;

   outFactors("aks") $ factors("fattnersPerHaArab") = yes;

$endif.task1

* --------------------------------------------------------------------------------------------------------------------------
*
*     Settings for sows farms
*
* --------------------------------------------------------------------------------------------------------------------------

$iftheni.task1 "%task%" == "Experiments sows"
*
*  --- Aks: derived from number of sows and sows per AK
*
   p_scenParam(draws,"Aks") $ p_scenParam(draws,"sowsPerAk")
    = p_scenParam(draws,"nSows")/p_scenParam(draws,"sowsPerAk");
   outFactors("aks") $ factors("sowsPerAk") = yes;

   p_scenParam(draws,"nArabLand") $ p_scenParam(draws,"sowsPerHaArab")
    = p_scenParam(draws,"nSows")/p_scenParam(draws,"sowsPerHaArab");
   outFactors("nArabland") $ factors("sowsPerHaArab") = yes;

$endif.task1



$iftheni %noStart% == true

   display factors,p_ranges;
   display p_scenParam;

$endif

$ifi %noStart% == true $exit

 set allScen(draws);
 allScen(draws) = YES;
 alias(draws,scen);

$ontext

*
* --- exclude implausible ones
*
* (1) large herds and low milk yields (konsistent with findings of 5000 single farms in NRW, LKV-NRW 2012)
*
 allScen(scen) $ ( (p_scenParam(scen,"nCows") ge 50)   and (p_scenParam(scen,"milkYield") le 50)) = no;
 allScen(scen) $ ( (p_scenParam(scen,"nCows") ge 100)  and (p_scenParam(scen,"milkYield") le 60)) = no;
 allScen(scen) $ ( (p_scenParam(scen,"nCows") ge 150)  and (p_scenParam(scen,"milkYield") le 70)) = no;
*
* (3) small herds and high milk yields
*
 allScen(scen) $ ( (p_scenParam(scen,"nCows") le 60)   and (p_scenParam(scen,"milkYield") ge 90)) = no;
 allScen(scen) $ ( (p_scenParam(scen,"nCows") le 50)   and (p_scenParam(scen,"milkYield") ge 80)) = no;
 allScen(scen) $ ( (p_scenParam(scen,"nCows") le 30)   and (p_scenParam(scen,"milkYield") ge 70)) = no;
*
*
* (3) small herds and recent investment in stables
*
 allScen(scen) $ ( (p_scenParam(scen,"nCows") le 50)   and (p_scenParam(scen,"stableYear") eq 2000)) = no;

$offtext

*
* --- delete parameters of deleted scenarios
*
 p_scenParam(scen,scenItems) $ (not allScen(scen)) = 0;
 p_scenParam(allScen,"lastYear") $ (p_scenParam(allScen,"lastYear") eq 0) = %lastYear%;

 display allScen,p_scenParam;

$setglobal curDir %system.fp%
*
*------------------------------------------------------------------------------
*
* Execution and data collection loop
*
*------------------------------------------------------------------------------
*
$eval parallelThreads round(%parallelThreads%)

$iftheni %parallelThreads% == 1

$setglobal runParallel NO

$else

$setglobal runParallel YES

$endif
*
 scalar iLoop;

 batch.lw=0;

 file test / test.txt /;test.lw=0;test.pw=9999;


$iftheni.run %onlyCollectResults% == false

 parameter p_jobHandles(scen);
 scalar rc;
*
 Loop(allScen(scen),
*
*     --- delete the GDX /lst / include file for the experiments so that we do not read later old stuff
*
      put_utility batch 'shell'    / ' %GAMSPATH%gbin/rm  -f "../results/expFarms/res_',scen.tl'.gdx"';
      put_utility batch 'shell'    / ' %GAMSPATH%gbin/rm  -f "%curdir%/incgen/'scen.tl'.gms"';
      put_utility batch 'shell'    / ' %GAMSPATH%gbin/rm  -f "%curdir%/'scen.tl'.lst"';
      put_utility batch 'msglog'   / ' %GAMSPATH%gbin/rm  -f "../results/expFarms/res_',scen.tl'.gdx"';
 );
*
 scalar usedTime,firstStart,curTime;
 usedTime  = 0;
 firstStart = TimeElapsed;

 iLoop=0;
 Loop(allScen(scen) $ (usedTime le %maxWaitTime%*card(allScen)/10),
    iLoop = iLoop + 1;
*
*   --- we have at least 10% of the draws started: correct total time since first start
*       by average time expected for each experiment (max wait time per experiment)
*
*
    usedTime $ (iLoop gt card(allScen)/10) = [timeElapsed - firstStart] - %maxWaitTime%*(Iloop-card(allScen)/10);
    curTime = timeElapsed;

    display usedTime,firstStart,iLoop,curTime;

*
*     --- generate include file for exp_starter, thread specific
*
$batinclude 'scenGen/gen_inc_file.gms' %runParallel%

$iftheni.parallel %runParallel% == yes
*
*    --- 60 Minutes times 60 seconds = max 3.600 seconds wait time for the %parallelThreads% processes
*        The batch script will continue to block further execution until less than
*        %parallelThreads% flag files are present in the directory. That will ensure that not more than
*        %parallelThreads% GAMS processes run in parallel on the machine
*
*
*     --- execute exp_starter as a seperate program, no wait, program will delete a flag at the end to signal that it is ready
*

      put_utility  batch  'msglog'  / '%GAMSPATH%/gams.exe %CURDIR%/exp_starter.gms --scen='allScen.tl
                           ' --iScen='iLoop:0:0' -maxProcDir=255 -output='allScen.tl'.lst'
                          ' --seed=',uniform(0,1000):0:0,
                          ' -maxProcDir=255 -output='allScen.tl:0'.lst %gamsarg% lo=3'
                          ' --pgmName="'allScen.tl' (',iLoop:0:0,' of ',card(allScen):0:0,')"';

      put_utility  batch 'exec.async'   / '%GAMSPATH%/gams.exe %CURDIR%/exp_starter.gms --scen='allScen.tl
                           ' --iScen='iLoop:0:0' -maxProcDir=255 -output='allScen.tl'.lst',
                          ' --seed=',uniform(0,1000):0:0,
                          ' -maxProcDir=255 -output='allScen.tl'.lst %gamsarg% lo=3',
                          ' --pgmName="'allScen.tl' (',iLoop:0:0,' of ',card(allScen):0:0,')"';

      p_jobHandles(scen) = JobHandle;

      while (     (sum(draws $ (jobStatus(p_jobHandles(draws)) eq 1),1) ge %parallelThreads%)
              and (usedTime le %maxWaitTime%*card(allScen)/10),
          put_utility batch 'msglog' / '    -----   Too many jobs active, wait ...';
          rc=sleep(1)
      );
*
$else.parallel
*
      put_utility  batch 'exec'   / '%GAMSPATH%/gams.exe %CURDIR%/exp_starter.gms --scen='allScen.tl
                           ' --iScen='iLoop:0:0' -maxProcDir=255 -output='allScen.tl'.lst',
                          ' --seed=',uniform(0,1000):0:0,
                          ' -maxProcDir=255 -output='allScen.tl'.lst %gamsarg% lo=3',
                          ' --pgmName="'allScen.tl' (',iLoop:0:0,' of ',card(allScen):0:0,')"';


$endif.parallel

 );

$iftheni.parallel %runParallel% == yes

   while(     (sum(draws $ (jobStatus(p_jobHandles(draws)) eq 1),1)
          and (usedTime le %maxWaitTime%*card(allScen)/10)),
       put_utility batch 'msglog' / '       ---- Some jobs are still running, wait ...';
       rc=sleep(5);
   );
$endif.parallel
*
$batinclude 'util/title.gms' "'Allow output'"

if ( usedTime ge %maxWaitTime%*card(allScen)/10,
   put_utility 'msglog' / 'Not all processing terminated correct, waited longer than in average %maxWaitTime% minutes';
   $$batinclude 'util/title.gms' '"Not all processing terminated correct, waited longer than in average %maxWaitTime% minutes"'
);

$endif.run

*
*------------------------------------------------------------------------------
*
* Execution and data collection loop
*
*------------------------------------------------------------------------------
*
*
 iLoop=0;
 Loop( allScen(scen),
      iLoop = iLoop + 1;
      execError = 0;
*
*     --- delete listing file if result file is available
*
      $$iftheni.delList %delListings%==true

         put_utility batch 'shell'   / '%gamspath%/gbin/test -e "../results/expFarms/res_',scen.tl,
             '.gdx" && %gamspath%/gbin/rm "%curdir%/incgen/'scen.tl'.gms"';

         put_utility batch 'shell'   / '%gamspath%/gbin/test -e "../results/expFarms/res_',scen.tl,
             '.gdx" && %gamspath%/gbin/rm "%curdir%/'scen.tl'.lst"';
      $$endif.dellist
*
*     --- set name of result file (comprises last year)
*
      put_utilities batch 'gdxin' / ' ../results/expFarms/res_',scen.tl,'.gdx';

      p_dummy = sleep(.01);
*
      if ( execerror eq 0,

*
*        --- load the result
*
              execute_load p_res;
              p_dummy = sleep(.01);
              if ( execerror eq 0,
*
*               --- filter out results of interest (so far only macs, avAcs and totACs)
*
                $$ifi "%scentype%"=="MAC"     $include 'scengen/scen_load_res_mac.gms'

                $$ifi "%scentype%"=="PROFITS" $include 'scengen/scen_load_res_profits.gms'
                $$ifi "%scentype%"=="Fertilizer directive" $include 'scengen/scen_load_res_profits.gms'
         $$ifi "%scentype%"=="Multi indicator" $include 'scengen/scen_load_res_multi_indicator.gms'

             );
       );
    );
*
*   --- Store to disk
*
    execute_unload '../results/scenGen/meta_%scenDes%.gdx' s_meta,p_meta=p_res;
*
*  --- Display resuls and store to disk
*
   display p_meta;
$batinclude 'util/title.gms' "'Suppress output'"
