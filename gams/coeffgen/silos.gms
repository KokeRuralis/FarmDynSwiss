********************************************************************************
$ontext

   FARMDYN project

   GAMS file : Silos.GMS

   @purpose  : Define size of manures silos, costs of coverage types,
               Investment costs and lifetimes


   @author   : Bernd Lengers
   @date     : 06.10.11
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************

$batinclude 'util/title.gms' "'%titlePrefix% Define coefficients relating to manure silos'"

$iftheni.bio %biogas%==true

  parameter p_siloBiogas(bhkw)     "digestate storage capacity of biogas plant silos"
   /
     150kW   1500
     250kW   2900
     500kW   5500
   /;

* --- Values above calculated by DS but too low, increased by 50 % to be sure that storage capacity is not restrictive

 p_siloBiogas(bhkw)   =  p_siloBiogas(bhkw) * 1000 ;

$endif.bio


$ifi not "%herd%"=="true" $exit

$batinclude "%datDir%/%SiloFile%.gms" read

$if set invPrice  p_priceSilo(silos,tCur) = p_priceSilo(silos,tCur) * %invPrice%;


