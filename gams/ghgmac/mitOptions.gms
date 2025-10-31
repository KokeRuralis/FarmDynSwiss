********************************************************************************
$ontext

   CAPRI project

   GAMS file : REDRUNS.GMS

   @purpose  : To control for enforced mitigation options given via GUI as globals
   @author   : David Schaefer
   @date     : 09/08/2022
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************


*------------------------------------------------------------------------------
*
*   Feed additive mitigation options including vegetable oil and Bovaer
*     * There is no literature on the effect of feeding multiple feed additives at a time
*       Hence, we we throw an error when both are on at the same time
*------------------------------------------------------------------------------

* ---- The different feed additives
$ifi "%mitimeasureoptvegetableOil%"    == on $$setglobal vegetableOil true
$ifi "%mitimeasureoptBovaer%"          == on $$setglobal Bovaer true

* --- As there is no literature on simultaneaous use of feed additivies they are mutually exclusive
$ifi "%vegetableOil%"==true $$ifi "%Bovaer%"==true abort "Combination of Bovaer and vegetable oil together is not backed by literature";

* ---  Both feed adds have common parameters and equations and therefore are partly controlled
*      by the same global

$ifi "%vegetableOil%" == true $$setglobal feedAddOn true
$ifi "%Bovaer%" == true $$ setglobal feedAddOn true

*------------------------------------------------------------------------------
*
*   Extended lactation period of cows based on an improved animal health.
*   The improved animal health is generated through higher variable costs per animal
*   which cover veterinarian costs
*
*------------------------------------------------------------------------------
$ifi "%mitimeasureoptLacFloor%" == on $$setglobal lacFloor true
* ----------------------------------------------------------------------------
*
*   Application techniques close to the ground that prevent N-related emissions
*
*-----------------------------------------------------------------------------
$ifi "%mitimieasureoptApplTech%" == on $$setglobal applTech true
