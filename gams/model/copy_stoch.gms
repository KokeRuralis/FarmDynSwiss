********************************************************************************
$ontext

   FarmDyn project

   GAMS file : COPY_STOCH.GMS

   @purpose  : Copy results for variables which are identical across nodes
               back to all nodes
   @author   : W.Britz
   @date     : 24.11.21
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter.gms

$offtext
********************************************************************************
$ifi not "%stochProg%"=="true" $exit
$ifi not "%dynamics%" == "Comparative-static" $exit

  v_cropHa.l(curcrops,plot,till,intens,t_n(t,nCur)) = v_cropHa.l(curcrops,plot,till,intens,t,%nCur%);
  v_sumCrop.l(crops,sys,t_n(t,nCur))                = v_sumCrop.l(crops,sys,t,%nCur%);
  v_croppedPlotLand.l(plot,sys,t_n(t,nCur))         = v_croppedPlotLand.l(plot,sys,t,%nCur%);
  v_rentOutPlot.l(plot,t_n(t,nCur))                 = v_rentOutPlot(plot,t,%nCur%);
  v_croppedLand.l(landType,soil,t_n(t,nCur))        = v_croppedLand.l(landType,soil,t,%nCur%);
  v_croplandActive.l(t_n(t,nCur))                   = v_croplandActive.l(t,%nCur%);


  v_buyMach.l(machType,t_n(t,nCur))                 = v_buyMach.l(machType,t,%nCur%);
  v_buyBuildings.l(buildings,t_n(t,nCur))           = v_buyBuildings.l(buildings,t,%nCur%);
  v_hasFarm.l(t_n(t,nCur))                          = v_hasFarm.l(t,%nCur%);
  $$ifi defined v_org v_org.l(t_n(t,nCur))          = v_org.l(t,%nCur%);
  v_labOffB.l(t_n(t,nCur))                          = v_labOffB.l(t,%nCur%);
  v_labOff.l(t_n(t,nCur),workType)                  = v_labOff.l(t,%nCur%,workType);
  v_hasBranch.l(branches,t_n(t,nCur))               = v_hasBranch.l(branches,t,%nCur%);

$$iftheni.herd "%herd%"=="true"

  v_buySilos.l(manChain,silos,t_n(t,nCur))       = v_buySilos.l(manChain,silos,t,%nCur%);
  v_buyStables.l(stables,hor,t_n(t,nCur))        = v_buyStables.l(stables,hor,t,%nCur%);
  v_minInvStables.l(stableTypes,hor,t_n(t,nCur)) = v_minInvStables.l(stableTypes,hor,t,%nCur%);

  v_herdStart.l(possHerds,breeds,t_n(t,nCur),m)  = v_herdStart.l(possHerds,breeds,t,%nCur%,m);
  v_sumHerds.l(sumHerds,breeds,t_n(t,nCur))      = v_sumHerds.l(sumHerds,breeds,t,%nCur%);

 $$iftheni.cattle "%cattle%"=="true"
     $$iftheni.SOS2 "%useSOS2%"=="true"
        v_buySilosSOS2(manChain,t_n(t,nCur),silos)                     = v_buySilosSOS2.l(manChain,t,%nCur%,silos);
        v_buyCowStablesSos2(hor,t_n(t,nCur),cowStables)                = v_buyCowStablesSos2(hor,t,%nCur%,cowStables);
        v_buyMotherCowStablesSos2(hor,t_n(t,nCur),motherCowStables)    = v_buyMotherCowStablesSos2(hor,t,%nCur%,motherCowStables);
        v_buyYoungStablesSos2(hor,t_n(t,nCur),youngStables)            = v_buyYoungStablesSos2(hor,t,%nCur%,youngStables);
        v_buyCalvStablesSos2(hor,t_n(t,nCur),calvStables)              = v_buyCalvStablesSos2(hor,t,%nCur%,calvStables);
     $$endif.SOS2
  $$endif.cattle
$$endif.herd
