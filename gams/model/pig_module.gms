********************************************************************************
$ontext

   FARMDYN project

   GAMS file : PIG_MODULE.GMS

   @purpose  : Variables/equations linked of pig module
   @author   : Wolfgang Britz, using existing code of rev. 472
   @date     : 10.12.14
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : model/templ.gms

$offtext
********************************************************************************


    parameter
        p_feedAttrPig(feedsPig,feedAttr)                       "Feeding attributes for different inputs"
        p_feedMinPig(herds,feedspig,feedRegime)                "Minimum requirements of pig feeding"
        p_feedMaxPig(herds,feedspig,feedRegime)                "Maximum requirements of pig feeding"
        p_lifeTimeSow                                          "Life time of sows in years"
        p_animalLoss(herds)                                    "Animal losses for fattners and piglets"
    $$ifi "%parsAsVars%"=="true" variable
        p_feedReqPig(herds,feedRegime,feedAttr)                "Feeding requirement for herds with respect to energy, crude protein, lysing and phosphate"
   ;


   Equations
      newPiglets_(t,n,m)                                   "Determines the amount of piglets born"
      reqPigs_(herds,feedAttr,feedRegime,t,n,m)            "Requirements of pigherd for energy, crude protein etc."
      feedSourcePig_(feedspig,t,n)                         "Determine the source of feed(purchased or own produced)"
      feedTotPig_(herds,feedRegime,t,n,m)                  "Total feed amount for pigs in tons"
      feedMinPig_(herds,feedspig,feedRegime,t,n,m)         "Minimum requirements for mixture of feed products for correct texture and digestibility"
      feedMaxPig_(herds,feedspig,feedRegime,t,n,m)         "Maximum requirements for mixture of feed products for correct texture and digestibility"
     $$ifi defined fatStables  buyFatStablesSos2_(hor,t,n,fatStables)
     $$ifi defined sowStables  buySowStablesSos2_(hor,t,n,SowStables)
   ;

   positive variables
        v_feedingPig(herds,feedsPig,feedRegime,t,n,m)      "Feeding amount for pigs differentiated by herd and feed product"
        v_feedOwnPig(feedspig,t,n)                         "Own produced pig feed in tons"
        v_feedPurchPig(feedspig,t,n)                       "Purchased pig feed in tons "
        v_feedTotPig(herds,feedRegime,t,n,m)               "Total amount of pig feed each month in tons per pig herd"
   ;

   $$ifi %MIP%==on   sos2 variables
    $$ifi defined fatStables  v_buyFatStablesSos2(hor,t,n,fatStables)
    $$ifi defined sowStables  v_buySowStablesSos2(hor,t,n,sowStables)
   ;
*
*   --- piglets born: herd size of sows times piglets per sow and year
*

    $$iftheni.sows "%farmBranchSows%"=="on"

       newPiglets_(t_n(tCur(t),nCur),m) $  sum(feedRegime,actHerds("sows","",feedRegime,t,m)) ..

          v_herdStart("youngPiglets","",t,nCur,m)
              =e=  sum(actHerds("sows","",feedRegime,t,m),
                       v_herdSize("sows","",feedRegime,t,nCur,m) * p_OCoeff("sows","youngPiglet","",t))/card(m);
    $$endif.sows
*
*   --- feeding requirements for energy, crude protein, lysin, phosphatefeed and mass
*
    reqPigs_(possHerds,feedAttr,feedRegime,t_n(tCur(t),nCur),m) $ ( sum(actHerds(herds,"",feedRegime,t,m),1)
                                           $ p_feedReqPig%l%(possHerds,feedRegime,feedAttr)
                                           $ (not (sameas(possherds,"pigletsBought") or sameas(possherds,"youngSows")
                                                                                     or sameas(possherds,"youngPiglets")))) ..

         v_herdSize(possHerds,"",feedRegime,t,nCur,m) * p_feedReqPig(possHerds,feedRegime,feedAttr)
                =L= sum(feedspig $ sum(sameas(feedsPig,curInputs),1), v_feedingPig(possherds,feedsPig,feedRegime,t,nCur,m) * p_feedAttrPig(feedsPig,feedAttr));

*
*  --- Either purchased or own produced product
*
   feedSourcePig_(feedspig,t_n(tCur(t),nCur)) $ (sum(actHerds(herds,"",feedRegime,t,m),1) $ sum(sameas(feedsPig,curInputs),1))  ..

        v_feedOwnPig(feedspig,t,nCur) $ sum(sameas(curProds,feedspig),1)
      + v_feedPurchPig(feedspig,t,nCur)

          =E= sum((possherds,feedRegime,m)
                  $ [   (not (    sameas(possherds,"pigletsBought") or sameas(possherds,"youngSows")
                               or sameas(possherds,"youngPiglets")))
                      $ sum(actHerds(possHerds,"",feedRegime,t,m),1)],
                       v_feedingPig(possherds,feedsPig,feedRegime,t,nCur,m));
*
*  --- Total amount of fodder in tons for each pigherd
*
   feedTotPig_(possHerds,feedRegime,t_n(t,nCur),m) $( sum(actHerds(herds,"",feedRegime,t,m),1)
                                   $ (not sameas(possherds,"pigletsBought"))
                                   $ (not sameas(possherds,"youngSows"))
                                   $ (not sameas(possherds,"youngPiglets"))) ..

                v_feedTotPig(possherds,feedRegime,t,nCur,m)
                                =E=
                          sum(feedsPig $ sum(sameas(feedsPig,curInputs),1), v_feedingPig(possHerds,feedspig,feedRegime,t,nCur,m));

*
*  --- Upper and lower bounds for feed mixture, defined for fattners by typical feeding ratio.
*      Equation is only active for feeds which are
*      linked to bounds, certains feeds - e.g. cereals - can be freely selected
*
   feedMinPig_(possHerds,feedspig,feedRegime,t_n(t,nCur),m) $ ( sum(actHerds(herds,"",feedRegime,t,m),1)
                                              $  sum (feedsRestricted(feedspig),1)
                                              $ sum(sameas(feedsPig,curInputs),1)
                                              $ (not sameas(possherds,"pigletsBought"))
                                              $ (not sameas(possherds,"youngSows"))
                                              $ (not sameas(possherds,"youngPiglets")) ) ..

                v_feedingPig(possHerds,feedsPig,feedRegime,t,nCur,m)
                                        =G=
                              v_feedTotPig(possherds,feedRegime,t,nCur,m) *  p_feedMinPig(possHerds,feedspig,feedRegime) ;

   feedMaxPig_(possHerds,feedspig,feedRegime,t_n(t,nCur),m) $ ( sum(actHerds(herds,"",feedRegime,t,m),1)
                                                    $  sum (feedsRestricted(feedspig),1)
                                                    $ sum(sameas(feedsPig,curInputs),1)
                                                    $ (not sameas(possherds,"youngSows"))
                                                    $ (not sameas(possherds,"youngPiglets"))
                                                    $ (not sameas(feedsPig,"soybeanMeal")) )  ..

               v_feedingPig(possHerds,feedsPig,feedRegime,t,nCur,m)
                                        =L=
                               v_feedTotPig(possherds,feedRegime,t,nCur,m) *  p_feedMaxPig(possHerds,feedspig,feedRegime) ;

$iftheni.SOS2 "%useSOS2%"=="true"
*
*  --- For the SOS2 sets (two neibhoring points need to be selected by the solver), the set has to be on the last position
*
  $$iftheni.fat defined fatStables
    buyFatStablesSos2_(hor,t_n(tcur,%nCur%),fatStables) $ ((v_buyStablesF.up(fatStables,hor,tCur,%nCur%) ne 0) $ (v_hasFarm.up(tCur,%nCur%) ne 0)) ..
           v_buyStables(fatStables,hor,tCur,%nCur%) =E= v_buyFatStablesSos2(hor,tcur,%nCur%,fatStables);

  $$endif.fat

  $$iftheni.sow defined sowStables

     buySowStablesSos2_(hor,t_n(tcur,%nCur%),sowStables) $ ((v_buyStablesF.up(sowStables,hor,tCur,nCur) ne 0) $ (v_hasFarm.up(tCur,%nCur%) ne 0)) ..
           v_buyStables(sowStables,hor,tCur,%nCur%) =E= v_buySowStablesSos2(hor,tcur,%nCur%,sowStables);

  $$endif.sow

$endif.SOS2


    model m_pigs /

    $$ifi  "%farmBranchSows%"=="on"  newPiglets_
                 reqPigs_
                 feedSourcePig_
                 feedTotPig_
                 feedMinPig_
*                 feedMaxPig_
$iftheni.SOS2 "%useSOS2%"=="true"
    $$ifi defined fatStables  buyFatStablesSos2_
    $$ifi defined SowStables  buySowStablesSos2_
$endif.SOS2
    /;
