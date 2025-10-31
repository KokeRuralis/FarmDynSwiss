********************************************************************************
$ontext

   FARMDYN project

   GAMS file : BUILDINGS_DE.GMS

   @purpose  : Define sets for buildings and declare attributes
   @author   :
   @date     : 12.03.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************
$iftheni.mode "%1"=="decl"

  set s_bunkerSilos /
                   bunkerSilo0
                   bunkerSilo450
*                   bunkerSilo900
*                   bunkerSilo1620
*                   bunkerSilo2640
*                   bunkerSilo3630
*                   bunkerSilo4620
*                   bunkerSilo8580
*                   bunkerSilo11870
                   bunkerSilo26550
                 /;

set s_potaStores /
                    potaStore0
                    potaStore100t
                    potaStore500t
                    potaStore11250t
                 /;

  set buildings  /
                    set.s_potaStores
                    set.s_bunkerSilos
                   /;

$else.mode

   table p_building(buildings,buildAttr)
                     invSum   capac_t  capac_m3   lifeTime    varCost

   potaStore500t    195850      500                 12          323
*
*  --- KTBL 2014/15 p.144
*
  bunkerSilo0                            eps        20
  bunkerSilo450      62100               450        22
*  bunkerSilo900      60900               900        20
*  bunkerSilo1620     84490              1620        20
*  bunkerSilo2640    115770              2640        20
*  bunkerSilo3630    127110              3630        20
*  bunkerSilo4620    138450              4620        20
*  bunkerSilo8580    218250              8580        20
*  bunkerSilo11870   284970             11870        20
  bunkerSilo26550   3663900             26550       22
   ;

   curBuildings(buildings) $ (sum(curcrops(potatoes),1) $ sum(sameas(buildings,s_potaStores),1)) = yes;

   curBuildType("potaStore")                   $ sum(curcrops(potatoes),1)      = yes;
   p_buildingNeed(prods,"potaStore","capac_t") $ sum(sameas(prods,potatoes),1)  = 1;

   curBuildings(bunkerSilos) $ sum(curCrops(maizSilage),1) = YES;
   curBuildings(bunkerSilos) $ sum(curCrops(GPS),1)        = YES;

   p_buildingNeed(prods,"bunkerSilo","capac_m3") $ sum(sameas(prods,maizSilage),1)  = 1/0.7;
   p_buildingNeed(prods,"bunkerSilo","capac_m3") $ sum(sameas(prods,GPS),1)         = 1/0.7;

$endif.mode
