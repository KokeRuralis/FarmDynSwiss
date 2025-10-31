********************************************************************************
$ontext

   FARMDYN project

   GAMS file : prices.gms

   @purpose  : Defines output prices for certain products


   @author   : David Sch�fer
   @date     : 20.03.2017
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************

* *****
*
* ---- Input and Output Prices for the country "Schweiz"
*
* *****

* --- Input prices for dairy, arable, biogas, sow and fattener production (Currently only German Default values are inserted)

$iftheni.Schweiz "%region%"== "Schweiz"

* --- To change wage rates please refer to /coeffgen/labour.gms

*p_inputprice("WageFull",t,s) $ p_inputPrices("WageFull","conv")                = 8;
*p_inputprice("WageHalf",t,s) $ p_inputPrices("WageHalf","conv")                = 7;
*p_inputprice("WageFlex",t,s) $ p_inputPrices("WageFlex","conv")                = 6;



$iftheni.b %biogas% == true
  p_inputprice("MaizSil",t,s) $ p_inputPrices("MaizSil","conv")                = 40;
  p_inputprice("GrasSil",t,s) $ p_inputPrices("GrasSil","conv")                = 56;
  p_inputprice("manCatt",t,s) $ p_inputPrices("manCatt","conv")                = 0.01;
  p_inputprice("manPig",t,s) $ p_inputPrices("manPig","conv")                  = 0.01;

$else.b
    $$ifi.dh %dairyherd% == true  p_inputprice("MaizSil",sys,t) $ p_inputPrices("MaizSil","conv") = 40;
$endif.b


$iftheni.dh %cattle% == true
 p_inputprice("concCattle1",sys,t) $ p_inputPrices("concCattle1","conv")          = 280;
 p_inputprice("concCattle2",sys,t) $ p_inputPrices("concCattle2","conv")          = 290;
 p_inputprice("concCattle3",sys,t) $ p_inputPrices("concCattle3","conv")          = 340;
 p_inputprice("milkpowder",sys,t) $ p_inputPrices("milkpowder","conv")            = 2460;
 p_inputprice("oilsforFeed",sys,t) $ p_inputPrices("oilsforFeed","conv")          = 1150;
$endif.dh

 p_inputprice("Diesel",sys,t) $ p_inputPrices("Diesel","conv")                    = 1;
 p_inputprice("ASS",sys,t) $ p_inputPrices("ASS","conv")                          = 0.31;
 p_inputprice("AHL"sys,,s) $ p_inputPrices("AHL","conv")                          = 0.26;
 p_inputprice("Seed",sys,t) $ p_inputPrices("Seed","conv")                        = 1;
 p_inputprice("KAS",sys,t) $ p_inputPrices("KAS","conv")                          = 0.31;
 p_inputprice("PK_18_10",sys,t) $ p_inputPrices("PK_18_10","conv")                = 0.24;
 p_inputprice("KaliMag",sys,t) $ p_inputPrices("KaliMag","conv")                  = 0.38;
 p_inputprice("Lime",sys,t) $ p_inputPrices("Lime","conv")                        = 59;
 p_inputprice("Herb",sys,t) $ p_inputPrices("Herb","conv")                        = 1;
 p_inputprice("Fung",sys,t) $ p_inputPrices("Fung","conv")                        = 1;
 p_inputprice("Insect",sys,t) $ p_inputPrices("Insect","conv")                    = 1;
 p_inputprice("growthContr",sys,t) $ p_inputPrices("growthContr","conv")          = 1;
 p_inputprice("water",sys,t) $ p_inputPrices("water","conv")                      = 2.5;
 p_inputprice("hailIns",sys,t) $ p_inputPrices("hailIns","conv")                  = 9.34;

$iftheni.p %pigHerd% == true
 p_inputprice("pigletsBought",sys,t) $ p_inputPrices("pigletsBought","conv")      = 58.6;
    $$ifi.sows "%farmBranchSows%" == "on"      p_inputprice("youngSow",sys,t) $ p_inputPrices("youngSow","conv")                = 338;
 p_inputprice("SoybeanMeal",sys,t) $ p_inputPrices("SoybeanMeal","conv")          = 469;
 p_inputprice("SoybeanOil",sys,t) $ p_inputPrices("SoybeanOil","conv")                  = 469;
 p_inputprice("WinterCere",sys,t) $ p_inputPrices("WinterCere","conv")                  = 205;
 p_inputprice("SummerCere",sys,t) $ p_inputPrices("SummerCere","conv")                  = 220;
 p_inputprice("MaizCCM",sys,t) $ p_inputPrices("MaizCCM","conv")                  =  86;
 p_inputprice("MinFu",sys,t) $ p_inputPrices("MinFu","conv")                      = 650;
$endif.p


* --- Output prices for dairy, arable, sow and fattener production (Currently only German Default values are inserted)


p_price("WinterCere",sys,t) = 224;
p_price("SummerCere",sys,t) = 219;
p_price("WinterRape",sys,t) = 437;
p_price("MaizSil",sys,t)    = 40;
p_price("Potatoes",sys,t)   = 190;
p_price("Sugarbeet",sys,t)  = 38;
p_price("MaizCorn",sys,t)   = 210;
p_price("Summerpeas",sys,t) = 221;
p_price("Summerbeans",sys,t) = 202;
p_price("Winterbarley",sys,t) = 192;


p_price("milk",sys,t) = 320;
p_price("mcalv_HF",sys,t) = 100;
p_price("fcalv_HF",sys,t) = 32;
p_price("youngBull_HF",sys,t) = 550;
p_price("mcalv_SI",sys,t) = 100;
p_price("fcalv_SI",sys,t) = 32;
p_price("youngBull_SI",sys,t) = 550;
p_price("youngBullH_SI",sys,t) = 550;

p_price("oldSow",sys,t) = 367 ;
p_price("pigletsSold",sys,t) = 58.6;
p_price("PigletSold",sys,t) = 57.1 ;
p_price("pigmeat",sys,t) = 1.75;

$endif.Schweiz

