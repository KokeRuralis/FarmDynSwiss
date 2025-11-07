********************************************************************************
$ontext

   FARMDyn project

   GAMS file : Build_data.GMS

   @purpose  : Convert Ktbl Regression results, machine data, direct cost etc.
               into format required by FarmDyn
   @author   : J. Heinrichs, C. Pahmeyer, W.Britz
   @date     : 11.12.20
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************

$offlisting
$onmulti
$onglobal
$setglobal curDir %system.fp%


$include 'incgen/UserInc.gms'


* --- Data taken from multiple sources including KTBL Books on Betriebswirtschaft Landwirtschaft, Düngeverordnung,etc
* --- (A hand book how to manipulate the data and construct a country/region specific crop data base is available on the FarmDyn Web-Documentation [TODO]

$$batinclude "%datDir%/User/%CropDataSource%.gms" read


