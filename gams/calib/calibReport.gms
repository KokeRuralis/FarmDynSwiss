********************************************************************************
$ontext

   CAPRI project

   GAMS file : CALIBREPORT.GMS

   @purpose  :
   @author   :
   @date     : 24.09.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************
  $$if not defined reportPrice scalar reportPrice / 0 /;

  p_calibReport("v_obje","","","%1")                = v_obje.l;
  p_calibReport("obje","wages","","%1")        = sum(t_n(tCur,nCur),v_offFarmWages.l(tCur,nCur))/sum(t_n(tCur,nCur),1);
  p_calibReport("obje","opCashFlow","","%1")   = sum(t_n(tCur,nCur),v_opCashFlow.l(tCur,nCur))/sum(t_n(tCur,nCur),1);
  p_calibReport("obje","invCashFlow","","%1")  = sum(t_n(tCur,nCur),v_invCashFlow.l(tCur,nCur))/sum(t_n(tCur,nCur),1);
$ifi defined v_finCashFlow  p_calibReport("obje","finCashFlow","","%1")  = sum(t_n(tCur,nCur),v_finCashFlow.l(tCur,nCur))/sum(t_n(tCur,nCur),1);

  p_calibReport("crops",curCrops,"ha","%1")      $ p_calibReport("crops",curCrops,"ha","target")
       = sum((sys,t_n(tCur,nCur)), v_sumCrop.l(curCrops,sys,tCur,nCur)*p_probN(nCur))/sum(t_n(tCur,nCur),p_probN(nCur));

  p_calibReport("crops",curCrops,"dha","%1")      $ p_calibReport("crops",curCrops,"ha","target")
       = p_calibReport("crops",curCrops,"ha","%1")-p_calibReport("crops",curCrops,"ha","target");

  p_calibReport("crops",curCrops,"d%","%1")      $ (p_calibReport("crops",curCrops,"ha","target") gt eps)
       = [p_calibReport("crops",curCrops,"ha","%1")/p_calibReport("crops",curCrops,"ha","target")-1]*100;

  p_calibReport("crops",curCrops,"yield","%1")      $ p_calibReport("crops",curCrops,"ha","%1")
       = sum( (t_n(tCur,nCur),prodsYearly)
            $ sum((c_p_t_i(curCrops,plot,till,intens),plot_soil(plot,soil)),p_OCoeffC(curCrops,soil,till,intens,prodsYearly,tCur)),
                v_prods(prodsYearly,tCur,nCur))
                /p_calibReport("crops",curCrops,"ha","%1");

  $$ifthen defined v_sumHerd

     p_calibReport("herds",sumHerds,breeds,"%1") $ p_calibReport("herds",sumHerds,breeds,"target")
          = sum(t_n(tCur,nCur), v_sumHerd.l(sumHerds,breeds,tCur,nCur)*p_probN(nCur))/sum(t_n(tCur,nCur),p_probN(nCur));

     p_calibReport("herds",sumHerds,"","%1") $ sum(breeds $ (not sameas(breeds,"")),p_calibReport("herds",sumHerds,breeds,"%1"))
        = sum(breeds $ (not sameas(breeds,"")),p_calibReport("herds",sumHerds,breeds,"%1"));

     p_calibReport("herds",sumHerds,"d%","%1") $ sum(breeds $ (not sameas(breeds,"")),p_calibReport("herds",sumHerds,breeds,"target"))
       =  [ p_calibReport("herds",sumHerds,"","%1")/Sum(breeds $ (not sameas(breeds,"")),p_calibReport("herds",sumHerds,breeds,"target"))-1]*100;

     p_calibReport("herds",sumHerds,"d%","%1") $ p_calibReport("herds",sumHerds,"","target")
       =  [ p_calibReport("herds",sumHerds,"","%1")/p_calibReport("herds",sumHerds,"","target") -1]*100;


  $$endif

  $$ifthen defined v_sumHerd
     p_calibReport("frac",stables,hor,"%1")          = sum(t_n(tCur,nCur),v_buyStablesF.l(stables,hor,tCur,nCur))/sum(t_n(tCur,nCur),1);
     p_calibReport("frac",silos,manChain,"%1")       = sum(t_n(tCur,nCur),v_buySilosF.l(manChain,silos,tCur,nCur))/sum(t_n(tCur,nCur),1);
     p_calibReport("int",stables,hor,"%1")          = sum(t_n(tCur,nCur),v_buyStables.l(stables,hor,tCur,nCur))/sum(t_n(tCur,nCur),1);
     p_calibReport("int",silos,manChain,"%1")       = sum(t_n(tCur,nCur),v_buySilos.l(manChain,silos,tCur,nCur))/sum(t_n(tCur,nCur),1);
  $$endif

  p_calibReport("frac",buildings,"building","%1")    = sum(t_n(tCur,nCur),v_buyBuildingsF.l(buildings,tCur,nCur))/sum(t_n(tCur,nCur),1);
  p_calibReport("int",buildings,"building","%1")    = sum(t_n(tCur,nCur),v_buyBuildings.l(buildings,tCur,nCur))/sum(t_n(tCur,nCur),1);
  p_calibReport("int",machType,"machine","%1")      = sum(t_n(tCur,nCur),v_buyMach.l(machType,tCur,nCur))/sum(t_n(tCur,nCur),1);
  p_calibReport("int",branches,"branch","%1")       = sum(t_n(tCur,nCur),v_hasBranch.l(branches,tCur,nCur))/sum(t_n(tCur,nCur),1);
  p_calibReport("int",workOpps,"workoff","%1")      = sum(t_n(tCur,nCur),v_labOff.l(tCur,nCur,workOpps))/sum(t_n(tCur,nCur),1);


  $$ifthen.greening defined greeningTriggers
     p_calibReport("int",greeningTriggers,"greening","%1")  = sum(t_n(tCur,nCur),v_triggerGreening.l(greeningTriggers,tCur,nCur))/sum(t_n(tCur,nCur),1);
  $$endif.greening
$iftheni.prices "%2"=="yes"

  p_calibReport("price",curProds,sys,"%1")      $ sum(tCur $ (( (abs(p_price.l(curProds,sys,tCur)-p_price.scale(curProds,sys,tCur)) gt 1.E-3) or reportPrice)
                                                                $ (p_price.scale(curProds,sys,tCur) ne 1))  ,1)
       = sum(t_n(tCur,nCur), p_price.l(curProds,sys,tCur))/sum(t_n(tCur,nCur),1);

  p_calibReport("price",curInputs,sys,"%1")      $ sum(tCur $ (( (abs(p_inputPrice.l(curInputs,sys,tCur)-p_inputPrice.scale(curInputs,sys,tCur)) gt 1.E-3) or reportPrice)
                                                                $ (p_inputPrice.scale(curInputs,sys,tCur) ne 1)),1)
       = sum(t_n(tCur,nCur), p_inputPrice.l(curInputs,sys,tCur))/sum(t_n(tCur,nCur),1);

$endif.prices
