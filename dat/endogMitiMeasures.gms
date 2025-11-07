********************************************************************************
$ontext

   FARMDYN project

   GAMS file : BUILDINGS_DE.GMS

   @purpose  : Endogenous mitigation options
   @author   : David Sch�fer
   @date     : 17.08.2022
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy

$offtext
********************************************************************************
* -----------------------------------------------------------------------------
*
*  Mitigation measure  - extended lactation
*
* -----------------------------------------------------------------------------

* --- a) Associated variable costs for long lactation periods
      p_VCost("cows%MilkYield%00_long",curBreeds,t) =  p_VCost("cows%MilkYield%00_long",curBreeds,t) + 35;

* --- b) Fixed lactations for short and long animals
      p_nLac("cows%MilkYield%00_short") = 2.7;
      p_nLac("cows%MilkYield%00_long")  = 4;

* -----------------------------------------------------------------------------
*
*  Mitigation measure  - Bovaer
*
* -----------------------------------------------------------------------------

