********************************************************************************
$ontext

   FARMDYN project

   GAMS file : MODULE_DAIRY.GMS

   @purpose  : Variables / Equations only used if cattle module is switched on
   @author   : W.Britz, using existing code from rev. 473
   @date     : 10.12.14
   @since    :
   @refDoc   :
   @seeAlso  : coeffgen/requ.gms
   @calledBy : model/templ.gms

$offtext
********************************************************************************


  set phase "lactation phase / dry / general / months in year" /
      LC30_1,LC92_1,LC213_1,LC305_1,dry_1,
      LC30_2,LC92_2,LC213_2,LC305_2,dry_2,
      LC30_3,LC92_3,LC213_3,LC305_3,dry_3,
      LC30_4,LC92_4,LC213_4,LC305_4,dry_4,
      LC30_5,LC92_5,LC213_5,LC305_5,dry_5,
      LC30_6,LC92_6,LC213_6,LC305_6,dry_6,
      GEN,0_2,3_/;


  set reqsPhase / LC30,LC92,LC213,LC305,dry,GEN,0_2,3_/;

  set phase_reqsPhase(phase,reqsPhase) /

      (LC30_1,LC30_2,LC30_3,LC30_4,LC30_5,LC30_6).LC30
      (LC92_1,LC92_2,LC92_3,LC92_4,LC92_5,LC92_6).LC92
      (LC213_1,LC213_2,LC213_3,LC213_4,LC213_5,LC213_6).LC213
      (LC305_1,LC305_2,LC305_3,LC305_4,LC305_5,LC305_6).LC305
      (dry_1,dry_2,dry_3,dry_4,dry_5,dry_6).dry
      GEN.GEN,
*
*     -- for calves raising processes, first two months and rest
*
      0_2.0_2,3_.3_

  /;

  set phase_startPhase(phase,reqsPhase) /
        (LC30_1).LC30
        (LC92_1).LC92
        (LC213_1).LC213
        (LC305_1).LC305
        (dry_1).dry
  /;

  set actHerdsF(herds,breeds,feedRegime,reqsPhase,m) "ReqsPhase indicator";

Parameter

   p_reqsPhase(herds,allBreeds,reqsphase,feedAttr)            "Animal requirements per requirement phase (calves, cows)"
   p_reqsPhaseMonths(herds,breeds,feedRegime,reqsPhase,reqs)  "Requirements for a lactation phase broken down to a month"
   p_reqsPhaseLengthMonths(herds,breeds,reqsPhase)            "Length of requirement phase in month"
   p_reqsPhaseLength(herds,allBreeds,reqsPhase)               "length of specific requirement phases in days"
   p_reqsPhaseStart(herds,allBreeds,phase)                    "Start month of specific requirement phases in days"
   p_grossEnergyPhase(herds,breeds,reqsPhase)                 "Gross energy used to calculate GHG emissions from enteric fermentation"


$iftheni.cows "%cowHerd%"=="true"

   p_nLactations
   p_nLac(cows)                                                 "Number of lactiation periods per cow"
   p_calvCoeff(cows,breeds,mDist)                               "Calves produced per cow"
   p_feedAddRationShare(feedAdd)
$endif.cows
;

   variables
      v_sumReqs(reqs,t,n)                                       "Total requirements in each year"
      v_sumReqsBought(reqs,t,n)                                 "Total requirements in each year from bought feed"
$ifi "%parsAsVars%"=="false" parameter
      v_reqsCorr(herds,breeds,*)                                "Calibration variable"

   positive variables
      v_sexingF(breeds,t,n,m)                                   "Use female sexing for one calving"
      v_sexingM(breeds,t,n,m)                                   "Use male sexing for one calving"
      v_feedUse(feeds,t,n)                                      "Yearly feeding in t per farm"
      v_feedUseProds(feeds,t,n)                                 "Yearly feeding of own produce in t per farm"
      v_feedUseBuy(feeds,t,n)                                   "Yearly feeding of bought in t per farm"
      v_feedUseHerds(herds,feeds,t,n)                           "Yearly feeding in t per farm"
      v_feedUseM(feeds,m,t,n)                                   "Feeding by month period in t per farm"
      v_feeding(herds,breeds,feedRegime,reqsPhase,m,feeds,t,n)  "Yearly feeding in t per herd"
      v_herdsReqsPhase(herds,breeds,feedRegime,reqsPhase,m,t,n) "Animal herds in a certain phase in a certain month"
      v_nutExcrPast(allNut,t,n,m)                               "N and P excretion on pasture"
      v_herdExcrPast(crops,plot,till,intens,herds,feedRegime,t,n,m)
      v_manQuantPast(crops,plot,till,intens,manChain,t,n,m)  "Manure quantity in m3 per month excreted on pastures"
   ;
$ifi %MIP%==on   sos2 variables
      v_buyCowStablesSos2(hor,t,n,cowStables)
      v_buyMotherCowStablesSos2(hor,t,n,motherCowStables)
      v_buyYoungStablesSos2(hor,t,n,youngStables)
      v_buyCalvStablesSos2(hor,t,n,calvStables)
   ;

   equations
      
      minFeedAdd_
      feedUseSource_(feeds,t,n)                                 "Adds up the feed used on farm from own production and market sources"
      reqs_(herds,breeds,feedRegime,t,m,reqsPhase,reqs,n)       "Animal requirements need to be covered"
      herdsByFeedRegime_(herds,breeds,feedRegime,t,n,m)         "Distribute herds to feed regimes"
      herdsreqsPhase_(herds,breeds,reqsPhase,m,t,n)             "Animal herds in a certain phase in a certain month"
      reqsPhase_(herds,breeds,feedRegime,reqs,reqsPhase,m,t,n)  "Animal requirements need to be covered"
      sumReqs_(reqs,t,n)                                        "Total requirements per year"
      sumReqsBought_(reqs,t,n)                                  "Total requirements per year from bought feed"
      feedUse_(feeds,t,n)                                       "Definition of total feed use"
      feedUseHerds_(herds,feeds,t,n)                            "Definition of total feed use"
      feedUseM_(feeds,m,t,n)                                    "Definition of total feed use"
      prodsM_(prods,m,t,n)                                      "Monthly feed use definition"
      herdsBefore_(herds,breeds,feedRegime,t,t,n,m)             "First two years"
      herdsStartBefore_(herds,breeds,t,t,n,m)                   "First two years"
      sumHerdsYY_(sumHerdsY,breeds,t,n)                          "Summary herd definition, per year, sold herds"
      avgLactations_(breeds,t,n)                                "Recover average lactation length from short and long"
      maxHerdChange1_(herds,breeds,feedRegime,t,n,n)            "Special restricton for heifer and calves raisingherd"
      maxHerdChange2_(herds,breeds,feedRegime,t,n,n)            "Special restricton for heifer and calves raisingherd"
      hasHerdOrderDairy_(t,n)
      hasHerdOrderMotherCows_(t,n)

$iftheni.dh %cowherd%==true
      newCalves_(breeds,t,n,m)                                  "Born calves (male and female)"
      maleFemaleRel_(breeds,t,n,m)                              "Born calves, keep male/female relation"
      calvesRaisBal_(herds,breeds,t,n,m)
$elseifi.dh "%buyCalvs%"=="true"
      calvesRaisBal_(herds,breeds,t,n,m)
$endif.dh

      herdExcrPast_(herds,grazRegime,t,n,m)                     "Allocate grazing to grazing plots"
      nutExcrPast_(allNut,t,n,m)                                "N and P excretion on pasture"
      nut2ManurePast_(crops,plot,till,intens,allNut,t,n,m)
      manQuantPast_(crops,plot,till,intens,manChain,t,n,m) "Defintion of manure quantity in m3 per month on pastures"
      FixGrasLand_(t,n)                                         "Ensures that there is no grassland on arable land"
      FixPastLand_(t,n)                                         "Distribution of gras and past land on total land  "

      buyCowStablesSos2_(hor,t,n,cowStables)
      buyMotherCowStablesSos2_(hor,t,n,motherCowStables)
      buyYoungStablesSos2_(hor,t,n,youngStables)
      buyCalvStablesSos2_(hor,t,n,calvStables)
;

*
* ---- Adding up the bought and own produced feed for cattle
*
     feedUseSource_(curFeeds(feedsY),t_n(tCur(t),nCur)) ..
         v_feedUse(feedsY,t,nCur)   =E=
                                          v_feedUseProds(feedsY,t,nCur) $ (sum(sameas(curProds,feedsY),1))
                                        + v_feedUseBuy(feedsY,t,nCur)   $ (sum(sameas(curInputs,feedsY),1)) ;
*
*   --- add requirements over herds, total and bought ones
*
    sumReqs_(reqs,t_n(tCur(t),nCur)) ..

         v_sumReqs(reqs,t,nCur)*1000 =E=
                              sum( curFeeds(feedsY),     v_feedUse(feedsY,t,nCur)   * p_feedContFMton(feedsY,reqs))
                            + sum( (curFeeds(feedsM),m), v_feedUseM(feedsM,m,t,nCur)* p_feedContFMton(feedsM,reqs));

    sumReqsBought_(reqs,t_n(tCur(t),nCur)) ..

         v_sumReqsBought(reqs,t,nCur)*1000
               =E= sum( (sameas(feedsY,curInputs),sys) $ (p_inputprice%l%(curInputs,sys,t) $ curFeeds(feedsY)),
                                   v_buy(curInputs,sys,t,nCur)*p_feedContFMton(feedsY,reqs));
*
*   --- distribution of herd sizes to feeding regimes
*       (such as no grazing, partial grazing, full grazing)
*
    herdsByFeedRegime_(possHerds,curBreeds,feedRegime,t_n(tCur(t),nCur),m)
           $ (actHerds(possHerds,curBreeds,feedRegime,t,m)
                $ sum(reqsPhase $ (not sameas(reqsPhase,"gen")), p_reqsPhaseLengthMonths(possHerds,curBreeds,reqsPhase))) ..

        v_herdSize(possHerds,curBreeds,feedRegime,t,nCur,m)

             =E= sum(reqsPhase $ p_reqsPhase(possHerds,curBreeds,reqsPhase,"DMMX"),
                    v_herdsReqsPhase(possHerds,curBreeds,feedRegime,reqsphase,m,t,nCur)
                    );
*
*   --- calculation of herds in currenty requirement phase over cycles (e.g. dry cows in second lactation)
*
    herdsReqsPhase_(possHerds,breeds,reqsPhase,m,t_n(tCur,nCur))
         $ ( (not p_reqsPhaseLengthMonths(possHerds,breeds,"gen"))
               $ sum(feedRegime, actHerds(possHerds,breeds,feedRegime,tCur,m))
                 $ p_reqsPhase(possHerds,breeds,reqsPhase,"DMMX")  ) ..

          sum(actHerds(possHerds,breeds,feedRegime,tCur,m),
                v_herdsReqsPhase(possHerds,breeds,feedRegime,reqsphase,m,tCur,nCur))

*     --- herds which started in the months before the production length, in case for piglets a separate construct is used
        =E=
          sum(phase_reqsPhase(phase,reqsPhase) $ p_reqsPhaseStart(possHerds,breeds,phase),
            sum( (t1,nCur1,m1) $ ( t_n(t1,nCur1) $ isNodeBefore(nCur,nCur1)
                              $ [ (     ( -p_mDist(tCur,m,t1,m1)+1-p_reqsPhaseStart(possHerds,breeds,phase)       ge 0)
                                   $    ( -p_mDist(tCur,m,t1,m1)+1-p_reqsPhaseStart(possHerds,breeds,phase)
                                      - p_reqsPhaseLengthMonths(possHerds,breeds,reqsPhase) lt 0) $ (p_mDist(tCur,m,t1,m1) le 0)

                                   $    (-p_mDist(tCur,m,t1,m1) le (p_prodLength(possHerds,breeds)-1))

                                  )

                              or  (
                                       ( -p_mDist(tCur,m,t1,m1)+13-p_reqsPhaseStart(possHerds,breeds,phase)    ge 0)
                                   $   ( -p_mDist(tCur,m,t1,m1)+13-p_reqsPhaseStart(possHerds,breeds,phase)
                                          - p_reqsPhaseLengthMonths(possHerds,breeds,reqsPhase) lt 0)    )   $ p_compStatHerd
                                 ]
                                $ sum(feedRegime,actHerds(possHerds,breeds,feedRegime,t1,m1))
                               ),


                    v_herdStart(possHerds,breeds,t1,%nCur1%,m1)
*
*                   --- minus, in case of cows, slaughtered before reaching the final age
*
                   -sum( (slgtCows,cows) $ (sum(feedRegime, actHerds(slgtCows,breeds,feedRegime,t1,m1))
                        $ sameas(cows,possHerds) $ (slgtCows.pos eq cows.pos)),
                             v_herdStart(slgtCows,breeds,t1,%nCur1%,m1))
           ));
*
*   --- requirement constraints (per herd and year), in case only several requirement phases
*       are defined and not the unique general one "gen"
*
    reqsPhase_(possHerds,breeds,feedRegime,reqs,reqsPhase,m,t_n(tCur(t),nCur))
             $ ( actHerds(possHerds,breeds,feedRegime,t,m)
                  $ (not p_reqsPhaseLengthMonths(possHerds,breeds,"gen"))
                  $ p_reqsPhase(possHerds,breeds,reqsPhase,reqs)) ..
*
*         --- herds which started in the months before the production length
*
*                   -- number of months that herd in that requirement phase during that period
*                      multiplied with monthly requirements
*
              sum(actHerds(possHerds,breeds,feedRegime,t,m) $ p_reqsPhaseMonths(possHerds,breeds,feedRegime,reqsPhase,reqs),
                     v_herdsReqsPhase(possHerds,breeds,feedRegime,reqsphase,m,t,nCur)
                       * p_reqsPhaseMonths(possHerds,breeds,feedRegime,reqsPhase,reqs)

*
*                       --- these corrections are endogenous during automatic calibration, otherwise fixed to
*                           loaded calibration results or equal to unity
*
                        *(   v_reqsCorr(possHerds,breeds,"Ener") $ (sameas(reqs,"NEL") or sameas(reqs,"ME"))
                           + v_reqsCorr(possHerds,breeds,"Prot") $ (sameas(reqs,"XP")  or sameas(reqs,"nXP"))
                           + v_reqsCorr(possHerds,breeds,"Rest") $ (not (    sameas(reqs,"XP")  or sameas(reqs,"nXP")
                                                                          or sameas(reqs,"NEL") or sameas(reqs,"ME")))
                         ))
*
*      --- must be covered by feeding times the content of the feed stuff
*
          =L=   sum((actHerdsF(possHerds,breeds,feedRegime,reqsPhase,m),feedRegime_feeds(feedRegime,curFeeds(feeds))),
                   v_feeding(possHerds,breeds,feedRegime,reqsPhase,m,feeds,t,nCur) * p_feedContFMton(feeds,reqs))
          ;
*
*   --- requirement constraints (per herd, year and SON), if solve one unique and general
*       requirement phase "gen" is defined
*
    reqs_(actHerds(possHerds,breeds,feedRegime,tCur(t),m),reqsPhase,reqs,nCur)
        $ (    p_reqsPhaseLengthMonths(possHerds,breeds,"gen")
             $ p_reqsPhaseMonths(possHerds,breeds,feedRegime,reqsphase,reqs)
             $ t_n(t,nCur)) ..
*
*      --- herd size times requirements per head, minus year and SON specific reduction in milk yield


         v_herdSize(possHerds,breeds,feedRegime,t,nCur,m)
                 * p_reqsPhaseMonths(possHerds,breeds,feedRegime,reqsPhase,reqs)
*
*                       --- these corrections are endogenous during automatic calibration, otherwise fixed to
*                           loaded calibration results or equal to unity
*
                        *(   v_reqsCorr(possHerds,breeds,"Ener") $ (sameas(reqs,"NEL") or sameas(reqs,"ME"))
                           + v_reqsCorr(possHerds,breeds,"Prot") $ (sameas(reqs,"XP")  or sameas(reqs,"nXP"))
                           + v_reqsCorr(possHerds,breeds,"Rest") $ (not (    sameas(reqs,"XP")  or sameas(reqs,"nXP")
                                                                          or sameas(reqs,"NEL") or sameas(reqs,"ME")))
                         )
*
*      --- must be covered by feeding times the content of the feed stuff
*
          =L=   sum( feedRegime_feeds(feedRegime,curFeeds(feeds)) $ actHerdsF(possHerds,breeds,feedRegime,reqsPhase,m),
                   v_feeding(possHerds,breeds,feedRegime,reqsPhase,m,feeds,t,nCur) * p_feedContFMton(feeds,reqs))
             ;
*
*   --- definition of total feeduse at farm level from feeding coefficients, yearly
*
    feedUse_(curFeeds(feedsY),t_n(tCur(t),nCur))  ..

       v_feedUse(feedsY,t,nCur)

           =e= sum(actHerdsF(possHerds,breeds,feedRegime,reqsPhase,m) $ feedRegime_feeds(feedRegime,feedsY),
                            v_feeding(possHerds,breeds,feedRegime,reqsPhase,m,feedsY,t,nCur));
*
*   --- definition of total feedusefor each herd from feeding coefficients, yearly
*
    feedUseHerds_(possHerds,curFeeds(feeds),t_n(tCur(t),nCur)) $ sum(actHerdsF(possHerds,breeds,feedRegime,reqsPhase,m),1) ..

       v_feedUseHerds(possHerds,feeds,t,nCur)

           =e= sum(actHerdsF(possHerds,breeds,feedRegime,reqsPhase,m)$ feedRegime_feeds(feedRegime,feeds),
                                 v_feeding(possHerds,breeds,feedRegime,reqsPhase,m,feeds,t,nCur));
*
*   --- definition of feeduse from feeding coefficients, intra-year feeding period
*       (this is relevant for feed harvsted and used fresh)
*
    feedUseM_(curFeeds(feedsM),m,t_n(tCur(t),nCur)) $ sum(actHerdsF(possHerds,breeds,feedRegime,reqsPhase,m),1) ..

       v_feedUseM(feedsM,m,t,nCur)

           =e= sum( actHerdsF(possHerds,breeds,feedRegime,reqsPhase,m) $ feedRegime_feeds(feedRegime,feedsM),
                                           v_feeding(possHerds,breeds,feedRegime,reqsPhase,m,feedsM,t,nCur));

*
*   --- Minimum quantity of feed additives to achieve a certain level of emission reductions
*

 minFeedAdd_(possHerds,feedAdd,t_n(tCur(t),nCur)) $ (sum(actHerdsF(possHerds,breeds,feedRegime,reqsPhase,m),1)
                                                  $ (not sameas (possHerds,"fCalvsrais"))
                                                  $ (not sameas (possHerds,"mCalvsRais"))
                                                  $ (not sum(sameas(possHerds,heifs),1))
                                                  )..

      sum(actHerdsF(possHerds,breeds,feedRegime,reqsPhase,m), v_feeding(possHerds,breeds,feedRegime,reqsPhase,m,feedAdd,tCur,nCur)
                 * p_feedContFMton(feedAdd,"DM"))

                                  =G=
                   p_feedAddRationShare(feedAdd) *
                    sum((actHerdsF(possHerds,breeds,feedRegime,reqsPhase,m),curFeeds) $feedRegime_feeds(feedRegime,curFeeds),
                          v_feeding(possHerds,breeds,feedRegime,reqsPhase,m,curFeeds,tCur,nCur)
*                  correct by dry matter content, as v_feeding is in t FM
                                                      * p_feedContFMton(curFeeds,"DM"));

*
*  ---- add up herds per beerd over feed regimes and months to yearly herd size
*
   sumHerdsYY_(sumHerdsY,breeds,t_n(t,nCur)) $ ( (tCur(t) or tBefore(t))
                                     $  sum(actHerds(sumHerdsY,breeds,feedRegime,t,m),1)) ..

       v_sumherd(sumHerdsY,breeds,t,%nCur%)
          =e= sum((feedRegime,m) $ actHerds(sumHerdsY,breeds,feedRegime,t,m),
                               v_herdSize(sumHerdsY,breeds,feedRegime,t,nCur,m));
$iftheni.dh %cowherd%==true
*
*   --- recover average lactations (e.g. 3.7) from short (e.g. 3 lactations) and long (e.g. 4 lactations) cows
*
    avgLactations_(breeds,t_n(t,nCur)) $ sum((feedRegime,m), actHerds("cows",breeds,feedRegime,t,m)) ..

         sum( (dCows,feedRegime,m) $ actHerds(dCows,breeds,feedRegime,t,m),
               v_herdSize(dCows,breeds,feedRegime,t,nCur,m)*p_nLactations)
        =E=

          sum( (dCows,feedRegime,m) $ actHerds(dCows,breeds,feedRegime,t,m),
               v_herdSize(dcows,breeds,feedRegime,t,nCur,m)*p_nLac(dCows));

$endif.dh

*
*   --- if no herd in t-1, then also no herd in the current year
*       (for dairy and mother cows)
*
$iftheni.dh %dairyherd%==true
    hasHerdOrderDairy_(tCur(t),nCur) $ (tCur(t-1) $ t_n(t,nCur)) ..

       v_HasBranch("dairy",t,%nCur%) =L= sum(t_n(t-1,nCur1) $ anc(nCur,nCur1), v_hasBranch("dairy",t-1,%nCur1%));

$endif.dh

$iftheni.mc "%farmBranchMotherCows%"=="on"
    hasHerdOrderMotherCows_(tCur(t),nCur) $ (tCur(t-1) $ t_n(t,nCur)) ..

       v_HasBranch("motherCows",t,%nCur%) =L= sum(t_n(t-1,nCur1) $ anc(nCur,nCur1), v_hasBranch("motherCows",t-1,%nCur1%));
$endif.mc

$iftheni.dh %cowHerd%==true
*
*   --- definition of calves born
*
    newCalves_(dairyBreeds,t,nCur,m) $ ( sum( (calvs,feedRegime), actHerds(calvs,dairyBreeds,feedRegime,t,m))
                        $ (p_Year(t) le p_year("%lastYear%")) $ t_n(t,nCur) $ (not sameas(dairyBreeds,"%crossBreed%"))) ..
*
*      --- new born calves (for females by genetic potential for milk yield) are born
*          from the current herd of cows
*
                  v_herdStartBornCalvsRais("fCalvsRais",dairyBreeds,t,%nCur%,m)  $ sum(feedRegime,actHerds("fCalvsRais",dairyBreeds,feedRegime,t,m))
                + v_herdStart("fCalvsSold",dairyBreeds,t,%nCur%,m)  $ sum(feedRegime,actHerds("fCalvsSold",dairyBreeds,feedRegime,t,m))
                + v_herdStart("mCalvsSold",dairyBreeds,t,%nCur%,m)  $ sum(feedRegime,actHerds("mCalvsSold",dairyBreeds,feedRegime,t,m))
                + v_herdStartBornCalvsRais("mCalvsRais",dairyBreeds,t,%nCur%,m)  $ sum(feedRegime,actHerds("mCalvsRais",dairyBreeds,feedRegime,t,m))
              $$iftheni.crossBreed "%crossBreeding%"=="true"
                + v_herdStartBornCalvsRais("fCalvsRais","%crossBreed%",t,%nCur%,m) $ (sum(feedRegime,actHerds("fCalvsRais","%crossBreed%",feedRegime,t,m)) $ sameas(dairyBreeds,"%crossBreedBase%"))
                + v_herdStart("fCalvsSold","%crossBreed%",t,%nCur%,m) $ (sum(feedRegime,actHerds("fCalvsSold","%crossBreed%",feedRegime,t,m)) $ sameas(dairyBreeds,"%crossBreedBase%"))
                + v_herdStart("mCalvsSold","%crossBreed%",t,%nCur%,m) $ (sum(feedRegime,actHerds("mCalvsSold","%crossBreed%",feedRegime,t,m)) $ sameas(dairyBreeds,"%crossBreedBase%"))
                + v_herdStartBornCalvsRais("mCalvsRais","%crossBreed%",t,%nCur%,m) $ (sum(feedRegime,actHerds("mCalvsRais","%crossBreed%",feedRegime,t,m)) $ sameas(dairyBreeds,"%crossBreedBase%"))
             $$endif.crossBreed

          =e= sum( (cows,t1,nCur1,m1,mDist) $ (sum(feedRegime,actHerds(cows,dairyBreeds,feedRegime,t1,m1))
                  $ (      (mDist.pos  eq -p_mDist(t,m,t1,m1))
                         or (mDist.pos eq -p_mDist(t,m,t1,m1)+12) $ p_compStatHerd)
                       $ t_n(t1,nCur1) $ herds_breeds(cows,dairyBreeds) $ sameScen(nCur,nCur1)),
                         ( v_herdStart(cows,dairyBreeds,t1,%nCur1%,m1)
                          -sum(slgtCows $((cows.pos eq slgtCows.pos) $ sum(feedRegime,actHerds(slgtcows,dairyBreeds,feedRegime,t1,m1))),
                                           v_herdStart(slgtCows,dairyBreeds,t1,%nCur1%,m1)))
                           * p_calvCoeff(cows,dairyBreeds,mDist))
;
*
*   --- calves raised stem from born on farm or bought ones
*
    calvesRaisBal_(calvsRais,dairyBreeds,t_n(t,nCur),m)
          $ ( sum(actHerds(calvs,dairyBreeds,feedRegime,t,m),1) $ (p_Year(t) le p_year("%lastYear%"))) ..

        v_herdStart(calvsRais,dairyBreeds,t,%nCur%,m)

           =E=

              v_herdStartBornCalvsRais(calvsRais,dairyBreeds,t,%nCur%,m)

            + sum(calvesBought $ ((calvsRais.pos eq calvesBought.pos) $ actHerds(calvesBought,dairyBreeds,"",t,m)),
                v_herdStart(calvesBought,dairyBreeds,t,%nCur%,m))  $ (not sameas(dairyBreeds,"%crossBreed%"))
    ;
*
*   --- make sure that cross-breeding without sexing does not change the male/female relation
*
    maleFemaleRel_(breeds, t_n(t,nCur),m) $ (sum(actHerds(calvs,breeds,feedRegime,t,m),1)
                                                        $ (p_Year(t) le p_year("%lastYear%"))) ..

                 [
                   v_herdStartBornCalvsRais("fCalvsRais",breeds,t,%nCur%,m) $ sum(feedRegime,actHerds("fCalvsRais",breeds,feedRegime,t,m))
                 + v_herdStart("fCalvsSold",breeds,t,%nCur%,m) $ sum(feedRegime,actHerds("fCalvsSold",breeds,feedRegime,t,m))
                 ] /0.495

                 - v_sexingF(breeds,t,nCur,m)*0.5
                 + v_sexingM(breeds,t,nCur,m)*0.5

             =E=
                 + v_sexingF(breeds,t,nCur,m)*0.5
                 - v_sexingM(breeds,t,nCur,m)*0.5

             +[
                   v_herdStartBornCalvsRais("mCalvsRais",breeds,t,%nCur%,m) $ sum(feedRegime,actHerds("mCalvsRais",breeds,feedRegime,t,m))
                 + v_herdStart("mCalvsSold",breeds,t,%nCur%,m) $ sum(feedRegime,actHerds("mCalvsSold",breeds,feedRegime,t,m))
              ] / 0.505;


*
*   --- Current year herd cannot be larger than 104% of last  year herd
*       (Not in current model version)
*
     maxHerdChange1_(herds,breeds,feedRegime,tCur(t),nCur,nCur1) $ (  sum(actHerds(herds,breeds,feedRegime,t,m),1)
                                                 $ t_n(t,nCur) $ anc(nCur,nCur1)
                                                 $ (
                                                     sameas(herds,"heifs")
                                                     or sameas(herds,"fCalvsRais")
                                                     or sameas(herds,"Cows")
                                                     or sameas(herds,"bulls")
                                                     or sameas(herds,"motherCow")
                                                     or sameas(herds,"remonteMotherCows")
                                                     or sameas(herds,"mCalvsRais")
                                                     or sameas(herds,"remonte")
                                                     )
                                                 $ tCur(t-1) $ (not sameas(t,"%lastYear%")) ) ..
*
*         --- steady state: same herd size as last year
*
      sum(t_n(t-1,nCur1), sum(actHerds(herds,breeds,feedRegime,t-1,m), v_herdSize(herds,breeds,feedRegime,t-1,nCur1,m))
                 $$ifi %dairyHerd%==true  + (1-v_hasBranch("dairy",t-1,%nCur1%)) * 1000                $ (not sameas(breeds,"mc"))
                 $$ifi %farmBranchMotherCows%==on  + (1-v_hasBranch("motherCows",t-1,%nCur1%)) * 1000  $      sameas(breeds,"mc")
          )

           =G=  sum(actHerds(herds,breeds,feedRegime,t,m),v_herdSize(herds,breeds,feedRegime,t,nCur,m))*0.96 -1;

     maxHerdChange2_(herds,breeds,feedRegime,tCur(t),nCur,nCur1) $ ( sum(actHerds(herds,breeds,feedRegime,t,m),1)
                                                 $ anc(nCur,nCur1)
                                                 $ ( (1 eq 2)
*                                                      or sameas(herds,"heifs")
                                                       or sameas(herds,"fCalvsRais")
                                                       or sameas(herds,"Cows") $ (not sameas(t,"%lastYear%"))
                                                       or sameas(herds,"bulls")
                                                       or sameas(herds,"motherCow") $ (not sameas(t,"%lastYear%"))
                                                       or sameas(herds,"remonteMotherCows")
                                                       or sameas(herds,"mCalvsRais")
                                                      or sameas(herds,"remonte")
                                                     )
                                                 $ tCur(t-1)  $ (not sameas(t,"%lastYear%"))) ..
*
*         --- steady state: same herd size as last year
*
       sum((actHerds(herds,breeds,feedRegime,t-1,m),t_n(t-1,nCur1)), v_herdSize(herds,breeds,feedRegime,t-1,nCur1,m))

           =l=  sum(actHerds(herds,breeds,feedRegime,t,m),v_herdSize(herds,breeds,feedRegime,t,nCur,m))*1.04 +1
                 $$ifi %dairyHerd%==true  + (1-v_hasBranch("dairy",t,%nCur%)) * 100                $ (not sameas(breeds,"mc"))
                 $$ifi %farmBranchMotherCows%==on  + (1-v_hasBranch("motherCows",t,%nCur%)) * 1000  $      sameas(breeds,"mc")
     ;

*
*    ---- calvsrais balance for beef branch only
*
$elseifi.dh  "%buyCalvs%"=="true"

   calvesRaisBal_("mCalvsRais",dairyBreeds,t_n(t,nCur),m) $ ( sum(actHerds(calvs,dairyBreeds,feedRegime,t,m),1)
                                                              $ (p_Year(t) le p_year("%lastYear%"))) ..

        v_herdStart("mCalvsRais",dairyBreeds,t,%nCur%,m)

           =E=

               v_herdStart("mCalvsRaisBought",dairyBreeds,t,%nCur%,m)  $ (not sameas(dairyBreeds,"%crossBreed%"))
;
$endif.dh
*
*   --- steady state before the actual simulation starts
*
$iftheni.compStat "%Dynamics%"=="Comparative-static"

$eval firstYear1 %firstYear%

$elseifi.compStat "%Dynamics%"=="Short run"

$eval firstYear1 %firstYear%

$else.compStat

$eval firstYear1 %firstYear%+1

$endif.compStat

    herdsBefore_(possHerds(herds),breeds,feedRegime,tbefore,t,nCur,m) $ (  actHerds(herds,breeds,feedRegime,tBefore,m)
                                                              $ actHerds(herds,breeds,feedRegime,t,m)
                         $ (sameas(t,"%firstYear%") $ t_n(t,nCur))
                                                   $ (
       $$iftheni %cowherd%==true
                                                           sameas(herds,"cows")
                                                       or  sum(sameas(herds,heifs),1)
                                                       or  sameas(herds,"slgtCows")
                                                       or  sameas(herds,"remonte")
                                                       or  sameas(herds,"motherCow")


                                                       or  remonte(herds)
                                                       or  sameas(herds,"fCalvsRais")
                                                       or  sameas(herds,"mCalvsRais")
                                                       or  sameas(herds,"fCalvsSold")
                                                       or  sameas(herds,"mCalvsSold")

            $$ifi "%farmBranchBeef%"=="on"             or
       $$endif

       $$ifi "%farmBranchBeef%"=="on"                      sum(sameas(herds,bulls),1)
       $$ifi "%farmBranchBeef%"=="on"                  or  sameas(herds,"bullsSold")
       $$ifi "%farmBranchBeef%"=="on"                  or  sameas(herds,"bullsBought")
       $$ifi "%farmBranchMotherCows%"=="on"            or sum(sameas(herds,bulls),1)
                                               )) ..



      sum(t_n(tBefore,nCur1) $ sameScen(nCur1,nCur) ,v_herdSize(herds,breeds,feedRegime,tBefore,nCur1,m))
          =E= v_herdSize(herds,breeds,feedRegime,t,nCur,m);

    herdsStartBefore_(possHerds(herds),breeds,tbefore,t,nCur,m) $ (sum(feedRegime,actHerds(herds,breeds,feedRegime,tBefore,m))
                                $ (sameas(t,"%firstYear%") or sameas(t,"%firstYear1%")) $ t_n(t,nCur)
                                                   $  (
                                                            sameas(herds,"MotherCow")
                                       $$ifi defined heifs  or sum(sameas(herds,heifs),1)
                                       $$ifi defined bulls  or sum(sameas(herds,bulls),1)
                                                         or sameas(herds,"remonteMotherCows")
                                                      )
                                                   ) ..

*         --- steady state: starting herds before the first fully simulated year are equal to that one
*
      sum(t_n(tBefore,nCur1) $ sameScen(nCur1,nCur),v_herdStart(herds,breeds,tBefore,%nCur1%,m))
              =E=  v_herdStart(herds,breeds,t,%nCur%,m);
*
*   --- production of non-marketable feed per intra-year planning period
*
    prodsMY_(curProds(prodsMonthly),t_n(tCur(t),nCur),m) $ sum( (c_p_t_i(curCrops(crops),plot,till,intens))
                                                        $ (v_cropHa.up(crops,plot,till,intens,tCur,nCur) ne 0),
                                                          sum(plot_soil(plot,soil),p_OCoeffM%l%(crops,soil,till,intens,prodsMonthly,m,t))
                                                         $ curProds(prodsMonthly)) ..

       v_prodsIntr(prodsMonthly,t,nCur,m)
         =e= sum( c_p_t_i(curCrops(crops),plot,till,intens),
                      v_cropHa(crops,plot,till,intens,t,%nCur%)
                         * sum(plot_soil(plot,soil) $ p_OCoeffM%l%(crops,soil,till,intens,prodsMonthly,m,t),
                                        p_OCoeffM(crops,soil,till,intens,prodsMonthly,m,t))
                    $$iftheni.sp "%stochProg%"=="true"
                       $$iftheni.stochYield "%stochYields%"=="true"
                                    * p_randVar("gras",nCur)
                       $$endif.stochYield
                    $$endif.sp
                                        );
*
*   --- these products must be exhausted by feed use
*
    prodsM_(curProds(prodsMonthly),m,t_n(tCur(t),nCur)) ..

       sum(sameas(prodsMonthly,curFeeds(feedsM)),v_feedUseM(feedsM,m,t,nCur))

         =e=
*        --- crop output
           v_prodsIntr(prodsMonthly,t,nCur,m) $ sum( c_p_t_i(curCrops(crops),plot,till,intens)
                $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0),
                  sum(plot_soil(plot,soil),p_OCoeffM%l%(crops,soil,till,intens,prodsMonthly,m,t))
                    $$iftheni.sp "%stochProg%"=="true"
                       $$iftheni.stochYield "%stochYields%"=="true"
                                     * p_randVar("gras",nCur)
                       $$endif.stochYield
                    $$endif.sp
                  ) ;
*
*   -- distribute grazing herds to grazing plots
*      (nutrient balancing equation in templ.gms should lead to a reasonable allocation)
*
    herdExcrPast_(possHerds,grazRegime,t_n(tCur(t),nCur),m) $ (sum(grasscrops $ (p_grazMonth(grassCrops,m)>0),1)
                                                                $ sum(actHerds(possHerds,breeds,grazRegime,t,m)
                                                                   $ sum(nut2,p_nutExcreDueV(possHerds,grazRegime,nut2)),1)) ..

        sum(c_p_t_i(curCrops(pastcrops),plot,till,intens)$(p_grazMonth(pastCrops,m)>0),
           v_herdExcrPast(curCrops,plot,till,intens,possHerds,grazRegime,tCur,nCur,m)) =e=

                       sum(actHerds(possHerds,breeds,grazRegime,t,m)
                              $ sum(nut2,p_nutExcreDueV(possHerds,grazRegime,nut2)),
                                 v_herdSize(possHerds,breeds,grazRegime,t,nCur,m)

                                   * (     1   $ sameas(grazRegime,"fullGraz")
                                         + 0.5 $ sameas(grazRegime,"partGraz")));
*
* --- derive for each plot the resulting nutrient excreation
*
   nut2ManurePast_(c_p_t_i(curCrops(pastcrops),plot,till,intens),allNut,t_n(tCur(t),nCur),m)
                                                $ ( (p_grazMonth(pastCrops,m)>0)
                                                    $ sum(actHerds(possHerds,breeds,grazRegime,t,m),1)) ..

     v_nut2ManurePast(pastcrops,plot,till,intens,allNut,t,nCur,m)
        =E=  sum((possHerds,grazRegime) $ sum(actHerds(possHerds,breeds,grazRegime,t,m),1),
                       v_herdExcrPast(pastcrops,plot,till,intens,possHerds,grazRegime,t,nCur,m)
                                                  * p_nutExcreDueV(possHerds,grazRegime,allNut)) * 1/card(m);
*
*  --- add up over excretion allocated to inidivual grazing activities
*
   nutExcrPast_(allNut,t_n(tCur(t),nCur),m)$(  sum(pastcrops $(p_grazMonth(pastCrops,m)>0),1)
                                                $ sum(actHerds(possHerds,breeds,grazRegime,t,m),1)) ..

       v_nutExcrPast(allNut,t,nCur,m) =e= sum(c_p_t_i(curCrops(pastcrops),plot,till,intens)
                                                   $ ((p_grazMonth(pastCrops,m)>0)
                                                   $ sum(actHerds(possHerds,breeds,grazRegime,t,m),1)),
                                               v_Nut2ManurePast(pastcrops,plot,till,intens,allNut,t,nCur,m));

*
*   --- manure quantity excreted on pasture for emission calculation
*

    manQuantPast_(pastcrops,plot,till,intens,curManChain(manChain),t_n(tCur(t),nCur),m)
          $ (c_p_t_i(pastcrops,plot,till,intens) $ (p_grazMonth(pastCrops,m)>0) ) ..

        v_manQuantPast(pastcrops,plot,till,intens,manChain,t,nCur,m)  =e=

                 sum((possHerds,grazRegime) $ (sum(actHerds(possHerds,breeds,grazRegime,t,m),1)
                                                  $ manChain_herd(curManChain,possHerds)
                                                  $c_p_t_i(pastcrops,plot,till,intens)),
                                 v_herdExcrPast(pastcrops,plot,till,intens,possHerds,grazRegime,t,nCur,m)
                                                            * p_manQuantMonth(possHerds,curManChain)) * 1/card(m);
*
*  --- Equation to ensure that there is no gras on arable land
*
   fixGrasLand_(t_n(tCur(t),nCur)) ..

      $$iftheni.grasOnArab "%grasOnArab%"=="true"
*
*         --- grasslands for cutting allowed on arable land: exclude that pasture use exceed available
*             land equipped with fences
*
          sum( c_p_t_i(grassCrops(curCrops),plot,till,intens) $ (past(curCrops) or mixPast(curCrops)), v_cropHa(curCrops,plot,till,intens,t,%nCur%)  )
      $$else.grasOnArab
          sum( c_p_t_i(grassCrops(curCrops),plot,till,intens), v_cropHa(curCrops,plot,till,intens,t,%nCur%)  )
      $$endif.grasOnArab
                                =l=
          sum(plot $ (not plot_landType(plot,"arab")), p_plotSize(plot)
             + sum( (t1,nCur1) $ (t_n(t1,nCur1) $ tcur(t1) $ isNodeBefore(nCur,nCur1) $ (ord(t1) le ord(t))), v_buyPlot(plot,t1,nCur1)*p_buyPlotSize))
             ;
*
*  --- Equation to ensure no cut grasland on pastureland
*
   fixPastLand_(t_n(tCur(t),nCur))  ..

       sum( c_p_t_i(curCrops,plot,till,intens) $ (gras(curCrops) or mixPast(curCrops)), v_cropHa(curCrops,plot,till,intens,t,%nCur%)  )
                                =l=
      $$iftheni.grasOnArab "%grasOnArab%"=="true"
          sum(plot $ (not plot_landType(plot,"past")), p_plotSize(plot)
             + sum( (t1,nCur1) $ (t_n(t1,nCur1) $ tcur(t1) $ isNodeBefore(nCur,nCur1) $ (ord(t1) le ord(t))), v_buyPlot(plot,t1,nCur1)*p_buyPlotSize))
      $$else.grasOnArab
          sum(plot_landType(plot,"gras") $ (not plot_landType(plot,"past")), p_plotSize(plot)
             + sum((t1,nCur1) $ (t_n(t1,nCur1) $ tcur(t1) $ isNodeBefore(nCur,nCur1) $ (ord(t1) le ord(t))), v_buyPlot(plot,t1,nCur1)*p_buyPlotSize)
          )
      $$endif.grasOnArab
       ;

$iftheni.SOS2 "%useSOS2%"=="true"
*
*  --- For the SOS2 sets (two neibhoring points need to be selected by the solver), the set has to be on the last position
*

  buyCowStablesSos2_(hor,t_n(tcur,%nCur%),cowStables) $ ((v_buyStablesF.up(cowStables,hor,tCur,%nCur%) ne 0) $ (v_hasFarm.up(tCur,%nCur%) ne 0)) ..
           v_buyStables(cowStables,hor,tCur,%nCur%) =E= v_buyCowStablesSos2(hor,tcur,%nCur%,cowStables);

  buyMotherCowStablesSos2_(hor,t_n(tcur,%nCur%),motherCowstables) $ ((v_buyStablesF.up(motherCowstables,hor,tCur,%nCur%) ne 0) $ (v_hasFarm.up(tCur,%nCur%) ne 0)) ..
           v_buyStables(motherCowStables,hor,tCur,%nCur%) =E= v_buyMotherCowStablesSos2(hor,tcur,%nCur%,motherCowStables);

  buyYoungStablesSos2_(hor,t_n(tcur,%nCur%),youngstables) $ ((v_buyStablesF.up(youngstables,hor,tCur,%nCur%) ne 0) $ (v_hasFarm.up(tCur,%nCur%) ne 0)) ..
           v_buyStables(youngStables,hor,tCur,%nCur%) =E= v_buyYoungStablesSos2(hor,tcur,%nCur%,youngStables);

  buyCalvstablesSos2_(hor,t_n(tcur,%nCur%),calvstables) $ ((v_buyStablesF.up(calvStables,hor,tCur,%nCur%) ne 0) $ (v_hasFarm.up(tCur,%nCur%) ne 0)) ..
           v_buyStables(calvStables,hor,tCur,%nCur%) =E= v_buyCalvStablesSos2(hor,tcur,%nCur%,calvStables);

$endif.SOS2


   model m_cattle /
                  herdsByFeedRegime_
                  herdsReqsPhase_
                  reqsPhase_
                  reqs_
                  sumReqs_
                  sumReqsBought_
                  feedUse_
                  feedUseHerds_
                  feedUseM_
                  sumHerdsYY_
                  feedUseSource_
$ifi "%feedAddOn%" == true minFeedAdd_
$iftheni.ch %cowHerd%==true
                  newCalves_
                  maleFemaleRel_
                  calvesRaisBal_
$elseifi.ch  "%buyCalvs%"=="true"
                  calvesRaisBal_
$endif.ch

$iftheni.ch %cowHerd%==true
*                 maxHerdChange1_
*                 maxHerdChange2_
$endif.ch
$iftheni.dh %dairyHerd%==true
$ifi not "%endoMeasures%" == true avgLactations_
$endif.dh
                  herdsBefore_
                  herdsStartBefore_
*                  maxoilsfats_
                  prodsM_
                  prodsMY_
                  herdExcrPast_
                  nutExcrPast_
                  nut2ManurePast_
                  manQuantPast_
  FixGrasLand_
                  FixPastLand_


$iftheni.SOS2 "%useSOS2%"=="true"

                  buyCowStablesSos2_
                  buyMotherCowStablesSos2_
                  buyYoungStablesSos2_
                  buyCalvStablesSos2_
$endif.SOS2

$iftheni.dh %dairyHerd%==true
                         hasHerdOrderDairy_
$endif.dh
$iftheni.mc "%farmBranchMotherCows%"=="on"
                         hasHerdOrderMotherCows_
$endif.mc

      /;
