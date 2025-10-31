********************************************************************************
$ontext

   FARMDYN project

   GAMS file : BINARY_FIXING.GMS

   @purpose  : Try to fix binary variable in RMIP mode to provide good
               starting point for final MIP solve

               The user should normally chose 6 steps. Only if it turns out
               that the RMIP model becomes infeasible or leads to very
               large drops in the objective, the # of steps should be reduced

   @author   : W. Britz
   @date     : 22.02.16
   @since    :

   @refDoc   :
   @seeAlso  : model/reduce_var_for_mip.gms
   @calledBy : exp_starter.gms

$offtext
********************************************************************************
$include 'solve/setSolprint.gms'
$$ifi "%noSolprintHeuristics%" =="true"  m_farm.solprint = 2;
$$ifi "%StopPoint%"=="After heuristics"  m_farm.solprint = 1;

   m_farm.bratio = 1.00;

   if ( p_cutLow eq -inf, p_cutLow = v_obje.l * 0.5);

   $$ifi defined v_buySilos     parameter p_buySilos;
   $$ifi defined v_buyBuildings parameter p_buyBuildings;
   $$ifi defined v_buyStables   parameter p_buyStables;
*
*  -- store the current levels and bounds for binary variables
*     the bounds will be reloaded later as the following code
*     will only temporary fix binaries to provide a good MIPSTART point
*
   $$ifthen.partialMIPSolve not "%partialMIPSolve%"=="true"
      execute_unload '%gams.scrdir%/beforeFixing.gdx'
        $$include "%gams.scrdir%binaries.gms"
      ;
   $$endif.partialMIPSolve
*
*  ---- the current RMIP solution serves as a fall back if none of the ones with
*       (partially) fixed binaries is better as no farm at all
*
   execute_unload "%gams.scrdir%/duringFixing.gdx" v_obje.l
               $$include "%gams.scrdir%binaries.gms"
       ;
*
   v_hasFarm.fx(t,nCur) $ (t_n(t,nCur) $ v_hasFarm.l(t,nCur)) = 1;
   v_hasBranch.fx(branches,t,nCur) $ (t_n(t,nCur) $ v_hasBranch.l(branches,t,nCur)) = 1;
   $$ifthen.definedOrg defined v_org

      v_org.fx   (t,nCur) $ (t_n(t,nCur) and (v_org.l(t,nCur) le 0.2)) = 0.0;
      v_org.fx   (t,nCur) $ (t_n(t,nCur) and (v_org.l(t,nCur) gt 0.8)) = 1.0;

   $$endif.definedOrg
*
   $$ifthen.buyStables defined v_buyStables
*
*       --- fix branch choice and restrict investments into stables
*           to two concave points matching chosen stable places bought
*
        $$include 'solve/bin_fix_stables.gms'
*
*       --- the include calls embedded Python code to count the number of binaries
*           not zero or unity. We only solve the model if that number has changed
*           That step is repeated multiple times below in the code
*
        $$include 'solve/count_binaries'
        if ( nOldFixedBinaries <> nRelaxedBinaries,
*
           $$batinclude 'util/title.gms' "'%titlePrefix% Solve model as %rmip%, heuristic binary fixing, stable fixed'"
           solve m_farm using %rmip% maximizing v_obje;
           $$ifi "%stochProg%"=="true" $include 'model/copy_stoch.gms'
*
*          --- small helper program which reports model statistics included
*              the number of not yet fixed binaries
*
           $$batinclude 'solve/trackStat.gms' "binStab"
      );
    $$endif.buyStables
*
*  --- fix choice of buildings and silo investments to points close to each other
*      on concave set, based on the amount of silo / building capacity bougt
*
   $$include 'solve/bin_fix_buildings.gms'
   $$include 'solve/count_binaries'
   if ( nOldFixedBinaries <> nRelaxedBinaries,
      $$batinclude 'util/title.gms' "'%titlePrefix% Solve model as %rmip%, heuristic binary fixing, buildings fixed'"
      solve m_farm using %rmip% maximizing v_obje;
      $$ifi "%stochProg%"=="true" $include 'model/copy_stoch.gms'
      $$batinclude 'solve/trackStat.gms' "binBuild"
   );

   $$ifthen.buySilos defined v_buySilos
     $$include 'solve/bin_fix_silos.gms'
     $$include 'solve/count_binaries'
     if ( nOldFixedBinaries <> nRelaxedBinaries,
         $$batinclude 'util/title.gms' "'%titlePrefix% Solve model as %rmip%, heuristic binary fixing, bunkerSilos fixed'"
         solve m_farm using %rmip% maximizing v_obje;
         $$ifi "%stochProg%"=="true" $include 'model/copy_stoch.gms'
         $$batinclude 'solve/trackStat.gms' "binSilo"
     );
   $$endif.buySilos

   $$ifthen.definedOrg defined v_org

      v_org.fx   (t,nCur) $ (t_n(t,nCur) and (v_org.l(t,nCur) le 0.2)) = 0.0;
      v_org.fx   (t,nCur) $ (t_n(t,nCur) and (v_org.l(t,nCur) gt 0.8)) = 1.0;

   $$endif.definedOrg

   $$ifi "%allowHiring%"=="true" v_hireWorkers.fx(t_n(tcur,nCur)) = round(v_hireWorkers.l(tCur,nCur));v_hireWorkers.l(t_n(tcur,nCur))=v_hireWorkers.up(tCur,nCur) ;

   $$ifi defined v_triggerStorageGVHa  v_triggerStorageGVha.fx(t_n(t,nCur)) $  v_triggerStorageGVha.l(t,nCur) = 1;
*
*   --- fix first investment point for machinery if at least 1/2 machine is bought in total
*
    v_buyMach.fx(machType,t,nCur) $ (t_n(t,nCur)
       $ (t.pos eq smin(t_n(t1,nCur1) $ ((v_buyMach.l(machType,t1,nCur1) gt 0.0) $ sameScen(nCur,nCur1)), t1.pos))
                $ (  (sum(t_n(t1,nCur1) $ sameScen(nCur,nCur1), v_buyMach.l(machType,t1,nCur1)) gt 0.75)
          $$ifi defined v_buyStables or  (sum(t_n(t1,nCur1) $ sameScen(nCur,nCur1), sum(stables_to_mach(stables,machType), v_stableUsed.l(stables,t1,nCur1))) gt 0.1)
                )) = ceil(v_buyMach.l(machType,t,nCur));

    v_buyMach.l(machType,t_n(t,ncur)) $ ( v_buyMach.range(machType,t,nCur) eq 0) = v_buyMach.up(machType,t,nCur);

    v_rentOutPlotNew.fx(plot,t,nCur) $ (t_n(t,nCur) $ (v_rentoutPlot.l(plot,t,nCur) lt 0.2)) = 0;
    v_rentOutPlotNew.fx(plot,t,nCur) $ (t_n(t,nCur) $ (v_rentoutPlot.l(plot,t,nCur) ge 0.8)) = 1;

   $$if defined v_switchBioGas   v_switchBioGas.fx(curBhkw,curEeg,curEeg1,tcur,nCur) $ (t_n(tCur,nCur) $ (v_switchBioGas.l(curBhkw,curEeg,curEeg1,tcur,nCur) gt 0.5))  = 1;
   $$if defined v_invBioGas      v_invBioGas.fx(curBhkw,curEeg,tcur,nCur)            $ (t_n(tCur,nCur) $ (v_invBioGas.l(curBhkw,curEeg,tcur,nCur)            gt 0.5))  = 1;
   $$if defined v_useBioGasPlant v_useBioGasPlant.fx(curBhkw,curEeg,tcur,nCur)       $ (t_n(tCur,nCur) $ (v_useBioGasPlant.l(curBhkw,curEeg,tcur,nCur)       gt 0.5))  = 1;
   $$if defined v_buyBioGasPlant v_buyBioGasPlant.fx(curbhkw,cureeg,ih,tcur,nCur)    $ (t_n(tCur,nCur) $ (v_buyBioGasPlant.l(curBhkw,curEeg,ih,tcur,nCur)    gt 0.5))  = 1;
   $$if defined v_buyBioGasPlantParts v_buyBioGasPlantParts.fx(curbhkw,ih,tCur,nCur) $ (t_n(tCur,nCur) $ (v_buyBioGasPlantParts.l(curBhkw,ih,tcur,nCur)      gt 0.5))  = 1;

   $$ifthen.greening defined v_triggerGreening
       v_triggerGreening.fx(greeningTriggers,t_n(tCur,nCur)) $ (v_triggerGreening.l(greeningTriggers,tCur,nCur) gt 1.E-5) = 1;
       v_triggerGreening.fx(greeningTriggers,t_n(tCur,nCur)) $ (v_triggerGreening.l(greeningTriggers,tCur,nCur) lt 1.E-5) = 0;
   $$endif.greening

   $$ifthen.aes defined v_triggerAes
       v_triggerAes.fx(aesTriggers,triggerAesDim,t_n(tCur,nCur)) $ (v_triggerAes.l(aesTriggers,triggerAesDim,tCur,nCur) gt 1.E-6) =   1;
   $$endif.aes

   $$include 'solve/count_binaries'
   if ( nOldFixedBinaries <> nRelaxedBinaries,
      $$batinclude 'util/title.gms' "'%titlePrefix% Solve model as %rmip%, heuristic binary fixing, first round'"
      solve m_farm using %rmip% maximizing v_obje;
      $$ifi "%stochProg%"=="true" $include 'model/copy_stoch.gms'
      $$batinclude 'solve/trackStat.gms' "bin1"

      if ( m_farm.modelstat ne 1, v_obje.l = 0);
      if ( (v_obje.l gt p_cutlow),
*
*           ---- if the new solution if better than having no farm at all,
*                store for later use of binary levels for final solve
*
          execute_unload "%gams.scrdir%/duringFixing.gdx" v_obje.l,p_trackstat
              $$include "%gams.scrdir%binaries.gms"
          ;
      );
      execerror = 0;
   );

   $$ifi defined v_npvAtRisk  v_npvAtRisk.l(nCur)$ t_n("%lastYearCalc%",nCur) = 1 $ (v_objeN(nCur) lt p_npvAtRiskLim );
*
*
*  ---- we have that condition several times: move to next step of fixing if current solution is better
*       than having no farm at all
*
   if ( (v_obje.l gt p_cutlow) $ (%nHeuristicFixing%>1),

      $$ifi "%solver%"=="OSICPLEX" envAcc=1;
      $$ifthen.definedOrg defined v_org

         v_org.fx   (t,nCur) $ (t_n(t,nCur) and (v_org.l(t,nCur) le 0.3)) = 0.0;
         v_org.fx   (t,nCur) $ (t_n(t,nCur) and (v_org.l(t,nCur) gt 0.7)) = 1.0;

      $$endif.definedOrg

      v_rentOutPlotNew.fx(plot,t,nCur) $ (t_n(t,nCur) $ (v_rentoutPlot.l(plot,t,nCur) lt 0.3))  = 0;
      v_rentOutPlotNew.fx(plot,t,nCur) $ (t_n(t,nCur) $ (v_rentoutPlot.l(plot,t,nCur) ge 0.7))  = 1;

      $$ifthen.aes defined v_triggerAes
          v_triggerAes.fx(aesTriggers,triggerAesDim,t_n(tCur,nCur)) $ (v_triggerAes.l(aesTriggers,triggerAesDim,tCur,nCur) gt 1.E-6) =   1;
          v_triggerAes.fx(aesTriggers,triggerAesDim,t_n(tCur,nCur)) $ (v_triggerAes.l(aesTriggers,triggerAesDim,tCur,nCur) lt 1.E-6) =   0;
      $$endif.aes

      $$ifi defined v_triggerStorageGVHa  v_triggerStorageGVha.fx(t_n(t,nCur)) $  v_triggerStorageGVha.l(t,nCur) = 1;
      $$if defined v_hasAlwaysHerd   v_hasAlwaysHerd.fx(nCur) $ v_hasAlwaysHerd.l(nCur)      = 1;
      v_hasFarm.fx(t,nCur) $ (t_n(t,nCur) $ v_hasFarm.l(t,nCur)) = 1;
      v_hasBranch.fx(branches,t,nCur) $ (t_n(t,nCur) $ v_hasBranch.l(branches,t,nCur)) = 1;


      $$if defined v_switchBioGas   v_switchBioGas.fx(curBhkw,curEeg,curEeg1,tcur,nCur) $ (t_n(tCur,nCur) $ (v_switchBioGas.l(curBhkw,curEeg,curEeg1,tcur,nCur) le 0.5))  = 0;
      $$if defined v_invBioGas      v_invBioGas.fx(curBhkw,curEeg,tcur,nCur)            $ (t_n(tCur,nCur) $ (v_invBioGas.l(curBhkw,curEeg,tcur,nCur)            le 0.5))  = 0;
      $$if defined v_useBioGasPlant v_useBioGasPlant.fx(curBhkw,curEeg,tcur,nCur)       $ (t_n(tCur,nCur) $ (v_useBioGasPlant.l(curBhkw,curEeg,tcur,nCur)       le 0.5))  = 0;
      $$if defined v_buyBioGasPlant v_buyBioGasPlant.fx(curbhkw,cureeg,ih,tcur,nCur)    $ (t_n(tCur,nCur) $ (v_buyBioGasPlant.l(curBhkw,curEeg,ih,tcur,nCur)    le 0.5))  = 0;
      $$if defined v_buyBioGasPlantParts v_buyBioGasPlantParts.fx(curbhkw,ih,tCur,nCur) $ (t_n(tCur,nCur) $ (v_buyBioGasPlantParts.l(curBhkw,ih,tcur,nCur)      le 0.5))  = 0;

      v_buyMach.fx(machType,t,nCur) $ (t_n(t,nCur)
          $ (t.pos eq smin(t_n(t1,nCur1) $ ((v_buyMach.l(machType,t1,nCur1) gt 0.0) $ sameScen(nCur,nCur1) $ (v_buyMach.range(machType,t1,nCur1) ne 0)), t1.pos))
               $ (sum(t_n(t1,nCur1) $ (sameScen(nCur,nCur1) $ (v_buyMach.range(machType,t1,nCur1) ne 0)), v_buyMach.l(machType,t1,nCur1)) gt 0.50))
                   = round(v_buyMach.l(machType,t,nCur));

      v_buyMach.l(machType,t_n(t,ncur)) $ ( v_buyMach.range(machType,t,nCur) eq 0) = v_buyMach.up(machType,t,nCur);

      $$ifi defined v_npvAtRisk  v_npvAtRisk.l(nCur)$ t_n("%lastYearCalc%",nCur) = 1 $ (v_objeN(nCur) lt p_npvAtRiskLim );
      $$include 'solve/count_binaries'
      if ( nOldFixedBinaries <> nRelaxedBinaries,
         $$batinclude 'util/title.gms' "'%titlePrefix% Solve model as %rmip%, heuristic binary fixing, second round'"
         solve m_farm using %rmip% maximizing v_obje;
         $$ifi "%stochProg%"=="true" $include 'model/copy_stoch.gms'
         if ( m_farm.modelstat ne 1, v_obje.l = 0);
         $$batinclude 'solve/trackStat.gms' "bin2"
         execerror = 0;
         if ( (v_obje.l gt p_cutlow),
            execute_unload "%gams.scrdir%/duringFixing.gdx" v_obje.l,p_trackstat
              $$include "%gams.scrdir%binaries.gms"
           ;
         );
      );
*
*     --- do not continue if solution drops below what can be earned without a farm
*
      if ( (v_obje.l gt p_cutlow) $ (%nHeuristicFixing%>2),
         v_hasFarm.fx(t,nCur) $ (t_n(t,nCur) $ v_hasFarm.l(t,nCur)) = 1;
         v_hasBranch.fx(branches,t,nCur) $ (t_n(t,nCur) $ v_hasBranch.l(branches,t,nCur)) = 1;

         $$ifthen.definedOrg defined v_org

           v_org.fx   (t,nCur) $ (t_n(t,nCur) and (v_org.l(t,nCur) le 0.4)) = 0.0;
           v_org.fx   (t,nCur) $ (t_n(t,nCur) and (v_org.l(t,nCur) gt 0.6)) = 1.0;

         $$endif.definedOrg
         $$ifi defined v_triggerStorageGVHa  v_triggerStorageGVha.fx(t_n(t,nCur)) $  v_triggerStorageGVha.l(t,nCur) = 1;
*
*        --- try fix machines in later time points
*
         v_buyMach.fx(machType,t,nCur) $ (t_n(t,nCur)
               $ (t.pos eq smin(t_n(t1,nCur1)
                                   $ ((v_buyMach.l(machType,t1,nCur1) gt 0.0)
                                   $  (v_buyMach.range(machType,t1,nCur1) ne 0.0) $ sameScen(nCur,nCur1)), t1.pos))
                                   $  (sum(t_n(t1,nCur1) $ ((v_buyMach.range(machType,t1,nCur1) ne 0.0) $ sameScen(nCur,nCur1)),
                                                               v_buyMach.l(machType,t1,nCur1)) ge 0.50)
                                              $ (v_buyMach.range(machType,t,nCur) ne 0)) = round(v_buyMach.l(machType,t,nCur));

         v_buyMach.l(machType,t_n(t,ncur)) $ ( v_buyMach.range(machType,t,nCur) eq 0) = v_buyMach.up(machType,t,nCur);
*
*        --- exclude work options which require more hours than the combined total off farm simulated
*
         v_labOff.fx(t,nCur,workOpps) $ (t_n(t,nCur) $ (p_workTimeLost(workOpps) gt
                         smin(workOpps1 $ (p_workTimeLost(workOpps1) gt v_labOffFixed.l(t,nCur)),
                                           p_workTimeLost(workOpps1)))) = 0;

         v_labOff.fx(t,nCur,workOpps) $ (t_n(t,nCur) $ ( (v_labOff.l(t,nCur,workOpps) lt 0.1) $ v_labOff.l(t,nCur,workOpps))) = 0;
*
*                 --- fix off farm options if to more than 90% realised
*
         $$offorder
         v_labOff.fx(t,nCur,workOpps) $ (  (t_n(t,nCur) $ (v_labOff.l(t,nCur,workOpps+1) gt p_workTimeLost(workOpps)/p_workTimeLost(workOpps+1))
                                                      $  (v_labOff.l(t,nCur,workOpps+1) ne 1)) $ p_workTimeLost(workOpps+1)) = 1;
        $$onorder

        v_labOff.l(t_n(t,nCur),workOpps) $ (v_labOff.range(t,nCur,workOpps) eq 0) = v_labOff.up(t,nCur,workOpps);
        v_labOffB.l(t_n(t,nCur)) = 1 $ sum(workOpps(workType) $ v_labOff.l(t,nCur,workType),1);

        $$ifi defined v_npvAtRisk  v_npvAtRisk.l(nCur)$ t_n("%lastYearCalc%",nCur) = 1 $ (v_objeN(nCur) lt p_npvAtRiskLim );
        $$include 'solve/count_binaries'
        if ( nOldFixedBinaries <> nRelaxedBinaries,

           $$batinclude 'util/title.gms' "'%titlePrefix% Solve model as %rmip%, heuristic binary fixing, third round'"
           solve m_farm using %rmip% maximizing v_obje;
           $$ifi "%stochProg%"=="true" $include 'model/copy_stoch.gms'
           if ( m_farm.modelstat ne 1, v_obje.l = 0);
           $$batinclude 'solve/trackStat.gms' "bin3"
           execerror = 0;
           if ( (v_obje.l gt p_cutlow),
               v_labOffB.l(t,nCur) $ sum(workOpps(workType), v_labOff.l(t,nCur,workType)) = 1;
               execute_unload "%gams.scrdir%/duringFixing.gdx" v_obje.l,p_trackstat
                   $$include "%gams.scrdir%binaries.gms"
               ;
           );
        );

        if ( (v_obje.l gt p_cutlow) $ (%nHeuristicFixing%>3),

            v_hasFarm.fx(t,nCur) $ (t_n(t,nCur) $ v_hasFarm.l(t,nCur)) = 1;
            v_hasBranch.fx(branches,t,nCur) $ (t_n(t,nCur) $ v_hasBranch.l(branches,t,nCur))    = 1;

            v_buyMach.fx("tractor",t,nCur) $ (t_n(t,nCur)
                $ (t.pos eq smin(t_n(t1,nCur1) $ ((v_buyMach.l("tractor",t1,nCur1) gt 0.05) $ sameScen(nCur,nCur1) $ (v_buyMach.range("tractor",t1,nCur1) ne 0)), t1.pos))
                         $ (sum(t_n(t1,nCur1) $ (sameScen(nCur,nCur1) $ (v_buyMach.range("tractor",t1,nCur1) ne 0)), v_buyMach.l("tractor",t1,nCur1)) gt 0.00)) = 1;

            v_buyMach.fx("tractorSmall",t,nCur) $ (t_n(t,nCur)
                $ (t.pos eq smin(t_n(t1,nCur1) $ ((v_buyMach.l("tractorSmall",t1,nCur1) gt 0.05) $ sameScen(nCur,nCur1) $ (v_buyMach.range("tractorSmall",t1,nCur1) ne 0)), t1.pos))
                         $ (sum(t_n(t1,nCur1) $ (sameScen(nCur,nCur1) $ (v_buyMach.range("tractorSmall",t1,nCur1) ne 0)), v_buyMach.l("tractorSmall",t1,nCur1)) gt 0.00)) = 1;

            v_buyMach.l(machType,t_n(t,ncur)) $ ( v_buyMach.range(machType,t,nCur) eq 0) = v_buyMach.up(machType,t,nCur);

            v_buyMach.fx(machType,t,nCur) $ (t_n(t,nCur)
                  $ (t.pos eq smin(t_n(t1,nCur1)$ ((v_buyMach.l(machType,t1,nCur1) gt 0.0) $ sameScen(nCur,nCur1)
                                                   $ (v_buyMach.range(machType,t1,nCur1) ne 0.0)), t1.pos))
                                                 $ (sum(t_n(t1,nCur1) $ ((v_buyMach.range(machType,t1,nCur1) ne 0.0) $ sameScen(nCur,nCur1)),
                                                                                        v_buyMach.l(machType,t1,nCur1)) ge 0.05)
                                                 $ (v_buyMach.range(machType,t,nCur) ne 0)) = 1;
               v_buyMach.l(machType,t_n(t,ncur)) $ ( v_buyMach.range(machType,t,nCur) eq 0) = v_buyMach.up(machType,t,nCur);

            $$ifthen.definedOrg defined v_org

              v_org.fx   (t,nCur) $ (t_n(t,nCur) and (v_org.l(t,nCur) le 0.60)) = 0.0;
              v_org.fx   (t,nCur) $ (t_n(t,nCur) and (v_org.l(t,nCur) gt 0.60)) = 1.0;

            $$endif.definedOrg
*
*           --- fix off farm options if to more than 90% realised
*
            $$offorder
            v_labOff.fx(t,nCur,workOpps) $ (  (t_n(t,nCur) $ (v_labOff.l(t,nCur,workOpps+1) gt p_workTimeLost(workOpps)/p_workTimeLost(workOpps+1))
                                                      $  (v_labOff.l(t,nCur,workOpps+1) ne 1)) $ p_workTimeLost(workOpps+1)) = 1;
            $$onorder
            v_labOff.l(t_n(t,nCur),workOpps) $ (v_labOff.range(t,nCur,workOpps) eq 0) = v_labOff.up(t,nCur,workOpps);
            v_labOffB.l(t_n(t,nCur)) = 1 $ sum(workOpps(workType) $ v_labOff.l(t,nCur,workType),1);

            $$ifi defined v_npvAtRisk  v_npvAtRisk.l(nCur)$ t_n("%lastYearCalc%",nCur) = 1 $ (v_objeN(nCur) lt p_npvAtRiskLim );
            $$include 'solve/count_binaries'
            if ( nOldFixedBinaries <> nRelaxedBinaries,
               $$batinclude 'util/title.gms' "'%titlePrefix% Solve model as %rmip%, heuristic binary fixing, fourth round'"
               solve m_farm using %rmip% maximizing v_obje;
               $$ifi "%stochProg%"=="true" $include 'model/copy_stoch.gms'
               if ( m_farm.modelstat ne 1, v_obje.l = 0);
               $$batinclude 'solve/trackStat.gms' "bin4"
               execerror = 0;
               if ( (v_obje.l gt p_cutlow),
                   v_labOffB.l(t,nCur) $ sum(workOpps(workType), v_labOff.l(t,nCur,workType)) = 1;
                   execute_unload "%gams.scrdir%/duringFixing.gdx" v_obje.l,p_trackstat
                       $$include "%gams.scrdir%binaries.gms"
                   ;
               );
            );
*
*           --- do not continue if solution drops below what can be earned without a farm
*
            if ( (v_obje.l gt p_cutlow)  $ (%nHeuristicFixing%>4),
               v_hasFarm.fx(t,nCur) $ (t_n(t,nCur) $ v_hasFarm.l(t,nCur)) = 1;
               v_hasBranch.fx(branches,t,nCur) $ (t_n(t,nCur) $ v_hasBranch.l(branches,t,nCur)) = 1;

               $$if defined v_switchBioGas   v_switchBioGas.fx(curBhkw,curEeg,curEeg1,tcur,nCur) $ (t_n(tCur,nCur) $ (v_switchBioGas.l(curBhkw,curEeg,curEeg1,tcur,nCur) le 0.5))  = 0;
               $$if defined v_invBioGas      v_invBioGas.fx(curBhkw,curEeg,tcur,nCur)            $ (t_n(tCur,nCur) $ (v_invBioGas.l(curBhkw,curEeg,tcur,nCur)            le 0.5))  = 0;
               $$if defined v_useBioGasPlant v_useBioGasPlant.fx(curBhkw,curEeg,tcur,nCur)       $ (t_n(tCur,nCur) $ (v_useBioGasPlant.l(curBhkw,curEeg,tcur,nCur)       le 0.5))  = 0;
               $$if defined v_buyBioGasPlant v_buyBioGasPlant.fx(curbhkw,cureeg,ih,tcur,nCur)    $ (t_n(tCur,nCur) $ (v_buyBioGasPlant.l(curBhkw,curEeg,ih,tcur,nCur)    le 0.5))  = 0;
               $$if defined v_buyBioGasPlantParts v_buyBioGasPlantParts.fx(curbhkw,ih,tCur,nCur) $ (t_n(tCur,nCur) $ (v_buyBioGasPlantParts.l(curBhkw,ih,tcur,nCur)      le 0.5))  = 0;

               v_buyMach.fx(machType,t,nCur) $ (t_n(t,nCur)
                  $ (t.pos eq smin(t_n(t1,nCur1)$ ((v_buyMach.l(machType,t1,nCur1) gt 0.0) $ sameScen(nCur,nCur1)
                                                   $ (v_buyMach.range(machType,t1,nCur1) ne 0.0)), t1.pos))
                                                 $ (sum(t_n(t1,nCur1) $ ((v_buyMach.range(machType,t1,nCur1) ne 0.0) $ sameScen(nCur,nCur1)),
                                                                                        v_buyMach.l(machType,t1,nCur1)) ge 0.025)
                                                 $ (v_buyMach.range(machType,t,nCur) ne 0)) = 1;
               v_buyMach.l(machType,t_n(t,ncur)) $ ( v_buyMach.range(machType,t,nCur) eq 0) = v_buyMach.up(machType,t,nCur);
*
               v_labOff.fx(t,nCur,workOpps) $ (t_n(t,nCur) $ (v_labOff.l(t,nCur,workOpps) lt 0.1) $ v_labOff.l(t,nCur,workOpps))  = 0;
*
*              --- fix off farm options if to more than 90% realised
*
               $$offorder
               v_labOff.fx(t,nCur,workOpps) $ (  (t_n(t,nCur) $ (v_labOff.l(t,nCur,workOpps+1) gt p_workTimeLost(workOpps)/p_workTimeLost(workOpps+1))
                                                      $  (v_labOff.l(t,nCur,workOpps+1) ne 1)) $ p_workTimeLost(workOpps+1)) = 1;
               $$onorder
               v_labOff.l(t_n(t,nCur),workOpps) $ (v_labOff.range(t,nCur,workOpps) eq 0) = v_labOff.up(t,nCur,workOpps);
               v_labOffB.l(t_n(t,nCur)) = 1 $ sum(workOpps(workType) $ v_labOff.l(t,nCur,workType),1);

               $$ifi defined v_npvAtRisk  v_npvAtRisk.l(nCur)$ t_n("%lastYearCalc%",nCur) = 1 $ (v_objeN(nCur) lt p_npvAtRiskLim );
               $$include 'solve/count_binaries'
               if ( nOldFixedBinaries <> nRelaxedBinaries,
                  $$batinclude 'util/title.gms' "'%titlePrefix% Solve model as %rmip%, heuristic binary fixing, fifth round'"
                  solve m_farm using %rmip% maximizing v_obje;
                  $$ifi "%stochProg%"=="true" $include 'model/copy_stoch.gms'
                  if ( m_farm.modelstat ne 1, v_obje.l = 0);
                  execerror = 0;
                  $$batinclude 'solve/trackStat.gms' "bin5"
                  v_labOffB.l(t,nCur) $ sum(workOpps(workType), v_labOff.l(t,nCur,workType)) = 1;
                  if ( (v_obje.l gt p_cutlow),
                     execute_unload "%gams.scrdir%/duringFixing.gdx" v_obje.l,p_trackstat
                        $$include "%gams.scrdir%binaries.gms"
                     ;
                  );
               );
*
*              --- do not continue if solution drops below what can be earned without a farm
*
               if ( (v_obje.l gt p_cutlow)  $ (%nHeuristicFixing%>5),
                  v_hasFarm.fx(t,nCur) $ (t_n(t,nCur) $ v_hasFarm.l(t,nCur)) = 1;
                  v_hasBranch.fx(branches,t,nCur) $ (t_n(t,nCur) $ v_hasBranch.l(branches,t,nCur)) = 1;

                  $$if defined v_switchBioGas   v_switchBioGas.fx(curBhkw,curEeg,curEeg1,tcur,nCur) $ (t_n(tCur,nCur) $ (v_switchBioGas.l(curBhkw,curEeg,curEeg1,tcur,nCur) le 0.5))  = 0;
                  $$if defined v_invBioGas      v_invBioGas.fx(curBhkw,curEeg,tcur,nCur)            $ (t_n(tCur,nCur) $ (v_invBioGas.l(curBhkw,curEeg,tcur,nCur)            le 0.5))  = 0;
                  $$if defined v_useBioGasPlant v_useBioGasPlant.fx(curBhkw,curEeg,tcur,nCur)       $ (t_n(tCur,nCur) $ (v_useBioGasPlant.l(curBhkw,curEeg,tcur,nCur)       le 0.5))  = 0;
                  $$if defined v_buyBioGasPlant v_buyBioGasPlant.fx(curbhkw,cureeg,ih,tcur,nCur)    $ (t_n(tCur,nCur) $ (v_buyBioGasPlant.l(curBhkw,curEeg,ih,tcur,nCur)    le 0.5))  = 0;
                  $$if defined v_buyBioGasPlantParts v_buyBioGasPlantParts.fx(curbhkw,ih,tCur,nCur) $ (t_n(tCur,nCur) $ (v_buyBioGasPlantParts.l(curBhkw,ih,tcur,nCur)      le 0.5))  = 0;
*
*                 --- that seems to be sensitive statements which can lower the objective dramatically
*                     we therefore only keep that solution if it does not reduce the objective by more then 10%
*
                  v_buyMach.fx(machType,t,nCur) $ (t_n(t,nCur)
                       $ (sum(t_n(t1,nCur1) $ sameScen(nCur,nCur1), v_buyMach.l(machType,t1,nCur1)) le 0.01)
                                            $ (v_buyMach.range(machType,t,nCur) ne 0) ) = 0;

                  v_buyMach.fx(machType,t,nCur) $ (t_n(t,nCur)
                     $ (t.pos eq smin(t_n(t1,nCur1)$ ((v_buyMach.l(machType,t1,nCur1) gt 0.0) $ sameScen(nCur,nCur1)
                                                      $ (v_buyMach.range(machType,t1,nCur1) ne 0.0)), t1.pos))
                                                    $ (sum(t_n(t1,nCur1) $ ((v_buyMach.range(machType,t1,nCur1) ne 0.0) $ sameScen(nCur,nCur1)),
                                                                                           v_buyMach.l(machType,t1,nCur1)) ge 0.01)
                                                    $ (v_buyMach.range(machType,t,nCur) ne 0)) = 1;

                  v_buyMach.fx(machType,t,nCur) $ (t_n(t,nCur) $ (v_buyMach.l(machType,t,nCur) le 0.01)) = 0;
                  v_buyMach.l(machType,t_n(t,ncur)) $ ( v_buyMach.range(machType,t,nCur) eq 0) = v_buyMach.up(machType,t,nCur);
*
                  v_labOff.fx(t,nCur,workOpps) $ (t_n(t,nCur) $ (v_labOff.l(t,nCur,workOpps) lt 0.1) $ v_labOff.l(t,nCur,workOpps))  = 0;
                  $$offorder
                  v_labOff.fx(t,nCur,workOpps) $ ( ( t_n(t,nCur) $ (v_labOff.l(t,nCur,workOpps+1) gt p_workTimeLost(workOpps)/p_workTimeLost(workOpps+1))
                                                      $  (v_labOff.l(t,nCur,workOpps+1) ne 1)) $ p_workTimeLost(workOpps+1)) = 1;
                  $$onorder
                  v_labOff.l(t_n(t,nCur),workOpps) $ (v_labOff.range(t,nCur,workOpps) eq 0) = v_labOff.up(t,nCur,workOpps);
                  v_labOffB.l(t_n(t,nCur)) = 1 $ sum(workOpps(workType) $ v_labOff.l(t,nCur,workType),1);

                  $$ifi defined v_npvAtRisk  v_npvAtRisk.l(nCur)$ t_n("%lastYearCalc%",nCur) = 1 $ (v_objeN(nCur) lt p_npvAtRiskLim );
                  $$include 'solve/count_binaries'
                  if ( nOldFixedBinaries <> nRelaxedBinaries,
                     $$batinclude 'util/title.gms' "'%titlePrefix% Solve model as %rmip%, heuristic binary fixing, sixth round'"
                     solve m_farm using %rmip% maximizing v_obje;
                     $$ifi "%stochProg%"=="true" $include 'model/copy_stoch.gms'
                     if ( m_farm.modelstat ne 1, v_obje.l = 0);
                     execerror = 0;
*
*                    --- different from others: if the drop is > 10% compared to last step, don't save
*
                     if ( (v_obje.l gt p_cutlow) $ ( (v_obje.l Gt p_trackstat("bin5","obje")*0.9) or (v_obje.l Gt (p_trackstat("bin5","obje")-25000)) ),
                        execute_unload "%gams.scrdir%/duringFixing.gdx" v_obje.l,p_trackstat
                           $$include "%gams.scrdir%binaries.gms"
                        ;

                     else
                        display "Final RMIP solve not stored ",v_obje.l,m_farm.modelStat;
                     );

                     $$include 'solve/count_binaries'
                     $$batinclude 'solve/trackStat.gms' "bin6"
                  );

               );
            );
         );
      );
   );
   $$ifi defined v_npvAtRisk  v_npvAtRisk.l(nCur)$ t_n("%lastYearCalc%",nCur) = 1 $ (v_objeN(nCur) lt p_npvAtRiskLim );

   if ( (v_obje.l lt p_cutlow),

       display "Final RMIP solve at fixed binaries ",v_obje.l," < ",p_cutLow;
*
*     --- load the best solution if the last solve was not the best one
*         and solve relaxed model agin as start point for LP solver
*
       $$include 'solve/count_binaries'
       execute_load '%gams.scrdir%/duringFixing.gdx' v_obje.l
       $$include "%gams.scrdir%binaries.gms"
     ;
   );
*
*  --- solve again if we did not find a better solution
*
   if ( (v_obje.l lt p_cutlow),

      display "Best RMIP solve at partially fixed binaries ",v_obje.l," < ",p_cutLow;

      solve m_farm using %rmip% maximizing v_obje;
      $$ifi "%stochProg%"=="true" $include 'model/copy_stoch.gms'
      $$include 'solve/count_binaries'
      $$batinclude 'solve/trackStat.gms' "final"
      execute_unload "%gams.scrdir%/duringFixing.gdx"
         $$include "%gams.scrdir%binaries.gms"
      ;
   );
$$include 'solve/count_binaries'
*
*  --- load old bounds, levels etc.
*
   execute_load '%gams.scrdir%/beforeFixing.gdx'
    $$include "%gams.scrdir%binaries.gms"
  ;
*
*  --- and just add the levels from the heuristics above
*
   execute_loadpoint '%gams.scrdir%/duringFixing.gdx'
    $$include "%gams.scrdir%binaries.gms"
  ;

$$ifi defined v_npvAtRisk  v_npvAtRisk.l(nCur) $ t_n("%lastYearCalc%",nCur)  = 1 $ (v_objeN(nCur) lt p_npvAtRiskLim );

if ( nRelaxedBinaries ne 0,

  $$if defined v_buyStables  v_buyStables.l(stables,hor,t_n(t,nCur))     = round(v_buyStables.l(stables,hor,t,nCur));
  $$if defined v_buySilos    v_buySilos.l(curManChain,silos,t_n(t,nCur)) = round(v_buySilos.l(curManChain,silos,t,nCur));

  v_buyBuildings.l(curBuildings,t_n(t,nCur)) = ceil(v_buyBuildings.l(curBuildings,t,nCur));
  v_labOffB.l(t_n(t,nCur)) $ sum(workOpps(workType) $ v_labOff.l(t,nCur,workType),1) = 1;

 else

   $$ifi defined v_npvAtRisk  if ( (sum(nCur,v_npvAtRisk.l(nCur)*p_probN(nCur)) le p_npvAtRiskMaxProb) or (not p_npvAtRiskMaxProb),
      $$ifi "%solver%"=="ODHCPLEX" execute  "echo mipstart=6  >> %curDir%/opt/%solver%.%op4%";
      $$ifi "%solver%"=="CPLEX"    execute  "echo mipstart=6  >> %curDir%/opt/%solver%.%op4%";
      $$ifi "%solver%"=="ODHCPLEX" execute  "echo mipemphasis=3  >> %curDir%/opt/%solver%.%op4%";
      $$ifi "%solver%"=="CPLEX"    execute  "echo mipemphasis=3  >> %curDir%/opt/%solver%.%op4%";
      $$ifi "%solver%"=="CBC"      execute  "echo mipstart   1  >> %curDir%/opt/%solver%.%op4%";
      $$ifi "%solver%"=="CBC"      execute  "echo heuristics 0  >> %curDir%/opt/%solver%.%op4%";
*      $$ifi "%solver%"=="GUROBI"   execute  "echo method=-1     >> %curDir%/opt/%solver%.%op4%";
      m_farm.bratio=0;
   $$iftheni.npvAtRisk defined  v_npvAtRisk
     else
        option kill=v_hasFarm.l,kill=v_hasBranch.l,kill=v_buyMach.l,kill=v_buyBuildings.l,kill=v_npvAtRisk.l,kill=v_labOff.l;
        $$ifi declared v_buyStables option kill=v_buySilos.l,kill=v_buyStables.l;
        v_hasFarm.l(t_n(t,nCur)) = 1;
        v_labOff.l(t_n(t,nCur),workOpps) $ (workOpps.pos eq card(workOpps)) = 1;
        v_labOffB.l(t_n(t,nCur)) $ sum(workOpps(workType) $ v_labOff.l(t,nCur,workType),1) = 1;
        v_hasBranch.l(branches,t_n(t,nCur)) = 0;
        m_farm.bratio=1;
        solve m_farm using %mip% maximizing v_obje;
        $$ifi "%stochProg%"=="true" $include 'model/copy_stoch.gms'
        v_hasBranch.up(branches,t_n(t,nCur)) = 1;
        m_farm.bratio=0;
     );

   $$endif.npvAtRisk
);
*
* --- print binaries not at either the lower or upper limit to log
*     if some non-relaxed binaries are left
*
embeddedCode Python:

  test = list(gams.get('nRelaxedBinaries'))
  if ( test != [0.0]):
     for s in gams.db:
       if (type(s) == GamsVariable) and (s.vartype in [VarType.Binary, VarType.Integer,
                                                       VarType.SOS1, VarType.SOS2,
                                                       VarType.SemiCont, VarType.SemiInt]):
          for r in s:
               if ( int(r.level) != r.level):
                  gams.printLog(" "+str(r))

endEmbeddedCode
