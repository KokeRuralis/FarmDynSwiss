********************************************************************************
$ontext

   FarmDyn project

   GAMS file : TUNE.GMS

   @purpose  : Tuning step with MIP solvers GUROBI and CPLEX
   @author   : W.Britz
   @date     : 09.03.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starer

$offtext
********************************************************************************

*
*   --- append run specific options
*
    file optf1/ "%curDir%/opt/%solver%.%op4%" /;
    optf1.ap = 1;
    put optf1;

$iftheni.solver %solver% == GUROBI

    put " mipgap    " (%optcr%):10:4  /;
    if ( p_cutLow ne -inf,
       put " mipgapabs ",max(250,min(p_cutLow*0.001,(v_obje.l-p_cutlow*0.998)/10)) /;
       $$ife %optca%=0      put " mipgapabs ",0;
    else
       put " mipgapabs ",2500 /;
       put " mipgapabs ",0 /;
       $$ife %optca%=0       put " mipgapabs ",0;

    );

$else.solver

    if ( p_cutLow ne -inf,
       put " objdif=",max(250,min(p_cutLow*0.001,(v_obje.l-p_cutlow*0.998)/10)) /;
       $$ife %optca%=0  put " objdif=",0 /;
    else
       put " objdif=",250 /;
       $$ife %optca%=0  put " objdif=",0;

    );
$endif.solver
    putclose;

*
     execute  "type %curDir%/opt/%solver%.%op4% > %gams.scrdir%/opt/%solver%.%op4%";
     $$batinclude 'util/title.gms' "'%titlePrefix% Solve model as %MIP% - tuning step'"
*
*    --- copy tuning instructions
*
     execute  "rm %curDir%/opt/%solver%.%op3%";
     execute  "cp  %curDir%/opt/%solver%.op3 %curDir%/opt/%solver%.%op3%  > nul";
*
     putclose;
     m_farm.optfile    = %op3%;

     $$iftheni.solver %solver%==CPLEX


        execute  "echo tuningdisplay 3                >> %curDir%/opt/%solver%.%op3%";
*       execute  "echo tuningDettilim     %reslim%    >> %curDir%/opt/%solver%.%op3%";
        execute  "echo TiLim           %reslim%       >> %curDir%/opt/%solver%.%op3%";
        $$eval tiLim %resLim%/10
        execute  "echo tuningTiLim     %tiLim%        >> %curDir%/opt/%solver%.%op3%";
     $$else.solver
        execute  "echo tuneTimeLimit %reslim%         >> %curDir%/opt/%solver%.%op3%";
     $$endif.solver

*
*    --- use the normal option file as the tuning output
*
     execute  "echo tuning %curDir%/opt/%solver%.%op4% >> %curDir%/opt/%solver%.%op3%";
     m_farm.optfile    = %op3%;

     $$ifi     %useMIP%==on   solve m_farm using %MIP% maximizing v_obje;
     $$ifi not %useMIP%==on   solve m_farm using RMIP maximizing v_obje;

     execute  "type %gams.scrDir%%solver%.%op4% >> %curDir%/opt/%solver%.%op4%";
*
*    --- store for later re-use
*
     execute  "cp %curDir%/opt/%solver%.%op4% %curDir%/opt/%solver%.op6";
*
     abort "tuning step finalized";

