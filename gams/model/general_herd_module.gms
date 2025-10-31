********************************************************************************
$ontext

   FARMDYN project

   GAMS file : GENERAL_HERD_MODULE.GMS

   @purpose  : Equations which are active if a herd is in the model
               (cattle, pigs), but are not specific to cattle or pigs

   @author   : Wolfgang Britz, building on revision 472
   @date     : 11.12.14
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************

     Parameter
        p_prodLengthB(herds,breeds)                        "Production length of animal processes in month in balancing equation"
        p_lu(herds,breeds)                                 "Livestock units"
        p_herdYearScaler(herds,breeds)                     "Normally 1, in comp static mode equal number of years of the production process"
        p_nut2ManMonth(duevHerds,feedregime,nut2)          "Norg,NTAN and P excreted by different herds"
        p_lifeTimeS(stables,hor)                           "Physical lifetime of stables, depending on part"
        p_stableNeed(sumHerds,breeds,stableTypes)          "Which type of stable is need by the different herds"
        p_nutShare(manChain,stableStyles,*)                "Share of solid/light liquid manure"
        p_maxStockRate                                     "Maximum stocking rate"
     ;

     Positive variable
      v_sumherd(sumHerds,breeds,t,n)                       "Average herd each year"
      v_herdSize(herds,breeds,feedRegime,t,n,m)            "Size of different herds"
      v_herdStart(herds,breeds,t,n,m)                      "Starting point of different herds"
      v_herdStartBornCalvsRais(herds,breeds,t,n,m)         "Starting point of different herds"
      v_stableNeed(stableTypes,t,n)                        "Stable place need (max over months)"
      v_stableUsed(stables,t,n)                            "Stable inventory used in year t"
      v_stableNotUsed(stables,t,n,m)                       "Stable inventory used in year t"
      v_machNeedHerds(machType,machLifeUnit,t,n)           "Machine need in operating hours/ha/m3"
      v_SubManStorCap(manChain,t,n)                        "Total manure capacity subfloor of all stables"

      v_manQuant(manChain,t,n)                             "Fluid manure quantity in m3 per year"
      v_manQuantM(manChain,t,n,m)                          "Fluid manure quantity in m3 per month"
      v_nut2manureM(manChain,nut2,t,n,m)                   "NTAN,NORG and P exretion of herd in stable per month"
      v_nut2manureT(nut2,t,n)                              "NTAN,NORG and P exretion, yearly stable and pasture"
      v_nut2manureHerds(herds,breeds,manChain,nut2,t,n,m)  "NTAN,NORG and P exretion in stable per month and herd"
      v_sumGV(t,n)                                         "stocking rate to calculate stocking density"
      v_stableInv(stables,hor,t,n)                         "Stable inventory in year t"
      v_buyStablesF(stables,hor,t,n)                       "Investments in new stables in year t,n, by lifetime of stable part, share"

$ifi %MIP%==on   binary variables
      v_buyStables(stables,hor,t,n)                        "Choice of investments in new stables in year t,n, by lifetime of stable part"
      v_minInvStables(stableTypes,hor,t,n)                     "Minimum cost of investments in stables"
    ;

   Equations
      sumHerds_(sumHerds,breeds,feedRegime,t,n,m)          "Summary herd definition, per year and month"
      sumHerdsY_(sumHerds,breeds,t,n)                      "Summary herd definition, per year"
      herdSize_(herds,breeds,t,n,m)                        "Definition of standing herd"
      herdsBal_(balHerds,breeds,t,n,m)                     "Balance for raising/fattening processes"
      luland_(t,n)                                         "Max stocking density restriction"
      machNeedHerds_(machType,machLifeUnit,t,n)            "Machinery hours by herds"
      stableNeed_(stableTypes,t,n,m)                       "Stable place need (max over months)"
      stableNeed1_(stableTypes,t,n)                        "Stable place need (max over months)"
      stables_(stableTypes,t,n,m)                          "Stable place restriction"
      stableUsed_(stables,hor,t,n,m)                       "Stable used part definition"
      stableInvOrder_(stables,hor,t,n)                     "Make sure that partly replacements are only done after fill investments"
      minInvStables_(stableTypes,hor,t,n)
      machInvStable_(machType,stables,t,n)                 "Certain machiney are needed for a certain stable type"
      stableBuy_(stables,hor,t,n)                          "Stables can only be bought if there is a farm"
      stableInv_(stables,hor,t,n)                          "Stables inventory definition"

      stableConcaveComb_(stables,hor,t,n)                  "Select two points on concave set next to each other"
      stableBin_(stables,hor,t,n)                          "Select share choice to the chosen points"
      stableConvexComb_(stableTypes,hor,t,n)                "Shares must add up to unity"

      convStables_(stableTypes,hor,t,n)                    "Only one type of stable per type (cow, calves, young cattle) allowed"
      sumStrawBought_(inputs,t,n)                          "Sums the straw requirement for the stables used"

      manQuant_(manChain,t,n)                              "Definition of manure quantity in m3 per year"
      manQuantM_(manChain,t,n,m)                           "Definition of manure quantity in m3 per month"
      SubManStorCap_(manChain,t,n)                         "Manure storage capacity of stables subfloor in m^3"

      machBuyStable_(machType,t,n)                         "Certain machiney are needed for a certain stable type"
      ManureRemove_(t,n,m)                                 "Storage amount has to be below xy% of storage capacity one month a year"

      nut2manureM_(manChain,nut2,t,n,m)                    "NTAN,NORG and P exretion of  herd per month"
      nut2manureT_(nut2,t,n)                                "NTAN,NORG and P exretion, yearly stable and pasture"
      nut2ManureHerds_(herds,breeds,manChain,nut2,t,n,m)   "NTAN,NORG and P exretion per  herd and month"
      manTest_(manChain,nut2,t,n,m)
      nut2manure_(manChain,nut2,t,n)
      sumGV_(t,n)                                          "Calculation of total GV numbers on farm"
    ;

   sumHerdsY_(sumHerds,breeds,t_n(tCur(t),nCur)) $ ((    sameas(sumHerds,"cows")
                                            or sameas(sumHerds,"sows")
                          $$ifi defined fatHerd or sum(sameas(fatHerd,sumherds),1)
                                            or sameas(sumHerds,"pigFattened")
                                            or sameas(sumHerds,"heifs")
                                            or sameas(sumherds,"motherCow")
                                            or sameas(sumherds,"fCalvsRais")
                                            or sameas(sumherds,"MCalvsRais")
                                            or sameas(sumherds,"bulls"))
                                       $  sum( (feedRegime,m) $ actHerds(sumHerds,breeds,feedRegime,t,m),1)) ..

       v_sumherd(sumHerds,breeds,t,%nCur%) * card(m)
          =e= sum((feedRegime,m) $ actHerds(sumHerds,breeds,feedRegime,t,m),
                               v_herdSize(sumHerds,breeds,feedRegime,t,nCur,m));
*
*   --- definition of summary herds (cows, heifs, female calves, fattened pig)
*       which enter e.g. labour need equations (or for information)
*
    sumHerds_(sumHerds,breeds,feedRegime,t,nCur,m) $ (t_n(t,nCur)  $(tCur(t) or tBefore(t))
                       $  sum(sum_herds(sumHerds,possHerds) $ actHerds(possHerds,breeds,feedRegime,t,m),1)) ..

       v_herdSize(sumHerds,breeds,feedRegime,t,nCur,m)
          =e= sum(sum_herds(sumHerds,possHerds) $ actHerds(possHerds,breeds,feedRegime,t,m) ,
                 v_herdSize(possHerds,breeds,feedRegime,t,nCur,m) $ (p_prodLength(possHerds,breeds) gt 1)
              +  v_herdStart(possHerds,breeds,t,%nCur%,m)           $ (p_prodLength(possHerds,breeds) eq 1));
*
*   --- definition of standing herds
*
herdSize_(herds,breeds,tCur(t),nCur,m)
    $ (sum(FeedRegime,actHerds(herds,breeds,feedRegime,t,m))
    $  sum((t_n(t1,nCur1),feedRegime,m1)
            $ (((-p_mDist(t,m,t1,m1) le (p_prodLength(herds,breeds)-1) $ (p_mDist(t,m,t1,m1) le 0))
               or
               ((abs(p_mDist(t,m,t1,m1)-12) le (p_prodLength(herds,breeds)-1)) $ (p_mDist(t,m,t1,m1)-12 le 0)) $ p_compStatHerd
               )
              $ actHerds(herds,breeds,feedRegime,t1,m1)
              $ (balherds(herds)
              $$ifi defined remonte or remonte(herds) or sameas("remonte",herds)
              )
              $ t_n(t,nCur) $ isNodeBefore(nCur,nCur1)),
        1)
     ) ..

  sum(feedRegime $ actHerds(herds,breeds,feedRegime,t,m),
    v_herdSize(herds,breeds,feedRegime,t,nCur,m))
  =E=
*
*         --- herds which started in the months before the production length, in case for piglets a separate construct is used
*
  sum((t_n(t1,nCur1),m1)
    $ ((((-p_mDist(t,m,t1,m1) le (p_prodLength(herds,breeds)-1))
        $ (p_mDist(t,m,t1,m1) le 0))
        or
        ((abs(p_mDist(t,m,t1,m1)-12) le (p_prodLength(herds,breeds)-1))
        $ (p_mDist(t,m,t1,m1)-12 le 0)) $ p_compStatHerd
       )
       $ sum(feedRegime,actHerds(herds,breeds,feedRegime,t1,m1))
       $ isNodeBefore(nCur,nCur1)
       $$iftheni.sows "%farmBranchSows%" == "on"
         $(not sameas(herds,"piglets"))
       $$endif.sows
     ),
      v_herdStart(herds,breeds,t1,%nCur1%,m1)

      $$iftheni.ch %cowHerd%==true
*
*       --- minus, in case of cows, slaughtered before reaching the final age
*
        -sum( (slgtCows,cows)
          $ (sum(feedRegime, actHerds(slgtCows,breeds,feedRegime,t1,m1))
            $ sameas(cows,herds) $ (slgtCows.pos eq cows.pos)),
          v_herdStart(slgtCows,breeds,t1,%nCur%,m1))
      $$endif.ch
    )
*
*  --- add herds multiple times if their process length is longer than 12
*

  +  sum((t_n(t1,nCur1),m1)
      $ (((-p_mDist(t,m,t1,m1) le (p_prodLength(herds,breeds)-1))
          $
          (   (abs(p_mDist(t,m,t1,m1)-12) le (p_prodLength(herds,breeds)-1))$ (p_mDist(t,m,t1,m1) le 0)
          or  (abs(p_mDist(t,m,t1,m1)-24) le (p_prodLength(herds,breeds)-1))$ (p_mDist(t,m,t1,m1) ge 0)
          ) $ p_compStatHerd $
                                  $$ifi defined cows (not cows(herds) $ (p_prodLength(herds,breeds) gt 12))
                                  $$ifi not defined cows (1 eq 1)
         )
         $ sum(feedRegime,actHerds(herds,breeds,feedRegime,t1,m1))
         $ isNodeBefore(nCur,nCur1)
         $$iftheni.sows "%farmBranchSows%" == "on"
           $(not sameas(herds,"piglets"))
         $$endif.sows
      ),
         v_herdStart(herds,breeds,t1,%nCur1%,m1)
*
*       --- minus, in case of cows, slaughtered before reaching the final age
*
      $$iftheni.ch %cowHerd%==true
        -sum( (slgtCows,cows)
          $ (sum(feedRegime, actHerds(slgtCows,breeds,feedRegime,t1,m1))
            $ sameas(cows,herds) $ (slgtCows.pos eq cows.pos)),
          v_herdStart(slgtCows,breeds,t1,%nCur%,m1))
      $$endif.ch
         )
*
*         --- Herd size dynamic for piglets separately to depict a correct transfer from year t to year t1 as well as account for temporal resolution adjustments
*

  $$iftheni.sows "%farmBranchSows%" == "on"
    +  sum( (t_n(t1,nCur1),m1)
      $ ((abs(p_mDist(t,m,t1,m1)) le (p_prodLengthB(herds,breeds) -1
        $ (p_prodLengthB(herds,breeds) eq 1)))
      $ (p_mDist(t,m,t1,m1) le 0)
      $ isNodeBefore(nCur,nCur1)
      $ sum(feedRegime,actHerds(herds,breeds,feedRegime,t1,m1))
      $ (sameas(herds,"youngPiglets") or sameas(herds,"piglets"))
      $ {
        (sameas(t,t1) $ (not sameas(m  - p_prodLengthB(herds,breeds),m1)))
        or ((not sameas(t,t1)) $ (sameas("Jan",m))$ (sameas( m + 11, m1)))
      }
      ),
         v_herdStart(herds,"",t1,%nCur%1,m1))
  $$endif.sows
;

*
*   --- general balance definition
*
    herdsBal_(balHerds,breeds,tCur(t),nCur,m) $ (  sum(feedRegime,actherds(balHerds,breeds,feedRegime,t,m)) $ t_n(t,nCur)
*
     $ (p_Year(t) le p_year("%lastYear%"))
     $ (sum( (herds_from_herds(balHerds,herds,breeds),t1,m1)
                   $ (( -p_mDist(t,m,t1,m1) eq round(p_prodLengthB(herds,breeds)))
                           $  sum(feedRegime,actHerds(herds,breeds,feedRegime,t1,m1))),1)
       $$iftheni.compStat "%dynamics%" == "comparative-static"
         or (sum( (herds_from_herds(balHerds,herds,breeds),t1,m1)
                   $ (( -p_mDist(t,m,t1,m1)+12 eq round(p_prodLengthB(herds,breeds)))
                           $  sum(feedRegime,actHerds(herds,breeds,feedRegime,t1,m1))),1))
       $$endif.compStat
                           or sum((bought_to_herds(herds,breeds,balherds),feedRegime) $ actherds(herds,breeds,feedRegime,t,m),1)
                           or sum((sold_comp_herds(herds,breeds,balherds),feedRegime) $ actherds(herds,breeds,feedRegime,t,m),1)  )
                        ) ..
*
*      --- herd starting at current time point
*
          v_herdStart(balHerds,breeds,t,%nCur%,m)/p_herdYearScaler(balHerds,breeds)
*
*      --- plus herd starting at current time point which compete for the same input herds
*
     + sum( herds1 $ [ (sum(herds_from_herds(herds1,herds,breeds)
                                      $ herds_from_herds(balHerds,herds,breeds),1)
                    or sum(bought_to_herds(herds,breeds,herds1)
                            $ bought_to_herds(herds,breeds,balherds),1))
                    $ (not sameas(balHerds,herds1)) $  sum(feedRegime,actherds(herds1,breeds,feedRegime,t,m))],
          v_herdStart(herds1,breeds,t,%nCur%,m)/p_herdYearScaler(herds1,breeds))

         =e=
*
*      --- equal to the starting herd of the process wich generates these herds
*
     + sum( (herds_from_herds(balHerds,herds,breeds),t_n(t1,nCur1),m1)
                   $ ( (  (-p_mDist(t,m,t1,m1)    eq round(p_prodLengthB(herds,breeds)) )
                $$iftheni.compStat "%dynamics%" == "comparative-static"
                     or (-p_mDist(t,m,t1,m1)+12 eq round(p_prodLengthB(herds,breeds)) )
                $$endif.compStat
                       )   $  sum(feedRegime,actHerds(herds,breeds,feedRegime,t1,m1)) $ isNodeBefore(nCur,nCur1)),
                                    v_herdStart(herds,breeds,t1,%nCur1%,m1))
*
*      --- bought to herd (e.g. heifers bought from market)
*
     + sum( (bought_to_herds(herds,breeds,balherds))
           $ sum(feedRegime,actherds(herds,breeds,feedRegime,t,m)), v_herdStart(herds,breeds,t,nCur,m))
*
*      --- sold animals from the competing process for these herds (e.g. using heifer for remonte or selling heifer)
*
     - sum( sold_comp_herds(herds,breeds,balherds) $ sum(feedRegime,actherds(herds,breeds,feedRegime,t,m)),
            v_herdStart(herds,breeds,t,%nCur%,m));

*   --- machinery needs of herds
*
    machNeedHerds_(curMachines(machType),machLifeUnit,t_n(tCur(t),nCur))
        $ sum(actHerds(sumHerds,breeds,feedRegime,t,m),
               p_machNeed(sumHerds,"plough","normal",machType,machLifeUnit)) ..

       v_machNeedHerds(machType,machLifeUnit,t,nCur)

         =e=
*
*      --- herd sizes times their request for specific machine type
*
          sum(actHerds(sumHerds,breeds,feedRegime,t,m) $ p_prodLength(sumHerds,breeds),
             v_herdSize(sumHerds,breeds,feedRegime,t,nCur,m)
              * p_machNeed(sumHerds,"plough","normal",machType,machLifeUnit)
                          * 1/min(12,p_prodLength(sumHerds,breeds)));
*
*   --- stable places
*
    stableNeed1_(stableTypes,t_n(tCur(t),nCur))
          $ (   sum(actHerds(sumHerds,breeds,feedRegime,t,m) $ ((not sameas(feedRegime,"fullGraz"))
                  $ v_herdSize.up(sumHerds,breeds,feedRegime,t,nCur,m)), p_stableNeed(sumHerds,breeds,stableTypes))
*             --- this is needed for the non-farm case if the stables are fixed
              $ sum(branches,v_hasBranch.up(branches,t,nCur))
              $ (v_hasFarm.up(tCur,nCur) ne 0))  ..
*
*      --- herd sizes times their request for specific stable "types" (cow, calves, young cattle)
*
       sum(actHerds(sumHerds,breeds,feedRegime,t,m) $ (not sameas(feedRegime,"fullGraz")),
             v_herdSize(sumHerds,breeds,feedRegime,t,nCur,m)
                      * p_stableNeed(sumHerds,breeds,stableTypes))
                 =G=
*
*         --- must be covered by current stable inventory (not fully depreciated building),
*             mutiplied with the stable places they offer
*
           sum(stables,v_stableInv(stables,"long",t,nCur) * p_stableSize(stables,stableTypes));


    stableNeed_(stableTypes,tCur(t),nCur,m)
          $ (sum(actHerds(sumHerds,breeds,feedRegime,t,m) $ ((not sameas(feedRegime,"fullGraz"))
                  $ v_herdSize.up(sumHerds,breeds,feedRegime,t,nCur,m)), p_stableNeed(sumHerds,breeds,stableTypes))
                  $ t_n(t,nCur) $ sum(branches,v_hasBranch.up(branches,t,nCur))
                  $ (v_hasFarm.up(tCur,nCur) ne 0))  ..
*
*      --- herd sizes times their request for specific stable "types" (cow, calves, young cattle)
*
       sum(actHerds(sumHerds,breeds,feedRegime,t,m) $ (not sameas(feedRegime,"fullGraz")),
             v_herdSize(sumHerds,breeds,feedRegime,t,nCur,m)
                      * p_stableNeed(sumHerds,breeds,stableTypes))
*
*    --- not used stable places
*
     + sum(stables $ (  (  sum( (t_n(t1,nCur1),hor) $ ((isNodeBefore(nCur,nCur1) or sameas(nCur,nCur1))  and (p_year(t1) le p_year(t))),
                               (v_buyStables.up(stables,hor,t1,nCur1) ne 0))
                       or sum( (tOld,hor), p_iniStables(stables,hor,tOld))) $ (p_stableLab(stables,m) gt eps)),
           v_stableNotUsed(stables,t,nCur,m) * (p_stableSize(stables,stableTypes) $ (p_stableSize(stables,stableTypes) gt eps))
                                                 $  p_stableSize(stables,stableTypes))

                       =E= v_stableNeed(stableTypes,t,nCur);
*
*   --- stable places
*
    stables_(stableTypes,tCur(t),nCur,m)
          $ (sum(actHerds(sumHerds,breeds,feedRegime,t,m) $ ((not sameas(feedRegime,"fullGraz"))
                  $ v_herdSize.up(sumHerds,breeds,feedRegime,t,nCur,m)), p_stableNeed(sumHerds,breeds,stableTypes))
                  $ t_n(t,nCur) )  ..
*
       v_stableNeed(stableTypes,t,nCur)

          =L=
*
*         --- must be covered by current stable inventory (not fully depreciated building),
*             mutiplied with the stable places they offer
*
       sum(stables $ (    sum( (t_n(t1,nCur1),hor) $ ((isNodeBefore(nCur,nCur1) or sameas(nCur,nCur1)) and (p_year(t1) le p_year(t))),
                               (v_buyStables.up(stables,hor,t1,nCur1) ne 0))
                       or sum( (tOld,hor), p_iniStables(stables,hor,tOld))),
           v_stableUsed(stables,t,nCur) * p_stableSize(stables,stableTypes));

*
*   --- long lasting parts of building at least as large as parts with lower lifetime
*        (help branching algorithm)
*
    stableInvOrder_(stables,hor,t_n(tFull(t),nCur)) $ ( (ord(hor) ne card(hor))
            $  sum(stableTypes $ (p_stableSize(stables,stableTypes) gt eps),1)
            $  (v_buyStables.up(stables,hor,t,nCur) ne 0)) ..

       v_stableInv(stables,hor,t,nCur) =L= v_stableInv(stables,hor+1,t,nCur);
*
*   --- minInvStables
*
    minInvStables_(stableTypes,hor,t_n(tFull(t),nCur)) $ p_minInvStableCost(stableTypes,hor,t) ..

       v_minInvStables(stableTypes,hor,t,%nCur%)

           =G= sum(stables $ (p_stableSize(stables,stableTypes) gt eps), v_buyStablesF(stables,hor,t,nCur));
*
*   --- The actual stable inventory must be larger than the part used
*
    stableUsed_(stables,hor,tFull(t),nCur,m)
       $ ( (p_priceStables(stables,hor,t) gt eps)
           $  (       sum( (t_n(t1,nCur1),hor1) $ ((isNodeBefore(nCur,nCur1) or sameas(nCur,nCur1)) and (p_year(t1) le p_year(t))),
                               (v_buyStables.up(stables,hor1,t1,nCur1) ne 0))
                or  sum( (tOld,hor1), p_iniStables(stables,hor1,tOld)))
                     $ (sum(stableTypes,p_stableSize(stables,StableTypes)) gt eps) $  t_n(t,nCur)) ..

       v_stableInv(stables,hor,t,nCur) =G= [v_stableUsed(stables,t,nCur) + v_stableNotUsed(stables,t,nCur,m)] $ tCur(t)

                                         + [   sum( (t1,nCur1) $ ( isNodeBefore(nCur,nCur1) $ sameas(t1,"%lastYear%") $ t_n(t1,nCur1) $ (not sameas(t,t1))),
                                                                    v_stableUsed(stables,t1,nCur1)+ v_stableNotUsed(stables,t1,nCur1,m))
                                           ]  $ ( (not tCur(t)) and p_prolongCalc);
*
*   --- stable inventory, binary (depreciation over time)
*
    stableInv_(stables,hor,tFull(t),nCur)
       $ (   (p_priceStables(stables,hor,t) gt eps)
               $ (      sum( (t_n(t1,nCur1),hor1) $ ((isNodeBefore(nCur,nCur1) or sameas(nCur,nCur1)) and (p_year(t1) le p_year(t))),
                         (v_buyStables.up(stables,hor1,t1,nCur1) ne 0))
                    or  sum( tOld, p_iniStables(stables,hor,tOld)))
                     $ (sum(stableTypes,p_stableSize(stables,StableTypes)) gt eps)
                     $ t_n(t,nCur) ) ..

       v_stableInv(stables,hor,t,nCur)

          =L=
*
*         --- old stables according to building date and lifetime
*             (will drop out of equation if too old)
*
          sum( tOld $ (   ((p_year(tOld) + p_lifeTimeS(stables,hor)) gt p_year(t))
                              $ ( p_year(told)                       le p_year(t))),
                           p_iniStables(stables,hor,tOld))

*
*         --- plus (old) investments - de-investments
*
       +  sum( t_n(t1,nCur1) $ ( isNodeBefore(nCur,nCur1)
                                   $  (   ((p_year(t1)  + p_lifeTimeS(stables,hor) ) gt p_year(t))
                                   $ (      p_year(t1)                               le p_year(t)))),
                                                    v_buyStablesF(stables,hor,t1,nCur1));
*
*   --- concave combinations: select two points next to eacher other on concave set
*                             realized by excluding not neighbouring sizes
*
    stableConcaveComb_(stables,hor,t_n(tCur,nCur)) $ sum(stableTypes_to_stables(stableTypes,stables)
                                                            $ (v_buyStables.up(stables,hor,tCur,nCur) ne 0),1) ..
        sum(stableTypes_to_stables(stableTypes,Stables1) $ (stableTypes_to_stables(stableTypes,stables)
               $ (abs(stables.pos - stables1.pos) gt 1)), v_buyStables(stables1,hor,tCur,%nCur%))
           =L= (1 - v_buyStables(stables,hor,tCur,%nCur%))*2;

*
*   --- restrict choice for convex combination to the two points implicitly defined above
*
    stableBin_(stables,hor,t_n(tFull,nCur)) $ ((v_buyStablesF.up(stables,hor,tFull,nCur) ne 0) $ (v_hasFarm.up(tFull,nCur) ne 0)) ..

         v_buyStablesF(stables,hor,tFull,nCur) =L= v_buyStables(stables,hor,tFull,%nCur%);
*
*   --- only two types of stables can be bought for each type of herd,
*       in between two points of the concave curve
*
    stableConvexComb_(stableTypes,hor,t_n(tFull,nCur)) $ sum(stableTypes_to_stables(stableTypes,stables)
                                                          $ (v_buyStables.up(stables,hor,tFull,nCur) ne 0),1) ..

         sum(stableTypes_to_stables(stableTypes,stables) $ (v_buyStables.up(stables,hor,tFull,nCur) ne 0),
                                                                  v_buyStablesF(stables,hor,tFull,nCur)) =E= 1;

*   --- binary restriction (migh help solver): don t buy stable if the farm has no herd
*
    stableBuy_(stables,hor,t_n(tFull(t),nCur)) $ (v_buyStables.up(stables,hor,t,nCur) gt 0) ..

       v_buyStables(stables,hor,t,%nCur%) =L= sum(stableTypes_to_branches(stableTypes,branches)
                                              $ p_stableSize(stables,stableTypes), v_HasBranch(branches,t,%nCur%));
*
*   --- binary restriction (migh help solver): don t keep stables in use if the farm has no herd
*
*
*   --- stables come in defined size, only one of one type (milkcow, youngCattle,calves)
*       can be bought per year

    convStables_(stableTypes,hor,t_n(tFull(t),nCur))

     $ (sum(stables $ (p_stableSize(stables,StableTypes) $ (v_buyStables.up(stables,hor,t,nCur) gt 0)),1)) ..

        sum(stables $ p_stableSize(stables,StableTypes), v_buyStables(stables,hor,t,%nCur%)) =E= 2;
*
*   --- manure excreted in stable in m3, each month
*
    manQuantM_(curManChain(manChain),t_n(tCur,nCur),m) $ (not sameas(curManChain,"LiquidBiogas")) ..

        v_manQuantM(manChain,tCur,nCur,m)

          =e=
               sum( actherds(possHerds,breeds,feedRegime,tCur,m) $ (manChain_herd(curManChain,possHerds) $ p_prodLength(possherds,breeds)),
                   p_manQuantMonth(possHerds,curManChain) * ( 1 - 1   $ sameas(feedRegime,"fullGraz")
                                                                - 0.5 $ sameas(feedRegime,"partGraz"))
                    * v_herdSize(possHerds,breeds,feedRegime,tCur,nCur,m));
*
*    --- definition of manure excreted in stable in m3 in whole year
*
     manQuant_(curManChain(manChain),t_n(tCur,nCur)) $ (not sameas(curManChain,"LiquidBiogas"))  ..

             v_manQuant(manChain,tCur,nCur) =e= sum(m, v_manQuantM(manChain,tCur,nCur,m))   ;
*
*   --- Storage capacity for manure subfloor in stable systems
*
    subManStorCap_(curManChain(manChain),tCur(t),nCur) $(t_n(t,nCur)$(not sameas(curManChain,"LiquidBiogas"))) ..

       v_SubManStorCap(manChain,t,nCur) =e=
       sum(stables $ (     [ sum( (t_n(t1,nCur1),hor) $ ( (isNodeBefore(nCur,nCur1) or sameas(nCur,nCur1)) and (p_year(t1) le p_year(t))),
                                                             (v_buyStables.up(stables,hor,t1,nCur1) ne 0))
                                                    or (sum( (tOld,hor), p_iniStables(stables,hor,tOld)))
                                                   ]  $ (p_ManStorCap(manChain,stables) gt eps)
                                                    ),

                                             v_StableInv(stables,"long",t,nCur)*p_ManStorCap(manChain,stables));
*
* --- Calculation of NTan, NOrg and P excreted per herd (same as above, used for environmental accounting)
*
    nut2ManureHerds_(possherds,breeds,curManChain(manChain),nut2,t_n(tCur,nCur),m)
        $ (   (not sameas(curManChain,"LiquidBiogas"))
            $ sum(feedRegime,actherds(possherds,breeds,feedregime,tCur,m))
            $ manChain_herd(curManChain,possHerds)) ..

      v_nut2ManureHerds(possherds,breeds,manChain,nut2,tCur,nCur,m) =e=
            sum((feedRegime)
               $ ( (not sameas(feedRegime,"fullGraz"))
               $ manChain_herd(curManChain,possHerds)
               $ actherds(possherds,breeds,feedregime,tCur,m)
               $ p_prodLength(possherds,breeds)),
                     p_nut2ManMonth(possHerds,feedRegime,nut2)
                          * ( 1 - 1   $ sameas(feedRegime,"fullGraz")
                                - 0.5 $ sameas(feedRegime,"partGraz"))
                      * sum(herd_stableStyle(possHerds,stableStyles), p_nutShare(manChain,stableStyles,nut2))
                          * v_herdSize(possHerds,breeds,feedRegime,tCur,nCur,m))
      ;

*
* --- total excreted nutrient (stable and pasture), without any lossws
*
  nut2ManureT_(nut2,t_n(tCur,nCur)) ..

     v_nut2ManureT(nut2,tCur,nCur) =E=

        sum( actHerds(possherds,breeds,feedRegime,tCur,m),
             p_nut2ManMonth(possHerds,feedRegime,nut2)*v_herdSize(possHerds,breeds,feedRegime,tCur,nCur,m));

*
* --- Calculation of NTan, NOrg and P excreted by herd
*
  nut2ManureM_(curManChain(manChain),nut2,t_n(tCur,nCur),m) $ (not sameas(curManChain,"LiquidBiogas")) ..

    v_nut2ManureM(manChain,nut2,tCur,nCur,m)

       =e= sum((possherds,breeds) $ (manChain_herd(curManChain,possHerds)
                                  $ sum(feedRegime,actherds(possherds,breeds,feedregime,tCur,m))),
                                          v_nut2ManureHerds(possherds,breeds,manChain,nut2,tCur,nCur,m));
*
* --- Calculation of stocking rate for later calculatioin of stocking density (needed for FO 17 requirements)
*
  sumGV_(t_n(tCur,nCur)) ..

     v_sumGV(tCur,nCur) =e=

                   sum(actHerds(possherds,breeds,feedRegime,tCur,m) $ p_prodLength(possherds,breeds),
                          v_herdSize(possherds,breeds,feedRegime,tCur,nCur,m) * p_lu(possherds,breeds)) * 1/card(m);
*
* --- Maximum stocking rate allowed
*       (ensures that a certain ammount of land is present)
*
  luLand_(t_n(tCur(t),nCur)) ..

       sum( plot $ p_plotSize(plot), v_totPlotLand(plot,t,nCur)

$ifi %landLease% == true            -v_rentOutPlot(plot,t,nCur) * p_plotSize(plot)

           ) * p_maxStockRate  =G=  v_sumGV(t,nCur);
*
*   --- specific machinery (front loader, shear grab, dung grab ... are linked to stables)
*
    machInvStable_(curMachines(machType),stables,tCur(t),nCur)
       $ ( (v_machInv.up(machType,"years",t,nCur) ne 0)
           $  (   sum( (t_n(t1,nCur1),hor) $ ( (isNodeBefore(nCur,nCur1) or sameas(nCur,nCur1)) and (p_year(t1) le p_year(t))),
                      (v_buyStables.up(stables,hor,t1,nCur1) ne 0))
              or  sum( tOld, p_iniStables(stables,"long",tOld)))
           $ sum(stables_to_mach(stables,machType),1)
           $ (p_lifeTimeM(machType,"years"))  $ p_priceMach(machType,t)  $ t_n(t,nCur))  ..

       sum(stables_to_mach(stables,machType), v_stableUsed(stables,t,nCur)
           -sum(m $ (p_stableLab(stables,m) gt eps),v_stableNotUsed(stables,t,nCur,m))/card(m))
          =L= v_machInv(machType,"years",t,nCur);

*
*   --- helper equation: attention requires that machinery is not linked to other type of stables ...
*
    machBuyStable_(curMachines(machType),tCur(t),nCur) $ ( (v_machInv.up(machType,"years",t,nCur) ne 0)
             $  sum(stables_to_mach(stables,machType)
                      $  (   sum( t_n(t1,nCur1) $ ( (isNodeBefore(nCur,nCur1) or sameas(nCur,nCur1)) and (p_year(t1) le p_year(t))),
                                 (v_buyStables.up(stables,"long",t1,nCur1) ne 0))
                         or  sum( tOld, p_iniStables(stables,"long",tOld)))
                       ,1)

             $ (p_lifeTimeM(machType,"years"))  $ p_priceMach(machType,t) $ t_n(t,nCur))  ..

       sum(stables_to_mach(stables,machType), v_stableInv(stables,"long",t,nCur))*10
          =G= v_buyMach(machType,t,%nCur%);

    model m_herd /
                  luland_
                  stableNeed_
                  stableNeed1_
                  stables_
                  stableInv_
                  stableBin_
                  stableConvexComb_
                  $$ifi not "%useSOS2%"=="true" stableConcaveComb_
                  stableInvOrder_
                  minInvStables_
                  machInvStable_
                  machBuyStable_
                  stableUsed_
                  convStables_
                  herdsBal_
                  herdSize_
                  sumHerds_
                  sumHerdsY_
                  machNeedHerds_
                  SubManStorCap_
                  manQuant_
                  manQuantM_
                  nut2manureT_
                  nut2manureM_
                  nut2ManureHerds_
                  sumGV_
*
*                 --- equations linked to v_hasHerd trigger
*
*             stableBuy_
   /;
