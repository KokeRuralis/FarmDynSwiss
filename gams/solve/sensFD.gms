********************************************************************************
$ontext

   FARMDYN Project

   GAMS file : SENSFD.GMS

   @purpose  : Run sensitivity analysis from 2007 to 2017 Fertilizer Directive
   @author   : Till Kuhn and Wolfgang Britz
   @date     : 19.07.17
   @since    :
   @refDoc   :
   @seeAlso  : scen_gen.gms
   @calledBy : exp_starter.gms

$offtext
********************************************************************************
*
*  --- set global to use new FD
*
$SETGLOBAL RegulationFert FD_2017
*
*  --- re-include files from coeffgen which comprise parameters
*      depending on the FD
*
$onglobal
$onmulti
$include 'coeffgen/manure.gms'
$include 'coeffgen/fertilizing.gms'
$include 'coeffgen/prices.gms'
$offmulti

 parameter p_sumResMeta(*);

  p_sumResMeta("ProfitBefore") = v_obje.l;



$iftheni.dairy %Dairyherd% == true

  p_sumResMeta("NmilkBefore")  =  sum (  (t_n(tCur,nCur)), v_prods.l("milk",tCur,nCur) * 10 /card(tCur)  )      ;

  p_sumResMeta("GMBeforePerECM") =    v_obje.l   /   p_sumResMeta("NmilkBefore") ;

$endif.dairy

$iftheni.f "%farmBranchFattners%" == "on"

   p_sumResMeta("NFattnersBefore") =    sum ( t_n(tCur,nCur),  v_branchSize.l("fatPig",tCur,nCur) / card (tCur) ) ;

   p_sumResMeta("GMBeforePerFat") $  p_sumResMeta("NFattnersBefore") =     v_obje.l   /     p_sumResMeta("NFattnersBefore") ;

$endif.f

* --- Get summary variables for run under FO 07 to asses selected compliance strategies

   p_res("base","red0","StrawEx_07","sum","","mean")       = sum ( (  t_n(tCur,nCur),c_p_t_i(crops,plot,till,intens)  ),
                                                                 p_probn(nCur) * v_residuesRemoval.l(crops,plot,till,intens,tCur,nCur)   )  ;

   p_res("base","red0","ManSpread_07","sum","","mean")     = sum( (t_n(tCur,nCur),c_p_t_i(crops,plot,till,intens),manType,ManApplicSpread,m)
                                                                 $ v_cropHa.l(crops,plot,till,intens,tCur,nCur),
                                                                       p_probn(nCur)*v_manDist.l(crops,plot,till,intens,ManApplicSpread,manType,tCur,nCur,m) );

   p_res("base","red0","ManShoe_07","sum","","mean")       = sum( (t_n(tCur,nCur),c_p_t_i(crops,plot,till,intens),manType,ManApplicShoe,m)
                                                                 $ v_cropHa.l(crops,plot,till,intens,tCur,nCur),
                                                                       p_probn(nCur)*v_manDist.l(crops,plot,till,intens,ManApplicShoe,manType,tCur,nCur,m) );

   p_res("base","red0","ManHose_07","sum","","mean")       = sum( (t_n(tCur,nCur),c_p_t_i(crops,plot,till,intens),manType,ManApplicTailh,m)
                                                                 $ v_cropHa.l(crops,plot,till,intens,tCur,nCur),
                                                                       p_probn(nCur)*v_manDist.l(crops,plot,till,intens,ManApplicTailh,manType,tCur,nCur,m) );

   p_res("base","red0","ManInj_07","sum","","mean")        = sum( (t_n(tCur,nCur),c_p_t_i(crops,plot,till,intens),manType,ManApplicInjec,m)
                                                                 $ v_cropHa.l(crops,plot,till,intens,tCur,nCur),
                                                                       p_probn(nCur)*v_manDist.l(crops,plot,till,intens,ManApplicInjec,manType,tCur,nCur,m) );

   p_res("base","red0","ManVolMon_07","sum","","mean")    = sum ( (curManChain(manChain),t_n(tCur,nCur),m), v_manQuantM.l(manChain,tCur,nCur,m)) /card(m);

   p_res("base","red0","StorageIni","sum","","mean")     =   sum ( (curManChain(manChain),silos) ,  p_iniSilos(manChain,silos,"%stableYear%") * p_ManStorCapSi(silos) ) ;

   p_res("base","red0","StorageCap_07","sum","","mean")    = sum( ( curManChain(manChain),t_n(tCur,nCur) ) ,  v_TotalManStorCap.l(manChain,tCur,nCur)  ) ;


   p_res("base","red0","CatchCrop_07","sum","","mean")     = sum( (t_n(tCur,nCur),c_p_t_i("CatchCrop",plot,till,intens)),
                                                                            p_probn(nCur) * v_cropHa.l("CatchCrop",plot,till,intens,tCur,nCur)     )  ;

$iftheni.f "%farmBranchFattners%" == "on"
   p_res("base","red0","AnimProd_07","sum","","mean")       =  sum( (t_n(tCur,nCur)), p_probn(nCur) * v_prods.l("pigMeat",tCur,nCur)   ) ;

   p_res("base","red0","MinFuNPred_07","sum","","mean")     =  sum( (t_n(tCur,nCur)),   v_buy.l("MinFu",tCur,nCur) +   v_buy.l("MinFu2",tCur,nCur)  ) ;

   p_res("base","red0","MinFuHighNPred_07","sum","","mean") =  sum( (t_n(tCur,nCur)),   v_buy.l("MinFu3",tCur,nCur) +   v_buy.l("MinFu4",tCur,nCur)  ) ;
$endif.f

$iftheni.dairy %Dairyherd% == true
   p_res("base","red0","AnimProd_07","sum","","mean")      = sum( (t_n(tCur,nCur)), p_probn(nCur) * v_prods.l("milk",tCur,nCur)  * 1000 ) ;
$endif.dairy


* --- Get summary of fertilizer variabels for model run with Fertilization Ordinance 2007


   p_res("base","red0","NSurplus_07","sum","","mean") $ sum( t_n(tCur,nCur), v_croplandActive.l(tCur,nCur) )  = sum( t_n(tCur,nCur), p_probn(nCur)*v_surplusDueV.l (tCur,nCur,"N"))
                                                                                                    / sum(  (t_n(tCur,nCur) ),  v_croplandActive.l(tCur,nCur) )  ;

   p_res("base","red0","PSurplus_07","sum","","mean") $ sum( t_n(tCur,nCur), v_croplandActive.l(tCur,nCur) )  = sum(t_n(tCur,nCur),p_probn(nCur)*v_surplusDueV.l(tCur,nCur,"P"))
                                                                                                  / sum(  (t_n(tCur,nCur) ),  v_croplandActive.l(tCur,nCur) )  ;

   p_res("base","red0","Norg170_07","sum","","mean")     $ sum( t_n(tCur,nCur), v_croplandActive.l(tCur,nCur) )
                                           =  sum(t_n(tCur,nCur),p_probn(nCur)*v_DueVOrgN.l(tCur,nCur))   / sum(  (t_n(tCur,nCur) ),  v_croplandActive.l(tCur,nCur) ) ;

   p_res("base","red0","NminFert_07","sum","","mean")    $ sum( t_n(tCur,nCur), v_croplandActive.l(tCur,nCur) )
                                         = sum( (t_n(tCur,nCur),c_p_t_i(crops,plot,till,intens),syntFertilizer,m),p_probn(nCur)*
                                                   v_syntDist.l(crops,plot,till,intens,syntFertilizer,tCur,nCur,m)
                                                                * p_nutInSynt(syntFertilizer,"N") )
                                                                        / sum(  (t_n(tCur,nCur) ),  v_croplandActive.l(tCur,nCur) ) ;

   p_res("base","red0","PminFert_07","sum","","mean")       $ sum( t_n(tCur,nCur), v_croplandActive.l(tCur,nCur) )
                                   = sum( (t_n(tCur,nCur),c_p_t_i(crops,plot,till,intens),syntFertilizer,m),  p_probn(nCur)* v_syntDist.l(crops,plot,till,intens,syntFertilizer,tCur,nCur,m)
                                               * p_nutInSynt(syntFertilizer,"P") )
                                                     / sum(  (t_n(tCur,nCur) ),  v_croplandActive.l(tCur,nCur) ) ;

   p_res("base","red0","NneedMin_07","sum","","mean")    $ sum( t_n(tCur,nCur), v_croplandActive.l(tCur,nCur) )
                                          = (    sum( (  plot_soil(plot,soil), t_n(tCur,nCur),c_p_t_i(crops,plot,till,intens)  ) ,
                                                v_cropHa.l(crops,plot,till,intens,tCur,nCur) *    p_minChemFert(crops,"N")    )
                                                                                                        / sum(  (t_n(tCur,nCur) ),  v_croplandActive.l(tCur,nCur) )    )
                                                                                                      / p_cardtCur  ;

   p_res("base","red0","PneedMin_07","sum","","mean")  $ sum( t_n(tCur,nCur), v_croplandActive.l(tCur,nCur) )
                                         =  (    sum( (  plot_soil(plot,soil), t_n(tCur,nCur),c_p_t_i(crops,plot,till,intens) ) ,
                                                v_cropHa.l(crops,plot,till,intens,tCur,nCur) *     p_minChemFert(crops,"P")    )
                                                                                                     / sum(  (t_n(tCur,nCur) ),  v_croplandActive.l(tCur,nCur) )    )
                                                                                                  / p_cardtCur  ;

   p_res("base","red0","ManVolApl_07","sum","","mean")  $ sum( t_n(tCur,nCur), v_croplandActive.l(tCur,nCur) )
                                     =  sum ( (curManChain(manChain),t_n(tCur,nCur),m) ,  v_volManApplied.l(manChain,tCur,nCur,m) ) /  sum(  (t_n(tCur,nCur) ),  v_croplandActive.l(tCur,nCur) )
                                                                                                  / p_cardtCur  ;

   p_res("base","red0","ManExport_07","sum","","mean")    $ sum( t_n(tCur,nCur), v_croplandActive.l(tCur,nCur) )
                                        =      sum( (t_n(tCur,nCur),curManChain(manChain),manType,m),p_probn(nCur)* v_manExport.l(manChain,manType,tCur,nCur,m) ) /   sum(  (t_n(tCur,nCur) ),  v_croplandActive.l(tCur,nCur) )    ;


   p_res("base","red0","StockDen_07","sum","","mean")  $ sum( t_n(tCur,nCur), v_croplandActive.l(tCur,nCur) )
                                   =   sum(  t_n(tCur,nCur) ,v_sumGV.l(tCur,nCur) /  v_croplandActive.l(tCur,nCur)  )   / p_cardtCur  ;


   p_res("base","red0","NQuotNeed_07","sum","","mean")   =  sum( (t_n(tCur,nCur)),  v_FertQuotaNeed.l(tCur,nCur) ) ;



   p_res("base","red0","NQuotAppl_07","sum","","mean")  =  sum( (t_n(tCur,nCur)),  v_FertQuotaInput.l(tCur,nCur) /   p_cardtCur ) ;


*
*  --- re-solve model under new FD
*
  $$ifi     %useMIP%==on   solve m_farm using %MIP% maximizing v_obje;
  $$ifi not %useMIP%==on   solve m_farm using RMIP maximizing v_obje;
  $$batinclude 'model/treat_infes.gms' %MIP% "Land shock"


*
*  --- report profit changes on p_sumRes
*
   p_sumRes("ProfitDiff") =  v_obje.l - p_sumResMeta("ProfitBefore");
   p_res("base","red0","ProfitDiff","sum","","mean") = p_sumRes("ProfitDiff") ;

$iftheni.dairy %Dairyherd% == true

   p_sumRes("GMDiffOut") =  v_obje.l /   p_sumResMeta("NmilkBefore")  -   p_sumResMeta("GMBeforePerECM")          ;

$endif.dairy


$iftheni.f "%farmBranchFattners%" == "on"

   p_sumRes("GMDiffOut") =   v_obje.l /     p_sumResMeta("NFattnersBefore")   -    p_sumResMeta("GMBeforePerFat") ;

$endif.f


   p_res("base","red0","GMDiffOut","sum","","mean")  = p_sumRes("GMDiffOut") ;


* --- Get summary variables for run under FO 17 to asses selected compliance strategies

   p_res("base","red0","StrawEx_17","sum","","mean")       = sum ( (  t_n(tCur,nCur),c_p_t_i(crops,plot,till,intens)  ),
                                                                       v_residuesRemoval.l(crops,plot,till,intens,tCur,nCur)     )  ;

     p_res("base","red0","ManSpread_17","sum","","mean")     =  0;
   p_res("base","red0","ManSpread_17","sum","","mean")     = sum( (t_n(tCur,nCur),c_p_t_i(crops,plot,till,intens),manType,ManApplicSpread,m)
                                                                 $ v_cropHa.l(crops,plot,till,intens,tCur,nCur),
                                                                       p_probn(nCur)*v_manDist.l(crops,plot,till,intens,ManApplicSpread,manType,tCur,nCur,m)  );

   p_res("base","red0","ManShoe_17","sum","","mean")       = sum( (t_n(tCur,nCur),c_p_t_i(crops,plot,till,intens),manType,ManApplicShoe,m)
                                                                 $ v_cropHa.l(crops,plot,till,intens,tCur,nCur),
                                                                       p_probn(nCur)*v_manDist.l(crops,plot,till,intens,ManApplicShoe,manType,tCur,nCur,m)  );

   p_res("base","red0","ManHose_17","sum","","mean")       = sum( (t_n(tCur,nCur),c_p_t_i(crops,plot,till,intens),manType,ManApplicTailh,m)
                                                                 $ v_cropHa.l(crops,plot,till,intens,tCur,nCur),
                                                                       p_probn(nCur)*v_manDist.l(crops,plot,till,intens,ManApplicTailh,manType,tCur,nCur,m) );

   p_res("base","red0","ManInj_17","sum","","mean")        = sum( (t_n(tCur,nCur),c_p_t_i(crops,plot,till,intens),manType,ManApplicInjec,m)
                                                                 $ v_cropHa.l(crops,plot,till,intens,tCur,nCur),
                                                                       p_probn(nCur)*v_manDist.l(crops,plot,till,intens,ManApplicInjec,manType,tCur,nCur,m) );


   p_res("base","red0","ManVolMon_17","sum","","mean")    = sum ( (curManChain(manChain),t_n(tCur,nCur),m), v_manQuantM.l(manChain,tCur,nCur,m)) /card(m);

   p_res("base","red0","StorageCap_17","sum","","mean")    = sum( (curManChain(manChain),t_n(tCur,nCur)) ,  v_TotalManStorCap.l(manChain,tCur,nCur)  ) ;


   p_res("base","red0","CatchCrop_17","sum","","mean")     = sum( (t_n(tCur,nCur),c_p_t_i("CatchCrop",plot,till,intens)),
                                                                               v_cropHa.l("CatchCrop",plot,till,intens,tCur,nCur)      )  ;

$iftheni.f "%farmBranchFattners%" == "on"
   p_res("base","red0","AnimProd_17","sum","","mean")       =  sum( (t_n(tCur,nCur)), p_probn(nCur) * v_prods.l("pigMeat",tCur,nCur)  ) ;

   p_res("base","red0","MinFuNPred_17","sum","","mean")     =  sum( (t_n(tCur,nCur)),   v_buy.l("MinFu",tCur,nCur) +   v_buy.l("MinFu2",tCur,nCur)  ) ;

   p_res("base","red0","MinFuHighNPred_17","sum","","mean") =  sum( (t_n(tCur,nCur)),   v_buy.l("MinFu3",tCur,nCur) +   v_buy.l("MinFu4",tCur,nCur)  ) ;
$endif.f

$iftheni.dairy %Dairyherd% == true
   p_res("base","red0","AnimProd_17","sum","","mean")      = sum( (t_n(tCur,nCur)), p_probn(nCur) * v_prods.l("milk",tCur,nCur)  * 1000 ) ;
$endif.dairy


* --- Get summary of fertilizer variabels for model run with Fertilization Ordinance 2017

   p_res("base","red0","NSurplus_17","sum","","mean") $ sum( t_n(tCur,nCur), v_croplandActive.l(tCur,nCur) )  = sum( t_n(tCur,nCur), p_probn(nCur)*v_surplusDueV.l (tCur,nCur,"N"))
                                                                                                    / sum(  (t_n(tCur,nCur) ),  v_croplandActive.l(tCur,nCur) )  ;

   p_res("base","red0","PSurplus_17","sum","","mean") $ sum( t_n(tCur,nCur), v_croplandActive.l(tCur,nCur) )  = sum(t_n(tCur,nCur),p_probn(nCur)*v_surplusDueV.l(tCur,nCur,"P"))
                                                                                                  / sum(  (t_n(tCur,nCur) ),  v_croplandActive.l(tCur,nCur) )  ;

   p_res("base","red0","Norg170_17","sum","","mean")     $ sum( t_n(tCur,nCur), v_croplandActive.l(tCur,nCur) )
                                           =  sum(t_n(tCur,nCur),p_probn(nCur)*v_DueVOrgN.l(tCur,nCur))   / sum(  (t_n(tCur,nCur) ),  v_croplandActive.l(tCur,nCur) ) ;

   p_res("base","red0","NminFert_17","sum","","mean")    $ sum( t_n(tCur,nCur), v_croplandActive.l(tCur,nCur) )
                                         = sum( (t_n(tCur,nCur),c_p_t_i(crops,plot,till,intens),syntFertilizer,m),p_probn(nCur)*
                                                   v_syntDist.l(crops,plot,till,intens,syntFertilizer,tCur,nCur,m)
                                                                * p_nutInSynt(syntFertilizer,"N"))
                                                                        / sum(  (t_n(tCur,nCur) ),  v_croplandActive.l(tCur,nCur) ) ;

   p_res("base","red0","PminFert_17","sum","","mean")       $ sum( t_n(tCur,nCur), v_croplandActive.l(tCur,nCur) )
                                   = sum( (t_n(tCur,nCur),c_p_t_i(crops,plot,till,intens),syntFertilizer,m),  p_probn(nCur)* v_syntDist.l(crops,plot,till,intens,syntFertilizer,tCur,nCur,m)
                                               * p_nutInSynt(syntFertilizer,"P") )
                                                     / sum(  (t_n(tCur,nCur) ),  v_croplandActive.l(tCur,nCur) ) ;

   p_res("base","red0","NneedMin_17","sum","","mean")    $ sum( t_n(tCur,nCur), v_croplandActive.l(tCur,nCur) )
                                          = (    sum( (  plot_soil(plot,soil), t_n(tCur,nCur),c_p_t_i(crops,plot,till,intens) ) ,
                                                v_cropHa.l(crops,plot,till,intens,tCur,nCur) *     p_minChemFert(crops,"N")    )
                                                                                                        / sum(  (t_n(tCur,nCur) ),  v_croplandActive.l(tCur,nCur) )    )
                                                                                                      / p_cardtCur  ;

   p_res("base","red0","PneedMin_17","sum","","mean")  $ sum( t_n(tCur,nCur), v_croplandActive.l(tCur,nCur) )
                                         =  (    sum( (  plot_soil(plot,soil), t_n(tCur,nCur),c_p_t_i(crops,plot,till,intens) ) ,
                                                v_cropHa.l(crops,plot,till,intens,tCur,nCur) *    p_minChemFert(crops,"P")    )
                                                                                                     / sum(  (t_n(tCur,nCur) ),  v_croplandActive.l(tCur,nCur) )    )
                                                                                                  / p_cardtCur  ;

   p_res("base","red0","ManVolApl_17","sum","","mean")  $ sum( t_n(tCur,nCur), v_croplandActive.l(tCur,nCur) )
                                     =  sum ( (curManChain(manChain),t_n(tCur,nCur),m) ,  v_volManApplied.l(manChain,tCur,nCur,m) ) /  sum(  (t_n(tCur,nCur) ),  v_croplandActive.l(tCur,nCur) )
                                                                                                  / p_cardtCur  ;

   p_res("base","red0","ManExport_17","sum","","mean")    $ sum( t_n(tCur,nCur), v_croplandActive.l(tCur,nCur) )
                                        =      sum( (t_n(tCur,nCur),manType,curManChain(manChain),m),p_probn(nCur)* v_manExport.l(manChain,manType,tCur,nCur,m) ) /   sum(  (t_n(tCur,nCur) ),  v_croplandActive.l(tCur,nCur) )    ;


   p_res("base","red0","StockDen_17","sum","","mean")  $ sum( t_n(tCur,nCur), v_croplandActive.l(tCur,nCur) )
                                   =   sum(  t_n(tCur,nCur) ,v_sumGV.l(tCur,nCur) /  v_croplandActive.l(tCur,nCur)  )   / p_cardtCur  ;


   p_res("base","red0","NQuotNeed_17","sum","","mean")   =  sum( (t_n(tCur,nCur)),  v_FertQuotaNeed.l(tCur,nCur) ) ;



   p_res("base","red0","NQuotAppl_17","sum","","mean")  =  sum( (t_n(tCur,nCur)),  v_FertQuotaInput.l(tCur,nCur) /   p_cardtCur ) ;


  display p_res;

