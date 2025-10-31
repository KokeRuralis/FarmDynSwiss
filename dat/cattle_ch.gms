********************************************************************************
$ontext

   FarmDyn project

   GAMS file : CATTLE_DE.GMS

   @purpose  : Parameters relating to cattle not covered by user interface
   @author   :
   @date     : 12.03.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************
*
* --- variable costs at  150 Euro per cow and year at 4000 liters,
*     increasing to 300 Euro per cow and year at 10000 liters
*     (net of feed cost)


    p_Vcost("motherCow",curBreeds,t)   =   5 * ([1+%outputPriceGrowthRate%/100]**t.pos);
    p_Vcost("fCalvsSold",curBreeds,t)  =   5 * ([1+%outputPriceGrowthRate%/100]**t.pos);
    p_Vcost("mCalvsSold",curBreeds,t)  =   5 * ([1+%outputPriceGrowthRate%/100]**t.pos);
*
* --- Factors to calculate stocking rate and density, taken from FO
*
    $$ifi defined cows      p_lu(cows,curBreeds)      $ herds_breeds(cows,curbreeds)      = 1;
    $$ifi defined heifs     p_lu(heifs,curBreeds)     $ herds_breeds(heifs,curbreeds)     = 0.7;
    $$ifi defined calvsRais p_lu(calvsrais,curBreeds) $ herds_breeds(calvsrais,curbreeds) = 0.3;
    $$ifi defined bulls     p_lu(bulls,curBreeds)     $ herds_breeds(bulls,curbreeds)     = 0.7;


*
* --- calculation for partial grazing: assume that it takes 0.5 hour a day to get the herd from the stable
*                                        to the pasture and back = 15 hours are months
*
*                                        assuming 60 cows = 0.25 hour per animal and month
*                                        assuming 30 heifers/bulls = 0.5 hours per animal and month
*                                        assume that calves can be driven with heifers/buls: 0.25

  p_herdLab("cows","noGraz",m)       =  20/card(m);
  p_herdLab("cows","partGraz",m)     =  20/card(m) + 0.25;
*
* --- full grazing for cows means that the milking has to be done
*     outside: assume quite some work load
*
  p_herdLab("cows","fullGraz",m)     =  50/card(m);
*
* --- KTBL estimate is 26 hours per mother cow and year, which however includes
*     the raising process (mCalvesRais,fmfCavlsRais,heifers);
*     the remaining hours are attributed to the mother cow
*
  p_herdLab("motherCow","fullGraz",m)  =   10/card(m);
  p_herdLab("motherCow","partGraz",m)  =   10/card(m) + 0.5;
  p_herdLab("motherCow","noGraz",m)    =   15/card(m);

  p_herdLab("heifs","noGraz",m)        =   9 / card(m);
  p_herdLab("heifs","partGraz",m)      =   9 / card(m) + 0.5;
  p_herdLab("heifs","fullGraz",m)      =   5 / card(m);
*
  p_HerdLabStart(sumHerds,m) $ sum(sameas(sumherds,calvs),1) = 1;
*
* --- we assume that calves sold stay 14 days on the farm!
*
  p_herdLab("mCalvsSold",feedRegime,m)    =   0.5/12;

  p_herdLab("fCalvsSold",feedRegime,m)    =   0.5/12;
*
* --- raising calves are for 12 months on the farm,
*     10 hours total
*
  p_herdLab("fCalvsRais","noGraz",m)   = 10/12;
  p_herdLab("fCalvsRais","partGraz",m) = 10/12 + 0.25;
  p_herdLab("fCalvsRais","fullGraz",m) =  8/12;
*
* --- bull fattening, for 12 months on the farm,
*      8 hours total
*
  p_herdLab("mCalvsRais","noGraz",m)   = 10/12;
  p_herdLab("mCalvsRais","partGraz",m) = 10/12 + 0.25;
  p_herdLab("mCalvsRais","fullGraz",m) =  8/12;


$iftheni.bulls defined bulls

  p_herdLab("bulls","noGraz",m)        =   9 / card(m);
  p_herdLab("bulls","partGraz",m)      =   9 / card(m) + 0.25;
  p_herdLab("bulls","fullGraz",m)      =   5 / card(m);

$endif.bulls


*
* --- Machinery need link to cattle for small tractor
*L.K 14.08.2019: Looks like a rather relaxed assumption, changed it for bulls
*
  p_machNeed(sumHerds,"plough","normal","tractorSmall","hour") $ sum((m,feedRegime),p_herdLab(sumherds,feedRegime,m))
     = smax((m,feedRegime),p_herdLab(sumherds,feedRegime,m))
                                         * (  (1/5) $ sameas(sumHerds,"cows")
                                            + (1/4) $ sameas(sumHerds,"heifs")
                                            + (1/4) $ sameas(sumHerds,"mothercow")
                                            + (1/6) $ ( (sameas(sumHerds,"fCalvsRais") or sameas(sumHerds,"mCalvsRais")))
                                            +  1 $ sameas(sumHerds,"bulls"));

  $$ifi defined bulls p_machNeed(bulls,"plough","normal","tractorSmall","hour") = p_machNeed("bulls","plough","normal","tractorSmall","hour");
  $$ifi defined heifs p_machNeed(heifs,"plough","normal","tractorSmall","hour") = p_machNeed("heifs","plough","normal","tractorSmall","hour");
  p_machNeed(dcows,"plough","normal","tractorSmall","hour") = p_machNeed("cows","plough","normal","tractorSmall","hour");

*
* --- Manure excretion values of volumes according to German Fertilizer Ordinance (DueV, Annex 9) in qm per month
*
  $$ifi set milkYield       p_manQuantMonth(cows,"liquidCattle")          = ( 19 + 1 $ (%milkYield% > 78) + 1 $ (%milkYield% > 98) )/card(m);
                            p_manQuantMonth("mcalvsRais","liquidCattle")  = ( 1.5 * 2  * 16/52   +   4.65 * 2     * 36/52  ) / card(m) ;
  $$ifi defined fCalvsRais  p_manQuantMonth(fcalvsRais,"liquidCattle")    = ( 1.5 * 2  * 16/52   +   4.65 * 2     * 36/52  ) / card(m) ;
  $$ifi defined heifs       p_manQuantMonth(heifs,"liquidCattle")         = ( 4.65 * 2 ) / card(m);
                            p_manQuantMonth("heifs","liquidCattle")       = ( 4.65 * 2 ) / card(m);
  $$ifi defined bulls       p_manQuantMonth(bulls,"liquidCattle")         = ( 3.65 * 2 ) / card(m);
  $$ifi defined bulls       p_manQuantMonth("bulls","liquidCattle")       = ( 3.65 * 2 ) / card(m);
  p_manQuantMonth("MotherCow","liquidCattle")   = 19 / card(m);

table  p_nutExcreDueV(duevHerds,feedRegime,allNut) "Defintion of N and P excretion of different herds according to fertilizer directive"

                                                  N            P

   $$iftheni.ar %arable% == true

   motherCow    .(set.feedRegimeCattle)          103          37


   cow7800      .(set.feedRegimeCattle)          103          37

   cow9800      .(set.feedRegimeCattle)          117          42

   cowHigh      .(set.feedRegimeCattle)          134          47

   heifs.(set.feedRegimeCattle)                   48          15.5

   fCalvsRais.(set.feedRegimeCattle)            38.34         12.7

   mCalvsRais.(set.feedRegimeCattle)            38.34         12.7

$iftheni.bulls defined bulls
   bulls.(set.feedRegimeCattle)                 39.1          14.2
$endif.bulls
   $$else.ar

   motherCow.(set.feedRegimeCattle)              114          36

   cow7800.(set.feedRegimeCattle)               114          36

   cow9800.(set.feedRegimeCattle)               129          43

   cowHigh.(set.feedRegimeCattle)               143          47

   heifs.(set.feedRegimeCattle)                   57          16.4

   fCalvsRais.(set.feedRegimeCattle)            44.57         13.32

   mCalvsRais.(set.feedRegimeCattle)            44.57         13.32

$iftheni.bulls defined bulls
   bulls.(set.feedRegimeCattle)                 39.1          14.2
$endif.bulls

   $$endif.ar
;


$iftheni.dh %cowherd% == true

   p_nutExcreDuev(cows,feedRegime,nut) $ ((%milkYield% < 80) $ (not p_nutExcreDuev(cows,feedRegime,nut)))
       = p_nutExcreDuev("cow7800",feedRegime,nut);

   p_nutExcreDuev(cows,feedRegime,nut) $ ((%milkYield% < 100) $ (not p_nutExcreDuev(cows,feedRegime,nut)))
       = p_nutExcreDuev("cow9800",feedRegime,nut);

   p_nutExcreDuev(cows,feedRegime,nut) $ ((%milkYield% ge 100) $ (not p_nutExcreDuev(cows,feedRegime,nut)))
       = p_nutExcreDuev("cowHigh",feedRegime,nut);

$endif.dh

* --- Makes sure that N and P excretion is calculated for the right herds

   p_nutExcreDueV(herds,feedRegime,nut)    $ (not p_nutExcreDueV(herds,feedRegime,nut))
      = sum(sum_herds(sumHerds,herds), p_nutExcreDueV(sumHerds,feedRegime,nut));



$iftheni.ch %cattle% == true
   p_NTANshare(cows)  = 0.6 ;
   p_NTANshare("cow7800")  = 0.6 ;
   p_NTANshare("cow9800")  = 0.6 ;
   p_NTANshare("cowhigh")  = 0.6 ;
$endif.ch


$iftheni.dh %cowherd% == true

   p_NTANshare(heifs)   = 0.6 ;
   p_NTANshare("heifs") = 0.6 ;
   p_NTANshare("mcalvsRais")  = 0.6 ;
   p_NTANshare(fcalvsRais)    = 0.6 ;

$endif.dh
$$iftheni.beef "%farmBranchBeef%"=="on"
   p_NTANshare(bulls)     = 0.6 ;
   p_NTANshare("bulls")   = 0.6 ;
  $$ifi "%buyCalvs%"=="true" p_NTANshare("mcalvsRais")  = 0.6 ;
$$endif.beef

   p_nutExcreDueV(herds,feedRegime,"NTAN")
    =  p_nutExcreDueV(herds,feedRegime,"N") * p_NTANshare(herds);

   p_nutExcreDueV(herds,feedRegime,"NORG")
    =  p_nutExcreDueV(herds,feedRegime,"N") * (1-p_NTANshare(herds));

   p_nut2ManMonth(duevHerds,feedRegime,"NTAN")   = p_nutExcreDueV(duevHerds,feedRegime,"N") *       p_NTANshare(duevHerds)  * 1/card(m) ;
   p_nut2ManMonth(duevHerds,feedRegime,"NOrg")   = p_nutExcreDueV(duevHerds,feedRegime,"N") *  (1 - p_NTANshare(duevHerds)) * 1/card(m) ;
   p_nut2ManMonth(duevHerds,feedRegime,"P")      = p_nutExcreDueV(duevHerds,feedRegime,"P")                                 * 1/card(m) ;

* --- makes sure that excretion is defined for correct elements of dairy herds

$iftheni.dh %cattle% == true
   p_nut2ManMonth(herds,feedRegime,nut2) $ (not p_nut2ManMonth(herds,feedRegime,nut2))
       = sum(sum_herds(sumHerds,herds), p_nut2ManMonth(sumHerds,feedRegime,nut2));
$endif.dh

   p_nutExcreDuev(sumHerds,feedRegime,nut)   $ (sum(sum_herds(sumHerds,herds),1) gt 1) = 0;
   p_nutExcreDuev(sumHerds,feedRegime,nut2)  $ (sum(sum_herds(sumHerds,herds),1) gt 1) = 0;
