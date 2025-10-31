********************************************************************************
$ontext

   FARMDYN project

   GAMS file : STABLES.GMS

   @purpose  : Define stable sizes, under floor manure storage capacities,
               prices and lifetime, labour need related to stables,
               livetsock units for animals
   @author   : Bernd Lengers
   @date     : 12.11.10
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************

*
*   ---- If initial assessts are treated as sunk costs, the file "introduce_fixed_stable_size.gms" is included and created a element of the relevant
*        stable set which corresponds to the observed stable size. Labour need and stable prices are interpolated in stalbes.gms.
*
$batinclude 'util/title.gms' "'%titlePrefix% Define coefficients relating to stables'"

*
*   --- read data on stable size and
*
$batinclude "%datDir%/%stableFile%.gms" read
*
*   --- Storage capacity in m3/animal subfloor / floor
*   https://protecteau.be/resources/shared/publications/fiches-techniques/classeur-eau-nitrate/9.2_MiseNormes(1506).pdf

parameter p_storCap(stables, manChain, stableStyles,stableTypes) /

$$iftheni.cowstables defined cowStables

*
* --- Slatted floows
*

 set.cowStables."liquidCattle"."Slatted_floor"."milkCow"             10
 set.motherCowStables."liquidCattle"."Slatted_floor"."motherCow"     6.7
 set.youngStables."liquidCattle"."Slatted_floor"."youngCattle"       5.6
 set.calvStables."liquidCattle"."Slatted_floor"."calves"             1.9

*
* --- Tie stalls
*
$iftheni.straw "%strawManure%"=="true"

 set.cowStables."solidCattle"."Tie_Stall"."milkCow"                  8.5
 set.cowStables."lightLiquidCattle"."Tie_Stall"."milkCow"            1.3
 set.motherCowStables."solidCattle"."Tie_Stall"."motherCow"          6.0
 set.motherCowStables."lightLiquidCattle"."Tie_Stall"."motherCow"    0.9
 set.calvStables."solidCattle"."Tie_Stall"."calves"            2.5
 set.calvStables."lightLiquidCattle"."Tie_Stall"."calves"       0.4

*
* --- Shed and Deep_Litter
*
 set.cowStables."solidCattle"."Shed"."milkCow"                 11.7
 set.motherCowStables."solidCattle"."Shed"."motherCow"         7.0
 set.youngStables."solidCattle"."Shed"."youngCattle"           5.8
 set.calvStables."solidCattle"."Shed"."calves"                 1.6

 set.motherCowStables."solidCattle"."Deep_Litter"."motherCow"  11.7
 set.cowStables."solidCattle"."Deep_Litter"."milkCow"          11.7
 set.calvStables."solidCattle"."Deep_Litter"."calves"          1.6

*
* --- Cubicle_House
*
 set.cowStables."solidCattle"."Cubicle_House"."milkCow"           5.4
 set.cowStables."liquidCattle"."Cubicle_House"."milkCow"          4.9
 set.motherCowStables."solidCattle"."Cubicle_House"."motherCow"   3.6
 set.calvStables."solidCattle"."Cubicle_House"."calves"           1.2
$$endif.straw

 set.motherCowStables."liquidCattle"."Cubicle_House"."motherCow"  3.2
 set.calvStables."liquidCattle"."Cubicle_House"."calves"          1.4

$$endif.cowstables
$$iftheni.youngStables defined youngStables
$iftheni.straw "%strawManure%"=="true"
 set.youngStables."solidCattle"."Tie_Stall"."youngCattle"            6.0
 set.youngStables."lightLiquidCattle"."Tie_Stall"."youngCattle"  0.9
 set.youngStables."solidCattle"."Deep_Litter"."youngCattle"    5.8
 set.youngStables."solidCattle"."Cubicle_House"."youngCattle"     3
$endif.straw
 set.youngStables."liquidCattle"."Cubicle_House"."youngCattle"    2.7
$$endif.youngStables
/;


$ifthenI.dh %cattle% == true

  $$iftheni.dairy %farmBranchDairy% == on
     p_manStorCap(manChain,cowStables)
        = p_storCap(cowStables,manChain,"%cowStableInv%",      "milkCow")     * p_stableSize(cowStables,"milkCow");
  $$endif.dairy


  $$iftheni.beef %farmBranchBeef% == on

    p_manStorCap(manChain,youngStables)
        = p_storCap(youngStables,manChain,"%bullsStableInv%", "youngCattle") * p_stableSize(youngStables,"youngCattle");

  $$else.beef

   p_manStorCap(manChain,youngStables)
     = p_storCap(youngStables,manChain,"%heifersStableInv%", "youngCattle") * p_stableSize(youngStables,"youngCattle");

  $$endif.beef

   p_manStorCap(manChain,calvStables)
      = p_storCap(calvStables,manChain,"%calvesStableInv%",  "calves")      * p_stableSize(calvStables,"calves");


    p_stableNeed("cows",breeds,"milkCow")           = 1;
*
*   --- 0.5 months in farm, all in winter
*
    p_stableNeed("mcalvsSold",breeds,"calves")      = 0.5/12;
    p_stableNeed("fcalvsSold",breeds,"calves")      = 0.5/12;
*
    p_stableNeed("fCalvsRais",breeds,"calves")      = 0.5;
    p_stableNeed("fCalvsRais",breeds,"youngCattle") = 0.5;
    p_stableNeed("mCalvsRais",breeds,"calves")      = 0.5;

    p_stableNeed("heifs",breeds,"youngCattle")      = 1;
$endif.dh


$ifthenI.mc %farmBranchMotherCows% == on
    p_manStorCap(manChain,motherCowStables)
        = p_storCap(motherCowStables,manChain,"%motherCowStableInv%", "motherCow") * p_stableSize(motherCowStables,"motherCow");
    p_stableNeed("motherCow","%motherCowBreed%","motherCow")           = 1;

$endif.mc
$iftheni.beef "%farmBranchBeef%"=="on"
    p_stableNeed("bulls",breeds,"youngCattle")              = 1;
$endif.beef

$ifthenI.sows "%farmBranchSows%"=="on"

    p_stableNeed("sows","","sows")                = 1;
    p_stableNeed("piglets","","piglets")          = 1;

$endif.sows

$ifthenI.fat "%farmBranchFattners%"=="on"
    p_stableNeed("earlyFattners","","fattners")   = 1;
    p_stableNeed("midFattners","","fattners")     = 1;
    p_stableNeed("lateFattners","","fattners")    = 1;
    p_stableNeed("fattners","","fattners")        = 1;

$endif.fat

    p_priceStables(stables,hor,t) $ ( (p_priceStables(stables,hor,t) eq 0)
                                          $ sum(stableTypes_to_stables(stableTypes,stables) $ p_stableSize(stables,stableTypes),1)
         $ sum(stableTypes_to_stables(stableTypes,stables1) $ (stableTypes_to_stables(stableTypes,stables)
                              $ (p_priceStables(stables1,hor,t) gt eps)),1))
             = 1;

    set sameTypeStable(stables,stables1);

    sameTypeStable(stables,stables1) $ sum(stableTypes $ (p_stableSize(stables,stableTypes) $ p_stableSize(stables1,stableTypes)),1) = yes;
    set s_min(stables,stables);

    s_min(sameTypeStable(stables,stables1))
        $ (smax((stables2,hor,StableTypes) $ ((p_stableSize(stables2,stableTypes) lt p_stableSize(stables,stableTypes))
                    $ p_priceStables(stables2,hor,"%firstYear%") $ p_stableSize(stables,stableTypes) $ (p_stableSize(stables2,stableTypes) gt eps)),
                        p_stableSize(stables2,stableTypes))
                         eq sum(stableTypes  $ p_stableSize(stables,stableTypes), p_stableSize(stables1,stableTypes))) = YES;

    set s_max(stables,stables);


    s_max(sameTypeStable(stables,stables1))
        $ (smin( (stables2,hor,stableTypes) $ ((p_stableSize(stables2,stableTypes) gt p_stableSize(stables,stableTypes))
                    $ p_priceStables(stables2,hor,"%firstYear%") $ p_stableSize(stables,stableTypes) $ p_stableSize(stables2,stableTypes)),
                        p_stableSize(stables2,stableTypes))
                         eq sum(stableTypes  $ p_stableSize(stables,stableTypes), p_stableSize(stables1,stableTypes))) = YES;


    $$ifi not defined motherCowStables set motherCowStables / dummy /;

    p_priceStables(stables,hor,t) $ ( (not p_priceStables(stables,hor,t)) $ (not sum(sameas(stables,motherCowStables),1)))
     = sum[stableTypes $ p_stableSize(stables,stableTypes),
         {
*
*         --- price per unit for the largest stable which is smaller compared to the current size
*             (= next smaller)
*
           sum(s_min(stables,stables1),p_priceStables(stables1,hor,t)/p_stableSize(stables1,stableTypes))

*
*         --- Number of additional stable places compared to next smaller size
*
          + (
               p_stableSize(stables,stableTypes)
              -sum(s_min(stables,stables1), p_stableSize(stables1,stableTypes))
            )
*
*         --- divided by difference in stable places between next larger and next smaller size
*
          / (  sum(s_max(stables,stables1), p_stableSize(stables1,stableTypes))
              -sum(s_min(stables,stables1), p_stableSize(stables1,stableTypes))
             )
*
*         --- multiplied with price difference between the next larger and next smaller size
*
          * (  sum(s_max(stables,stables1),p_priceStables(stables1,hor,t)/p_stableSize(stables1,stableTypes))
              -sum(s_min(stables,stables1),p_priceStables(stables1,hor,t)/p_stableSize(stables1,stableTypes))
             )


         }
            * p_stableSize(stables,stableTypes)
      ]

   ;

*
* --- interpolation of stable labour need between given points
*
  p_stableLab(stables,m) $ (not p_stableLab(stables,m))
     = sum[stableTypes $ p_stableSize(stables,stableTypes),
*
*        --- higher price per unit (= larger stable size)
*
         {   sum(s_min(stables,stables1),p_stableLab(stables1,m)/p_stableSize(stables1,stableTypes))

          + (
               p_stableSize(stables,stableTypes)
              -sum(s_min(stables,stables1), p_stableSize(stables1,stableTypes))
            )
          / (  sum(s_max(stables,stables1), p_stableSize(stables1,stableTypes))
              -sum(s_min(stables,stables1), p_stableSize(stables1,stableTypes))
             )

          * (  sum(s_max(stables,stables1),p_stableLab(stables1,m)/p_stableSize(stables1,stableTypes))
              -sum(s_min(stables,stables1),p_stableLab(stables1,m)/p_stableSize(stables1,stableTypes))
             )


         }
            * p_stableSize(stables,stableTypes)
      ]
   ;


$ifi %herd%== true    p_stableLab(stables,m)  $ ((not p_stableLab(stables,m)) $  sum(stableTypes $ (p_stableSize(stables,stableTypes) gt 0),1)) = 0.1 /card(m);


 stables_to_mach(stables,machType) $ (not sum(stableTypes $ (p_stableSize(stables,stableTypes) gt 0),1)) = no;



$iftheni.animals defined p_priceStables



$iftheni "%dynamics%" == "comparative-static"
*
* --- convert into investment costs per year of lifetimes of the stables
*
  p_priceStables(stables,hor,t) $ p_lifeTimeS(stables,hor)
     = [sum(t1,p_priceStables(stables,hor,t1))/card(t1)] /  p_lifeTimeS(stables,hor);

  p_minInvStableCost(stableTypes,hor,t) $ sum(stables $ (p_stableSize(stables,stableTypes) gt eps), p_lifeTimeS(stables,hor))
    = [sum(t1,p_minInvStableCost(stableTypes,hor,t1))/card(t1)]
         / smax(stables $ (p_stableSize(stables,stableTypes) gt eps), p_lifeTimeS(stables,hor));

  p_lifeTimeS(stables,hor) = 1;

$endif

$if set invPrice  p_priceStables(stables,hor,t) = p_priceStables(stables,hor,t) * %invPrice%

$endif.animals

*
*   --- If the initial assests of the farms are fixed, subfloor storage is set to zero and an initial silo of the precise size is
*       provided to allow the represntation of the observed farm.
*
