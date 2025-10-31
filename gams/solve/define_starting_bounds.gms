********************************************************************************
$ontext

   FARMDYN project

   GAMS file : DEFINE_STARTING_BOUNDS.GMS

   @purpose  : Define upper and lower limits of variables before the first
               solve

   @author   : W.Britz and others
   @date     : 21.12.10
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter.gms

$offtext
********************************************************************************

$ifi not defined v_triggerGreening $setglobal greening false


$ifi %greening%==true v_triggerGreening.fx("gras",t_n(tCur,nCur)) $ (not sum(c_p_t_i(curCrops(grasCrops),plot,till,intens),1)) = 1;


 p_maxBranch(branches,t_n(t,nCur)) = 50000;

 v_rentOutPlot.up(plot,t_n(tCur,nCur)) = 1;
 option kill=v_rentOutPlotNew;
 option kill=v_buy;

$$ifi "%allowHiring%"=="false" $setglobal maxWorkersHired 0
$$ifi "%allowHiring%"=="false" $setglobal flexHoursHired 0
$$ifi not set workHoursHired    $set workHoursHired  0
v_hireWorkers.up(t_n(tcur,nCur)) = %maxWorkersHired%;

$iftheni.cash "%farmBranchArable%"=="on"
   p_maxBranch("cashCrops",t_n(tCur,nCur)) = sum(plot_lt_soil(plot,"arab",soil), p_plotSize(plot)) + 5;
$endif.cash

$iftheni.organic "%orgTill%"=="enforced"
 c_p_t_i(crops,plot,till,intens) $ (not sameas(till,"org")) = no;
$endif.organic

$iftheni.cattle %cattle% == true

*   --- switch off sexing if not activated by user

    $$ifi not "%useFemaleSexing%"=="true" v_sexingF.fx(breeds,t_n(t,nCur),m) = 0;
    $$ifi not "%useMaleSexing%"=="true"   v_sexingM.fx(breeds,t_n(t,nCur),m) = 0;

    $$iftheni.heifs defined heifs

       set allHeifs(herds) / set.heifs,heifs,set.heifsSold,set.heifsBought,heifsSold,heifsBought,remonte,remonteMotherCows /;
       actHerds(allHeifs,breeds,"noGraz",t,m)   $ (not heifsNoGraz(m))   = no;
       actHerds(allHeifs,breeds,"partGraz",t,m) $ (not heifsPartGraz(m)) = no;
       actHerds(allHeifs,breeds,"fullGraz",t,m) $ (not heifsGraz(m))     = no;

    $$endif.heifs

    $$iftheni.bulls defined set bulls

       set allBulls(herds) / set.bulls,bulls,set.bullsSold,set.bullsBought,bullsSold,bullsBought /;
       actHerds(allBulls,breeds,"noGraz",t,m)   $ (not bullsNoGraz(m))   = no;
       actHerds(allBulls,breeds,"partGraz",t,m) $ (not bullsPartGraz(m)) = no;
       actHerds(allBulls,breeds,"fullGraz",t,m) $ (not bullsGraz(m))     = no;

    $$endif.bulls

    actHerds(calvs,breeds,"noGraz",t,m)   $ (not calvsNoGraz(m))   = no;
    actHerds(calvs,breeds,"partGraz",t,m) $ (not calvsPartGraz(m)) = no;
    actHerds(calvs,breeds,"fullGraz",t,m) $ (not calvsGraz(m))     = no;

    set allCows(herds) / set.cows,cows /;

    $$iftheni.dairy defined cowsNoGraz

       actHerds(allCows,breeds,"noGraz",t,m)   $ (not cowsNoGraz(m))    = no;
       actHerds(allCows,breeds,"partGraz",t,m) $ (not cowsPartGraz(m))  = no;
       actHerds(allCows,breeds,"fullGraz",t,m) $ (not cowsGraz(m))      = no;

       actHerds(slgtCows,breeds,"noGraz",t,m)   $ (not cowsNoGraz(m))    = no;
       actHerds(slgtCows,breeds,"partGraz",t,m) $ (not cowsPartGraz(m))  = no;
       actHerds(slgtCows,breeds,"fullGraz",t,m) $ (not cowsGraz(m))      = no;

    $$endif.dairy

*
*  --- Kill buying of calves if no price is given
*

    $$ifi "%buyCalvs%"=="true" actHerds("fCalvsRaisBought",curBreeds,"",t,m) $ (not p_InputPrice%l%("fCalvsRaisBought","conv",t)) = no;
    $$ifi "%buyCalvs%"=="true" actHerds("mCalvsRaisBought",curBreeds,"",t,m) $ (not p_InputPrice%l%("mCalvsRaisBought","conv",t)) = no;

*   --- upper bounds (important for binary variable to reduce problem size!)

    option kill=v_herdSize.up;
    $$if not defined p_nCows p_nCows = p_nBulls;
    v_herdSize.up(cattle,breeds,feedRegime,t_n(t,nCur),m)
         $ ((v_herdSize.up(cattle,breeds,feedRegime,t,nCur,m) eq inf) and (actHerds(cattle,breeds,feedRegime,t,m)))
           = max((p_nCows+%nMotherCows%)*1.5,min(((p_nCows+%nMotherCows%)*%maxGrowthRateCowHerd%**t.pos),(%aks%+%maxWorkersHired%)*2000/35));
*
*  --- Breed differentiation required for cattle, so set upper bound of 0 for "no breed"
*
    v_herdSize.up(cattle,"",feedRegime,t_n(t,nCur),m) = 0;

    v_sumHerd.up(sumHerds,breeds,t_n(t,nCur)) $ sum(sameas(cattle,sumHerds),1)
       = max((p_nCows+%nMotherCows%)*1.5,min(((p_nCows+%nMotherCows%)*%maxGrowthRateCowHerd%**t.pos),(%aks%+%maxWorkersHired%)*2000/35));


    v_herdSize.up(slgtCows,breeds,feedRegime,t_n(t,nCur),m)  = v_herdSize.up(slgtCows,breeds,feedRegime,t,nCur,m) * 1.5;
    v_herdSize.up(slgtCows,breeds,feedRegime,t_n(t,nCur),m)
        $ ((p_year(t) le p_year("%firstYear%")+1) $ (not p_compStatHerd)) = 0;

    v_herdStart.up(herds,breeds,t_n(t,nCur),m) $ sum(feedRegime $ (v_herdSize.up(herds,breeds,feedRegime,t,nCur,m) ne inf),1)
    = smax(feedRegime $ (v_herdSize.up(herds,breeds,feedRegime,t,nCur,m) ne inf),v_herdSize.up(herds,breeds,feedRegime,t,nCur,m));
*
*   --- not start of heifers for selling before first year with full herd accounting
*
    v_herdStart.fx("heifsSold",breeds,t_n(t,nCur),m) $ ((p_year(t) le p_year("%firstYear%")) $ (not p_compStatHerd)) = 0;

    v_herdSize.up(slgtCows,breeds,feedRegime,t_n(t,nCur),m) $ (p_year(t) le p_year("%firstYear%")) = 0;

    $$iftheni.dairyHerd %dairyHerd% == true
       v_branchSize.up("dairy",t_n(t,nCur))
          = smax(actHerds(cows,breeds,feedRegime,t,m), v_herdSize.up(cows,breeds,feedRegime,t,nCur,m));

       p_maxBranch("dairy",t_n(t,nCur))     = v_branchSize.up("dairy",t,nCur);
       v_branchSize.up("dairy",t_n(t,nCur)) $ (p_nCows eq 0) = 0;
    $$endif.dairyHerd

    $$iftheni.motherCows "%farmBranchMotherCows%"=="on"
       v_branchSize.up("motherCows",t_n(t,nCur))
          = smax(actHerds("motherCow",breeds,feedRegime,t,m), v_herdSize.up("motherCow",breeds,feedRegime,t,nCur,m));

       p_maxBranch("motherCows",t_n(tCur,nCur)) = v_branchSize.up("motherCows",tCur,nCur);
       v_branchSize.up("motherCows",t,nCur) $ (t_n(t,nCur) $ (%nMotherCows% eq 0)) = 0;


       v_herdStart.up("fCalvsRaisBought",breeds,t_n(t,nCur),m) = 400;
       v_herdStart.up("mCalvsRaisBought",breeds,t_n(t,nCur),m) = 400;
    $$endif.motherCows

    $$iftheni.branchBeef "%farmBranchBeef%"=="on"
       v_herdSize.up(bulls,breeds,feedRegime,t_n(t,nCur),m)         $ actHerds(bulls,breeds,feedRegime,t,m)         = 1500;
       v_herdSize.up(bullsBought,breeds,feedRegime,t_n(t,nCur),m)   $ actHerds(bullsBought,breeds,feedRegime,t,m)   = 1500;
       v_herdSize.up("bulls",breeds,feedRegime,t_n(t,nCur),m)       $ actHerds("bulls",breeds,feedRegime,t,m)       = 1500;
       v_herdSize.up("bullsBought",breeds,feedRegime,t_n(t,nCur),m) $ actHerds("bullsBought",breeds,feedRegime,t,m) = 1500;

       v_herdStart.up(bulls,breeds,t_n(t,nCur),m)         $ sum(feedRegime, actHerds(bulls,breeds,feedRegime,t,m))        = 1500;
       v_herdStart.up(bullsBought,breeds,t_n(t,nCur),m)   $ sum(feedRegime,actHerds(bullsBought,breeds,feedRegime,t,m))   = 1500;
       v_herdStart.up("bulls",breeds,t_n(t,nCur),m)       $ sum(feedRegime,actHerds("bulls",breeds,feedRegime,t,m))       = 1500;
       v_herdStart.up("bullsBought",breeds,t_n(t,nCur),m) $ sum(feedRegime,actHerds("bullsBought",breeds,feedRegime,t,m)) = 1500;

       v_sumHerd.up("bulls",breeds,t_n(t,nCur))        = 1500;
       v_sumHerd.up("bullsBought",breeds,t_n(t,nCur))  = 1500;
       v_sumHerd.up("bullsSold",breeds,t_n(t,nCur))   = 1500;

       $$iftheni.buyCalves "%buyCalvs%"=="true"

           v_herdStart.up("mCalvsRaisBought",breeds,t_n(t,nCur),m)           $ sum(feedRegime, actHerds("mCalvsRaisBought",breeds,feedRegime,t,m)) = 1000;
           v_herdStart.up("mCalvsRais",breeds,t_n(t,nCur),m)                 $ sum(feedRegime, actHerds("mCalvsRais",breeds,feedRegime,t,m))       = 1000;
           v_herdSize.up("mCalvsRaisBought",breeds,feedregime,t_n(t,nCur),m) $ actHerds("mCalvsRaisBought",breeds,feedRegime,t,m)                  = 1000;
           v_herdSize.up("mCalvsRais",breeds,feedregime,t_n(t,nCur),m)       $ actHerds("mCalvsRais",breeds,feedRegime,t,m)                        = 1000;
       $$endif.buyCalves

       p_maxBranch("beef",t_n(tCur,nCur))  = 5000;
       v_branchSize.up("beef",t_n(t,nCur)) = 5000;
*
*  --- set upper bound of 0 if farm cannot buy bulls, nor produce them on it's own
*
      $$iftheni.buyYoungBulls "%buyYoungBulls%"=="false"
        v_sumherd.up("bulls",breeds,t_n(t,nCur)) $ (not sum(bulls $ herds_from_herds(bulls,"mCalvsRais",breeds),1)) = 0;
      $$endif.buyYoungBulls
    $$endif.branchBeef
$endif.cattle
*
* --- Do not have fattners without preceding early, mid and late fattners
*
$iftheni.ph %pigherd% == true
*
*  --- Do not have fattners without preceding early, mid and late fattners
*
   $$iftheni.fattners "%farmBranchFattners%" == "on"
         option kill=v_herdStart.up;
         v_herdSize.up(fattners,"",feedRegime,t_n(tFull,nCur),m)  = p_nFattners*10;

         v_herdSize.up("midfattners","",feedRegime,"%firstYear%",nCur,m)   $ (t_n("%firstYear%",nCur) $ (ord(m) le 1) ) = 0;
         v_herdSize.up("lateFattners","",feedRegime,"%firstYear%",nCur,m)  $ (t_n("%firstYear%",nCur) $ (ord(m) le 2) ) = 0;
         v_herdSize.up("fattners","",feedRegime,"%firstYear%",nCur,m)      $ (t_n("%firstYear%",nCur) $ (ord(m) le 3) ) = 0;

         p_maxBranch("fatpig",t_n(tCur,nCur)) = p_nFattners*200;

   $$endif.fattners

*
*  --- Do not have young piglets before in the month before the simulation years
*
     $$iftheni.sows "%farmBranchSows%" == "on"

         v_herdstart.up("youngPiglets","",t_n(t,nCur),m)                  $ (p_year(t) lt p_year("%firstYear%"))  = p_nSows * 26.63;
         v_herdSize.up("piglets","",feedRegime,t_n("%firstYear%",nCur),m) $ (ord(m) eq 1) = p_nSows * 26.63;
         v_herdSize.up("sows","",feedRegime,t_n(tFull,nCur),m) = p_nSows * 2;
         p_maxBranch("sowpig",t_n(tCur,nCur)) = p_nSows * 2;
     $$endif.sows

$endif.ph

$iftheni.manure %manure% == true

  v_manDist.up(c_p_t_i(crops,plot,till,intens),manApplicType,manType,t_n(t,nCur),m)    $ (not curManType(manType)) = inf;
  v_manDist.up(c_p_t_i(crops,plot,till,intens),manApplicType,curManType,t_n(t,nCur),m) $ (not manApplicType_manType(manApplicType,curManType)) = inf;

$endif.manure

$iftheni.herd %herd% == true

    v_LabHerd.up(t_n(t,nCur))     = p_yearlyLabH(t)*1.01 +%maxWorkersHired%*%workHoursHired%;
    v_labHerdM.up(t_n(t,nCur),m)  = p_monthlyLabH(t,m) +%maxWorkersHired%*%workHoursHired%/card(m)*(1. + %flexHoursHired%/100);

    parameter p_replaceYear(stableTypes,hor) "Year when the lifetime of existing stable is over";
*
    p_replaceYear(stableTypes,hor)
       = smin((tOld,stables) $ (p_iniStables(stables,hor,tOld) $ p_stableSize(stables,stableTypes)), (p_year(tOld) + p_lifeTimeS(stables,hor)));

    p_replaceYear(stableTypes,hor) $ (p_replaceYear(stableTypes,hor) eq inf) = 0;
    v_buySilos.up(curManChain,silos,t,nCur) $ t_n(t,nCur)          =  1;

*
*   ---- stable can be bought in the year where current stables become unusable
*        or we are in year scheduled for investment decisions
*
$iftheni.compStat not "%dynamics%"=="Comparative-static"


    v_buyStables.up(stables,hor,t_n(t,nCur)) $ (v_buyStables.up(stables,hor,t,nCur) ne 0)
             =  1 $ ( (    (p_year(t) eq sum(stableTypes $ p_stableSize(stables,stableTypes),p_replaceYear(stableTypes,hor)))
                        or (p_year(t) eq sum(stableTypes $ p_stableSize(stables,stableTypes),p_replaceYear(stableTypes,hor)+p_lifeTimeS(stables,hor)))
                        or (p_year(t) eq sum(stableTypes $ p_stableSize(stables,stableTypes),p_replaceYear(stableTypes,hor)+2*p_lifeTimeS(stables,hor)))
                    ) $ p_lifeTimeS(stables,hor));

    v_buyStables.up(stables,hor,t_n(tFull,nCur)) $ (p_lifeTimeS(stables,hor) $ (tFull.pos eq 1)) = 1;
    v_buyStables.up(stables,hor,t_n(tFull,nCur)) $ (p_lifeTimeS(stables,hor) $ (tFull.pos eq p_lifeTimeS(stables,hor)+1))   = 1;
    v_buyStables.up(stables,hor,t_n(tFull,nCur)) $ (p_lifeTimeS(stables,hor) $ (tFull.pos eq p_lifeTimeS(stables,hor)*2+1)) = 1;

    $$if not defined v_buyStablesF option kill=v_buyStablesF.up;
    v_buyStablesF.up(stables,hor,t_n(tFull,nCur)) $ (not (v_buyStablesF.range(stables,hor,tFull,nCur) eq 0)) = v_buyStables.up(stables,hor,tFull,nCur);

$else.compStat
*
*   --- stables can only be build in current year
*
    v_buyStables.up(stables,hor,t_n(t,nCur)) $ ((not tCur(t))) = 0;
    $$if not defined v_buyStablesF option kill=v_buyStablesF.up;
    v_buyStablesF.up(stables,hor,t_n(tCur,nCur)) $ (not (v_buyStablesF.range(stables,hor,tCur,nCur) eq 0)) = v_buyStables.up(stables,hor,tCur,nCur);

$endif.compStat

    v_minInvStables.up(stableTypes,hor,t_n(t,nCur))
      = 1  $ sum(stables $ ((p_stableSize(stables,stableTypes) gt eps) $ (v_buyStables.up(stables,hor,t,nCur) eq 1)),1);

$endif.herd
*
*   --- investment and binary off-farm work decisions are also "timed"
*
$iftheni.compStat1 not "%dynamics%"=="Comparative-static"

    v_buyMach.up(machType,t_n(t,nCur))        =  1;
    v_buyBuildings.up(buildings,t_n(t,nCur))  =  1;

    option kill=v_credits.up;
    option kill=v_sumCredits.up;


$else.compStat1
    v_buyMach.up(machType,t_n(t,nCur))       $ (not p_machAttr(machType,"years"))   =  5;
$endif.compStat1

$iftheni.landBuy %landBuy% == "true"

    p_buyPlotSize = max(1,%maxLandBuy%/10);
    v_buyPlot.up(plot,t_n(t,nCur)) = min(10,%maxLandBuy%) $ p_plotSize(plot);
$else.landBuy
    p_buyPlotSize                  = 0;
    v_buyPlot.up(plot,t_n(t,nCur)) = 0;
$endif.landBuy

 v_cropLandActive.up(t_n(tCur(t),nCur)) = sum(plot_lt_soil(plot,landType,soil), p_plotSize(plot)+ v_buyPlot.up(plot,t,nCur)*p_buyPlotSize) * 1.50;
;
$ifi %greening%==true p_m = smax(t_n(tCur,nCur), v_cropLandActive.up(tCur,nCur));

$iftheni.greening "%greening%"=="true"
    v_haCropGroups.up(cropGroups,t_n(tCur,nCur)) = v_cropLandActive.up(tCur,nCur);
$endif.greening

*  --- bounds derived from initial settings
*
    v_totPlotland.up(plot,t_n(t,nCur)) = [p_plotSize(plot)+ v_buyPlot.up(plot,t,nCur)*p_buyPlotSize] * 1.50;

*$ifi not "%farmBranchArable%" == "on"    v_totLand.up("arab",soil,t) = 0;

    v_croppedLand.up(landType,soil,t_n(t,nCur))  $ (not sameas(landType,"gras"))
       = sum(plot_lt_soil(plot,landType,Soil),  v_totPlotland.up(plot,t,nCur))*1.50;

$iftheni.conv not "%orgTill%"=="enforced"
    v_croppedPlotLand.up(plot,"conv",t_n(t,nCur))               = v_totPlotland.up(plot,t,nCur)*1.50;
$else.conv
    v_croppedPlotLand.up(plot,"conv",t_n(t,nCur))               = 0;
$endif.conv
$iftheni.organic not "%orgTill%"=="off"
    v_croppedPlotLand.up(plot,"org",t_n(t,nCur))                = v_totPlotland.up(plot,t,nCur)*1.50;
$else.organic
    v_croppedPlotLand.fx(plot,"org",t_n(t,nCur))                = 0;
$endif.organic
*
    v_cropHa.up(c_p_t_i(crops,plot,till,intens),t_n(t,nCur)) = v_totPlotland.up(plot,t,nCur)*1.50;

    v_cropHa.up(c_p_t_i(crops,plot,till,intens),t_n(t,nCur)) $ sum((plot_soil(plot,soil),sys_till(sys,till)),p_maxRotShare(crops,sys,soil))
               =  v_totPlotland.up(plot,t,nCur)*1.01  * sum((plot_soil(plot,soil),sys_till(sys,till)),p_maxRotShare(crops,sys,soil));


    v_sumCrop.up(crops,sys,t_n(t,nCur)) $ sum(c_p_t_i(crops,plot,till,intens) $ sys_till(sys,till),1)
      = sum(plot, v_totPlotland.up(plot,t,nCur));


$ifi "%farmBranchArable%" == "on"    v_branchSize.up("cashCrops",t,nCur) $ t_n(t,nCur) = sum( (soil), v_croppedLand.up("arab",soil,t,nCur));
*
*   --- maximal monthly work in hours, assume that hireworkers are somewhat flexible (up to 10% more per month compared to average)
*
    $$ifi not set maxWorkersHired   $set maxWorkersHired 0
    v_labTotM.up(t_n(t,nCur),m)      =  p_monthlyLabH(t,m)+%maxWorkersHired%*%workHoursHired%/card(m)*(1. + %flexHoursHired%/100);
    v_labCropSM.up(t_n(t,nCur),m)    =  p_monthlyLabH(t,m)+%maxWorkersHired%*%workHoursHired%/card(m)*(1. + %flexHoursHired%/100);

    v_fieldWorkHours.up(plot,labReqLevl,labPerSum,t_n(t,nCur))
       = sum(labPerSum_ori(labPerSum,LabPeriod),
               sum(plot_soil(plot,soil),  p_fieldWorkingDays(labReqLevl,labPeriod,"%curClimateZone%",soil)
                 * 12)) * (%Aks%+%maxWorkersHired%);

     v_labOnFarm.up(t_n(t,nCur))   = (p_yearlyLabH(t) + %maxWorkersHired%*%workHoursHired%)*1.01;
     v_labOffTot.up(t_n(t,nCur))   = p_yearlyLabH(t)*1.01;
     v_leisureTot.up(t_n(t,nCur))  = p_yearlyLabH(t) * (1 + %flexHoursFamily%/100) * 1.01;

$iftheni.offFarmWork %allowForOffFarm% == true

     v_labOff.lo(t_n(t,nCur),workType)  =  0;
     v_labOff.up(t_n(t,nCur),workType)  =  1;
     v_labOffB.up(t_n(t,nCur))          =  1;
     v_labOffHourly.up(t_n(t,nCur))     =  min(v_labOffHourly.up(t,nCur)/card(m),smax(m,p_monthlyLabH(t,m)))*card(m);
     v_labOffFixed.up(t_n(t,nCur))      = p_yearlyLabH(t)*1.01;

$else.offFarmWork

     v_labOff.fx(t_n(t,nCur),workType)  = 0;
     v_labOffB.fx(t_n(t,nCur))          = 0;
     v_labOffHourly.up(t_n(t,nCur))     = 0;
     v_labOffFixed.up(t_n(t,nCur))      = 0;

$endif.offFarmWork

*
*   --- fix machine inventory and liquidity in t-1
*
    v_machInv.fx(machType,machLifeUnit,t_n(t,nCur)) $ ((p_year(t+1) eq p_year("%firstYear%"))) = p_iniMach(machtype,machLifeUnit);
    v_liquid.lo(t_n(t,nCur))                        $ ((p_year(t+1) eq p_year("%firstYear%"))) = p_iniLiquid*0.999;
    v_liquid.up(t_n(t,nCur))                        $ ((p_year(t+1) eq p_year("%firstYear%"))) = p_iniLiquid*1.0001;

$iftheni.cattle %cattle% == true
*
*   --- maximum amount of 80 kg fresh weight of any type of feed per kg and animal
*       (beware: feed use decisions might also be timed according to p_decPeriodFeed)
*

    p_reqsPhaseMonths(herds,breeds,feedRegime,reqsPhase,reqs) $ (not sum( (t,m), actherds(herds,breeds,feedRegime,t,m))) = 0;

    option kill=actHerdsF;
    actHerdsF(possHerds,breeds,feedRegime,reqsPhase,m) $ sum( tCur, actHerds(possHerds,breeds,feedRegime,tCur,m)) = YES;
    actHerdsF(herds,breeds,feedRegime,reqsPhase,m) $ ((not p_reqsPhaseMonths(herds,breeds,feedRegime,reqsPhase,"DMMX"))
        $ actHerdsF(herds,breeds,feedRegime,reqsPhase,m)) = NO;

    v_feeding.up(actHerdsF(herds,breeds,feedRegime,reqsPhase,m),feeds,t_n(tCur,nCur))
         = sum(actHerds(herds,breeds,feedRegime,tCur,m),
                              80/1000 * 30.5 * v_herdSize.up(herds,breeds,feedRegime,tCur,nCur,m));

   v_feeding.up(actHerdsF(adults,breeds,feedRegime,reqsPhase,m),"milkPowder",t_n(tCur,nCur)) = 0;
*
*
*   --- no feed use in months where nothing grows
*
    v_feedUseM.up(feedsM,m,t_n(tCur,nCur)) $ ( (not sum( c_p_t_i(curCrops(crops),plot,till,intens)
                                                       $ (v_cropHa.up(crops,plot,till,intens,tCur,nCur) ne 0),
                                                             sum((plot_soil(plot,soil),sameas(prodsMonthly,feedsM)),
                                                                p_OCoeffC(crops,soil,till,intens,prodsMonthly,tCur)))))
      = 0;

    v_feeding.up(actHerdsF(herds,breeds,feedRegime,reqsphase,m),feedsM,t,nCur)
       $ (   (v_feedUseM.up(feedsM,m,t,nCur) eq 0)
           $ (v_feeding.up(herds,breeds,feedRegime,reqsphase,m,feedsM,t,nCur) ne 0)
           $ t_n(t,nCur)) = 0;
*
*   --- no use of gras from pasture for non-grazing herds
*
    v_feeding.up(actHerdsF(herds,breeds,"noGraz",reqsphase,m),feeds,t,nCur) $ sum(sameas(feeds,pastOutputs),1) = 0;
*
*   --- only milk powder or milk fed during first two months of raising processes
*
     v_feeding.up(actHerdsF("mCalvsRais",breeds,feedRegime,"0_2",m),feeds,t,nCur)
        $ (not (sameas(feeds,"milkPowder") or sameas(feeds,"milkFed"))) = 0;
     v_feeding.up(actHerdsF("fCalvsRais",breeds,feedRegime,"0_2",m),feeds,t,nCur)
        $ (not (sameas(feeds,"milkPowder") or sameas(feeds,"milkFed"))) = 0;

     v_feeding.up(actHerdsF(herds,breeds,feedRegime,reqsPhase,m),"milkFed",t,nCur)
       $ (not (sameas(herds,"mCalvsRais") or sameas(herds,"fCalvsRais"))) = 0;
*
*   --- general switch to switch off endogenous reduction of milk yields
*
    $$if not setGlobal redMlk $setGlobal redMlk true
*
*  --- when grouped calvings are set to true, force them to the required months
*
    $$iftheni.groupCalvings %useGroupedCalvings%=="true"
      v_herdStart.up(calvsRais,breeds,t_n(t,nCur),m) = 0;
      v_herdStart.up(calvsRais,breeds,t_n(t,nCur),m) $ (sum(calvMonths $ sameas(m,calvMonths),1)) = inf;
    $$endif.groupCalvings


$endif.cattle

option kill=v_saleQuant.up;
$ifi not %sellGrasSil%==true    v_saleQuant.up(grasSil,sys,t_n(t,nCur))   = 0;
$ifi not %sellMaizSil%==true    v_saleQuant.up(prodsYearly,sys,t_n(t,nCur))   $ sum((maizSilage,soil,till,intens), p_OCoeffC(maizSilage,soil,till,intens,prodsYearly,t))= 0;
*$ifi not %sellAlfalfa%==true    v_saleQuant.up("alfalfa",sys,t_n(t,nCur)) = 0;

$iftheni.organic "%orgTill%"=="enforced"

    v_org.lo(t,nCur) $ t_n(t,nCur) = 1;
    p_inputPrice(inputs,"conv",t)  = 0;
    v_saleQuant.up(prodsYearly,"conv",t_n(t,nCur))  = 0;

$elseifi.organic "%orgTill%"=="off"

    v_saleQuant.up(prodsYearly,"org",t_n(t,nCur))  = 0;
    v_buy.up(inputs,"org",t_n(t,nCur))             = 0;

$endif.organic

$iftheni.herd %herd% == true
*
*   -- only one type of stable at any time
*
    v_stableInv.up(stables,hor,tCur(t),nCur) $ t_n(t,nCur) = 0;
    v_stableInv.up(stables,hor,tFull(t),nCur)
       $ ( sum( (sumHerds,breeds,stableTypes,t_n(t1,nCur1)) $ (   p_stableNeed(sumHerds,breeds,stableTypes)
                                                                              $ (sum((feedRegime,m),v_herdSize.up(sumHerds,breeds,feedRegime,t1,nCur1,m)) gt 0)
                                                                              $ p_stableSize(stables,stableTypes)
                                                                              $ isNodeBefore(nCur,nCur1)),1)
                                                                    $ t_n(t,nCur)) = 100;

    $$if not defined  v_stableUsed option kill=v_stableUsed;
    v_stableUsed.up(stables,t_n(t,nCur)) $ (v_stableUsed.range(stables,t,nCur) ne 0)  = smax(hor, v_stableInv.up(stables,hor,t,nCur));

    v_buyStables.up(stables,hor,tCur(t),nCur)
        $ ( (not sum( (sumHerds,breeds,feedRegime,stableTypes,t_n(t1,nCur1)) $ (   p_stableNeed(sumHerds,breeds,stableTypes)
                                                                   $ (sum(m,v_herdSize.up(sumHerds,breeds,feedRegime,t1,nCur1,m)) gt 0)
                                                                   $ p_stableSize(stables,stableTypes)
                                                                   $ isNodeBefore(nCur,nCur1)),1))
                                                                   $ t_n(t,nCur)) = 0;

    v_buyStables.up(stables,hor,t,nCur)  $ (t_n(t,nCur) $ (p_priceStables(stables,hor,t) le eps)) = 0;

    v_stableInv.up(stables,hor,t_n(t,nCur)) $ (p_priceStables(stables,hor,t) le eps) = 0;
    v_stableInv.up(stables,hor,t_n(t,nCur)) $ (not p_priceStables(stables,hor,t))    = 0;

     $$if not defined v_buyStablesF option kill=v_buyStablesF.up;

    v_buyStablesF.up(stables,hor,t_n(t,nCur)) = min(v_buyStablesF.up(stables,hor,t,nCur),v_buyStables.up(stables,hor,t,nCur));

    v_buyStables.up(stables,hor,t_n(t,nCur)) $ (not p_priceStables(stables,hor,t)) = 0;

    v_buyStables.up(stables,hor,t_n(t,nCur))    $ (t.pos lt smin(tCur(t1), t1.pos)) = 0;
    v_buyStablesF.up(stables,hor,t_n(t,nCur))   $ (t.pos lt smin(tCur(t1), t1.pos)) = 0;

$endif.herd

*
*  ----- remove machinery not used by any active activity
*
*
   v_buyMach.up(machType,t,nCur) $ (
                                 ([  sum( (c_p_t_i(curCrops,plot,till,intens),machLifeUnit) $ p_machNeed(curCrops,till,intens,machType,machLifeUnit),            1)
                                  +  sum( (syntFertilizer,machLifeUnit)                     $ p_machNeed(syntFertilizer,"plough","normal",machType,machLifeUnit),1)
$ifi %herd% == true               +  sum( (actHerds(sumHerds,breeds,feedRegime,t1,m),machLifeUnit)  $ p_machNeed(sumHerds,"plough","normal",machType,machLifeUnit),      1)
$ifi %herd% == true               +  sum( (stables_to_mach(stables,machType),t_n(t1,nCur1)) $ (v_stableInv.up(stables,"long",t1,nCur1) ne 0),1)
                                  ]  eq 0) $ t_n(t,nCur) ) = NO;


   v_buyMach.up(machType,t_n(t,nCur)) $ (t.pos lt smin(tCur(t1), t1.pos)) = 0;

   v_machInv.up(machType,machLifeUnit,t_n(t,nCur)) $ v_machInv.range(machType,machLifeUnit,t,nCur) = p_lifeTimeM(machType,MachLifeUnit);
   v_machInv.up(machType,machLifeUnit,t_n(t,nCur)) $ v_machInv.range(machType,"years",t,nCur)      = 1;

   v_machInv.up(machType,machLifeUnit,t,nCur) $ (t_n(t,nCur) $ (not sum(t_n(t1,nCur1) $ (v_buyMach.up(machType,t1,nCur1) gt 0),1))) = 0;

$ifi %herd% == true   v_siloInv.up(curManChain,silos,t_n(t,nCur)) $ v_siloInv.range(curManChain,silos,t,nCur) = 1;

$ifi %herd% == true   v_siCovComb.up(curManChain,silos,t_n(t,nCur),manStorage) $ v_siloInv.range(curManChain,silos,t,nCur) = 100;

   v_buildingsInv.up(buildings,t,nCur) $ (t_n(t,nCur) $ sum(t_n(t1,nCur1), v_buyBuildings.up(buildings,t1,nCur1)))
        = smax(t_n(t1,nCur1), v_buyBuildings.up(buildings,t1,nCur1));
*
* --- define which machines are based on continous re-investment decisions
*

$ifi not setglobal buyMachFlexThreshold $setglobal buyMachFlexThreshold 3
$ifthene.allFlex round(%buyMachFlexThreshold%)==1000
    $$setglobal buyMachFlexThresHold 1.E+9
$else.allFlex
*    $$ifi "%dynamics%" == "comparative-static"  $evalglobal buyMachFlexThreshold %buyMachFlexThresHold% * 20
$endif.allFlex


    v_buyMach.fx(machType,t_n(t,nCur))
    $ ( (    (p_machAttr(machType,"depCost_ha")     le %buyMachFlexThreshold%) $ p_machAttr(machType,"depCost_ha")
          or (p_machAttr(machType,"depCost_hour")   le %buyMachFlexThreshold%) $ p_machAttr(machType,"depCost_hour") )
                                      $ (not p_machAttr(machType,"years"))) = 0;

    v_buyMachFlex.fx(machType,t_n(t,nCur))
    $  (    (p_machAttr(machType,"depCost_ha")    gt %buyMachFlexThreshold%)
         or (p_machAttr(machType,"depCost_hour")  gt %buyMachFlexThreshold%)
         or p_machAttr(machType,"years")) = 0;
