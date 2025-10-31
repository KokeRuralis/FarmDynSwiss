********************************************************************************
$ontext

   FarmDyn project

   GAMS file : STABLES_DE.GMS

   @purpose  : Set of stables and their attributes for default model
   @author   :
   @date     : 12.03.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************
$iftheni.mode "%1"=="decl"

  set set_cowStables "Stable for dairy cows"  /
           milk0
           milk30
           milk60
           milk90
           milk120
           milk240
           milk480
  /;

  set set_motherCowStables "Stables for mother cows" / motherCow0,motherCowSmall,motherCowLarge /;

  set set_youngStables "Stable for cattle older than 6 months"
        / youngCattle0
          youngCattle15
          youngCattle60
          youngCattle600
          youngCattle900
       /;
  set set_calvStables  "Stable for calves up to 6 months"
       / calves0
         calves15
         calves60
         calves150
         calves300
      /;

  set set_fatStables     /fat0,fat100,fat3000,fat6000/ ;
  set set_sowStables     /sows0,sows50,sows500 /;
  set set_pigletStables  /piglet0,piglet200,piglet4000 /;

$else.mode

*
*   ---- data relating to stables
*
$onmulti

*
*   --- Straw Quantity required in kg / head and day
*       Kosten für Einstreu oft unterschätzt, in Bauernblatt, 25. Feb. 2012
*       Feel free to update values and cite more credible source
*

$$iftheni.cattleStables defined cattleStables

parameter p_strawQuant(stables,stableStyles) /
  set.cattleStables."Deep_Litter"    2
  set.cattleStables."Tie_Stall"      1.8
  set.cattleStables."Cubicle_House"  1.3
/;

$$endif.cattleStables

$iftheni.cowHerd %cowHerd% == true

    table p_stableSize(stables,stableTypes)



                                milkCow      youngCattle    calves motherCow

    $$iftheni.mc "%farmBranchMotherCows%"=="on"

    motherCow0                                                       eps
    motherCowSmall                                                   100
    motherCowLarge                                                   200

    $$endif.mc
    $$iftheni.dh %dairyHerd% == true

    milk0                          eps
    milk30                          30
    milk60                          60
    milk90                          90
    milk120                        120
    milk240                        240
    milk480                        480
    $$endif.dh

*
*   --- calve stables are always needed with a cow herd
*
    calves0                                                  eps
    calves15                                                  15
    calves60                                                  60
    calves150                                                150
    calves300                                                300

 ;

$endif.cowHerd

$iftheni.c %cattle% == true

    table p_stableSize(stables,stableTypes)

                      youngCattle     calves

    youngCattle0         eps
    youngCattle15         30
    youngCattle60         60
    youngCattle600       600

$iftheni.b "%buyCalvs%"=="true"
    calves0                            eps
    calves15                            15
    calves60                            60
    calves150                          150
$endif.b
 ;

$endif.c

$iftheni.pigHerd %pigHerd% == true

   $$iftheni.sows "%FarmBranchSows%" == on

   table p_stableSize(stables,stableTypes)
                     sows                      piglets
     sows0              eps
     sows50              50
     sows500            500

     piglet0                                       eps
     piglet200                                     200
     piglet4000                                   4000
   ;
   $$endif.sows
   $$iftheni.fat "%FarmBranchFattners%" == on

   table p_stableSize(stables,stableTypes)
                                  fattners
     fat0                            eps
     fat100                          100
     fat3000                        3000
     fat6000                        6000
  ;
  $$endif.fat
;
$endif.pigHerd

$offmulti

* --- manure storage capacity subfloor m^3 in stable types
*     (capacity to store manure 3 month sub floor)

$onempty
  parameter p_ManStorCap(manChain,stables) /


$iftheni.sows "%farmBranchSows%"=="on"

      liquidPig .  sows50                          20
      liquidPig .  sows500                        200

      liquidPig .  piglet200                       20
      liquidPig .  piglet4000                     400

$endif.sows
$iftheni.fat "%farmBranchFattners%"=="on"
      liquidPig .  fat100                          50
      liquidPig .  fat3000                        1500
      liquidPig .  fat6000                        3000
$endif.fat

      /;


$onMulti
*
*   --- CP 12.11.18: Updated slatted floor stable prices according to KTBL Baukost Demo application

$iftheni.cowHerd %cattle% == true

*Costs according to agridea REFLEX 2020, prices per Animal / 7.5.2021 S. Hug

parameter p_stablePriceHead(stables, hor, stableStyles) /

   "milk0"."short"."Slatted_floor"   22054
   "milk30"."short"."Slatted_floor"  22054
   "milk60"."short"."Slatted_floor"  22054
   "milk90"."short"."Slatted_floor"  22054
   "milk120"."short"."Slatted_floor" 22054
   "milk240"."short"."Slatted_floor" 22054
   "milk480"."short"."Slatted_floor" 22054

   "milk30"."short"."Tie_Stall" 22274
   "milk240"."short"."Tie_Stall" 22274

   "milk0"."middle"."Slatted_floor"  22054
   "milk30"."middle"."Slatted_floor"  22054
   "milk60"."middle"."Slatted_floor"  22054
   "milk90"."middle"."Slatted_floor"  22054
   "milk120"."middle"."Slatted_floor" 22054
   "milk240"."middle"."Slatted_floor" 22054
   "milk480"."middle"."Slatted_floor" 22054


   "milk30"."middle"."Tie_Stall" 22274
   "milk240"."middle"."Tie_Stall" 22274
   "milk480"."middle"."Tie_Stall" 22274

   "milk0"."long"."Slatted_floor"   22054
   "milk30"."long"."Slatted_floor"  22054
   "milk60"."long"."Slatted_floor"  22054
   "milk90"."long"."Slatted_floor"  22054
   "milk120"."long"."Slatted_floor" 22054
   "milk240"."long"."Slatted_floor" 22054
   "milk480"."long"."Slatted_floor" 22054



   "milk30"."long"."Tie_Stall"    22274
   "milk240"."long"."Tie_Stall" 22274
   "milk480"."long"."Tie_Stall" 22274


   "milk0"."long"."Deep_Litter"    21859
   "milk30"."long"."Deep_Litter"    21859
   "milk240"."long"."Deep_Litter" 21859

   "motherCowSmall"."long"."Deep_Litter" 24475
   "motherCowLarge"."long"."Deep_Litter" 24475

*
*   --- Todo: Delete these debugging settings once finished
*
   "motherCowSmall"."long"."Slatted_floor"         24475
   "motherCowLarge"."long"."Slatted_floor"         24475

   "motherCowSmall"."long"."Shed" 557
   "motherCowLarge"."long"."Shed" 557
*Shed --> Remisen geschlossen, mittelwert CHF 557/m2 Nutzfläche

*Rindviehmast REFLEX 2020, 11'015 Fr. / Jungtierplatz
   "youngCattle15"."long"."Slatted_floor"  11015
   "youngCattle60"."long"."Slatted_floor"  11015
   "youngCattle600"."long"."Slatted_floor" 11015
   "youngCattle900"."long"."Slatted_floor" 11015

   "youngCattle0"."long"."Deep_Litter"  11015
   "youngCattle15"."long"."Deep_Litter"  11015
   "youngCattle60"."long"."Deep_Litter" 11015
   "youngCattle600"."long"."Deep_Litter" 11015
   "youngCattle900"."long"."Deep_Litter" 11015

   "youngCattle15"."long"."Tie_Stall"    11015
   "youngCattle60"."long"."Tie_Stall"   11015
   "youngCattle600"."long"."Tie_Stall"   11015
   "youngCattle900"."long"."Tie_Stall"   11015

   "youngCattle15"."long"."Cubicle_House"  11015
   "youngCattle60"."long"."Cubicle_House" 11015
   "youngCattle600"."long"."Cubicle_House" 11015
   "youngCattle900"."long"."Cubicle_House" 11015




   "calves0"."long"."Slatted_floor"   11015
   "calves15"."long"."Slatted_floor"  11015
   "calves60"."long"."Slatted_floor"  11015
   "calves150"."long"."Slatted_floor" 11015
   "calves300"."long"."Slatted_floor" 11015
*
*   --- TODO: CP: delete these as they are for debugging only
*
   "calves0"."long"."Deep_Litter"   11015
   "calves15"."long"."Deep_Litter"  11015
   "calves60"."long"."Deep_Litter"  11015
   "calves150"."long"."Deep_Litter" 11015

$$endif.cowHerd


/
;




$ifthenI.mc %farmBranchMotherCows% == on
    p_priceStables(motherCowStables,hor,t)
      = p_stablePriceHead(motherCowStables,hor,"%cowStableInv%") * p_stableSize(motherCowStables,"motherCow")
                                                                 * ([1.+%OutputPriceGrowthRate%/100] ** t.pos);
$endif.mc

$ifthenI.dh %dairyHerd% == true
*
*   --- stable prices, derived from price per stables, 1% price increase per year
*
    p_priceStables(cowStables,hor,t)
      = p_stablePriceHead(cowStables,hor,"%cowStableInv%") * p_stableSize(cowStables,"milkCow")
                                                           * ([1.+%OutputPriceGrowthRate%/100] ** t.pos);

$endif.dh
$ifthenI.cattle %cattle% == true

    p_priceStables(calvStables,hor,t)
       = p_stablePriceHead(calvStables,hor,"%calvesStableInv%") * p_stableSize(calvStables,"calves")
                                                                * ([1.+%OutputPriceGrowthRate%/100] ** t.pos);

    $$ifthen.heifs set heifersstableInv

       p_priceStables(youngStables,hor,t)
          = p_stablePriceHead(youngStables,hor,"%heifersStableInv%") * p_stableSize(youngStables,"youngCattle")
                                                                      * ([1.+%OutputPriceGrowthRate%/100] ** t.pos);
    $$else.heifs

       p_priceStables(youngStables,hor,t)
          = p_stablePriceHead(youngStables,hor,"%bullsStableInv%") * p_stableSize(youngStables,"youngCattle")
                                                                      * ([1.+%OutputPriceGrowthRate%/100] ** t.pos);
    $$endif.heifs

$endif.cattle

$ifthenI.sows "%farmBranchSows%"=="on"

    p_priceStables("sows0","long",t)      = 1;
    p_priceStables("sows50","long",t)     = 2900 * p_stableSize("sows50","sows");
    p_priceStables("sows500","long",t)    = 2650 * p_stableSize("sows500","sows");

    p_priceStables("piglet0","long",t)    =   1;
    p_priceStables("piglet200","long",t)  =   92 * p_stableSize("piglet200","piglets");
    p_priceStables("piglet4000","long",t) =   87 * p_stablesize("piglet4000","piglets");

$endif.sows

$ifthenI.fat "%farmBranchFattners%"=="on"

    p_priceStables("fat0","long",t)       =  1;
    p_priceStables("fat100","long",t)     =  530 * p_stablesize("fat100","fattners");
    p_priceStables("fat3000","long",t)    =  350 * p_stablesize("fat3000","fattners");
    p_priceStables("fat6000","long",t)    =  340 * p_stablesize("fat6000","fattners");

$endif.fat

    p_minInvStableCost(stableTypes,hor,t) $ sum(stables $ (p_stableSize(stables,stableTypes) gt eps),1)
      = smin(stables $ (p_stableSize(stables,stableTypes) gt eps), p_priceStables(stables,hor,t)*0.75);

    p_priceStables(stables,hor,t) $ sum(stableTypes $ (p_stableSize(stables,stableTypes) gt eps),1)
     = p_priceStables(stables,hor,t) -  sum(stableTypes $ (p_stableSize(stables,stableTypes) gt eps),p_minInvStableCost(stableTypes,hor,t));
*
* --- labour needs per month for different stables
*

  parameter p_stableLabByStyle(stables,stableStyles);


$iftheni.cattle %cattle%==true

  p_stableLabByStyle("calves15", stableStyles)      = 450 ;
  p_stableLabByStyle("calves60", stableStyles)      = 0.1 ;
  p_stableLabByStyle("calves150", stableStyles)     = 0.1 ;
  p_stableLabByStyle("calves300", stableStyles)     = 0.1 ;

  p_stableLabByStyle("youngCattle15", stableStyles) = 120 ;
  p_stableLabByStyle("youngCattle60", stableStyles) =  0.1;
  p_stableLabByStyle("youngCattle600",stableStyles) =  0.1;
  p_stableLabByStyle("youngCattle900",stableStyles) =  0.1;

$endif.cattle

$ifthenI.dairyHerd %dairyHerd% == true

  p_stableLabByStyle("milk30", stableStyles)        = (50-22)*30 ;
  p_stableLabByStyle("milk60", stableStyles)        = (40-22)*60 ;
  p_stableLabByStyle("milk90", stableStyles)        = (35-22)*90 ;
  p_stableLabByStyle("milk120", stableStyles)       = (30-22)*120 ;
  p_stableLabByStyle("milk240", stableStyles)       = (27-22)*240 ;
  p_stableLabByStyle("milk480", stableStyles)       = (27-22)*480 ;

    p_stableLab(cowStables,m)         =  p_stableLabByStyle(cowStables, "%cowStableInv%") / card(m);


$endif.dairyHerd

$ifthenI.cattle %cattle% == true
    p_stableLab(calvStables,m)        =  p_stableLabByStyle(calvStables, "%calvesStableInv%") / card(m);

 $$iftheni.beef "%farmBranchBeef%"=="on"
    p_stableLab(youngStables,m)        =  p_stableLabByStyle(youngStables, "%bullsStableInv%") / card(m);
 $$else.beef
    p_stableLab(youngStables,m)        =  p_stableLabByStyle(youngStables, "%heifersStableInv%") / card(m);
 $$endif.beef

    p_lifeTimeS(stables,"long")     = 30;
    p_lifeTimeS(stables,"middle")   = 15;
    p_lifeTimeS(stables,"short")    = 10;

$endif.cattle


$ifthenI.sows "%farmBranchSows%"=="on"

    p_stableLab("sows50",m)         =   (10.0 -7.6) *  50 / card(m);
    p_stableLab("sows500",m)        =   (8.5  -7.6) * 400 / card(m);

    p_lifeTimeS(sowStables,"long")    = 20;
    p_lifeTimeS(pigletStables,"long") = 20;

$endif.sows

$ifthenI.fat "%farmBranchFattners%"=="on"

    p_stableLab("fat100",m)          = (1.02-0.72)  * 100  / card(m);
    p_stableLab("fat3000",m)         = (0.73-0.729) * 3000 / card(m);

    p_lifeTimeS(fatStables,"long")    = 20;

$endif.fat

*
*  ---- manure excretion depending on stable type
*

*
*    1) define the share of the nutrients: the values from the German fertilizer ordinance (DüV) are taken as base (see table p_nutExcreDueV).
*       The adjustment is then done by multipling the percentage share value of a nutrient with the base content.
*       E.g if "solid manure" of the stable type "Tie Stall" has 30% of the NTan content of the DüV manure,
*       then it's p_nutShare value needs to bet set to 0.3.
*
   $$iftheni.cattle "%cattle%"=="true"
      p_nutShare("liquidCattle","Slatted_floor",nut2)    = 1;
      p_nutShare("liquidCattle","Slatted_floor","m3")    = 1;
      p_nutShare("liquidCattle","Cubicle_House","Norg")  = 1;
      p_nutShare("liquidCattle","Cubicle_House","NTan")  = 1;
      p_nutShare("liquidCattle","Cubicle_House","P")     = 1;
   $$endif.cattle

   $$iftheni.pig "%pigherd%"=="true"
      p_nutShare("liquidPig","Slatted_floor",nut2)       = 1;
      p_nutShare("liquidPig","Slatted_floor","m3")       = 1;
   $$endif.pig

   $$iftheni.straw "%strawManure%"=="true"
      p_nutShare("solidCattle","Deep_Litter",nut2)       = 1;
      p_nutShare("solidCattle","Shed",nut2)              = 1;

      p_nutShare("solidCattle","Tie_Stall","Norg")       = 0.558;
      p_nutShare("solidCattle","Tie_Stall","NTan")       = 0.372;
      p_nutShare("solidCattle","Tie_Stall","P")          = 1.15;
      p_nutShare("lightLiquidCattle","Tie_Stall","Norg") = 0.101;
      p_nutShare("lightLiquidCattle","Tie_Stall","NTan") = 0.039;
      p_nutShare("lightLiquidCattle","Tie_Stall","P")    = 0.065;

      p_nutShare("solidCattle","Cubicle_House","Norg")   = 0.558;
      p_nutShare("solidCattle","Cubicle_House","NTan")   = 0.372;
      p_nutShare("solidCattle","Cubicle_House","P")      = 1.15;
*
*      2) define different solid, light liquid manure quantities per herd and stable
*
      p_nutShare("solidCattle","Tie_Stall","m3")         = 0.756;
      p_nutShare("lightLiquidCattle","Tie_Stall","m3")   = 0.411;

      p_nutShare("solidCattle","Deep_Litter","m3")       = 1;
      p_nutShare("solidCattle","Shed","m3")              = 1;

      p_nutShare("solidCattle","Cubicle_House","m3")     = 0.7;
      p_nutShare("LiquidCattle","Cubicle_House","m3")    = 0.3;
   $$endif.straw

$endif.mode
