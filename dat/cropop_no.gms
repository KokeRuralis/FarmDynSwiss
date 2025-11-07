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



 table op_attr(operation,machVar,plotSize,opAttr)

                                                labTime         diesel      fixCost      varCost   nPers  amount
    soilSample                .67kw.2ha         0.2              0.5          1.05         0.30
    manDist                   .67kw.2ha         1.7              6.7         20.20        24.65
    basFert                   .67kw.2ha         0.25             0.9          2.04         2.11
*
*   --- page 153, KTBL 2010/2011
*
    plow                      .67kw.2ha         1.89            23.0         20.39        40.76
    chiselPlow                .67kw.2ha         1.09            15.1          9.02        22.92
    SeedBedCombi              .67kw.2ha         0.58             6.0          7.98        12.05
    sowMachine                .67kw.2ha         0.84             4.9          9.44        10.62
    directSowMachine          .67kw.2ha         0.71             6.5         23.01        22.59
    circHarrowSow             .67kw.2ha         1.29            12.9         16.96        27.16
    springTineHarrow          .67kw.2ha         0.75             7.3          6.56        13.60
    weedValuation             .67kw.2ha         0.16             0.3          1.59         0.35
    herb                      .67kw.2ha         0.28             1.0          4.37         3.25
    weederLight               .67kw.2ha         0.42             2.6          3.93         6.22
    weederIntens              .67kw.2ha         0.73             3.8         13.10         9.70
    plantValuation            .67kw.2ha         0.13             0.1          0.91         0.18
    NFert320                  .67kw.2ha         0.23             0.9          1.75         1.95
    NFert160                  .67kw.2ha         0.19             0.8          1.16         1.58
    lime_fert                 .67kw.2ha         0.48             3.6         12.54         6.51
    combineCere               .67kw.2ha         1.20            20.8         66.43        31.94
    combineRape               .67kw.2ha         1.25            22.83        86.11        40.73
    combineMaiz               .67kw.2ha         1.32            23.99       115.57        54.54
    cornTransport             .67kw.2ha         0.23             0.8          5.28         3.41
    store_n_dry_8             .67kw.2ha         1.29                        100.81        29.28
    store_n_dry_4             .67kw.2ha         0.64                         50.41        14.64
    store_n_dry_beans         .67kw.2ha         0.47                         33.42        11.56
    store_n_dry_rape          .67kw.2ha         0.64                         49.38        40.52
    store_n_dry_corn          .67kw.2ha         1.50                        107.36       255.20
*
*   --- page 152 KBL 2010/2011
*
    stubble_shallow           .67kw.2ha         0.85             8.4          7.54        16.59
    stubble_deep              .67kw.2ha         0.92             9.8          7.99        18.04
*
*--- KTBL 12/13 S. 420 [TK,24.07.13]
*
    rotaryHarrow              .67kw.2ha         1.17            9.40           8.27       22.06
    NminTesting               .67kw.2ha         0.51            0.18           1.32        0.34
    mulcher                   .67kw.2ha         1.40            8.39          14.51       20.59
    chitting                  .67kw.2ha         2.36                         481.82       97.80
    solidManDist              .67kw.2ha         1.61           10.88          32.73       30.99
    seedPotatoTransp          .67kw.2ha         0.26            0.94           2.77        2.72
    potatoLaying              .67kw.2ha         1.19           11.84          23.94       31.60
    rakingHoeing              .67kw.2ha         0.73            4.12          11.65       10.80
    earthingUp                .67kw.2ha         0.70            3.49           7.67       10.03
    knockOffHaulm             .67kw.2ha         1.92            8.41          22.24       23.46
    killingHaulm              .67kw.2ha         0.23            1.15           5.48        3.09
    potatoHarvest             .67kw.2ha        19.94           55.23         189.53      133.98      3
    potatoTransport           .67kw.2ha         1.61            5.37          31.63       22.82
*
*   --- fix costs covered by potaStore type buildings
*
    potatoStoring             .67kw.2ha        10.00                                     148.50


*
*---  KTBL 12/13 S.437 und 445  (BL 10.02.2014)
*
   singleSeeder               .67kw.2ha         1.0            4.26           28.3        18.39
   weederHand                 .67kw.2ha        71.52           0.35           1.26         1.09
   uprootBeets                .67kw.2ha         4.41          49.73         149.98       134.33

*
*---  KTBL 12/13 S.348  (BL 10.02.2014)
*
   DiAmmonium                 .67kw.2ha        0.16            0.65           0.86        1.48
   grinding                   .67kw.2ha                                                     84
   disposal                   .67kw.2ha         0.7            3.57           4.19        7.55
*---  KTBL 14/15 S.331  (WB 27.07.2016)
*  coveringSilo               .67kw.2ha         4.2                         265.15       60.61
   coveringSilo               .67kw.2ha         4.2                         000.00       60.61

*     H?cksler wird bei KTBL nur als Dienstleistung gef?hrt, nicht zur Eigenanschaffung
*
   chopper                    .67kw.2ha                                                    410
*
*---  KTBL 14/15 S.453 (CP 28.02.2018)
*
*                                               labTime         diesel      fixCost      varCost   nPers  amount
   mowing                     .67Kw.2ha         0.64            5.47          8.48         11.39
   tedding                    .67kw.2ha         0.43            2.78          3.56          6.88
   raking                     .67kw.2ha         0.51            3.12          4.45          8.02
   silageTrailer              .67kw.2ha                                                    98.00           11.9
   closeSilo                  .67kw.2ha         1.09                         69.42         15.87
   grasReSeeding              .67kw.2ha         0.27            2.07          3.63          4.44
   roller                     .67kw.2ha         0.34            1.72          3.91          4.36
*---  KTBL 14/15 S.458 (Silage)/S.515 (Hay) (CP 27.02.2018)
*---  Ballenpressen mit Wickeln wird bei KTBL als Dienstleistung aufgeführt
   balePressWrap              .67kw.2ha                                                   240.00           11.9
*---  Copied, data not found
   balePressHay               .67kw.2ha                                                   240.00           11.9
   baleTransportSil           .67kw.2ha         1.65            3.29         21.66         16.27           11.9
   baleTransportHay           .67kw.2ha         1.62            3.02         15.45         14.19            4.8
;

* --- Alfalfa contract work
op_attr("alfalfaHarvDry","67kw","2ha","varCost") = 170 * p_cropYieldInt("Alfalfa","Yield");


op_attr(operation,machVar,plotSize,"varCost")  =  op_attr(operation,machVar,plotSize,"varCost") *  %EXR%;
op_attr(operation,machVar,plotSize,"fixCost")  =  op_attr(operation,machVar,plotSize,"fixCost") *  %EXR%;

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

 CCmustard    .    springTineHarrow    .  AUG2                   1.0                               1.0
 CCmustard    .    roller              .  AUG2                   1.0                               1.0
 CCmustard    .    SeedBedCombi        .  AUG2                   1.0                               1.0
 CCmustard    .    springTineHarrow    .  FEB2                   1.0                               1.0

 CCclover     .    springTineHarrow    .  AUG2                   1.0                               1.0
 CCclover     .    roller              .  AUG2                   1.0                               1.0
 CCclover     .    SeedBedCombi        .  AUG2                   1.0                               1.0
 CCclover     .    chopper             .  FEB2                   1.0          1.0                  1.0
 CCclover     .    springTineHarrow    .  FEB2                   1.0                               1.0



*                                                             plough     minTill   noTill          org  silo  bales  hay      graz
*
* --- definition of basic field operations for graslands
*
 set.gras     .    soilSample          .  SEP2                                      0.25                 0.25  0.25   0.25    0.25
 set.gras     .    weederlight         .  MAR2                                      0.25                 0.25  0.25   0.25    0.25
 set.gras     .    sowMachine          .  MAR2                                      0.75                 0.75  0.75   0.75    0.75
 set.gras     .    grasReSeeding       .  APR1                                      0.25                 0.25  0.25   0.25    0.25
 set.gras     .    roller              .  APR1                                      0.25                 0.25  0.25   0.25    0.25
 ;



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

*
* --- changes in # of field operations / intensity of operation depending on intensity level
*
 p_changeOpIntens(curCrops,operation,labperiod,intens) = 1;

 p_changeOpIntens(curCrops("winterWheat"),"herb","MAY1",lower)             = 0;
 p_changeOpIntens(curCrops("winterWheat"),"herb","JUN1",lower)             = 0.5;

 p_changeOpIntens(curCrops("winterWheat"),"nFert160","JUN1",lower)         = 0.5;
 p_changeOpIntens(curCrops("winterWheat"),"combineCere","AUG1",lower)      = 0.94;
 p_changeOpIntens(curCrops("winterWheat"),"cornTransport","AUG1",lower)    = 0.94;
 p_changeOpIntens(curCrops("winterWheat"),"store_n_dry_8","AUG1",lower)    = 0.92;

 p_changeOpIntens(curCrops("winterWheat"),"herb","MAY1",veryLow)           = 0;
 p_changeOpIntens(curCrops("winterWheat"),"herb","JUN1",veryLow)           = 0;
 p_changeOpIntens(curCrops("winterWheat"),"nFert160","JUN1",veryLow)       = 0;
 p_changeOpIntens(curCrops("winterWheat"),"combineCere","AUG1",veryLow)    = 0.86;
 p_changeOpIntens(curCrops("winterWheat"),"cornTransport","AUG1",veryLow)  = 0.86;
 p_changeOpIntens(curCrops("winterWheat"),"store_n_dry_8","AUG1",veryLow)  = 0.84;

 p_changeOpIntens(curCrops("winterBarley"),"herb","MAY1",lower)            = 0;
 p_changeOpIntens(curCrops("winterBarley"),"herb","JUN1",lower)            = 0.5;

 p_changeOpIntens(curCrops("winterBarley"),"nFert160","JUN1",lower)        = 0.5;
 p_changeOpIntens(curCrops("winterBarley"),"combineCere","AUG1",lower)     = 0.94;
 p_changeOpIntens(curCrops("winterBarley"),"cornTransport","AUG1",lower)   = 0.94;
 p_changeOpIntens(curCrops("winterBarley"),"store_n_dry_8","AUG1",lower)   = 0.92;

 p_changeOpIntens(curCrops("winterBarley"),"herb","MAY1",veryLow)          = 0;
 p_changeOpIntens(curCrops("winterBarley"),"herb","JUN1",veryLow)          = 0;
 p_changeOpIntens(curCrops("winterBarley"),"nFert160","JUN1",veryLow)      = 0;
 p_changeOpIntens(curCrops("winterBarley"),"combineCere","AUG1",veryLow)   = 0.86;
 p_changeOpIntens(curCrops("winterBarley"),"cornTransport","AUG1",veryLow) = 0.86;
 p_changeOpIntens(curCrops("winterBarley"),"store_n_dry_8","AUG1",veryLow) = 0.84;

 p_changeOpIntens(curCrops("winterRye"),"herb","APR2",lower)            = 0;
 p_changeOpIntens(curCrops("winterRye"),"herb","OCT2",lower)            = 0.5;

 p_changeOpIntens(curCrops("winterRye"),"nFert160","APR1",lower)        = 0.5;
 p_changeOpIntens(curCrops("winterRye"),"combineCere","AUG1",lower)     = 0.94;
 p_changeOpIntens(curCrops("winterRye"),"cornTransport","AUG1",lower)   = 0.94;
 p_changeOpIntens(curCrops("winterRye"),"store_n_dry_8","AUG1",lower)   = 0.92;

 p_changeOpIntens(curCrops("winterRye"),"herb","OCT2",veryLow)          = 0;
 p_changeOpIntens(curCrops("winterRye"),"herb","APR2",veryLow)          = 0;
 p_changeOpIntens(curCrops("winterRye"),"nFert160","APR1",veryLow)      = 0;
 p_changeOpIntens(curCrops("winterRye"),"combineCere","AUG1",veryLow)   = 0.86;
 p_changeOpIntens(curCrops("winterRye"),"cornTransport","AUG1",veryLow) = 0.86;
 p_changeOpIntens(curCrops("winterRye"),"store_n_dry_8","AUG1",veryLow) = 0.84;


 p_changeOpIntens(curCrops("SummerTriticale"),"combineCere","JUL2",lower)     = 0.94;
 p_changeOpIntens(curCrops("SummerTriticale"),"cornTransport","JUL2",lower)   = 0.92;
 p_changeOpIntens(curCrops("SummerTriticale"),"store_n_dry_8","JUL2",lower)   = 0.92;
 p_changeOpIntens(curCrops("SummerTriticale"),"combineCere","JUL2",veryLow)   = 0.86;
 p_changeOpIntens(curCrops("SummerTriticale"),"cornTransport","JUL2",veryLow) = 0.86;
 p_changeOpIntens(curCrops("SummerTriticale"),"store_n_dry_8","JUL2",veryLow) = 0.84;

 p_changeOpIntens(curCrops("summerCere"),"combineCere","JUL2",lower)     = 0.94;
 p_changeOpIntens(curCrops("summerCere"),"cornTransport","JUL2",lower)   = 0.92;
 p_changeOpIntens(curCrops("summerCere"),"store_n_dry_8","JUL2",lower)   = 0.92;
 p_changeOpIntens(curCrops("summerCere"),"combineCere","JUL2",veryLow)   = 0.86;
 p_changeOpIntens(curCrops("summerCere"),"cornTransport","JUL2",veryLow) = 0.86;
 p_changeOpIntens(curCrops("summerCere"),"store_n_dry_8","JUL2",veryLow) = 0.84;

 p_changeOpIntens(curCrops("winterRape"),"herb","APR1",lower)   = 0;
 p_changeOpIntens(curCrops("winterRape"),"herb","APR1",veryLow) = 0;
 p_changeOpIntens(curCrops("winterRape"),"herb","MAY1",veryLow) = 0;

 p_changeOpIntens(curCrops("winterRape"),"combineRape","JUL2",lower)        = 0.94;
 p_changeOpIntens(curCrops("winterRape"),"combineRape","JUL2",veryLow)      = 0.86;
 p_changeOpIntens(curCrops("winterRape"),"cornTransport","JUL2",lower)      = 0.94;
 p_changeOpIntens(curCrops("winterRape"),"cornTransport","JUL2",veryLow)    = 0.86;
 p_changeOpIntens(curCrops("winterRape"),"store_n_dry_rape","JUL2",lower)   = 0.92;
 p_changeOpIntens(curCrops("winterRape"),"store_n_dry_rape","JUL2",veryLow) = 0.84;

*
* --- see page 250 KTBL 2010/2011 for winter cereals
*
*     Describe effect of plot size and mechanisation (= work width) on time, variable and fix
*     machinery costs and diesel.
*
  table p_plotSizeEffect(crops,machVar,opAttr,plotSize)

                                    1ha    2ha   5ha  20ha

     winterWheat. 67kw .labTime    12.4   10.5   9.3   8.0
     winterWheat. 67kw .diesel       90     83    78    73
     winterWheat. 67kw .varCost     205    188   176   168
     winterWheat. 67kw .fixCost     282    258   241   231

     winterWheat.102kw .labTime    11.1    9.1   7.6   6.8
     winterWheat.102kw .diesel       95     86    78    74
     winterWheat.102kw .varCost     209    188   172   164
     winterWheat.102kw .fixCost     315    284   262   249

     winterWheat.200kw .labTime    11.9    8.6   6.3   4.9
     winterWheat.200kw .diesel      118     99    84    75
     winterWheat.200kw .varCost     240    201   173   157
     winterWheat.200kw .fixCost     396    334   292   267
  ;

  p_plotSizeEffect("winterWheat",machVar,"nPers",plotSize) = 1;
  p_plotSizeEffect("winterWheat",machVar,"amount",plotSize) = 1;
