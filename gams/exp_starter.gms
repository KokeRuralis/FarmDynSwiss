********************************************************************************
$ontext

   FARMDYN project

   GAMS file : EXPSTARTER.GMS

   @purpose  : Top level program of single farm runs
   @author   : W.Britz, B.Lengers
   @date     : 12.11.10
   @since    : 2010
   @refDoc   :
   @seeAlso  :
   @calledBy :


$offtext
*********************************************************************************
*
$onglobal
$offlisting
$setglobal curDir %system.fp%
*
*------------------------------------------------------------------------------
*
*   Define globals / load farm from interface or given example
*
*------------------------------------------------------------------------------
*
* --- define some global settings used in rest
*
$include 'solve/def_run.gms'
*
$batinclude 'util/title.gms' "'%titlePrefix% Declaration and initialisation ...'"
*
* --- some check for valid user input from interface
*
$include 'solve/abort_GUI_settings.gms'
*
* --- define sets for cattle herds and grassland types
*
$ifi "%cattle%"=="true"   $$batinclude 'solve/define_Cattle_herds.gms'
$ifi "%cattle%"=="true"   $$batinclude 'util/grasAttr.gms'
*
*------------------------------------------------------------------------------
*
*   Declaration / Initialisation
*
*------------------------------------------------------------------------------
*
$batinclude 'util/title.gms' "'%titlePrefix% Declaration and initialisation ...'"
*
*  --- declarations of parameters used in model
*
$include 'model/templ_decl.gms'
*
*  --- model variables/equations
*
$include 'model/templ.gms'
*
*  --- construct land endowment of farm
*
$include 'coeffgen/farm_ini.gms'
*
*  --- call coefficient generator
*
$include 'coeffgen/coeffgen.gms'
*
*  --- initial endowment with stables, buildings and
*      machinery; consumption of household,
*      labour available per month
*
$ifi not "%calibration%"=="false" $batinclude 'calib/calib.gms' target
$include 'coeffgen/farm_constructor.gms'
*
*  --- define herd demographics and potential herds
*
$ifi "%herd%"=="true" $$include 'coeffgen/ini_herds.gms'
*
   possActs(crops) $ sum(c_p_t_i(crops,plot,till,intens),1) = YES;
*
*  --- declarations for reporting part
*
$include 'exploiter/decl.gms'
*
*  --- starting bounds
*
$batinclude 'util/title.gms' "'%titlePrefix% Define starting bounds'"
*
$include 'solve/define_starting_bounds.gms'
$include 'solve/set_derived_bounds.gms'
*
*  --- check for reasonsable price (input price > output price for same product)
*
$include 'solve/abort_Compilation.gms'

$setglobal startFromCalibRes false
$ifi "%calibration%"=="false" $if not "%calibRes%"=="farm_empty" $setglobal startFromCalibRes true
*
* --- load parameters from previous calibration
*
$ifi "%startFromCalibRes%"=="true" $include 'solve\load_calib.gms'
*
* --- fix variables used during calibration and formally declared as parameters
*
$batinclude "calib/calib.gms" fixPars



*
*------------------------------------------------------------------------------
*
*   Solve model with only off farm work and single farm premium
*
*------------------------------------------------------------------------------
*
$batinclude 'util/title.gms' "'%titlePrefix% Solve model as %MIP% without farm, only off farm work and Single Farm Premium'"
*
* --- solve model without farm (= v_hasFarmUp is zero),
*     If off farm work is activated, family will work off farm resulting objective function is used to define a lower limit for the objective function
*     If off farm work is deactivated, the lower limit is given by the generated income from the single farm premium received
*
  v_hasFarm.up(t_n(t,nCur))             = 0;
  v_hasBranch.up(branches,t_n(t,nCur))  $ (not sameas(branches,"cap")) = 0;


  m_farm.optfile    = 5;
  $$include 'solve/setSolprint.gms'
  $$ifi "%noSolprintRMIP%"=="true" m_farm.solprint = 2;
  m_farm.limcol     = 0;
  m_farm.limrow     = 0;
  $$ifi     %useMIP%==on   solve m_farm using %MIP% maximizing v_obje;
  $$ifi not %useMIP%==on   solve m_farm using %RMIP% maximizing v_obje;
*
* --- this solution is not worth much, don't use as basis
*
  m_farm.bratio     = 1;
  $$batinclude 'solve/trackStat.gms' noFarm
  $$batinclude 'solve/treat_infes.gms' %MIP% "Solve model without farm, only off farm work"
*
* --- the solution without a farm defines a lower limit on the objective function.
*     That can help the MIP solver during cut and branch
*
$ifi %stochProg%==true  p_npvAtRiskLim = smin(t_n("%lastYearCalc%",nCur),v_objeN.l(nCur)) * p_npvAtRiskLim;
*
  scalar p_cutlow,p_cutUpp;
*
  p_cutLow = v_obje.l * 0.999;
*
* --- generate list of binary variables (used for calibration, heuristics)
*
$include "calib/listOfBinaries.gms"
*
* --- load results from previous calibration run
*
$iftheni.calib "%startFromCalibRes%"=="true"
  if (execError, abort "Run time error in : %system.fn%, line: %system.incline%");
  execute_loadpoint '%resdir%/calib/%calibRes%.gdx';
*
* --- the calibation should provide a good MIP-Start,
*     don't use heuristics to construct one
*
  $$setglobal nHeuristicFixing 0
$endif.calib
*
* --- copy option file to run specific one
*
$ifi %tune%==true $setglobal useOldTuningResults false
$iftheni.tuneold %useOldTuningResults% == true
*
*  --- copy existing solver specific options from preivous tuning run
*
   execute  'test -e "%curDir%/opt/%solver%.op6" && cp %curDir%/opt/%solver%.op6 %curDir%/opt/%solver%.%op4%';
*
*  --- odhcplex needs a CPLEC option file as well
*
   $$ifi "%solver%"=="ODHCPLEX" execute 'cp %curDir%/opt/cplex.op5 %curDir%/opt/cplex.%op4%';
$else.tuneold
*
*  --- default solveroption file
*
   execute  'cp %curDir%/opt/%solver%.op5 %curDir%/opt/%solver%.%op4%';
*
*  --- odhcplex needs a CPLEC option file as well
*
   $$ifi "%solver%"=="ODHCPLEX" execute 'cp %curDir%/opt/cplex.op5 %curDir%/opt/cplex.%op4%';
$endif.tuneold
*
* --- inform solvers about # of threads to use
*
$ifi "%solver%"=="CPLEX"     execute  "echo threads %threads% >> %curDir%/opt/%solver%.%op4%";
$ifi "%solver%"=="GUROBI"    execute  "echo threads %threads% >> %curDir%/opt/%solver%.%op4%";
$ifi "%solver%"=="ODHCPLEX"  execute  "echo odhthreads %threads% >> %curDir%/opt/%solver%.%op4%";
*
*  --- use this option file in the following
*
 m_farm.optfile = %op4%;

*------------------------------------------------------------------------------
*
*   Solve model as relaxed RMIP
*   (integer variable are relaxed and treated as fractionals,
*    that defines an upper bounds for the objective under a MIP solve)
*
*------------------------------------------------------------------------------
*
* --- set minimum yearly household consumption (from GUI)
*
  v_hhsldIncome.lo(t_n(tFull,nCur)) $ p_hcon(tFull) = p_hcon(tFull);
  v_hhsldIncome.lo(t_n(tFull,nCur)) $ (not p_hcon(tFull)) = -inf;
*
* --- allow farm
*
  v_hasFarm.up(t_n(t,nCur))             = 1;
  v_hasBranch.up(branches,t_n(t,nCur))  = 1;

  $$ifi  "%Solprint%"  == "full Output" m_farm.limcol     = %limCol%;
  $$ifi  "%Solprint%"  == "full Output" m_farm.limrow     = %limRow%;
*
* --- introduce potential debug bounds (crop acreages or herd sizes are bounded)
*      (as entered on interface)
*
$include 'solve/debug_bounds.gms'
*
*  --- we introduce bounds around the calibration targets to ensure that
*      crops/herds subject to calibration are found in the RMIP solution,
*      as well as related variables (feeding, fertilization, machines ...)
*
$ifi not "%calibration%"=="false" $batinclude 'calib/calib.gms' bounds
*
$batinclude 'util/title.gms' "'%titlePrefix% Solve model as %RMIP%'"
  $$ifi "%stopPoint%"=="After first RMIP solve" $include 'solve/setSolprint.gms'
  solve m_farm using %RMIP% maximizing v_obje;
  $$include 'model/copy_stoch.gms'
  $$batinclude 'solve/trackStat.gms' RMIP
  $$batinclude 'solve/treat_infes.gms' %RMIP% "RMIP solve"
  if ( (m_farm.modelstat ne 1) and (m_farm.modelstat ne 8), abort "RMIP Model not solved to optimality");
*
* --- this is used during heuristics to estimate if the
*     binary fixing might have reduced the objective too much
*
$ifi %stochProg%==true p_objeRmip = v_obje.l;
*
* --- we have now a reasonable basis for further solves
*
  m_farm.bratio     = 0.25;
*
$iftheni.abortFirstRMipSolve "%stopPoint%"=="After first RMIP solve"
*
  $$include 'solve/del_temp_files.gms'
  execute_unload '%gdxFileName%' p_res;
  abort.NoError "Abort after first RMIP solve upon user request";
*
$endif.abortFirstRMipSolve
*
* --- report solution of the RMIP solve with calibration bounds if calibration is active
*
$ifi not "%calibration%"=="false" $$batinclude 'calib/calibReport' 'boundsRMIP' yes
*
* --- define branching priorities for MIP solver (on demand)
*
$include 'solve/def_priors.gms'
*
* --- solve optionally artial MIP start
*
$ifi "%partialMIPSolve%"=="true" $include 'solve/part_mip_solve.gms'
*
* ----- report solution of RMIP solve with calibration bounds if calibration is active
*
$ifi not "%calibration%"=="false" $$batinclude 'calib/calibReport' 'boundsRMIP' yes
*
* --- any MIP solution cannot exceed the relaxed one:
*     inform the solver about an upper limit
*
  p_cutUpp = v_obje.l*1.001;
*
*  --- heuristics: remove variables from the model not used in
*                  relaxed mode, remove stable / silo / building in years
*                  where not realized

$ifi"%nHeuristicsToRedBinaries%"=="true" $$include 'solve/reduce_vars_for_mip.gms'
*
*  --- heuristics: try to find a feasible MIP solution by solving several time the
*                  model with more integer variables fixed to 0/1
*
$ife %nHeuristicFixing%>0  $$batinclude 'solve/binary_fixing.gms'

$$iftheni.abheu "%StopPoint%"=="After heuristics"

   $$include 'solve/del_temp_files.gms'
   execute_unload '%gdxFileName%' p_res;
   abort.noError "Abort after heuristics upon user request";

$$endif.abheu

*
* --- heuristics remove variables, marginal, equations
*     a dummy call to CONOPT, closing GAMSCMEX, frees
*     memory and can speed up further processing
*
$include 'util/kill_model1.gms'

* ------------------------------------------------------------------------------
*
*   Tuning step, i.e. let CPLEX/GUROBI try to find a set of options which solve the
*   model fast. Makes only sense if these settings are re-used for other runs
*
* ------------------------------------------------------------------------------

$ifi "%tune%"=="true" $include "solve/tune.gms"

*------------------------------------------------------------------------------
*
*   Model solve for baseline, %MIP%
*
*------------------------------------------------------------------------------
*
$batinclude 'util/title.gms' "'%titlePrefix% Solve model as %MIP% for base run'"
*
* --- introduce user set debug bounds (e.g. min # of cows) form interface
*
$include 'solve/debug_bounds.gms'
*
* --- load calibration bounds (on demand)
*
$ifi not "%calibration%"=="false"     $include 'calib/calib.gms'
*
* --- introduce solprint settings from interface
*
$include 'solve/setSolprint.gms'
*
* --- switch on environmental accounting (only information equations)
*     Where off before to speed up helper solutions
*
   envAcc = 1;
$ifi     %useMIP%==on   solve m_farm using %MIP% maximizing v_obje;
$ifi not %useMIP%==on   solve m_farm using %RMIP% maximizing v_obje;
$batinclude 'solve/treat_infes.gms' %MIP% "Base run"
*
* --- report model status and MIPs
*
  $$batinclude 'solve/trackStat.gms' MIP
   execute_unload '%gams.scrdir%/afterSolve' v_obje.l
    $$include "%gams.scrdir%binaries.gms"
  ;

$iftheni.abortAfterMipSolve "%StopPoint%"=="After first MIP solve"

  $$include 'solve/del_temp_files.gms'
  if ( (m_farm.modelstat ne 1) and (m_farm.modelstat ne 8), abort "Model not solved to optimality";);

  abort.noError "Abort after first solve upon user request";

$endif.abortAfterMipSolve
$ifi "%StopPoint%"=="After first MIP solve" $exit
*
* --- post-model processing, results report in p_res
*
$include 'model/copy_stoch.gms'
$batinclude 'exploiter/store_res.gms' '"Base"' '"%exploiterDim2%"' full
  parameter p_sumRes,p_numbOfBindLabourMonths, p_sumResT2B(*,*), p_sumRes2GLOBIOM(*,*,*,*,*,*), p_sumLAMASUS(*,*,*,*,*,*);
$batinclude 'exploiter/gen_sumres.gms' '"Base"' "'%exploiterDim2%'"
*$batinclude 'exploiter/GEN_res2GLOBIOM.gms' '"Base"' "'%exploiterDim2%'"
*$batinclude 'exploiter/gen_LAMASUS.gms' '"Base"' "'%exploiterDim2%'"

$ifi "%stochProg%"=="true" $include 'solve/run_cpt.gms'
$ifi "%stochProg%"=="true" $include 'exploiter/uApprox.gms'
*
* --- core summary results for use with GDXDiff
*
$ifi "%output_feed%"=="true" $include 'exploiter/gen_feed.gms'
*$ifi "%output_p_resEmissions%"=="true" $batinclude 'exploiter/gen_emissions.gms'
$ifi "%addReporting%"=="true"          $batinclude 'exploiter/%addReportFile%.gms'
*$batinclude 'exploiter/gen_SustainBeef.gms' '"Base"' "'%exploiterDim2%'"
*$include 'exploiter/gen_herds_xml.gms'
*
 if ( (m_farm.modelstat ne 1) and (m_farm.modelstat ne 8), abort "Model not solved to optimality");
*
* --- program simuatled points on marginal abatement curve
*     by step-wise reduction of maximal GHG emissions allowed
*
$ifi "%GHGreduction%"=="true" $include 'ghgmac/redruns.gms'
*
* --- trial implementation of generating economic results at differences
*     prices and fixed core decision variables
*
$ifi "%postModelStoch%"=="true" $include 'exploiter/post_model_stoch.gms'
*
* --- run sensitivity analysis with land endowment and FO
*
$ifi "%useSensLand%"=="true"              $include 'solve/sensLand.gms'
$ifi "%scenType%"=="Fertilizer Directive" $include 'solve/sensFD.gms'
*
*
* --- report core results to listing
*

  display plot_landType, p_plotSize, c_p_t_i, p_fieldWorkingDays, plot_soil;
*
* --- store results to GDX
*
  execute_unload '%gdxFileName%' p_res,
$ifi defined s_meta  s_meta,
                                 p_sumRes
$ifi "%postModelStoch%"=="true"  p_stochRes
                                 p_sumResT2B
                                 p_sumLAMASUS
*                                p_sumRes2GLOBIOM
*                                feedBasket
*                                cropPatternCrops
*                                otherItems
$ifi set addIndicators           %addIndicators%
$ifi defined p_checkU            p_checkU
  ;
*
* -- run separate GAMS program to generate a FOC overview
*    (will be added to GDX)
*
$ifi "%exhaustion_report%"=="true" $include 'exploiter/FOC_report.gms'
*
* --- delete run specific files
*
$include 'solve/del_temp_files.gms'
*
* --- collect results in case of last instance
*     of a farm sample run
*
$ifi not setglobal lastInstance $setglobal lastInstance false
$ifi not "%lastInstance%"=="false" $include 'exploiter/collect_sample_results.gms'
