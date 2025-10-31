********************************************************************************
$ontext

   FARMDYN project

   GAMS file : COMBINE_SUMRES.GMS

   @purpose  : Combine results from a batch execution run, i.e. several solve
   @author   : W.Britz
   @date     : 08.03.18
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************
$offlisting
*
* --- from GUI: directory where resuls are to be found
*
$include "combinc.gms"
$setglobal inputDir %scrdir%/%batchOutputDir%
*
set gdxDiffPos / ins1,ins2,dif1,dif2 /;
*
*
* --- read universal domain and files which were sent to GDXDiff
*
   $$include "%inputDir%/testInc.gms"

   display p_sumout;

   execute_unload "%resdir%\qManag\%BatchOutputDir%.gdx" p_sumOut=p_res;

$ifthen.exist exist "%resdir%\qManag\all.gdx"
*
*  --- load the summary of the summaries
*
   parameter p_summaryOut(*,*,*);
$GDXIN "%resdir%\qManag\all.gdx"
$load p_summaryOut=p_res
$GDXIN

   p_summaryOut("%BatchOutputDir%",fileLabels,sumRes) $ p_sumOut("%BatchOutputDir%",fileLabels,sumRes)
    = p_sumOut("%BatchOutputDir%",fileLabels,sumRes);

   execute_unload "%resdir%\qManag\all.gdx" p_summaryOut=p_res;

$else.exist

   execute_unload "%resdir%\qManag\all.gdx" p_summaryOut = p_res;
$endif.exist
