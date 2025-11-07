********************************************************************************
$ontext

   FarmDyn project

   GAMS file : upstreamEF_DE.GMS

   @purpose  : Upstream emission factors from ecoinvent
   @author   :
   @date     : 27.11.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************
* --- CO2 from the provision of inputs: (KTBL online based on ecoinvent 3.X)
*    Already converted in CO2_eq per ton, as we use tons in the purchasing section (for those applicable (feed))
*    for alfalfa: based on Corson and Avadi (2016) p26; pea and beans: umweltbundesamt
table  p_EFInput(inputs,emissions)
                            CO2_eq
MaizSil                      149
GrasSil                      139
*ManCatt
ConcCattle1                 8198
ConcCattle2                 1600
ConcCattle3                  810
milkPowder                  2100
OilsforFeed                  713
WinterWheat                  505
WinterRye                    505
SummerCere                   505
SummerTriticale              505
MaizCCM                      505
WinterBarley                 544
Soybeanmeal                 1770
SoybeanOil                   713
rapeSeedMeal                 869
*Alfalfa
*PlantFat
MinFu                        502
MinFu2                       502
MinFu3                       502
MinFu4                       502
Diesel                     0.349
ASS                        0.883
AHL                        1.019
*Seed
KAS	                       0.915
PK_18_10	                 0.097
KaliMag	                   0.883
Lime	                        21
Herb                       11.09
Fung                       11.09
Insect                     11.09
growthContr                11.09
water	                     0.409
*hailIns
pigletsBought	              89.6
*ManPig
*youngSow
Straw	                      300
Hay	                        300
YoungCow	                 5700
*femaleSexing
*maleSexing
fCalvsRaisBought	        1092.5
;

* --- Emissions from crop specific buildings from ecoinvent () dummy at the moment should be sth per m3 and year

 p_EFBuild(buildings,buildType,"CO2") = 0.001;
$iftheni.herd "%herd%" == "true"
* --- Emissions from manure storage buildings from ecoinvent () dummy at the moment should be sth per m3 and year

 p_EFSilo(silos,manStorage,"CO2") = 0.001;

* --- Emissions from building stables from ecoinvent () dummy at the moment should be sth per place and year

 p_EFStable(stables,hor,"CO2") = 0.001;
$endif.herd
* --- Emissions from machine oeprations from ecoinvent () dummy at the moment should be sth per place and year
 p_EFmachines(machType,machLifeUnit,"CO2") = 0.001;
