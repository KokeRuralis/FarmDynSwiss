
********************************************************************************
$ontext

   CAPRI project

   GAMS file : CROPOP_DE.GMS

   @purpose  :
   @author   :
   @date     : 11.03.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************
$onMulti
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


 set op_rf(operation,labReqLevl) "Link between operation and available field working days requirement level"/
*
*    --- see page 245ff in KTBL 2012/13
*


*                     soilSample
                      manDist                   .rf3
                      basFert                   .(rf2,rf3)
                      plow                      .rf3
                      chiselPlow                .rf3
                      seedBedCombi              .(rf2,rf3)
                      herb                      .(rf2,rf3)
                      sowMachine                .(rf2,rf3)
                      directSowMachine          .(rf2,rf3)
                      circHarrowSow             .(rf2,rf3)
                      springTineHarrow          .(rf2,rf3)
*                     weedValuation
                      weederLight               .(rf2,rf3)
                      weederIntens              .(rf2,rf3)
*                     plantvaluation
                      NFert320                  .(rf2,rf3)
                      NFert160                  .(rf2,rf3)
*                     combine
*                     cornTransport
*                     store_n_dry_8
*                     store_n_dry_4
*                     store_n_dry_rape
                      lime_fert                 .(rf2,rf3)
                      stubble_shallow           .rf3
                      stubble_deep              .rf3
                      rotaryHarrow              .(rf2,rf3)
*                     NminTesting
                      mulcher                   .(rf2,rf3)
                      chitting                  .(rf2,rf3)
                      solidManDist              .rf3
*                     seedPotatoTransp
                      potatoLaying              .(rf2,rf3)
                      rakingHoeing              .(rf2,rf3)
                      earthingUp                .(rf2,rf3)
                      knockOffHaulm             .(rf2,rf3)
                      killingHaulm              .(rf2,rf3)
                      potatoHarvest             .(rf2,rf3)
*                     potatoTransport
*                     potatoStoring
               /;



$iftheni.data "%database%"=="KTBL_database"
* ****
*
* --- Sets/Parameters for operations required for KTBL crops
*
*
   sets
      items            "operation attributes by KTBL (resource requirements)"
      stats            "regression coefficients"
      amount           "amount of inputs and outputs (e.g. water, seeds transported)"
      amountUnit       "amountUnit of inputs and outputs"
      operationID      "KTBL-ID of an operation"
      opType           "Type of a operation (e.g. soilSample)"
      operation_opType "assigns a operationType to each operation"
      operationID_operation(operationID,operation) "crossset linking ID to name of operation"
      crops_operationID(crops,sys,till,operationID,labperiod,amount,actmachVar) "operations required for crop production, subject to sys, till and machVar"

;

*
* load regression parameters, input requirements of operation
*
      parameter p_noRegCoeff(operationID,Amount,soil,items)
                p_RegCoeff(operationID,Amount,soil,items,stats)
                p_crops_operationID(crops,sys,till,operationID,labperiod,amount,amountUnit,machVar) "frequency of operations required for crop production, subject to sys, till and machVar"
;

   $$GDXIN '%datDir%/cropop_ktbl.gdx'
      $$LOAD  amount amountUnit items stats
      $$onmulti
         $$LOAD operation
         $$LOAD operationID opType operation_opType
         $$LOAD  crops_operationID operationID_operation
         $$LOAD  p_noRegCoeff,p_RegCoeff,p_crops_operationID
         $$LOAD  op_rf
      $$offmulti
   $$GDXIN
$endif.data
   $$onmulti
      set items /nPers/;
   $$offmulti


 table op_attr(operation,machVar,rounded_plotsize,opAttr) "resource requirements of operations"

                                                labTime         diesel      fixCost      varCost   nPers  amount
    soilSample                .67kw."2"          0.2              0.5          1.05         0.30
    manDist                   .67kw."2"          1.7              6.7         20.20        24.65
    basFert                   .67kw."2"          0.25             0.9          2.04         2.11
*
*   --- page 153, KTBL 2010/2011
*
    plow                      .67kw."2"          1.89            23.0         20.39        40.76
    chiselPlow                .67kw."2"          1.09            15.1          9.02        22.92
    SeedBedCombi              .67kw."2"          0.58             6.0          7.98        12.05
    sowMachine                .67kw."2"          0.84             4.9          9.44        10.62
    directSowMachine          .67kw."2"          0.71             6.5         23.01        22.59
    circHarrowSow             .67kw."2"          1.29            12.9         16.96        27.16
    springTineHarrow          .67kw."2"          0.75             7.3          6.56        13.60
    weedValuation             .67kw."2"          0.16             0.3          1.59         0.35
    herb                      .67kw."2"          0.28             1.0          4.37         3.25
    weederLight               .67kw."2"          0.42             2.6          3.93         6.22
    weederIntens              .67kw."2"          0.73             3.8         13.10         9.70
    plantValuation            .67kw."2"          0.13             0.1          0.91         0.18
    NFert320                  .67kw."2"          0.23             0.9          1.75         1.95
    NFert160                  .67kw."2"          0.19             0.8          1.16         1.58
    lime_fert                 .67kw."2"          0.48             3.6         12.54         6.51
    combineCere               .67kw."2"          1.20            20.8         66.43        31.94
    combineRape               .67kw."2"          1.25            22.83        86.11        40.73
    combineMaiz               .67kw."2"          1.32            23.99       115.57        54.54
    cornTransport             .67kw."2"          0.23             0.8          5.28         3.41
    store_n_dry_8             .67kw."2"          1.29                        100.81        29.28
    store_n_dry_4             .67kw."2"          0.64                         50.41        14.64
    store_n_dry_beans         .67kw."2"          0.47                         33.42        11.56
    store_n_dry_rape          .67kw."2"          0.64                         49.38        40.52
    store_n_dry_corn          .67kw."2"          1.50                        107.36       255.20
*
*   --- page 152 KBL 2010/2011
*
    stubble_shallow           .67kw."2"          0.85             8.4          7.54        16.59
    stubble_deep              .67kw."2"          0.92             9.8          7.99        18.04
*
*--- KTBL 12/13 S. 420 [TK,24.07.13]
*
    rotaryHarrow              .67kw."2"          1.17            9.40           8.27       22.06
    NminTesting               .67kw."2"          0.51            0.18           1.32        0.34
    mulcher                   .67kw."2"          1.40            8.39          14.51       20.59
    chitting                  .67kw."2"          2.36                         481.82       97.80
    solidManDist              .67kw."2"          1.61           10.88          32.73       30.99
    seedPotatoTransp          .67kw."2"          0.26            0.94           2.77        2.72
    potatoLaying              .67kw."2"          1.19           11.84          23.94       31.60
    rakingHoeing              .67kw."2"          0.73            4.12          11.65       10.80
    earthingUp                .67kw."2"          0.70            3.49           7.67       10.03
    knockOffHaulm             .67kw."2"          1.92            8.41          22.24       23.46
    killingHaulm              .67kw."2"          0.23            1.15           5.48        3.09
    potatoHarvest             .67kw."2"         19.94           55.23         189.53      133.98      3
    potatoTransport           .67kw."2"          1.61            5.37          31.63       22.82
*
*   --- fix costs covered by potaStore type buildings
*
    potatoStoring             .67kw."2"        10.00                                     148.50


*
*---  KTBL 12/13 S.437 und 445  (BL 10.02.2014)
*
   singleSeeder               .67kw."2"         1.0            4.26           28.3        18.39
   weederHand                 .67kw."2"        71.52           0.35           1.26         1.09
   uprootBeets                .67kw."2"         4.41          49.73         149.98       134.33

*
*---  KTBL 12/13 S.348  (BL 10.02.2014)
*
   DiAmmonium                 .67kw."2"        0.16            0.65           0.86        1.48
   grinding                   .67kw."2"                                                     84
   disposal                   .67kw."2"         0.7            3.57           4.19        7.55
*---  KTBL 14/15 S.331  (WB 27.07.2016)
*  coveringSilo               .67kw.2ha         4.2                         265.15       60.61
   coveringSilo               .67kw."2"         4.2                         000.00       60.61

*     H?cksler wird bei KTBL nur als Dienstleistung gef?hrt, nicht zur Eigenanschaffung
*
   chopper                    .67kw."2"                                                    410
*
*---  KTBL 14/15 S.453 (CP 28.02.2018)
*
*                                               labTime         diesel      fixCost      varCost   nPers  amount
   mowing                     .67Kw."2"         0.64            5.47          8.48         11.39
   tedding                    .67kw."2"         0.43            2.78          3.56          6.88
   raking                     .67kw."2"         0.51            3.12          4.45          8.02
   silageTrailer              .67kw."2"                                                    98.00           11.9
   closeSilo                  .67kw."2"         1.09                         69.42         15.87
   grasReSeeding              .67kw."2"         0.27            2.07          3.63          4.44
   roller                     .67kw."2"         0.34            1.72          3.91          4.36
*---  KTBL 14/15 S.458 (Silage)/S.515 (Hay) (CP 27.02.2018)
*---  Ballenpressen mit Wickeln wird bei KTBL als Dienstleistung aufgeführt
   balePressWrap              .67kw."2"                                                   240.00           11.9
*---  Copied, data not found
   balePressHay               .67kw."2"                                                   240.00           11.9
   baleTransportSil           .67kw."2"         1.65            3.29         21.66         16.27           11.9
   baleTransportHay           .67kw."2"         1.62            3.02         15.45         14.19            4.8
;

* --- Alfalfa contract work
   op_attr("alfalfaHarvDry","67kw","2","varCost") = 170 * p_cropYieldInt("Alfalfa","conv");

*
*--- taken from KTBL, "Verfahrensuebersicht", e.g. potatoes KTBL 2012/13, p. 418-419
*--- Herbizid, fungizid, insecticide summed up as herb [TK]
*--- not yet in FARMDYN included: hoe, mulcher and cropSprayer;  potatoes need storage and boxes, front bucket for fork lift not included [TK, 24.07.13]
*--- Catch crops are taken from KTBL Homepage, "Kurzscheibenegge" replace bei springTimeHarrow; seeding is moved from JUL1 to AUG2 to prevent overlapping with other crops
*

   parameter p_crop_op_per_tilla(crops,operation,labperiod,till);


set grasTill(till) /noTill, silo, bales, hay, graz/;

* --- Read in operations as defined by User


$iftheni.data "%database%" == "User_database"
   $$GDXIN '%datDir%/%cropsFile%.gdx'
     $$load p_crop_op_per_tilla
   $$GDXIN
$endif.data


   p_crop_op_per_tilla("CCmustard","springtineHarrow","Aug2","plough")= 1;
   p_crop_op_per_tilla("CCmustard","springtineHarrow","Aug2","org")= 1;
   p_crop_op_per_tilla("CCmustard","roller","Aug2","plough")= 1;
   p_crop_op_per_tilla("CCmustard","roller","Aug2","org")= 1;
   p_crop_op_per_tilla("CCmustard","SeedBedCombi","Aug2","plough")= 1;
   p_crop_op_per_tilla("CCmustard","seedBedCombi","Aug2","org")= 1;
   p_crop_op_per_tilla("CCmustard","springtineHarrow","Feb2","plough")= 1;
   p_crop_op_per_tilla("CCmustard","springtineHarrow","Feb2","org")= 1;

   p_crop_op_per_tilla("CCClover","springtineHarrow","Aug2","plough")= 1;
   p_crop_op_per_tilla("CCClover","springtineHarrow","Aug2","org")= 1;
   p_crop_op_per_tilla("CCClover","roller","Aug2","plough")= 1;
   p_crop_op_per_tilla("CCClover","roller","Aug2","org")= 1;
   p_crop_op_per_tilla("CCClover","SeedBedCombi","Aug2","plough")= 1;
   p_crop_op_per_tilla("CCClover","seedBedCombi","Aug2","org")= 1;
   p_crop_op_per_tilla("CCClover","chopper","Feb2","plough")= 1;
   p_crop_op_per_tilla("CCClover","chopper","Feb2","org")= 1;
   p_crop_op_per_tilla("CCClover","chopper","Feb2","minTill")= 1;
   p_crop_op_per_tilla("CCClover","springtineHarrow","Feb2","plough")= 1;
   p_crop_op_per_tilla("CCClover","springtineHarrow","Feb2","org")= 1;


   p_crop_op_per_tilla(grasscrops,"soilSample","Sep2",grasTill)    $ (not sameas(grasscrops,"idleGras")) = 0.25;
   p_crop_op_per_tilla(grasscrops,"weederlight","Mar2",grasTill)   $ (not sameas(grasscrops,"idleGras")) = 0.25;
   p_crop_op_per_tilla(grasscrops,"sowMachine","Mar2",grasTill)    $ (not sameas(grasscrops,"idleGras")) = 0.75;
   p_crop_op_per_tilla(grasscrops,"grasReSeeding","Apr1",grasTill) $ (not sameas(grasscrops,"idleGras")) = 0.25;
   p_crop_op_per_tilla(grasscrops,"roller","Apr1",grasTill)        $ (not sameas(grasscrops,"idleGras")) = 0.25;

*
* crop operation requirements of a crop per month, subject to sys,till and amount
*
$iftheni.data "%database%" == "KTBL_database"
   parameter p_crop_op_per_tillaKTBL(Crops,operation,labperiod,till,amount) "operations required for crop production";
             p_crop_op_per_tillaKTBL(curCrops,operation,labperiod,till,amount) =sum((actMachVar,operationID,sys,amountUnit), p_crops_operationID(curCrops,sys,till,operationID,labperiod,amount,amountUnit,actmachVar)
                                                                                $(operationID_operation(operationID,operation)));




$endif.data

 set op_machType(operation,machType) "Links the operations to machinery";
* was ist mit dem Trecker? muss nicht f�r jeden Arbeitsgang auch noch der Traktor zu den
* Arbeitsg�ngen verlinkt werden? oder ist das woanders schon mit Treckeranspr�chen pro ha und Frucht abgegolten?
* Die Kosten f�r Trecker in den Arbeitsg�ngen sind ja durch KTBL Angaben zu var und fixCost schon abgegolten, aber die
* Treckerstunden evtl. nicht die die Nutzungsdauer beeinflussen (BL 10.02.2014)

 op_machType("plow","plough")                                  = yes;
 op_machType("chiselplow","chiselPlough")                      = yes;
 op_machType("stubble_shallow","chiselPlough")                 = yes;
 op_machType("stubble_deep","chiselPlough")                    = yes;
 op_machType("seedBedCombi","seedBedCombi")                    = yes;
 op_machType("springTineHarrow","springTineHarrow")            = yes;
 op_machType("circHarrowSow","circHarrow")                     = yes;
 op_machType("circHarrowSow","sowMachine")                     = yes;
 op_machType("sowMachine","sowMachine")                        = yes;
 op_machType("directSowMachine","directSowMachine")            = yes;
 op_machType("combineCere","combine")                          = yes;
 op_machType("combineCere","cuttingUnitCere")                  = yes;
 op_machType("combineRape","combine")                          = yes;
 op_machType("combineRape","cuttingUnitCere")                  = yes;
 op_machType("combineRape","cuttingAddRape")                   = yes;
 op_machType("combineMaiz","combine")                          = yes;
 op_machType("combineMaiz","cuttingUnitMaiz")                  = yes;
 op_machType("rotaryHarrow","rotaryHarrow")                    = yes;
 op_machType("seedPotatoTransp","threeWayTippingTrailer")      = yes;
 op_machType("seedPotatoTransp","forkLiftTruck")               = yes;
 op_machType("potatoLaying","potatoPlanter")                   = yes;
 op_machType("earthingUp","ridger")                            = yes;
 op_machType("knockOffHaulm","haulmCutter")                    = yes;
 op_machType("potatoHarvest","potatoLifter")                   = yes;
 op_machType("potatoTransport","threeWayTippingTrailer")       = yes;
 op_machType("basFert","fertSpreaderSmall")                    = yes;
 op_machType("herb","Sprayer")                                 = yes;
 op_machType("Nfert160","fertSpreaderSmall")                   = yes;
 op_machType("Nfert320","fertSpreaderSmall")                   = yes;
 op_machType("mulcher","mulcher")                              = yes;
 op_machType("weederLight","fingerHarrow")                     = yes;
 op_machType("weederIntens","hoe")                             = yes;

 op_machType("singleSeeder","singleSeeder")                    = yes;
 op_machType("uprootBeets","beetHarvester")                    = yes;
 op_machType("DiAmmonium","fertSpreaderSmall")                 = yes;
 op_machType("lime_fert","fertSpreaderLarge")                  = yes;
 op_machType("cornTransport","threeWayTippingTrailer")         = yes;
* H�cksler(Chopper) ist bei KTBL nur Dienstleisung, somit nicht Teil des Maschinenparks
 op_machType("chopper","chopper")                              = yes;

 op_machType("tedding","rotaryTedder")                         = yes;
 op_machType("raking","rake")                                  = yes;
 op_machType("mowing","mowerConditioner")                      = yes;
 op_machType("closeSilo","closeSilo")                          = yes;
 op_machType("silageTrailer","silageTrailer")                  = yes;
 op_machType("grasReSeeding","grasReSeedingUnit")              = yes;
 op_machType("roller","roller")                                = yes;
 op_machType("baleTransportSil","threeWayTippingTrailer")      = yes;
 op_machType("baleTransportHay","threeWayTippingTrailer")      = yes;
* Ballenpresse/Wickler (balePressWrap) ist bei KTBL nur Dienstleisung, somit nicht Teil des Maschinenparks
*op_machType("balePressWrap","balePressWrap")                  = yes;
*op_machType("balePressHay","balePressHay")                    = yes;

 op_machType(operation,machType) $ (not p_machAttr(machType,"price")) = no;

$iftheni.data "%database%"=="KTBL_database"
   $$GDXIN '%datDir%/cropop_ktbl.gdx'
      $$onmulti
      $$LOAD op_machType
      $$offmulti
    $$GDXIN
$endif.data

*
* --- changes in # of field operations / intensity of operation depending on intensity level
*
 p_changeOpIntens(curCrops,operation,labperiod,intens) = 1;

$iftheni.data "%database%" == "User_database"
   parameter p_changeOP(crops,operation,labperiod,intens);
   $$GDXIN "%datdir%/%cropsFile%.gdx"
      $$load p_changeOP=p_changeopIntens
   $$GDXIN
    p_changeOPIntens(curCrops,operation,labPeriod,intens) = p_changeOP(curCrops, operation,labPeriod,intens);
$endif.data



* --- see page 250 KTBL 2010/2011 for winter cereals
*
*     Describe effect of plot size and mechanisation (= work width) on time, variable and fix
*     machinery costs and diesel.
*     plot size effect currently only for crops not included in KTBL database (e.g. gras, AEM catchcrops)
*     currently not considered for fertilization
*    idle only used as placeholder (data refers to winterwheat, but winterwheat is now included in KTBL database)

  table p_plotSizeEffect(crops,machVar,opAttr,rounded_plotSize)

                            "1"    "2"   "5"  "20"

     idle. 67kw .labTime    12.4   10.5   9.3   8.0
     idle. 67kw .diesel       90     83    78    73
     idle. 67kw .varCost     205    188   176   168
     idle. 67kw .fixCost     282    258   241   231

     idle.102kw .labTime    11.1    9.1   7.6   6.8
     idle.102kw .diesel       95     86    78    74
     idle.102kw .varCost     209    188   172   164
     idle.102kw .fixCost     315    284   262   249

     idle.200kw .labTime    11.9    8.6   6.3   4.9
     idle.200kw .diesel      118     99    84    75
     idle.200kw .varCost     240    201   173   157
     idle.200kw .fixCost     396    334   292   267
  ;

   p_plotSizeEffect("idle","45kW",opAttr,rounded_plotSize)=p_plotSizeEffect("idle","67kW",opAttr,rounded_plotSize);
   p_plotSizeEffect("idle","83kW",opAttr,rounded_plotSize)=p_plotSizeEffect("idle","67kW",opAttr,rounded_plotSize);
   p_plotSizeEffect("idle","120kW",opAttr,rounded_plotSize)=p_plotSizeEffect("idle","102kW",opAttr,rounded_plotSize);
   p_plotSizeEffect("idle","230kW",opAttr,rounded_plotSize)=p_plotSizeEffect("idle","200kW",opAttr,rounded_plotSize);


   p_plotSizeEffect("idle",machVar,"nPers",rounded_plotSize) = 1;
   p_plotSizeEffect("idle",machVar,"amount",rounded_plotSize) = 1;
