********************************************************************************
$ontext

   FARMDYN project

   GAMS file : MACH.GMS

   @purpose  : Define lifietime of machinery, investment costss and machenery needs
               for crops
   @author   : Bernd Lengers, Wolfgang britz, Finn Timcke
   @date     : 13.11.10, 06.07.20
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************
$iftheni.mode "%1"=="decl"

    set set_machType /tractor
                      tractorSmall
                      plough                  "Pflug"
                      chiselPlough            "Schwergrubber"
                      sowMachine              "Saemaschine"
                      directSowMachine        "Direktsaemaschine"
                      seedBedCombi            "Saatbeetkombination"
                      circHarrow              "Scheibenegge"
                      springTineHarrow        "Federzinkenegge"
                      fingerHarrow            "Hackstriegel"
                      combine                 "Maehdrescher"
                      cuttingUnitCere         "Getreideschneidwerk"
                      cuttingAddRape          "Zusatzausruestung Rapsernte"
                      cuttingUnitMaiz         "Maispflueckeinrichtung fuer Maehdrescher"
                      rotaryHarrow            "Kreiselegge"
                      mulcher                 "Mulcher"
                      potatoPlanter           "Kartoffellegegeraet"
                      potatoLifter            "Kartoffelroder"
                      hoe                     "Hackmachine, 5-reihig"
                      ridger                  "Haeufler"
                      haulmCutter             "Krautschlaeger"
                      forkLiftTruck           "Gabelstapler"
                      threeWayTippingTrailer  "Dreiseitenkippanhaenger"
                      Sprayer                 "Feldspritze"
                      singleSeeder            "Einzelkornsaehgeraet (Rueben/Mais)"
                      beetHarvester           "Ruebenroder"
                      fertSpreaderSmall       "Duengerstreuer, 0.8cbm"
                      fertSpreaderLarge       "Duengerstreuer, 4.0cbm"
                      chopper                 "Feldhaecksler"
                      cornHeader              "Maisgebiss fuer Haecksler"
                      mowerConditioner        "Maehaufbereiter"
                      grasReseedingUnit       "Gasnachsaemaschine"
                      rotaryTedder            "Kreiselzettwender"
                      rake                    "Schwader"
                      roller                  "Walze"
                      silageTrailer           "Silage trailer, service"
                      balePressWrap           "Baler and bale wrapper, service"
                      balePressHay            "Baler"
                      closeSilo

                      manbarrel
                      draghose
                      injector
                      trailingshoe

                      solidManDist            "Miststreuer"
                      frontLoader             "Frontlader"
                      siloBlockCutter         "Siloblockschneider"
                      shearGrab               "Schneidzange"
                      dungGrab                "Dungzange"
                      fodderMixingVeh8        "Futtermischwagen,  8m3, horizontale Schnecke, mit Befuellschild"
                      fodderMixingVeh10       "Futtermischwagen, 10m3, vertikale Schnecke, mit Befuellschild"
                      fodderMixingVeh16       "Futtermischwagen, 16m3, 2 vertikale Schnecken, mit Befuellschild"
 /;

 set set_stables_to_mach(stables,set_machType) /

               (motherCowSmall,motherCowLarge) .(siloBlockCutter,shearGrab,frontLoader,dungGrab)

               (milk30,milk60,milk90)         .(siloBlockCutter,frontLoader,dungGrab)
               (milk120)                      .(frontLoader,dungGrab,fodderMixingVeh8)
               (milk240)                      .(frontLoader,dungGrab,fodderMixingVeh8)

               (set.youngStables) .(siloBlockCutter,shearGrab,frontLoader,dungGrab)

 /;



$else.mode


$onmulti

 table p_machAttr(machType,machAttr)

*
* --- Data from "KTBL 2014/2015" und "�konomie Agroscope Transfer | Nr. 291 / 2019 Maschinenkosten 2019 G�ltig bis September 2020"
*
*
* --- KTBL. 82, 4 Schare, 140 cm, Agroscope Code 4023
*
                      price        hour       ha       m3     t     varCost_ha  varCost_t  varCost_h  diesel_h  fixCost_h  fixCost_t years varCost_m3
 Plough               29000                 1100                        39.55
*
* --- KTBL. 84, Schwergrubber, angebaut, 2.5m, Agroscope Code 4004
*
 ChiselPlough          9400                 1600                         7.34
*
* --- KTBL. 85, Federzinkenegge, angebaut, 4.5m, Agroscope Code 4039
*
 springTineHarrow      12000                 1600                         9.38
*
* --- KTBL. 100, Hackstriegel, 4.5m, Agroscope Code 5081
*
 fingerHarrow          8900                 2000                         4.01
*
* --- KTBL. 85, saatbeetkombi, 4,5 m, Agroscope Code ???? (5060) --> Simon Hug: 5067 Zapfwellenegge + Sämaschine
*
 seedBedCombi         76000                 1600                         49.88
*
* --- KTBL. 86, Kurzscheibenegge, 3 m, Agroscope Code 4034
*
 circHarrow           23000                 2000                         12.65
*
* --- KTBL. 97, mechanic sowing machine, 3 m, Agroscope Code 5002
*hugs_15.04.21 --> Variable Kosten von 9 auf 9.75 angepasst gemäss Maschinenkostenkatalog
 sowMachine           15000                 1000                         9.75
*
* --- KTBL.2012/13 98, direct sow machine, 3m, 1800 l, Agroscope Code 5005
*
 directSowMachine     72000                 3000                        21.6
*
*  Cropsprayer , bezieht sich auf m3, bestehend aus Beh�lter und Spritzgest�nge
*                    Anbaupflanzenschutzspritze, 15 m 1000 l, 67 kW
* --- KTBL. 101+102, crop sprayer in hitch. 1000 l, 15m sprayer boom, Agroscope Code 5154
* cropSprayer
*
    Sprayer           23500                 4000                        5.88
*
* mulcher   (Abgeleitet aus M�hwerksangaben, da keine Mulcher in KTBL 2012/13 vorhanden, S.103, 2,8m Rotationsm�hwerk, Heckanbau), Agroscope Code ??? (14021)
*
  mulcher             6200                  3850                        1.7
*
* --- KTBL. 100, hoe (Hackmaschine 5-reihig), Agroscope Code 5123
*
  hoe                 14500                  800                         65.25
*
* --- KTBL S. 89, Kreiselegge 2,5 m angebaut, Agroscope Code 4055
*
 rotaryHarrow         14500                  800                         17.22
*
*---  KTBL S.100, Kartoffellegemaschine mite starrem Bunker, 4-reihig, 1,2 t, Agroscope Code 5044
*
 potatoPlanter        28000                 500                        47.6
*
*---  KTBL S. 112, Kartoffelbunkerroder angeh�ngt 1-reihig 4 t, Agroscope Code 8012
*
 potatoLifter         88000                  220                        340.0
*
*---  KTBL S. 100, Kartoffelh�ufer mit Dammformer, 4-reihig, Agroscope Code 5102
*
 ridger                15500                 1200                         15.5
*
*---  KTBL 12/13 S. 113, Kartoffelkrautschl�ger 2-reihig 45 kW, Agroscope Code 8001
*
 haulmCutter           13500                 250                         35.1

*
*--- KTBL S.98   Einzelkornlegeger�t (Mais, R�ben) 4-reihig, 3m, Agroscope Code 5021
*

 singleSeeder          22000                1000                          7.7
*
*--- KTBL 12/13 S.92   D�ngerstreuer  (Schleuderstreuer Angebaut, 800 L)
*                from (t to ha using 1 t per ha), Agroscope Code 6004

 fertSpreaderSmall      6600                2400                         2.75
*
*--- KTBL 12/13 S.92   D�ngerstreuer  (Schleuderstreuer, angh�ng,t 40 km/h, 4000 l)
*                from (t to ha using 3 t per ha, lime_fert), Agroscope Code 6005
*
 fertSpreaderLarge     20000       3600                                  4.17
*
*--- KTBL 12/13 S.109 Feldh�cksler 250kw mit 4,5m Maisgebiss S.110(als Dienstleistung, muss hier also nicht rein), Agroscope Code 9185
*                   Fixcost are derived by dividing yearly fix costs by total lifetime in hours by # of years

chopper                235000     3000                                                        64.11     43.6      94.3
*chopper                           3000                                                        64.11     43.6      94.3

 cornHeader            110000                800                          96.25

*
*--- KTBL S.113   R�benroder (K�pfrodebunker, 2-reihig,gezogen 67KW), Agroscope Code 8063
*                    Fixcost are derived by dividing yearly fix costs by total lifetime in hours by # of years

 beetHarvester         136000                 1000                        190.4

*
*---  KTBL S. 78, Dreiseitenkipper zweiachsig, 14 t, Agroscope Code 3022
*
*     As for tractor, fix costs per t are derived by: a*Fix costs pro a/t Leistung
*     40000 t with 0.0375 hour/t = 1500 hour life time
*
*
threeWayTippingTrailer 37000      1500                       75000                   0.76       5.3               14.65

*
*--- KTBL S. 70, Frontgabelstapler, 3t Dieselmotor, Agroscope Code 1105
*
 forkLiftTruck         24000      10000                                                          8.69
*
*                     price        hour       ha       m3     t     varCost_ha  varCost_t  varCost_h  diesel_h  fixCost_h  fixCost_t years varCost_m3
*
* --- KTBL.12/13 S.65, tractor    (67kw), Agroscope Code 1005
*
*    Fixcost are derived by dividing yearly fix costs by total lifetime in hours by # of years
*
 tractorSmall          90000     10000                                                          19.9       14.95
*
* --- KTBL.12/13 S.65, tractor    (54kw), Agroscope Code 1002
*
*    Fixcost are derived by dividing yearly fix costs by total lifetime in hours by # of years
*
 tractor               51000     10000                                                          12.84      8.76
*
* --- KTBL combine S.112 mit Getreideschneidwerk 4,5m, Rapstisch 4,5m und Maispfl�cker 4-reihig S.111
*
*    150 kw, 7000 , Agroscope Code ????
*
 combine             151000       3000                                                          36.12     27.3      58.20
 cuttingUnitCere      19500                 2800                         5.0
 cuttingAddRape        8900                 1500                         1.0
 cuttingUnitMaiz      34000                  800                        18.0
*
* --- KTBL S. 103, Rotationsm�hwerk mit M�haufbereiung, Heckanbau 2,4 m, Agroscope Code 9002
*
 mowerConditioner    11500                  1000                         8.05
*
* --- KTBL S. 105, Kreiselzettwender, 4,5 m, Agroscope Code 9041
*
 rotaryTedder        8600                   1600                         4.03
*
* --- KTBL S. 102, Kreiselschwader  , 3,5 m, Agroscope Code 9062
*
 rake                9800                   2400                         3.68
*
* --- KTBL S. 88, Glattwalze 3m, Agroscope Code ??? 4072
*
 roller              6100                   3000                         2.34
*hugs: alte Werte    2450                   3000                         0.20
* --- KTBL S. 99, Grasnachs�maschine, 2.5 m, Agroscope Code ???
*
 grasReSeedingUnit  14500                   2500                         2.35
*
*                     price        hour       ha       m3     t     varCost_ha  varCost_t  varCost_h  diesel_h  fixCost_h  fixCost_t years varCost_m3
*
* --- KTBL S.119, Siloblockschneider 3m�, Agroscope Code 10045
*
 siloBlockCutter     18000                         20000                                                                                    0.90
*
* --- KTBL S.76, Schneidzange       2m�, Agroscope Code 2017
*
 shearGrab           5200          5000                                                       2.39
*
* --- KTBL S.71, Fontlader   1750 daN, Agroscope Code 2011
*
 frontLoader         9500          5000                                                       3.23
*
* --- KTBL S.74, Dungzange 1.25m3, Agroscope Code 2014
*
 dungGrab            1750          5000                                                       1.75
*
* --- KTBL S.121, Futtermischwagen, horizontale Schnecke, 8m3, Agroscope Code 10031
*
 fodderMixingVeh8   36000                          56000                                                                                      0.45
*
* --- KTBL S.117, Futtermischwagen, vertikale Schnecke, 10m3, Agroscope Code 10032
*
 fodderMixingVeh10  44000                          80000                                                                                      0.358
*
* --- KTBL 10/11, S.117, Futtermischwagen, vertikale Schnecke, 16m3, Agroscope Code 10035
*
 fodderMixingVeh16  63000                          160000                                                                                     0.236
*
* --- KTBL 14/15, S.107, Rundballenpresse 1.2m Festkammer, Agroscope Code 9124
*                                                  1.4m3*30000Rb = 42000m3?                                                                   1.61/1.4m3 =1.15/m3
balePressHay        52000                          42000                                                                                      1.15
;

* --- according to KTBL2010 S.98 for ....in kg N
*
*     i.e. 6000 ha * 200 kg N (?)
  p_machAttr ("sprayer","m3")  =   6000*200;

* --- according to KTBL 2014/15 S.95 for 12m� barrel 120000m� lifetime

  p_lifeTimeM("manbarrel","m3")=  120000;

* --- according to KTBL 2014/15 S.96 f�r 15m draghose 62000m� lifetime

  p_lifeTimeM("draghose","m3") =  150000;

* --- according to KTBL 2014/15 S.96 for 6m working width 25000m� lifetlime

  p_lifeTimeM("injector","m3") =  6000;

* --- according to KTBL 2014/15 S.92 for 6m-12m working width, 22.5t max weight, 78400 t lifetlime (1t muck eq 1.2 m3)

  p_lifeTimeM("solidManDist","m3") =  78400 * 1.2;

* --- according to KTBL 2014/15 S.96 for 4.5m working widht 18750m3 lifetime

  p_lifeTimeM("trailingshoe","m3") =  4500;


  p_machAttr(machType,"varcost_h") $ p_machAttr(machType,"diesel_h")
   = p_machAttr(machType,"varcost_h") - p_machAttr(machType,"diesel_h")*0.9;

*
*  ---- calculate variable cost per year where depreciation is calculated per year,
*       and afterwards delete variable cost per unit of use
*

  p_machAttr(machType,"varCost_year") $ (p_machAttr(machType,"m3")  $ p_machAttr(machType,"years"))
     = p_machAttr(machType,"m3") * p_machAttr(machType,"varCost_m3") / p_machAttr(machType,"years");


  p_machAttr(machType,"varCost_year") $ (p_machAttr(machType,"hour")  $ p_machAttr(machType,"years"))
     = p_machAttr(machType,"hour") * p_machAttr(machType,"varCost_h") / p_machAttr(machType,"years");


  p_machAttr(machType,"varcost_year") $ (p_machAttr(machType,"t")  $ p_machAttr(machType,"years"))
     = p_machAttr(machType,"t") * p_machAttr(machType,"varCost_t") / p_machAttr(machType,"years");


  p_machAttr(machType,"varcost_year") $ (p_machAttr(machType,"ha")  $ p_machAttr(machType,"years"))
     = p_machAttr(machType,"ha") * p_machAttr(machType,"varCost_ha") / p_machAttr(machType,"years");

  p_machAttr(machType,"varCost_m3")  $ p_machAttr(machType,"years") = 0;
  p_machAttr(machType,"varCost_h")   $ p_machAttr(machType,"years") = 0;
  p_machAttr(machType,"varCost_t")   $ p_machAttr(machType,"years") = 0;
  p_machAttr(machType,"varCost_ha")  $ p_machAttr(machType,"years") = 0;

* --- according to KTBL 2014/15 p. 95 & 96

  p_priceMach("manbarrel",t)    = 29000 * ([1+%outputPriceGrowthRate%/100]**t.pos);
  p_priceMach("draghose",t)     = 20500 * ([1+%outputPriceGrowthRate%/100]**t.pos);
  p_priceMach("injector",t)     = 25500 * ([1+%outputPriceGrowthRate%/100]**t.pos);
  p_priceMach("trailingshoe",t) = 19000 * ([1+%outputPriceGrowthRate%/100]**t.pos);
  p_priceMach("solidManDist",t) = 67000 * ([1+%outputPriceGrowthRate%/100]**t.pos);

* --- deprecation of machines not included in KTBL-regression
$iftheni.data "%database%" == "KTBL_database"
  p_machAttr(machType,"depCost_ha")    $ (p_machAttr(machType,"ha")   $ (not (sum(machTypeID $ machTypeID_machType(machTypeID,machType),1)))) = ( p_machAttr(machType,"price")/p_machAttr(machType,"ha"));
  p_machAttr(machType,"depCost_hour")  $ (p_machAttr(machType,"hour") $ (not (sum(machTypeID $ machTypeID_machType(machTypeID,machType),1)))) = ( p_machAttr(machType,"price")/p_machAttr(machType,"hour"));
$else.data
  p_machAttr(machType,"depCost_ha")    $ p_machAttr(machType,"ha")    = ( p_machAttr(machType,"price")/p_machAttr(machType,"ha"));
  p_machAttr(machType,"depCost_hour")  $ p_machAttr(machType,"hour")  = ( p_machAttr(machType,"price")/p_machAttr(machType,"hour"));
$endif.data


*
* --- pasture needs 1 tractor hour a year
*
  p_machNeed(past,till,intens,"Tractor","ha") $ sum(plot, c_p_t_i(past,plot,till,intens)) = 1;

$iftheni.app     "%ManureAppl%" == "Investments"

*--- machine need for different application techniques and the manure barrel, defined in m3

  p_machNeed(manApplicType,"plough","normal","manbarrel","m3")        = 1 ;
  p_machNeed("applTailhPig","plough","normal","draghose","m3")        = 1 ;
  p_machNeed("applTailhCattle","plough","normal","draghose","m3")     = 1 ;
  p_machNeed("applInjecPig","plough","normal","injector","m3")        = 1 ;
  p_machNeed("applInjecCattle","plough","normal","injector","m3")     = 1 ;
  p_machNeed("applTShoePig","plough","normal","injector","m3")        = 1 ;
  p_machNeed("applTShoeCattle","plough","normal","injector","m3")     = 1 ;
  p_machNeed("applSolidSpread","plough","normal","solidManDist","m3") = 1 ;

  p_machNeed(manApplicType,"plough","normal","tractor","hour")        = 0.5 / (12);
  p_machNeed("applTailhPig","plough","normal","tractor","hour")       = 0.5 / (12);
  p_machNeed("applTailhCattle","plough","normal","tractor","hour")    = 0.5 / (12);
  p_machNeed("applInjecPig","plough","normal","tractor","hour")       = 0.5 / (12);
  p_machNeed("applInjecCattle","plough","normal","tractor","hour")    = 0.5 / (12);
  p_machNeed("applTShoePig","plough","normal","tractor","hour")       = 0.5 / (12);
  p_machNeed("applTShoeCattle","plough","normal","tractor","hour")    = 0.5 / (12);
  p_machNeed("applSolidSpread","plough","normal","tractor","hour")    = 0.5 / (12);


$endif.app


*--- machine need for synthetic Fertilizer

  set syntFertilizer_machType(syntFertilizer,machType) /
      AHL.sprayer
      ASS.fertSpreaderSmall
      PK_18_10.fertSpreaderSmall
      dolophos.fertSpreaderSmall
      KAS.fertSpreaderSmall
      KaliMag.fertSpreaderSmall
*      Lime.fertSpreaderLarge
  /;

*
* --- convert bale / hay press from m3 to hours, assuming 25 m3 from each ha
*
 p_machAttr("balePressHay","ha") = p_machAttr("balePressHay","m3") / 25;
*
* --- this is defined per kg material sprayed (AHL)
*
  p_machNeed(syntFertilizer,till,"normal","sprayer","m3")   $ (syntFertilizer_machType(syntFertilizer,"sprayer")) = 1/1000;
  p_machNeed(syntFertilizer,till,"normal","tractor","hour") $ (syntFertilizer_machType(syntFertilizer,"sprayer")) = 0.25/360;
*
* --- this is defined per kg material spread (PK_18_10,dolophos, ASS), see e.g. KTBL 2012/13, page 388, BLA and FA
*
  p_machNeed(syntFertilizer,till,"normal","fertSpreaderSmall","hour")   $ (syntFertilizer_machType(syntFertilizer,"fertSpreaderSmall")) = 0.25/360;
  p_machNeed(syntFertilizer,till,"normal","tractor","hour")             $ (syntFertilizer_machType(syntFertilizer,"fertSpreaderSmall")) = 0.25/360;

$endif.mode
