
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
                      loadinghaytractor       "Heuaufladen mit Ladewagen an Traktor"
                      mowingtwoaxle           "Maehen mit Zweiachsmäher mit Rotationsmähwerk"
                      teddingtwoaxle          "Zetten mit Zweiachsmäher mit Kreiselheuer"
                      rakingtwoaxle           "Schwaden mit Zweiachsmäher"
                      loadinghaytransporter   "Heuaufladen mit Hecklader auf Transporter"
                      mowingmotormower        "Maehen mit Motormäher"
                      rakingleafblower        "Zetten mit Laubbläser"
                      teddingmotormower       "Schwaden mit Motormäher"
                      mowinggras              "Mähen ohne Maehaufbereiter"
                      loadingrastractor       "Grasaufladen mit Ladewagen an Traktor"
                      loadinggrastransporter  "Grasaufladen mit Hecklader auf Transporter"

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
    soilSample                .67kw."2"          0.20             1.68         3.66         4.11
    manDist                   .67kw."2"          0.75             6.30        36.86        25.01
    basFert                   .67kw."2"          0.50             4.20        15.36        13.20
*
*   --- page 153, KTBL 2010/2011
*
    plow                      .67kw."2"          1.61           13.55         94.62        75.40
    chiselPlow                .67kw."2"          2.86           24.00         76.80        64.85
    SeedBedCombi              .67kw."2"          0.83            7.00         90.36        66.46
    sowMachine                .67kw."2"          0.61            5.12         53.25        26.17
    directSowMachine          .67kw."2"          0.67            5.60         61.60        37.69
    circHarrowSow             .67kw."2"          1.29           12.90         31.03        49.69
    springTineHarrow          .67kw."2"          0.63            5.32         45.14        25.67
    weedValuation             .67kw."2"          0.16            1.34          2.93         3.29
    herb                      .67kw."2"          0.28            2.35         24.43        12.99
    weederLight               .67kw."2"          0.70            5.91         26.03        19.50
    weederIntens              .67kw."2"          0.80            6.72         39.23        31.96
    plantValuation            .67kw."2"          0.13            1.09          2.38         2.67
    NFert320                  .67kw."2"          0.23            0.90          3.20         3.57
    NFert160                  .67kw."2"          0.19            0.80          2.12         2.89
    lime_fert                 .67kw."2"          0.48            3.60         22.94        11.91
    combineCere               .67kw."2"          0.75           16.92        169.09        54.48
    combineRape               .67kw."2"          0.75           16.92        169.09        54.48
    combineMaiz               .67kw."2"          0.75           16.92        169.09        54.48
    cornTransport             .67kw."2"          0.86            7.20         38.87        25.17
    store_n_dry_8             .67kw."2"          1.29            0           184.44        29.28
    store_n_dry_4             .67kw."2"          0.64            0            92.23        14.64
    store_n_dry_beans         .67kw."2"          0.47            0            61.14        11.56
    store_n_dry_rape          .67kw."2"          0.64            0            90.34        40.52
    store_n_dry_corn          .67kw."2"          1.50            0           196.42       466.90
*
*   --- page 152 KBL 2010/2011
*
    stubble_shallow           .67kw."2"          0.84            7.06         42.01        25.89
    stubble_deep              .67kw."2"          0.92            9.80         14.62        33.00
*
*--- KTBL 12/13 S. 420 [TK,24.07.13]
*
    rotaryHarrow              .67kw."2"          1.09            9.13          80.36       41.33
    NminTesting               .67kw."2"          0.51            0.18           2.41        0.62
    mulcher                   .67kw."2"          1.15            9.65          38.24       39.61
    chitting                  .67kw."2"          2.36            0            881.51      178.93
    solidManDist              .67kw."2"          2.86           24.00          82.56      103.09
    seedPotatoTransp          .67kw."2"          0.20            1.68          36.54       20.36
    potatoLaying              .67kw."2"          1.00            8.40         161.16       78.34
    rakingHoeing              .67kw."2"          0.25            2.10          21.31        9.55
    earthingUp                .67kw."2"          1.00            8.40          52.52       44.54
    knockOffHaulm             .67kw."2"          1.67           14.00         110.15       66.43
    killingHaulm              .67kw."2"          2.50           21.00          74.21      528.00
    potatoHarvest             .67kw."2"         10.00               0         888.25      455.60
    potatoTransport           .67kw."2"          3.00           25.20          57.12       74.67
*
*   --- fix costs covered by potaStore type buildings
*
    potatoStoring             .67kw."2"        10.00                0              0      271.89


*
*---  KTBL 12/13 S.437 und 445  (BL 10.02.2014)
*
   singleSeeder               .67kw."2"         0.96           8.08          76.79        41.63
   weederHand                 .67kw."2"        71.52           0              0          522.03
   uprootBeets                .67kw."2"         4.00          33.60         277.90       269.76

*
*---  KTBL 12/13 S.348  (BL 10.02.2014)
*
   DiAmmonium                 .67kw."2"        1.00            8.40          24.79       23.54
   grinding                   .67kw."2"          0                0              0      153.68
   disposal                   .67kw."2"         0.7            5.88          18.02       18.72
*---  KTBL 14/15 S.331  (WB 27.07.2016)
*  coveringSilo               .67kw.2ha         4.2                         265.15       60.61
   coveringSilo               .67kw."2"         4.2                0        485.10      110.89

*     H?cksler wird bei KTBL nur als Dienstleistung gef?hrt, nicht zur Eigenanschaffung
*
   chopper                    .67kw."2"        1.00            8.40         130.14       63.67
*
*---  KTBL 14/15 S.453 (CP 28.02.2018)
*
*                                               labTime         diesel      fixCost      varCost   nPers  amount
   mowing                     .67Kw."2"         0.50            4.20         40.81         25.27
   tedding                    .67kw."2"         0.36            3.00         15.79         11.75
   raking                     .67kw."2"         0.55            4.59         20.70         15.35
   silageTrailer              .67kw."2"            0               0            0         179.30           11.9
   closeSilo                  .67kw."2"         1.09               0        127.01         29.03
   grasReSeeding              .67kw."2"         0.91            7.64         32.16         26.47
   roller                     .67kw."2"         0.33            2.77         26.80          8.78
   
   loadinghaytractor          .67Kw."2"         0.4             3.36         27.70         15.35 
   mowingtwoaxle              .67Kw."2"         0.73            6.13         33.81         23.36
   teddingtwoaxle             .67Kw."2"         0.36            3.00         19.09         11.73
   rakingtwoaxle              .67Kw."2"         0.77            6.46         33.94         23.12
   loadinghaytransporter      .67Kw."2"         0.33            2.80         34.81         74.94 
   mowingmotormower           .67Kw."2"                                      54.55         45.26
   rakingleafblower           .67Kw."2"                                       2.6
   teddingmotormower          .67Kw."2"         0.20            1.68         19.93         14.32
   mowinggras                 .67Kw."2"         0.50            4.20         28.11         20.48
   loadingrastractor          .67Kw."2"         0.40            3.36         27.02         32.84
   loadinggrastransporter     .67Kw."2"         0.33            2.80         34.81         94.16

*---  KTBL 14/15 S.458 (Silage)/S.515 (Hay) (CP 27.02.2018)
*---  Ballenpressen mit Wickeln wird bei KTBL als Dienstleistung aufgeführt
   balePressWrap              .67kw."2"         0.51            4.32         50.56         36.64           11.9
*---  Copied, data not found
   balePressHay               .67kw."2"         0.78            6.55         68.44         48.78           11.9
   baleTransportSil           .67kw."2"         0.80            6.75         64.42         31.92           11.9
   baleTransportHay           .67kw."2"         1.22           10.24         97.75         40.45            4.8
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


set grasTill(till) /noTill, grasSil, grasSilM, hay, hayM, hayExt,gras, grasM, graz/;

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
*
* --- list of oprations for which no tractor is needed
*
  op_machType(operation,"tractor") $ (not ( sameas(operation,"combineCere")
                                         or sameas(operation,"CombineRape")
                                         or sameas(operation,"CombineMaiz")
                                         or sameas(operation,"forkLiftTruck")
                                         or sameas(operation,"chopper")
                                         or sameas(operation,"potatoStoring")
                                         or sameas(operation,"silageTrailer")
                                         or sameas(operation,"grinding")
                                    $$iftheni.data "%database%" == "KTBL_database"
                                         or (sum(operationID $(operationID_operation(operationID,operation)),1))
                                    $$endif.data
                                         ))       = Yes;
  op_machType("soilSample",   "tractor")      = NO;
  op_machType("weedValuation","tractor")      = NO;
  op_machType("coveringSilo","tractor")       = NO;
  op_machType("closeSilo","tractor")          = NO;
  op_machType("plantValuation","tractor")     = NO;
  op_machType("weedValuation","tractor")      = NO;
  op_machType("store_n_dry_4","tractor")      = NO;
  op_machType("store_n_dry_beans","tractor")  = NO;
  op_machType("store_n_dry_8","tractor")      = NO;
  op_machType("store_n_dry_rape","tractor")   = NO;

  op_machType(operation,"tractor") $ op_machType(operation,"tractorSmall") = No;


* --- Fertilization and plant protection
  op_machType(operation,"tractorSmall") $ op_machType(operation,"fertSpreaderSmall")       = YES;
  op_machType(operation,"tractorSmall") $ op_machType(operation,"sprayer")                 = YES;
  op_machType(operation,"tractorSmall") $ op_machType(operation,"threeWayTippingTrailer")  = YES;
  op_machType("basFert","fertSpreaderSmall")                    = yes;
  op_machType("herb","Sprayer")                                 = yes;
  op_machType("Nfert160","fertSpreaderSmall")                   = yes;
  op_machType("Nfert320","fertSpreaderSmall")                   = yes;
  op_machType("DiAmmonium","fertSpreaderSmall")                 = yes;
  op_machType("lime_fert","fertSpreaderLarge")                  = yes;
  op_machType("manDist","tractorSmall")              = YES;


  op_machType("plow","plough")                                  = yes;
  op_machType("chiselplow","chiselPlough")                      = yes;
  op_machType("stubble_shallow","chiselPlough")                 = yes;
  op_machType("stubble_deep","chiselPlough")                    = yes;
  op_machType("seedBedCombi","seedBedCombi")                    = yes;
  op_machType("springTineHarrow","springTineHarrow")            = yes;
  op_machType("circHarrowSow","circHarrow")                     = yes;
  op_machType("circHarrowSow","sowMachine")                     = yes;
  op_machType("sowMachine","tractorSmall")           = YES;
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
  op_machType("mulcher","mulcher")                              = yes;
  op_machType("weederLight","fingerHarrow")                     = yes;
  op_machType("weederIntens","hoe")                             = yes;
  op_machType("earthingUp","tractorSmall")           = YES;
  op_machType("rotaryHarrow","tractorSmall")         = YES;
  op_machType("singleSeeder","tractorSmall")         = YES;
 
  op_machType("singleSeeder","singleSeeder")                    = yes;
  op_machType("uprootBeets","beetHarvester")                    = yes;
  op_machType("cornTransport","threeWayTippingTrailer")         = yes;
* H�cksler(Chopper) ist bei KTBL nur Dienstleisung, somit nicht Teil des Maschinenparks
  op_machType("chopper","chopper")                              = yes; 
  op_machType("weederLight","tractorSmall")          = YES;
  op_machType("mulcher","tractorSmall")              = YES;
  op_machType("knockOffHaulm","tractorSmall")        = YES;

***********************************************************************************************************************
*
*
* Hallo Ihr Lieben; ab hier bitte einmal checken. 
* Das Crossset op_machType verbindet operations (das erste in Klammern mit Maschinen als zweites Element)
* Die Grünlandmaschinen sollten hier drunter abgedeckt sein;
*
***********************************************************************************************************************
  op_machType("roller","tractorSmall")                          = YES;
  op_machType("roller","roller")                                = yes;

  op_machType("grasReSeeding","tractorSmall")                   = yes;
  op_machType("grasReSeeding","grasReSeedingUnit")              = yes;
  
  op_machType("mowing","tractorSmall")                          = YES;
  op_machType("mowing","mowerConditioner")                      = yes;

  op_machType("tedding","tractorSmall")                         = YES;
  op_machType("tedding","rotaryTedder")                         = yes;

  op_machType("raking","tractorSmall")                          = YES;
  op_machType("raking","rake")                                  = yes;
  
  op_machType("closeSilo","closeSilo")                          = yes;
  op_machType("silageTrailer","silageTrailer")                  = yes;

  op_machType("baleTransportSil","threeWayTippingTrailer")      = yes;
  op_machType("baleTransportHay","threeWayTippingTrailer")      = yes;

  op_machType("loadinghaytractor","tractorSmall")     = yes;
  op_machType("loadinghaytractor","loaderWagon")      = yes;

  op_machType("mowingtwoaxle","twoaxleMower")           = yes;
  op_machType("mowingtwoaxle","mowerConditioner")       = yes;

  op_machType("teddingtwoaxle","twoaxleMower")          = yes;
  op_machType("teddingtwoaxle","rotaryTedder")          = yes;

  op_machType("rakingtwoaxle","rakeTwoAxle")            = yes;
  op_machType("rakingtwoaxle","twoaxleMower")           = yes;

  op_machType("loadinghaytransporter","transportMountain")      = yes;

  op_machType("mowingmotormower","singleAxleMower")      = yes;
  op_machType("mowingmotormower","cuttingbarSAxle") = yes;

  op_machType("rakingleafblower","leafBlower")           = yes;
  op_machType("teddingmotormower","bandrakeSingleAxle")  = yes;
  op_machType("teddingmotormower","singleAxleMower")     = yes;

  op_machType("loadingrastractor","loaderWagon")            = yes;
  op_machType("loadinggrastransporter","transportMountain") = yes;

* Hier endet das set.
*************************************************************************************************************************
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
