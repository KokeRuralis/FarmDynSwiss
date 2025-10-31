********************************************************************************
$ontext

   FarmDyn project

   GAMS file : PART_MIP_SOLVE.GMS

   @purpose  : Solve a MIP with eco,farm,laboffB and v_hireworkers as
               integers and all others integers relaxed
   @author   : W.Britz
   @date     : 27.01.21
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter.gms

$offtext
********************************************************************************

$batinclude 'util/title.gms' "'%titlePrefix% Partial MIP solve'"
*
*  --- store the binaries before fixing
*
   execute_unload '%gams.scrdir%/beforeFixing.gdx'
    $$include "%gams.scrdir%binaries.gms"
   ;
*
*  --- check if core integeer fixed in partial MIP solve are not fixed
*      anyhow by model configuration
*
$setglobal usePartSolve false
$ifi "%orgTill%"         =="optional"  $setglobal usePartSolve yes
$ifi "%allowForOffFarm%" == "true"     $setglobal usePartSolve yes
$ifi "%allowHiring%"     == "true"     $setglobal usePartSolve yes
$ifi "%usePartSolve%"    == "false"    $exit
*
* --- relax all binaries (set .prior to inf)
*
  $$batinclude 'util\relaxAllBinaries.gms' float('inf')
*
* --- only consider the eco-switch, hasfarm and hasBranches as integers
*     and labour choices as integers
*
  option kill=v_org.prior;
  option kill=v_hasFarm.prior;
  option kill=v_LaboffB.prior;
  option kill=v_hireWorkers.prior;
*
* --- use zero MIP start optin
*
  $$ifi "%solver%"=="ODHCPLEX" execute  "echo mipstart=6  >> %curDir%/opt/%solver%.%op4%";
  $$ifi "%solver%"=="CPLEX"    execute  "echo mipstart=6  >> %curDir%/opt/%solver%.%op4%";
*
* --- solve the MIP (with many integers relaxed)
*
  v_hasFarm.l(t_n(tCur,nCur))    $ v_hasFarm.l(tCur,nCur)         = 1;
  v_labOffb.l(t_n(tCur,nCur))    $ v_labOffB.l(tCur,nCur)         = 1;
  v_hireWorkers.l(t_n(tCur,nCur))                                 = round(v_hireWorkers.l(tCur,nCur));

  v_labOffb.l(t_n(tCur,nCur)) = 1 $ (v_labOffB.l(tCur,nCur) and (not v_hireWorkers.l(tCur,nCur)));

  v_hasBranch.l(branches,t,nCur) $ v_hasBranch.l(branches,t,nCur) = 1;

  $$ifthen.definedEco defined v_org

     v_org.l   (t_n(tCur,nCur)) $ (v_org.l(tCur,nCur) le 0.6) = 0.0;
     v_org.l   (t_n(tCur,nCur)) $ (v_org.l(tCur,nCur) gt 0.6) = 1.0;
  $$endif.definedEco

  solve m_farm using MIP maximizing v_obje;
  $$ifi "%stochProg%"=="true" $include 'model/copy_stoch.gms'
*
* --- Set MIP start level again
*
  $$ifi "%solver%"=="ODHCPLEX" execute  "echo mipstart=5  >> %curDir%/opt/%solver%.%op4%";
  $$ifi "%solver%"=="CPLEX"    execute  "echo mipstart=5  >> %curDir%/opt/%solver%.%op4%";
*
* --- report
*
  $$include 'solve\count_binaries'
  $$batinclude 'solve/trackStat.gms' PartialMIP
*
* --- fix these intger choices until the final MIP solve
*
  v_org.fx(t_n(tCur,nCur))                = v_org.l(tCur,nCur);
  v_hasFarm.fx(t_n(tCur,nCur))            = v_hasFarm.l(tCur,nCur);
  v_LaboffB.fx(t_n(tCur,nCur))            = v_labOffb.l(tCur,nCur);
  v_hireWorkers.fx(t_n(tCur,nCur))        = v_hireworkers.l(tCur,nCur);

*
* --- remove the relaxation
*
  $$batinclude 'util\relaxAllBinaries.gms' 0
