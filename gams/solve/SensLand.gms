********************************************************************************
$ontext

   FAMRDyn project

   GAMS file : SENSLAND.GMS

   @purpose  : Run experiment with increased land endowment and report
               changes in marginals of land
   @author   : W.Britz
   @date     : 19.07.17
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter.gms

$offtext
********************************************************************************

*
* --- in case of experiements, allow for derivation of marginals of land
*     by re-solving the model with an enlarged land endowment
*

* --- Marginals for additional land for multiple endowment enlargements only available for arable farms

      set additionalLand /addOne,addTwo,addThree/;
      parameter p_profit(*), p_addLand(additionalLand);
      $$batinclude 'util/title.gms' "'%titlePrefix% Solve model as %MIP%, will all plots +1 ha'"

      p_addLand("addOne") = 1;
      $$iftheni.addLand "%useLandEndowInc%" == true
      p_addLand("addTwo")   = %landIncFirst%;
      p_addLand("addThree") = %landIncSecond%;
      $$endif.addLand

      p_profit("Before") = v_obje.l;
loop(additionalLand,

      p_plotSize(plot) $ p_plotSize(plot) = p_plotSize(plot) + (p_addLand(additionalLand)+1);

*
*     --- First add two hectares (as done in separate experiments for grasslands and arable lands below)
*         expand bounds
*
      v_cropLandActive.up(t_n(tCur(t),nCur)) = sum(plot_lt_soil(plot,landType,soil), p_plotSize(plot));
      v_totPlotland.up(plot,t_n(t,nCur))     = p_plotSize(plot);
      v_croppedPlotLand.up(plot,sys,t_n(t,nCur)) = v_totPlotland.up(plot,t,nCur)*1.01;
      v_cropHa.up(c_p_t_i(crops,plot,till,intens),t_n(t,nCur)) $ sum((plot_soil(plot,soil),sys_till(sys,till)),p_maxRotShare(crops,sys,soil))
               =  v_totPlotland.up(plot,t,nCur)*1.01  * sum((plot_soil(plot,soil),sys_till(sys,till)),p_maxRotShare(crops,sys,soil));
      $$ifi "%farmBranchArable%" == "on"    v_branchSize.up("cashCrops",t,nCur) $ t_n(t,nCur) = sum( (soil), v_croppedLand.up("arab",soil,t,nCur));
*
*     --- and next set back to +1 ha
*
      p_plotSize(plot) $ p_plotSize(plot) = p_plotSize(plot) - 1;
      p_sumres("Land") = sum(plot, p_plotSize(plot));
      $$ifi     %useMIP%==on   solve m_farm using %MIP% maximizing v_obje;
      $$ifi not %useMIP%==on   solve m_farm using RMIP maximizing v_obje;
      $$batinclude 'solve/treat_infes.gms' %MIP% "Land shock"
      p_profit("after") = v_obje.l;
      p_plotSize(plot) $ p_plotSize(plot) = p_plotSize(plot) - p_addLand(additionalLand);
      p_sumRes("margLand") = (p_profit("after")-p_profit("Before"))/p_addLand(additionalLand);
      p_sumRes("InitialProfit") = p_profit("before");
      p_sumRes("AddLandProfit") = p_profit("after");

);



      if ( sum(plot_landType(plot,"gras"),1) and sum(plot_landType(plot,"arab"),1),

         $$batinclude 'util/title.gms' "'%titlePrefix% Solve model as %MIP%, will all grass land plots +2 ha'"

         p_plotSize(plot) $ plot_landType(plot,"gras") = p_plotSize(plot) + 2;
         display p_plotSize;
         $$ifi     %useMIP%==on   solve m_farm using %MIP% maximizing v_obje;
         $$ifi not %useMIP%==on   solve m_farm using RMIP maximizing v_obje;
         $$batinclude 'solve/treat_infes.gms' %MIP% "Land shock"
         p_profit("after") = v_obje.l;
         p_plotSize(plot) $ plot_landType(plot,"gras") = p_plotSize(plot) - 2;
         p_sumRes("margGras")
             = (p_profit("after")-p_profit("Before"))/sum(plot $ plot_landType(plot,"gras"),2);

         $$batinclude 'util/title.gms' "'%titlePrefix% Solve model as %MIP%, will all arable plots +2 ha'"

         p_plotSize(plot) $ plot_landType(plot,"arab") = p_plotSize(plot) + 2;
         display p_plotSize;
         $$ifi     %useMIP%==on   solve m_farm using %MIP% maximizing v_obje;
         $$ifi not %useMIP%==on   solve m_farm using RMIP maximizing v_obje;
         $$batinclude 'solve/treat_infes.gms' %MIP% "Land shock"
         p_profit("after") = v_obje.l;
         p_plotSize(plot) $ plot_landType(plot,"arab") = p_plotSize(plot) - 2;
         p_sumRes("margArab") $ sum(plot_landType(plot,"arab"),1)
            = (p_profit("after")-p_profit("Before"))/sum(plot $plot_landType(plot,"arab"),2);
         p_sumRes("margArab") = p_sumRes("margLand");

      elseif ( sum(plot_landType(plot,"gras"),1) ),
         p_sumRes("margGras") = p_sumRes("margLand");

      else
         p_sumRes("margArab") = p_sumRes("margLand");

      );
