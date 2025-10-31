********************************************************************************
$ontext

   FARMDYN project

   GAMS file : SET_DERIVED_BOUNDS.GMS

   @purpose  : Determine set of currently active crops and products
               from given upper bounds, and set upper bounds for certain
               variables derived from others
   @author   : W.Britz
   @date     : 25.07.13
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter.gms

$offtext
********************************************************************************

 curCrops(crops) $ (not sum(c_p_t_i(crops,plot,till,intens),1)) = no;

$ifi "%orgTill%"=="off" p_inputPrice(inputs,"org",tCur) = 0;
 v_buy.fx(inputs,sys,t_n(tCur,nCur)) $ (not p_inputprice(inputs,sys,tCur)) = 0;


$ifi "%biogas%" == "true" option kill = v_volManBioGas.l;

 v_prods.fx (prodsYearly,t_n(t,nCur))
                     $ ( ([sum((c_p_t_i(crops,plot,till,intens),plot_soil(plot,soil))
                                      $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0),
                                         p_OCoeffC(crops,soil,till,intens,prodsYearly,t))


                       +  sum ((c_p_t_i(crops,plot,till,intens),plot_soil(plot,soil))
                                         $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0),
                                           p_OCoeffResidues(crops,soil,till,intens,prodsyearly,t))

                       $$iftheni.herd "%herd%" == "true"

                          +  sum( actherds(possHerds,breeds,feedRegime,t,m)
                                        $ (p_OCoeff(possHerds,prodsYearly,breeds,t)
                                             $ v_herdSize.up(possHerds,breeds,feedRegime,t,nCur,m)),1)
                       $$endif.herd
                     ] eq 0)) = 0;


 curProds(prodsYearly) $ ((sum( (t_n(tCur,nCur),sys) $ (v_prods.up(prodsYearly,tCur,nCur) gt 0),1))
                                                              $$ifthen.curInputs defined curInputs
                                                                or sum(sameas(curInputs,prodsYearly),1)
                                                              $$else.curInputs
                                                                or sum(sameas(inputs,prodsYearly),1)
                                                              $$endif.curInputs
                                                               ) = yes;
*
* --- delete crops (feeds) that are not selected in GUI and  do not have a input price from prods
*

  curProds(prodsYearly) $ ((sum(sameas(Crops,prodsYearly),1)) $ (not sum(sameas(curCrops,prodsYearly),1)) $ (not (sum(sameas(inputs,prodsYearly), p_inputPrices(inputs,"price"))))) = NO;


 v_prods.up (curProds(prodsYearly),t_n(t,nCur))
                     = sum(plot $ sum((c_p_t_i(crops,plot,till,intens),plot_soil(plot,soil)),p_OCoeffC(crops,soil,till,intens,prodsYearly,t)),
                        smax ((c_p_t_i(crops,plot,till,intens),plot_soil(plot,soil)) $ p_OCoeffC(crops,soil,till,intens,prodsYearly,t),
                                     v_cropHa.up(crops,plot,till,intens,t,nCur)*
                                         p_OCoeffC(crops,soil,till,intens,prodsYearly,t)))

                       + sum(plot $ sum((c_p_t_i(crops,plot,till,intens),plot_soil(plot,soil)),p_OCoeffResidues(crops,soil,till,intens,prodsyearly,t)),
                          smax((c_p_t_i(crops,plot,till,intens),plot_soil(plot,soil)) $ p_OCoeffResidues(crops,soil,till,intens,prodsyearly,t),
                                       v_cropHa.up(crops,plot,till,intens,t,nCur)*
                                           p_OCoeffResidues(crops,soil,till,intens,prodsyearly,t)))

                       $$iftheni.herd "%herd%" == "true"

                          + [ smax( actherds(possHerds,breeds,feedRegime,t,m) $ p_OCoeff(possHerds,prodsYearly,breeds,t),
                                        p_OCoeff(possHerds,prodsYearly,breeds,t)
                                             * v_herdSize.up(possHerds,breeds,feedRegime,t,nCur,m))
$iftheni "%farmbranchFattners%" == "on"
                                                 * 4
$endif
                             ]   $ sum( actherds(possHerds,breeds,feedRegime,t,m),p_OCoeff(possHerds,prodsYearly,breeds,t))

                       $$endif.herd
                     ;
 v_saleQuant.up(prodsYearly,sys,t_n(t,nCur)) $ ( v_saleQuant.up(prodsYearly,sys,t,nCur) ne 0)
     = v_prods.up(prodsYearly,t,nCur);

 if ( sum((prodsYearly,sys,t_n(t,nCur)) $ ((v_saleQuant.up(prodsYearly,sys,t,nCur) ne 0) and (not p_price(prodsYearly,sys,t))),1),

    option kill=curProds;
    curProds(prodsYearly)
      $ sum((sys,t_n(t,nCur)) $ ((v_saleQuant.up(prodsYearly,sys,t,nCur) ne 0) and (not p_price(prodsYearly,sys,t))),1) = YES;

    abort "Products which can be sold, but have no price in file: %system.fn%, line: %system.incline%",curProds;
 );
*
* --- crops which are not produced cannot be used for bio-gas production from own production
*
$ifi "%biogas%" == "true" v_feedBioGas.fx(bhkw,eeg,crM,t_n(t,nCur),m) $ (not sum(sameas(curProds,crM),1)) = 0;

$iftheni.cattle "%cattle%" == "true"

 v_feedUse.up(feeds,t_n(t,nCur)) $ sum(sameas(feeds,prodsYearly) $ (not curProds(prodsYearly)),1) = no;

 option kill=actHerdsF;
 actHerdsF(herds,breeds,feedRegime,reqsPhase,m) $ sum(tCur, actHerds(herds,breeds,feedRegime,tCur,m)) = YES;
 actHerdsF(herds,breeds,feedRegime,reqsPhase,m) $ ((not p_reqsPhaseMonths(herds,breeds,feedRegime,reqsPhase,"DMMX"))
        $ actHerdsF(herds,breeds,feedRegime,reqsPhase,m)) = NO;

 v_feeding.up(actHerdsF(possHerds,breeds,feedRegime,reqsPhase,m),feeds,t_n(tCur,nCur))
            $ sum(sameas(feeds,prodsYearly) $ (not curProds(prodsYearly)),1) = no;

 v_feedUseHerds.up(possHerds,feeds,t_n(tCur,nCur))
            $ sum(sameas(feeds,prodsYearly) $ (not curProds(prodsYearly)),1) = no;

 v_prods.up(prodsMonthly,t_n(t,nCur))
  $  (not sum( (c_p_t_i(crops,plot,till,intens),m), v_cropHa.up(crops,plot,till,intens,t,nCur)
                     * sum(plot_soil(plot,soil),p_OCoeffM(crops,soil,till,intens,prodsMonthly,m,t)))) = 0;

 v_feedUseM.up(feedsM,m,t_n(tCur,nCur)) $ ((not sum( c_p_t_i(crops,plot,till,intens),
                    v_cropHa.up(crops,plot,till,intens,tCur,nCur)
                     * sum((plot_soil(plot,soil),sameas(feedsM,prodsMonthly)),
                           p_OCoeffM(crops,soil,till,intens,prodsMonthly,m,tCur)))) ) = 0;

 curProds(prodsMonthly) = YES;

$ifi "%debugOutput%"=="true"  display curProds;

 v_feedUseM.up(feedsM,m,t_n(tcur,nCur)) $ (not sum(sameas(feedsM,curProds),1)) = 0;

 v_feeding.up(actHerdsF(possHerds,breeds,feedRegime,reqsPhase,m),feedsM,t_n(tCur,nCur)) $ (not sum(sameas(feedsM,curProds),1)) = 0;

*
*   --- fix feed use to zero if all feeding activities are fixed to zero
*
 v_feeduseM.fx(feedsM,m,t_n(tcur,nCur))
     $ (not sum( (actHerds(herds,breeds,feedRegime,tCur,m),reqsPhase)
                    $ (v_feeding.up(herds,breeds,feedRegime,reqsPhase,m,feedsM,tCur,nCur) gt 0),1) $ v_feedUseM.range(feedsM,m,tCur,nCur) ) = 0;
*
*   -- fix pasture use in month with no production
*
 v_feeduseM.fx(feedsM,m,t_n(tCur,nCur))
     $ (not sum( (crops,soil,till,intens,sameas(feedsM,prodsMonthly)),
                             p_OCoeffM(crops,soil,till,intens,prodsMonthly,m,tCur))) = 0;

 v_feedUseM.up(feedsM,m,t_n(tCur,nCur)) $ v_feedUseM.range(feedsM,m,tCur,nCur)
    = sum( (actHerds(herds,breeds,feedRegime,tCur,m),reqsPhase)
            $ p_reqsPhaseMonths(herds,breeds,feedRegime,reqsPhase,"DMMX"),
                           v_feeding.up(herds,breeds,feedRegime,reqsphase,m,feedsM,tCur,nCur));

 v_feeduse.fx(feedsY,t_n(tCur,nCur))
    $ (not sum( (actHerds(herds,breeds,feedRegime,tCur,m),reqsPhase)
                   $ (v_feeding.up(herds,breeds,feedRegime,reqsphase,m,feedsY,tCur,nCur) gt 0),1) $ v_feedUse.range(feedsY,tCur,nCur)) = 0;

 v_feedUse.up(feedsY,t_n(tCur,nCur)) $ v_feedUse.range(feedsY,tCur,nCur)
     = sum( (actHerds(herds,breeds,feedRegime,tCur,m),reqsPhase)
              $ p_reqsPhaseMonths(herds,breeds,feedRegime,reqsPhase,"DMMX"),
                            v_feeding.up(herds,breeds,feedRegime,reqsphase,m,feedsY,tCur,nCur));

 curFeeds(feedsY)  $ (not sum(t_n(tCur,nCur),v_feedUse.up(feedsY,tCur,nCur)))        = no;
 curFeeds(feedsM)  $ (not sum((m,t_n(tCur,nCur)),v_feedUseM.up(feedsM,m,tCur,nCur))) = no;
 curFeeds(feeds)   $ (not sum(reqs,p_feedContFMton(feeds,reqs))) = no;

$endif.cattle
*
*   --- Ensure purchasing of maize for farms without arable when switched on
*
$iftheni.feedUse declared v_feeduse

$$iftheni.purchMaiz "%purchMaizSil%"=="true"
    curFeeds(feeds)$ sum(sameas(feeds,maizSilage),1) = yes;

    v_prods.up(prods,t_n(t,nCur))        $(sum(sameas(prods,maizSilage),1) $ (not sum(sameas(curCrops,maizSilage),1))) = +inf;
    v_buy.up(inputs,sys,t_n(tCur,nCur))  $ sum(sameas(inputs,maizSilage),1)       = +inf;
    v_feedUse.up(feeds,t_n(t,nCur))      $ sum(sameas(feeds,maizSilage),1)        = +inf;
    v_feedUseHerds.up(herds,feeds,t_n(t,nCur)) $ sum(sameas(feeds,maizSilage),1)  = +inf;

    v_feeding.up(actHerdsF(herds,breeds,feedRegime,reqsphase,m),feeds,t_n(t,nCur)) $  (sum(sameas(feeds,maizSilage),1)
                $ (p_reqsPhaseMonths(herds,breeds,feedRegime,reqsPhase,"DMMX")))  = +inf;

 $$else.purchMaiz

     v_prods.up(prods,t_n(t,nCur)) $ (sum(sameas(prods,maizSilage),1) $ (not sum(sameas(curCrops,maizSilage),1)))   = 0;
     v_buy.fx(inputs,sys,t_n(tCur,nCur))  $ sum(sameas(inputs,maizSilage),1)    = 0;

     v_feedUse.up(feeds,t_n(t,nCur)) $ (sum(sameas(feeds,maizSilage),1) $ (not sum(sameas(curCrops,maizSilage),1))) = 0;
     v_feedUseBuy.up(feeds,t_n(t,nCur)) $ sum(sameas(feeds,maizSilage),1)= 0;

     v_feeding.up(actHerdsF(herds,breeds,feedRegime,reqsphase,m),feeds,t_n(t,nCur))
         $ (sum(sameas(feeds,maizSilage),1) $ (not sum(sameas(curCrops,maizSilage),1))
             $ p_reqsPhaseMonths(herds,breeds,feedRegime,reqsPhase,"DMMX")) = 0;

     p_inputprice%l%(inputs,sys,t) $ sum(sameas(inputs,maizSilage),1) = 0;

 $$endif.purchMaiz

 $$iftheni.purchGrasSil not "%purchGrasSil%"=="true"

    v_prods.up(grasSil,t_n(t,nCur)) $ (not sum(c_p_t_i(crops,plot,till,intens),
                                    sum(plot_soil(plot,soil),p_OcoeffC(crops,soil,till,intens,grasSil,t)))) = 0;

    v_buy.up(inputs,sys,t_n(t,nCur)) $ sum(sameas(inputs,grasSil),1) = 0;
    v_feedUse.up(feeds,t_n(t,nCur))  $ (sum(sameas(feeds,grassil),1) $ (not sum(curProds(grasSil),1))) = 0;
    v_feedUseBuy.up(feeds,t_n(t,nCur))  $ sum(sameas(feeds,grassil),1) = 0;
    v_feeding.up(actHerdsF(herds,breeds,feedRegime,reqsphase,m),feeds,t_n(t,nCur))
        $ ( sum(sameas(feeds,grassil),1) $ (not sum(curProds(grasSil),1))
            $ p_reqsPhaseMonths(herds,breeds,feedRegime,reqsPhase,"DMMX")) = 0;

     p_inputprice%l%(inputs,sys,t) $ sum(sameas(inputs,grasSil),1) = 0;
 $$endif.purchGrasSil

* $$iftheni.alfalfa not "%purchAlfalfa%"=="true"
*
*      v_prods.up("Alfalfa",t_n(t,nCur)) $ (not curCrops("Alfalfa")) = 0;
*      v_buy.fx("Alfalfa",sys,t_n(t,nCur))  = 0;
*      v_feedUse.up("Alfalfa",t_n(t,nCur)) $ (not curCrops("Alfalfa")) = 0 = 0;
*      v_feedUseBuy.up("Alfalfa",t_n(t,nCur))  = 0;
*      v_feeding.up(actHerdsF(herds,breeds,feedRegime,reqsphase,m),"Alfalfa",t_n(t,nCur))
*         $ ( (not CurCrops("Alfalfa"))
*             $ p_reqsPhaseMonths(herds,breeds,feedRegime,reqsPhase,"DMMX")) = 0;
*
*     p_inputprice%l%("alfalfa",sys,t) = 0;
* $$endif.alfalfa

$endif.feedUse

$if defined v_feeding  option kill=v_feeding.m;


 curMachines(machType) = no;

 option kill=mach_to_branch;

 mach_to_branch(machType,branches)
   $ [  sum( (c_p_t_i(curCrops(crops),plot,till,intens),t_n(t,nCur),machLifeUnit)
             $ (branchlink_to_acts(branches,crops)
                $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0)),
                  p_machNeed(crops,till,intens,machType,machLifeUnit))

      + sum( (c_p_t_i(curCrops(crops),plot,till,intens),syntFertilizer,t_n(t,nCur),m,machLifeUnit)
             $ (branchlink_to_acts(branches,crops)
                $ (v_syntDist.up(crops,plot,till,intens,syntFertilizer,t,nCur,m) ne 0)),
                 p_machNeed(syntFertilizer,till,"normal",machType,machLifeUnit))

*     ---- machine need for the application of N (manure/fertilizer)

     $$iftheni.man "%manure%" == "true"

      + sum((c_p_t_i(curCrops(crops),plot,till,intens),manApplicType_manType(ManApplicType,curManType),
                            t_n(t,nCur),m,machLifeUnit)
              $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0),
                        p_machNeed(ManApplicType,"plough","normal",machType,machLifeUnit))
     $$endif.man
   ] = yes;

 mach_to_branch("roller","cashCrops")           = yes ;
 mach_to_branch("springTineHarrow","cashCrops") = yes ;
 $$ifthen.env  %agriEnvSchemes%==true
  mach_to_branch("mowerConditioner","cashCrops") = yes ;
 $$endif.env
$iftheni.herd "%herd%"=="true"

 mach_to_branch(machType,branches)
   $  [

*
      + sum((actHerds(sumHerds,breeds,feedRegime,t,m),machLifeUnit)
               $ (branchlink_to_acts(branches,sumherds) $ possHerds(sumHerds)),
                 p_machNeed(sumHerds,"plough","normal",machType,machLifeUnit))
      ] = YES;

   mach_to_branch(machType,branches)
        $ sum( (stables_to_mach(stables,machType),t_n(t1,nCur1))
            $ ( (v_stableInv.up(stables,"long",t1,nCur1) ne 0)
                 $ sum((branchlink_to_acts(branches,possHerds(sumherds)),breeds,stableTypes)
                    $ (p_stableNeed(sumHerds,breeds,stableTypes) and p_stableSize(stables,stableTypes)),1))
            ,1) = YES;

$endif.herd


 curMachines(machType) $ sum(mach_to_branch(machType,branches),1) = YES;
 curMachines(contractMachines) = no;

$iftheni.dyn not "%dynamics%"=="comparativ-static"
*
* --- that is important for calculation of the liquidation value
*
 curMachines(machType) $ (smax( tOld $ p_iniMachT(machType,told),
                                       p_year(tOld) + p_lifeTimeM(machType,"years")) ge p_Year("%lastYearCalc%")) = YES;

 curMachines(machType) $ sum(machLifeUnit, p_iniMach(machType,machLifeUnit)) = yes;
$endif.dyn

$ifi "%debugOutput%"=="true"  display curMachines;

 curInv(machType)      $ (not curMachines(machType))   = no;
 curInv(buildings)     $ (not curBuildings(buildings)) = no;

$iftheni.defStables defined v_buyStables

 curInv(stables)       $ (not sum( (t_n(tCur,nCur),hor) $ (v_buyStables.up(stables,hor,tCur,nCur) gt 0),1)) = no;
 curInv(stableTypes)   $ (not sum( (stables,t_n(tCur,nCur),hor) $ ((v_buyStables.up(stables,hor,tCur,nCur) gt 0) $ p_stableSize(stables,StableTypes)),1)) = no;

$endif.defStables


 curInputs(inputs) = no;

 curInputs(inputs) $ [

                sum( (c_p_t_i(curCrops(crops),plot,till,intens),t_n(t,nCur))
                      $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0),
                           p_costQuant(crops,till,intens,inputs))

          $$iftheni.cattle "%cattle%"=="true"

              + sum((sameas(inputs,feedsY),t_n(tCur,nCur)) $ ((v_feedUse.up(feedsY,tCur,nCur) ne 0) $ sum(sys $ p_inputprice%l%(inputs,sys,tCur),1)),1)

              $$ifi "%useMaleSexing%"  =="true"   + sum(sameas(inputs,"maleSexing"),1)
              $$ifi "%useFemaleSexing%"=="true"   + sum(sameas(inputs,"femaleSexing"),1)

              $$ifi "%buyHeifs%"=="true"        + sum(sameas(inputs,heifsBought),1)
              $$ifi "%buyYoungBulls%"=="true"   + sum(sameas(inputs,bullsBought),1)
              $$ifi "%buyCalvs%"=="true"        + sum(sameas(inputs,calvesBought),1)

              $$ifi "%purchMaizSil%"=="true"    + sum(sameas(inputs,"MaizSil"),1)
              $$ifi "%purchGrasSil%"=="true"    + sum(sameas(inputs,grasSil),1)

              $$ifi not "%bullsStableInv%"    =="slatted_floor" + sum(sameas(inputs,"straw"),1)
              $$ifi not "%cowStableInv%"      =="slatted_floor" + sum(sameas(inputs,"straw"),1)
              $$ifi not "%heifersStableInv%"  =="slatted_floor" + sum(sameas(inputs,"straw"),1)
              $$ifi not "%motherCowStableInv%"=="slatted_floor" + sum(sameas(inputs,"straw"),1)
          $$endif.cattle

          $$iftheni.sows "%farmBranchSows%"=="on"

              + 1 $ ( sum( (t_n(t,nCur),feedRegime,m) $ (v_herdSize.up("youngSows","",feedRegime,t,nCur,m) ne 0),1)
                                                                       $ sameas(inputs,"youngSow") )
          $$endif.sows
          $$iftheni.fat "%farmBranchFattners%"=="on"

              + 1 $ ( sum( (t_n(t,nCur),feedRegime,m) $ (v_herdStart.up("pigletsBought","",t,nCur,m) ne 0),1)
                                                                        $ sameas(inputs,"pigletsBought") )
          $$endif.fat

          $$iftheni.pigHerd "%pigHerd%"=="true"
              + sum ( (feedAttr,sameas(inputs,feedspig)) $ p_feedAttrPig(feedsPig,feedAttr), 1)

          $$endif.pigHerd

              + sum(  (c_p_t_i(curCrops(crops),plot,till,intens),sameas(inputs,syntFertilizer),t_n(t,nCur),m)
                       $ ( v_syntDist.up(crops,plot,till,intens,syntFertilizer,t,nCur,m) ne 0),1)

*        --- variable costs for diesel

              + 1 $ sameas(inputs,"diesel")

*        --- variable costs for biogas inputs (easy version)
         $$iftheni.biogas "%biogas%" == "true"

             + 1 $ sum(sameas(inputs,selpurchInputs),1)
         $$endif.biogas
              ] = yes;


  curInputs(inputs) $ ( (not sum( (sys,t_n(tCur,nCur)) $ (v_buy.up(inputs,sys,tCur,ncur) gt 0),1)) $ sum((sys,tCur),p_inputPrice%l%(inputs,sys,tCur))) = no;

 $$ifi "%allowHiring%"=="true" curInputs("hiredLabour") = yes;
 $$iftheni.sp "%stochProg%"=="true"
      $$iftheni.stochYield "%stochYields%"=="true"
          curInputs("cropIns") = YES;
      $$endif.stochYield
 $$endif.sp

$ifi "%debugOutput%"=="true"  display curInputs;


$if defined p_nut2InMan curManType(manType) $ (not sum( (nut2,manChain), p_nut2inMan("NTAN",manType,manChain))) = no;

$$ifi not defined biogasBranch set biogasBranch / biogas /;


 v_branchSize.up(branches,t_n(tCur,nCur))  $ ( (not sum(branches_to_acts(branches,possActs),1)) and (not sameas(branches,"biogas"))) = 0;
 v_hasbranch.up(branches,t_n(tCur,nCur))   $ ( (not sum(branches_to_acts(branches,possActs),1)) and (not sameas(branches,"biogas"))) = 0;
 v_hasbranch.up("cap",t_n(tCur,nCur))  = 1;

 p_maxBranch(branches,t_n(t,nCur)) = min(p_maxBranch(branches,t,nCur),
                                         sum((branches_to_acts(branches,curCrops(crops)),plot,till,intens)
                                          $( c_p_t_i(crops,plot,till,intens) $ (not catchcrops(crops) )
                                               $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0)),
                                             v_cropHa.up(crops,plot,till,intens,t,nCur))

                            $$iftheni.herd "%herd%" == "true"

                                  + sum( (branches_to_acts(branches,possHerds),breeds,feedRegime,m)
                                       $ (actHerds(possHerds,breeds,feedRegime,t,m) $ p_prodLength(possHerds,breeds)
                                           $ (v_herdSize.up(possHerds,breeds,feedRegime,t,nCur,m) ne inf)
                                       ),
                                           v_herdSize.up(possHerds,breeds,feedRegime,t,nCur,m)
                                              * 1/min(12,p_prodLength(possHerds,breeds))
                                           )
                            $$endif.herd
                                  );

p_maxBranch("cap",t_n(t,nCur)) = 1;


$iftheni.cattle "%cattle%"=="true"

 v_feedUseM.up(feedsM,m,t_n(tCur,nCur)) $ (v_feedUsem.up(feedsM,m,tCur,nCur) ne 0)
   = sum( (possHerds,breeds,feedRegime,reqsPhase) $ (p_reqsPhaseMonths(possHerds,breeds,feedRegime,reqsPhase,"DMMX")
                                                       $  actHerds(possHerds,breeds,feedRegime,tCur,m)),
                                          v_feeding.up(possHerds,breeds,feedRegime,reqsphase,m,feedsM,tCur,nCur));

 v_feedUseHerds.up(possHerds,feeds,t_n(tCur,nCur)) $ (v_feedUseHerds.up(possHerds,feeds,tCur,nCur) ne 0)
   = sum( (breeds,feedRegime,reqsPhase,m) $ (p_reqsPhaseMonths(possHerds,breeds,feedRegime,reqsPhase,"DMMX")
                                                           $ actHerds(possHerds,breeds,feedRegime,tCur,m)),
                                              v_feeding.up(possHerds,breeds,feedRegime,reqsphase,m,feeds,tCur,nCur));

 v_herdsReqsPhase.up(possHerds,breeds,feedRegime,reqsphase,m,t_n(tCur,nCur))
     $ (p_reqsPhase(possHerds,breeds,reqsPhase,"DMMX") and actHerds(possHerds,breeds,feedRegime,tCur,m))
        =  v_herdSize.up(possHerds,breeds,feedRegime,tCur,nCur,m);

 v_buy.up(curInputs,sys,t_n(tCur,nCur)) $ (sum(sameas(curInputs,feeds),1)
                                            and (v_buy.up(curInputs,sys,tCur,nCur) ne 0) and (not sameas(curInputs,"straw")))
     = sum(sameas(curInputs,feeds), v_feedUse.up(feeds,tCur,nCur));

$endif.cattle


$iftheni.manure "%manure%" == "true"

*
*   --- not more than 60 m3 per ha and month
*
    v_volManApplied.up(curManChain,t_n(t,nCur),m) $ ( v_volManApplied.up(curManChain,t,nCur,m) ne 0)
        = v_cropLandActive.up(t,nCur) * 60;

    v_manDist.up(c_p_t_i(curCrops,plot,till,intens),manApplicType_manType(manApplicType,curManType),t_n(tCur,nCur),m)
          $ (v_manDist.up(curCrops,plot,till,intens,manApplicType,curManType,tCur,nCur,m) ne 0)
      = v_cropHa.up(curCrops,plot,till,intens,tcur,nCur) * 60;
    option kill=v_manDist.m;
$endif.manure

*
*   --- specific bounds for differrent plots from interface
*
$$iftheni.PlotEndo  "%landEndo%" == "Land endowment per plot"

  v_syntDist.up(crops,plot,till,intens,syntFertilizer,t,nCur,m)
       $(p_plots(plot,"fert")=0)  
     = 0 ;

  $$iftheni.manure "%manure%" == "true"
    v_manDist.up(c_p_t_i(curCrops,plot,till,intens),manApplicType_manType(manApplicType,curManType),t_n(tCur,nCur),m)
          $(p_plots(plot,"fert")=0) 
     = 0;
  $$endif.manure
$$endif.PlotEndo