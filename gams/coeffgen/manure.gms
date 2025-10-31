********************************************************************************
$ontext

   FARMDYN project

   GAMS file : MANURE.GMS

   @purpose  : Slurry output per month of different herds,
               N lossesduring storage, treatment costs
   @author   : Bernd Lengers
   @date     : 13.11.10
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************

$batinclude 'util/title.gms' "'%titlePrefix% Define coefficients relating to manure'"

*
* --- this might be set differently in fertOrd files to reflect current legal restrictions
*
$ifi not defined p_manugeStorageNeed p_manureStorageNeed = 0.5;

$iftheni.herd %herd% == true
*
*  --- Correct the monthly manure quantity according to the stable style of the herd
*      We want to make sure to only overwrite the montly manure quantity if a herd IS NOT on a Slatted_floor (default)
*      so as currently straw stables are only available for cattle herds, only that set is used
*

*
*  --- split up the total output in m3 (stored on "liquidCattle") in to different fractions (mainChain)
*      dependong on stable type. The p_nutShare parameters is provided by the stable file
*
*
  $$iftheni.cattle "%cattle%"=="true"


      p_manQuantMonthStable(cattle,manChain,stableStyles) $ manChain_herd(manChain,cattle)
         = p_manQuantMonth(cattle,"liquidCattle") * p_nutShare(manChain,stableStyles,"m3")  ;

      p_manQuantMonth(cattle,manChain)
       = sum(herd_stableStyle(cattle,stableStyles), p_manQuantMonthStable(cattle,manChain,stableStyles));

   $$endif.cattle

   $$ifi not "%farmBranchfattners%"==on $setglobal redNPFeed false
*
*  --- link between herds and type of manure excreted
*
   set herds_manType(herds,mantype) /

     $$ifi  "%farmBranchSows%"     == "on"                  sows.sow,piglets.piglet

     $$iftheni.fat  "%farmBranchfattners%" == "on"
                                                            fattners.fattner
       $$ifi %redNPFeed% == true                            fattners.(fattnerRed,fattnerHighRed)
     $$endif.fat

     $$iftheni.dh  "%dairyHerd%" == "true"
                                                            (set.dcows).cows
       $$ifi not "%cowStableInv%" == "Slatted_floor"        (set.dcows).(cowsSolid,cowsLight)
     $$endif.dh

     $$iftheni.dh   "%cowherd%" == "true"
                                                            (set.heifs,heifs).heifs
       $$ifi not "%heifersStableInv%" == "Slatted_floor"    (set.heifs,heifs).(heifsSolid,heifsLight)
                                                            mcalvsRais.mcalvsRais
       $$ifi not "%calvesStableInv%" == "Slatted_floor"     mcalvsRais.(mcalvsRaisSolid,mcalvsRaisLight)
                                                            fcalvsRais.fcalvsRais
       $$ifi not "%calvesStableInv%" == "Slatted_floor"     fcalvsRais.(fcalvsRaisSolid,fcalvsRaisLight)

     $$elseifi.dh   "%cattle%"=="true"
         $$ifthen.buyCalves  "%buyCalvs%"=="true"
                                                                mcalvsRais.mcalvsRais
           $$ifi not "%calvesStableInv%" == "Slatted_floor"     mcalvsRais.(mcalvsRaisSolid,mcalvsRaisLight)
         $$endif.buyCalves
     $$endif.dh

     $$iftheni.bulls  "%farmBranchBeef%" == "on"
                                                            (set.bulls,bulls).bulls
       $$ifi not "%bullsStableInv%" == "Slatted_floor"      (set.bulls,bulls).(bullsSolid,bullsLight)
     $$endif.bulls

     $$iftheni.mc  "%farmBranchMotherCows%"=="on"
                                                            (set.mcows).mc
       $$ifi not "%motherCowStableInv%" == "Slatted_floor"  (set.mcows).mcSolid
     $$endif.mc

   / ;

*
*  --- Calculation of NTAN, Norg and P without losses (basis  for further calculations)
*

   p_nut2inManNoLoss(nut2,feedRegime,manType) $ sum(herds_manType(herds,manType),
                                                   sum(manChain,p_manQuantMonth(herds,manChain)))
     =  smax(herds_manType(herds,manType)  $ sum(manChain,p_manQuantMonth(herds,manChain)),
            p_nut2ManMonth(herds,feedRegime,nut2)
                            / sum(manChain,p_manQuantMonth(herds,manChain))   ) ;

   $$iftheni.dh   %cattle% == true
     p_nut2inManNoLoss(nut2,feedRegime,manDairyPro)       =  p_nut2ManMonth("cow9800",feedRegime,nut2)  / 20 * 12;
   $$endif.dh

   $$iftheni.RedNP %redNPFeed% == true
*
*    --- (1A) Calculation with N/P reduced feeding option
*
     set manType_reg(manType,feedRegime) /(set.manType).(set.feedRegime)/;
         manType_reg("fattner","highRedNP")       = NO;
         manType_reg("fattner","redNP")           = NO;
         manType_reg("fattnerRed","normFeed")     = NO;
         manType_reg("fattnerRed","highRedNP")    = NO;
         manType_reg("fattnerHighRed","normFeed") = NO;
         manType_reg("fattnerHighRed","redNP")    = NO;

       p_nut2inMan(nut2,manType,manChain)
          =  sum(manType_reg(manType,feedRegime),p_nut2inManNoLoss(nut2,feedRegime,mantype));


   $$else.RedNP
*
*    --- (1B) Calculation without N/P reduced feeding option
*
     p_nut2inMan(nut2,manType,manChain)
        =  smax(feedRegime,p_nut2inManNoLoss(nut2,feedRegime,mantype));

   $$endif.RedNP

*  --- definition of different manure storage techniques with their relating additional costs  (costs per m^3 of storage)

   parameter p_manTreatCost(ManStorage) "extra cost for special treatment of stored manure per m^3 vol."

   / storsub      0
     stornocov    2
     storstraw    2
     storfoil     2
   /;
*
*  --- Remove unnecessary manTypes from curManType so manDist is more compact
*

   p_nut2inMan(nut2,manType,manChain) $ (not curManType(manType)) = 0;

$endif.herd

$iftheni.manIm   "%AllowManureImport%" == "true"
*
*  --- If manure import is allowed, an additional manure type for application is available which corresponds
*      to liquid pig manure. Furthermore,
*      curmantype is activated for corresponding element.
*
$iftheni.bioIm   "%AllowBiogasExchange%" == "false"
     curMantype("manImport")       = YES;

     p_nut2inMan("NTAN","manImport","LiquidImport") = 3 ;
     p_nut2inMan("NOrg","manImport","LiquidImport") = 2.2237228 ;
     p_nut2inMan("P","manImport","LiquidImport")    = 3.33333333333333 ;

     p_LimitManureImport =    %LimitManureImport%;

$elseifi.bioIm   "%AllowBiogasExchange%" == "true"
* values for biogas substrate according to LWK Niedersachsen
     curMantype("manBiogasImport") = YES;
     p_nut2inMan("NTAN","manBiogasImport","LiquidImport") = 2.9 ;
     p_nut2inMan("NOrg","manBiogasImport","LiquidImport") = 5.5 - 2.9 ;
     p_nut2inMan("P","manBiogasImport","LiquidImport")    = 2.1 ;

     p_DistBiogas = %DistanceBiogasPlant%;
*
* --- Maximum Netto N-input restricted when importing manure (Netto: N in addition to biomass/fermentation substrate exchange)
*

$$ifi "%RestrictedNInputQuant%"== "true"     p_MaxNImport = %LimitAdditionalNImport%;

*
* --- N-imput restricted by N-output when exchanging manure with external biogas plant
*
$$iftheni.ratio "%RestrictedNInput%" == "true"
   p_NInOutratio = %NinputOutputratio%;
$$endif.ratio

$endif.bioIm
$endif.manIm



*
* --- Agronomic limitations of manure application techniques
*
  v_manDist.up(c_p_t_i("idle",plot,till,intens),manApplicType_manType(manApplicType,curManType),t_n(t,nCur),m)             = 0;
*
* --- Shoes are used for grassland
*
  $$ifi "%pigHerd%"=="true"             v_manDist.up(c_p_t_i(arableCrops(crops),plot,till,intens),manApplicType_manType("applTShoePig",curManType),t_n(t,nCur),m) = 0;
  $$ifi "%cattle%"=="true"              v_manDist.up(c_p_t_i(arableCrops(crops),plot,till,intens),manApplicType_manType("applTShoeCattle",curManType),t_n(t,nCur),m) = 0;
  $$ifi "%strawManure%"=="true"         v_manDist.up(c_p_t_i(arableCrops(crops),plot,till,intens),manApplicType_manType("applTShoeLightCattle",curManType),t_n(t,nCur),m) = 0;
  $$ifi "%biogas%"=="true"              v_manDist.up(c_p_t_i(arableCrops(crops),plot,till,intens),manApplicType_manType("applTShoeBiogas",curManType),t_n(t,nCur),m) = 0;
  $$ifi "%AllowManureImport%"=="true"   v_manDist.up(c_p_t_i(arableCrops(crops),plot,till,intens),manApplicType_manType("applTShoeImport",curManType),t_n(t,nCur),m) = 0;

  $$iftheni.cattle %cattle% == true
*
*     --- no application on idle grazing areas
*
      v_manDist.up(c_p_t_i("idlegras",plot,till,intens),manApplicType_manType(manApplicType,curManType),t_n(t,nCur),m) = 0;
*
*     --- Tail hose no used on grasslands, shoes used
*
      $$ifi "%pigHerd%"=="true" v_manDist.up(c_p_t_i(grassCrops(crops),plot,till,intens),manApplicType_manType("applTailhPig",curManType),t_n(t,nCur),m) = 0;
      v_manDist.up(c_p_t_i(grassCrops(crops),plot,till,intens),manApplicType_manType("applTailhCattle",curManType),t_n(t,nCur),m) = 0;
  $$endif.cattle
*
* --- application of manure per injection not possible for maize silage
  $$iftheni.pig "%pigHerd%"=="true"
    v_manDist.up(c_p_t_i(maizSilage,plot,till,intens),manApplicType_manType("applInjecPig",curManType),t_n(t,nCur),m)
       $ (not (sameas(m,"Mar") or sameas(m,"Oct"))) = 0;
  $$endif.pig

  $$iftheni.cattle "%cattle%"=="true"
    v_manDist.up(c_p_t_i(maizSilage,plot,till,intens),manApplicType_manType("applInjecCattle",curManType),t_n(t,nCur),m)
       $ (not (sameas(m,"Mar") or sameas(m,"Oct"))) = 0;
  $$endif.cattle

$iftheni.herd %herd% == true
*
*    --- remove nutrient excretion from summary herds
*
     p_manQuantMonth(sumHerds,manChain)       $ (sum(sum_herds(sumHerds,herds),1) gt 1) = 0;
     p_nut2ManMonth(sumHerds,feedRegime,nut2) $ (sum(sum_herds(sumHerds,herds),1) gt 1) = 0;
*
*    --- Throw out all entries for which the manChain is not linked to the manType
*
     p_nut2InMan(nut2,manType,manChain) $ (not manChain_Type(manChain,manType)) = 0;

*
*   --- Create link between manChain (liquid manure, solid manure...)
*       and stableStyle (straw stables or slatted floor)
*
    set manChain_stableStyle(manChain,stableStyles) ;

    manChain_stableStyle(manChain,stableStyles)
        = sum( manChain_herd(manChain,herds) $ herd_stableStyle(herds,stableStyles),1);

*
*   --- TODO: CP: (1) Documentation: Correct nutrient content for shares according to the stable
*                 the herd is currently in (straw or no straw)... See documentation for details.
*                 (2) Add to actual straw nutrient contents and multiply with stable requirement
*

     p_nut2InMan(nut2,manType,manChain) $ (sum((manChain_herd(manChain,cattle),herds_manType(cattle,manType),feedRegime)
                                                 $ p_manQuantMonth(cattle,manChain),1) $ p_nut2InMan(nut2,manType,manChain) )
       = smax((manChain_herd(manChain,cattle),herds_manType(cattle,manType),feedRegime)
                                                          $ p_manQuantMonth(cattle,manChain),
                p_nut2ManMonth(cattle,feedRegime,nut2)
                  * sum(manChain_stableStyle(manChain,stableStyles),
                        p_nutShare(manChain,stableStyles,nut2)/ p_manQuantMonth(cattle,manChain))
            );
*

     p_nut2inMan(nut2,manType,manChain) $ (p_nut2InMan(nut2,manType,manChain) )
       =  p_nut2InMan(nut2,manType,manChain) * (1 - p_lossFactorSto(mantype,nut2,manChain));

$endif.herd
