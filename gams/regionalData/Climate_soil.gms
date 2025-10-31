********************************************************************************
$ontext

   FARMDYN project

   GAMS file : climate_soil.gms

   @purpose  : Defines regional climate and soil conditions


   @author   : David Sch�fer
   @date     : 20.03.2017
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************

$iftheni.Schweiz "%region%" == "Schweiz"
****
*
*  Climate and soil data in FarmDyn primarily defines the available number of field working days in 2-weeks resolution (see /coeffgen/tech.gms).
*  Climate zones account for different elevations and rainfall patterns according to twelve different climate zones in Germany (see KTBL 2016/17,p. 247)
*  Soils account for light, medium and heavy soils (Sand, Schluff, Ton).
*
***

* --- p_soilShare have to add up to unity

p_soilShare("l","Share") = 0.2 ;
p_soilShare("m","Share" ) = 0.5 ;
p_soilShare("h","Share") = 0.3 ;

p_soilShare(soil,"Share") = p_soilShare(soil,"Share") * 1 / sum(soil1, p_soilShare(soil1,"Share"));

* --- Adjusting the climate zone; Choose a climate zone by changing XX "czXX" to a number between 1-12


curClimateZone(climateZone) = NO;
curClimateZone("cz11") = YES;





$endif.Schweiz
