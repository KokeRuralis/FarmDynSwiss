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

 set set_machType /tractor                 "Standardtraktor 65-74 kW"    
                      tractorSmall            "Standardtraktor 37-44 kW"          
                      twoaxleMower            "Zweiachser (Bergtraktor)"                                     
                      singleaxleMower         "Einachser (Benzin)"
                      transportMountain       "Reform Muli"                                                        
                      rakeTwoAxle             "Bandschwader Bergtraktor"                                                     
                      cuttingbarSAxle    "Mähbalken einachser"
                      bandrakeSingleAxle      "Bandschwader einahcser"
                      leafBlower              "Laubbläser"                                                   
                      loaderWagon             "Ladewagen"
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



       $$ifthen.stables defined stables

 set set_stables_to_mach(stables,set_machType) /

      $$iftheni.cattle "%cowHerd%"=="true"


               (motherCowSmall,motherCowLarge) .(siloBlockCutter,shearGrab,frontLoader,dungGrab)

               (milk30,milk60,milk90)         .(siloBlockCutter,frontLoader,dungGrab)
               (milk120)                      .(frontLoader,dungGrab,fodderMixingVeh8)
               (milk240)                      .(frontLoader,dungGrab,fodderMixingVeh8)

           $$elseif.cattle defined bulls


               (set.youngStables) .(siloBlockCutter,shearGrab,frontLoader,dungGrab)

    $$endif.cattle


 /;

    $$endif.stables

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
 Plough               31000                 1100                        75.40
*
* --- KTBL. 84, Schwergrubber, angebaut, 2.5m, Agroscope Code 4004
*
 ChiselPlough          5800                  800                         64.85
*
* --- KTBL. 85, Federzinkenegge, angebaut, 4.5m, Agroscope Code 4039
*
 springTineHarrow       9500                 1200                        25.67
*
* --- KTBL. 100, Hackstriegel, 4.5m, Agroscope Code 5081
*
 fingerHarrow          9800                 2000                         9.55
*
* --- KTBL. 85, saatbeetkombi, 4,5 m, Agroscope Code ???? (5060) --> Simon Hug: 5067 Zapfwellenegge + Sämaschine
*
 seedBedCombi         77000                 1600                         67.65
*
* --- KTBL. 86, Kurzscheibenegge, 3 m, Agroscope Code 4034
*
 circHarrow           23000                 2000                         26.34
*
* --- KTBL. 97, mechanic sowing machine, 3 m, Agroscope Code 5002
*hugs_15.04.21 --> Variable Kosten von 9 auf 9.75 angepasst gemäss Maschinenkostenkatalog
 sowMachine           21000                 1000                         13.99
*
* --- KTBL.2012/13 98, direct sow machine, 3m, 1800 l, Agroscope Code 5005
*
 directSowMachine     80000                 3000                        37.69
*
*  Cropsprayer , bezieht sich auf m3, bestehend aus Beh�lter und Spritzgest�nge
*                    Anbaupflanzenschutzspritze, 15 m 1000 l, 67 kW
* --- KTBL. 101+102, crop sprayer in hitch. 1000 l, 15m sprayer boom, Agroscope Code 5154
* cropSprayer
*
    Sprayer           29000                 4000                        12.99
*
* mulcher   (Abgeleitet aus M�hwerksangaben, da keine Mulcher in KTBL 2012/13 vorhanden, S.103, 2,8m Rotationsm�hwerk, Heckanbau), Agroscope Code ??? (14021)
*
  mulcher             12000                 1800                        39.61
*
* --- KTBL. 100, hoe (Hackmaschine 5-reihig), Agroscope Code 5123
*
  hoe                 19000                 2000                       119.83
*
* --- KTBL S. 89, Kreiselegge 2,5 m angebaut, Agroscope Code 4055
*
 rotaryHarrow         16000                  800                        41.33
*
*---  KTBL S.100, Kartoffellegemaschine mite starrem Bunker, 4-reihig, 1,2 t, Agroscope Code 5044
*
 potatoPlanter        34000                 500                         78.34
*
*---  KTBL S. 112, Kartoffelbunkerroder angeh�ngt 1-reihig 4 t, Agroscope Code 8013
*
 potatoLifter         134000                 250                        455.6
*
*---  KTBL S. 100, Kartoffelh�ufer mit Dammformer, 4-reihig, Agroscope Code 5102
*
 ridger                14000                  700                        44.54
*
*---  KTBL 12/13 S. 113, Kartoffelkrautschl�ger 2-reihig 45 kW, Agroscope Code 8001
*
 haulmCutter           33000                  4000                       455.60

*
*--- KTBL S.98   Einzelkornlegeger�t (Mais, R�ben) 4-reihig, 3m, Agroscope Code 5031
*

 singleSeeder          25000                 800                          41.63
*
*--- KTBL 12/13 S.92   D�ngerstreuer  (Schleuderstreuer bis 500 l)
*                from (t to ha using 1 t per ha), Agroscope Code 6003

 fertSpreaderSmall      6000                2000                         23.54
*
*--- KTBL 12/13 S.92   D�ngerstreuer  (Schleuderstreuer, 500-1000l)
*                from (t to ha using 3 t per ha, lime_fert), Agroscope Code 6004
*
 fertSpreaderLarge      6700               2400                          13.20
*
*--- KTBL 12/13 S.109 Feldh�cksler 250kw mit 4,5m Maisgebiss S.110(als Dienstleistung, muss hier also nicht rein), Agroscope Code 9185
*                   Fixcost are derived by dividing yearly fix costs by total lifetime in hours by # of years
                        
 chopper                 46000               800                         443.66                                       

 cornHeader            110000                800                          96.25

*
*--- KTBL S.113   R�benroder (K�pfrodebunker, 2-reihig,gezogen 67KW), Agroscope Code 8063
*                    Fixcost are derived by dividing yearly fix costs by total lifetime in hours by # of years

 beetHarvester         134000                 250                       269.76

*
*---  KTBL S. 78, Dreiseitenkipper zweiachsig, 14 t, Agroscope Code 3022
*
*     As for tractor, fix costs per t are derived by: a*Fix costs pro a/t Leistung
*     40000 t with 0.0375 hour/t = 1500 hour life time
*
*
threeWayTippingTrailer 40000      1500                       75000                   0.76       5.3               14.65

*
*--- KTBL S. 70, Frontgabelstapler, 3t Dieselmotor, Agroscope Code 1105
*
 forkLiftTruck         25000      10000                                                        7.25
*
*                     price        hour       ha       m3     t     varCost_ha  varCost_t  varCost_h  diesel_h  fixCost_h  fixCost_t years varCost_m3
*
* --- KTBL.12/13 S.65, tractor    (67kw), Agroscope Code 1005
*
*    Fixcost are derived by dividing yearly fix costs by total lifetime in hours by # of years
*
 tractorSmall          94000     10000                                                          20.54  8.4         18.3
*
* --- KTBL.12/13 S.65, tractor    (54kw), Agroscope Code 1002
*
*    Fixcost are derived by dividing yearly fix costs by total lifetime in hours by # of years
*
 tractor               59000     10000                                                          13.7  4.92         16.4
*
* --- KTBL combine S.112 mit Getreideschneidwerk 4,5m, Rapstisch 4,5m und Maispfl�cker 4-reihig S.111
*
*    150 kw, 7000 , Agroscope Code 10031,10032,10035
*
 combine             151000       3000                                                          36.12     27.3      58.20
 cuttingUnitCere     219000                 2800                        54.48
 cuttingAddRape      219000                 2800                        54.48
 cuttingUnitMaiz     219000                 2800                        54.48
*
* --- KTBL S. 103, Rotationsm�hwerk mit M�haufbereiung, Heckanbau 2,4 m, Agroscope Code 9002
*
 mowerConditioner    30000                  1200                         25.27
*
* --- KTBL S. 105, Kreiselzettwender, 4,5 m, Agroscope Code 9041
*
 rotaryTedder        9400                   1600                         11.75
*
* --- KTBL S. 102, Kreiselschwader  , 3,5 m, Agroscope Code 9062
*
 rake                11000                   2400                        15.35
*
* --- KTBL S. 88, Glattwalze 3m, Agroscope Code ??? 4073
*
 roller              12500                   5000                         8.78
*hugs: alte Werte    2450                   3000                         0.20
* --- KTBL S. 99, Grasnachs�maschine, 2.5 m, Agroscope Code 5137
*
 grasReSeedingUnit  12000                   2000                         26.47
*
*                     price        hour       ha       m3     t     varCost_ha  varCost_t  varCost_h  diesel_h  fixCost_h  fixCost_t years varCost_m3
*
* --- KTBL S.119, Siloblockschneider 3m�, Agroscope Code 10045
*
 siloBlockCutter     18000                         20000                                                                                    0.90
*
* --- KTBL S.76, Schneidzange       2m�, Agroscope Code 2017
*
 shearGrab           5000          5000            43                                                                                       0.05
*
* --- KTBL S.71, Frontlader schwer, Agroscope Code 2013
*
 frontLoader         5000          5000                                                      2.6
*
* --- KTBL S.74, Dungzange 1.25m3, Agroscope Code 2014
*
 dungGrab            1800          5000                                                      0.81                
*
* --- KTBL S.121, Futtermischwagen, horizontale Schnecke, 8m3, Agroscope Code 10031
*
 fodderMixingVeh8   34000                          56000                                                                                     0.45
*
* --- KTBL S.117, Futtermischwagen, vertikale Schnecke, 10m3, Agroscope Code 10032
*
 fodderMixingVeh10  42000                          80000                                                                                     0.358
*
* --- KTBL 10/11, S.117, Futtermischwagen, vertikale Schnecke, 16m3, Agroscope Code 10035
*
 fodderMixingVeh16  66000                          160000                                                                                    0.236
*
* --- KTBL 14/15, S.107, Rundballenpresse 1.2m Festkammer, Agroscope Code 9124
*                                                  1.4m3*30000Rb = 42000m3?                                                                   1.61/1.4m3 =1.15/m3
balePressHay        61000                          42000                                                                                    1.15
* --- Ladewagen mit Schneidvorrichtung, 20 m3 DIN,Agroscope Code 9084
*

************************************************************************************************************************************************
*
* Hello hier bitte die Kosten eintragen. Ihr könnt euch an den Einträgen darüber orientieren.
*
***********************************************************************************************************************************************
*                     price        hour       ha       m3     t     varCost_ha  varCost_t  varCost_h  diesel_h  fixCost_h  fixCost_t years varCost_m3
*                     price        hour       ha       m3     t     varCost_ha  varCost_t  varCost_h  diesel_h  fixCost_h  fixCost_t years varCost_m3
 twoaxleMower         118000       10000                                                   20.5       5.4       27.53      8260 
 
 rakeTwoAxle          10500                  1500                      23.12                                                893
*Single axle mower not diesel but ignore?
 singleAxleMower      16000        4000                                                    10.85      2.87       7.5        1876                                     
 
 cuttingbarSAxle       36000                  1300                      45.26                                                3000

 bandrakeSingleAxle    7200                   800                      14.32                                                 645              

 transportMountain   108000        10000                                                   21.24        6.0      114.5      8130         

 leafBlower             950                   800                                                                            104

 loaderWagon            66000                         20              32.84                                                 1310

;
* --- according to KTBL2010 S.98 for ....in kg N
*
*     i.e. 6000 ha * 200 kg N (?)

* p_lifeTimeM("sprayer","m3")  =   6000*200;


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


* p_machAttr(machType,"varcost_h") $ p_machAttr(machType,"diesel_h")
*  = p_machAttr(machType,"varcost_h") - p_machAttr(machType,"diesel_h")*0.9;

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

  p_machAttr(machType,"depCost_ha")    $ p_machAttr(machType,"ha")    = ( p_machAttr(machType,"price")/p_machAttr(machType,"ha"));
  p_machAttr(machType,"depCost_hour")  $ p_machAttr(machType,"hour")  = ( p_machAttr(machType,"price")/p_machAttr(machType,"hour"));

display label, p_machAttr, label;
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
  p_machNeed(syntFertilizer,"plough","normal","sprayer","m3")   $ (syntFertilizer_machType(syntFertilizer,"sprayer")) = 1/1000;
  p_machNeed(syntFertilizer,"plough","normal","tractor","hour") $ (syntFertilizer_machType(syntFertilizer,"sprayer")) = 1/300;
*
* --- this is defined per kg material spread (PK_18_10, ASS), see e.g. KTBL 2012/13, page 388, BLA and FA
*
  p_machNeed(syntFertilizer,"plough","normal","fertSpreaderSmall","hour")   $ (syntFertilizer_machType(syntFertilizer,"fertSpreaderSmall")) = 0.25/360;
  p_machNeed(syntFertilizer,"plough","normal","tractor","hour")             $ (syntFertilizer_machType(syntFertilizer,"fertSpreaderSmall")) = 0.25/360;




$endif.mode
