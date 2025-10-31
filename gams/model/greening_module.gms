********************************************************************************
$ontext

   FARMDYN project

   GAMS file : GREENING.GMS

   @purpose  : Implementation of greening regulations in FarmDyn
   @author   : Lennart Kokemohr, Christoph Pahmeyer
   @date     : 17.03.15
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :


********************************************************************************
$offtext
********************************************************************************
*                                     SETS
********************************************************************************

* --- 'Superset' of crops, where affiliate crops are grouped under one crop name
*     (eg. Wintercere = Wintercere + Wheat GPS) as per greening obligation

$include '%datdir%/%greeningFile%.gms'
alias(cropGroups,cropGroups1,cropGroups2) ;


Parameter p_M;
  p_M = 1000;

set greeningTriggers / 10ha,15ha,30ha,Gras,Idle /;

Binary variable
   v_triggerGreening(greeningTriggers,t,n)
 ;
 positive variable
   v_haCropGroups(cropGroups,t,n)
 ;

 Equation
   trigger10Ha_(t,n)
   trigger15Ha_(t,n)
   trigger30Ha_(t,n)
   triggerGras75_(t,n)
   triggerIdle75_(t,n)
   triggerRestlandGras_(t,n)
   triggerRestlandIdle_(t,n)
   haCropGroups_(cropGroups,t,n)
   green75_(cropGroups,t,n)
   green95_(cropGroups,cropGroups1,t,n)
   efa_(t,n)
 ;

* Check if total arable land is above 10ha (75%-Greening rule), 15ha (EFA-Rule) and 30ha (95% rule)
* (if trigger is 1, it is multiplied with a larger number p_m and the LHS becomes negative,
*  such that the farm can be larger than 10ha
*

 trigger10Ha_(t_n(tCur(t),%nCur%)) ..
   sum((plot_landType(plot,"arab"),sys) $ p_plotSize(plot),v_croppedPlotLand(plot,sys,t,%nCur%))
         - (v_triggerGreening("10ha",tCur,%nCur%) * p_M) =l= 10;

 trigger15Ha_(t_n(tCur(t),%nCur%)) ..
  sum((plot_landType(plot,"arab"),sys) $ p_plotSize(plot),v_croppedPlotLand(plot,sys,t,%nCur%))
               - (v_triggerGreening("15ha",tCur,%nCur%) * p_M) =l= 15;

 trigger30Ha_(t_n(tCur(t),%nCur%)) ..
   sum((plot_landType(plot,"arab"),sys) $ p_plotSize(plot),v_croppedPlotLand(plot,sys,t,%nCur%))
    - (v_triggerGreening("30ha",tCur,%nCur%) * p_M) =l= 30;

*
* --- permanent and rotational grass lands > 75% of all land =>
*     total cropped land < 25% grass lands
*
 triggerGras75_(t_n(tCur(t),%nCur%)) ..
   sum((plot,sys) $ p_plotSize(plot),v_croppedPlotLand(plot,sys,t,%nCur%))
    - v_triggerGreening("Gras",tCur,%nCur%) * p_M =l=
             sum(c_p_t_i(curCrops(grasCrops),plot,till,intens),
                  v_cropHa(grasCrops,plot,till,intens,tCur,%nCur%))/0.75;

*
* --- trigger = 1 <=> non grass land exceeds 30 hectares
*
 triggerRestlandGras_(t_n(tCur(t),%nCur%)) ..
    sum((plot,sys) $ p_plotSize(plot),v_croppedPlotLand(plot,sys,t,%nCur%))
  - sum(c_p_t_i(curCrops(grasCrops),plot,till,intens), v_cropHa(grasCrops,plot,till,intens,tCur,%nCur%))
   - (v_triggerGreening("Gras",tCur,%nCur%) * p_M) =l= 30
;
*
* ---  trigger must be 1 if idling land on arable land < 75%
*
 triggerIdle75_(t_n(tCur(t),%nCur%)) ..
   sum((plot_landType(plot,"arab"),sys)  $ p_plotSize(plot),v_croppedPlotLand(plot,sys,t,%nCur%))
    - (v_triggerGreening("Idle",tCur,%nCur%) * p_M) =l=
             sum(c_p_t_i(curCrops("Idle"),plot,till,intens),
                 v_cropHa("Idle",plot,till,intens,tCur,%nCur%))/0.75;
*
* --- trigger must be 1 if not idling arable land > 30 ha
*
 triggerRestlandIdle_(t_n(tCur(t),%nCur%)) ..
    sum((plot_landType(plot,"arab"),sys) $ p_plotSize(plot),v_croppedPlotLand(plot,sys,t,%nCur%))
     - sum(c_p_t_i("Idle",plot,till,intens), v_cropHa("Idle",plot,till,intens,tCur,%nCur%))
       - (v_triggerGreening("Idle",tCur,%nCur%) * p_M) =l= 30
;

* --- Sum up crop hectares to group of crops (e.g. CCM, MaizSil etc.)

 haCropGroups_(cropGroups,t_n(tCur(t),%nCur%))
                $ (sum(c_p_t_i(curCrops(crops),plot,till,intens) $ (plot_landType(plot,"arab")
                    $ p_cropGroups_to_crops(cropGroups,crops)),1)) ..

    v_haCropGroups(cropGroups,t,%nCur%)
        =e= sum((c_p_t_i(curCrops(crops),plot,till,intens))
                 $ (p_cropGroups_to_crops(cropGroups,crops) $ plot_landType(plot,"arab")),
                    v_cropHa(crops,plot,till,intens,t,%nCur%))
 ;
*
* --- Set maximum crop share of 75% per crop
*     (only binding for farm > 10 ha)
*
 green75_(cropGroups,t_n(tCur(t),%nCur%))
            $ (sum(c_p_t_i(curCrops(crops),plot,till,intens) $ (plot_landType(plot,"arab")  $ (not grassCrops(crops))
                 $ p_cropGroups_to_crops(cropGroups,crops)),1)) ..

  v_haCropGroups(cropGroups,tCur,%nCur%)
     =l=    sum((plot_landType(plot,"arab"),sys),v_croppedPlotLand(plot,sys,t,%nCur%)) *0.75
              + ((1 - v_triggerGreening("10ha",tCur,%nCur%)) * p_M)
              + ((1 - v_triggerGreening("Idle",tCur,%nCur%)) * p_M)
              + ((1 - v_triggerGreening("Gras",tCur,%nCur%)) * p_M)
;
*
* --- Set maximum crop share for a combination of any two crops to 95%
*     (only binding for farm > 30 ha)

 green95_(cropGroups,cropGroups1,t_n(tCur(t),%nCur%))
               $ (   sum(c_p_t_i(curCrops(crops),plot,till,intens) $ (plot_landType(plot,"arab")  $ (not grassCrops(crops))
                        $ p_cropGroups_to_crops(cropGroups,crops)),1)

                   $ sum(c_p_t_i(curCrops(crops),plot,till,intens) $ (plot_landType(plot,"arab")  $ (not grassCrops(crops))
                        $ p_cropGroups_to_crops(cropGroups1,crops)),1)

                   $ (not sameas(cropGroups,cropGroups1)) ) ..

     v_haCropGroups(cropGroups,tCur,%nCur%) +  v_haCropGroups(cropGroups1,tCur,%nCur%)

        =l= sum((plot_landType(plot,"arab"),sys),v_croppedPlotLand(plot,sys,t,%nCur%))*0.95
               + ((1 - v_triggerGreening("30ha",tCur,%nCur%)) * p_M)
               + ((1 - v_triggerGreening("Idle",tCur,%nCur%)) * p_M)
               + ((1 - v_triggerGreening("Gras",tCur,%nCur%)) * p_M);
*
* --- Provide at least 5% ecological focus area
*     (different types of land count with their weighting factors p_efa)
*
 efa_(t_n(tCur(t),%nCur%)) ..

   sum(plot_landType(plot,"arab") $ p_plotSize(plot),
           sum(sys,v_croppedPlotLand(plot,sys,t,%nCur%))) * 0.05
         =l=

    sum(c_p_t_i(curCrops(crops),plot,till,intens) $ plot_landType(plot,"arab"),
          v_cropHa(crops,plot,till,intens,tCur,%nCur%)*p_efa(crops))
*
*  --- if one or several of these triggers is active, the EFA condition
*      cannot be binding
*
              + ((1 - v_triggerGreening("15ha",tCur,%nCur%)) * p_M)
              + ((1 - v_triggerGreening("Idle",tCur,%nCur%)) * p_M)
              + ((1 - v_triggerGreening("Gras",tCur,%nCur%)) * p_M)
 ;

model m_greening /
              trigger10Ha_
              trigger15Ha_
              trigger30Ha_
              triggerIdle75_
              triggerGras75_
              triggerRestlandIdle_
              triggerRestlandGras_
              haCropGroups_
              green75_
              green95_
              efa_
                /;
