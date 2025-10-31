********************************************************************************
$ontext

   CAPRI project

   GAMS file : initialize_cropsData.gdx

   @purpose  :
   @author   :
   @date     : 11.03.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************
$offlisting
$onempty
**********************************************************************************
*
*   Set definition:
*             [1] Sets used in this file to be consistent with FarmDyn sets
*             [2] Definitions for crop groupings
*
*
*
**********************************************************************************

****************************************************************
*
*   --- [1] Miscellaneous sets
*
****************************************************************

*           "Sys" defines if a crop is produced org or conventional,
set sys    /conv,org/;
*           "M" returns the month of each year
set m      /JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC/
*           "soil" defines if a soil is light, middle, or high
set soil   /l,m,h/
*           "till" defines the tillage system
set till   /mintill,noTill,plough,org/;
*           "unit" is used for p_inputQuant to determine actual quantities in order to link them to emissions
set unit   / "t/ha", "EUR/t", "EUR/ha", "kg/ha", "EUR/kg", "m3/ha", "EUR/m3", "EUR/EUR",
             "EUR/1000 EUR", "COUNT/ha", "EUR/Count", "EUR/100 EUR", "U/ha", "EUR/U",
             "m2/ha", "EUR/m2", "m/ha", "EUR/m", "l/ha", "EUR/l"
           /;

*           "inputs" return all available inputs which can be purchased
set  inputs "Inputs"/
  'Wage rate full time       ' "Wage rate full time       "
  'Wage rate half time       ' "Wage rate half time       "
  'Wage rate flexible hourly ' "Wage rate flexible hourly "
  'MaizSil                   ' "MaizSil                   "
  'GrasSil                   ' "GrasSil                   "
  'ManCatt                   ' "ManCatt                   "
  'ConcCattle1               ' "ConcCattle1               "
  'ConcCattle2               ' "ConcCattle2               "
  'ConcCattle3               ' "ConcCattle3               "
  'milkPowder                ' "milkPowder                "
  'OilsForFeed               ' "OilsForFeed               "
  'WinterWheat               ' "WinterWheat               "
  'WinterRye                 ' "WinterRye                 "
  'SummerCere                ' "SummerCere                "
  'SummerTriticale           ' "SummerTriticale           "
  'MaizCCM                   ' "MaizCCM                   "
  'WinterBarley              ' "WinterBarley              "
  'SoyBeanMeal               ' "SoyBeanMeal               "
  'SoybeanOil                ' "SoybeanOil                "
  'rapeSeedMeal              ' "rapeSeedMeal              "
  'Alfalfa                   ' "Alfalfa                   "
  'PlantFat                  ' "PlantFat                  "
  'MinFu                     ' "MinFu                     "
  'MinFu2                    ' "MinFu2                    "
  'MinFu3                    ' "MinFu3                    "
  'MinFu4                    ' "MinFu4                    "
  'feedAdd_Bovaer            ' "feedAdd_Bovaer            "
  'feedAdd_VegOil            ' "feedAdd_VegOil            "
  'Diesel                    ' "Diesel                    "
  'ASS                       ' "ASS                       "
  'AHL                       ' "AHL                       "
  'seed                      ' "seed                      "
  'KAS                       ' "KAS                       "
  'PK_18_10                  ' "PK_18_10                  "
  'dolophos                  ' "dolophos                  "
  'KaliMag                   ' "KaliMag                   "
  'Lime                      ' "Lime                      "
  'Herb                      ' "Herb                      "
  'Fung                      ' "Fung                      "
  'Insect                    ' "Insect                    "
  'growthContr               ' "growthContr               "
  'water                     ' "water                     "
  'hailIns                   ' "hailIns                   "
  'pigletsBought             ' "pigletsBought             "
  'ManPig                    ' "ManPig                    "
  'youngSow                  ' "youngSow                  "
  'straw                     ' "straw                     "
  'Hay                       ' "Hay                       "
  'YoungCow                  ' "YoungCow                  "
  'femaleSexing              ' "femaleSexing              "
  'maleSexing                ' "maleSexing                "
  'fCalvsRaisBought          ' "fCalvsRaisBought          "
  'mCalvsRaisBought          ' "mCalvsRaisBought          "
 /;


****************************************************************
*
*   --- [2] Crop groupings
*
***************************************************************

* --- All crops (alias crops) called in:
*                    ..\dat\crops_de.gms
*                    ..\model\templ_decl.gms

  set set_crops_and_prods "crop and products of the same name" / WinterWheat      "Winter wheat"
                                                                 WinterBarley     "Winter barley"
                                                                 WinterRye        "Winter rye"
                                                                 SummerCere       "Summer cereals"
                                                                 SummerTriticale  "Summer triticale"
                                                                 WinterRape       "Winter rapeseed"
                                                                 Potatoes         "Potatoes"
                                                                 Sugarbeet        "Sugar beet"
                                                                 MaizCorn         "Maize, corn"
                                                                 MaizCCM          "Maize, corn-cobb-mix"
                                                                 Summerpeas       "Summer peas"
                                                                 Summerbeans      "Summer beans"
                                                                 WheatGPS         "Wheat, whole plant silage"
                                                                 MaizSil          "Maize, silage"
                                                                 Alfalfa          "Alfalfa"
                                                                 /;

alias(set_crops_and_prods,crops);




* --- Definition of all arable crops called in:
*                     ..\dat\crops_de.gms
*                     ..\model\templ_decl.gms

   set arableCrops(crops) /
        WinterWheat
        WinterBarley
        WinterRye
        SummerCere
        SummerTriticale
        WinterRape
        Potatoes
        Sugarbeet
        MaizCorn
        MaizCCM
        Summerpeas
        Summerbeans
        WheatGPS
        MaizSil
        Alfalfa
 /;



* --- Definition of catch crops called in:
*                     ..\dat\crops_de.gms
*                     ..\model\templ_decl.gms
*                     .....
  set catchCrops(crops) "Catch crops" /
  /;

* --- Ungainly solution for ccCrops and feed_ccCrops to comply with _ktbl data
   set ccCrops(*) "Catch Crops" /
   /;

   set feed_ccCrops(crops) "catch crops used as feed" /
   /;



* --- Definition of all feeds for biogas from the predefined crop list

  set biogas_feed(crops) /
              maizSil
              maizCorn
              maizCCM
              wheatGPS          /;


* --- All cash crops from the predefined crops list

   set cashCrops(crops) /

      winterWheat,winterBarley,winterRye,summerCere,summerTriticale,winterRape,summerBeans,summerPeas,
      MaizCorn,potatoes,sugarBeet,MaizCCM,
      MaizSil,WheatGPS
   /;

* --- All crops related to grains excluding maize

   set cere(crops)   /
    winterWheat,wheatGPS,winterBarley,winterRye,summerCere,summerTriticale
   /;

* --- Feed for pigs also include maizcorn and ccm
   set cereFeedsPigGDX(crops) /
    winterWheat,wheatGPS,winterBarley,winterRye,summerCere,summerTriticale,MaizCorn,maizCCM
   /;

* --- Legumes for partly selling and feeding

    set leg(crops) /
    summerPeas,summerBeans,Alfalfa
   /;

* --- All maize products

   set maize(crops) /
    maizSil,maizCCM,maizCorn
   /;


* --- Crops planted on arable land but not sold
   set no_cashCrops(crops) /
        Alfalfa
   /;

* --- All root crops

   set rootCrops(crops)  /
    potatoes,sugarBeet
   /;


* --- Some crops required in crops_de.gms as sets
   set Wintercere(crops)  /WinterWheat,WinterBarley,WinterRye/;
   set Summercere(crops)  /SummerCere,SummerTriticale/;
   set Potatoes(crops)    /Potatoes/;
   set sugarbeet(crops)  /Sugarbeet/;
   set Rapeseed(crops)    /winterRape/;
   set maizSilage(crops) /maizSil/;
   set GPS(crops)         /wheatGPS/;
   set grain_wheat(crops) /WinterWheat/;
   set grain_barley(crops)/WinterBarley/;
   set grain_rye(crops)   /WinterRye/;
   set grain_maize(crops) /MaizCorn/;
   set maizCCM(crops)    /maizCCM/;
   set grain_oat(crops)   //;
   set other(crops)       //;
   set hay(crops)         //;
   set vegetables(crops)  //;
   set grainleg(crops)    /Summerpeas,Summerbeans/;
   set OtherGrains(crops) /SummerCere, SummerTriticale/;

* --- All crops harvested in summer months

   set SummerHarvest(set_crops_and_prods)
   /
      SummerCere
      SummerTriticale
      Potatoes
      Sugarbeet
      MaizCorn
      MaizCCM
      Summerpeas
      Summerbeans
      MaizSil
      Alfalfa
   /;


set cropShareGrp "Crop group with maximal shares" / cere,rootCrops,legumes,maize/;

set cropShareGrp_crops(cropShareGrp,crops) / cere.(set.cere)
                                             rootCrops.(set.rootCrops)
                                             legumes.(set.leg)
                                             maize.(set.maize)
                          /;



* --- Taken from KTBL data

   set monthHarvestCrops(crops,sys,m)
                   /"WinterWheat"."conv"."sep"
                   "WinterBarley"."conv"."sep"
                   "WinterRye"."conv"."sep"
                   "SummerCere"."conv"."aug"
                   "SummerTriticale"."conv"."sep"
                   "WinterRape"."conv"."aug"
                   "Potatoes"."conv"."oct"
                   "Sugarbeet"."conv"."oct"
                   "MaizCorn"."conv"."oct"
                   "MaizCCM"."conv"."oct"
                   "Summerpeas"."conv"."aug"
                   "Summerbeans"."conv"."sep"
                   "WheatGPS"."conv"."aug"
                   "MaizSil"."conv"."oct"

                                                                 /;
*yields in dt/ha according to "Deckungsbeitragskatalog 2019"
PARAMETER p_cropYield(*,*) /
'WinterWheat'.'conv' 7.0
*Winterweizen TOP ÖLN intensiv
'WinterBarley'.'conv' 7.5
*Wintergerste ÖLN intensiv
'SummerCere'.'conv' 6.0
*Sommerweizen TOP ÖLN intensiv
'WinterRape'.'conv' 4.0
*Raps ÖLN intensiv
'Potatoes'.'conv' 45.0
*Speisekartoffeln ÖLN Grosshandel
'Sugarbeet'.'conv' 75.0
*Zuckerrüben ÖLN ab Feld
'MaizCorn'.'conv' 10.0
*Körnermais ÖLN
'MaizCCM'.'conv' 14.3
*CCM ÖLN ab Feldrand
'Summerpeas'.'conv' 4.2
*Eiweisserbsen ÖLN intensiv
'Summerbeans'.'conv' 4.2
*Ackerbohnen ÖLN intensiv
*'WheatGPS'.'Yield' 40.0 --> not found in DB Katalog 2019
'MaizSil'.'conv' 56.5
*Silomais ÖLN stehend ab Feld
*'Alfalfa'.'Yield' 10.2 --> not found in DB Katalog 2019
*'CCclover'.'Yield' 18 --> not found in DB Katalog 2019
* --- German data for remaining crops
'WinterRye'.'conv' 6.0
'SummerTriticale'.'conv' 6.0
'Alfalfa'.'conv' 10.2
'WheatGPS'.'conv' 36.0
/;
 p_cropYield(crops,'Change,conv % p.a.')   = eps;


* --- Crop price as default settings for GUI

 parameter p_cropPrice(*,*)/

       "WinterWheat"     ."conv"       500
       "WinterBarley"    ."conv"       340
       "WinterRye"       ."conv"       365
* --- No data - Value assumed
       "MaizCorn"        ."conv"       365
       "SummerCere"      ."conv"       500
* --- No data - Value assumed
       "SummerTriticale" ."conv"       500
       "WinterRape"      ."conv"       795
       "SummerBeans"     ."conv"       345
       "SummerPeas"      ."conv"       365
* ---
       "WheatGPS"        ."conv"       140
       "MaizSil"         ."conv"       140
       "MaizCCM"         ."conv"       196
       "GrasSil"         ."conv"        32
       "Alfalfa"         ."conv"       180
       "Potatoes"        ."conv"       475
       "SugarBeet"       ."conv"       57.0
       "CCclover"        ."conv"       EPS
 /;

 p_cropPrice(crops,'Change,conv % p.a.') = eps;


 set monthGrowthCrops(crops,sys,m) "Crosssets linking crops to month when the crop is growing"/
                                             (potatoes.conv).(APR,MAY,JUN,JUL,AUG)
                                             (WinterWheat.conv).(JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,OCT,NOV,DEC)
                                             (WinterBarley.conv).(JAN,FEB,MAR,APR,MAY,JUN,JUL,OCT,NOV,DEC)
                                             (WinterRye.conv).(JAN,FEB,MAR,APR,MAY,JUN,JUL,OCT,NOV,DEC)
                                             (SummerBeans.conv).(MAR,APR,MAY,JUN,JUL,AUG)
                                             (SummerPeas.conv).(FEB,MAR,APR,MAY,JUN,JUL)
                                             (SummerTriticale.conv).(MAR,APR,MAY,JUN,JUL)
                                             (SummerCere.conv).(MAR,APR,MAY,JUN,JUL)
                                             (winterRape.conv).(JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC)
                                             (Sugarbeet.conv).(MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT)
                                             (maizCorn.conv).(APR,MAY,JUN,JUL,AUG,SEP,OCT)
                                             (maizCCM.conv).(APR,MAY,JUN,JUL,AUG,SEP,OCT)
                                             (maizSil.conv).(APR,MAY,JUN,JUL,AUG,SEP)
                                             (WheatGPS.conv).(JAN,FEB,MAR,APR,MAY,JUL,AUG,OCT,NOV,DEC)
                                     /;

*
* --- Post harvest loss of roughages
*

parameter p_storageLoss(*);
   p_storageLoss(crops) = 1;
   p_storageLoss("wheatGPS")     =  0.88 ;
   p_storageLoss("maizSil")      =  0.88 ;
   p_storageLoss("earlyGrasSil") =  0.9  ;
   p_storageLoss("middleGrasSil")=  0.9  ;
   p_storageLoss("lateGrasSil")  =  0.9  ;
   p_storageLoss("earlyGraz")    =  1    ;
   p_storageLoss("middleGraz")   =  1    ;
   p_storageLoss("lateGraz")     =  1    ;
   p_storageLoss("hay")          =  0.7  ;
   p_storageLoss("hayM")          =  0.7  ;
   p_storageLoss("grasM")          =  0.7  ;

* --- p_nutContent has to be given as an output file [TODO]

* ---- N content of crops in kg N/dt fresh matter according to GRUD 2017, Anhang 1
* ---- N content of maizCCM according to LWK NRW
* ---- P content of crops in kg P/dt fresh matter according to GRUD 2017, Anhang 1
* ---- N and P removal via product and crop residues (Nebenernteprodukt) is calculated as HF + HNV * NF (D�V 2006, Anlage 1)
* ---- Assumption: crop residues are taken away from the field  (except of potatoes, rape, beets, beans, peas, maizCorn,MaizCCM)
parameter p_nutContent(crops,*,sys,*);

   p_nutContent("winterWheat","winterWheat",sys,"N")    =  2.02;
   p_nutContent("winterBarley","winterBarley",sys,"N")  =  1.48;
   p_nutContent("winterRye","winterRye",sys,"N")        =  1.65;
   p_nutContent("winterRape","winterRape",sys,"N")      =  2.61;
   p_nutContent("summerCere","summerCere",sys,"N")      =  2.02;
   p_nutContent("summerTriticale","summerTriticale",sys,"N")    =  1.79;
   p_nutContent("potatoes","potatoes",sys,"N")          =  0.3;
   p_nutContent("maizCorn","maizCorn",sys,"N")          =  1.30;
   p_nutContent("maizCCM","maizCCM",sys,"N")            =  1.05;
   p_nutContent("sugarbeet","sugarbeet",sys,"N")        =  0.12;
   p_nutContent("summerbeans","summerbeans",sys,"N")    =  4.00;
   p_nutContent("summerpeas","summerpeas",sys,"N")      =  3.5;
*  --- output defined in freshweight
   p_nutContent("Alfalfa","alfalfa",sys,"N")            =  3.59;
   p_nutContent("wheatGPS","wheatGPS",sys,"N")          =  0.56;
   p_nutContent("MaizSil","MaizSil",sys,"N")                =  1.18;
* --- Nut content of removed residues, possible for cereal production
   p_nutContent("winterWheat","WCresidues",sys,"N")     =  0.5 ;
   p_nutContent("winterBarley","WBresidues",sys,"N")    =  0.5 ;
   p_nutContent("winterRye","WRresidues",sys,"N")       =  0.5 ;
   p_nutContent("summerCere","SCresidues",sys,"N")      =  0.5 ;
   p_nutContent("summerTriticale","STresidues",sys,"N") =  0.5 ;
   p_nutContent("MaizSil","MaizSil",sys,"N")            = 0.38;


* --- P content is taken from GRUD 2017; content in kg P2O5/dt FS
   p_nutContent("winterWheat","winterWheat",sys,"P")         =  0.82;
   p_nutContent("winterBarley","winterBarley",sys,"P")       =  0.84;
   p_nutContent("winterRye","winterRye",sys,"P")             =  0.80;
   p_nutContent("winterRape","winterRape",sys,"P")           =  1.46;
   p_nutContent("summerCere","summerCere",sys,"P")           =  0.82;
   p_nutContent("summerTriticale","summerTriticale",sys,"P") =  0.80;
   p_nutContent("potatoes","potatoes",sys,"P")               =  0.13;
   p_nutContent("maizCorn","maizCorn",sys,"P")               =  0.59;
   p_nutContent("maizCCM","maizCCM",sys,"P")                 =  0.53;
   p_nutContent("sugarbeet","sugarbeet",sys,"P")             =  0.07;
   p_nutContent("summerbeans","summerbeans",sys,"P")         =  1.20;
   p_nutContent("summerpeas","summerpeas",sys,"P")           =  1.10;
*  --- output defined in freshweight
   p_nutContent("Alfalfa","alfalfa",sys,"P")                 =  0.77/3;
   p_nutContent("wheatGPS","wheatGPS",sys,"P")               =  0.24;
   p_nutContent("MaizSil","MaizSil",sys,"P")                 = 0.48;


* --- Organic Yield Multiplicator

   parameter p_organicYieldMult(crops) /
      (set.cere)   0.5
       maizCorn    0.6
       winterRape  0.6
       summerBeans 1.0
       summerPeas  1.0
       alfalfa     1.0
       potatoes    0.6
       sugarBeet   0.8
       maizSil     0.6
*       (set.grassCrops) 0.50
    /;





* --- Crop residue sets

set cropsResidues_prods/
       WCresidues,
       SCresidues,
       WBresidues,
       STresidues,
       WRresidues
    /;


set crop_residues(cropsResidues_prods,crops) /
       WCresidues.winterWheat,
       SCresidues.summercere,
       wbresidues.winterbarley,
       stresidues.summertriticale,
       WRresidues.winterRye/;


 set cropsResidueRemo(crops) "Crops which generally allow the removal of residues"   /
              WinterWheat
              WinterRye
              SummerCere,
              SummerTriticale,
              Winterbarley
       /;



* --- N fixation from legumes, enters nutrient balance and fertilizer planning according to FO 17
*     Value taken from FO 17, p. 29 assuming legume share in grassland of 5 to 10%
* --- Value is assumed and taken from old crops_de.gms

parameter p_NfromLegumes(crops,sys);

   p_NfromLegumes(leg,sys) = 50;


parameter p_maxRotshare(crops,sys,soil);

*
*  --- [TODO-DS] Maximal rotational share has to be checked in gdx if values are correct
*
   p_maxRotShare("winterWheat","conv",soil)     = 2/3;
   p_maxRotShare("winterBarley","conv",soil)    = 2/3;
   p_maxRotShare("winterRye","conv",soil)       = 2/3;
   p_maxRotShare("winterWheat","conv","h")      = 4/5;
   p_maxRotShare("winterRape","conv",soil)      = 1/3;
   p_maxRotShare("summerCere","conv",soil)      = 1/3;
   p_maxRotShare("summerCere","conv","h")       = 1/2;
   p_maxRotShare("summerTriticale","conv",soil) = 1/3;
   p_maxRotShare("summerTriticale","conv","h")  = 1/2;
   p_maxRotShare("potatoes","conv",soil)        = 1/3;
   p_maxRotShare("sugarbeet","conv",soil)       = 1/3;
   p_maxRotShare("summerbeans","conv",soil)     = 1/3;
   p_maxRotShare("summerpeas","conv",soil)      = 1/3;
   p_maxRotShare("alfalfa","conv",soil)          = 1/3;
   p_maxRotShare("wheatGPS","conv",soil)        = 1/3;

   p_maxRotShare("MaizSil","conv",soil)        = 1;
   p_maxRotShare("MaizCorn","conv",soil)       = 1;
   p_maxRotShare("MaizCCM","conv",soil)        = 1;


$ontext
   $$setglobal a
   $$setglobal m
   $$setglobal v


   $$setglobal  normal (normal,f90p,f80p,f70p)
   $$setglobal  midLow (f60p                 )
   $$setglobal  empty "                     "
   $$setglobal v *
$offtext
*
*  --- the %a% defaults to an empty string, while the %m%/%v% are either empty (= entry read) or a * to comment them out when not needed
*

set intens /empty, normal, midlow, verylow/;
   table p_costQuant(crops,till,intens,inputs)
*                         %empty%       Eu/ha   kg        kg      t    EU/ha  EU/ha   EU/ha       EU/ha      mEU    1000EU     kg
                                        seed   KAS   PK_18_10   Lime   Herb   Fung   Insect   growthContr   water   hailIns    KaliMag

winterWheat.org        .normal           155                     40.7                                              1.73
winterWheat.plough     .normal           60.0  640        400    40.7    65     160   13.00             2     1.2    3.5
winterWheat.plough     .midLow                 640        360    40.7    57.9   28.1  13.00             2     1.2    0.79
winterWheat.plough     .veryLow                640        320    40.7    28.9   28.1  13.00             2     1.2    0.62

winterWheat.minTill    .normal           60.0  640        400    40.7    63.5   134.1 13.00             2     1.2    0.87
winterWheat.minTill    .midLow                 640        360    40.7    57.9   28.1  13.00             2     1.2    0.79
winterWheat.minTill    .veryLow                640        320    40.7    28.9   28.1  13.00             2     1.2    0.62

winterWheat.noTill     .normal           60.0  640        400    40.7    79.4   186   13.00             2     1.5    0.87
winterWheat.noTill     .midLow                 640        360    40.7    83.3   28.1  13.00             2     1.5    0.79
winterWheat.noTill     .veryLow                640        320    40.7    43.3   28.1  13.00             2     1.5    0.62

winterBarley.org       .normal           110.6                   40.7                                                1.27
winterBarley.plough    .normal           60.0  640        400    40.7    65     160   13.00             2     1.2    1.17
winterBarley.plough    .midLow                 640        360    40.7    57.9   28.1  13.00             2     1.2    0.79
winterBarley.plough    .veryLow                640        320    40.7    28.9   28.1  13.00             2     1.2    0.62

winterBarley.minTill   .normal           60.0  640        400    40.7    63.5   134.1 13.00             2     1.2    0.87
winterBarley.minTill   .midLow                 640        360    40.7    57.9   28.1  13.00             2     1.2    0.79
winterBarley.minTill   .veryLow                640        320    40.7    28.9   28.1  13.00             2     1.2    0.62

winterBarley.noTill    .normal           60.0  640        400    40.7    79.4   186   13.00             2     1.5    0.87
winterBarley.noTill    .midLow                 640        360    40.7    83.8   28.1  13.00             2     1.5    0.79
winterBarley.noTill    .veryLow                640        320    40.7    43.3   28.1  13.00             2     1.5    0.62
**** ---- No WinterRye data for Swiss
winterRye   .org       .normal           96                      40.7                                                1.42
winterRye   .plough    .normal           68.4  440        400    40.7    58     70      1              35     0.9    1.1
winterRye   .plough    .midLow           63.6  320        300    40.7    48     51                     17     0.6    0.83
winterRye   .plough    .veryLow                220        220    40.7    43     37                     12     0.6    0.55

winterRye   .minTill   .normal           63.6  440        400    40.7    58     70      1              35     0.9    1.1
winterRye   .minTill   .midLow                 320        300    40.7    48     51                     17     0.6    0.83
winterRye   .minTill   .veryLow                220        220    40.7    43     37                     12     0.6    0.55

winterRye   .noTill    .normal           63.6  440        400    40.7    58     70       1              35    1.2    0.79
winterRye   .noTill    .midLow                 320        300    40.7    58     52                      17    0.9    0.83
winterRye   .noTill    .veryLow                220        220    40.7    58     37                      12    0.9    0.55

*                                           EU/ha   kg        kg      t     EU/ha  EU/ha   EU/ha          EU/ha      mEU      1000EU     kg
*                       %empty%             seed   KAS   PK_18_10   Lime   Herb   Fung   Insect   growthContr   water   hailIns    KaliMag

summerCere.org        .normal            128.8                   40.7                                                1.21
summerCere.plough     .normal            67.2  310        320    40.7    65     160     1               3     0.6    0.98
summerCere.plough     .midLow                  310        290    40.7    26     24                            0.6    0.55
summerCere.plough     .veryLow                 310        250    40.7    13     12                            0.6    0.49

summerCere.minTill    .normal            67.2  310        320    40.7    65     160     1               3     0.6    0.98
summerCere.minTill    .midLow                  310        290    40.7    26     24                            0.6    0.55
summerCere.minTill    .veryLow                 310        250    40.7    13     12                            0.6    0.49

summerCere.noTill     .normal            67.2  310        320    40.7    79.6   232     1               3     0.6    0.98
summerCere.noTill     .midLow                  310        290    40.7    30     33                            0.6    0.55
summerCere.noTill     .veryLow                 310        250    40.7    12     13                            0.6    0.49
* ------ No Summertriticale data for Swiss
summerTriticale.org   .normal            174                     40.7                                                1.14
summerTriticale.plough.normal             84   350        320    40.7    36     89      2               8     0.6    1.24
summerTriticale.plough.midLow             73   310        320    40.7    36     65      1               1     0.6    1.07
summerTriticale.plough.veryLow            73   200        200    40.7    33     48                            0.6    0.71

summerTriticale.minTill.normal            84   350        320    40.7    45     89      2               8     0.6    1.24
summerTriticale.minTill.midLow            73   310        320    40.7    36     65      1               1     0.9    1.07
summerTriticale.minTill.veryLow           73   200        200    40.7    32     48                            0.6    0.71

summerTriticale.noTill .normal            84   350        320    40.7    45     89      2               8     0.9    1.24
summerTriticale.noTill .midLow            73   310        320    40.7    45     89      1               1     0.9    1.07
summerTriticale.noTill .veryLow           73   200        200    40.7    45     89                            0.9    0.71

winterRape.org        .normal            84.2                    40.7                                                1.72
winterRape.plough     .normal            72.6  440        360    40.7    145    50    42.00            28     0.9    0.99
winterRape.plough     .midLow                  440        320    40.7    40     15    16.00                   0.9    2.16
winterRape.plough     .veryLow                 440        280    40.7    20     10    16.00                   0.9    1.94

winterRape.minTill    .normal            72.6  440        360    40.7    145    50    42.00            28     0.9    0.99
winterRape.minTill    .midLow                  440        320    40.7    40     15    16.00                   0.9    2.16
winterRape.minTill    .veryLow                 440        280    40.7    20     10    16.00                   0.9    1.94

winterRape.noTill     .normal            72.6  440        360    40.7    176.9  92    42.00            28     1.2    0.99
winterRape.noTill     .midLow                  440        320    40.7    40     18    16.00                   1.2    2.16
winterRape.noTill     .veryLow                 440        280    40.7    20     12    16.00                   1.2    1.94

potatoes.org          .normal          2625                      40.7          168    60.00                   1800   15
potatoes.plough       .normal          1171.6  580        400    40.7    108    336   31.00                   2.4    6.75       660
potatoes.plough       .midLow
potatoes.plough       .veryLow

potatoes.minTill      .normal          1171.6  580        400    40.7    108    336   31.00                   2.4    6.75       660
potatoes.minTill      .midLow
potatoes.minTill      .veryLow

potatoes.noTill       .normal
potatoes.noTill       .midLow
potatoes.noTill       .veryLow

maizsil.org          .normal            290                      40.7
maizsil.plough       .normal            195.8  400         500   1       95                                   0.6
maizsil.plough       .midLow
maizsil.plough       .veryLow

maizsil.minTill      .normal            195.8  400         500   1       95                                   0.6
maizsil.minTill      .midLow
maizsil.minTill      .veryLow

maizsil.noTill       .normal
maizsil.noTill       .midLow
maizsil.noTill       .veryLow

maizcorn.org          .normal           264                      40.7                                                 2.03
maizcorn.plough       .normal           184    240         80     1       95                                  0.6     1.49
maizcorn.plough       .midLow
maizcorn.plough       .veryLow

maizcorn.minTill      .normal           184    240         80     1       95                                  0.6     1.49
maizcorn.minTill      .midLow
maizcorn.minTill      .veryLow

maizcorn.noTill       .normal
maizcorn.noTill       .midLow
maizcorn.noTill       .veryLow

maizCCM.plough       .normal            184    240         80     1       95                                  0.6     1.1
maizCCM.plough       .midLow
maizCCM.plough       .veryLow

maizCCM.minTill      .normal            184    240         80     1       95                                  0.6     1.1
maizCCM.minTill      .midLow
maizCCM.minTill      .veryLow

maizCCM.noTill       .normal
maizCCM.noTill       .midLow
maizCCM.noTill       .veryLow

sugarbeet.org          .normal           283                     40.7                                                  5.25
sugarbeet.plough       .normal           203   400         600      1     375    250    20                      0.9     2.22
sugarbeet.plough       .midLow
sugarbeet.plough       .veryLow

sugarbeet.minTill      .normal           203   400         600      1     375    250    20                   0.9     2.22
sugarbeet.minTill      .midLow
sugarbeet.minTill      .veryLow

sugarbeet.noTill       .normal
sugarbeet.noTill       .midLow
sugarbeet.noTill       .veryLow

summerbeans.org          .normal         227                     40.7                                                   1.6
summerbeans.plough       .normal          97               360      1     104    3      45                    0.6      0.54
summerbeans.plough       .midLow
summerbeans.plough       .veryLow

summerbeans.minTill      .normal          97               360      1     104    3      45                    0.6      0.54
summerbeans.minTill      .midLow
summerbeans.minTill      .veryLow

summerbeans.noTill       .normal          97               360      1     104    3      45                 0.6      0.54
summerbeans.noTill       .midLow
summerbeans.noTill       .veryLow

summerpeas.org          .normal           281                    40.7                                                  1.37
summerpeas.plough       .normal           92               300     1       104          45                    0.6      0.53
summerpeas.plough       .midLow
summerpeas.plough       .veryLow

summerpeas.minTill      .normal           92               300     1     104          45                    0.6      0.53
summerpeas.minTill      .midLow
summerpeas.minTill      .veryLow

summerpeas.noTill       .normal           92               300     1     104          45                    0.6      0.53
summerpeas.noTill       .midLow
summerpeas.noTill       .veryLow

alfalfa.org             .normal           97                     40.7
alfalfa.plough          .normal           41               300   0.25    41                                            0.53
alfalfa.plough          .midLow           41               300   0.25    41                                            0.53
alfalfa.plough          .veryLow          41               300   0.25    41                                            0.53

alfalfa.minTill       .normal             41               300   0.25    41                                            0.53
alfalfa.minTill       .midLow             41               300   0.25    41                                            0.53
alfalfa.minTill       .veryLow            41               300   0.25    41                                            0.53

wheatGPS.org          .normal            126                     40.7
wheatGPS.plough       .normal             60   720         700      1    45     53                            0.6
wheatGPS.plough       .midLow
wheatGPS.plough       .veryLow

wheatGPS.minTill      .normal             60   720         700      1    45     53                            0.6
wheatGPS.minTill      .midLow
wheatGPS.minTill      .veryLow

wheatGPS.noTill       .normal             60   720         700      1    56     53                            0.9
wheatGPS.noTill       .midLow
wheatGPS.noTill       .veryLow
;

*    --- (2) Heyn, Olfgs - Definition of different crop intensities
*

*    --- Calculating different crop intensities based on date in Fruchtfolge (Pahmeyer) which was derived from Heyn, J., Olfs, H.-W., 2018. Wirkungen reduzierter
*        N-Düngung auf Produktivität, Bodenfruchtbarkeit und N-Austragsgefährdung - Beurteilung anhand mehrjähriger Feldversuche,
*        VDLUFA-Schriftenreihe. VDLUFA-Verlag, Darmstadt.

*    --- Corresponding regression function: ax^2+bx + c

       set value /a,b,c/;

       set nodata_crops(crops) /    Summerpeas,Summerbeans, WheatGPS, MaizSil,Alfalfa /;
       table p_NrespFunct(crops,value)

                                     a                  b                 c
       WinterWheat             -0.003768594         0.933464905      45.46525176
       WinterBarley            -0.004057113         0.934904995      45.91033064
       WinterRye               -0.004057113         0.934904995      45.91033064
       SummerCere              -0.004057113         0.934904995      45.91033064
       SummerTriticale         -0.004057113         0.934904995      45.91033064
       WinterRape              -0.002239363         0.729674451      50.79738128
       MaizCorn                -0.003169961         0.653536469      67.02084733
       MaizCCM                 -0.003169961         0.653536469      67.02084733
       Sugarbeet               -0.002024548         0.438812504      75.45452825
       Potatoes                -0.000540731         0.365467474      66.03934992
       set.nodata_crops        -0.004207087         0.898120957      52.81497477
        ;



*
* --- Definition of nutrients provided from the soil required for Fertilization = Default
*


* --- Nutrient provided from N mineralization in spring based on LWK NRW [updated 2/2021] - remaining data in crops_de.gms

parameter p_nMin(crops)/

          Winterwheat    44,
          wheatGPS       44,
          WinterBarley   24,
          WinterRye      31,
          WinterRape     24,
          maizCorn       51,
          sugarBeet      52,
          maizSil        51,
          maizCCM        51,
          potatoes       52/;




*
*   --- Definition of residue removal for different crops
*       Main product - resiude relation multiplied with yield, factor based on Fertilzation Ordinance 2017, p. 31f.





parameter p_residue_ratio(cropsResidues_prods)/

          WCResidues 0.8,
          SCresidues 0.8,
          WBresidues 0.7,
          STresidues 0.8,
          WRresidues 0.7/;

**********************************************************************************
*
*
*  - \dat\emissions_de:
*
*
*
**********************************************************************************

*  ---  Leaching factor for fertilization from Richner (2014) p.20
  table p_EfLeachFert(m,crops)
               WinterWheat  SummerCere  WinterRape   MaizSil  WinterBarley  Potatoes  Sugarbeet  MaizCorn  MaizCCM  Summerpeas  Summerbeans  WheatGPS
      JAN         0.5          1         0.2           1         0.5           1         1         1         1         1           1           0.5
      FEB         0.3          0.5       0.1           1         0.3           1         1         1         1         1           1           0.3
      MAR         0.1          0.3       0             1         0.1           0.5       0.5       1         1         0.5         0.5         0.1
      APR         0            0.1       0             0.8       0             0.3       0.3       0.8       0.8       0.3         0.3         0
      MAY         0            0         0             0.7       0             0         0         0.7       0.7       0           0           0
      JUN         0            0         0             0         0             0         0         0         0         0           0           0
      JUL         1            0         1             0         1             0         0         0         0         0           0           1
      AUG         1            1         0.8           0         1             0         0         0         0         1           1           1
      SEP         1            1         0             0         1             0         0         0         0         1           1           1
      OCT         1            1         0             0         1             1         1         0         0         1           1           1
      NOV         1            1         0.2           1         1             1         1         1         1         1           1           1
      DEC         1            1         0.2           1         1             1         1         1         1         1           1           1
;

* --- Correction of Mineralisation of Legumes, 6 month after Legumes (only for month where mneralisation appears)
*     [TODO] Ask Julia about values

parameter p_monthAfterLeg(leg,m);
          p_monthAfterLeg(leg,m) = 1;



*  ---  Humus degradation through crop cultivation LFL Exceltool nach VDLUFA (2014)

parameter p_humCrop(crops)
        /WinterWheat               400
         SummerCere                400
         WinterRape                400
         MaizSil                   800
         WinterBarley              400
         Potatoes                 1000
         Sugarbeet                1300
         MaizCorn                  800
         MaizCCM                   800
         Summerpeas               -160
         Summerbeans              -160
         WheatGPS                  400
        /;




*  ---  Effect of crop residues on humus LFL Exceltool nach VDLUFA (2014)
* https://www.lfl.bayern.de/mam/cms07/iab/dateien/humusbilanz_59_fruchtfolge_10_2015.xls

   parameter p_resiInc(crops)
       /WinterWheat                  7
        SummerCere                   7
        WinterRape                   7
        WinterBarley                 7
        Sugarbeet                    1.3
        MaizCorn                     7
        MaizCCM                      7
       /;
*  --- Table of input data for calculation of N2O emissions from crop residues
*       assumption maizcorn is same as CCM wheatccm is wheat DÜNGEVERORDNUNG(2007, Anlage 1, Tabelle 1), IPCC(2006)-11.17


  set resiEle "elements for calculation of emissions from crop residues"

/
                                           duration  "Duration of cropped system"
                                           freqHarv  "frequency of harvesting"
                                           DMyield   "Dry matter content of yield"
                                           DMresi    "Dry matter content of  above ground residues"
                                           aboveRat  "Ratio of above ground crop residues to yield"
                                           aboveN    "Nitrogen content of the above-ground crop residues"
                                           belowRat  "Ratio of below ground crop residues to above ground biomass"
                                           belowN    "Nitrogen content of below ground crop residues"
                                          /;


   Table p_cropResi(crops,resiEle)
*                     ha/ha                 kg/kg              kg/kg   kg/(kg FM)  kg/kg    kg (kg DM)-1
                     duration   freqHarv   DMyield   DMresi   aboveRat   aboveN   belowRat   belowN
   winterwheat          1          1          0.86     0.86      0.8      0.005     0.23      0.009
   summercere           1          1          0.86     0.86      0.8      0.005     0.28      0.009
   WheatGPS             1          1          0.86     0.86      0.8      0.005     0.23      0.009
   WinterBarley         1          1          0.86     0.86      0.7      0.005     0.22      0.014
   MaizCorn             1          1          0.86     0.86      1        0.009     0.22      0.007
   MaizCCM              1          1          0.86     0.86      1        0.009     0.22      0.007
   MaizSil              1          1          0.28     0.28      0        0.0038    0.22      0.007
   WinterRape           1          1          0.91     0.86      1.7      0.007     0.22      0.01
   Sugarbeet            1          1          0.23     0.18      0.7      0.004     0.2       0.014
   Potatoes             1          1          0.22     0.15      0.2      0.002     0.2       0.014
   Summerbeans          1          1          0.86     0.86      1        0.015     0.4       0.022
   Summerpeas           1          1          0.86     0.86      1        0.015     0.4       0.022
*   triticale           1          1          0.86     0.86      0.9      0.005     0.22      0.009
*   clover              0.33       0.33       0.2      0.2       0.3      0.0052    0.8       0.016
    alfalfa             1          1          0.2      0.2       0.3      0.006     0.4       0.019
;



* ---- Calculation of cereal units (Getreideeinheitenschlüssel) based on
*      https://www.bmel-statistik.de/fileadmin/daten/SJT-3120100-2011.xlsx
*
*      For now: onyl arable crops
*      No data found for MaizCCM, therefore selected "sonstige Hauptfutterfrüchte"
*      No data found for catchCrops (with fodderUse), therefore selected: "Zwischenfrucht Raps"
*                        silage -> GPS / silage maize selected
*      No data found for grassland / clover grass

parameter p_cerealUnit(*);

     p_cerealUnit("WinterWheat")  = 1.07 ;
     p_cerealUnit("WinterBarley") = 1.00 ;
     p_cerealUnit("SummerCere")   = 1.00 ;
     p_cerealUnit("WinterRape")   = 2.46 ;
     p_cerealUnit("Potatoes")     = 0.22 ;
     p_cerealUnit("Sugarbeet")    = 0.27 ;
     p_cerealUnit("MaizCorn")     = 1.10 ;
     p_cerealUnit("MaizCCM")      = 0.60 ;
     p_cerealUnit("Summerpeas")   = 1.04 ;
     p_cerealUnit("Summerbeans")  = 0.86 ;
     p_cerealUnit("WheatGPS")     = 0.60 ;
     p_cerealUnit("MaizSil")      = 0.18 ;
     p_cerealUnit("WCresidues")   = 0.10 ;
     p_cerealUnit("WBresidues")   = 0.10 ;
     p_cerealUnit("SCresidues")   = 0.10 ;

* --- In p_costQuant most of the inputs are given in monetary rather than quantity units. In order to be able to link
*     them to emissions provide quantity estimates based on different sources:
*     (1) Data on Herb/Fung/Insect quantities for WW,WB,SB,POTA are taken by Kuhn et al. (2022) - Green release paper
*     (2) Data for SC,ST,WR,WGPS are adapted based on the data for WW and WB
*     (3) Data for all other crops is not yet available

Table p_inputQuant(crops,till,intens,inputs,*)

                                  seed.""           Lime.""       Herb.""     Fung.""   Insect.""      growthContr.""     water.""
*                                 kg/ha             t/ha          l/ha        l/ha       l/ha             kg/ha           m3/ha

Winterwheat    .plough.normal      120               1            1.63        5.45                        1.45
SummerCere     .plough.normal      100               1            1.63        5.45                        1.45
SummerTriticale.plough.normal      100               1            1.63        5.45                        1.45

WinterBarley   .plough.normal      100               1            0.525       3.25       0.075             0.9
WinterRye      .plough.normal      120               1            0.525       3.25       0.075             0.9
WheatGPS       .plough.normal      120               1            0.525       3.25       0.075             0.9

WinterRape     .plough.normal       6                1

Potatoes       .plough.normal     2500               1             5.4       10.25       0.31
Sugarbeet      .plough.normal      8                 1             4.84        1          1.3

MaizCorn       .plough.normal      24                1
MaizCCM        .plough.normal      24                1
MaizSil        .plough.normal      28                1

Summerpeas     .plough.normal      100               1
Summerbeans    .plough.normal      100               1

Alfalfa        .plough.normal                        1
;


**********************************************************************************
*
*
*  - \dat\feeds_de:
*
*
*
**********************************************************************************

* --- Feed crops


set feed(crops) /
                          winterWheat     "Winter wheat"
                          winterBarley    "Winter barley"
                          winterRye       "Winter rye"
                          summerTriticale "Summer triticale"

                          summerBeans    "Ackerbohnen"
                          summerPeas     "Futtererbsen"
                          Alfalfa
              /;

set       roughages(crops) /
                maizSil
                wheatGPS
                 /;

set       feeds(crops) /
                set.feed
                set.roughages
                 /;

set feedAttr /
        DM
        XF
        aNDF
        ADF
        XP
        nXP
        UDP
        RNB
        NEL
        ME
        XS+XZ
        bSX
        XL
        Ca
        P
        Mg
        Na
        K
        energ
        crudeP
        Lysin
        phosphFeed
        mass
    /;


*
*       --- Nutrient and energy content in different feeds expressed in g / kg of fresh matter (FM)
*           according to Gruber Futterwerttabellen Wiederkäuer 2014
*           https://www.lfl.bayern.de/mam/cms07/publikationen/daten/informationen/gruber_tabelle_fuetterung_milchkuehe_zuchtrinder_schafe_ziegen_lfl-information.pdf
*
*       DM = Dry matter / Trockenmasse
*       XP = Raw protein / Rohprotein
*       nXP = Usable raw protein / nutzbares Rohprotein
*       RNB = Ruminal nitrogen balance / Ruminale N-Bilanz
*       XF = Raw fibre / Rohfaser
*       NEL = Net energy for lactation / Netto-Energie-Laktation
*       ME = Metabolisable Energy / Umsetzbare Energie
*       CA = Calcium
*       P = Phosphate
*       milkPowder  = Gruber Code 8015
*       concCattle1 = Gruber Code 8104
*       concCattle2 = Gruber Code 8126
*       concCattle3 = Gruber Code 8147
*       CCclover = Gruber code 1815

        table p_feedContDMg(feeds,feedAttr)

*                   in 1000g FM   |                                 in 1000g DM
*                            g    | g     g      g    g     g    %     g      MJ     MJ    g      g     g    g     g    g    g    g
                             DM     XF   aNDF   ADF   XP   nXP   UDP   RNB    NEL    ME     XS+XZ  bSX   XL   Ca    P    Mg   Na   K
          maizSil            350    195  485    250   82   134   25     -8    6.69   11.04  305    44    33   2.0   2.2  1.3  0.3  11
          winterWheat        880     30              137   170   20     -5    8.53   13.40  707    68    20   0.7   3.8  1.3  0.3   5
          wheatGPS           400    245  490    285   98   117   15     -3    5.46    9.32  220    20    23   2.0   2.5  1.0  0.3  12
          winterBarley       880     52              125   164   25     -6    8.14   12.91  626    60    23   0.7   4.0  1.3  0.3   5
          winterRye          880     23              105   161   15     -9    8.49   13.30  708    65    18   0.9   3.3  1.4  0.3   6
          summerTriticale    880     25              105   162   15     -7    8.37   13.17  707    67    18   0.5   3.9  1.3  0.3   6
          summerBeans        880     90              295   194   15     16    8.58   13.57  451   103    16   1.6   4.8  1.4  0.2  12
          summerPeas         880     65              235   183   15      8    8.52   13.44  539   119    15   0.9   4.8  1.3  0.2  11
          Alfalfa            890    225  490    285  185   162   40      4    5.46    9.27   75     0    29  18.0   3.5  2.8  0.5  24
;

set feedsPig(crops) /
        WinterWheat,Summertriticale,SummerCere,MaizCCM,Winterbarley,WinterRye/;


      Table p_feedAttrPig(feedsPig,feedAttr) "feed attributes of pig feed in GJ/t(energ) and kg/t (crudeP,Lysin,phosphFeed) and t/t (mass)"
*
*     ---- feeding attributes for feed products for pigs
*          Sources feeds except miFu: KTBL Betriebsplanung 16/16 p. 479 ff.
*          Sources minFu Stalljohann (2017): Futter: So drehen Sie an der N�hrstoffschraube, in top agra (Hrsg.) (2017): Ratgeber Neue D�ngeverordnung, M�nster, p. 18 - 21.
*          Assumption that plant fat has same attributes like soybeanoil
*
*         MinFu  [%] 19 Ca, 3 P, 8 Lys, 1 Met, 3 Thr)
*         MinFu2 [%] 20 Ca, 3 P, 8 Lys, 0 Met, 1.5 Thr)
*         MinFu3 [%] 16 Ca, 2 P, 10 Lys, 2 Met, 4 Thr)
*         MinFu4 [%] 18 Ca, 1.5 P, 10 Lys, 0 Met, 3 Thr)


                          energ           crudeP            Lysin          phosphFeed        mass
*      --- Cereal contents

        WinterWheat       13.8             121               3.4               3.3          - 1
        SummerTriticale   13.8             115               3.8               3.3          - 1
        SummerCere        13.8             115               3.8               3.3          - 1
        MaizCCM           8.94              63               1.7               1.9          - 1
        Winterbarley      12.6             109               3.8               3.4          - 1
        WinterRye         12.6             109               3.8               3.4          - 1
       ;



**********************************************************************************
*
*
*  - \dat\fertOrd_Duev2007_de - \dat\fertOrd_Duev2017_de - \dat\fertOrd_Duev2020_de
*
*
*
**********************************************************************************

*---- Table with nutrient content of crops_as_inputs?


  Table  p_nutCont(*,*)
                           N          P
       WinterWheat       18.1        8.0
       WinterRye         16.5        8.0
       Winterbarley      16.5        8.0
       MaizCCM           16.8        6.8
       SummerTriticale   16.5        8.0
       SummerCere        16.5        8.0
  ;

*
* --- (C) RESTRICTION AFTER HARVEST OF MAIN CROPS PREVENT FERTILIZER APPLICATION,
*         FOLLOWING FP 07 AND FO 017 (Enters equation NLimitautumn_ in model/templ.gms
*

 set monthHarvestBlock(crops,m)   "months between harvest and November where fertilizer application is possible"
*                                        harvest month taken from coeffgen/tech.gms,  MaizCorn, MaizCCM no month at all
                                         /   (potatoes,sugarbeet,maizSil,maizCCM).(Sep,Oct)
                                             (WinterWheat,SummerBeans).(Sep,Oct)
                                             (SummerPeas,SummerCere,SummerTriticale,WinterRape).(Aug,Sep,Oct)
                                             (WheatGPS).(Jul,Aug,Sep,Oct)
                                             (winterBarley,WinterRye).(Jul,Aug,Sep,Oct)
                                       /;






**********************************************************************************
*
*
*  - \dat\fertor_ferplan.gms
*
*
*
**********************************************************************************

parameter p_yieldlevel(crops) "Yield level according to DUEV in t/ha" /
            winterWheat        8
            wheatGPS           8
            SummerCere         7
            SummerTriticale    7
            winterBarley       7
            winterRye          7
            winterRape         4
            maizCorn           9
            sugarBeet         65
            maizSil           45
            potatoes          45

/;

parameter p_NNeed(crops) "Per hectare N requirements of crops at given yield level" /
            winterWheat        230
            wheatGPS           230
            SummerCere         180
            SummerTriticale    180
            winterBarley       180
            winterRye          180
            winterRape         200
            maizCorn           200
            sugarBeet          170
            maizSil            200
            maizCCM            200
            potatoes           180
/;


parameter p_addN(crops) "Increased N requirement with rising yields" /
            winterWheat        10
            wheatGPS           10
            SummerCere         10
            SummerTriticale    10
            winterBarley       10
            winterRye          10
            winterRape         15
            maizCorn           10
            sugarBeet           1
            maizSil             2
            maizCCM            eps
            potatoes            2

/;

parameter p_redN(crops) "Reduced N requirements with lower yields" /
            winterWheat        15
            wheatGPS           15
            SummerCere         15
            SummerTriticale    15
            winterBarley       15
            winterRye          15
            winterRape         20
            maizCorn           15
            sugarBeet          1.5
            maizSil            3
            maizCCM            eps
            potatoes           3
/;



**********************************************************************************
*
*
*  - \dat\greening.gms
*
*
*
**********************************************************************************


set cropGroups /

   WinterWheat
   Winterbarley
   WinterRye
   SummerTriticale
   Summercere
   WinterRape
   Idle
   MaizSil
   Potatoes
   Sugarbeet
   Summerpeas
   Summerbeans
   Alfalfa
   Gras
/;


*
* --- link crop groups (relevant for crop diversification)
*     to individual groups
*
table p_cropGroups_to_crops(cropGroups,crops)
                 WinterWheat  SummerCere WinterRape    MaizSil Potatoes  WheatGPS    MaizCCM  MaizCorn
 WinterWheat        1                                                        1
 SummerCere                     1
 WinterRape                                 1
 MaizSil                                                1                               1         1
 Potatoes                                                        1

+                Sugarbeet  Summerpeas Summerbeans Alfalfa Winterbarley  WinterRye   SummerTriticale
 Sugarbeet       1
 Summerpeas                       1
 Summerbeans                                  1
 Alfalfa                                               1
 Winterbarley                                                    1
 WinterRye                                                                   1
 SummerTriticale                                                                            1
;


 parameter p_efa(crops) "Factors for Ecological focus area"
 /
   WinterWheat          0
   SummerCere           0
   SummerTriticale      0
   WinterRape           0
   MaizSil              0
   Potatoes             0
   Sugarbeet            0
   MaizCorn             0
   MaizCCM              0
   Summerpeas           1
   Summerbeans          1
   Alfalfa              1
   Winterbarley         0
   WinterRye            0
   WheatGPS             0

 /;



**********************************************************************************
*
*
*  -   \coeffgen\fermenter_tech.gms
*
*
*
**********************************************************************************

*--- Methane yield of various crops (Source:FNR (2013) "Leitfaden Biogas" page 76, table 4.9)

 parameter    p_crop(biogas_feed)                           "Metahne yield for crops in m3 per ton"
              /
              maizSil   106
              maizCorn  329
              maizCCM   106
              wheatGPS  105
              /;



*--- Dry matter and organic dry matter content (Source: FNR (2013) "Leitfaden Biogas" p. 69ff)

 parameter     p_dryMatterCrop(biogas_feed)                 "dry matter content of crops in percentage"
              /
              maizSil           0.33
              maizCorn          0.87
              maizCCM           0.33
              wheatGPS          0.33
              /;



parameter     p_orgDryMatterCrop(biogas_feed)              "organic dry matter content of crops in percentage of the dry matter content"
              /
              maizSil           0.95
              maizCorn          0.95
              maizCCM           0.95
              wheatGPS          0.95
              /;



*---- Values taken from KTBL (2013) "Faustzahlen Biogas" p.251
parameter     p_fugCrop(biogas_feed)                   "fugatfactor for crops"
              /
              maizSil 0.76
              wheatGPS 0.75
              /;


parameter     p_totNCrop(biogas_feed)                       "total N in crops in kg/t"
              /
              maizSil        4.5
              wheatGPS       4.9
              /;

parameter     p_shareNTAN(biogas_feed)                      "share of NTAN in crops in percent";
              p_shareNTAN("maizSil") = 0.562584;
              p_shareNTAN("wheatGPS") = 0.562584;

**********************************************************************************
*
*
*  -   Generation of inputs
*
*
*
**********************************************************************************




 PARAMETER p_inputPrices "Inputs"/
'Wage rate full time       '.sys     17.5
'Wage rate half time       '.sys     11.5
'Wage rate flexible hourly '.sys     9.0
'MaizSil                   '."conv"  160.00
'GrasSil                   '."conv"  160.00
'ManCatt                   '."conv"  0.001
'ConcCattle1               '."conv"  220.0
'ConcCattle2               '."conv"  230.0
'ConcCattle3               '."conv"  270.0
'milkPowder                '."conv"  2110.0
'OilsForFeed               '."conv"  1150.0
'WinterWheat               '."conv"  530.0
'SummerCere                '."conv"  530.0
'SummerTriticale           '."conv"  530.0
'MaizCCM                   '."conv"  220.0
'WinterBarley              '."conv"  380.0
'WinterRye                 '."conv"  400.0
'SoyBeanMeal               '."conv"  338.0
'SoybeanOil                '."conv"  1150.0
'rapeSeedMeal              '."conv"  220.0
'Alfalfa                   '."conv"  184.0
'PlantFat                  '."conv"  1000.0
'MinFu                     '."conv"  700.0
'MinFu2                    '."conv"  700.0
'MinFu3                    '."conv"  700.0
'MinFu4                    '."conv"  700.0
'feedAdd_Bovaer            '.sys     17500.0
'feedAdd_VegOil            '.sys     500.0
'Diesel                    '.sys     0.7
'ASS                       '.'conv'  0.29
'AHL                       '.'conv'  0.238
'seed                      '.'conv'  1.0
'KAS                       '.'conv'  0.31
'PK_18_10                  '.'conv'  0.236
'dolophos                  '.sys     0.400
'KaliMag                   '.'conv'  0.449
'Lime                      '.sys     1
'Herb                      '.sys     1.0
'Fung                      '.sys     1.0
'Insect                    '.sys     1.0
'growthContr               '.sys     1.0
'water                     '.sys      2.5
'hailIns                   '.sys     9.91
'pigletsBought             '.'conv'  48.2
'ManPig                    '.'conv'  0.01
'youngSow                  '.'conv'  570.0
'straw                     '.'conv'  115.0
'Hay                       '.'conv'  132.0
'YoungCow                  '.'conv'  1775.0
'femaleSexing              '.sys     10
'maleSexing                '.sys     10
'fCalvsRaisBought          '.'conv'  144.0
'mCalvsRaisBought          '.'conv'  144.0
 /;


   p_inputprices(inputs,"conv") $ (p_inputprices(inputs,"sys") $ (not p_inputPrices(inputs,"conv"))) =  p_inputprices(inputs,"sys");
   p_inputprices(inputs,"org")  $ (p_inputprices(inputs,"sys") $ (not p_inputPrices(inputs,"org")))  =  p_inputprices(inputs,"sys");
   p_inputprices(inputs,"sys") =   0;

* --- if organic inputprice does not exist (e.g. ConCattle), use conventional outputprice + 20%
   p_inputprices(inputs,"org")  $ (not p_inputPrices(inputs,"org")) =  p_inputprices(inputs,"conv") * 1.2 ;


*
* --- define growth rate
*
  p_InputPrices(inputs,'Change,conv % p.a.')  $ p_InputPrices(inputs,"conv")   =     eps;
  p_InputPrices(inputs,'Change,org % p.a.')   $ p_InputPrices(inputs,"org")    =     eps;


********************************************************************************
$ontext


   GAMS file : Previously cropop_de.gms


$offtext
********************************************************************************
$onMulti
$onempty

  set cropOpcrops(crops) /  potatoes
                            winterWheat
                            winterBarley
                            WinterRye
                            Summerbeans
                            summerPeas
                            alfalfa
                            summerCere
                            summerTriticale
                            winterRape
                            sugarbeet
                            MaizCorn
                            maizCCM
                            maizSil
                            wheatGPS/;

  set labPeriod "Two-weekly Labour periods as defined by KTBL for field operations"
   /  jan1,jan2,
      feb1,feb2
      mar1,mar2,
      apr1,apr2,
      may1,may2,
      jun1,jun2,
      jul1,jul2,
      aug1,aug2,
      sep1,sep2,
      oct1,oct2,
      nov1,nov2
   /;

  set till/ plough, minTill, noTill, org, silo, bales, hay, hayM, grasM, graz/;


  set lower(intens) //;
  set verylow(intens) //;

  set operation "Field operators as defined by KTBL"

             /
                      soilSample              "Bodenprobe"
                      manDist                 "Guelleausbringung"
                      basFert                 "P und K Duengung, typischerweise Herbst"
                      plow                    "Pfluegen"
                      chiselPlow              "Tiefengrubber"
                      seedBedCombi            "Saatbettkombination"
                      herb                    "Herbizidmassnahme"
                      sowMachine              "Saemaschine"
                      directSowMachine        "Direktsaatmaschine"
                      circHarrowSow           "Kreiselegge u. Drillmaschine Kombination"
                      springTineHarrow        "Federzinkenegge"
                      weedValuation           "Unkrautbonitur"
                      weederLight             "Striegeln"
                      weederIntens            "Hacken"
                      plantvaluation          "Bestandsbonitur"
                      NFert320
                      NFert160
                      combineCere             "Maehdrusch, Getreide"
                      combineRape             "Maehdrusch, Raps"
                      combineMaiz             "Maehdrusch, Mais"
                      cornTransport           "Getreidetransport"
                      store_n_dry_8
                      store_n_dry_4
                      store_n_dry_beans
                      store_n_dry_rape
                      store_n_dry_corn
                      lime_fert               "Kalkung"
                      stubble_shallow         "Stoppelbearbeitung flach"
                      stubble_deep            "Stoppelbearbeitung tief"
                      rotaryHarrow            "Kreiselegge"
                      NminTesting             "Nmin Probenahme"
                      mulcher                 "Mulcher"
                      chitting                "Vorkeimen"
                      solidManDist            "Miststreuer"
                      seedPotatoTransp        "Pflanzkartoffeltransport"
                      potatoLaying            "Legen von Kartoffeln"
                      rakingHoeing            "Hacken, striegeln"
                      earthingUp              "haeufeln"
                      knockOffHaulm           "Kartoffelkraut schlagen"
                      killingHaulm            "Krautabt�ten"
                      potatoHarvest           "Kartoffeln roden"
                      potatoTransport         "Kartoffeln zum Lager transportieren"
                      potatoStoring           "Kartoffeln lagern"
                      singleSeeder            "Einzelkornlegegeraet fuerr Zuckerrueben/Mais"
                      weederHand              "von Hand hacken"
                      uprootBeets             "Zuckerrueben roden"
                      DiAmmonium              "Diammonphosphat streuen"
                      grinding                "KornMahlen"
                      disposal                "Erntegut festfahren"
                      coveringSilo            "Silo reinigen und mit Folie verschliessen, Maiz"
                      chopper                 "Haeckseln"
                      grasReSeeding           "Grasnachsaehen"
                      roller                  "Walzen"
                      mowing                  "Maehen mit Maehaufbereiter"
                      raking                  "Schwaden"
                      tedding                 "Wenden mit Kreiselzettwender"
                      silageTrailer           "Anwelkgut bergen mit Ladewagen"
                      closeSilo               "Silo reinigen und mit Folie verschliessen"
* Hay/Bale specific tasks
                      balePressWrap           "Ballen pressen und wickeln, Silage (Anwelkgut)"
                      baleTransportSil        "Ballentransport Silageballen"
                      baleTransportHay        "Ballentransport Heuballen"
                      balePressHay            "Bodenheu pressen"
                      alfalfaHarvDry          "Contract work needed for Alfalfa"
                   /;

*
*--- taken from KTBL, "Verfahrensuebersicht", e.g. potatoes KTBL 2012/13, p. 418-419
*--- Herbizid, fungizid, insecticide summed up as herb [TK]
*--- not yet in FARMDYN included: hoe, mulcher and cropSprayer;  potatoes need storage and boxes, front bucket for fork lift not included [TK, 24.07.13]
*--- Catch crops are taken from KTBL Homepage, "Kurzscheibenegge" replace bei springTimeHarrow; seeding is moved from JUL1 to AUG2 to prevent overlapping with other crops
*

 table p_crop_op_per_tilla(crops,operation,labPeriod,till)
                                                              plough     minTill   noTill          org  silo  bales  hay      graz

 potatoes     .    soilSample          .  AUG1                   0.2         0.2                   0.2
 potatoes     .    basFert             .  AUG1                   1.0         1.0                   1.0
 potatoes     .    solidManDist        .  AUG2                                                     1.0
 potatoes     .    plow                .  AUG2                                                     1.0
 potatoes     .    chiselPlow          .  AUG2                   1.0         1.0
 potatoes     .    sowmachine          .  AUG2                   1.0         1.0
 potatoes     .    mulcher             .  NOV1                   1.0         1.0                   1.0
 potatoes     .    plow                .  NOV1                   1.0                               1.0
 potatoes     .    chiselPlow          .  NOV1                               1.0
 potatoes     .    NminTesting         .  FEB1                   1.0         1.0
 potatoes     .    NFert320            .  MAR1                   1.0         1.0                   1.0
 potatoes     .    chitting            .  MAR1                                                     1.0
 potatoes     .    seedBedCombi        .  MAR2                   1.0
 potatoes     .    rotaryHarrow        .  MAR2                               1.0                   1.0
 potatoes     .    seedPotatoTransp    .  APR1                   1.0         1.0                   1.0
 potatoes     .    potatoLaying        .  APR1                   1.0         1.0                   1.0
 potatoes     .    rakingHoeing        .  APR2                                                     1.0
 potatoes     .    earthingUp          .  APR2                   1.0         1.0
 potatoes     .    weedValuation       .  MAY1                   1.0         1.0                   1.0
 potatoes     .    earthingUP          .  MAY1
 potatoes     .    plantvaluation      .  JUN1                   1.0                               1.0
 potatoes     .    herb                .  JUN1                                                     1.0
 potatoes     .    plantValuation      .  JUN2                   2.0         2.0                   1.0
 potatoes     .    herb                .  JUN2                   2.0         2.0                   2.0
 potatoes     .    plantValuation      .  JUL1                   2.0         2.0
 potatoes     .    herb                .  JUL1                   2.0         2.0                   1.0
 potatoes     .    plantValuation      .  JUL2                   1.0         1.0
 potatoes     .    herb                .  JUL2                   1.0         1.0                   1.0
 potatoes     .    plantValuation      .  AUG1                   1.0         1.0
 potatoes     .    herb                .  AUG1                   1.0         1.0                   1.0
 potatoes     .    plantValuation      .  AUG2                   1.0         1.0
 potatoes     .    herb                .  AUG2                   1.0         1.0
 potatoes     .    knockOffHaulm       .  AUG2                                                     1.0
 potatoes     .    killingHaulm        .  AUG2                   1.0         1.0
 potatoes     .    potatoHarvest       .  SEP1                   0.5         0.5                   0.5
 potatoes     .    potatoTransport     .  SEP1                   0.5         0.5                   0.5
 potatoes     .    potatoStoring       .  SEP1                   0.5         0.5                   0.5
 potatoes     .    potatoHarvest       .  SEP2                   0.5         0.5                   0.5
 potatoes     .    potatoTransport     .  SEP2                   0.5         0.5                   0.5
 potatoes     .    potatoStoring       .  SEP2                   0.5         0.5                   0.5
 potatoes     .    lime_fert           .  OCT1                 0.333       0.333                 0.333

*                                                             plough     minTill   noTill          org  silo  bales
 winterWheat  .    soilSample          .  SEP1                   0.2         0.2        0.2        0.2
 winterWheat  .    manDist             .  SEP1                                                     1.0
 winterWheat  .    basFert             .  SEP1                   1.0         1.0        1.0
 winterWheat  .    plow                .  SEP2                   1.0                               1.0
 winterWheat  .    chiselPlow          .  SEP2                               1.0
 winterWheat  .    SeedBedCombi        .  OCT1                   1.0                               1.0
 winterWheat  .    herb                .  OCT1                                          1.0
 winterWheat  .    sowMachine          .  OCT2                   1.0                               1.0
 winterWheat  .    directSowMachine    .  OCT2                                          1.0
 winterWheat  .    circHarrowSow       .  OCT2                               1.0
 winterWheat  .    weedValuation       .  OCT2                   1.0         1.0        1.0
 winterWheat  .    herb                .  OCT2                   1.0         1.0        1.0
 winterWheat  .    weederLight         .  OCT2                                                     1.0
 winterWheat  .    plantValuation      .  FEB2                   1.0         1.0        1.0        1.0
 winterWheat  .    NFert320            .  MAR1                   1.0         1.0        1.0
 winterWheat  .    weederLight         .  MAR1                                                     1.0
 winterWheat  .    manDist             .  MAR1                                                     1.0
 winterWheat  .    plantValuation      .  MAR2                   1.0         1.0        1.0
 winterWheat  .    NFert160            .  APR1                   1.0         1.0        1.0
 winterWheat  .    herb                .  APR2                   1.0         1.0        1.0
 winterWheat  .    herb                .  MAY1                   1.0         1.0        1.0
 winterWheat  .    plantValuation      .  MAY1                   1.0         1.0        1.0
 winterWheat  .    NFert160            .  JUN1                   1.0         1.0        1.0
 winterWheat  .    herb                .  JUN1                   1.0         1.0        1.0
 winterWheat  .    combineCere         .  AUG1                   1.0         1.0        1.0        1.0
 winterWheat  .    cornTransport       .  AUG1                   1.0         1.0        1.0        1.0
 winterWheat  .    store_n_dry_8       .  AUG1                   1.0         1.0        1.0
 winterWheat  .    store_n_dry_4       .  AUG1                                                     1.0
 winterWheat  .    lime_fert           .  AUG2                 0.333       0.333      0.333      0.333
 winterWheat  .    stubble_shallow     .  AUG2                   1.0         1.0                   1.0
 winterWheat  .    stubble_deep        .  SEP2                   1.0         1.0                   1.0
*                                                             plough     minTill   noTill          org  silo  bales
 winterBarley .    soilSample          .  SEP1                   0.2         0.2        0.2        0.2
 winterBarley .    manDist             .  SEP1                                                     1.0
 winterBarley .    basFert             .  SEP1                   1.0         1.0        1.0
 winterBarley .    plow                .  SEP2                   1.0                               1.0
 winterBarley .    chiselPlow          .  SEP2                               1.0
 winterBarley .    SeedBedCombi        .  OCT1                   1.0                               1.0
 winterBarley .    herb                .  OCT1                                          1.0
 winterBarley .    sowMachine          .  OCT2                   1.0                               1.0
 winterBarley .    directSowMachine    .  OCT2                                          1.0
 winterBarley .    circHarrowSow       .  OCT2                               1.0
 winterBarley .    weedValuation       .  OCT2                   1.0         1.0        1.0
 winterBarley .    herb                .  OCT2                   1.0         1.0        1.0
 winterBarley .    weederLight         .  OCT2                                                     1.0
 winterBarley .    plantValuation      .  FEB2                   1.0         1.0        1.0        1.0
 winterBarley .    NFert320            .  MAR1                   1.0         1.0        1.0
 winterBarley .    weederLight         .  MAR1                                                     1.0
 winterBarley .    manDist             .  MAR1                                                     1.0
 winterBarley .    plantValuation      .  MAR2                   1.0         1.0        1.0
 winterBarley .    NFert160            .  APR1                   1.0         1.0        1.0
 winterBarley .    herb                .  APR2                   1.0         1.0        1.0
 winterBarley .    herb                .  MAY1                   1.0         1.0        1.0
 winterBarley .    plantValuation      .  MAY1                   1.0         1.0        1.0
 winterBarley .    NFert160            .  JUN1                   1.0         1.0        1.0
 winterBarley .    herb                .  JUN1                   1.0         1.0        1.0
 winterBarley .    combineCere         .  AUG1                   1.0         1.0        1.0        1.0
 winterBarley .    cornTransport       .  AUG1                   1.0         1.0        1.0        1.0
 winterBarley .    store_n_dry_8       .  AUG1                   1.0         1.0        1.0
 winterBarley .    store_n_dry_4       .  AUG1                                                     1.0
 winterBarley .    lime_fert           .  AUG2                 0.333       0.333      0.333      0.333
 winterBarley .    stubble_shallow     .  AUG2                   1.0         1.0                   1.0
 winterBarley .    stubble_deep        .  SEP2                   1.0         1.0                   1.0

*   based on Verfahrensrechner, 02/2021 (Winterroggen, Mahl-und Brotroggen (wendend Gülle))
*                                                             plough     minTill   noTill          org  silo  bales
 winterRye    .    soilSample          .  SEP1                   0.2         0.2        0.2        0.2
 winterRye    .    basFert             .  SEP1                   1.0         1.0        1.0
 winterRye    .    plow                .  SEP2                   1.0                               1.0
 winterRye    .    chiselPlow          .  SEP1                               1.0
 winterRye    .    SeedBedCombi        .  SEP2                   1.0                               1.0
 winterRye    .    herb                .  SEP1                                          1.0
 winterRye    .    sowMachine          .  SEP2                   1.0                               1.0
 winterRye    .    directSowMachine    .  SEP2                                          1.0
 winterRye    .    circHarrowSow       .  SEP2                               1.0
 winterRye    .    weedValuation       .  OCT2                   1.0         1.0        1.0
 winterRye    .    herb                .  OCT2                   1.0         1.0        1.0
 winterRye    .    weederLight         .  OCT2                                                     1.0
 winterRye    .    plantValuation      .  FEB2                   1.0         1.0        1.0        1.0
 winterRye    .    NFert320            .  FEB2                   1.0         1.0        1.0
 winterRye    .    manDist             .  MAR1                                                     1.0
 winterRye    .    plantValuation      .  MAR2                   1.0         1.0        1.0
 winterRye    .    NFert160            .  APR1                   1.0         1.0        1.0
 winterRye    .    herb                .  APR2                   1.0         1.0        1.0
 winterRye    .    combineCere         .  AUG1                   1.0         1.0        1.0        1.0
 winterRye    .    cornTransport       .  AUG1                   1.0         1.0        1.0        1.0
 winterRye    .    store_n_dry_8       .  AUG1                   1.0         1.0        1.0
 winterRye    .    store_n_dry_4       .  AUG1                                                     1.0
 winterRye    .    lime_fert           .  AUG2                 0.333       0.333      0.333      0.333
 winterRye    .    stubble_shallow     .  AUG2                   1.0         1.0                   1.0
 winterRye    .    stubble_deep        .  SEP2                   1.0         1.0                   1.0

*                                                             plough     minTill   noTill          org  silo  bales
 summerBeans  .    soilSample          .  SEP2                   0.2         0.2        0.2        0.2
 summerBeans  .    basFert             .  OCT1                   1.0         1.0        1.0
 summerBeans  .    plow                .  OCT2                   1.0                               1.0
 summerBeans  .    chiselPlow          .  OCT2                               1.0
 summerBeans  .    springTineHarrow    .  FEB2                                                     1.0
 summerBeans  .    SeedBedCombi        .  FEB2                   1.0                               1.0
 summerBeans  .    sowMachine          .  MAR1                   1.0                               1.0
 summerBeans  .    directSowMachine    .  MAR1                                          1.0
 summerBeans  .    weederLight         .  MAR1                                                     1.0
 summerBeans  .    herb                .  MAR1                   1.0         1.0        1.0
 summerBeans  .    plantValuation      .  MAR1                   1.0         1.0        1.0        1.0
 summerBeans  .    weederIntens        .  APR2                                                     1.0
 summerBeans  .    herb                .  MAY2                   1.0         1.0        1.0
 summerBeans  .    combineCere         .  AUG2                   1.0         1.0        1.0        1.0
 summerBeans  .    cornTransport       .  AUG2                   1.0         1.0        1.0        1.0
 summerBeans  .    store_n_dry_beans   .  AUG2                   1.0         1.0        1.0        1.0
 summerBeans  .    lime_fert           .  SEP1                 0.333       0.333      0.333      0.333
 summerBeans  .    stubble_shallow     .  SEP1                   1.0         1.0                   1.0
 summerBeans  .    stubble_deep        .  OCT1                   1.0         1.0                   1.0


 summerPeas   .    soilSample          .  SEP2                   0.2         0.2        0.2        0.2
 summerPeas   .    basFert             .  OCT1                   1.0         1.0        1.0
 summerPeas   .    plow                .  OCT2                   1.0                               1.0
 summerPeas   .    chiselPlow          .  OCT2                               1.0
 summerPeas   .    springTineHarrow    .  FEB2                                                     1.0
 summerPeas   .    SeedBedCombi        .  FEB2                   1.0                               1.0
 summerPeas   .    sowMachine          .  MAR1                   1.0                               1.0
 summerPeas   .    directSowMachine    .  MAR1                                          1.0
 summerPeas   .    weederLight         .  MAR1                                                     1.0
 summerPeas   .    herb                .  MAR2                   1.0         1.0        1.0
 summerPeas   .    plantValuation      .  MAR2                   1.0         1.0        1.0        1.0
 summerPeas   .    weederLight         .  MAR2                                                     1.0
 summerPeas   .    herb                .  MAY2                   1.0         1.0        1.0
 summerPeas   .    combineCere         .  JUL2                   1.0         1.0        1.0        1.0
 summerPeas   .    cornTransport       .  JUL2                   1.0         1.0        1.0        1.0
 summerPeas   .    store_n_dry_beans   .  JUL2                   0.90        0.90       0.9        0.9
 summerPeas   .    lime_fert           .  AUG1                   0.333       0.333      0.333      0.333
 summerPeas   .    stubble_shallow     .  AUG1                   1.0         1.0                   1.0
 summerPeas   .    stubble_deep        .  SEP1                   1.0         1.0                   1.0

 alfalfa      .    soilSample          .  JUL2                   0.25        0.25       0.25       0.25
 alfalfa      .    plow                .  JUL2                   0.25                              0.25
 alfalfa      .    chiselPlow          .  JUL2                               0.25
 alfalfa      .    springTineHarrow    .  JUL2                                                     0.25
 alfalfa      .    basFert             .  JUL2                   0.25        0.25       0.25
 alfalfa      .    SeedBedCombi        .  JUL2                   0.25                              0.25
 alfalfa      .    sowMachine          .  JUL2                   0.25                              0.25
 alfalfa      .    directSowMachine    .  JUL2                                          0.25
 alfalfa      .    alfalfaHarvDry      .  JUL2                   1.00        1.00       1.00       1.00
 alfalfa      .    herb                .  AUG1                   0.25        0.25       0.25
 alfalfa      .    plantValuation      .  OCT1                   0.25        0.25       0.25       0.25
 alfalfa      .    herb                .  NOV1                   0.75        0.75       0.75
 alfalfa      .    lime_fert           .  JUL1                   0.25        0.25       0.25       0.25
 alfalfa      .    stubble_shallow     .  JUL1                   0.25        0.25       0.25       0.25
 alfalfa      .    stubble_deep        .  JUL1                   0.25        0.25       0.25       0.25
*                                                             plough     minTill   noTill          org  silo  bales
 summerCere   .    soilSample          .  SEP2                   0.2         0.2        0.2        0.2
 summerCere   .    basFert             .  OCT1                   1.0         1.0        1.0
 summerCere   .    plow                .  OCT2                   1.0                               1.0
 summerCere   .    chiselPlow          .  OCT2                               1.0
 summerCere   .    circHarrowSow       .  MAR1                               1.0
 summerCere   .    springTineHarrow    .  MAR1                                                     1.0
 summerCere   .    SeedBedCombi        .  MAR1                   1.0                               1.0
 summerCere   .    sowMachine          .  MAR1                   1.0         1.0                   1.0
 summerCere   .    directSowMachine    .  MAR1                                          1.0
 summerCere   .    weederLight         .  MAR1                                                     1.0
 summerCere   .    plantValuation      .  MAR1                   1.0         1.0        1.0        1.0
 summerCere   .    NFert320            .  MAR1                   1.0         1.0        1.0
 summerCere   .    weedValuation       .  MAR2                   1.0         1.0        1.0
 summerCere   .    herb                .  MAR2                   1.0         1.0        1.0
 summerCere   .    weederLight         .  APR1                                                     1.0
 summerCere   .    plantValuation      .  MAY1                   1.0         1.0        1.0
 summerCere   .    herb                .  JUN1                   1.0         1.0        1.0
 summerCere   .    combineCere         .  JUL2                   1.0         1.0        1.0        1.0
 summerCere   .    cornTransport       .  JUL2                   1.0         1.0        1.0        1.0
 summerCere   .    store_n_dry_8       .  JUL2                   1.0         1.0        1.0
 summerCere   .    store_n_dry_4       .  JUL2                                                     1.0
 summerCere   .    lime_fert           .  AUG1                 0.333       0.333      0.333      0.333
 summerCere   .    stubble_shallow     .  AUG1                   1.0         1.0                   1.0
 summerCere   .    stubble_deep        .  SEP1                   1.0         1.0                   1.0

*                                                             plough     minTill   noTill          org  silo  bales
*conv based on Summerbarley
 summerTriticale.  soilSample          .  SEP2                   0.2        0.2       0.2          0.2
 summerTriticale.  basFert             .  OCT1                   1.0        1.0       1.0
 summerTriticale.  plow                .  OCT2                   1.0                               1.0
 summerTriticale.  chiselPlow          .  OCT2                              1.0
 summerTriticale.  herb                .  FEB2                              1.0       1.0
 summerTriticale.  springTineHarrow    .  FEB2                                                     1.0
 summerTriticale.  circHarrowSow       .  MAR1                              1.0
 summerTriticale.  SeedBedCombi        .  MAR1                   1.0                               1.0
 summerTriticale.  sowMachine          .  MAR1                   1.0                               1.0
 summerTriticale.  directSowMachine    .  MAR1                                        1.0
 summerTriticale.  weederLight         .  MAR1                                                     1.0
 summerTriticale.  manDist             .  MAR2                                                     1.0
 summerTriticale.  plantValuation      .  MAR1                                                     1.0
 summerTriticale.  NFert320            .  MAR1                   1.0        1.0       1.0
 summerTriticale.  weedValuation       .  MAR2                   1.0        1.0       1.0
 summerTriticale.  herb                .  MAR2                   1.0        1.0       1.0
 summerTriticale.  weederLight         .  APR1                                                     1.0
 summerTriticale.  plantValuation      .  JUN1                   1.0        1.0       1.0
 summerTriticale.  herb                .  JUN1                   1.0        1.0       1.0
 summerTriticale.  combineCere         .  JUL2                   1.0        1.0       1.0
 summerTriticale.  cornTransport       .  JUL2                   1.0        1.0       1.0
 summerTriticale.  combineCere         .  AUG1                                                     1.0
 summerTriticale.  cornTransport       .  AUG1                                                     1.0
 summerTriticale.  store_n_dry_8       .  JUL2                   1.0        1.0       1.0
 summerTriticale.  store_n_dry_4       .  AUG1                                                     1.0
 summerTriticale.  lime_fert           .  AUG2                  0.333       0.333     0.333        0.333
 summerTriticale.  stubble_shallow     .  AUG1                   1.0        1.0                    1.0
 summerTriticale.  stubble_deep        .  SEP1                   1.0        1.0                    1.0
 summerTriticale.  stubble_shallow     .  AUG2                                                     1.0
 summerTriticale.  stubble_deep        .  SEP2                                                     1.0


 winterRape   .    soilSample          .  JUL2                   0.2         0.2        0.2        0.2
 winterRape   .    basFert             .  JUL2                   1.0         1.0        1.0
 winterRape   .    plow                .  JUL2                   1.0                               1.0
 winterRape   .    chiselPlow          .  JUL2                               1.0
 winterRape   .    SeedBedCombi        .  AUG1                   1.0                               1.0
 winterRape   .    herb                .  AUG1                                          1.0
 winterRape   .    sowMachine          .  AUG2                   1.0         1.0                   1.0
 winterRape   .    directSowMachine    .  AUG2                                          1.0
 winterRape   .    circHarrowSow       .  AUG2                               1.0
 winterRape   .    weedValuation       .  AUG2                   1.0         1.0        1.0
 winterRape   .    herb                .  AUG2                   1.0         1.0        1.0
 winterRape   .    weederIntens        .  SEP1                                                     1.0
 winterRape   .    weederIntens        .  OCT1                                                     1.0
 winterRape   .    herb                .  OCT2                   1.0
 winterRape   .    NFert320            .  MAR1                   1.0         1.0        1.0
 winterRape   .    plantValuation      .  FEB1                   1.0
 winterRape   .    plantValuation      .  FEB2                                                     1.0
 winterRape   .    manDist             .  MAR1                                                     1.0
 winterRape   .    NFert320            .  APR1                   1.0         1.0        1.0
 winterRape   .    herb                .  APR1                   1.0         1.0        1.0
 winterRape   .    combineRape         .  JUL2                   1.0         1.0        1.0        1.0
 winterRape   .    cornTransport       .  JUL2                   1.0         1.0        1.0        1.0
 winterRape   .    store_n_dry_rape    .  JUL2                   1.0         1.0        1.0        1.0
 winterRape   .    lime_fert           .  JUL2                 0.333       0.333      0.333      0.333
 winterRape   .    stubble_shallow     .  JUL2                   1.0         1.0                   1.0
 winterRape   .    stubble_deep        .  AUG2                   1.0         1.0                   1.0

*                                                             plough     minTill   noTill          org  silo  bales
 sugarbeet    .    soilSample          .  SEP1                   0.2          0.2                  0.2
 sugarbeet    .    basFert             .  OCT1                   1.0          1.0
 sugarbeet    .    plow                .  OCT2                   1.0                               1.0
 sugarbeet    .    chiselPlow          .  OCT2                                1.0
 sugarbeet    .    NFert320            .  MAR1                   1.0          1.0
 sugarbeet    .    manDist             .  MAR1                                                     1.0
 sugarbeet    .    springTineHarrow    .  MAR1                                                     1.0
 sugarbeet    .    SeedBedCombi        .  MAR1                   1.0                               1.0
 sugarbeet    .    rotaryHarrow        .  MAR1                                1.0
 sugarbeet    .    singleSeeder        .  MAR2                   1.0          1.0                  1.0
 sugarbeet    .    weedValuation       .  MAR2                   1.0          1.0                  1.0
 sugarbeet    .    herb                .  MAR2                   1.0          1.0
 sugarbeet    .    weederIntens        .  APR2                                                     1.0
 sugarbeet    .    weederIntens        .  MAY1                                                     1.0
 sugarbeet    .    herb                .  MAY2                   1.0          1.0
 sugarbeet    .    plantValuation      .  MAY2                                                     1.0
 sugarbeet    .    weederHand          .  MAY2                                                     1.0
 sugarbeet    .    weederIntens        .  MAY2                                                     1.0
 sugarbeet    .    weederHand          .  JUN1                                                     1.0
 sugarbeet    .    plantValuation      .  JUL2                   1.0          1.0
 sugarbeet    .    herb                .  AUG1                   1.0          1.0
 sugarbeet    .    uprootBeets         .  SEP2                   1.0          1.0                  1.0
 sugarbeet    .    lime_fert           .  OCT1                 0.333        0.333                0.333
 sugarbeet    .    stubble_shallow     .  OCT1                   1.0          1.0                  1.0

*                                                             plough     minTill   noTill          org  silo  bales
 maizCorn     .    soilSample          .  SEP2                   0.2          0.2                  0.2
 maizCorn     .    plow                .  OCT2                   1.0                               1.0
 maizCorn     .    chiselPlow          .  OCT2                                1.0
 maizCorn     .    springTineHarrow    .  APR1                                                     1.0
 maizCorn     .    manDist             .  APR1                   1.0          1.0                  1.0
 maizCorn     .    SeedBedCombi        .  APR1                   1.0                               1.0
 maizCorn     .    rotaryHarrow        .  APR1                                1.0
 maizCorn     .    DiAmmonium          .  APR2                   1.0          1.0
 maizCorn     .    singleSeeder        .  APR2                   1.0          1.0                  1.0
 maizCorn     .    herb                .  APR2                   1.0          1.0
 maizCorn     .    weederLight         .  APR2                                                     1.0
 maizCorn     .    weedValuation       .  APR2                   1.0          1.0
 maizCorn     .    manDist             .  MAY1                                                     1.0
 maizCorn     .    herb                .  MAY1                   1.0          1.0
 maizCorn     .    weederIntens        .  MAY1                                                     1.0
 maizCorn     .    plantValuation      .  MAY2                   1.0          1.0                  1.0
 maizCorn     .    NFert160            .  MAY2                   1.0          1.0
 maizCorn     .    weederIntens        .  JUN1                                                     1.0
 maizCorn     .    combineMaiz         .  OCT2                   1.0          1.0                  1.0
 maizCorn     .    cornTransport       .  OCT2                   1.0          1.0                  1.0
 maizCorn     .    store_n_dry_corn    .  OCT2                   1.0          1.0                  1.0
 maizCorn     .    lime_fert           .  OCT2                 0.333        0.333                0.333
 maizCorn     .    stubble_shallow     .  OCT2                   1.0          1.0
 maizCorn     .    stubble_deep        .  OCT2                                                     1.0

*                                                             plough     minTill   noTill          org  silo  bales
 maizCCM      .    soilSample          .  SEP2                   0.2          0.2
 maizCCM      .    plow                .  OCT2                   1.0
 maizCCM      .    chiselPlow          .  OCT2                                1.0
* maizCCM      .    springTineHarrow    .  APR1
 maizCCM      .    manDist             .  APR1                   1.0          1.0
 maizCCM      .    SeedBedCombi        .  APR1                   1.0
 maizCCM      .    rotaryHarrow        .  APR1                                1.0
 maizCCM      .    DiAmmonium          .  APR2                   1.0          1.0
 maizCCM      .    singleSeeder        .  APR2                   1.0          1.0
 maizCCM      .    herb                .  APR2                   1.0          1.0
 maizCCM      .    weederLight         .  APR2
 maizCCM      .    weedValuation       .  APR2                   1.0          1.0
* maizCCM      .    manDist             .  MAY1
 maizCCM      .    herb                .  MAY1                   1.0          1.0
* maizCCM      .    weederIntens        .  MAY1
 maizCCM      .    plantValuation      .  MAY2                   1.0          1.0
 maizCCM      .    NFert160            .  MAY2                   1.0          1.0
* maizCCM      .    weederIntens        .  JUN1
 maizCCM      .    combineMaiz         .  OCT1                   1.0          1.0
 maizCCM      .    cornTransport       .  OCT1                   1.0          1.0
 maizCCM      .    grinding            .  OCT1                   1.0          1.0
 maizCCM      .    disposal            .  OCT1                   1.0          1.0
 maizCCM      .    coveringSilo        .  OCT1                   1.0          1.0
 maizCCM      .    lime_fert           .  OCT1                   0.333        0.333
 maizCCM      .    stubble_shallow     .  OCT1                   1.0          1.0

*                                                             plough     minTill   noTill          org  silo  bales
 maizSil      .    soilSample          .  SEP2                   0.2          0.2                  0.2
 maizSil      .    basFert             .  OCT1                   1.0          1.0
 maizSil      .    plow                .  OCT2                   1.0                               1.0
 maizSil      .    chiselPlow          .  OCT2                                1.0
 maizSil      .    springTineHarrow    .  APR1                                                     1.0
 maizSil      .    manDist             .  APR1                   1.0          1.0                  1.0
 maizSil      .    SeedBedCombi        .  APR1                   1.0                               1.0
 maizSil      .    rotaryHarrow        .  APR1                                1.0
 maizSil      .    singleSeeder        .  APR2                   1.0          1.0                  1.0
 maizSil      .    herb                .  APR2                   1.0          1.0
 maizSil      .    weederLight         .  APR2                                                     1.0
 maizSil      .    weedValuation       .  MAY1                   1.0          1.0
 maizSil      .    herb                .  MAY1                   1.0          1.0
 maizSil      .    manDist             .  MAY1                                                     1.0
 maizSil      .    weederIntens        .  MAY1                                                     1.0
 maizSil      .    plantValuation      .  MAY2                   1.0          1.0
 maizSil      .    NFert160            .  MAY2                   1.0          1.0
 maizSil      .    weederIntens        .  JUN1                                                     1.0
 maizSil      .    chopper             .  SEP2                   1.0          1.0                  1.0
 maizSil      .    disposal            .  SEP2                   1.0          1.0                  1.0
 maizSil      .    coveringSilo        .  SEP2                   1.0          1.0
 maizSil      .    lime_fert           .  OCT2                 0.333        0.333                0.333
 maizSil      .    stubble_shallow     .  OCT2                   1.0          1.0                  1.0

*                                                             plough     minTill   noTill          org  silo  bales
 wheatGPS     .    soilSample          .  SEP1                   0.2         0.2        0.2        0.2
 wheatGPS     .    manDist             .  SEP1                                                     1.0
 wheatGPS     .    basFert             .  SEP1                   1.0         1.0        1.0
 wheatGPS     .    plow                .  SEP2                   1.0                               1.0
 wheatGPS     .    chiselPlow          .  SEP2                               1.0
 wheatGPS     .    SeedBedCombi        .  OCT1                   1.0                               1.0
 wheatGPS     .    herb                .  OCT1                                          1.0
 wheatGPS     .    sowMachine          .  OCT2                   1.0                               1.0
 wheatGPS     .    directSowMachine    .  OCT2                                          1.0
 wheatGPS     .    circHarrowSow       .  OCT2                               1.0
 wheatGPS     .    weedValuation       .  OCT2                   1.0         1.0        1.0
 wheatGPS     .    herb                .  OCT2                   1.0         1.0        1.0
 wheatGPS     .    weederLight         .  NOV1                                                     1.0
 wheatGPS     .    plantValuation      .  FEB2                   1.0         1.0        1.0        1.0
 wheatGPS     .    NFert320            .  FEB2                   1.0         1.0        1.0
 wheatGPS     .    weederLight         .  MAR1                                                     1.0
 wheatGPS     .    plantValuation      .  MAR2                   1.0         1.0        1.0
 wheatGPS     .    NFert160            .  APR1                   1.0         1.0        1.0
 wheatGPS     .    herb                .  APR1                   1.0         1.0        1.0
 wheatGPS     .    chopper             .  JUN2                   1.0         1.0        1.0        1.0
 wheatGPS     .    disposal            .  JUN2                   1.0         1.0        1.0        1.0
 wheatGPS     .    lime_fert           .  AUG2                 0.333       0.333      0.333      0.333
 wheatGPS     .    stubble_shallow     .  AUG2                   1.0         1.0                   1.0
 wheatGPS     .    stubble_deep        .  SEP2                   1.0         1.0                   1.0
;


*
* --- changes in # of field operations / intensity of operation depending on intensity level
*
parameter p_changeOpIntens(crops,operation,labPeriod,intens);

* p_changeOpIntens(cropOpcrops(crops),operation,labperiod,intens) = 1;

 p_changeOpIntens("winterWheat","herb","MAY1",lower)             = 0;
 p_changeOpIntens("winterWheat","herb","JUN1",lower)             = 0.5;

 p_changeOpIntens("winterWheat","nFert160","JUN1",lower)         = 0.5;
 p_changeOpIntens("winterWheat","combineCere","AUG1",lower)      = 0.94;
 p_changeOpIntens("winterWheat","cornTransport","AUG1",lower)    = 0.94;
 p_changeOpIntens("winterWheat","store_n_dry_8","AUG1",lower)    = 0.92;

 p_changeOpIntens("winterWheat","herb","MAY1",veryLow)           = 0;
 p_changeOpIntens("winterWheat","herb","JUN1",veryLow)           = 0;
 p_changeOpIntens("winterWheat","nFert160","JUN1",veryLow)       = 0;
 p_changeOpIntens("winterWheat","combineCere","AUG1",veryLow)    = 0.86;
 p_changeOpIntens("winterWheat","cornTransport","AUG1",veryLow)  = 0.86;
 p_changeOpIntens("winterWheat","store_n_dry_8","AUG1",veryLow)  = 0.84;

 p_changeOpIntens("winterBarley","herb","MAY1",lower)            = 0;
 p_changeOpIntens("winterBarley","herb","JUN1",lower)            = 0.5;

 p_changeOpIntens("winterBarley","nFert160","JUN1",lower)        = 0.5;
 p_changeOpIntens("winterBarley","combineCere","AUG1",lower)     = 0.94;
 p_changeOpIntens("winterBarley","cornTransport","AUG1",lower)   = 0.94;
 p_changeOpIntens("winterBarley","store_n_dry_8","AUG1",lower)   = 0.92;

 p_changeOpIntens("winterBarley","herb","MAY1",veryLow)          = 0;
 p_changeOpIntens("winterBarley","herb","JUN1",veryLow)          = 0;
 p_changeOpIntens("winterBarley","nFert160","JUN1",veryLow)      = 0;
 p_changeOpIntens("winterBarley","combineCere","AUG1",veryLow)   = 0.86;
 p_changeOpIntens("winterBarley","cornTransport","AUG1",veryLow) = 0.86;
 p_changeOpIntens("winterBarley","store_n_dry_8","AUG1",veryLow) = 0.84;

 p_changeOpIntens("winterRye","herb","APR2",lower)            = 0;
 p_changeOpIntens("winterRye","herb","OCT2",lower)            = 0.5;

 p_changeOpIntens("winterRye","nFert160","APR1",lower)        = 0.5;
 p_changeOpIntens("winterRye","combineCere","AUG1",lower)     = 0.94;
 p_changeOpIntens("winterRye","cornTransport","AUG1",lower)   = 0.94;
 p_changeOpIntens("winterRye","store_n_dry_8","AUG1",lower)   = 0.92;

 p_changeOpIntens("winterRye","herb","OCT2",veryLow)          = 0;
 p_changeOpIntens("winterRye","herb","APR2",veryLow)          = 0;
 p_changeOpIntens("winterRye","nFert160","APR1",veryLow)      = 0;
 p_changeOpIntens("winterRye","combineCere","AUG1",veryLow)   = 0.86;
 p_changeOpIntens("winterRye","cornTransport","AUG1",veryLow) = 0.86;
 p_changeOpIntens("winterRye","store_n_dry_8","AUG1",veryLow) = 0.84;


 p_changeOpIntens("SummerTriticale","combineCere","JUL2",lower)     = 0.94;
 p_changeOpIntens("SummerTriticale","cornTransport","JUL2",lower)   = 0.92;
 p_changeOpIntens("SummerTriticale","store_n_dry_8","JUL2",lower)   = 0.92;
 p_changeOpIntens("SummerTriticale","combineCere","JUL2",veryLow)   = 0.86;
 p_changeOpIntens("SummerTriticale","cornTransport","JUL2",veryLow) = 0.86;
 p_changeOpIntens("SummerTriticale","store_n_dry_8","JUL2",veryLow) = 0.84;

 p_changeOpIntens("summerCere","combineCere","JUL2",lower)     = 0.94;
 p_changeOpIntens("summerCere","cornTransport","JUL2",lower)   = 0.92;
 p_changeOpIntens("summerCere","store_n_dry_8","JUL2",lower)   = 0.92;
 p_changeOpIntens("summerCere","combineCere","JUL2",veryLow)   = 0.86;
 p_changeOpIntens("summerCere","cornTransport","JUL2",veryLow) = 0.86;
 p_changeOpIntens("summerCere","store_n_dry_8","JUL2",veryLow) = 0.84;

 p_changeOpIntens("winterRape","herb","APR1",lower)   = 0;
 p_changeOpIntens("winterRape","herb","APR1",veryLow) = 0;
 p_changeOpIntens("winterRape","herb","MAY1",veryLow) = 0;

 p_changeOpIntens("winterRape","combineRape","JUL2",lower)        = 0.94;
 p_changeOpIntens("winterRape","combineRape","JUL2",veryLow)      = 0.86;
 p_changeOpIntens("winterRape","cornTransport","JUL2",lower)      = 0.94;
 p_changeOpIntens("winterRape","cornTransport","JUL2",veryLow)    = 0.86;
 p_changeOpIntens("winterRape","store_n_dry_rape","JUL2",lower)   = 0.92;
 p_changeOpIntens("winterRape","store_n_dry_rape","JUL2",veryLow) = 0.84;







**********************************************************************************
*
*
*  -   New Structure see beginning of file
*                     -
*
*
**********************************************************************************


Execute_unload "%datdir%/crops_ch.gdx"
* Sets
                             m, crops,arableCrops,biogas_feed, cashCrops,ccCrops,cere,cereFeedsPigGDX,leg,maize,maizSilage,no_CashCrops,rootCrops,Wintercere,summercere,potatoes,
                             sugarbeet, rapeseed,summerHarvest, GPS, grain_Wheat, grain_barley, grain_rye, grain_maize, maizccm, grain_Oat OtherGrains, grainleg, monthGrowthCrops,
                             crop_residues,cropsResidues_prods, feed_ccCrops, feed, cropGroups, feedAttr,monthHarvestBlock, monthHarvestCrops, resiEle, cropsResidueRemo, roughages,
                             other, hay, vegetables,inputs, p_crop_op_per_tilla,
* Parameters
                             p_storageLoss,p_nutContent, p_organicYieldMult, p_nfromLegumes, p_maxRotShare,p_costQuant,p_NrespFunct, p_nMin,p_residue_ratio
                             p_cropResi,p_efLeachFert,p_monthAfterLeg, p_humCrop,p_feedContDMg,p_feedAttrPig,p_nutCont,p_Yieldlevel,p_cropPrice,p_addN,p_redN ,p_NNeed
                             p_cropGroups_to_crops, p_efa, p_crop,p_dryMatterCrop,p_fugCrop,p_totNCrop, p_shareNTAN, p_cropYield, p_cerealUnit, p_orgDryMatterCrop,
                             p_resiInc, p_inputPrices, p_changeOpIntens, p_inputQuant;
