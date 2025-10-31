********************************************************************************
$ontext

   FARMDYN project

   GAMS file : ABORT_GUI_SETTINGS.GMS

   @purpose  : Test for combination of not working GUI settings and throw erros
   @author   : Kuhn, Britz
   @date     : 03.08.18
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter.gms

$offtext
********************************************************************************

$iftheni.calib not "%calibRes%"=="farm_empty"
  $$iftheni.calibration "%calibration%"=="false"

    $$iftheni.nHeu "%nHeuristicsToRedBinaries%"=="true"
       $$setglobal nHeuristicsToRedBinaries false
      $$log "Warning: Heuristics to remove unused variables might prevent calibration, now switched off when loading calibration results"
    $$endif.nHeu
  $$endif.calibration
$endif.calib

$iftheni.fert %Fertilization% == FertilizationOrdinance

  $$ifi  not  "%orgTill%" == "off"  $$abort "Organic farming not working with fertilizing according to Fertilization Ordinance"

$endif.fert

$iftheni.agriEnv %agriEnvSchemes% == "true"
    $$ifi not "%Dynamics%" == "Comparative-static"    $$abort "Agri-environmental schemes are only working in comparative-static setting"
*    $$ifi not "%calibration%" == "false"              $$abort "Agri-environmental schemes are not working with calibration"
*    $$ifi not "%calibration%" == "false"              $$abort "Agri-environmental schemes are not working with calibration"
$endIf.agriEnv

$iftheni.FO2020 %fertOrdFile% == "fertord_duev2020"
   $$ifi not %ShareArableLandRedZone% == 0.0  $$ifi not %nPlot% == 1 $$abort "FO 2020 and land in red zones only works with exactly one plot"
   $$ifi not %ShareGrassLandRedZone%  == 0.0  $$ifi not %nPlot% == 1 $$abort "FO 2020 and land in red zones only works with exactly one plot"
   $$ifi not %SharePastureRedZone%    == 0.0  $$ifi not %nPlot% == 1 $$abort "FO 2020 and land in red zones only works with exactly one plot"
$endIf.FO2020

* --- Abort CAP policy settings which do not make sense

$$iftheni.EUcountry "%EUCountry%"=="true"

 $$ifi %policyCAPfile% == "Policy_CAP_de_2023" $$ifi %policyCAPdataFile% == "policy_CAP_data_de"  $$abort "CAP module and data file not matching"
 $$ifi %policyCAPfile% == "Policy_CAP_de" $$ifi %policyCAPdataFile% == "policy_CAP_data_de_2023"  $$abort "CAP module and data file not matching"
 
 $$ifi %policyCAPfile% == "Policy_CAP_de_2023" $$ifi %greening% == "true"                         $$abort "CAP 2023 and Greening switched on"
 $$ifi %policyCAPfile% == "Policy_CAP_de" $$ifi %conditionalityCapPillar1% == "true"              $$abort "CAP 2014 and Conditionality switched on"
 $$ifi %policyCAPfile% == "Policy_CAP_de" $$ifi %ecoSchemesCapPillar1% == "true"                  $$abort "CAP 2014 and Eco-schemes switched on"
 $$ifi "%forceCropResults%" == "1 ha of each system/tillage/intensity"  $ifi "%ecoSchemesCapPillar1%" == "true" $$abort "Force 1 ha and Eco-schemes not working together"
 
 

$$endif.EUcountry 





$ifi  "%farmBranchdairyHerd%"=="true"  $setglobals cows true
$ifi  "%farmBranchmotherCows%"=="true" $setglobals cows true

$iftheni.cows "%farmBranchdairyHerd%"=="true"

* --- Cattle only works when there is a feedregime specified for every month

$ifi NOT "%cowsgrazJAN%" == "ON" $$ifi NOT "%cowsNoGrazJAN%" == "ON" $$ifi NOT "%cowsPartGrazJAN%" == "ON" $$abort "Month without feedregime cows"
$ifi NOT "%cowsgrazFEB%" == "ON" $$ifi NOT "%cowsNoGrazFEB%" == "ON" $$ifi NOT "%cowsPartGrazFEB%" == "ON" $$abort "Month without feedregime cows"
$ifi NOT "%cowsgrazMAR%" == "ON" $$ifi NOT "%cowsNoGrazMAR%" == "ON" $$ifi NOT "%cowsPartGrazMAR%" == "ON" $$abort "Month without feedregime cows"
$ifi NOT "%cowsgrazAPR%" == "ON" $$ifi NOT "%cowsNoGrazAPR%" == "ON" $$ifi NOT "%cowsPartGrazAPR%" == "ON" $$abort "Month without feedregime cows"
$ifi NOT "%cowsgrazMAY%" == "ON" $$ifi NOT "%cowsNoGrazMAY%" == "ON" $$ifi NOT "%cowsPartGrazMAY%" == "ON" $$abort "Month without feedregime cows"
$ifi NOT "%cowsgrazJUN%" == "ON" $$ifi NOT "%cowsNoGrazJUN%" == "ON" $$ifi NOT "%cowsPartGrazJUN%" == "ON" $$abort "Month without feedregime cows"
$ifi NOT "%cowsgrazJUL%" == "ON" $$ifi NOT "%cowsNoGrazJUL%" == "ON" $$ifi NOT "%cowsPartGrazJUL%" == "ON" $$abort "Month without feedregime cows"
$ifi NOT "%cowsgrazAUG%" == "ON" $$ifi NOT "%cowsNoGrazAUG%" == "ON" $$ifi NOT "%cowsPartGrazAUG%" == "ON" $$abort "Month without feedregime cows"
$ifi NOT "%cowsgrazSEP%" == "ON" $$ifi NOT "%cowsNoGrazSEP%" == "ON" $$ifi NOT "%cowsPartGrazSEP%" == "ON" $$abort "Month without feedregime cows"
$ifi NOT "%cowsgrazOCT%" == "ON" $$ifi NOT "%cowsNoGrazOCT%" == "ON" $$ifi NOT "%cowsPartGrazOCT%" == "ON" $$abort "Month without feedregime cows"
$ifi NOT "%cowsgrazNOV%" == "ON" $$ifi NOT "%cowsNoGrazNOV%" == "ON" $$ifi NOT "%cowsPartGrazNOV%" == "ON" $$abort "Month without feedregime cows"
$ifi NOT "%cowsgrazDEC%" == "ON" $$ifi NOT "%cowsNoGrazDEC%" == "ON" $$ifi NOT "%cowsPartGrazDEC%" == "ON" $$abort "Month without feedregime cows"

$endif.cows

$iftheni.beef "%farmBranchbeef%"=="true"

$ifi NOT "%bullsgrazJAN%" == "ON" $$ifi NOT "%bullsNoGrazJAN%" == "ON" $$ifi NOT "%bullsPartGrazJAN%" == "ON" $$abort "Month without feedregime bulls"
$ifi NOT "%bullsgrazFEB%" == "ON" $$ifi NOT "%bullsNoGrazFEB%" == "ON" $$ifi NOT "%bullsPartGrazFEB%" == "ON" $$abort "Month without feedregime bulls"
$ifi NOT "%bullsgrazMAR%" == "ON" $$ifi NOT "%bullsNoGrazMAR%" == "ON" $$ifi NOT "%bullsPartGrazMAR%" == "ON" $$abort "Month without feedregime bulls"
$ifi NOT "%bullsgrazAPR%" == "ON" $$ifi NOT "%bullsNoGrazAPR%" == "ON" $$ifi NOT "%bullsPartGrazAPR%" == "ON" $$abort "Month without feedregime bulls"
$ifi NOT "%bullsgrazMAY%" == "ON" $$ifi NOT "%bullsNoGrazMAY%" == "ON" $$ifi NOT "%bullsPartGrazMAY%" == "ON" $$abort "Month without feedregime bulls"
$ifi NOT "%bullsgrazJUN%" == "ON" $$ifi NOT "%bullsNoGrazJUN%" == "ON" $$ifi NOT "%bullsPartGrazJUN%" == "ON" $$abort "Month without feedregime bulls"
$ifi NOT "%bullsgrazJUL%" == "ON" $$ifi NOT "%bullsNoGrazJUL%" == "ON" $$ifi NOT "%bullsPartGrazJUL%" == "ON" $$abort "Month without feedregime bulls"
$ifi NOT "%bullsgrazAUG%" == "ON" $$ifi NOT "%bullsNoGrazAUG%" == "ON" $$ifi NOT "%bullsPartGrazAUG%" == "ON" $$abort "Month without feedregime bulls"
$ifi NOT "%bullsgrazSEP%" == "ON" $$ifi NOT "%bullsNoGrazSEP%" == "ON" $$ifi NOT "%bullsPartGrazSEP%" == "ON" $$abort "Month without feedregime bulls"
$ifi NOT "%bullsgrazOCT%" == "ON" $$ifi NOT "%bullsNoGrazOCT%" == "ON" $$ifi NOT "%bullsPartGrazOCT%" == "ON" $$abort "Month without feedregime bulls"
$ifi NOT "%bullsgrazNOV%" == "ON" $$ifi NOT "%bullsNoGrazNOV%" == "ON" $$ifi NOT "%bullsPartGrazNOV%" == "ON" $$abort "Month without feedregime bulls"
$ifi NOT "%bullsgrazDEC%" == "ON" $$ifi NOT "%bullsNoGrazDEC%" == "ON" $$ifi NOT "%bullsPartGrazDEC%" == "ON" $$abort "Month without feedregime bulls"
$endif.beef

$iftheni.cows "%cows%"=="true"
$ifi NOT "%heifsgrazJAN%" == "ON" $$ifi NOT "%heifsNoGrazJAN%" == "ON" $$ifi NOT "%heifsPartGrazJAN%" == "ON" $$abort "Month without feedregime heifs"
$ifi NOT "%heifsgrazFEB%" == "ON" $$ifi NOT "%heifsNoGrazFEB%" == "ON" $$ifi NOT "%heifsPartGrazFEB%" == "ON" $$abort "Month without feedregime heifs"
$ifi NOT "%heifsgrazMAR%" == "ON" $$ifi NOT "%heifsNoGrazMAR%" == "ON" $$ifi NOT "%heifsPartGrazMAR%" == "ON" $$abort "Month without feedregime heifs"
$ifi NOT "%heifsgrazAPR%" == "ON" $$ifi NOT "%heifsNoGrazAPR%" == "ON" $$ifi NOT "%heifsPartGrazAPR%" == "ON" $$abort "Month without feedregime heifs"
$ifi NOT "%heifsgrazMAY%" == "ON" $$ifi NOT "%heifsNoGrazMAY%" == "ON" $$ifi NOT "%heifsPartGrazMAY%" == "ON" $$abort "Month without feedregime heifs"
$ifi NOT "%heifsgrazJUN%" == "ON" $$ifi NOT "%heifsNoGrazJUN%" == "ON" $$ifi NOT "%heifsPartGrazJUN%" == "ON" $$abort "Month without feedregime heifs"
$ifi NOT "%heifsgrazJUL%" == "ON" $$ifi NOT "%heifsNoGrazJUL%" == "ON" $$ifi NOT "%heifsPartGrazJUL%" == "ON" $$abort "Month without feedregime heifs"
$ifi NOT "%heifsgrazAUG%" == "ON" $$ifi NOT "%heifsNoGrazAUG%" == "ON" $$ifi NOT "%heifsPartGrazAUG%" == "ON" $$abort "Month without feedregime heifs"
$ifi NOT "%heifsgrazSEP%" == "ON" $$ifi NOT "%heifsNoGrazSEP%" == "ON" $$ifi NOT "%heifsPartGrazSEP%" == "ON" $$abort "Month without feedregime heifs"
$ifi NOT "%heifsgrazOCT%" == "ON" $$ifi NOT "%heifsNoGrazOCT%" == "ON" $$ifi NOT "%heifsPartGrazOCT%" == "ON" $$abort "Month without feedregime heifs"
$ifi NOT "%heifsgrazNOV%" == "ON" $$ifi NOT "%heifsNoGrazNOV%" == "ON" $$ifi NOT "%heifsPartGrazNOV%" == "ON" $$abort "Month without feedregime heifs"
$ifi NOT "%heifsgrazDEC%" == "ON" $$ifi NOT "%heifsNoGrazDEC%" == "ON" $$ifi NOT "%heifsPartGrazDEC%" == "ON" $$abort "Month without feedregime heifs"

$ifi NOT "%calvsgrazJAN%" == "ON" $$ifi NOT "%calvsNoGrazJAN%" == "ON" $$ifi NOT "%calvsPartGrazJAN%" == "ON" $$abort "Month without feedregime calvs"
$ifi NOT "%calvsgrazFEB%" == "ON" $$ifi NOT "%calvsNoGrazFEB%" == "ON" $$ifi NOT "%calvsPartGrazFEB%" == "ON" $$abort "Month without feedregime calvs"
$ifi NOT "%calvsgrazMAR%" == "ON" $$ifi NOT "%calvsNoGrazMAR%" == "ON" $$ifi NOT "%calvsPartGrazMAR%" == "ON" $$abort "Month without feedregime calvs"
$ifi NOT "%calvsgrazAPR%" == "ON" $$ifi NOT "%calvsNoGrazAPR%" == "ON" $$ifi NOT "%calvsPartGrazAPR%" == "ON" $$abort "Month without feedregime calvs"
$ifi NOT "%calvsgrazMAY%" == "ON" $$ifi NOT "%calvsNoGrazMAY%" == "ON" $$ifi NOT "%calvsPartGrazMAY%" == "ON" $$abort "Month without feedregime calvs"
$ifi NOT "%calvsgrazJUN%" == "ON" $$ifi NOT "%calvsNoGrazJUN%" == "ON" $$ifi NOT "%calvsPartGrazJUN%" == "ON" $$abort "Month without feedregime calvs"
$ifi NOT "%calvsgrazJUL%" == "ON" $$ifi NOT "%calvsNoGrazJUL%" == "ON" $$ifi NOT "%calvsPartGrazJUL%" == "ON" $$abort "Month without feedregime calvs"
$ifi NOT "%calvsgrazAUG%" == "ON" $$ifi NOT "%calvsNoGrazAUG%" == "ON" $$ifi NOT "%calvsPartGrazAUG%" == "ON" $$abort "Month without feedregime calvs"
$ifi NOT "%calvsgrazSEP%" == "ON" $$ifi NOT "%calvsNoGrazSEP%" == "ON" $$ifi NOT "%calvsPartGrazSEP%" == "ON" $$abort "Month without feedregime calvs"
$ifi NOT "%calvsgrazOCT%" == "ON" $$ifi NOT "%calvsNoGrazOCT%" == "ON" $$ifi NOT "%calvsPartGrazOCT%" == "ON" $$abort "Month without feedregime calvs"
$ifi NOT "%calvsgrazNOV%" == "ON" $$ifi NOT "%calvsNoGrazNOV%" == "ON" $$ifi NOT "%calvsPartGrazNOV%" == "ON" $$abort "Month without feedregime calvs"
$ifi NOT "%calvsgrazDEC%" == "ON" $$ifi NOT "%calvsNoGrazDEC%" == "ON" $$ifi NOT "%calvsPartGrazDEC%" == "ON" $$abort "Month without feedregime calvs"
$endif.cows

$iftheni.biogas "%farmBranchBiogas%"=="on"

   $$ifi "%dynamics%"=="Short run" $$abort "Short-run and biogas farm branch not compatible"
$endif.biogas
