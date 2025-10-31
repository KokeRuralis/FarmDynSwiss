********************************************************************************
$ontext

   FARMDYN project

   GAMS file : REDUCE_VARS_FOR_MIP.GMS

   @purpose  : Heuristic rules to reduce # of variables in MIP model,
               based on RMIP solution

   @author   : Wolfgang Britz
   @date     : 24.09.14
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter.gms

$offtext
********************************************************************************
$include 'solve/setSolprint.gms'
$$ifi "%noSolprintHeuristics%" =="true"  m_farm.solprint = 2;
$$ifi "%StopPoint%"=="After heuristics"  m_farm.solprint = 1;

$batinclude 'util/title.gms' "'%titlePrefix% Heuristic to remove unused variables'"

alias(sys,sys1);
*
* --- remove inputs never used in RMIP
*
   $$iftheni.stochYields "%stochYields%"=="true"
      $$ifi "%cropInsurance%"=="true" curInputs("cropIns") = no;
   $$endif.stochYields

   v_buy.fx(curInputs,sys,t_n(tCur,nCur))     $ (not sum( (sys1,t1,nCur1) $ t_n(t1,nCur1), v_buy.l(curInputs,sys1,t1,nCur1))) = 0;
   v_buyCost.fx(curInputs,sys,t_n(tCur,nCur)) $ (not sum( (sys1,t1,nCur1) $ t_n(t1,nCur1), v_buy.l(curInputs,sys1,t1,nCur1))) = 0;

   $$iftheni.stochYields "%stochYields%"=="true"
      $$ifi "%cropInsurance%"=="true" curInputs("cropIns") = yes;
   $$endif.stochYields
*
* --- remove option to hire workers if never realized in RMIP
*
   v_hireWorkers.fx(t,nCur)      $ (t_n(t,nCur) $ (sum(t_n(t1,nCur1),v_hireWorkers.l(t1,nCur1)) eq 0)) = 0;
*
* --- remove buying of machines never bought
*
   v_buyMach.fx(machType,t,nCur) $ (t_n(t,nCur) $ (sum(t_n(t1,nCur1),v_buyMach.l(machType,t1,nCur1)) eq 0)

$iftheni.herd %herd% == true
                                     $ (not  sum(stables_to_mach(stables,machType)
                                                  $ (v_stableInv.up(stables,"long",t,nCur) eq 1),1))
$endif.herd
                                 ) = 0;


   v_buyMach.up(machType,tCur,nCur) $ (t_n(tCur,nCur) $ sum(t_n(t1,nCur1),v_buyMach.l(machType,t1,nCur1)))
                                                 = ceil(sMax(t_n(t1,nCur1),v_buyMach.l(machType,t1,nCur1)));

$setglobal flexLand false
$ifi %landBuy%==true   $setglobal flexLand false
$ifi %landLease%==true $setglobal flexLand false

$$ifthen.greening defined v_trigger10Ha
$$iftheni.flex %flexLand%==false

       v_trigger10Ha.fx(t,nCur) $ (t_n(t,nCur) $ (v_trigger10Ha.l(t,nCur) gt 1.E-5)) = 1;
       v_trigger15Ha.fx(t,nCur) $ (t_n(t,nCur) $ (v_trigger15Ha.l(t,nCur) gt 1.E-5)) = 1;
       v_trigger30Ha.fx(t,nCur) $ (t_n(t,nCur) $ (v_trigger30Ha.l(t,nCur) gt 1.E-5)) = 1;

$$endif.flex
$$endif.greening
$iftheni.herd %herd% == true

  v_herdSize.up(possHerds,breeds,feedRegime,t,nCur,m) $ (actHerds(possHerds,breeds,feedRegime,t,m)
               $ (not sum((t_n(t1,nCur1),m1) $ sameScen(nCur,nCur1), v_herdSize.l(possHerds,breeds,feedRegime,t1,nCur1,m1)))) = 0;

  v_herdStart.up(possHerds,breeds,t,nCur,m)
               $ ( (not sumHerds(possHerds))
                   $ (not sum((t_n(t1,nCur1),m1) $ sameScen(nCur,nCur1), v_herdStart.l(possHerds,breeds,t1,nCur1,m1)))) = 0;

*
  actHerds(herds,breeds,feedRegime,t,m)
   $  (    (sum(t_n(t,nCur) $ (v_herdSize.up(herds,breeds,feedRegime,t,nCur,m) ne 0),1)   eq 0)
        $  (sum(t_n(t,nCur) $ (v_herdStart.up(herds,breeds,t,nCur,m) ne 0),1)  eq 0)
      ) = no;

  actHerds(herds,breeds,feedRegime,tBefore,m) $ (not sum(t_n(t,nCur), actHerds(herds,breeds,feedRegime,t,m))) = no;

   $$iftheni.PH %farmBranchSows% == on
      v_herdSize.up("piglets",breeds,feedRegime,t,nCur,m) $ (t_n(t,nCur) $ actHerds("sows",breeds,feedRegime,t,m)) = inf;
      actHerds("piglets",breeds,feedRegime,t,m) $ actHerds("sows",breeds,feedRegime,t,m) = YES;
   $$endif.PH

  possHerds(herds) $ (not sum( (feedRegime,breeds,t,m), actHerds(herds,breeds,feedRegime,t,m))) = NO;
  possActs(herds)  $ (not sum( (feedRegime,breeds,t,m), actHerds(herds,breeds,feedRegime,t,m))) = NO;
$endif.herd

*
* --- some heuristics: assume that a type of animal which is not used in any year in RMIP mode
*                      will also not show up in any solution in MIP etc.
*
$iftheni.DH %cattle% == true

   v_herdSize.up(possHerds,breeds,feedRegime,t,nCur,m) $ ( (v_herdSize.range(possHerds,breeds,feedRegime,t,nCur,m) ne 0)
               $ actHerds(possHerds,breeds,feedRegime,t,m)    $ t_n(t,nCur)
               )
         = min(v_herdSize.up(possHerds,breeds,feedRegime,t,nCur,m),
              max(v_herdSize.lo(possHerds,breeds,feedRegime,t,nCur,m),
                 smax((t_n(t1,nCur1),m1) $ sameScen(nCur,nCur1), v_herdSize.l(possHerds,breeds,feedRegime,t1,nCur1,m1)  * 100.0)));

   v_herdStart.up(possHerds,breeds,t,nCur,m) $ ( (v_herdStart.range(possHerds,breeds,t,nCur,m) ne 0)
                $ sum(feedRegime,actHerds(possHerds,breeds,feedRegime,t,m)) $ t_n(t,nCur)
                 )
            =
                min(v_herdStart.up(possHerds,breeds,t,nCur,m),
                  max(v_herdStart.lo(possHerds,breeds,t,nCur,m)*1.1,
                     smax((t_n(t1,nCur1),m1) $ sameScen(nCur,nCur1),
                         v_herdStart.l(possHerds,breeds,t1,nCur1,m1)  * 100.0)));

   v_herdStart.up(possHerds,breeds,t,nCur,m)
      $ ((v_herdStart.up(possHerds,breeds,t,nCur,m) le 1.E-8)
          $ sum(feedRegime,actHerds(possHerds,breeds,feedRegime,t,m))  $ t_n(t,nCur)) = 0;

   v_herdSize.up(slgtCows,breeds,feedRegime,t,nCur,m) $ (actHerds(slgtCows,breeds,feedRegime,t,m) $ t_n(t,nCur))
      =  sum(cows $ (slgtCows.pos eq cows.pos), v_herdSize.up(cows,breeds,feedRegime,t,nCur,m));

   v_herdSize.up("cows",breeds,feedRegime,t,nCur,m)
     $ ((sum(cows, v_herdSize.up(cows,breeds,feedRegime,t,nCur,m)) eq 0) $ t_n(t,nCur) ) = 0;


$endif.DH


$iftheni.PH %pigHerd% == true

  v_herdSize.up(pigHerds,breeds,feedRegime,t,nCur,m) $ t_n(t,nCur)
       = max(min(v_herdSize.up(pigHerds,breeds,feedRegime,t,nCur,m),
                 smax((t_n(t1,nCur1),m1) $ sameScen(nCur,nCur1), v_herdSize.l(pigHerds,breeds,feedRegime,t1,nCur1,m1)  * 10)),
             min(v_herdStart.up(pigHerds,breeds,t,nCur,m),
                 smax((t_n(t1,nCur1),m1) $ sameScen(nCur,nCur1), v_herdStart.l(pigHerds,breeds,t1,nCur1,m1)  * 10)));

*
* --- Do not have fattners without preceding early, mid and late fattners
*
     $$iftheni.fattners "%farmBranchFattners%" == "on"
          $$ifi not set forceFattners $set forceFattners 100000
          $$ifthene.ff "%forceFattners%" == 0
             v_herdSize.up("midfattners","",feedRegime,"%firstYear%",nCur,m)   $ (t_n("%firstYear%",nCur) $ (ord(m) le 1)) = 0;
             v_herdSize.up("lateFattners","",feedRegime,"%firstYear%",nCur,m)  $ (t_n("%firstYear%",nCur) $ (ord(m) le 2)) = 0;
             v_herdSize.up("fattners","",feedRegime,"%firstYear%",nCur,m)      $ (t_n("%firstYear%",nCur) $ (ord(m) le 3)) = 0;
          $$endif.ff
     $$endif.fattners

     v_herdStart.up(pigHerds,breeds,t,nCur,m) $ (t_n(t,nCur) $ sum(feedRegime $ v_herdSize.up(pigHerds,breeds,feedRegime,t,nCur,m),1))
      =  smax(feedRegime $ (v_herdSize.up(pigHerds,breeds,feedRegime,t,nCur,m) ne inf),
                                                  v_herdSize.up(pigHerds,breeds,feedRegime,t,nCur,m));

$endif.PH

*
* --- exclude crop - plot - tillage - intensity combinaions never used in RMIP model
*
$setglobal updateCSTI true
$$ifi "%orgTill%"=="optional"    $setglobal updateCSTI false
$$ifi "%stochYields%"=="true"    $setglobal updateCSTI false
$ifi "%partialMIPSolve%"=="true" $setglobal updateCSTI true

$$iftheni.CSTI "%updateCSTI%"=="true"

      c_p_t_i(curCrops,plot,till,intens) $ (     (not (sameas(curCrops,"idle") or sameas(curCrops,"idleGras") or catchCrops(curCrops)))
                                             and (not sum( (t_n(tCur,nCur)), v_cropHa.l(curCrops,plot,till,intens,tCur,nCur)))) = NO;
*
* --- remove mineral fertilizer application in months where never applied
*
       v_syntDist.up(c_p_t_i(curCrops,plot,till,intens),syntFertilizer,t_n(tCur,nCur),m)
         $ ((sum((crops,plot1,till1,intens1) $ c_p_t_i(crops,plot1,till1,intens1),
                v_syntDist.l(crops,plot1,till,intens1,syntFertilizer,tCur,nCur,m)) eq 0) $ curInputs(syntFertilizer)) = 0;

$$endif.CSTI

$ifthen.man defined v_manDist
$ifi.carbTax defined p_carbonTax  if ( p_carbonTax eq 0,

   usedManTypeApplType(manApplicType_manType(manApplicType,curManType))  = YES;

   usedManTypeApplType(manApplicType,curManType) $ (manApplicType_manType(ManApplicType,curManType)
       $ (not sum( (c_p_t_i(curCrops,plot,till,intens),t_n(t,nCur),m),
            v_manDist.l(curCrops,plot,till,intens,manApplicType,curManType,t,nCur,m)))) = NO;
*
*   curManType(manType) $ (not sum(usedManTypeApplType(manApplicType,ManType),1)) = no;
*
*  --- remove manure fertilizer application in months where never applied
*
    v_manDist.up(c_p_t_i(curCrops,plot,till,intens),usedManTypeApplType(manApplicType,curManType),t_n(tCur,nCur),m)
           $ (sum((crops,plot1,till1,intens1) $ c_p_t_i(crops,plot1,till1,intens1),
                  v_manDist.l(crops,plot1,till1,intens1,manApplicType,curManType,tCur,nCur,m)) eq 0) = 0;

$ifi.carbTax defined p_carbonTax );
$endif.man

$iftheni.herd %herd% == true

*  $$if defined v_triggerStorageGVHa  v_triggerStorageGVha.fx(t_n(t,nCur)) $ (v_triggerStorageGVha.l(t,nCur) eq 0) = 0;

   $$iftheni.cattle %cattle% == true
*
      option kill=actHerdsF;
      actHerdsF(herds,breeds,feedRegime,reqsPhase,m) $ sum(tCur, actHerds(herds,breeds,feedRegime,tCur,m)) = YES;
      actHerdsF(herds,breeds,feedRegime,reqsPhase,m) $ ((not p_reqsPhaseMonths(herds,breeds,feedRegime,reqsPhase,"DMMX"))
        $ actHerdsF(herds,breeds,feedRegime,reqsPhase,m)) = NO;


      v_feeding.up(actHerdsF(herds,breeds,feedRegime,reqsphase,m),feeds,t_n(tCur,nCur)) $ (not possHerds(herds)) = 0;

      v_feeding.up( actHerdsF(possHerds,breeds,feedRegime,reqsPhase,m),feeds,t_n(tCur,nCur))
        = min(v_feeding.up(possHerds,breeds,feedRegime,reqsPhase,m,feeds,tcur,nCur),
           sum(actHerds(possHerds,breeds,feedRegime,tCur,m),
                                80/1000 * 30.5 * v_herdSize.up(possHerds,breeds,feedRegime,tCur,nCur,m)));


      parameter p_feedComb "Simulated feed combinations";

      p_feedComb(possHerds,breeds,feedRegime,reqsPhase,feeds ) $ sum(actHerdsF(possHerds,breeds,feedRegime,reqsPhase,m),1)
            =    sum( (t1,nCur1,m1) $ t_n(t1,nCur1),
                                                 v_feeding.l(possHerds,breeds,feedRegime,reqsPhase,m1,feeds,t1,nCur1));

      v_feeding.up( actHerdsF(possHerds,breeds,feedRegime,reqsphase,m),feeds,t_n(tCur,nCur))
         $ ((not p_feedComb(possHerds,breeds,feedRegime,reqsPhase,feeds))) = 0;


      v_feeduse.fx(feedsY,t_n(tCur,nCur))
         $ (not sum( actHerdsF(possHerds,breeds,feedRegime,reqsphase,m)
                       $ (v_feeding.up(possHerds,breeds,feedRegime,reqsphase,m,feedsY,tCur,nCur) gt 0),1)) = 0;
   $$endif.cattle

*
*  --- do not buy a new stable of a certain type if never an buying decision in that year or beyond
*      for the stable type (exlcuding the zero sized one)
*
   v_buyStablesF.up(stables,"long",t,nCur)
      $ ( sum(stableTypes $ (p_stableSize(stables,stableTypes) gt eps),1)
           $ (not sum((stables1,stableTypes,t_n(t1,nCur1)) $(v_buyStablesF.l(stables1,"long",t1,nCur1)
                     $ ( (p_stableSize(stables,stableTypes) gt eps) and (p_stableSize(stables1,stableTypes) gt eps))
                     $ sameScen(nCur1,nCur) $ (t1.pos ge t.pos)),1)) $ t_n(t,nCur) $ (v_buyStablesF.up(stables,"long",t,nCur) ne 0)) = 0;

   v_buyStablesF.up(stables,"middle",t,nCur)
      $ ( sum(stableTypes $ (p_stableSize(stables,stableTypes) gt eps),1)
           $ (not sum((stables1,stableTypes,t_n(t1,nCur1)) $(v_buyStablesF.l(stables1,"middle",t1,nCur1)
                     $ ( (p_stableSize(stables,stableTypes) gt eps) and (p_stableSize(stables1,stableTypes) gt eps))
                     $ sameScen(nCur1,nCur) $ (t1.pos ge t.pos)),1)) $ t_n(t,nCur) $ (v_buyStablesF.up(stables,"middle",t,nCur) ne 0)) = 0;

   v_buyStablesF.up(stables,"short",t,nCur)
      $ ( sum(stableTypes $ (p_stableSize(stables,stableTypes) gt eps),1)
          $ (not sum((stables1,stableTypes,t_n(t1,nCur1)) $(v_buyStablesF.l(stables1,"short",t1,nCur1)
                     $ ( (p_stableSize(stables,stableTypes) gt eps) and (p_stableSize(stables1,stableTypes) gt eps))
                     $ sameScen(nCur1,nCur) $ (t1.pos ge t.pos)),1)) $ t_n(t,nCur) $ (v_buyStablesF.up(stables,"short",t,nCur) ne 0)) = 0;

   v_buyStablesF.up(stables,hor,t,nCur) $ (t_n(t,nCur) $ (not p_priceStables(stables,hor,t))) = 0;

    v_buySilos.up(curManChain,silos,t,nCur)
       $ (  (silos.pos gt 2)
            $  (not sum((silos1,t_n(t1,nCur1)) $ ( v_buySilosF.l(curManChain,silos1,t1,nCur1)
                      $ ( (p_ManStorCapSi(silos1) gt eps) and (p_ManStorCapSi(silos) gt eps))
                      $ sameScen(nCur1,nCur) $ (t1.pos ge t.pos)),1)) $ t_n(t,nCur)) = 0;

    v_buySilosF.up(curManChain,silos,t,nCur) $ t_n(t,nCur) = v_buySilos.up(curManChain,silos,t,nCur);

$endif.herd


    v_buyBuildings.up(curBuildings,t,nCur)
       $ (  sum(buildCapac $ (p_building(curBuildings,buildCapac) gt eps),1) $ (v_buyBuildings.up(curBuildings,t,nCur) le 1)
            $  (not sum((buildings1,buildCapac,t_n(t1,nCur1)) $(v_buyBuildings.l(buildings1,t1,nCur1)
                      $ ( (p_building(buildings1,buildCapac) gt eps) and (p_building(curBuildings,buildCapac) gt eps))
                      $ sameScen(nCur1,nCur) $ (t1.pos ge t.pos)),1)) $ t_n(t,nCur)) = 0;

    v_buyBuildingsF.up(curBuildings,t,nCur) $ t_n(t,nCur) = v_buyBuildings.up(curBuildings,t,nCur);

$batinclude 'solve/set_derived_bounds.gms' test

    m_Farm.bRatio=0;
    solve m_farm using %RMIP% maximizing v_obje;
    $$ifi "%stochProg%"=="true" $include 'model/copy_stoch.gms'
    $$include 'solve/count_binaries.gms'
    $$batinclude 'solve/trackStat.gms' nHeu
    m_Farm.bRatio=0.25;
$batinclude 'solve/treat_infes.gms' %RMIP% "RMIP after heuristics"
   p_cutUpp = v_obje.l*1.001;
