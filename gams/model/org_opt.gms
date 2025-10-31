********************************************************************************
$ontext

   FarmDyn project

   GAMS file : ORG_OPT.GMS

   @purpose  : Equations related to endogenous switches between organic and
               conventional farming
   @author   : W.Britz
   @date     : 25.02.21
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : templ.gms

$offtext
********************************************************************************
Equations

      salrevGtBuyCost_(sys,t,n)                   "Sales revenues must exceed cost of buying input"
      salrevGtBuyCost1_(sys,t,n)                  "Sales revenues must exceed cost of buying input"
      prodsSys_(prodsYearly,sys,t,n)              "Sales by system (conv,org) cannot exceed production by system"

      org_(crops,plot,till,intens,t,n)            "Crop  in organic farming require the farm in organic"
      orgPlot_(plot,t,n)                          "Plots in organic farming require the farm in organic"
      conv_(crops,plot,till,intens,t,n)           "Crop  in conv    farming require the farm in conv"
      convPlot_(plot,t,n)                         "Plots in conv    farming require the farm in conv"
      orgSales_(prods,t,n)                        "Selling of organic products require whole farm in organic farming"
      convSales_(prods,t,n)                       "Selling of conv    products require whole farm in conv    farming"
      orgBuy_(inputs,t,n)                         "Buying  of organic products require whole farm in organic farming"
      convBuy_(inputs,t,n)                        "Buying  of conv    products require whole farm in conv    farming"
;

*   --- the revenues for each system (conventional or organic) must exceed the 50% of the costs
*       (can help in RMIP with organic farming)
*
    salRevGtBuyCost_(curSys(sys),t_n(tCur,nCur)) ..

        v_salRev(sys,tCur,nCur)/2    =G= v_buyCostTot(sys,tCur,nCur);
*
*   --- input costs must reach 10% of revenue for each system(conventional or organic)
*
*       (can help in RMIP with organic farming)
    salRevGtBuyCost1_(curSys(sys),t_n(tCur,nCur)) ..

        v_buyCostTot(sys,tCur,nCur)  =G= v_salRev(sys,tCur,nCur)*0.10;
*
*   --- sold quantities for organic and conventional crops cannot exceed
*       production quantities of the same system
*
    prodsSys_(prodsYearly,curSys(sys),t_n(tCur,nCur)) $ (sum(sameas(prodsYearly,curProds),1)
        $ sum( c_p_t_i(curCrops(crops),plot,till,intens), sum(plot_soil(plot,soil), p_OCoeffC%l%(crops,soil,till,intens,prodsYearly,tCur)))) ..

        v_saleQuant(prodsYearly,sys,tCur,nCur) =L=

          sum(c_p_t_i(curCrops(crops),plot,till,intens) $ sys_till(sys,till),
              v_cropHa(crops,plot,till,intens,tCur,%nCur%)
                  * sum(plot_soil(plot,soil) $ p_OCoeffC%l%(crops,soil,till,intens,prodsYearly,tCur),
                         p_OCoeffC(crops,soil,till,intens,prodsYearly,tCur)))*1.001;
*
*  --- organic farming: crops in organic system require the whole farm in organic system
*
   org_(c_p_t_i(curCrops(crops),plot,"org",intens),t_n(tCur,nCur))..

       v_cropHa(crops,plot,"org",intens,tCur,%nCur%) =L= v_org(tCur,%nCur%) * v_totPlotLand.up(plot,tCur,nCur);
*
*  --- organic farming: crops in organic system require the whole farm in organic system
*
   orgPlot_(plot,t_n(tCur,nCur)) $ sum(c_p_t_i(curCrops,plot,"org",intens),1) ..

       sum(c_p_t_i(crops,plot,"org",intens) $ (not catchCrops(crops)),v_cropHa(crops,plot,"org",intens,tCur,nCur))
                                             =L= v_org(tCur,%nCur%) * v_totPlotLand.up(plot,tCur,nCur);
*
*  --- organic farming: if organic farming is used, other types (conventional) are not allowed
*
   conv_(c_p_t_i(curCrops(crops),plot,till,intens),t_n(tCur,nCur)) $ ((not sameas(till,"org")) $ sum(sameas(till1,"org"),1)) ..

       v_cropHa(crops,plot,till,intens,tCur,%nCur%) =L= (1-v_org(tCur,%nCur%)) * v_totPlotLand.up(plot,tCur,nCur);
*
*  --- conventional farming: crops in conventional system require the whole farm in conventional system
*
   convPlot_(plot,t_n(tCur,nCur)) $ sum(c_p_t_i(curCrops,plot,"org",intens),1) ..

       sum(c_p_t_i(crops,plot,till,intens) $ ((not catchCrops(crops)) $ (not sameas(till,"org"))),v_cropHa(crops,plot,till,intens,tCur,%nCur%))
                                             =L= (1-v_org(tCur,%nCur%)) * v_totPlotLand.up(plot,tCur,nCur);

*
*  --- organic farming: selling of organic products require whole farm in organic farming
*
   orgSales_(curProds(prodsYearly),t_n(tCur(t),nCur)) $ p_price%l%(prodsYearly,"org",t) ..

       v_saleQuant(prodsYearly,"org",t,nCur) =L=   v_org(tCur,%nCur%)  *  (v_saleQuant.up(prodsYearly,"org",tCur,nCur)
                                                                                        $ (v_saleQuant.up(prodsYearly,"org",tCur,nCur) ne inf)
                                                                                + 1.E+6 $ (v_saleQuant.up(prodsYearly,"org",tCur,nCur) eq inf));
*
*  --- conventional farming: selling of conventional products require whole farm in convetional farming
*
   convSales_(curProds(prodsYearly),t_n(tCur(t),nCur)) $ p_price%l%(prodsYearly,"conv",t) ..

       v_saleQuant(prodsYearly,"conv",t,nCur) =L=  (1-v_org(tCur,%nCur%))  *  (v_saleQuant.up(prodsYearly,"conv",tCur,nCur)
                                                                                        $ (v_saleQuant.up(prodsYearly,"conv",tCur,nCur) ne inf)
                                                                                + 1.E+6 $ (v_saleQuant.up(prodsYearly,"conv",tCur,nCur) eq inf));
*
*  --- organic farming: buying of organic inputs require whole farm in organic farming
*
   orgBuy_(curInputs(inputs),t_n(tCur(t),nCur)) $ p_inputPrice%l%(inputs,"org",t) ..

       v_buy(inputs,"org",t,nCur) =L=  v_org(tCur,%nCur%)  *  (v_buy.up(inputs,"org",tCur,nCur)
                                                                        $ (v_buy.up(inputs,"org",tCur,nCur) ne inf)
                                                              + 1.E+6  $ (v_buy.up(inputs,"org",tCur,nCur) eq inf));
*
*  --- conventional farming: buying of conventional inputs require whole farm in conventional farming
*
   convBuy_(curInputs(inputs),t_n(tCur(t),nCur)) $ p_inputPrice%l%(inputs,"conv",t) ..

       v_buy(inputs,"conv",t,nCur) =L= (1-v_org(tCur,%nCur%))  *  (v_buy.up(inputs,"conv",tCur,nCur)
                                                                        $ (v_buy.up(inputs,"conv",tCur,nCur) ne inf)
                                                               + 1.E+6 $ (v_buy.up(inputs,"conv",tCur,nCur) eq inf));
model m_orgOpt /
                  salRevGtBuyCost_
                  salRevGtBuyCost1_
                  prodsSys_
                  org_
                  conv_
                  convPlot_
                  orgSales_
                  convSales_
                  orgBuy_
                  convBuy_
                  orgPremCropped_
                  orgPlot_
/;

