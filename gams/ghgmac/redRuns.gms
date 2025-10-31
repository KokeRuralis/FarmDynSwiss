********************************************************************************
$ontext

   FARMDYN project

   GAMS file : STORE_RES.GMS

   @purpose  : Setup and store results of GHG abatement cost curves

   @author   : W. Britz revisted by L. Kokemohr
   @date     : 18.11.21
   @since    :
   @refDoc   :
   @seeAlso  : model/templ.gms
   @calledBy : exp_starter.gms

$offtext
********************************************************************************

*
*  --- Error trapping/prevention
*


$$ifi "%envAcc%" == "false"   $$abort "Greenhouse gas mitigation reduction steps require environmental accounting turned on!";
$$ifi not "%task%"=="Single farm run"  $$abort "Greenhouse gas mitigation reduction steps are currently not tested with farm sample run";

*------------------------------------------------------------------------------
*
*   Simulation over abatement levels
*
*------------------------------------------------------------------------------
*

$evalGlobal redSteps round(%redSteps%)
  set redLevl / red0,red1*red%redSteps%/;
*
  parameter p_redLevl(redLevl);
  p_redLevl(redLevl) = MIN(1,(redLevl.pos-1)/(card(redLevl)-1) * (%perCentRedPerStep%*%redSteps%/100)
*
*                     --- stochastic perturbations
*
$if set seed          + [uniform(-%perCentRedPerStep%*0.495,+%perCentRedPerStep%*0.495)/100] $ (redLevl.pos ne 1)
                      );

  parameter p_macRes(*,redlevl) "Result array for marginal abatement costs"

  scalar p_nSim         "Number of total simulations"
         p_iSim         "Number of current simulations"
         p_nSec         "Seconds since start of simulations"
         p_lastSec      "Last measurement taken"
         p_secPerModel  "Average solution time in seconds per solve"
         p_simPerc      "Percentage of simulations done"
         p_nMins         "Number of minutes since start of simulations"
         p_nMinsRem      "Estimated number of minutes remaining until end"
         p_nSecRem      "Estimated number of seconds remaining until end"
  ;

  p_lastSec = 0;
  p_iSim    = 1.5;

  p_nSim =  card(redlevl) + p_iSim;

  file optf / %solver%.%op5% /;

  parameter p_baseLine;
  p_baseLine =    sum( tCur, sum((t_n(tCur,nCur)), p_probn(nCur) *   v_emissionsCatSum.l("GWP",tCur,nCur) ) ) / p_cardtCur ;
;


*
* ----- loop over reduction levels
*
  loop( (redlevl),
    continue$sameas(redlevl,"red0") ;
    p_iSim = p_iSim + 1;
    if ( redlevl.pos > 1,
    else

     );
*
*   --- append cutoffs to CPLEX option file
*
    execute  "cp  %solver%.%op4% %solver%.%op5% > nul";
*
    put optf;
    optf.ap = 1;
    put " cutlo=",(p_cutlow*0.998)/;
    put " cutup=",m_farm.cutoff /;
    put " objdif=",min(p_cutLow*0.001,(m_farm.cutoff-p_cutlow*0.998)/10) /;
    put " parallelmode=-1" /;
    putclose;
*
*   --- define maximal allowed emissions
*
    v_emissionsCatSum.up("GWP",t,n)     = inf;
    v_emissionsCatSum.up("GWP",t,n) $ (not sameas(redLevl,"red0"))
        = p_baseLine * (1 - p_redLevl(redLevl));

    p_nSec = timeElapsed;
    p_secPerModel = p_nSec/p_iSim;
    p_simPerc     = round(p_iSim/p_nSim * 100);
    p_nMins        = round(p_nSec/60);

    p_nSecRem     = ceil( (p_nSim - p_iSim + 1) * p_secPerModel);
    p_nMinsRem     = round( p_nSecRem/60);

    m_farm.optfile = %op5%;
    solve m_farm using %MIP% maximizing v_obje;

$batinclude 'solve/treat_infes.gms' %MIP% ""
$batinclude 'exploiter/store_res.gms' '"Base"' redLevl full
    p_lastSec = p_nSec;

    if ( m_farm.resusd > 10,
$include 'util/kill_model1.gms'
    );


    put_utilities batch 'gdxout' / '%scrdir%\res_' redLevl.tl;
    execute_unload p_res;

    option kill=p_res;
$include 'util/kill_model1.gms'

* closing the abatement run loop
);

*
*   --- loop to collect single run results in a common gdx
*
$ontext
execute_loadpoint "%scrdir%\res_base"  p_res;
*loop(redLevl,
*  put_utilities batch 'gdxin' / '%scrdir%\res_' redLevl.tl;
*  execute_loadpoint p_res;
*);

loop( (redLevl),

        put_utilities 'gdxin' / '%scrdir%/res_' redLevl.tl;
        if ( execerror eq 0,
           execute_loadpoint p_res;
        else
           option kill= p_res;
           execerror=0;
        )
    ;

   );
$offtext

   loop(redLevl $ (not sameas(redLevl,"red0")),
     put_utilities batch 'gdxin' / '%scrdir%\res_' redLevl.tl;
     execute_loadpoint p_res;
   );
*execute_unload "%resdir%/samples/res_%scenDes%_until_%lastYear%.gdx" p_sumResT2B, p_res ;
