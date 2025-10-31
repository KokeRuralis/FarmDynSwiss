********************************************************************************
$ontext

   FarmDyn project

   GAMS file : STOCHPROG_MODULE.GMS

   @purpose  : Variables and equations found in stochastic programming
               module
   @author   :
   @date     : 03.03.18
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************

  scalar
     p_objeRMIP               "Objective of RMIP solve, serves as BIM" / 1.E+7/
     p_npvAtRiskLim           "Threshold for NPV at risk"              / 0 /
     p_npvAtRiskMaxProb       "Threshold for prob of NPV at risk"      / 0 /
     p_maxShortFall           "Max mean shortfall"                     / 0 /
     p_approxUtil             "Expected approximated utility"          / 0 /
  ;

  parameter
     p_cropIns(crops,sys,t,n)  "Crop insurance: premiums minus indemnities"
  ;

  Variables
     v_shortFall(n)           "Negative deviation from target under MOTAD or conditonal var at risk, NPV for critical nodes for exp. shortfall"
     v_bestShortFall          "Max of conditional var at risk"
     v_expShortFall           "Mean of conditional var at risk"
     v_uApprox                "Approximated expected utility"
  ;

  Positive variables
     v_negDevNpv(n)           "Negative deviation for NPV at leaf n from simulated mean"
     v_expNegDevNpv           "Expected mean negative deviation for NPV at leaf n from simulated mean"
     v_slackNpv(n)
     $$iftheni.stochYield "%stochYields%"=="true"
        v_buyCropIns(crops,sys,t)
     $$endif.stochYield
     $$ifi %MIP%==on   binary variable
     v_npvAtRisk(n)           "Binary trigger for NPV at mnode n undercutting pre-defined limit"
  ;

   v_uApprox.fx      = 0;
   v_expShortFall.fx = 0;


  $$iftheni.dyn "%dynamics%" == "Comparative-static"
*
*    --- in comparative-static mode, the outcome for the final nodes are treated like SON for the one optimization period
*       The following equations ensure that same investments and basic farm program across SONs
*
     equations
        e_samebuyBuildingsF(buildings,t,n)
        e_sameHireWorkers(t,n)
        e_sameLandBuy(plot,t,n)
     ;
*
*    --- the following equations should help the solver to substitute out binaries
*
     e_sameBuyBuildingsF(curBuildings(buildings),t_n(tCur,nCur)) $ (v_buyBuildings.up(buildings,tCur,nCur) ne 0) ..

         v_buyBuildingsF(buildings,tCur,nCur) =E= sum(nCur1 $ (nCur1.pos eq 1), v_buyBuildingsF(buildings,tCur,nCur1));


     $$iftheni.hire "%allowHiring%"=="true"

       e_sameHireWorkers(t_n(tCur,nCur)) $ (v_hireWorkers.range(tCur,nCur) ne 0)  ..

          v_hireWorkers(tCur,nCur) =E= sum(nCur1 $ (nCur1.pos eq 1), v_hireWorkers(tCur,nCur1));

     $$endif.hire

     $$iftheni.landBuy "%landBuy%"=="true"

       e_sameLandBuy(plot,t_n(tCur,nCur)) $ (v_buyPlot.range(plot,tCur,nCur) ne 0)  ..

          v_buyPlot(plot,tCur,nCur) =E= sum(nCur1 $ (nCur1.pos eq 1), v_buyPlot(plot,tCur,nCur1));

     $$endif.landbuy

     $$iftheni.herd "%herd%"=="true"

        equations

          e_sameBuyStablesF(stables,hor,t,n)
          e_sameBuySilosF(manChain,silos,t,n)
        ;
*
*       --- the following equations should help the solver to substitute out binaries
*
        e_sameBuySilosF(curManChain(manChain),silos,t_n(tCur,nCur)) $ (v_buySilos.up(manChain,silos,tCur,nCur) ne 0) ..

            v_buySilosF(manChain,silos,tCur,nCur) =E= sum(nCur1 $ (nCur1.pos eq 1), v_buySilosF(manChain,silos,tCur,nCur1));

        e_sameBuyStablesF(stables,hor,t_n(tCur,nCur)) $  (v_buyStables.up(stables,hor,tCur,nCur) ne 0) ..

            v_buyStablesF(stables,hor,tCur,nCur) =E= sum(nCur1 $ (nCur1.pos eq 1), v_buyStablesF(stables,hor,tCur,nCur1));
     $$endif.herd

     model m_fixSons /
                                      e_samebuyBuildingsF
        $$ifi "%allowHiring%"=="true" e_sameHireWorkers
        $$ifi "%landBuy%"=="true"     e_sameLandBuy
        $$ifi "%herd%"=="true"        e_sameBuyStablesF,e_sameBuySilosF

     /;
  $$endif.dyn

  $$iftheni.riskModel "%RiskModel%" == "Estimated utility function"

     v_uApprox.lo = -inf;
     v_uApprox.up = +inf;

     set fudg / segment,fstDeriv,u /;


     $$evalglobal nApproxUtilSegments floor(%nApproxUtilSegments%/2)*2+1
     set incStep "Steps in linear approximation of utility function" / step1*step%nApproxUtilSegments% /;
     alias(incStep,incStep1);

     parameter
        p_approx(incStep,fudg) "Point and first derivatives of linear approximation curve, fixed in simulation"
        p_weights(n)           "Subjective weights for futures"
     ;

     option kill=p_approx,kill=p_weights;

     scalar p_refPoint / 0 /, refPos / 0 /;

     equations
        e_sumWgtIncStep(n)             "The weights for each node must add up to unity"
        e_sumWgtIncStepSOS2(n)         "The weights for each node must add up to unity"
        e_WgtIncStep1(n,incStep)       "The weights for each node must add up to unity"
        e_WgtIncStep2(n,incStep)       "The weights for each node must add up to unity"
        e_WgtIncStep3(n,incStep)       "The weights for each node must add up to unity"
        e_defSegment(n)                "The weights recover exactly the income"
        e_defSegment1SOS2(n)           "The weights recover exactly the income"
        e_defSegment2SOS2(n)           "The weights recover exactly the income"
        e_uApproxN(n)                  "Approximated value of utility function for each node"
        e_uApprox                      "Expected approximated value of utility function"
        e_buyCropIns1(crops,sys,t,n)   "Buying of crop insurance"
        e_buyCropIns2(crops,sys,t,n)   "Buying of crop insurance"
        e_buyCropIns3(crops,sys,t,n)   "Buying of crop insurance"
        e_wgtConcaveComb(incStep,n)
        e_coverCropIns(crops,sys,t,n)  "Buying of crop insurance"

        e_addUpPermMat1(n)             "Sum of permutation over columns equal 1"
        e_addUpPermMat2(n)             "Sum of permutation over rows equal 1"
        e_permValZero1(n,n)            "Permval is zero if related permutation matrix entry is zero, otherwise can be max"
        e_permValZero2(n,n)            "Permval is zero if related permutation matrix entry is zero, otherwise can be min"
        e_uApproxS(n)                  "Assign sorted value"
        e_uApproxNS(n)                 "Define approximated utility from permat"
        e_sortOrder(n)                 "Sorting condition"
     ;

     variables
        v_uApproxN(n)              "Approximated utility, by node"
        v_uApproxS(n)              "Approximated utility, by node, sorted"
        v_buyCropInsN(crops,sys,t) "Buying of crop insurance"
        v_permVal(n,n)             "Intermediate sort expression, for v_uApprox * v_permMat"
     ;

     positive variables
        v_buyCropIns(crops,sys,t)  "Buying of crop insurance"
     ;
     binary variables v_coverCropIns(crops,sys,t);

     positive variables   v_wgtIncStep(n,incStep) "Indicator value if current segment is active";
     ;
*
*    --- attention the right-most index depicts the SOS2 set, here, at most tow consecutive
*        segments can be active
*
     binary      variables  v_wgtIncStepSos2(n,incStep) "Indicator value if current segment is active";
     binary      variables  v_permMat(n,n);

     option kill=v_permMat;
     option kill=v_uApproxN;
     option kill=v_uApproxS;
     option kill=v_wgtIncStep;
*
     e_addUpPermMat1(nCur) $ p_approxUtil  ..
         sum(nCur1, v_permMat(ncur,nCur1)) =E= 1;

     e_addUpPermMat2(nCur) $ p_approxUtil ..
         sum(nCur1, v_permMat(ncur1,nCur)) =E= 1;

     e_permValZero1(nCur,nCur1) $ p_approxUtil    ..
          v_permVal(nCur,nCur1) =L= v_permMat(nCur,nCur1) * min(smax(incStep,p_approx(incStep,"u")),v_uApproxN.up(nCur1),v_uApproxS.up(nCur));

     e_permValZero2(nCur,nCur1) $ p_approxUtil  ..
          v_permVal(nCur,nCur1) =G= v_permMat(nCur,nCur1) * max(smin(incStep,p_approx(incStep,"u")),v_uApproxN.lo(nCur1),v_uApproxS.lo(nCur));


     e_uApproxS(nCur) $ p_approxUtil  ..
         v_uApproxS(nCur) =E= sum(nCur1, v_permVal(nCur,nCur1));

     e_uApproxNS(nCur) $ p_approxUtil  ..
         v_uApproxN(nCur) =E= sum(nCur1, v_permVal(nCur1,nCur));

     $$offorder
     e_sortOrder(nCur) $ ((nCur.pos gt 1) $ p_approxUtil) ..
         v_uApproxS(nCur) =g= sum(nCur1 $ (nCur1.pos eq nCur.pos-1), v_uApproxS(nCur1));
     $$onorder
*
     e_wgtConcaveComb(incStep,nCur) $ (p_approxUtil $ (v_wgtIncStep.range(nCur,incStep) ne 0)) ..

         sum(incStep1 $ ((incStep1.pos lt incStep.pos-1) or (incStep1.pos gt incStep.pos)), v_wgtIncStep(nCur,incStep1))
            =L= 1 - v_wgtIncStepSOS2(nCur,incStep);
*
*    --- SOS vars must add up to one
*
     e_sumWgtIncStepSOS2(nCur)  $ p_approxUtil ..

       sum(incStep, v_wgtIncStepSOS2(nCur,incStep)) =E= 1;
*
*    --- the weights are restricted by the binaries
*
     e_WgtIncStep1(nCur,incStep)  $ (p_approxUtil $ (v_wgtIncStep.range(nCur,incStep) ne 0)) ..

       v_wgtIncStep(nCur,incStep)  =L= v_wgtIncStepSOS2(nCur,incStep) + v_wgtIncStepSOS2(nCur,incStep+1);

     e_WgtIncStep2(nCur,incStep)  $ (p_approxUtil $ (     (v_wgtIncStep.range(nCur,incStep) ne 0)
                                                       or (v_wgtIncStep.range(nCur,incStep-1) ne 0))) ..

       v_wgtIncStep(nCur,incStep)+v_wgtIncStep(nCur,incStep-1)  =L= v_wgtIncStepSOS2(nCur,incStep-1)+ v_wgtIncStepSOS2(nCur,incStep) + v_wgtIncStepSOS2(nCur,incStep+1);

     e_WgtIncStep3(nCur,incStep)  $ (p_approxUtil $ ((v_wgtIncStep.range(nCur,incStep) ne 0) or (v_wgtIncStep.range(nCur,incStep-1) ne 0))) ..

       v_wgtIncStep(nCur,incStep)+v_wgtIncStep(nCur,incStep-1)  =G=  v_wgtIncStepSOS2(nCur,incStep) ;
*
*    --- weight must add up to unity
*
     e_sumWgtIncStep(nCur)  $ p_approxUtil ..

       sum(incStep, v_wgtIncStep(nCur,incStep)) =E= 1;
*
*    --- the weights recover the payoff
*
     e_defSegment(nCur)  $ p_approxUtil ..

       v_objeN(nCur) - p_refPoint =E= sum(incStep, v_wgtIncStep(nCur,incStep)*p_approx(incStep,"segment"));

     e_defSegment1SOS2(nCur)  $ p_approxUtil ..

       v_objeN(nCur) - p_refPoint =L= sum(incStep, v_wgtIncStepSOS2(nCur,incStep)*p_approx(incStep,"segment"));

     e_defSegment2SOS2(nCur)  $ p_approxUtil ..

       v_objeN(nCur) - p_refPoint =G= sum(incStep, v_wgtIncStepSOS2(nCur,incStep)*p_approx(incStep-1,"segment") - inf $ (incStep.pos eq 1));
*
*    --- approximated utility for each node (linear interpolation between two points on curve)
*
     e_uApproxN(nCur) $ p_approxUtil ..

       v_uApproxN(nCur) =E= sum(incStep, v_wgtIncStep(nCur,incStep)*p_approx(incStep,"u"));
*
*    --- expected approximated utility, using the subjective weights
*
     e_uApprox  $ p_approxUtil ..

       v_uApprox       =E= sum(nCur, v_uApproxS(nCur)*p_weights(nCur));
*
*    --- crop insurance per crop cannot exceed crop acreage
*
     e_buyCropIns1(curCrops,sys,t_n(tCur,nCur)) $ sum(c_p_t_i(curCrops,plot,till,intens) $ sys_till(sys,till),p_cropIns(curCrops,sys,tCur,nCur)) ..

        v_buyCropInsN(curCrops,sys,tCur) + (1-v_coverCropIns(curCrops,sys,tCur))*v_sumCrop.up(curCrops,sys,tCur,nCur)
               =E= v_sumCrop(curCrops,sys,tCur,%nCur%);

     e_buyCropIns2(curCrops,sys,t_n(tCur,nCur)) $ sum(c_p_t_i(curCrops,plot,till,intens) $ sys_till(sys,till),p_cropIns(curCrops,sys,tCur,nCur)) ..

        v_buyCropIns(curCrops,sys,tCur)
               =G= v_buyCropInsN(curCrops,sys,tCur);

     e_buyCropIns3(curCrops,sys,t_n(tCur,nCur)) $ sum(c_p_t_i(curCrops,plot,till,intens) $ sys_till(sys,till),p_cropIns(curCrops,sys,tCur,nCur)) ..

        v_buyCropIns(curCrops,sys,tCur)
               =L= v_sumCrop(curCrops,sys,tCur,%nCur%);

     e_coverCropIns(curCrops,sys,t_n(tCur,nCur)) $ sum(c_p_t_i(curCrops,plot,till,intens) $ sys_till(sys,till),p_cropIns(curCrops,sys,tCur,nCur)) ..

        v_coverCropIns(curCrops,sys,tCur)*v_sumCrop.up(curCrops,sys,tCur,nCur) =G= v_buyCropIns(curCrops,sys,tCur);


     model m_stochProg /

         $$ifi "%dynamics%" == "Comparative-static" m_fixSons
         e_wgtIncStep1
         e_wgtIncStep2
         e_wgtIncStep3
         e_wgtConcaveComb
         e_sumWgtIncStepSOS2
         e_sumWgtIncStep
         e_defSegment
         e_defSegment1SOS2
         e_defSegment2SOS2
         e_uApproxN
         e_uApprox
*         e_buyCropIns1
*         e_buyCropIns2
         e_buyCropIns3
*         e_coverCropIns
         e_addUpPermMat1
         e_addUpPermMat2
         e_permValZero1
         e_permValZero2
         e_uApproxS
         e_uApproxNS
         e_sortOrder
       /;

   $$else.riskModel
*
*     --- all other risk-behavioral options (no CPT)
*

      Equations

         npvAtRisk_(n)            "Definition of binary trigger which indicates that NPV of leave undercuts limit"
         maxProbNpvAtRisk_        "Constraint that probability weighted sum of v_varAtRisk triggers cannot exceed given prob threshold"
         negDevNpv_(n)            "Negative deviation for NPV at leaf n from simulated mean"
         expNegDevNpv_            "Expected mean negative deviation for NPV at leaf n from simulated mean"
         shortFall_(n)            "Negative deviation for NPV at leaf n from target MOTAD"
         maxShortFall_            "Maximum shortfall constraint"
         shortFallTrigger1_(n)
         shortFallTrigger2_(n)
         shortFallTrigger3_(n)
         shortFallTrigger4_(n)
         shortFallBound_(n)       "NPV leaf can only undercut best shortfall if v_npvAtRisk binary is active"
         expShortFall_            "Expected mean shortfall"
      ;
*
*     --- binary trigger for npv of each final leaf to undercut pre-defined lower limit
*
      npvAtRisk_(nCur) $ (t_n("%lastYearCalc%",nCur) $ (p_npvAtRiskLim gt 1))  ..

         v_objeN(nCur) =G= p_npvAtRiskLim - v_npvAtRisk(nCur) * p_npvAtRiskLim;

*
*     --- sum of probabilities of leaves under cutting pre-defined lower limit of NPV
*         is not allowed to exceed a certain threshold probability p_maxProb
*
      maxProbNpvAtRisk_ $ ( ( (p_npvAtRiskLim gt 1) or p_expShortFall) $ p_npvAtRiskmaxProb) ..

         sum(t_n("%lastYearCalc%",nCur), v_npvAtRisk(nCur) * p_probN(nCur)) =L= p_npvAtRiskmaxProb;
*
*     --- Expected shortFall is zero if the related trigger v_npvAtRisk is not set
*
      shortFallTrigger1_(nCur) $ ( t_n("%lastYearCalc%",nCur) $ p_expShortFall ) ..

         v_shortFall(nCur) =L= p_objeRmip * v_npvAtRisk(nCur);
*
*     --- the shortFall (= NPV) is equal to the objective value for those below 5%
*
      shortFallTrigger2_(nCur) $ ( t_n("%lastYearCalc%",nCur) $ p_expShortFall ) ..

         v_slackNPV(nCur)  =L= p_objeRmip * (1-v_npvAtRisk(nCur));
*
*     --- Expected shortFall is bounded by objective value at that leaf
*         (and exactly equal to it)
*
      shortFallTrigger3_(nCur) $ ( t_n("%lastYearCalc%",nCur) $ p_expShortFall ) ..

         v_shortFall(nCur) + v_slackNPV(nCur) =E= v_objeN(nCur);
*
*     --- Expected shortFall is bounded by the best short fall
*          (that splits the expected NPV in the part below and above the trigger percentage)
*
      shortFallTrigger4_(nCur) $ ( t_n("%lastYearCalc%",nCur) $ p_expShortFall ) ..

         v_shortFall(nCur) =L= v_bestShortFall;
*
*     --- all other cases must exceed the best short fall
*
      shortFallBound_(nCur)  $ ( t_n("%lastYearCalc%",nCur) $ p_expShortFall  ) ..

         v_objeN(nCur)     =G= v_bestShortFall+1 - v_npvAtRisk(nCur) * p_objeRmip;
*
*     --- negative deviaton from NPV
*
      negDevNPV_(nCur) $ t_n("%lastYearCalc%",nCur) ..

          v_objeN(nCur) + v_negDevNPV(nCur)  =G= v_objeMean;
*
*     --- Expected mean deviation
*
      expNegDevNPV_ ..

         v_expNegDevNPV =E= sum(nCur $ t_n("%lastYearCalc%",nCur), v_negDevNPV(nCur)*p_probN(nCur));
*
*     --- negative deviaton from given limit
*
      shortFall_(nCur) $ (t_n("%lastYearCalc%",nCur) $ (p_npvAtRiskLim gt 1))  ..

         v_objeN(nCur) + v_shortFall(nCur) =G= p_npvAtRiskLim;
*
*     --- maximum mean short fall definition
*
      maxShortFall_  $ ( (p_npvAtRiskLim gt 1) $ (p_maxShortFall gt 0) ) ..

         sum(nCur $ t_n("%lastYearCalc%",nCur), v_shortFall(nCur)*p_probN(nCur))
                                                       =L= p_maxShortFall*p_npvAtRiskLim;
*
*     --- Expected shortFall
*
      expShortFall_ $ ( p_expShortFall or p_maxShortFall ) ..

         v_expShortFall =E= sum(nCur $ t_n("%lastYearCalc%",nCur), v_shortFall(nCur)*p_probN(nCur));

      model m_stochProg /

        $$ifi "%dynamics%" == "Comparative-static" m_fixSons

        npvAtRisk_
        maxProbNpvAtRisk_
        negDevNpv_
        expNegDevNpv_
        shortFall_
        maxShortFall_
        shortFallTrigger1_
        shortFallTrigger2_
        shortFallTrigger3_
        shortFallTrigger4_
        shortFallBound_
        expShortFall_

      /;

  $$endif.riskModel
