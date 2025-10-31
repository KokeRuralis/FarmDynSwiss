********************************************************************************
$ontext

   FARMDYN project

   GAMS file : FARM_CONSTRUCTOR.GMS

   @purpose  : Define farm specific part of the coefficient matrix, such as
               max. labour available, investment possibilities and intial
               endowments

   @author   : W.Britz
   @date     : 23.11.10
   @since    :
   @refDoc   :
   @seeAlso  : model/templ.gms coeffgen/coeffgen.gms
   @calledBy : exp_starter.gms

$offtext
********************************************************************************


$ifi "%dynamics%" == "comparative-static" $setglobal stableYear %lastOldYear%

  p_vPriceInv%l%(invTypes)   = 1;
*
*  ---- exclude arable crops if no arable land
*
$iftheni.arable not "%farmBranchArable%" == "on"
$iftheni.grasOnArab not "%grasOnArab%"=="true"
   c_p_t_i(crops,plot,till,intens) $ (crops_t_landType(crops,"arab") $ (not crops_t_landType(crops,"gras"))
                                                                     $ c_p_t_i(crops,plot,till,intens)) = no;
$endif.grasOnArab
$endif.arable

$ifi %herd% == true   p_maxStockRate  = %maxStockingRate%;
*$ifi %herd% == true   curManTreat("liquidCattle") = yes;

*
*  --- Akh per year: 52 weeks times 40 hours a week
*
   p_yearlyLabH(t)   =  %AkhFirst%   * min(1,%Aks%)
                      + %AkhSecond%  * min(1,%Aks%-1) $ (%Aks% > 1)
                      + %AkhFurther% * (%Aks%-2)      $ (%Aks% > 2);

   scalar p_LabLostFirst,p_labLostSecond,p_LabLostFurther;

   p_LabLostFirst  =   %AkhFurther% $ (%Aks% > 2)
                     + %AkhSecond%  $ ( (%Aks% <= 2) and (%Aks% > 1))
                     + %AkhFirst%   $ (%Aks% <= 1);

   p_LabLostSecond =   %AkhFurther% $ (%Aks% > 3)
                     + %AkhSecond%  $ ( (%Aks% <= 3) and (%Aks% > 2))
                     + %AkhFirst%   $ (%Aks% <= 2);

   p_LabLostFurther=   %AkhFurther% $ (%Aks% > 4)
                     + %AkhSecond%  $ ( (%Aks% <= 4) and (%Aks% > 3))
                     + %AkhFirst%   $ (%Aks% <= 3);

   p_workTimeLost(workType) $ (workType.pos eq 1 ) = p_labLostFirst/2;
   p_workTimeLost(workType) $ (workType.pos eq 2 ) = p_labLostFirst;
   p_workTimeLost(workType) $ (workType.pos eq 3 ) = p_labLostFirst + p_LabLostSecond/2;
   p_workTimeLost(workType) $ (workType.pos eq 4 ) = p_labLostFirst + p_LabLostSecond;
   p_workTimeLost(workType) $ (workType.pos gt 4 ) = p_labLostFirst + p_LabLostSecond + p_LabLostFurther/2 * (workType.pos - 4);
*
*  --- ensure that flexible hourly work per month cannot exceed the number of working half time
*
   v_labOffHourly.up(t,nCur) = (p_labLostFirst/2);

*  --- akh per month: much more then yearly sum to allow covering work peaks
*                     (e.g. at harvest time, up 12 days for each normal work days monday-friday)
*
*
   p_monthlyLabH(t,m) =  p_yearlyLabH(t) / 365 * p_daysPerMonth(m) * (1+%flexHoursFamily%/100);
   p_leisureVal(leisLevl) = %leisureVal%*5 - %leisureVal%*5/(card(leislevl)-1) * leisLevl.pos;

   v_leisure.up(leisLevl,t_n(tCur,nCur),m) = p_monthlyLabH(tCur,m)/(1.5*%flexHoursFamily%/100) * 1/(card(leislevl)-1);
   v_leisure.up(leisLevl,t_n(tCur,nCur),m) $ (leisLevl.pos eq card(leisLevl)) = p_monthlyLabH(tCur,m) * (1-1.5*%flexHoursFamily%/100);

*
*  --- household consumption, dropping for larger  households
*
$eval householdConsumption round(%householdConsumption%)

$eval householdConsumptionGR round(%householdConsumptionGR%)


   p_hcon(t)      =

   round(
*
*    --- first household member
*
         (%householdConsumption%
*
*    --- additional household member
*
         + round( sqrt(max(0.1,%Aks%-1)) * %householdConsumption%,10))
*
*    --- growth rate, result rounded to 10 Euro
*
          * (1+%householdConsumptionGR%/100)**t.pos,10);
*
*  --- the farm has some cash reserve
*
$eval initialLiquidity round(%initialLiquidity%)
$evalglobal stableYear round(%stableYear%)

   p_iniLiquid    = %initialLiquidity%;

* --------------------------------------------------------------------------------
*
*      Initial endowment with buildings
*
* --------------------------------------------------------------------------------


* --------------------------------------------------------------------------------
*
*      Initial endowment with stables and silos
*
* --------------------------------------------------------------------------------

   option kill=p_iniBuildings;
   v_buyBuildings.up(curBuildings,t,nCur) $ t_n(t,nCur) = 1 + 5 $ [sum(buildType_buildings(buildType,buildings) $  buildType_buildings(buildType,curBuildings),1) eq 1];

   scalar minSize,maxSize,size;

$ifi "%manure%"=="true" parameter p_reqSilo(manChain),p_minSiloSize(manChain),p_maxSiloSize(manChain);

$iftheni.PH %pigHerd% == true

   curManChain("LiquidPig") = yes;

   $$iftheni.fattners "%farmBranchFattners%"=="on"

      $$batInclude 'coeffgen/def_iniStables.gms' fattners p_nFattners

   $$endif.fattners

   $$iftheni.sows "%farmBranchSows%"=="on"

      $$batInclude 'coeffgen\def_iniStables.gms' sows p_nSows

*     ---- Number of sows times their yearly output of piglets
*           divided by 6 to account piglets remaining for 2 months in stable
      size =  p_nSows * 26.36 / 6;
      $$batInclude 'coeffgen\def_iniStables.gms' piglets size

   $$endif.sows

   v_buySilos.up("liquidPig",silos,t,nCur) $ t_n(t,nCur) = 1;
   v_buySilosF.up("liquidPig",silos,t,nCur) $ t_n(t,nCur) = 1;

$endif.PH

$ifi %herd%==true option kill=v_buyStables.up;

$iftheni.dh %dairyHerd% == true

    $$iftheni.straw not "%cowStableInv%"=="slatted_floor"
       curManChain("solidCattle")       = yes;
       curManChain("LightLiquidCattle") = yes;
    $$endif.straw
*
*  --- regression line derived from comp-static experiments
*
   $$ifi "%DefineHerdSize%"=="Based on Aks" p_nCows =  -3.409e+01 + 2.317e-02 * smax(t,p_yearlyLabH(t));
*
*  --- select the smallest possible stable size fitting the herds
*

   $$batInclude 'coeffgen/def_iniStables.gms' milkCow p_nCows
*
*  --- 2.5 is the # of lactations for 8.500 l cow in average of short and long
*
   size = p_nCows * 2/3 * 2.50/(0.5*p_nLac("cows%milkYield%00_short")+0.5*p_nLac("cows%milkYield%00_long"));

   size $ (p_nHeifs ne 0) = p_nHeifs;
   $$batInclude 'coeffgen/def_iniStables.gms' youngCattle size
*
*  --- assume 1/3 stable need for calves per cow
*
   size = p_nCows * 1/3;
   size $ ( p_nCalves ne 0) = p_nCalves;
   $$batInclude 'coeffgen/def_iniStables.gms' calves size

$endif.dh
$iftheni.beef "%farmBranchBeef%"=="on"

   size = p_nBulls;
   $$ifi %dairyHerd%     == true size = size +  p_nCows * 2/3 * 3.66/p_nLac("cows%milkYield%00_short");
   $$ifi %motherCowHerd% == true size = size +  p_nMotherCows * 2/3;

   $$ifi "%cowherd%"=="true" size $ (p_nHeifs ne 0) = p_nHeifs;
   $$batInclude 'coeffgen/def_iniStables.gms' youngCattle size

   curManChain("liquidCattle")        = yes;
  $$iftheni.straw not "%bullsStableInv%"=="slatted_floor"
     curManChain("solidCattle")       = yes;
     curManChain("LightLiquidCattle") = yes;
  $$endif.straw

$endif.beef

$iftheni.mc "%farmBranchMotherCows%"=="on"
   $$iftheni.straw not "%motherCowStableInv%"=="slatted_floor"
      curManChain("solidCattle")       = yes;
      curManChain("LightLiquidCattle") = yes;
   $$endif.straw
   $$batInclude 'coeffgen/def_iniStables.gms' motherCow p_nMotherCows

   size = p_nMotherCows * 2/3;
   $$ifi %dairyHerd%       == true size = size +  p_nCows * 2/3 * 3.66/p_nLac("cows%milkYield%00_short");
   size $ (p_nHeifs ne 0) = p_nHeifs;
   $$ifi "%farmBranchBeef%"=="on"  size = size +  p_nBulls;
   $$batInclude 'coeffgen/def_iniStables.gms' youngCattle size

   size = p_nMotherCows * 1/2;
   $$ifi %dairyHerd%       == true size = size + p_nCows * 1/3;
   size $ ( p_nCalves ne 0) = p_nCalves;
   $$batInclude 'coeffgen/def_iniStables.gms' calves size

$endif.mc

$iftheni.cattle %cattle%==true
   curManChain("liquidCattle")      = yes;
    $$iftheni.straw not "%calvesStableInv%"=="slatted_floor"
       curManChain("solidCattle")       = yes;
       curManChain("LightLiquidCattle") = yes;
    $$endif.straw
  $$iftheni.straw not "%heifersStableInv%"=="slatted_floor"
     curManChain("solidCattle")       = yes;
     curManChain("LightLiquidCattle") = yes;
  $$endif.straw
  $$ifi %biogas%==true curManChain("liquidCattle") $ (not card(curManChain)) = yes;
$endif.cattle

$$ifi defined curChain curChain("")= YES;

$iftheni.manure "%manure%"=="true"
 $$ifi defined curChain curChain(curManChain) = YES;
$endif.manure


$iftheni.herd %Herd% == true
*
*  --- introduce re-investments during lifetime of stable part with longest life time
*

   scalar period;
   for(period=0 to 3,

      p_iniStables(stables,hor,tOld) $ (sum(t,(p_priceStables(stables,hor,t) gt eps)) $ p_iniStables(stables,"long","%stableYear%") $ (not sameas(hor,"long"))
                                         $ ( (%stableYear% + p_lifeTimeS(stables,hor)*period) eq p_year(tOld))
                                         $ ( (%stableYear% + p_lifeTimeS(stables,"long")      gt p_year(tOld))) )
                 =  p_iniStables(stables,"long","%stableYear%");
   );
*
*  --- Define initial endowment with manure silo capacity
*
   option kill=p_iniSilos;

   p_reqSilo(manChain) = max(0,sum( (manChain_herd(manChain,herds),breeds),
                                          p_iniHerd(herds,breeds) * p_manQuantMonth(herds,manChain) *  %MonthManStore% )
                               - sum(stables, p_iniStables(stables,"long","%stableYear%") * p_ManStorCap(manChain,stables)));

   p_iniSilos(manChain,silos,"%stableYear%")
     $ (  p_reqSilo(manChain) $ (p_ManStorCapSi(silos) gt p_reqSilo(manChain))
         $ ( p_ManStorCapSi(silos) eq smin(silos1 $ (p_ManStorCapSi(silos1) gt p_reqSilo(manChain)), p_manStorCapSi(silos1)))) = yes;

   p_iniSilos(manChain,silos,"%stableYear%")
     $ (  p_reqSilo(manChain) $ (p_ManStorCapSi(silos) lt p_reqSilo(manChain))
         $ ( p_ManStorCapSi(silos) eq smax(silos1 $ (p_ManStorCapSi(silos1) lt p_reqSilo(manChain)), p_manStorCapSi(silos1)))) = yes;



   p_minSiloSize(manChain) $ p_reqSilo(manChain) = smin(silos $ p_iniSilos(manChain,silos,"%stableYear%") , p_ManStorCapSi(silos));
   p_maxSiloSize(manChain) $ p_reqSilo(manChain) = smax(silos $ p_iniSilos(manChain,silos,"%stableYear%") , p_ManStorCapSi(silos));


   p_iniSilos(manChain,silos,"%stableYear%")      $ ((p_ManStorCapSi(silos) eq p_minSiloSize(manChain))
                                                       $ (p_minSiloSize(manChain) ne p_maxSiloSize(manChain))  $ p_reqSilo(manChain))
      = (  p_reqSilo(manChain)  - p_maxSiloSize(manChain))/(p_minSiloSize(manChain)-p_maxSiloSize(manChain));

   p_iniSilos(manChain,silos,"%stableYear%")      $ ((p_ManStorCapSi(silos) eq p_maxSiloSize(manChain))
                                                       $ (p_minSiloSize(manChain) ne p_maxSiloSize(manChain))  $ p_reqSilo(manChain))
      = 1 - (  p_reqSilo(manChain)  -p_maxSiloSize(manChain))/(p_minSiloSize(manChain)-p_maxSiloSize(manChain));

   p_iniSilos(manChain,silos,"%stableYear%")      $ ((p_ManStorCapSi(silos) eq p_maxSiloSize(manChain))
                                                       $ (p_minSiloSize(manChain) eq p_maxSiloSize(manChain))  $ p_reqSilo(manChain))
      = 1;

$endif.herd
*
*  --- take out stable which are too large
*
$if not setGlobal maxGrowthRateDairyCows $setglobal maxGrowthRateCowHerd 4
$eval maxGrowthRateCowHerd (1+%maxGrowthRateCowHerd%/100)


$iftheni.catt %cattle% == true

   v_buySilos.up(curManChain,silos,t,nCur) $ t_n(t,nCur) = 1;
   v_buySilosF.up(curManChain,silos,t,nCur) $ t_n(t,nCur) = 1;
   option kill=p_iniBuildings;
*
*  -- silos for manure (25 m3 is a proxy for the maximal storage size required)
*
   size = 0;
   $$ifi "%farmBranchDairy%"=="on" size = p_nCows*25;
   $$ifi "%farmBranchBeef%"=="on"  size = size + p_nBulls*25;

   p_iniBuildings(bunkerSilos,"%stableYear%") $ ( (p_building(bunkerSilos,"capac_M3") gt size)
                                                 $ (p_building(bunkerSilos,"capac_M3")
                                                     eq Smin(bunkerSilos1 $ (p_building(bunkerSilos1,"capac_M3")  gt size),
                                                             p_building(bunkerSilos1,"capac_M3")))) = yes;

   p_iniBuildings(bunkerSilos,"%stableYear%") $ ( (p_building(bunkerSilos,"capac_M3") lt size)
                                                 $ (p_building(bunkerSilos,"capac_M3")
                                                     eq Smax(bunkerSilos1 $ (p_building(bunkerSilos1,"capac_M3")  lt size),
                                                             p_building(bunkerSilos1,"capac_M3")))) = yes;

   minSize = smin(bunkerSilos $ p_iniBuildings(bunkerSilos,"%stableYear%"), p_building(bunkerSilos,"capac_M3"));
   maxSize = smax(bunkerSilos $ p_iniBuildings(bunkerSilos,"%stableYear%"), p_building(bunkerSilos,"capac_M3"));
*
   p_iniBuildings(bunkerSilos,"%stableYear%") $ ( (p_building(bunkerSilos,"capac_M3")  eq minSize) and (minSize ne maxSize))
      = ( size - maxsize)/(minSize-maxSize);

   p_iniBuildings(bunkerSilos,"%stableYear%") $ ( (p_building(bunkerSilos,"capac_M3")  eq maxSize) and (minSize ne maxSize))
      = 1 - ( size - maxsize)/(minSize-maxSize);

   p_iniBuildings(bunkerSilos,"%stableYear%") $ ( (p_building(bunkerSilos,"capac_M3")  eq maxSize) and (minSize eq maxSize))
      = 1;

$endif.catt


$iftheni.herd %herd% == true

   v_siloInv.up(curManChain,silos,t,nCur)              $ (sum(t_n(t1,nCur1), v_buySilos.up(curManChain,silos,t1,nCur1)) eq 0) = 0;
*   v_siCovComb.up(curManChain,silos,t,nCur,manStorage) $ (sum(t_n(t1,nCur1), v_buySilos.up(curManChain,silos,t1,nCur1)) eq 0) = 0;


   $$iftheni.compStat not "%dynamics%" == "comparative-static"

      p_iniStables(stables,hor,tOld) $ (p_iniStables(stables,hor,tOld) and
                                    (p_year(tOld) + p_lifeTimeS(stables,hor)
                                      lt p_year("%firstYear%") )) =0;
   $$endif.compStat

    p_luSumHerds(sumHerds,breeds)  = p_lu(sumherds,breeds);
    p_luSumHerds(sumHerds,breeds) $ ( (not p_luSumHerds(sumHerds,breeds)) $ sum(sum_herds(sumHerds,herds), p_lu(herds,breeds)))
       = smax(sum_herds(sumHerds,herds), p_lu(herds,breeds));

$endif.herd

* --------------------------------------------------------------------------------
*
*      Initial endowment of machinery
*
* --------------------------------------------------------------------------------

$ifthen.iniMach "%iniMach%" == true

      set iniMachType(machType);
*
*     --- required for the selected crops, synthetic fertilizer and manure applications
*         and the summary herds
*
      iniMachType(machType) $ sum( (c_p_t_i(curCrops(crops),plot,till,intens),machLifeUnit),
          p_machNeed(crops,till,intens,machType,machLifeUnit)) = yes;

      iniMachType(machType) $ sum((inputs(syntFertilizer),till,machLifeUnit),
          p_machNeed(syntFertilizer,till,"normal",machType,machLifeUnit)) = yes;

      $$iftheni.man %manure% == true

         iniMachType(machType) $ sum((manApplicType_manType(ManApplicType,curManType),machLifeUnit),
           p_machNeed(ManApplicType,"plough","normal",machType,machLifeUnit)) = yes;

      $$endif.man

      $$iftheni.herd %herd%==true

          iniMachType(machType) $ sum((sumHerds,machLifeUnit),
              p_machNeed(sumHerds,"plough","normal",machType,machLifeUnit)) = YES;

          iniMachType(machType) $ sum((stables_to_mach(stables,machType),hor,tOld),
              p_iniStables(stables,hor,tOld)) = YES;
      $$endif.herd
*
*    --- still rudimentary: all type of machines are assigned operation hours according to lifetime of stables, otherwise,
*        20 years are assumed
*
     scalar p_YearsToDivide;

     $$ifthen.stables defined p_iniStables
         p_yearsToDivide = smax(stables $ p_iniStables(stables,"long","%stableYear%"),p_lifeTimeS(stables,"long"));
     $$else.stables
         p_YearsToDivide = 20;
     $$endif.stables

*
     p_iniMach(iniMachType,machLifeUnit) = MAX(0, 1 - (p_year("%firstYear%") - p_Year("%stableYear%"))/p_yearsToDivide)
                                                    * p_lifeTimeM(iniMachType,machLifeUnit);

     p_iniMach(iniMachType,"Years") = 0;
     p_iniMachT(iniMachType,"%stableYear%") = 1 $ p_lifeTimeM(iniMachType,"years");

$else.iniMach

      option kill=p_iniMach;
      option kill=p_iniMachT;
$endif.iniMach



$ifi not %landLease% == true option kill=v_rentOutPlot;



   workOpps(workType) $ ( p_workTime(workType) * 44 le (%Aks% * 44 * 40)) = YES;

$iftheni.compStat "%dynamics%" == "comparative-static"


     option kill=p_iniMach;
     option kill=p_iniMachT;

     $$iftheni.herd %herd% == true
       $$ifi "%noNewStable%" == true  $setglobal fixIniAssets true
       $$iftheni.fixIniAssets "%fixIniAssets%"=="true"
*
*         --- force investments in a certain # of stable places
*
          v_stableNeed.lo(stableTypes,t_n("%firstYear%",nCur))
               = sum(stables $ p_stableSize(stables,stableTypes), p_iniStables(stables,"long","%stableYear%") * p_stableSize(stables,stableTypes));

       $$endif.fixIniAssets
       option kill=p_iniStables;
       option kill=p_iniSilos;
       option kill=p_iniBuildings;
     $$endif.herd

$endif.compStat

* --- Option to forbid investment in new stables to prevent farm from growing
*     (only implemented for main stable types)

$$iftheni.herd %herd% == true
$iftheni.noSta "%noNewStable%" == true


     set restrStableTypes(stableTypes) /
       $$ifi "%farmBranchDairy%"      == "on" milkCow
       $$ifi "%farmBranchMotherCows%" == "on" motherCow
       $$ifi "%farmBranchSows%"       == "on" sows
       $$ifi "%farmBranchFattners%"   == "on" fattners
       $$ifi "%farmBranchBeef%"       == "on" youngCattle
     /;

     $$ifi "%cowHerd%"=="true" restrStableTypes("youngCattle") $ (restrStableTypes("milkCow") or restrStableTypes("motherCow")) = no;

     $$ifthen.v_StableNeed not defined v_stableNeed
         v_stableNeed.lo(stableTypes,t_n("%firstYear%",nCur))
               = sum(stables $ p_stableSize(stables,stableTypes), p_iniStables(stables,"long","%stableYear%") * p_stableSize(stables,stableTypes));
     $$endif.v_stableNeed

     v_stableNeed.up(restrStableTypes,t,nCur) $ t_n(t,nCur) = sum(t_n("%firstYear%",nCur), v_stableNeed.lo(restrStableTypes,"%firstYear%",nCur));

$endif.noSta
$endif.herd


$iftheni.biogas %biogas%  == true
* --------------------------------------------------------------------------------
*
*      Construction of biogas plant
*
* --------------------------------------------------------------------------------

    option kill=v_prodElec;

$iftheni.d not "%dynamics%" == "Comparative-static"
*
*   --- The decision maker can only buy the biogas plant with a 20 year investment horizon in those years in which the eeg corresponds to the year
*
    v_buyBioGasPlant.fx(bhkw,eeg,"iH20",t,nCur)    $ (t_n(t,nCur) $  (not eeg_t(eeg,t))) = 0;
*
*   --- The decision maker can only switch in those years in which the EEG is replaced by a new eeg. eeg1,eeg (eg. 2009,2004) can only be one in years where the multidimensional set is not active.
*
    v_switchBioGas.fx(bhkw,eeg1,eeg,t,nCur)   $ (t_n(t,nCur) $ ( p_year(t) lt smin(eeg_t(eeg,t1), p_year(t1)))) = 0;

$endif.d

*   --- Trigger if initial biogas plant is existing

 parameter p_iniBioGas(bhkw,eeg,ih,tOld)      "initial biogas plant"
           p_iniBiogasParts(bhkw,eeg,ih,tOld) "initial biogas plant parts";

$iftheni.exist not %existBio% == true

   option kill=  p_iniBioGas;
   option kill=  p_iniBiogasParts;

$else.exist

   p_iniBioGas("%curBhkwsize%","%iniEEG%","ih20","%biogasYear%") =  1;
   p_inibiogasParts("%curBhkwsize%","%iniEEG%",ih,"%biogasYear%")$(not(ih20(ih))) = 1;

$endif.exist
$endif.biogas

$ifi not set emissionright      $setglobal emissionRight 0
$ifi declared p_emissionRights  p_emissionRights = %emissionRight%;
