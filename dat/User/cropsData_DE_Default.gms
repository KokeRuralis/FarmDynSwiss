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

* --- All winter crops

  set winterCrops(crops) /
                   WinterWheat
                   WinterBarley
                   WinterRye
                   WinterRape
                   WheatGPS
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
*[UPDATED]
* --- Crop yield as default settings for GUI

  PARAMETER p_cropYield(*,*) /
*KTBL BP 24/25 p.345  
'WinterWheat'.'conv' 8.0
* Verfahrensrechner Pflanze 24.09.25 Wintergerste - Futtergerste
'WinterBarley'.'conv' 7.0
* Verfahrensrechner Pflanze 24.09.25 Winterroggen - Futterroggen
'WinterRye'.'conv'    8.0
* KTBL BP 24/25 p. 376 Braugerste
'SummerCere'.'conv' 6.0
* [To do] take out summer triticale? not really grown and not in KTBL
'SummerTriticale'.'conv' 6.0
* KTBL BP 24/25 p. 432
'WinterRape'.'conv' 3.5
* KTBL BP 24/25 p. 468
'Potatoes'.'conv' 45.0
* KTBL BP 24/25 p. 481
'Sugarbeet'.'conv' 60.0
* KTBL BP 24/25 p. 391
'MaizCorn'.'conv' 12
* KTBL BP 24/25 p. 413
'MaizCCM'.'conv' 14.0
* KTBL BP 24/25 p. 456
'Summerpeas'.'conv' 3.5
* KTBL BP 24/25 p. 444
'Summerbeans'.'conv' 4.0
* KTBL BP 24/25 p. 362
'WheatGPS'.'conv' 40.0
* KTBL BP 24/25 p. 402 
'MaizSil'.'conv' 50.0
* [To do] not in KTBL book or online. where from? replace?
'Alfalfa'.'conv' 10.2
*'CCclover'.'conv' 18
*'CCMustard'.'conv' 18
 /;


 p_cropYield(crops,'Change,conv % p.a.')   = eps;


* --- Crop price as default settings for GUI
*[UPDATE TK]
 parameter p_cropPrice(*,*)/

* KTBL BP 24/25 p. 350
       "WinterWheat"     ."conv"       272
* KTBL Leistungs-Kostenrechnung Pflanzenbau 24.09.25 Wintergerste - Futtergerste
       "WinterBarley"    ."conv"       238
* KTBL Leistungs-Kostenrechnung Pflanzenbau 24.09.25 Winterroggen - Futterroggen   
       "WinterRye"       ."conv"       234
* KTBL BP 24/25 p. 395
       "MaizCorn"        ."conv"       205
* KTBL BP 24/25 p. 318
       "SummerCere"      ."conv"       318
*XXXXX
       "SummerTriticale" ."conv"       181
* KTBL BP 24/25 p. 436
       "WinterRape"      ."conv"       533
* KTBL BP 24/25 p. 448       
       "SummerBeans"     ."conv"       325
* KTBL BP 24/25 p. 460     
       "SummerPeas"      ."conv"       329
* KTBL BP 24/25 p. 366      
       "WheatGPS"        ."conv"        65.10
* KTBL BP 24/25 p. 406       
       "MaizSil"         ."conv"        54.90
* KTBL BP 24/25 p. 419       
       "MaizCCM"         ."conv"       116
* KTBL BP 24/25 p. 528       
       "GrasSil"         ."conv"        76
* XXXXX
       "Alfalfa"         ."conv"       180
* KTBL BP 24/25 p. 473        
       "Potatoes"        ."conv"       565
* KTBL BP 24/25 p. 473          
       "SugarBeet"       ."conv"        43.80
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

* --- p_nutContent has to be given as an output file [TODO]

* ---- N content of crops in kg N/dt fresh matter according to DUEV 2006, Anlage 1
* ---- P content of crops in kg P/dt fresh matter and N content of maizCCM according to LWK NRW
* ---- N and P removal via product and crop residues (Nebenernteprodukt) is calculated as HF + HNV * NF (D�V 2006, Anlage 1)
* ---- Assumption: crop residues are taken away from the field  (except of potatoes, rape, beets, beans, peas, maizCorn,MaizCCM)
parameter p_nutContent(crops,*,sys,*);

   p_nutContent("winterWheat","winterWheat",sys,"N")    =  2.11;
   p_nutContent("winterBarley","winterBarley",sys,"N")  =  1.79;
   p_nutContent("winterRye","winterRye",sys,"N")        =  1.65;
   p_nutContent("winterRape","winterRape",sys,"N")      =  3.35;
   p_nutContent("summerCere","summerCere",sys,"N")      =  1.79;
   p_nutContent("summerTriticale","summerTriticale",sys,"N")    =  1.79;
   p_nutContent("potatoes","potatoes",sys,"N")          =  0.35;
   p_nutContent("maizCorn","maizCorn",sys,"N")          =  1.38;
   p_nutContent("maizCCM","maizCCM",sys,"N")            =  1.05;
   p_nutContent("sugarbeet","sugarbeet",sys,"N")        =  0.18;
   p_nutContent("summerbeans","summerbeans",sys,"N")    =  4.10;
   p_nutContent("summerpeas","summerpeas",sys,"N")      =  3.60;
*  --- output defined in freshweight
   p_nutContent("Alfalfa","alfalfa",sys,"N")            =  3.59/3;
   p_nutContent("wheatGPS","wheatGPS",sys,"N")          =  0.54;

* --- Nut content of removed residues, possible for cereal production
   p_nutContent("winterWheat","WCresidues",sys,"N")     =  0.5 ;
   p_nutContent("winterBarley","WBresidues",sys,"N")    =  0.5 ;
   p_nutContent("winterRye","WRresidues",sys,"N")       =  0.5 ;
   p_nutContent("summerCere","SCresidues",sys,"N")      =  0.5 ;
   p_nutContent("summerTriticale","STresidues",sys,"N") =  0.5 ;
   p_nutContent("MaizSil","MaizSil",sys,"N")            = 0.38;


* --- P content is taken from LWK NRW; calculation equivalent to N
   p_nutContent("winterWheat","winterWheat",sys,"P")         =  0.80;
   p_nutContent("winterBarley","winterBarley",sys,"P")       =  0.80;
   p_nutContent("winterRye","winterRye",sys,"P")             =  0.80;
   p_nutContent("winterRape","winterRape",sys,"P")           =  1.80;
   p_nutContent("summerCere","summerCere",sys,"P")           =  0.80;
   p_nutContent("summerTriticale","summerTriticale",sys,"P") =  0.80;
   p_nutContent("potatoes","potatoes",sys,"P")               =  0.14;
   p_nutContent("maizCorn","maizCorn",sys,"P")               =  0.80;
   p_nutContent("maizCCM","maizCCM",sys,"P")                 =  0.53;
   p_nutContent("sugarbeet","sugarbeet",sys,"P")             =  0.10;
   p_nutContent("summerbeans","summerbeans",sys,"P")         =  1.20;
   p_nutContent("summerpeas","summerpeas",sys,"P")           =  1.10;
*  --- output defined in freshweight
   p_nutContent("Alfalfa","alfalfa",sys,"P")                 =  0.77/3;
   p_nutContent("wheatGPS","wheatGPS",sys,"P")               =  0.24;
   p_nutContent("wheatGPS","wheatGPS",sys,"P")               =  0.24;
   p_nutContent("MaizSil","MaizSil",sys,"P")                 = 0.19;


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
*  --- Definition of p_costQuant corresponds to direct costs (Direktkosten)
*
*  --- the %a% defaults to an empty string, while the %m%/%v% are either empty (= entry read) or a * to comment them out when not needed
*
*[UPDATE TK]
set intens /empty, normal, midlow, verylow/;
   table p_costQuant(crops,till,intens,inputs)
*                         %empty%       Eu/ha   kg        kg      t    EU/ha  EU/ha   EU/ha       EU/ha      m3      EU/ha     kg
                                        seed   KAS   PK_18_10   Lime   Herb   Fung   Insect   growthContr   water   hailIns    KaliMag

* KTBL BP 2024/25 p.359
winterWheat.org        .normal           180                      1.0                                               16.85
* KTBL BP 2024/25 p.353, p.67 for pesticide costs
* XXX Nachbaugebühr not included, add to own item or seed costs?
winterWheat.plough     .normal           140.4 640        400     1.0    99    130    18.00            20     1.2   17.59
winterWheat.plough     .midLow           140.4 640        400     1.0    65     80     6.00             5     1.2   17.59
winterWheat.plough     .veryLow          140.4 640        400     1.0    52     41                      8     1.2   17.59
* KTBL BP 2024/25 p.350, p.67 for pesticide costs
winterWheat.minTill    .normal           140.4 640        400     1.0    99    130    18.00            20     1.2   17.59
winterWheat.minTill    .midLow           140.4 640        400     1.0    65     80     6.00             5     1.2   17.59
winterWheat.minTill    .veryLow          140.4 640        400     1.0    52     41                      8     1.2   17.59
* KTBL BP 2024/25 p.356, p.67 for pesticide costs
* for midLow, assume  high intensity for fungizides and herbicides, as KTBL in default
winterWheat.noTill     .normal           140.4 640        400     1.0    99    130    18.00            20    1.5    17.59
winterWheat.noTill     .midLow           140.4 640        400     1.0    99    130     6.00             5     1.5    17.59
winterWheat.noTill     .veryLow          140.4 640        400     1.0    52     41                      8     1.5    17.59

* Leistungs-Kostenrechnung Pflanzenbau 24.09.25 Wintergerste - Futtergerste, wendend, Gülle, ökologisch
winterBarley.org       .normal           151.1                    1.0                                                13.99
* Leistungs-Kostenrechnung Pflanzenbau 24.09.25 Wintergerste - Futtergerste - wendend, KTBL BP 2024/25 p. 67 for pesticide costs
winterBarley.plough    .normal           121.8 420        340     1.0    85    113    18.00            39     0.9    13.42
winterBarley.plough    .midLow           121.8 420        340     1.0    69     86     6.00            26     0.9    13.42
winterBarley.plough    .veryLow          121.8 420        340     1.0    66     74                     13     0.9    13.42
* Leistungs-Kostenrechnung Pflanzenbau 24.09.25 Wintergerste - Futtergerste, nichtwendend, 
*XXXX Insectizid costs missing in KTBL for minTill
winterBarley.minTill   .normal           121.8 420        340     1.0    85    113                     39     0.9   13.42
winterBarley.minTill   .midLow           121.8 420        340     1.0    69     86                     26     0.9   13.42
winterBarley.minTill   .veryLow          121.8 420        340     1.0    66     74                     13     0.9   13.42
* Leistungs-Kostenrechnung Pflanzenbau 24.09.25 Wintergerste - Futtergerste, Direktsaat,
* for midLow , assume high intensity for  herbicides, as KTBL in default
winterBarley.noTill    .normal          121.8  420        340     1.0    85    113                     39     1.2   13.42
winterBarley.noTill    .midLow          121.8  420        340     1.0    85     86                     26     1.2   13.42
winterBarley.noTill    .veryLow         121.8  420        340     1.0    66     74                     13     1.2   13.42
* Leistungs-Kostenrechnung Pflanzenbau 24.09.25 Winterroggen - Futterroggen wendend, Gülle, ökologisch
winterRye   .org       .normal          128.4                     1.0                                               12.27
* Leistungs-Kostenrechnung Pflanzenbau 24.09.25 Winterroggen - Futterroggen, wenden
* Seed costs wrong in KTBL, used LFL Deckungsbeiträge online instead
* XXXX No min and noTill version for winter rye
winterRye   .plough    .normal           68.9  440        400     1.0    62     74      1              22     0.9    15.13
winterRye   .plough    .midLow           68.9  440        400     1.0    48     55                     11     0.9    15.13
winterRye   .plough    .veryLow          68.9  440        400     1.0    42     33                      7     0.9    15.13
* XXXX No min and noTill version for winter rye
winterRye   .minTill   .normal           68.9  440        400    40.7    62     74      1              22     0.9    15.13
winterRye   .minTill   .midLow           68.9  440        400    40.7    48     55                     11     0.9    15.13
winterRye   .minTill   .veryLow          68.9  440        400    40.7    42     33                      7     0.9    15.13
* XXXX No min and noTill version for winter rye
winterRye   .noTill    .normal           68.9  440        400    40.7    62     74      1              22     0.9    15.13
winterRye   .noTill    .midLow           68.9  440        400    40.7    48     55                     11     0.9    15.13
winterRye   .noTill    .veryLow          68.9  440        400    40.7    42     33                      7     0.9    15.13

*                                        EU/ha   kg        kg      t     EU/ha  EU/ha   EU/ha      EU/ha      m3       EU/ha      kg
*                       %empty%          seed   KAS   PK_18_10   Lime   Herb   Fung   Insect   growthContr   water   hailIns    KaliMag
* KTBL BP 2024/25 p.388 
summerCere.org        .normal           169.4                     1.0                                               11.53
* KTBL BP 2024/25 p. 383, p.67 for pesticide costs
summerCere.plough     .normal           103.4  310        320     1.0    59    104      3               6     0.6   15.38
summerCere.plough     .midLow           103.4  310        320     1.0    40     80      1               1     0.6   15.38
summerCere.plough     .veryLow          103.4  310        320     1.0    35     59      0               0     0.6   15.38
* KTBL BP 2024/25 p. 380, p.67 for pesticide costs
summerCere.minTill    .normal           103.4  310        320     1.0    59    104      3               6     0.9   15.38
summerCere.minTill    .midLow           103.4  310        320     1.0    40     80      1               1     0.9   15.38
summerCere.minTill    .veryLow          103.4  310        320     1.0    35     59      0               0     0.9   15.38
* KTBL BP 2024/25 p. 386
* for midLow, assume  high intensity for fungizides and herbicides, as KTBL in default
summerCere.noTill     .normal           103.4  310        320     1.0    59    104      3               6     0.9   15.38
summerCere.noTill     .midLow           103.4  310        320     1.0    59    104      1               1     0.9   15.38
summerCere.noTill     .veryLow          103.4  310        320     1.0    35     59      0               0     0.9   15.38
*                                        SummmerTriticale conv sed on   Summerbarley
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
* Leistungs-Kostenrechnung Pflanzenbau 24.09.25 Winterraps, wendend, Gülle, ökologisch  
winterRape.org        .normal            43.6                     1.0                                               45.64
* KTBL BP 2024/25 p.438, p. 67 for pesticide costs
winterRape.plough     .normal           123.4  440        360     1.0   158    106    52.00            29.2   0.9   44.91
winterRape.plough     .midLow           123.4  440        360     1.0   131     53    35.00            12.7   0.9   44.91
winterRape.plough     .veryLow          123.4  440        360     1.0   111     18    17.00                   0.9   44.91
* KTBL BP 2024/25 p.436, p. 67 for pesticide costs
winterRape.minTill    .normal           123.4  440        360     1.0   158    106    52.00            29.2   0.9   44.91
winterRape.minTill    .midLow           123.4  440        360     1.0   131     53    35.00            12.7   0.9   44.91
winterRape.minTill    .veryLow          123.4  440        360     1.0   110     18    17.00                   0.9   44.91
* KTBL BP 2024/25 p.436, p. 67 for pesticide costs
* for midLow, assume  medium intensity KTBL in default
winterRape.noTill     .normal           123.4  440        360     1.0   159    106    52.00            29.2   1.2   44.91
winterRape.noTill     .midLow           123.4  440        360     1.0   131     53    35.00            12.7   1.2   44.91 
winterRape.noTill     .veryLow          123.4  440        360     1.0   110     18    17.00                   1.2   44.91
* Leistungs-Kostenrechnung Pflanzenbau 24.09.25 Kartoffeln - Speisekartoffeln, spät, wendend, ökologisch
potatoes.org          .normal          2725.0                     1.0          168    60.00                   1.5  221.76
* Leistungs-Kostenrechnung Pflanzenbau 24.09.25 Kartoffeln - Speisekartoffeln, spät, wendend, gezogene Saatbettbereitung
*  KTBL BP 2024/25 p.67 for pesticide costs
potatoes.plough       .normal          1700.0  720        500     1.0    174   344    86.00            162.0  2.7  254.23       700
potatoes.plough       .midLow          1700.0  720        500     1.0    159   287    43.00             97.0  2.7  254.23       700
potatoes.plough       .veryLow         1700.0  720        500     1.0    131   191     3.0              65.0  2.7  254.23       700
* Leistungs-Kostenrechnung Pflanzenbau 24.09.25 Kartoffeln - Speisekartoffeln, spät, nichtwendend, Kreiseleggen, Legen
potatoes.minTill      .normal          1700.0  720        500     1.0    174   344    86.00            162    2.7  254.23       700
potatoes.minTill      .midLow          1700.0  720        500     1.0    159   287    43.00             97    2.7  254.23       700
potatoes.minTill      .veryLow         1700.0  720        500     1.0    131   191     3.0              65    2.7  254.23       700
* XXX Doest not exist in KTBL
potatoes.noTill       .normal
potatoes.noTill       .midLow
potatoes.noTill       .veryLow
*                                        EU/ha   kg        kg      t     EU/ha  EU/ha   EU/ha      EU/ha      m3       EU/ha      kg
*                       %empty%          seed   KAS   PK_18_10   Lime   Herb   Fung   Insect   growthContr   water   hailIns    KaliMag
* KTBL BP 2024/25 p.411 
* XXX Hail insurance for silage maize missing
maizsil.org          .normal            321.2                     1.0
* KTBL BP 2024/25 p.409, p.67 for pesticide costs (maize general)
maizsil.plough       .normal            270.6  400         500    1.0   135           32.0                    0.6
maizsil.plough       .midLow            270.6  400         500    1.0   102           13.0                    0.6
maizsil.plough       .veryLow           270.6  400         500    1.0    87                                   0.6
* KTBL BP 2024/25 p.406, p.67 for pesticide costs (maize general)
maizsil.minTill      .normal            270.6  400         500    1.0   135           32.0                    0.6
maizsil.minTill      .midLow            270.6  400         500    1.0   102           13.0                    0.6
maizsil.minTill      .veryLow           270.6  400         500    1.0    87                                   0.6
* XXX Does not exist in KTBL
maizsil.noTill       .normal
maizsil.noTill       .midLow
maizsil.noTill       .veryLow
* KTBL BP 2024/25 p.399 
maizcorn.org          .normal           274                       1.0                                                15.09
* KTBL BP 2024/25 p.395, p.67 for pesticide costs (maize general)
* Diammonphosphat as fertilzer missing, add?
maizcorn.plough       .normal           246    240                1.0    135         32.0                     0.6    14.72
maizcorn.plough       .midLow           246    240                1.0    102         13.0                     0.6    14.72
maizcorn.plough       .veryLow          246    240                1.0     87                                  0.6    14.72
* KTBL BP 2024/25 p.397, p.67 for pesticide costs (maize general)
* Diammonphosphat as fertilzer missing, add?
maizcorn.minTill      .normal           246    240                1.0    135         32.0                     0.6    14.72
maizcorn.minTill      .midLow           246    240                1.0    102         13.0                     0.6    14.72
maizcorn.minTill      .veryLow          246    240                1.0     87                                  0.6    14.72
* XXX Does not exist in KTBL
maizcorn.noTill       .normal
maizcorn.noTill       .midLow
maizcorn.noTill       .veryLow
* XXX Organic version missing in KTBL
* KTBL BP 2024/25 p.417, p.67 for pesticide costs (maize general)
maizCCM.plough       .normal            246    240                1.0    135         32.0                     0.6    10.89
maizCCM.plough       .midLow            246    240                1.0    102         13.0                     0.6    10.89
maizCCM.plough       .veryLow           246    240                1.0     87                                  0.6    10.89
* KTBL BP 2024/25 p.419, p.67 for pesticide costs (maize general)
maizCCM.minTill      .normal            246    240                1.0    135         32.0                     0.6    10.89
maizCCM.minTill      .midLow            246    240                1.0    102         13.0                     0.6    10.89
maizCCM.minTill      .veryLow           246    240                1.0     87                                  0.6    10.89 
* XXX Does not exist in KTBL
maizCCM.noTill       .normal
maizCCM.noTill       .midLow
maizCCM.noTill       .veryLow
* KTBL BP 2024/25 p.489 
sugarbeet.org          .normal           335.8                    1.0                                                 42.95
* KTBL BP 2024/25 p.485, p.67 for pesticide costs
sugarbeet.plough       .normal           254.6 400         450    1.0     379   200       3                    0.9    21.51        140
sugarbeet.plough       .midLow           254.6 400         450    1.0     321   100       2                    0.9    21.51        140
sugarbeet.plough       .veryLow          254.6 400         450    1.0     268    50                            0.9    21.51        140
* KTBL BP 2024/25 p.487, p.67 for pesticide costs
sugarbeet.minTill      .normal           254.6 400         450    1.0     379   200       3                    0.9    21.51        140
sugarbeet.minTill      .midLow           254.6 400         450    1.0     321   100       2                    0.9    21.51        140
sugarbeet.minTill      .veryLow          254.6 400         450    1.0     268    50                            0.9    21.51        140
* XXX Does not exist in KTBL
sugarbeet.noTill       .normal
sugarbeet.noTill       .midLow
sugarbeet.noTill       .veryLow
* KTBL BP 2024/25 p.454 
summerbeans.org          .normal         319                      1.0                                                  39.95
* KTBL BP 2024/25 p.448, p.67 for pesticide costs
summerbeans.plough       .normal         136               360    1.0     122    31      31                    0.6     23.56
summerbeans.plough       .midLow         136               360    1.0     109    15      12                    0.6     23.56
summerbeans.plough       .veryLow        136               360    1.0      96             6                    0.6     23.56
* KTBL BP 2024/25 p.450, p.67 for pesticide costs
summerbeans.minTill      .normal         136               360    1.0     122    31      31                    0.6     23.56
summerbeans.minTill      .midLow         136               360    1.0     109    15      12                    0.6     23.56
summerbeans.minTill      .veryLow        136               360    1.0      96             6                    0.6     23.56
* KTBL BP 2024/25 p.452, p.67 for pesticide costs
* for midLow, assume  high intensity for  herbicides, as KTBL in default
summerbeans.noTill       .normal         136               360    1.0     122    31      31                    0.6     23.56
summerbeans.noTill       .midLow         136               360    1.0     122    15      12                    0.6     23.56
summerbeans.noTill       .veryLow        136               360    1.0      96             6                    0.6     23.56
* KTBL BP 2024/25 p.466
summerpeas.org          .normal          356.2                    1.0                                                  34.06
*                                        EU/ha   kg        kg      t     EU/ha  EU/ha   EU/ha      EU/ha      m3       EU/ha      kg
*                       %empty%          seed   KAS   PK_18_10   Lime   Herb   Fung   Insect   growthContr   water   hailIns    KaliMag
* KTBL BP 2024/25 p.460, p.67 for pesticide costs
* XXXX Nachbaugebühr is missing, inlcude as cost position or include into seed costs?
summerpeas.plough       .normal          131               300    1.0     122    23     31                     0.3     20.99
summerpeas.plough       .midLow          131               300    1.0     109     5      5                     0.3     20.99
summerpeas.plough       .veryLow         131               300    1.0      96            6                     0.3     20.99 
* KTBL BP 2024/25 p.462, p.67 for pesticide costs
summerpeas.minTill      .normal          131               300    1.0     122    23     31                     0.3     20.99
summerpeas.minTill      .midLow          131               300    1.0     109     5      5                     0.3     20.99
summerpeas.minTill      .veryLow         131               300    1.0      96            6                     0.3     20.99
* KTBL BP 2024/25 p.464, p.67 for pesticide costs
* for midLow, assume  high intensity for  herbicides, as KTBL in default
* error in KTBL, copied water use and hail insurance from plough
summerpeas.noTill       .normal          131               300    1.0     122    23     31                     0.3     20.99
summerpeas.noTill       .midLow          131               300    1.0     122     5      5                     0.3     20.99
summerpeas.noTill       .veryLow         131               300    1.0      96            6                     0.3     20.99
* XXXX NOT IN KTBL, how to deal with this?
alfalfa.org             .normal           97                     40.7
alfalfa.plough          .normal           41               300   10.2    41                                            0.53
alfalfa.plough          .midLow           41               300   10.2    41                                            0.53
alfalfa.plough          .veryLow          41               300   10.2    41                                            0.53

alfalfa.minTill       .normal             41               300   10.2    41                                            0.53
alfalfa.minTill       .midLow             41               300   10.2    41                                            0.53
alfalfa.minTill       .veryLow            41               300   10.2    41                                            0.53
* KTBL BP 2024/25 p.373
* XXXX Nachbaugebühr missing, include as cost position or include into seed costs?
wheatGPS.org          .normal            137.4                    1.0
* KTBL BP 2024/25 p.366, p.67 for pesticide costs (use pesticide costs for Weizen, Winter Weizen)
wheatGPS.plough       .normal            144.4 720         700    1.0    99    130      18       20           0.6     
wheatGPS.plough       .midLow            144.4 720         700    1.0    65     80       6        5           0.6    
wheatGPS.plough       .veryLow           144.4 720         700    1.0    52     41       0        8           0.6    
* KTBL BP 2024/25 p.369, p.67 for pesticide costs (use pesticide costs for Weizen, Winter Weizen)
wheatGPS.minTill      .normal            114.4 720         700    1.0    99    130      18       20           0.6
wheatGPS.minTill      .midLow            114.4 720         700    1.0    65     80       6        5           0.6
wheatGPS.minTill      .veryLow           114.4 720         700    1.0    52     41       0        8           0.6
* KTBL BP 2024/25 p.371, p.67 for pesticide costs (use pesticide costs for Weizen, Winter Weizen)
* for midLow, assume  high intensity for  herbicides, as KTBL in default
wheatGPS.noTill       .normal            114.4 720         700   40.7    99   130       18       20           0.9
wheatGPS.noTill       .midLow            114.4 720         700   40.7    99    80        6        5           0.9
wheatGPS.noTill       .veryLow           114.4 720         700   40.7    52    41        0        8           0.9
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
*[UPDATE TK] ???
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
*  - CAP post 2023 - related sets and parameters
*
**********************************************************************************

   set cropGroupsExceptionGAEC7(cropGroups) /Alfalfa / ;

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
* [UPDATE TK]

 PARAMETER p_inputPrices "Inputs"/
* KTBL BP 24/25 p.714, assumed all same wage rate, used "Lohnansatz"
'Wage rate full time       '.sys     24.00 
'Wage rate half time       '.sys     24.00
'Wage rate flexible hourly '.sys     24.00
* XXXXXXXXXXX
'AHL                       '.'conv'  0.383
'dolophos                  '.sys     0.400
* KTBL BP 24/25 p.66
'ASS                       '.'conv'  0.333
'KAS                       '.'conv'  0.369
'PK_18_10                  '.'conv'  0.307
'KaliMag                   '.'conv'  0.585
* KTBL BP 24/25 p. 66
'Lime                      '.sys     33.92  
* Certain input prices are set to 1 as p_costQuant contains already
* costs per ha
'Herb                      '.sys     1.0
'Fung                      '.sys     1.0
'Insect                    '.sys     1.0
'growthContr               '.sys     1.0
'hailIns                   '.sys     1.0
'seed                      '.'conv'  1.0
* KTBL BP 24/25 p. 71
'water                     '.sys     2
'Diesel                    '.sys     1.15
* Inputs that are also grown on farm,  p_cropPrice * 1.2
'MaizSil                   '."conv"  65.88 
'GrasSil                   '."conv"  91.2
'WinterWheat               '."conv"  326.4
'SummerCere                '."conv"  381.6
'SummerTriticale           '."conv"  200
'MaizCCM                   '."conv"  139.2
'WinterBarley              '."conv"  285.6
'WinterRye                 '."conv"  280.8
* Inputs linked to animals, NOT UPDATED
'ManCatt                   '."conv"  0.001
'ConcCattle1               '."conv"  220.0
'ConcCattle2               '."conv"  230.0
'ConcCattle3               '."conv"  270.0
'milkPowder                '."conv"  2110.0
'OilsForFeed               '."conv"  1150.0
'SoyBeanMeal               '."conv"  338.0
'SoybeanOil                '."conv"  1150.0
'rapeSeedMeal              '."conv"  220.0
'Alfalfa                   '."conv"  180.0
'PlantFat                  '."conv"  1000.0
'MinFu                     '."conv"  700.0
'MinFu2                    '."conv"  700.0
'MinFu3                    '."conv"  700.0
'MinFu4                    '."conv"  700.0
'feedAdd_Bovaer            '.sys     17500.0
'feedAdd_VegOil            '.sys     500.0
'pigletsBought             '.'conv'  48.2
'ManPig                    '.'conv'  0.01
'youngSow                  '.'conv'  570.0
'straw                     '.'conv'  115.0
'Hay                       '.'conv'  132.00
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

  set till/ plough, minTill, noTill, org, silo, bales, hay, graz/;


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
* KTBL BP 24/25 p. 472, plant evalution and herb in same period summarized (2 then), added solidManDist for organic 
* (checked Verfahrensrechner online)
 potatoes     .    soilSample          .  AUG1                               0.2                   0.2
 potatoes     .    basFert             .  AUG1                   1.0         1.0                      
 potatoes     .    solidManDist        .  AUG2                                                     1.0
 potatoes     .    chiselPlow          .  AUG2                               1.0
 potatoes     .    sowmachine          .  AUG2                   1.0         1.0                   1.0
 potatoes     .    mulcher             .  NOV1                   1.0         1.0                   1.0
 potatoes     .    plow                .  NOV1                   1.0                               1.0
 potatoes     .    chiselPlow          .  NOV1                               1.0
* Eggen mit Saatbettkombination
 potatoes     .    rotaryHarrow        .  MAR1                               1.0                   1.0
 potatoes     .    chitting            .  MAR1                                                     1.0
 potatoes     .    NminTesting         .  MAR1                   1.0         1.0
* Why does KTBL has feritlizing in organic?
 potatoes     .    NFert320            .  MAR2                   1.0         1.0                   1.0
 potatoes     .    seedPotatoTransp    .  APR1                   1.0         1.0                   1.0
 potatoes     .    potatoLaying        .  APR1                   1.0         1.0                   1.0
 potatoes     .    rakingHoeing        .  APR2                                                     1.0
 potatoes     .    earthingUp          .  APR2                   1.0         1.0
 potatoes     .    weedValuation       .  MAY1                   1.0         1.0                      
 potatoes     .    herb                .  MAY1                   1.0         1.0                                  
 potatoes     .    plantvaluation      .  JUN2                   1.0         1.0                   1.0
 potatoes     .    herb                .  JUN2                   2.0         2.0                   1.0                   
 potatoes     .    plantvaluation      .  JUL1                   2.0         2.0                      
 potatoes     .    herb                .  JUL1                   2.0         2.0                   1.0
 potatoes     .    plantvaluation      .  JUL2                   1.0         1.0                      
 potatoes     .    herb                .  JUL2                   1.0         1.0                   1.0
 potatoes     .    plantvaluation      .  AUG1                   1.0         1.0                      
 potatoes     .    herb                .  AUG2                   1.0         1.0                   1.0
 potatoes     .    knockOffHaulm       .  AUG2                                                     1.0
 potatoes     .    killingHaulm        .  AUG2                   1.0         1.0
* Reinigen und desinfizieren des Lagers
 potatoes     .    potatoHarvest       .  SEP2                   1.0         1.0                   1.0
 potatoes     .    potatoTransport     .  SEP2                   1.0         1.0                   1.0
* Kartoffeln einlagern
 potatoes     .    potatoStoring       .  SEP2                   1.0         1.0                   1.0
* Kartoffeln auslagern
 potatoes     .    lime_fert           .  OCT1                 0.333       0.333                 0.333
* KTBL BP 24/25 p. 348
*                                                             plough     minTill   noTill          org  silo  bales
 winterWheat  .    soilSample          .  SEP1                   0.2         0.2        0.2        0.2
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
 winterWheat  .    soilSample          .  FEB1                   1.0         1.0        1.0        1.0
 winterWheat  .    plantValuation      .  FEB2                   1.0         1.0        1.0        1.0
 winterWheat  .    NFert320            .  FEB2                   1.0         1.0        1.0
 winterWheat  .    weederLight         .  MAR1                                                     1.0
 winterWheat  .    manDist             .  MAR1                                                     1.0
 winterWheat  .    plantValuation      .  MAR2                   1.0         1.0        1.0
 winterWheat  .    NFert160            .  APR1                   1.0         1.0        1.0
 winterWheat  .    herb                .  APR1                   1.0         1.0        1.0
 winterWheat  .    herb                .  APR2                   1.0         1.0        1.0
 winterWheat  .    plantValuation      .  MAY1                   1.0         1.0        1.0
 winterWheat  .    NFert160            .  JUN1                   1.0         1.0        1.0
 winterWheat  .    herb                .  JUN1                   1.0         1.0        1.0
* Lager vorbereiten
 winterWheat  .    combineCere         .  AUG1                   1.0         1.0        1.0        1.0
 winterWheat  .    cornTransport       .  AUG1                   1.0         1.0        1.0        1.0
* Annehmen, reinigen, Einlagern etc. - not clear, not all steps reflected
 winterWheat  .    store_n_dry_8       .  AUG1                   1.0         1.0        1.0
 winterWheat  .    store_n_dry_4       .  AUG1                                                     1.0
 winterWheat  .    lime_fert           .  AUG2                 0.333       0.333      0.333      0.333
 winterWheat  .    stubble_shallow     .  AUG2                   1.0         1.0                   1.0
 winterWheat  .    stubble_deep        .  SEP2                   1.0         1.0                   1.0

* Leistungs-Kostenrechnung Pflanzenbau 24.09.25 Wintergerste - Futtergerste, wendend, Gülle, ökologisch
* Leistungs-Kostenrechnung Pflanzenbau 24.09.25 Wintergerste - Futtergerste - wendend 
* Leistungs-Kostenrechnung Pflanzenbau 24.09.25 Wintergerste - Futtergerste, nichtwendend, 
* Leistungs-Kostenrechnung Pflanzenbau 24.09.25 Wintergerste - Futtergerste, Direktsaat,
*                                                             plough     minTill   noTill          org  silo  bales
 winterBarley .    soilSample          .  SEP1                   0.2         0.2        0.2        0.2
 winterBarley .    basFert             .  SEP1                   1.0         1.0        1.0
 winterBarley .    chiselPlow          .  SEP1                               1.0
 winterBarley .    herb                .  SEP1                                          1.0
 winterBarley .    plow                .  SEP2                   1.0                               1.0
 winterBarley .    SeedBedCombi        .  SEP2                   1.0                               1.0
 winterBarley .    circHarrowSow       .  SEP2                               1.0
 winterBarley .    sowMachine          .  SEP2                   1.0                               1.0
 winterBarley .    directSowMachine    .  SEP2                                          1.0
 winterBarley .    weedValuation       .  OCT2                   1.0         1.0        1.0
 winterBarley .    herb                .  OCT2                   1.0         1.0        1.0
 winterBarley .    soilSample          .  FEB1                   1.0         1.0        1.0        1.0
 winterBarley .    plantValuation      .  FEB2                   1.0         1.0        1.0        1.0
 winterBarley .    NFert320            .  FEB2                   1.0         1.0        1.0
 winterBarley .    weederLight         .  MAR1                                                     1.0
 winterBarley .    manDist             .  MAR1                                                     1.0
 winterBarley .    plantValuation      .  MAR2                   1.0         1.0        1.0        
 winterBarley .    NFert160            .  APR1                   1.0         1.0        1.0
 winterBarley .    herb                .  APR1                   1.0         1.0        1.0
 winterBarley .    herb                .  APR2                   1.0         1.0        1.0
* Lager vorbereiten
 winterBarley .    combineCere         .  JUL1                   1.0         1.0        1.0        1.0
 winterBarley .    cornTransport       .  JUL1                   1.0         1.0        1.0        1.0
* Annehmen, reinigen, Einlagern etc. - not clear, not all steps reflected
 winterBarley .    store_n_dry_8       .  JUL1                   1.0         1.0        1.0
 winterBarley .    store_n_dry_4       .  JUL1                                                     1.0
 winterBarley .    stubble_shallow     .  JUL2                   1.0         1.0                   1.0
 winterBarley .    lime_fert           .  AUG1                 0.333       0.333      0.333      0.333
 winterBarley .    stubble_deep        .  AUG2                   1.0         1.0                   1.0

* Leistungs-Kostenrechnung Pflanzenbau 24.09.25 Winterroggen - Futterroggen, wendend, 
* Leistungs-Kostenrechnung Pflanzenbau 24.09.25 Winterroggen - Futterroggen, wendend, Gülle, ökologisch
* ?? mintill and notill not in KTBL data, still old data, derive from other cereals?
*                                                             plough     minTill   noTill          org  silo  bales
 winterRye    .    soilSample          .  SEP1                   0.2         0.2        0.2        0.2
 winterRye    .    basFert             .  SEP1                   1.0         1.0        1.0
 winterRye    .    plow                .  SEP2                   1.0                               1.0
 winterRye    .    SeedBedCombi        .  OCT1                   1.0                               1.0
 winterRye    .    sowMachine          .  OCT2                   1.0                               1.0
 winterRye    .    weedValuation       .  OCT2                   1.0         1.0        1.0
 winterRye    .    herb                .  OCT2                   1.0         1.0        1.0
 winterRye    .    weederLight         .  OCT2                                                     1.0
 winterRye    .    soilSample          .  FEB1                   1.0                               1.0
 winterRye    .    plantValuation      .  FEB2                   1.0         1.0        1.0        1.0
 winterRye    .    NFert320            .  FEB2                   1.0         1.0        1.0
 winterRye    .    manDist             .  MAR1                                                     1.0
 winterRye    .    plantValuation      .  MAR2                   1.0         1.0        1.0
 winterRye    .    NFert160            .  APR1                   1.0         1.0        1.0
 winterRye    .    herb                .  APR1                   1.0         1.0        1.0
 winterRye    .    herb                .  APR2                   1.0         1.0        1.0
 winterRye    .    combineCere         .  AUG1                   1.0         1.0        1.0        1.0
 winterRye    .    cornTransport       .  AUG1                   1.0         1.0        1.0        1.0
* for organic, storing steps not included not clear/included
 winterRye    .    store_n_dry_8       .  AUG1                   1.0         1.0        1.0
 winterRye    .    store_n_dry_4       .  AUG1                                                     1.0
 winterRye    .    lime_fert           .  AUG2                 0.333       0.333      0.333      0.333
 winterRye    .    stubble_shallow     .  AUG2                   1.0         1.0                   1.0
 winterRye    .    stubble_deep        .  SEP2                   1.0         1.0                   1.0

 winterRye    .    chiselPlow          .  SEP1                               1.0
 winterRye    .    herb                .  SEP1                                          1.0
 winterRye    .    directSowMachine    .  SEP2                                          1.0
 winterRye    .    circHarrowSow       .  SEP2                               1.0

* KTBL BP 24/25 p. 447
*                                                             plough     minTill   noTill          org  silo  bales
 summerBeans  .    soilSample          .  SEP2                   0.2         0.2        0.2        0.2
 summerBeans  .    basFert             .  OCT1                   1.0         1.0        1.0
 summerBeans  .    plow                .  OCT2                   1.0                               1.0
 summerBeans  .    chiselPlow          .  OCT2                               1.0
 summerBeans  .    springTineHarrow    .  MAR1                                                     1.0
 summerBeans  .    SeedBedCombi        .  MAR1                   1.0                               1.0
 summerBeans  .    sowMachine          .  MAR1                   1.0                               1.0
 summerBeans  .    directSowMachine    .  MAR1                                          1.0
 summerBeans  .    circHarrowSow       .  MAR1                               1.0                    
 summerBeans  .    weedValuation       .  MAR1                   1.0         1.0        1.0        1.0 
 summerBeans  .    herb                .  MAR1                   1.0         1.0        1.0
 summerBeans  .    weederLight         .  MAR1                                                     1.0
 summerBeans  .    weederIntens        .  APR2                                                     1.0
 summerBeans  .    herb                .  MAY2                   1.0         1.0        1.0
* storing stepts not really reflected 
 summerBeans  .    combineCere         .  AUG2                   1.0         1.0        1.0        1.0
 summerBeans  .    cornTransport       .  AUG2                   1.0         1.0        1.0        1.0
 summerBeans  .    store_n_dry_beans   .  AUG2                   1.0         1.0        1.0        1.0
 summerBeans  .    lime_fert           .  SEP1                 0.333       0.333      0.333      0.333
 summerBeans  .    stubble_shallow     .  SEP1                   1.0         1.0                   1.0
 summerBeans  .    stubble_deep        .  OCT1                   1.0         1.0                   1.0

* KTBL BP 24/25 p. 459
*                                                             plough     minTill   noTill          org  silo  bales
 summerPeas   .    soilSample          .  SEP2                   0.2         0.2        0.2        0.2
 summerPeas   .    basFert             .  OCT1                   1.0         1.0        1.0
 summerPeas   .    plow                .  OCT2                   1.0                               1.0
 summerPeas   .    chiselPlow          .  OCT2                               1.0
 summerPeas   .    springTineHarrow    .  MAR1                                                     1.0
 summerPeas   .    SeedBedCombi        .  MAR1                   1.0                               1.0
 summerPeas   .    sowMachine          .  MAR1                   1.0                               1.0
 summerPeas   .    directSowMachine    .  MAR1                                          1.0
 summerPeas   .    circHarrowSow       .  MAR1                               1.0
 summerPeas   .    weederLight         .  MAR1                                                     1.0
 summerPeas   .    weedValuation       .  MAR2                   1.0         1.0        1.0        1.0
 summerPeas   .    herb                .  MAR2                   1.0         1.0        1.0
 summerPeas   .    weederLight         .  MAR2                                                     1.0
* storing stepst not really reflected
 summerPeas   .    combineCere         .  JUL2                   1.0         1.0        1.0        1.0
 summerPeas   .    cornTransport       .  JUL2                   1.0         1.0        1.0        1.0
* ??? Why 0.9 here and not 1.0 like other legumes?
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

* KTBL BP 24/25 p. 379
*                                                             plough     minTill   noTill          org  silo  bales
 summerCere   .    soilSample          .  SEP2                   0.2         0.2        0.2        0.2
 summerCere   .    basFert             .  OCT1                   1.0         1.0        1.0
 summerCere   .    plow                .  OCT2                   1.0                               1.0
 summerCere   .    chiselPlow          .  OCT2                               1.0
 summerCere   .    springTineHarrow    .  MAR1                                                     1.0
 summerCere   .    soilSample          .  FEB2                   1.0         1.0        1.0        1.0
 summerCere   .    herb                .  FEB2                               1.0
 summerCere   .    SeedBedCombi        .  MAR1                   1.0                               1.0
 summerCere   .    sowMachine          .  MAR1                   1.0           0                   1.0
 summerCere   .    directSowMachine    .  MAR1                                          1.0
 summerCere   .    circHarrowSow       .  MAR1                               1.0
 summerCere   .    weederLight         .  MAR1                                                     1.0
 summerCere   .    NFert320            .  MAR1                   1.0         1.0        1.0
 summerCere   .    weedValuation       .  MAR2                   1.0         1.0        1.0
 summerCere   .    herb                .  MAR2                   1.0         1.0        1.0
 summerCere   .    weederLight         .  APR1                                                     1.0
 summerCere   .    plantValuation      .  JUN1                   1.0         1.0        1.0
 summerCere   .    herb                .  JUN1                   1.0         1.0        1.0
* Storaging steps not really reflected
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

* KTBL BP 24/25 p. 366 
* Leistungs-Kostenrechnung Pflanzenbau 24.09.25 - Winterraps, wendend, Gülle
*                                                             plough     minTill   noTill          org  silo  bales
 winterRape   .    soilSample          .  JUL1                   0.2         0.2        0.2           
 winterRape   .    soilSample          .  JUL2                                                     0.2
 winterRape   .    basFert             .  JUL2                   1.0         1.0        1.0
 winterRape   .    plow                .  JUL2                   1.0                                  
 winterRape   .    plow                .  AUG1                                                     1.0
 winterRape   .    chiselPlow          .  JUL2                               1.0
 winterRape   .    SeedBedCombi        .  AUG1                   1.0                                  
 winterRape   .    SeedBedCombi        .  AUG2                                                     1.0
 winterRape   .    herb                .  AUG1                                          1.0
 winterRape   .    sowMachine          .  AUG2                   1.0                               1.0
 winterRape   .    directSowMachine    .  AUG2                                          1.0
 winterRape   .    circHarrowSow       .  AUG2                               1.0
 winterRape   .    weedValuation       .  AUG2                   1.0         1.0        1.0
 winterRape   .    herb                .  AUG2                   1.0         1.0        1.0
 winterRape   .    weederIntens        .  SEP1                                                     1.0
 winterRape   .    weederIntens        .  OCT1                                                     1.0
 winterRape   .    herb                .  OCT2                   1.0         1.0        1.0
 winterRape   .    soilSample          .  JAN1                   1.0         1.0        1.0          
 winterRape   .    soilSample          .  FEB1                                                     1.0
 winterRape   .    plantValuation      .  FEB1                   1.0         1.0        1.0      
 winterRape   .    plantValuation      .  FEB2                                                     1.0
 winterRape   .    NFert320            .  FEB1                   1.0         1.0        1.0
 winterRape   .    plantValuation      .  MAR1                   1.0         1.0        1.0           
 winterRape   .    manDist             .  MAR1                                                     1.0
 winterRape   .    NFert320            .  MAR1                   1.0         1.0        1.0
 winterRape   .    plantValuation      .  APR1                   1.0         1.0        1.0
 winterRape   .    herb                .  APR1                   2.0         2.0        2.0
* Lager vorbereiten missing
 winterRape   .    combineRape         .  JUL2                   1.0         1.0        1.0        1.0
 winterRape   .    cornTransport       .  JUL2                   1.0         1.0        1.0        1.0
* store rape seed summarizes
 winterRape   .    store_n_dry_rape    .  JUL2                   1.0         1.0        1.0        1.0
 winterRape   .    lime_fert           .  JUL2                 0.333       0.333      0.333      0.333
 winterRape   .    stubble_shallow     .  JUL2                   1.0         1.0                   1.0
 winterRape   .    stubble_deep        .  AUG2                   1.0         1.0                   1.0

* KTBL BP 24/25 p. 484 
* NoTill is missing
*                                                             plough     minTill   noTill          org  silo  bales
 sugarbeet    .    soilSample          .  SEP1                   0.2          0.2                  0.2
 sugarbeet    .    basFert             .  OCT1                   1.0          1.0
 sugarbeet    .    plow                .  OCT2                   1.0                               1.0
 sugarbeet    .    chiselPlow          .  OCT2                                1.0
 sugarbeet    .    soilSample          .  FEB2                   1.0          1.0                  1.0
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

* KTBL BP 24/25 p. 394 
* NoTill is missing
*                                                             plough     minTill   noTill          org  silo  bales
 maizCorn     .    soilSample          .  SEP2                   0.2          0.2                  0.2
 maizCorn     .    plow                .  OCT2                   1.0                               1.0
 maizCorn     .    chiselPlow          .  OCT2                                1.0
 maizCorn     .    soilSample          .  MAR2                   1.0          1.0                  1.0
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
* Lager vorbereiten missing
 maizCorn     .    combineMaiz         .  OCT2                   1.0          1.0                  1.0
 maizCorn     .    cornTransport       .  OCT2                   1.0          1.0                  1.0
 maizCorn     .    store_n_dry_corn    .  OCT2                   1.0          1.0                  1.0
 maizCorn     .    lime_fert           .  OCT2                 0.333        0.333                0.333
 maizCorn     .    stubble_shallow     .  OCT2                   1.0          1.0
 maizCorn     .    stubble_deep        .  OCT2                                                     1.0

* KTBL BP 24/25 p. 413 
* Notill and org missing
*                                                             plough     minTill   noTill          org  silo  bales
 maizCCM      .    soilSample          .  SEP2                   0.2          0.2
 maizCCM      .    plow                .  OCT2                   1.0
 maizCCM      .    chiselPlow          .  OCT2                                1.0
 maizCCM      .    soilSample          .  MAR2                   1.0          1.0
 maizCCM      .    manDist             .  APR1                   1.0          1.0
 maizCCM      .    SeedBedCombi        .  APR1                   1.0
 maizCCM      .    rotaryHarrow        .  APR1                                1.0
 maizCCM      .    DiAmmonium          .  APR2                   1.0          1.0
 maizCCM      .    singleSeeder        .  APR2                   1.0          1.0
 maizCCM      .    herb                .  APR2                   1.0          1.0
 maizCCM      .    weedValuation       .  MAY1                   1.0          1.0
 maizCCM      .    herb                .  MAY1                   1.0          1.0
 maizCCM      .    plantValuation      .  MAY2                   1.0          1.0
 maizCCM      .    NFert160            .  MAY2                   1.0          1.0
* Silo reinigen
* ?? same processes as for maizCorn 
 maizCCM      .    combineMaiz         .  SEP2                   1.0          1.0
 maizCCM      .    cornTransport       .  SEP2                   1.0          1.0
 maizCCM      .    grinding            .  SEP2                   1.0          1.0
 maizCCM      .    disposal            .  SEP2                   1.0          1.0
 maizCCM      .    coveringSilo        .  SEP2                   1.0          1.0
 maizCCM      .    lime_fert           .  OCT1                   0.333        0.333
 maizCCM      .    stubble_shallow     .  OCT1                   1.0          1.0

* KTBL BP 24/25 p. 405
* Notill and org missing
*                                                             plough     minTill   noTill          org  silo  bales
 maizSil      .    soilSample          .  SEP2                   0.2          0.2                  0.2
 maizSil      .    basFert             .  OCT1                   1.0          1.0
 maizSil      .    plow                .  OCT2                   1.0                               1.0
 maizSil      .    chiselPlow          .  OCT2                                1.0
 maizSil      .    soilSample          .  MAR2                   1.0          1.0                  1.0
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
* Silo reinigen
* Harvest processes differ from KTBL
 maizSil      .    chopper             .  SEP2                   1.0          1.0                  1.0
 maizSil      .    disposal            .  SEP2                   1.0          1.0                  1.0
 maizSil      .    coveringSilo        .  SEP2                   1.0          1.0
 maizSil      .    lime_fert           .  OCT2                 0.333        0.333                0.333
 maizSil      .    stubble_shallow     .  OCT2                   1.0          1.0                  1.0

* KTBL BP 24/25 p. 365
*                                                             plough     minTill   noTill          org  silo  bales
 wheatGPS     .    soilSample          .  SEP1                   0.2         0.2        0.2        0.2
 wheatGPS     .    basFert             .  SEP1                   1.0         1.0        1.0
 wheatGPS     .    plow                .  SEP2                   1.0                               1.0
 wheatGPS     .    chiselPlow          .  SEP2                               1.0
 wheatGPS     .    herb                .  OCT1                                          1.0 
 wheatGPS     .    SeedBedCombi        .  OCT2                   1.0                               1.0
 wheatGPS     .    sowMachine          .  OCT2                   1.0                               1.0
 wheatGPS     .    directSowMachine    .  OCT2                                          1.0
 wheatGPS     .    circHarrowSow       .  OCT2                               1.0
 wheatGPS     .    weedValuation       .  OCT2                   1.0         1.0        1.0
 wheatGPS     .    herb                .  OCT2                   1.0         1.0        1.0
 wheatGPS     .    weederLight         .  NOV1                                                     1.0
 wheatGPS     .    soilSample          .  FEB2                   1.0         1.0        1.0        1.0
 wheatGPS     .    plantValuation      .  FEB2                   1.0         1.0        1.0        1.0
* Error in KTBL - assumes mineral N for organic, chaged to mandist 
 wheatGPS     .    manDist             .  FEB2                                                     1.0
 wheatGPS     .    NFert320            .  MAR1                   1.0         1.0        1.0
 wheatGPS     .    weederLight         .  MAR1                                                     1.0
 wheatGPS     .    plantValuation      .  MAR2                   1.0         1.0        1.0
 wheatGPS     .    NFert160            .  APR1                   1.0         1.0        1.0
 wheatGPS     .    herb                .  APR1                   1.0         1.0        1.0
* Silo reinigen fehlt
* Harvest processes differ from KTBL
 wheatGPS     .    chopper             .  JUN2                   1.0         1.0        1.0        1.0
 wheatGPS     .    disposal            .  JUN2                   1.0         1.0        1.0        1.0
 wheatGPS     .    lime_fert           .  JUL1                   0.333       0.333      0.333      0.333
 wheatGPS     .    stubble_shallow     .  JUL1                   1.0         1.0                   1.0
 wheatGPS     .    stubble_deep        .  AUG2                   1.0         1.0                   1.0
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


Execute_unload "C:/Users/LennartKokemohr/Documents/FarmDyn/Clean_Swizz/dat//crops_de_default.gdx"
* Sets
                             m, crops,arableCrops,biogas_feed, cashCrops,ccCrops,cere,cereFeedsPigGDX,leg,maize,maizSilage,no_CashCrops,rootCrops,Wintercere,summercere,potatoes,
                             sugarbeet, rapeseed,summerHarvest, winterCrops,GPS, grain_Wheat, grain_barley, grain_rye, grain_maize, maizccm, grain_Oat OtherGrains, grainleg, monthGrowthCrops,
                             crop_residues,cropsResidues_prods, feed_ccCrops, feed, cropGroups, feedAttr,monthHarvestBlock, monthHarvestCrops, resiEle, cropsResidueRemo, roughages,
                             other, hay, vegetables,inputs, cropGroupsExceptionGAEC7, p_crop_op_per_tilla,
* Parameters
                             p_storageLoss,p_nutContent, p_organicYieldMult, p_nfromLegumes, p_maxRotShare,p_costQuant,p_NrespFunct, p_nMin,p_residue_ratio
                             p_cropResi,p_efLeachFert,p_monthAfterLeg, p_humCrop,p_feedContDMg,p_feedAttrPig,p_nutCont,p_Yieldlevel,p_cropPrice,p_addN,p_redN ,p_NNeed
                             p_cropGroups_to_crops, p_efa, p_crop,p_dryMatterCrop,p_fugCrop,p_totNCrop, p_shareNTAN, p_cropYield, p_cerealUnit, p_orgDryMatterCrop,
                             p_resiInc, p_inputPrices, p_changeOpIntens, p_inputQuant;
