********************************************************************************
$ontext

   FARMDYN project

   GAMS file : INI_HERDS.GMS

   @purpose  : Define which herds can occur in which month and year
               as well as certain calving attributes

   @author   : Wolfgang Britz, Christop Pahmeyer
   @date     : 12.11.10
   @since    :
   @refDoc   :
   @seeAlso  : model/templ.gms
   @calledBy : exp_starter.gms

$offtext
********************************************************************************

$batinclude 'util/title.gms' "'%titlePrefix% Initialize herd size module'"
*
* --- calculate a correction factor which measures the difference between the prodlength
*     when calculated at 1 month resolution, the rounded correction length, and the
*     number of periods (herdm) in the model to line up the requirements
*
*   --- round production length to number of month
*
    p_prodLength(herds,breeds) $ ( p_prodLength(herds,breeds) gt 1) = round(p_prodLength(herds,breeds));
*
* --- shorten or expand last requirement phase accordingly
*
$ifthen.defReqsPhase defined p_reqsPhaseLengthMonths

    alias(reqsPhase,reqsPhase1);
    p_reqsPhaseLengthMonths(herds,curBreeds,reqsPhase)
            $ ( herds_breeds(herds,curBreeds) $ (smax(reqsPhase1 $ p_reqsPhaseLengthMonths(herds,curBreeds,reqsPhase1), reqsPhase1.pos) eq reqsPhase.pos)
                                $ p_compStatHerd $ (p_prodLength(herds,curBreeds) le 12))
              = p_reqsPhaseLengthMonths(herds,curBreeds,reqsPhase)
                 + p_prodLength(herds,curBreeds) - sum(reqsPhase1,p_reqsPhaseLengthMonths(herds,curBreeds,reqsPhase1));

$endif.defReqsPhase
*
*   --- Definition of active herds within a pig herd
*
    option kill=sold_comp_herds;
    option kill=bought_to_herds;
$iftheni.pigHerd %pigHerd% == true
   $$iftheni.fattners "%farmBranchFattners%" == "on"

       actHerds("PigFattened","",feedRegimePigs,t,m)       = yes;
       actHerds("Fattners","",feedRegimePigs,t,m)          = yes;
       actHerds("earlyFattners","",feedRegimePigs,t,m)     = yes;
       actHerds("midFattners","",feedRegimePigs,t,m)       = yes;
       actHerds("lateFattners","",feedRegimePigs,t,m)      = yes;
       actHerds("pigletsBought","",feedRegimePigs,t,m)     = yes;

       bought_to_herds("pigletsBought","","earlyFattners") = yes;

       herds_from_herds("midfattners","earlyfattners","")  = yes;
       herds_from_herds("lateFattners","midFattners","")   = yes;
       herds_from_herds("Fattners","lateFattners","")      = yes;

   $$endif.fattners

   $$iftheni.sows "%farmBranchSows%" == "on"

      herds_from_herds("piglets","youngPiglets","")  = yes;

      bought_to_herds("youngSows","","sows")         = yes;

      actHerds("piglets","",feedRegimePigs,t,m)      = yes;
      actHerds("sows","",feedRegimePigs,t,m)         = yes;
      actHerds("youngPiglets","",feedRegimePigs,t,m) = yes;
      actHerds("youngSows","",feedRegimePigs,t,m)    = yes;
   $$endif.sows

   possHerds(herds) $ sum(actHerds(herds,"",feedRegime,t,m),1) = yes;

$endif.pigHerd

$iftheni.cowherd %cowHerd%==true

* -----------------------------------------------------------------------------
*
*   Definition of herd module (which herd type is found in which year)
*
* -----------------------------------------------------------------------------
*
   $$ife %nMotherCows%>0  actHerds("motherCow","%motherCowBreed%",feedRegimeCattle,t,m) = yes;

   parameter p_livingCalvesPerYear(cows,cowTypes);

   p_livingCalvesPerYear(cows,cowTypes)
      =  p_calvAttr(cowTypes,"birthPerLact")
             *  p_calvAttr(cowTypes,"livingCalvesPerBirth")
             *  (1. - p_calvAttr(cowTypes,"calvLosses"))
             *  365 / p_calvAttr(cowTypes,"daysBetweenBirths");

*
*  --- determine point where calves are born (prob. distribution depending on days between births
*
*
*  --- assumed probability for birth after 12 - 15 months
*
   set curCycleLength / l11*l15 /;
*
*  --- entropy estimator
*
   variable v_ent "Entropy";
   positive variables         v_prob(cowTypes,curCycleLength)

   parameter p_cycleLength(curCycleLength);
   p_cycleLength(curCycleLength) = 10 + curCycleLength.pos;


   equation e_ent                    "Entropy definition"
            e_daysBetweenBirths      "Recover given information on inter calving interval"
            e_sumUnity               "Probs add up to unity"
   ;

   e_ent .. -v_ent =E=  sum( (cowTypes,curCycleLength),v_prob(cowTypes,curCycleLength)
                                 * log(v_prob(cowTypes,curCycleLength)/card(curCycleLength)));

   e_daysBetweenBirths(cowTypes) ..
        p_calvAttr(cowTypes,"daysBetweenBirths")/30.5
                 =E=  sum(curCycleLength, v_prob(cowTypes,curCycleLength)* p_CycleLength(curCycleLength));

   e_sumUnity(cowTypes) $ (not sameas(cowTypes," ")) ..  sum(curCycleLength, v_prob(cowTypes,CurCycleLength)) =E= 1;

   v_prob.up(cowTypes,curCycleLength) = 1;
   v_prob.lo(cowTypes,curCycleLength) = 1.E-5;

   v_prob.fx(cowTypes,curCycleLength) $ (p_calvAttr(cowTypes,"daysBetweenBirths")/30.5 lt p_CycleLength(curCycleLength)-1) = 1.E-6;
   v_prob.fx(cowTypes,curCycleLength) $ (p_calvAttr(cowTypes,"daysBetweenBirths")/30.5 gt p_CycleLength(curCycleLength)+1) = 1.E-6;

   v_prob.l(cowTypes,CurCycleLength)  = 1/card(CurCycleLength);

   model m_ent / e_ent,e_daysBetweenBirths,e_sumUnity /;
   m_ent.solprint = 2;
$ifi "%debugOutput%"=="true" m_ent.solprint = 1;

   solve m_ent maximizing v_ent using NLP;

   v_prob.l(cowTypes,curCycleLength) $ (v_prob.l(cowTypes,curCycleLength) eq 1.E-6) = 0;

*
*  --- calving of heifer: always in first month
*
    p_calvCoeff(cows,curBreeds,"d1") $ herds_breeds(cows,curBreeds) = 1;
*
*  --- calving in later lactations
*      we extend the calving probability information recovered from the entropy
*      estimator to the upcoming lactations

   set props /min,max/;

   parameter
     calvMonthMin(cowTypes)
     calvMonthMax(cowTypes)
     p_calvProbability(cowTypes,props)
   ;

   calvMonthMin(cowTypes)
     = smin((curCycleLength)
       $ (v_prob.l(cowTypes,curCycleLength) gt 0),
       curCycleLength.pos + 10
     );
   calvMonthMax(cowTypes)
     = smax((curCycleLength)
       $ (v_prob.l(cowTypes,curCycleLength) gt 0),
       curCycleLength.pos + 10
     );

   p_calvProbability(cowTypes,"min")
     = smin((curCycleLength)
       $ (v_prob.l(cowTypes,curCycleLength) gt 0),
       v_prob.l(cowTypes,curCycleLength)
     );

   p_calvProbability(cowTypes,"max")
     = smax((curCycleLength)
       $ (v_prob.l(cowTypes,curCycleLength) gt 0),
       v_prob.l(cowTypes,curCycleLength)
     );

   set lactation /1*14/;
   set lactation_months(cowTypes,lactation,mDist);
   lactation_months(cowTypes,lactation,mDist)
     $ ((mDist.pos >= calvMonthMin(cowTypes)  * lactation.pos)
     $ (mDist.pos <= calvMonthMax(cowTypes) * lactation.pos))
     = YES;

   p_calvCoeff(cows,curBreeds,mDist) $ (herds_breeds(cows,curBreeds) $ (mDist.pos >= 11) )
     = sum((lactation,cowTypes)
         $ (lactation_months(cowTypes,lactation,mDist)
         $ (lactation.pos < p_nLac(cows))
         $ (herds_cowTypes(cows,cowTypes))),
     binomial(lactation.pos * (calvMonthMax(cowTypes) - calvMonthMin(cowTypes)),
              mDist.pos - (calvMonthMin(cowTypes) * lactation.pos))
       * (  p_calvProbability(cowTypes,"min") ** (lactation.pos - (mDist.pos - (calvMonthMin(cowTypes) * lactation.pos)) )
         *  p_calvProbability(cowTypes,"max") ** (mDist.pos - (calvMonthMin(cowTypes) * lactation.pos))
         )
     );

*parameter p_test;
*p_test(cows,breeds) = sum((Mdist),p_calvCoeff(cows,breeds,Mdist));
*abort p_test;
*
*  --- Adjust calving coefficient for living calves per year
* $ (mDist.pos > 1)
   p_calvCoeff(cows,curBreeds,mDist) $ (herds_breeds(cows,curBreeds))
     = p_calvCoeff(cows,curBreeds,mDist)
     * sum(cowTypes $ (herds_cowTypes(cows,cowTypes)), p_livingCalvesPerYear(cows,cowTypes));

   alias(mDist,mDist1,mDist2);

   $$iftheni.compStat "%dynamics%"=="Comparative-static"

*
*     --- calculate average calving coefficient over lactations
*
      p_calvCoeff(cows,curBreeds,mDist) $ (herds_breeds(cows,curBreeds) $ (mDist.pos <= 12)
             $ sum(mDist1 $ ((mod(mDist1.pos,12) eq mod(mDist.pos,12)) $ p_calvCoeff(cows,curBreeds,mDist1)),1))
         = sum(mDist1 $ (mod(mDist1.pos,12) eq mod(mDist.pos,12)),
              p_calvCoeff(cows,curBreeds,mDist1))
               / p_nLac(cows);

        p_calvCoeff(cows,curBreeds,mDist) $ (mDist.pos gt 12) = 0;
    $$endif.compStat
*
*  --- Disable calving distribution when grouped calvings are used
*
$iftheni.gc %useGroupedCalvings%=="true"
  p_calvCoeff(cows,dairyBreeds,"d1")
    = sum((mDist),p_calvCoeff(cows,dairyBreeds,Mdist));
  p_calvCoeff(cows,breeds,mDist) $ (not sameas(mdist,"d1")) = 0;
$endif.gc


    actHerds("fCalvsRais",curBreeds,feedRegimeCattle,t,m) = yes;
    actHerds("fCalvsSold",curBreeds,"",t,m)               = yes;
    actHerds("mCalvsRais",curBreeds,feedRegimeCattle,t,m) = yes;
    actHerds("mCalvsSold",curBreeds,"",t,m)               = yes;

    actHerds(heifs,curBreeds,feedRegimeCattle,t1,m) $  herds_breeds(heifs,curBreeds)  = yes;
*

    herds_from_herds("mCalvsRaisSold","mCalvsRais",dairyBreeds) = yes;

    herds_from_herds(heifs,heifs1,dairyBreeds) $ ( p_fParam(heifs,dairyBreeds,"startWgt")
                                                     and (   p_fParam(heifs,dairyBreeds,"startWgt")
                                                          eq p_fParam(heifs1,dairyBreeds,"finalWgt"))
                                                                  $ (not sameas(heifs,heifs1))
                                                                  $ herds_breeds(heifs,dairyBreeds)) = yes;

    herds_from_herds(heifsBase,"fCalvsRais","%basBreed%")
      $ ( p_fParam(heifsBase,"%basBreed%","startWgt")
      $ (   p_fParam(heifsBase,"%basBreed%","startWgt")
        eq p_calvsParam("fCalvsRais","%basBreed%","finalWgt")))
    = yes;

    $$iftheni.mc "%farmBranchMotherCows%"=="on"
      herds_from_herds(heifsMC,"fCalvsRais","%motherCowBreed%")
                    $ (   p_fParam(heifsMC,"%motherCowBreed%","startWgt") eq p_calvsParam("fCalvsRais","%motherCowBreed%","finalWgt")) = yes;
    $$endif.mc

    $$iftheni.cross "%crossBreeding%"=="true"
      herds_from_herds(heifsCross,"fCalvsRais",crossBreeds)
                    $ (   p_fParam(heifsCross,crossBreeds,"startWgt") eq p_calvsParam("fCalvsRais",crossBreeds,"finalWgt")) = yes;
    $$endif.cross

    actHerds(heifs,curBreeds,feedRegimeCattle,t,m) $ (  actHerds("fCalvsRais",curBreeds,feedRegimeCattle,t,m)
       $ herds_from_herds(heifs,"fCalvsRais",curBreeds)) = yes;

    actherds("heifs",curBreeds,feedRegimeCattle,t,m)  $ sum(heifs, actherds(heifs,curBreeds,feedRegimeCattle,t,m)) = yes;

*
*  --- Settings for buying heifers for replacements
*

$$iftheni.buyh %buyHeifs% == true

  actHerds(heifsBought,curBreeds,"",t,m) $sum((heifs)$((heifsBought.pos eq heifs.pos) $(p_heifsAttr(heifs,"price")
       $$ifi defined p_heifsAttrMC      or p_heifsAttrMC(heifs,"price")
       $$ifi defined p_heifsAttrCross   or p_heifsAttrCross(heifs,"price")
        )),  1) = yes;

  actherds("heifsBought",curbreeds,"",t,m)  $ sum(heifsBought,actherds(heifsBought,curbreeds,"",t,m)) = yes;

*    $$ifi "%farmBranchMotherCows%"=="on"  bought_to_herds(heifsBought,"%motherCowBreed%","remonteMotherCows")  = yes;
*    $$ifi  %dairyHerd%==true              bought_to_herds(heifsBought,"%basBreed%","remonte")                  = yes;

  bought_to_herds(heifsbought,curBreeds,heifs)
    $( ( p_fParam(heifs,curBreeds,"startWgt") $ p_prodLength(heifs,curBreeds)
         eq p_fParam(heifsbought,curBreeds,"finalWgt"))
         $herds_breeds(heifs,curbreeds) $herds_breeds(heifsbought,curbreeds)
         $sum((t,m)$actHerds(heifsBought,curBreeds,"",t,m),1)) = yes;


$$endif.buyh
*
*  --- Settings for selling heifers
*
$$iftheni.sellHeifs %sellHeifs%==true

  set breedsHeif(breeds);
  $$ifi "%farmBranchMotherCows%"=="on"  breedsHeif("%motherCowBreed%") = YES;
  $$ifi "%farmBranchDairy%"=="on"       breedsHeif(dairyBreeds)        = YES;
  $$ifi "%crossBreeding%"=="true"       breedsHeif(crossBreeds)        = YES;

  p_fParam(heifs,breedsHeif,"startWgt") = round(p_fParam(heifs,breedsHeif,"startWgt"));
  p_fParam(heifs,breedsHeif,"finalWgt") = round(p_fParam(heifs,breedsHeif,"finalWgt"));

  sold_comp_herds(heifsSold,breedsHeif,heifs) $ ( p_fParam(heifs,breedsHeif,"startWgt")
                                                   and (   p_fParam(heifs,breedsHeif,"startWgt")
                                                        eq p_fParam(heifsSold,breedsHeif,"finalWgt"))
                                                                $ (not sameas(heifs,heifsSold))
                                                                $ herds_breeds(heifsSold,breedsHeif)) = yes;


  $$iftheni.base defined p_heifsAttr
     herds_from_herds(heifsSold,heifs,"%basBreed%") $ ((not sum(heifs1,sold_comp_herds(heifsSold,"%basBreed%",heifs1)))
       $   (heifsSold.pos eq heifs.pos) $ (p_heifsAttr(heifs,"price") $ herds_breeds(heifsSold,"%basBreed%"))) = YES;
      actHerds(heifsSold,"%basBreed%","",t,m) $ sum(heifs $ (heifsSold.pos eq heifs.pos), p_heifsAttr(heifs,"price")) = yes;
  $$endif.base

  $$iftheni.mc  defined p_heifsAttrMC
     herds_from_herds(heifsSold,heifs,"%motherCowBreed%") $ ( (not sum(heifs1,sold_comp_herds(heifsSold,"%motherCowBreed%",heifs1)))
       $   (heifsSold.pos eq heifs.pos) $ p_heifsAttrMC(heifs,"price") $ herds_breeds(heifsSold,"%motherCowBreed%")) = YES;
      actHerds(heifsSold,"%motherCowBreed%","",t,m) $ sum(heifs $ (heifsSold.pos eq heifs.pos), p_heifsAttrMC(heifs,"price")) = yes;
  $$endif.mc

  $$iftheni.SI  defined p_heifsAttrSI
     herds_from_herds(heifsSoldSI,heifsCross,crossBreeds) $ ((heifsCross.pos eq heifsSoldSI.pos)
        and (not sum(sold_comp_herds(heifsSoldSI,breedsHeif,heifs),1))) = YES;
  $$endif.SI

  option dispWidth=26;
  $$ifi "%debugOutput%"=="true"  display sold_comp_herds,herds_from_herds;
  option dispWidth=15;
  option p_fParam:7;

  actherds("heifsSold",BreedsHeif,"",t,m)  $ sum(heifsSold,actherds(heifsSold,breedsHeif,"",t,m))   = yes;

$$endif.sellHeifs
*
*  ---  Settings for combined dairy and bull fattening
*
  $$iftheni.beef "%farmBranchBeef%"=="on"
     actHerds("mCalvsRais",curBreeds,feedRegimeCattle,t,m)  = yes;

     $$iftheni.crossBreed "%crossBreeding%"=="true"

        actHerds("fCalvsRais",crossBreeds,feedRegimeCattle,t,m)     = yes;
        actHerds("fCalvsSold",crossBreeds,"",t,m)                   = yes;
        actHerds("mCalvsRais",crossBreeds,feedRegimeCattle,t,m)     = yes;
        actHerds("mCalvsSold",crossBreeds,"",t,m)                   = yes;

     $$endif.crossBreed
  $$endif.beef
$endif.cowHerd

*
*  --- Dairy specific settings
*
$iftheni.dh %dairyHerd%==true

      $$ifi %sellHeifs%==false p_heifsAttr(heifs,"price") = 0;


      actHerds(dcows,"%BasBreed%",feedRegimeCattle,t,m)                           = yes;
      actHerds("remonte","%basBreed%","",t1,m)                                    = yes;

      herds_from_herds("remonte",heifs,"%basBreed%")
           $ ((p_fParam(heifs,"%basBreed%","finalWgt") ge 550) $ herds_breeds(heifs,"%basBreed%")
                  and (not p_heifsAttr(heifs,"price"))) = yes;

      if (not sum(herds_from_herds("remonte",heifs,"%basBreed%"),1),
         abort "No heifers process with a zero price defined >= 550 kg which would allow to replace dairy cows, (%system.fn%, line: %system.incline%)";
      );


      herds_from_herds(dcows,"remonte","%basBreed%")                              = yes;

    $$iftheni.slgt %allowSlgtCow% == true
      sold_comp_herds(slgtCows,"%basBreed%",dcows) $ (slgtCows.pos eq dcows.pos ) = yes;
      actHerds("slgtCowsShort","%basBreed%","",t,m)                               = yes;
      actHerds("slgtCowsLong","%basBreed%","",t,m)                                = yes;
    $$endif.slgt

$endif.dh


*
*  --- Mothercow specific settings
*
$iftheni.mc "%farmBranchMotherCows%"=="on"

      actherds("remonteMotherCows","%motherCowBreed%","",t,m)                           = yes;

      herds_from_herds("remonteMotherCows",heifs,"%motherCowBreed%")
        $ ((p_fParam(heifs,"%motherCowBreed%","finalWgt") ge 550)  $ herds_breeds(heifs,"%motherCowBreed%")
             and (not p_heifsAttrMC(heifs,"price"))) = yes;

      if (not sum(herds_from_herds("remonteMotherCows",heifs,"%motherCowBreed%"),1),
         abort "No heifers process with a zero price defined >= 550 kg which would allow to replace mother cows, (%system.fn%, line: %system.incline%)";
      );

      herds_from_herds("motherCow","remonteMotherCows","%motherCowBreed%")              = yes;

  $$ifi %allowSlgtCow% == true   actHerds("slgtMotherCows","%motherCowBreed%","",t,m)   = yes;
      sold_comp_herds("slgtMotherCows","%motherCowBreed%","motherCow")                  = yes;

$endif.mc

*
*  --- Bull fattening specific settings
*
$iftheni.beef "%farmBranchBeef%"=="on"

  actHerds(bulls,curBreeds,feedRegimeCattle,t,m) $ p_prodLength(bulls,curBreeds)  = yes;

  $$ifi defined bullsSoldHF            herds_from_herds(bullsSoldHF,bullsBase,"%basBreed%") $ (bullsBase.pos eq bullsSoldHF.pos) = yes;
  $$ifi "%farmBranchMotherCows%"=="on" herds_from_herds(bullsSoldMC,bullsMC,"%motherCowBreed%") $ (bullsMC.pos eq bullsSoldMC.pos) = yes;
  $$ifi "%crossBreeding%"=="true"      herds_from_herds(bullsSoldSI,bullsCross,crossBreeds) $ (bullsCross.pos eq bullsSoldSI.pos) = yes;

  actherds("bulls",curBreeds,feedRegimeCattle,t,m)  $ sum(bulls, actherds(bulls,curBreeds,feedRegimeCattle,t,m)) = yes;

  herds_from_herds(bulls,bulls1,curBreeds) $ ( p_mParam(bulls,curBreeds,"startWgt")
                                                   and (   p_mParam(bulls,curBreeds,"startWgt")
                                                        eq p_mParam(bulls1,curBreeds,"finalWgt"))
                                                                $ (not sameas(bulls,bulls1))
                                                                $ herds_breeds(bulls,curBreeds)) = yes;

  actHerds(bullsSold,curBreeds,"",t,m)
    $ sum( (bulls,feedRegimeCattle) $( (bulls.pos eq bullsSold.pos) $p_mParam(bulls,curBreeds,"Price")), actHerds(bulls,curBreeds,feedRegimeCattle,t,m)) = yes;

  $$iftheni.buyYoungBulls "%buyYoungBulls%"=="true"
     bought_to_herds(bullsBought,curBreeds,bulls1)
        $ ( p_mParam(bulls1,curBreeds,"startWgt") $ p_prodLength(bulls1,curBreeds)
                  eq p_mParam(bullsBought,curBreeds,"finalWgt")) = yes;

  actHerds(bullsBought,curBreeds,"",t,m)
     $( sum(bought_to_herds(bullsBought,curBreeds,bulls),1)
     $ sum( (bulls,feedRegimeCattle) $( (bulls.pos eq bullsBought.pos) $p_mParam(bulls,curBreeds,"Price")), actHerds(bulls,curBreeds,feedRegimeCattle,t,m)) ) = yes;

  $$endif.buyYoungBulls

  $$iftheni.buy "%buyCalvs%"=="true"
    herds_from_herds(bullsBase,"mCalvsRais","%basBreed%")
       $ (herds_breeds(bullsBase,"%basBreed%") $(   p_mParam(bullsBase,"%basBreed%","startWgt") eq p_calvsParam("mCalvsRais","%basBreed%","finalWgt"))) = yes;

   actHerds("mCalvsRaisBought","%basBreed%","",t,m) = yes;
   actHerds("mCalvsRais","%basBreed%",feedRegimeCattle,t,m)  = yes;

   actHerds(bulls,curBreeds,feedRegimeCattle,t,m) $ (  actHerds("mCalvsRais",curBreeds,feedRegimeCattle,t,m)
      $ herds_from_herds(bulls,"mCalvsRais",curBreeds)) = yes;

   actherds("bulls",curBreeds,feedRegimeCattle,t,m)  $ sum(bulls, actherds(bulls,curBreeds,feedRegimeCattle,t,m)) = yes;
  $$endif.buy

  $$iftheni.cw %cowHerd%==true

     herds_from_herds(bullsBase,"mCalvsRais","%basBreed%")
        $ (herds_breeds(bullsBase,"%basBreed%") $(   p_mParam(bullsBase,"%basBreed%","startWgt") eq p_calvsParam("mCalvsRais","%basBreed%","finalWgt"))) = yes;

     $$iftheni.mc "%farmBranchMotherCows%"=="on"
       herds_from_herds(bullsMC,"mCalvsRais","%motherCowBreed%")
          $ (herds_breeds(bullsMC,"%motherCowBreed%") $(   p_mParam(bullsMC,"%motherCowBreed%","startWgt") eq p_calvsParam("mCalvsRais","%motherCowBreed%","finalWgt"))) = yes;
     $$endif.mc

     $$iftheni.cross "%crossBreeding%"=="true"
       herds_from_herds(bullsCross,"mCalvsRais",crossBreeds)
                     $ (   p_mParam(bullsCross,crossBreeds,"startWgt") eq p_calvsParam("mCalvsRais",crossBreeds,"finalWgt")) = yes;

     $$endif.cross
     actHerds(bulls,curBreeds,feedRegimeCattle,t,m) $ (  actHerds("mCalvsRais",curBreeds,feedRegimeCattle,t,m)
        $ herds_from_herds(bulls,"mCalvsRais",curBreeds)) = yes;

     actherds("bulls",curBreeds,feedRegimeCattle,t,m)  $ sum(bulls, actherds(bulls,curBreeds,feedRegimeCattle,t,m)) = yes;
  $$endif.cw

$endif.beef


$iftheni.ch %cowHerd%==true

   $$ifi not "%Dynamics%"  ==  "Comparative-static"  actHerds(slgtCows,curBreeds,"","%firstYear%",m) = no;

       p_reqsPhaseMonths(herds,curBreeds,feedRegime,reqsPhase,reqs)
         $ (herds_breeds(herds,curBreeds)
         $ (not sum( (feedRegimeCattle,t,m),
           actHerds(herds,curBreeds,feedRegimeCattle,t,m)))) = 0;
$$endif.ch
*

$$iftheni.compStat "%dynamics%"=="Comparative-static"

    actHerds(herds,curBreeds,feedRegime,t,m) $ (not tCur(t)) = 0;
    $$ifi %cowHerd%==true actHerds(cows,curBreeds,feedRegime,t,m)  $ (not p_iniHerd(cows,curBreeds)) = 0;

$$endif.compStat

    option herds_from_herds:0:2:1;option actherds:0:4:1;

   actHerds(sumHerds,curBreeds,feedRegime,t,m)
        $ sum(sum_herds(sumHerds,herds) $ actHerds(herds,curBreeds,feedRegime,t,m),1) = yes;

   possHerds(herds) $ sum((curBreeds,feedRegime,t,m),
                      actHerds(herds,curBreeds,feedRegime,t,m)) = yes;
   possActs(possHerds) = yes;
   p_prodLengthB(herds,breeds) = p_prodLength(herds,breeds);
   p_herdYearScaler(balHerds,breeds) = 1;

   $$iftheni.compStat "%dynamics%" == "comparative-static"
      p_prodLengthB(herds,breeds) $ (p_prodLength(herds,breeds) gt 12) = p_prodLength(herds,breeds)-12;
      p_prodLengthB(herds,breeds) $ (p_prodLength(herds,breeds) gt 24) = p_prodLength(herds,breeds)-24;
      p_prodLengthB(herds,breeds) $ (p_prodLength(herds,breeds) gt 36) = p_prodLength(herds,breeds)-36;
      p_prodLengthB(herds,breeds) $ (p_prodLength(herds,breeds) gt 48) = p_prodLength(herds,breeds)-48;

      $$ if defined cows p_herdYearScaler(cows,breeds) $ (p_prodLength(cows,breeds) gt 12) =  p_prodLength(cows,breeds)/12;

      p_mDist(t,m,t1,m1) $ (not (sameas(t,"%firstYear%") and sameas(t1,"%firstYear%"))) = 100;

      tCur(t) $ (not sameas(t,"%firstYear%")) = no;
      actherds(balHerds,breeds,feedRegime,t,m) $ (not sameas(t,"%firstYear%")) = no;
      actherds(herds,breeds,feedregime,t,m) $ (not herds_breeds(herds,breeds)) = no;
      actherds(herds,breeds,feedregime,t,m) $(not sum(sameas(breeds,curbreeds),1)) = no;

   $$endif.compStat

$ifi "%debugOutput%"=="true"   display possHerds,p_prodLength,actHerds,bought_to_herds,balHerds,herds_from_herds,sold_comp_herds,herds_from_herds;
   set curFeedRegime(feedRegime);
   curFeedRegime(feedRegime) $ sum( (herds,t,m), actHerds(herds," ",feedRegime,t,m)) = YES;
   option dispWidth=31;
$ifi "%debugOutput%"=="true"   display "%sellHeifs%",actHerds,sold_comp_herds,herds_breeds,"%basBreed%",balHerds;
   option dispWidth=15;
