********************************************************************************
$ontext

   FarmDyn project

   GAMS file : LOAD_CALIB.GMS

   @purpose  : Load results from previous calibration
   @author   : W.Britz
   @date     : 08.03.21
   @since    :
   @refDoc   :
   @seeAlso  : calib\calib.gms
   @calledBy : exp_starter.gms

$offtext
********************************************************************************

$ifi not exist '%resdir%/calib/%calibRes%.gdx' $abort "calibration file is missing : %resdir%/calib/%calibRes%.gdx"

*
* --- reset sets defined by heuristics, will be empty
*
  option kill=c_p_t_i,kill=curCrops,kill=curProds,kill=curInputs,kill=curFeeds,kill=curMachines,kill=curInv,kill=possacts;
  $$ifi defined herds     option kill=actherds,kill=possHerds;
  $$ifi defined actherdsf option kill=actHerdsf;
  execute_loadpoint '%resdir%/calib/%calibRes%.gdx'
*
* --- load parameters from calibration
*
                                     p_vCostC,p_oCoeffC,p_oCoeffM,
    $$ifi defined p_reqsPhaseMonths  p_reqsPhaseMonths,
    $$ifi defined p_herdLab          p_herdLab,
    $$ifi defined p_feedReqPig       p_feedReqPig
    $$ifi defined p_vCost            p_vCost
                                     p_price,p_costQuant,p_inputPrice,p_cropLab,p_vPriceInv,
*
* --- load sets defined by heuristics before calibration, during calibration run
*
                            c_p_t_i,curCrops,curProds,curInputs,curFeeds,curMachines,curInv,possacts
    $$ifi defined herds     actherds,possherds
    $$ifi defined actherdsF actHerdsF
*
* --- load upper limits (mainly zeros) defined by heuristics before calibration, during calibration run
*
    $$ifi defined v_feeding      v_feeding.up,v_feedUse.up
    $$ifi defined v_manDist      v_manDist.up
                                 v_syntDist.up
                  ;

  ;
*
* --- remove any upper limits on production / sold quantities, might not fit into max crop area times now higher yields
*     (same statements also found in calib/calib.gms)
*
 v_saleQuant.up(prodsYearly,curSys,t_n(tCur,nCur)) $ (v_saleQuant.up(prodsYearly,curSys,tCur,nCur) ne 0) = inf;
 v_prods.up(prodsYearly,t_n(tCur,nCur))            $ (v_prods.up(prodsYearly,tCur,nCur) ne 0)            = inf;

$$ifi defined aesCrops c_p_t_i(aesCrops,plot,"plough","normal") $ plot_landType(plot,"arab") = YES;curCrops(aesCrops) =YES;


