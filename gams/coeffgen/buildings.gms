********************************************************************************
$ontext

   FARMDYN project

   GAMS file : Buildings.GMS

   @purpose  : Define different storage building/structures
   @author   : W.Britz
   @date     : 10.07.14
   @since    : model/templ.gms, model/templ_decl.gms
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************
*
*  --- read building attributes form data directory
*
   $$batinclude "%datdir%/%buildingsFile%.gms" read

   p_priceBuild(buildings,t)   = p_building(buildings,"invsum")  * [1.+%OutputPriceGrowthRate%/100] ** t.pos;
   p_varCostBuild(buildings,t) = p_building(buildings,"varCost") * [1.+%OutputPriceGrowthRate%/100] ** t.pos;
   p_lifeTimeBuild(buildings)  = p_building(buildings,"lifeTime");


*
*  --- KTBL 2010/2011, page 767
*

$ifi %herd%==true       curBuildings(bunkerSilos)  = YES;

   curBuildType("bunkerSilo") $ sum(curBuildings(bunkerSilos),1) = YES;

$iftheni.cattle "%cattle%"=="true"

   p_buildingNeed("grasSil","bunkerSilo","capac_m3")  = 1/0.65;
   p_buildingNeed("grasSilM","bunkerSilo","capac_m3") = 1/0.65;
$endif.cattle

$if set invPrice  p_priceBuild(buildings,t) = p_priceBuild(buildings,t) * %invPrice%;

$iftheni "%dynamics%" == "comparative-static"


  p_priceBuild(buildings,tCur) $ p_lifeTimeBuild(buildings)
     = [sum(t,p_priceBuild(buildings,t))/card(t)] /  p_lifeTimeBuild(buildings);

  p_lifeTimeBuild(buildings) = 1;

$endif
