********************************************************************************
$ontext

   FarmDyn project

   GAMS file : RUN_CPT.GMS

   @purpose  : After risk-neutral solve, define s-shaped function and
               redefine weights
   @author   : W.Britz
   @date     : 02.12.21
   @since    :
   @refDoc   :
   @seeAlso  : model\stochprog_module.gms
   @calledBy : exp_starter.gms

$offtext
********************************************************************************
$ifi not "%RiskModel%"=="Estimated utility function" $exit

*
*   --- activate equations for utility function approximation
*
    p_approxUtil = 1;
*
*  -----------------------------------------------------------------------------
*
*     estimate S-shaped utility function of TK type
*
*  -----------------------------------------------------------------------------
*
   $$evalglobal nApproxPointsYields floor(%nApproxPointsYields%/2)*2+1
*
*  --- approximation points
*
   set nApp(n);
   nApp(n) $ (n.pos le %nApproxPointsYields%) = YES;

   parameter p_uw(n,*) "Given (functional) relation between u and w, n observations";
*
*  --- use the benchmark risk-neutral optimum to define the refrence point
*      (i.e. the mean point of the sigmoid function)
*
   p_refPoint = v_obje.L;
*
*  --- the spread defines min and max
*
   scalar p_spread;
   p_spread   = max(p_refPoint*2,[v_obje.l - smin(nCur, v_objeN.l(nCur))]*2,
                                 [smax(nCur, v_objeN.l(nCur)) - v_obje.l]*2);
   display p_spread;
*
*  --- the point betwenn the first and last are linear approximation
*      between p_refPoint -/+ p_spread.
*
   p_uw(nApp,"w") =  p_spread / [card(nApp)-3] * (nApp.pos-2) - p_spread/2;
*
*  --- add two extreme points to avoid that the approximation restricts
*      the simulation space
*
   p_uw(nApp,"w") $ (nApp.pos eq 1)          = -p_spread;
   p_uw(nApp,"w") $ (nApp.pos eq card(nApp)) = +p_spread;
*
*  --- use original TK function parameter supplied by user
*
   p_uw(nApp,"u") =               [  p_uw(nApp,"w") **%TKAlpha%] $ (p_uw(nApp,"w") gt 0)
                     %TKgamma%  * [(-p_uw(nApp,"w"))**%TKBeta% ] $ (p_uw(nApp,"w") lt 0);

   $$offorder
   p_uw(nApp,"fstDiv") $ (nApp.pos gt 1) = (p_uw(nApp,"u")-p_uw(nApp-1,"u"))
                                          /(p_uw(nApp,"w")-p_uw(nApp-1,"w"));

   p_uw(nApp,"sndDiv") $ (nApp.pos gt 2) = (p_uw(nApp,"fstDiv")-p_uw(nApp-1,"fstDiv"))
                                          /(p_uw(nApp,"w")-p_uw(nApp-1,"w"));
*
*  -----------------------------------------------------------------------------
*
*     Estimate piece-wise linear approximation
*
*  -----------------------------------------------------------------------------
*
*
*  --- definition of utility for each future
*
   equations
     e_fit                         "Squared relative difference between given function values and approximated ones"
     e_incStep(incStep,n)          "Calculation of increment for current segment"
     e_curv(incStep)               "Ensure concavity left and convexity right of reference point"
     e_order(incStep)              "The segment points need to be ordered from low to high"
     e_orderU(n)                   "The approximated uility need to be ordered from low to high"
     e_u(n)                        "Approximated utility"
   ;

   variable v_fit                  "Squared relative difference between given and approximated utility"
            v_approx(incStep,fudg) "Point and first derivatives of linear approximation curve"
            v_u(n)                 "Approximated utility"
            v_inc(n)               "Income, given or simulated"
            v_approx(incStep,fudg) "Point and first derivatives of linear approximation curve, fixed in simulation"
            v_incStep(incStep,n)   "Intermediate variable in calculation of approximated u"
   ;

   scalar refPos "Position of segment closest to reference point"
          refVal "Value of segment closest to reference point";

   alias(incStep,incStep1);
*
*  --- fit between approximated u and given one for the given incomes
*
   e_fit ..
         v_fit =E= sum(nApp, sqr( [v_u(nApp) -  p_uw(nApp,"u")]/(p_uw(nApp,"u")+0.5) * sqrt(0.5*card(nApp)/abs(nApp.pos - card(nApp)/2))  ))/card(nApp) * 100000 ;
*
*  --- income on each segment of approximated utility function bounded by segment and realized income
*
   e_u(nApp) .. v_u(nApp) =E= sum(incStep, (v_incStep(incStep,nApp)-v_incStep(incStep-1,nApp))*v_approx(incStep,"fstDeriv"));
*
*  --- define the step in the segment as the smaller of the segment limit and current income
*
   e_incStep(incStep,nApp) .. v_incStep(incStep,nApp) =E= min(v_approx(incStep,"segment"),v_inc.l(nApp));
*
*  --- define the step in the segment as the smaller of the segment limit and current income
*
   e_curv(incStep) $ (incStep.pos gt 2) ..
                                         v_approx(incStep,"fstDeriv")    * ( 1 $ (incStep.pos le refPos)
                                                                            -1 $ (incStep.pos gt refPos))
                                     =G= v_approx(incStep-1,"fstDeriv")  * ( 1 $ (incStep.pos le refPos)
                                                                            -1 $ (incStep.pos gt refPos));
*
*  --- ensure some minimum positive distance between two follow-up segment
*
   e_order(incStep) $ (incStep.pos gt 1)     .. v_approx(incStep,"segment") =G= v_approx(incStep-1,"segment") + 0.01 * p_spread/card(incStep);
*
*  --- ensure that follow-up approximated utility estimates differ at least by 1
*
   e_orderU(nApp) $ (nApp.pos gt 1)      .. v_u(nApp) =G= v_u(nApp-1)+0.5;

   model fitApprox / e_fit,e_incStep,e_u,e_order,e_orderU,e_curv /;
*
*  --- fix income to given obs
*
   v_inc.fx(nApp) = p_uw(nApp,"w");
*
*  --- start point for the approximated utility is the given value on the utility function
*
   v_u.l(nApp)    = p_uw(nApp,"u");
*
*  --- Use same approach as for p_uw to define income steps to start with
*      for card(incstep) approximation point
*
   v_approx.l(incStep,"segment") =  p_spread / [card(incStep)-3] *  (incStep.pos-2) - p_spread/2;
   v_approx.l(incStep,"segment") $ (incStep.pos eq 1)             = -p_spread;
   v_approx.l(incStep,"segment") $ (incStep.pos eq card(incStep)) = +p_spread;
*
   parameter p_best "Next best value on the set of points on the true utility function";
   set bestFit(incStep,n) "Best approximation point set";
*
*  --- minimum absolute distane for a simulated pay-off on the TK utility function
*
   p_best(incStep) = smin(nApp, abs(p_uw(nApp,"w")+1.E-3*nApp.pos -v_approx.l(incStep,"segment") ));
*
*  --- use the related point to populate the link set
*
   bestFit(incStep,nApp) $ [abs(p_uw(nApp,"w")+1.E-3*nApp.pos -v_approx.l(incStep,"segment") ) eq p_best(incStep)]  = yes;
*
*  --- starting point for the first derivative is the differnce quotient on the TK utility curve for the best point
*
   v_approx.l(incStep,"fstDeriv") =  [sum(bestFit(incStep,nApp), p_uw(nApp,"u")) - sum(bestFit(incStep-1,nApp), p_uw(nApp,"u"))]
                                    /[sum(bestFit(incStep,nApp), p_uw(nApp,"w")) - sum(bestFit(incStep-1,nApp), p_uw(nApp,"w"))];
*
*  --- fix segment closest to reference point, used
*
   refVal = sum(incStep $ ( abs(v_approx.l(incstep,"segment")) eq smin(incStep1,abs(v_approx.l(incstep1,"segment")))), v_approx.l(incstep,"segment"));
   refPos = sum(incStep $ (v_approx.l(incstep,"segment") eq refVal), incStep.pos);

   v_approx.fx(incStep,"segment") $ (incStep.pos eq refPos)  = v_approx.l(incstep,"segment");
*
*  --- the risk utility function must be increaesing in the pay-off in each point
*
   v_approx.lo(incStep,"fstDeriv") = 1.E-6;
*
*  --- define the increment steps at the start value
*
   v_incStep.l(incStep,nApp) = min(v_approx.l(incStep,"segment"),v_inc.l(nApp));
*
*  --- and calculate from there the approximated utility
*
   v_u.l(nApp)               = sum(incStep, (v_incStep.l(incStep,nApp)-v_incStep.l(incStep-1,nApp))*v_approx.l(incStep,"fstDeriv"));
*
*  --- and the fit to minimize
*
   v_fit.l =sum(nApp, sqr( [v_u(nApp) -  p_uw(nApp,"u")]/(p_uw(nApp,"u")+0.5) * sqrt(0.5*card(nApp)/abs(nApp.pos - card(nApp)/2))  ))/card(nApp) * 100000 ;

   $$batinclude 'util/title.gms' "'%titlePrefix% Estimate piece-wise approximation of utitlity function'"
*
*  --- try to improve
*
   $$ifi exist "c:/scrdir/fitApprox.gdx" execute_load "c:/scrdir/fitApprox.gdx" v_u,v_approx,v_fit,v_incStep;
   solve fitApprox using DNLP minimizing v_fit;
   execute_unload "c:/scrdir/fitApprox.gdx" v_u,v_approx,v_fit,v_incStep;
*
*  --- report fit (approximate u, true derivative, approximated derivative)
*
   p_uw(nApp,"u*")    = v_u.l(nApp);
   p_uw(nApp,"df")    = (p_uw(nApp,"u")-p_uw(nApp-1,"u"))/(p_uw(nApp,"w")-p_uw(nApp-1,"w"));
   p_uw(nApp,"df*")   = (v_u.l(nApp)-v_u.l(nApp-1))      /(p_uw(nApp,"w")-p_uw(nApp-1,"w"));
   p_uw(nApp,"%Diff") $ p_uw(nApp,"u") = (p_uw(nApp,"u*")-p_uw(nApp,"u")) /p_uw(nApp,"u") * 100;
   display p_uw;
   execute_unload "%scrdir%/p_uw.gdx" p_uw;
   $$onorder
*
*  --- Fix approximation results
*
   p_approx(incStep,fudg) = v_approx.l(incStep,fudg);

   option kill=nApp;
   nApp(n) $ (n.pos le 2)  = YES;
   option kill=v_inc.l,kill=v_incStep.l;

*
*  --- store the true risk utility function at the segment
*
   p_approx(incStep,"u")  =                  [  v_approx.l(incStep,"segment") **%TKAlpha%]  $ (v_approx.l(incStep,"segment") gt 0)
                                %TKgamma%  * [(-v_approx.l(incStep,"segment"))**%TKBeta% ]  $ (v_approx.l(incStep,"segment") lt 0);
*
*  --- upper limits for weigths attached to segment
*
   v_wgtIncStep.up(nCur,incStep)      = 1;
   v_wgtIncStepSOS2.up(nCur,incStep)  = 1;
*
*  --- define shifter into positive domain for e_deltaMax equations
*
   alias(incStep,incStep1);
*
*  --- remove other terms from risk models
*
   v_expShortFall.fx  = 0;
*
*  -----------------------------------------------------------------------------
*
*     Solve CPT model
*
*  -----------------------------------------------------------------------------
*
   parameter p_probCum(n)  "Cumulative probabilities"
             p_statsRound          "Reporting error for repeated solves";
*
*
*  --- redefine probabilities by TK weighting function
*
   scalar p_delta / %TKDelta% /;
*
*  --- solve with updated weights until order does not change
*
   scalar continue / 1 /;
*
*  --- node with the next lower cumulative probabilities
*
   parameter p_nextLower(n)
             p_nextHigher(n);
*
*   --- initialize variables in stochastic programming module
*       from risk-neutral solution
*
*   --- store risk neutral solution for later reporting
*
*
   v_objeN.scale(nCur) = v_objeN.l(nCur);


   $$ondotl

   p_probCum(ncur) $ (nCur.pos le card(nCur)/2) = (nCur.pos)/card(nCur);
   p_probCum(ncur) $ (nCur.pos gt card(nCur)/2) = 0.5 - (nCur.pos-card(nCur)/2)/card(nCur);
*
*  --- apply TK weighting function to the cummulative probabilities
*
   p_weights(nCur) = p_probCum(nCur);

$offorder

   p_weights(nCur)  = p_weights(nCur)**p_delta
                 / [  p_weights(nCur)**p_delta + [(1 - p_weights(nCur))**p_delta] $ (p_weights(nCur) le 1)  ]**(1/p_delta);

*
*   --- loss part (> 50%): subtract from next higher
*
   p_weights(nCur) $ (p_probCum(nCur) le 0.5)
         =     (p_weights(nCur)  - p_weights(nCur-1))
              /(p_probCum(nCur)  - p_probCum(nCur-1)) * p_probN(nCur);
*
*   --- gain part (> 50%): subtract from next higher
*
    p_weights(nCur) $ ((p_probCum(nCur) gt 0.5) $ (p_probCum(nCur) le 0.999))
     =     (-p_weights(nCur)    + p_weights(nCur+1))
          /(p_probCum(nCur)     - p_probCum(nCur+1)) * p_probN(nCur);
*
*  --- replace probabilities by weights, and rescale to unity
*
   p_weights(nCur) = p_weights(nCur)/sum(nCur1,p_weights(nCur1));
*
   v_wgtIncStep(nCur,incStep) = 0;
   v_wgtIncStep(nCur,incStep) $ ( ( ( [v_objeN(nCur)-p_refPoint] ge p_approx(incStep-1,"segment")) or (incStep.pos eq 1))
                                and ( [v_objeN(nCur)-p_refPoint] le p_approx(incStep,"segment"))) = 1;

*
*
*  --- set the interpolation weight for this segment (upper limit of interpolation range)
*
   v_wgtIncStep(nCur,incStep) $ v_wgtIncStep(nCur,incStep)
     =   [v_objeN(nCur)-p_refPoint-p_approx(incStep-1,"segment")]
        /[p_approx(incStep,"segment")-p_approx(incStep-1,"segment")];

   v_wgtIncStepSOS2(nCur,incStep) = 0;
   v_wgtIncStepSOS2(nCur,incStep)   $ v_wgtIncStep(nCur,incStep) = 1;
   v_wgtIncStepSOS2.up(nCur,incStep) = 1;
*
*  --- the remainder of the interpolation weight goes to the lower limit
*
   v_wgtIncStep(nCur,incStep-1) $ v_wgtIncStep(nCur,incStep) = 1- v_wgtIncStep(nCur,incStep);
*
*  --- calculated the approximated risk utility for each future
*
   v_uApproxN(nCur) = sum(incStep, v_wgtIncStep(nCur,incStep)*p_approx(incStep,"u"));
*  v_isLoss(nCur) = 1 $ (v_uApproxN(nCur) le 0);

   parameter p_uA(n);
   p_uA(nCur) = v_uApproxN(ncur);
*   --- sort symbol; permutation index will be named A also

*  --- load the permutation index
   Parameter AIndex(n);
   $$libinclude rank p_Ua nCur AIndex
* --- create a sorted version
  option kill=v_uApproxS;
  v_uApproxS(nCur + (AIndex(ncur) - ord(nCur))) = p_ua(ncur);
  v_permVal(nCur,nCur1)     $ (v_uApproxS(ncur) eq v_uApproxN(nCur1)) = v_uApproxN(nCur1);
  v_permVal.up(nCur,nCur1)   = smax(incStep,p_approx(incStep,"u"));
  v_permVal.lo(nCur,nCur1)   = smin(incStep,p_approx(incStep,"u"));
  option kill=v_permMat;
  v_permMat.l(nCur,nCur1) $ v_permVal(nCur,nCur1) = 1;
  v_permMat.up(nCur,nCur1) = 1;

$onorder

    p_statsRound("riskNeutr","NPV",nCur) =  v_objen.l(nCur);
    p_statsRound("riskNeutr","u",nCur)   =  v_uApproxN(nCur);
*
*  --- initalize total subjective expected utility
*
   v_objeN.lo(nCur) = v_objeN.l(nCur) - 8000;
   v_objeN.up(nCur) = v_objeN.l(nCur) + 8000;

   v_uApproxN.lo(nCur) =                [  (v_objeN.lo(nCur)-p_refPoint) **%TKAlpha%] $ ((v_objeN.lo(nCur)-p_refPoint) gt 0)
                           %TKgamma%  * [(-(v_objeN.lo(nCur)-p_refPoint))**%TKBeta% ] $ ((v_objeN.lo(nCur)-p_refPoint) lt 0);


   v_uApproxN.up(nCur) =                [  (v_objeN.up(nCur)-p_refPoint) **%TKAlpha%] $ ((v_objeN.up(nCur)-p_refPoint) gt 0)
                           %TKgamma%  * [(-(v_objeN.up(nCur)-p_refPoint))**%TKBeta% ] $ ((v_objeN.up(nCur)-p_refPoint) lt 0);


   v_uApprox        = sum(nCur, v_uApproxS(nCur)*p_weights(nCur));
   v_uApprox.lo     = v_uApprox.l;
   v_obje           = v_uApprox;
*
*   --- solve the model with the risk utility function approximation, using the weights
*       instead of the objective probabilities
*
$batinclude 'util/title.gms' "'%titlePrefix% Solve model as %MIP% with CPT at fixed weights'"
    v_permMat.fx(nCur,nCur1) = v_permMat.l(nCur,nCur1);
*    $$setglobal useMip off
    $$ifi not %useMIP%==on option %RMIP%=CONOPT4;m_farm.iterlim = 0;
    $$ifi     %useMIP%==on   solve m_farm using %MIP% maximizing v_obje;
    $$ifi not %useMIP%==on   solve m_farm using %RMIP% maximizing v_obje;
    $$batinclude 'solve/trackStat.gms' fixedWgts

    p_statsRound("fixedWgts","NPV",nCur) =  v_objen.l(nCur);
    p_statsRound("fixedWgts","u",nCur)   =  v_uApproxN(nCur);

    v_permMat.up(nCur,nCur1)   = 1;
    v_permMat.lo(nCur,nCur1)   = 0;
   v_uApproxN(ncur) = v_uApproxN(ncur) + uniform(-1.E-6,+1.E-6);
*  v_isLoss(nCur) = 1 $ (v_uApproxN(nCur) le 0);
   p_uA(nCur) = v_uApproxN(ncur);
*   --- sort symbol; permutation index will be named A also
   $$libinclude rank p_Ua nCur AIndex
   option kill=v_uApproxS;
   $$offorder
   v_uApproxS(nCur + (AIndex(ncur) - ord(nCur))) = p_ua(ncur);

   option kill=v_permVal.L;
   v_permVal(nCur,nCur1)     $ (v_uApproxS(ncur) eq v_uApproxN(nCur1)) = v_uApproxN(nCur1);
   v_permVal.up(nCur,nCur1)   = smax(incStep,p_approx(incStep,"u"));
   v_permVal.lo(nCur,nCur1)   = smin(incStep,p_approx(incStep,"u"));
   v_permMat.prior(nCur,nCur1) = v_permMat.l(nCur,nCur1);
   option kill=v_permMat;
   v_permMat.l(nCur1,nCur)  $ v_permVal(nCur1,nCur) = 1;

   if (sum((nCur1,nCur) $ (v_permMat.l(nCur1,nCur) ne v_permMat.prior(nCur1,nCur)),1),
       option kill=v_permMat.prior;
*
*      --- initalize total subjective expected utility
*
       v_objeN.lo(nCur) = v_objeN.l(nCur) - 6000;
       v_objeN.up(nCur) = v_objeN.l(nCur) + 6000;

       v_uApproxN.lo(nCur) =                [  (v_objeN.lo(nCur)-p_refPoint) **%TKAlpha%] $ ((v_objeN.lo(nCur)-p_refPoint) gt 0)
                              %TKgamma%  * [(-(v_objeN.lo(nCur)-p_refPoint))**%TKBeta% ] $ ((v_objeN.lo(nCur)-p_refPoint) lt 0);


       v_uApproxN.up(nCur) =                [  (v_objeN.up(nCur)-p_refPoint) **%TKAlpha%] $ ((v_objeN.up(nCur)-p_refPoint) gt 0)
                              %TKgamma%  * [(-(v_objeN.up(nCur)-p_refPoint))**%TKBeta% ] $ ((v_objeN.up(nCur)-p_refPoint) lt 0);

       v_uApproxS.lo(nCur + (AIndex(ncur) - ord(nCur))) =  v_uApproxN.lo(nCur);
       v_uApproxS.up(nCur + (AIndex(ncur) - ord(nCur))) =  v_uApproxN.up(nCur);

       v_wgtIncStep.fx(nCur,incStep) $ (p_approx(incStep+1,"u") lt v_uApproxN.lo(nCur))  = 0;
       v_wgtIncStep.fx(nCur,incStep) $ (p_approx(incStep-1,"u") gt v_uApproxN.up(nCur))  = 0;

       v_wgtIncStepSOS2.fx(nCur,incStep) $ (p_approx(incStep+1,"u") lt v_uApproxN.lo(nCur))  = 0;
       v_wgtIncStepSOS2.fx(nCur,incStep) $ (p_approx(incStep-1,"u") gt v_uApproxN.up(nCur))  = 0;

       v_permVal.fx(ncur,nCur1) $ (v_uApproxs.lo(nCur) gt v_uApproxN.up(nCur1)) = 0;
       v_permVal.fx(ncur,nCur1) $ (v_uApproxs.up(nCur) lt v_uApproxN.lo(nCur1)) = 0;

       v_permMat.fx(ncur,nCur1) $ (v_uApproxs.lo(nCur) gt v_uApproxN.up(nCur1)) = 0;
       v_permMat.fx(ncur,nCur1) $ (v_uApproxs.up(nCur) lt v_uApproxN.lo(nCur1)) = 0;


       v_uApprox        = sum(nCur, v_uApproxS(nCur)*p_weights(nCur));
       v_uApprox.up     = sum(nCur, v_uApproxS.up(nCur)*p_weights(nCur));
       v_uApprox.lo     = v_uApprox.l;
       v_obje           = v_uApprox;
       $$ifi not %useMIP%==on option %RMIP%=CONOPT4;m_farm.iterlim = 0;
       $$batinclude 'util/title.gms' "'%titlePrefix% Solve model as %MIP% with CPT'"
       $$ifi     %useMIP%==on   solve m_farm using %MIP% maximizing v_obje;
       $$ifi not %useMIP%==on   solve m_farm using %RMIP% maximizing v_obje;
       $$batinclude 'solve/trackStat.gms' CPT
       $$ifi not %useMIP%==on abort "test";
    );
       $$onorder

    p_statsRound("CPT","NPV",nCur) =  v_objen.l(nCur);
    p_statsRound("CPT","u",nCur)   =  v_uApproxN(nCur);
*
*        --- report NPVs for each future and total approximated utility
*

 execute_unload "%scrdir%/trackStat.gdx" p_trackStat
    $$ifi defined p_statsRound p_statsRound
    $$ifi defined p_cropIns p_cropIns,p_testIns
  ;


*
*  --- copy from non-state contigent to all futures
*
$$ifi "%stochProg%"=="true" $include 'model/copy_stoch.gms'

$batinclude 'exploiter/store_res.gms' '"CPT"' '"%exploiterDim2%"' full
$batinclude 'exploiter/gen_sumres.gms' '"CPT"' "'%exploiterDim2%'"
*
*  --- put statistics to listing
*
   display p_statsRound;
