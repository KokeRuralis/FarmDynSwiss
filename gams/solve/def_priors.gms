********************************************************************************
$ontext

   FARMDYN project

   GAMS file : DEF_PRIORS.GMS

   @purpose  : Define branching priorities for MIP solver

   @author   : Wolfgang Britz
   @date     : 21.12.10
   @since    :
   @refDoc   :
   @seeAlso  : model/templ.gms
   @calledBy : exp_starter.gms

$offtext
********************************************************************************

$setglobal priorOperator 1/
$setglobal timeWeight [(card(t)-ord(t)+1)/card(t)]**0.5
*
* --- we only test first if we should not better buy no stables / silo / building
*     in years where we buy some under RMIP. The rest of the branching decisions is left with the solver
*

$iftheni.priors %priorities%==true
*
    m_farm.prioropt   = 1;

    $$ifthen.herd %herd%==true

      $$ifi defined p_buyStables option kill=p_buyStables;
      $$ifi not declared p_buyStables parameter p_buyStables;
*
* --- stable place actually bought in each year
*
       p_buyStables(stableTypes,"size",hor,t_n(t,nCur))
         = sum(stables, v_buyStablesF.l(stables,hor,t,nCur) * p_stableSize(stables,stableTypes));

       v_buyStables.prior(stables,hor,t_n(tCur(t),nCur))
          $ sum( (stableTypes,t1,nCur1) $ ( p_buyStables(stableTypes,"size",hor,t1,nCur1) $ p_stableSize(stables,stableTypes) $ t_n(t1,nCur1)),1)
           = %priorOperator% ( hor.pos * %timeWeight%
                              * ( 10
                                     $$ifi defined youngStables - 7 $  youngStables(stables)
                                   ))
                                 * sum(stableTypes $ p_stableSize(stables,stableTypes), (1/stables.pos)
                                    * sum(stables1 $ p_stableSize(stables1,stableTypes), 1));

       $$ifi defined p_buySilos option kill=p_buySilos;
       $$ifi not declared p_buySilos parameter p_buySilos;

        p_buySilos(curManChain,"size",t_n(t,nCur)) = sum(silos, v_buySilosF.l(curManChain,silos,t,nCur) * p_ManStorCapSi(silos));

        v_buySilos.prior(curManChain,silos,t_n(tCur(t),nCur)) $ ((p_ManStorCapSi(silos) eq 0)  $ p_buySilos(curManChain,"size",t,nCur))
            = %priorOperator% ( curManChain.pos * %timeWeight% * 20 );


    $$endif.herd

  $$ifi defined      p_buyBuildings option kill=p_buyBuildings;
  $$ifi not declared p_buyBuilings  parameter p_buyBuildings;

 p_buyBuildings(buildCapac,"size",t_n(t,nCur)) = sum(buildings, v_buyBuildingsF.l(buildings,t,nCur) * p_building(buildings,buildCapac));

 v_buyBuildings.prior(buildings,t_n(tCur(t),nCur))
    $ ( sum(buildCapac $ ( p_buyBuildings(buildCapac,"size",t,nCur) $  p_building(buildings,buildCapac)),1)
                           $ (sum(buildCapac $ p_buyBuildings(buildCapac,"size",t,nCur),p_building(buildings,buildCapac)) eq 0))
            = %priorOperator% ( %timeWeight% * 10 );

 v_laboff.prior(t_n(tCur(t),nCur),workType)    = %priorOperator% ( (card(workType)+1-workType.pos) * %timeWeight%
                                                                     * [100 + 900 $ v_laboff.l(t,nCur,workType)
                                                                            + 400 $ v_laboff.l(t,nCur,workType-1)
                                                                            + 400 $ v_laboff.l(t,nCur,workType+1)] );

 v_hasFarm.prior(t_n(tCur(t),nCur))                   = %priorOperator% ( %timeWeight% * 10000 );
 v_hasBranch.prior(branches,t_n(tCur(t),nCur))        = %priorOperator% ( %timeWeight% * 8000 );
 v_org.prior(t_n(tCur(t),nCur))                       = %priorOperator% ( %timeWeight% * 7500 );
 v_hireWorkers.prior(t_n(tCur(t),nCur))               = %priorOperator% ( %timeWeight% * 5000 );
 v_labOffB.prior(t_n(tCur(t),nCur))                   = %priorOperator% ( %timeWeight% * 4000 );

 v_buyMach.prior(curMachines,t_n(tCur(t),nCur))  $ sum( (machType,t1,nCur1) $ t_n(t1,nCur1), v_buyMach.l(machType,t1,nCur1)*p_priceMach(machType,t1))
      = %priorOperator% ( %timeWeight%     * (sum( (t1,nCur1)          $ t_n(t1,nCur1), v_buyMach.l(curMachines,t1,nCur1)*p_priceMach(curMachines,t1))+0.01)
                                           / sum( (machType,t1,nCur1) $ t_n(t1,nCur1), v_buyMach.l(machType,t1,nCur1)*p_priceMach(machType,t1)));

$$ifi defined v_triggerGreening v_triggerGreening(greeningTriggers,t_n(tCur(t),nCur)) = %priorOperator% ( %timeWeight% * 1000 );

$endif.priors
