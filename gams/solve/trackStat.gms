********************************************************************************
$ontext

   FarmDyn project

   GAMS file : TRACKSTAT.GMS

   @purpose  : Report a few core properties of the last model solve
               and unload in GDX in scratch directory
   @author   : W. Britz
   @date     : 21.09.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter.gms, reduce_vars_for_mip.gms

$offtext
********************************************************************************
$if not defined p_trackstat parameter p_trackStat;
$if not defined lastTime scalar lastTime / 0 /;
$set arg1 %1
$if not defined %arg1% $set arg1 "'%1'"

  p_trackstat(%arg1%,"obje")    = v_obje.l;
  p_trackstat(%arg1%,"numEqu")   = m_farm.numEqu;
  p_trackstat(%arg1%,"numVar")   = m_farm.numVar;
  p_trackstat(%arg1%,"numDVar")  = m_farm.numDVar;

  $$if defined nRelaxedBinaries p_trackstat(%arg1%,"nonFixedDVar") = nRelaxedBinaries;

  p_trackstat(%arg1%,"secUsdModel")   = m_farm.etSolve;
  p_trackstat(%arg1%,"secUsdSolver")  = m_farm.etSolver;
  p_trackstat(%arg1%,"modstat")       = m_farm.modelstat;
  p_trackstat(%arg1%,"solvestat")     = m_farm.solvestat;
  p_trackstat(%arg1%,"secUsdStep")    = timeElapsed - lastTime;
  p_trackstat(%arg1%,"secSinceStart") = timeElapsed;

  lastTime = timeElapsed;

  execute_unload "%scrdir%/trackStat.gdx" p_trackStat
    $$ifi defined p_statsRound p_statsRound
    $$ifi defined p_cropIns p_cropIns,p_testIns
  ;

