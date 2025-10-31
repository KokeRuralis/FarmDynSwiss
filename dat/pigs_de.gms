********************************************************************************
$ontext

   CAPRI project

   GAMS file : PIGS_DE.GMS

   @purpose  :
   @author   :
   @date     : 12.03.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************
$onmulti
*
*  --- Animal losses  - KTBL "Betriebsplanung Landwirtschaft 2014/2015" p.704, p.691
*
$$iftheni.sows "%farmBranchSows%"=="on"

   p_animalLoss("piglets")  = 0.02;

*  --- Sows: KTBL "Betriebsplanung Landwirtschaft 2014/2015", p.688 - per month and sow

   p_Vcost ("sows","",t)                     = ( 264.98 / card(m));

*  --- Piglets: KTBL "Betriebsplanung Landwirtschaft 2014/2015", p.701 - per month and piglet

   p_Vcost ("piglets","",t)                  = 30.87 / card(m);

*  --- Data taken from KTBL "Betriebsplanung Landwirtschaft 2014/2015", p.672

   p_lifeTimeSow =  3;
   p_OCoeff("sows","youngPiglet","",t)         = 26.36;
   p_OCoeff("sows","oldSow","",t)              = 1/p_lifeTimeSow;
   p_OCoeff("oldSows","oldSow","",t)           = 1;

   p_OCoeff("piglets","pigletsSold","",t)      = (1 - p_animalLoss("piglets")) ;
*
   p_lu("sows","")           =     0.48 ;
   p_lu("piglets","")        =     0    ;
*
* --- Labour requirements per animal and month for sows - KTBL "Betriebsplanung Landwirtschaft 2014/2015" p. 680 & p. 696 - 3 Week Rhythm and 250 sows
*(DS 15/09/2015)
   p_herdLab("sows",feedRegime,m)           = 0.754166667;
   p_herdLab("piglets",feedRegime,m)        = 0.096584615;

   p_manQuantMonth("sows","liquidPig")          = 7 / card(m);

   table  p_nutExcreDueV(duevHerds,feedRegime,allNut) "Defintion of N and P excretion of different herds according to fertilizer directive"
*  --- N and P excretion of pigtlets is already included in values for sows, therefore no excretion from piglets

                                                     N            P

      sows.normFeed                                42.9         18.6

      piglets.normFeed                                0            0

      $$iftheni.redNP %redNPfeed% == true

      sows.redNP                                   38.4         16.7

      sows.highRedNP                               36.6         15.1

      piglets.redNP                                   0            0

      piglets.highRedNP                               0            0

      $$endif.redNP
;

$$endif.sows

$$iftheni.fattners "%farmBranchFattners%"=="on"

    p_animalLoss("fattners") = 0.023;
*
*  --- Output Coefficients for pigherds  - Considering a 115kg pig and 78% of live weight is used - Correction factor for temporal resolution
*
    p_OCoeff ("fattners","pigMeat","",t)        = (1- p_animalLoss("fattners")) * 87.9;
*
*   --- Variable costs not accounted for in set inputs such as electricity, drugs, insurances etc. - NO fodder/piglets/youngsow costs included
*

*   --- Fattners: KTBL "Betriebsplanung Landwirtschaft 2014/2015", p. 717 - 8.52333 Euro is per finished fattner, as he has 4 stages, each stage is divided by 4
*     Hence it is a monthly value

    p_Vcost("earlyfattners","",t)             = 8.52333 / 4;
    p_Vcost("midfattners","",t)               = 8.52333 / 4;
    p_Vcost("latefattners","",t)              = 8.52333 / 4;
    p_Vcost("fattners","",t)                  = 8.52333 / 4;
*
* --- Factors to calculate stocking rate and stocking density from pig herd.
*     Values taken from KTBL online calculator and FO 17,pp.40. piglets 0 because
*     value is included in sows

    p_lu("earlyfattners","")  =     0.16 ;
    p_lu("midfattners","")    =     0.16 ;
    p_lu("latefattners","")   =     0.16 ;
    p_lu("fattners","")       =     0.16 ;

*
* --- Labour requirements per animal and month for fattening farms - KTBL "Betriebsplanung Landwirtschaft 2014/2015" p. 710 - Values for Group of 40 animals per bay and 960 stable spaces
*(DS 15/09/2015)

    p_herdLab("earlyfattners",feedRegime,m)  = 0.07;
    p_herdLab("midfattners",feedRegime,m)    = 0.07;
    p_herdLab("latefattners",feedRegime,m)   = 0.07;
    p_herdLab("fattners",feedRegime,m)       = 0.0466667;

*
* --- Manure excretion values of volumes according to German Fertilizer Ordinance (DueV, Annex 9) in qm per month
*

* --- piglets do not have own value because excretion is included excretion of sows

   p_manQuantMonth("earlyfattners","liquidPig") = 1500 / ( card(m) * 1000);
   p_manQuantMonth("midfattners","liquidPig")   = 1500 / ( card(m) * 1000);
   p_manQuantMonth("latefattners","liquidPig")  = 1500 / ( card(m) * 1000);
   p_manQuantMonth("fattners","liquidPig")      = 1500 / ( card(m) * 1000);

table  p_nutExcreDueV(duevHerds,feedRegime,allNut) "Defintion of N and P excretion of different herds according to fertilizer directive"
* --- N and P excretion of pigtlets is already included in values for sows, therefore no excretion from piglets

                                                  N            P

   earlyfattners.normFeed                       12.2          5.0

   midfattners.normFeed                         12.2          5.0

   latefattners.normFeed                        12.2          5.0

   fattners.normFeed                            12.2          5.0

   $$iftheni.redNP %redNPfeed% == true

   earlyfattners.redNP                          11.7          4.4

   earlyfattners.highRedNP                      10.6          3.9

   midfattners.redNP                            11.7          4.4

   midfattners.highRedNP                        10.6          3.9

   latefattners.redNP                           11.7          4.4

   latefattners.highRedNP                       10.6          3.9

   fattners.redNP                               11.7          4.4

   fattners.highRedNP                           10.6          3.9

   $$endif.redNP
   ;
$$endif.fattners

* --- Makes sure that N and P excretion is calculated for the right herds

   p_nutExcreDueV(herds,feedRegime,nut)    $ (not p_nutExcreDueV(herds,feedRegime,nut))
      = sum(sum_herds(sumHerds,herds), p_nutExcreDueV(sumHerds,feedRegime,nut));

$iftheni.sows "%farmBranchSows%"    == "on"

   p_NTANshare("sows")          = 0.7;
   p_NTANshare("piglets")       = 0.7;

$endif.sows

$iftheni.fat "%farmBranchfattners%" == "on"

   p_NTANshare("fattners")      = 0.7;
   p_NTANshare("latefattners")  = 0.7;
   p_NTANshare("midfattners")   = 0.7;
   p_NTANshare("earlyfattners") = 0.7;

$endif.fat

*
*  --- split up total N in NTAN (NH3/ NH4) and part bound in organic matter (slowly relased)
*
   p_nutExcreDueV(herds,feedRegime,"NTAN")  =  p_nutExcreDueV(herds,feedRegime,"N") * p_NTANshare(herds);
   p_nutExcreDueV(herds,feedRegime,"NORG")  =  p_nutExcreDueV(herds,feedRegime,"N") * (1-p_NTANshare(herds));
*
*  --- convert in monthly ?
*
   p_nut2ManMonth(duevHerds,feedRegime,"NTAN")   = p_nutExcreDueV(duevHerds,feedRegime,"N") *       p_NTANshare(duevHerds)  * 1/card(m) ;
   p_nut2ManMonth(duevHerds,feedRegime,"NOrg")   = p_nutExcreDueV(duevHerds,feedRegime,"N") *  (1 - p_NTANshare(duevHerds)) * 1/card(m) ;
   p_nut2ManMonth(duevHerds,feedRegime,"P")      = p_nutExcreDueV(duevHerds,feedRegime,"P")                                 * 1/card(m) ;

   p_nutExcreDuev(sumHerds,feedRegime,nut)  $ (sum(sum_herds(sumHerds,herds),1) gt 1) = 0;
$offmulti
