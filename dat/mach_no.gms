********************************************************************************
$ontext

   FARMDYN project

   GAMS file : MACH_NO.GMS

   @purpose  : Define lifietime of machinery, investment costss and machenery needs for crops - values for Norway
   @author   : Klaus
   @date     : 11.03.21
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


 $$ifthen.stables defined stables

 set set_stables_to_mach(stables,set_machType) /

    $$iftheni.cattle "%cowHerd%"=="true"


               (motherCowSmall,motherCowLarge) .(siloBlockCutter,shearGrab,frontLoader,dungGrab)
*               --- cost of fodder mixing vehicle 8 now expressed per stable place to avoid "jump" in cost from 60->90, see dat/stable_de, WB 09-01-20
               (milk30,milk60,milk90)         .(siloBlockCutter,frontLoader,dungGrab)
*               --- cost of fodder mixing vehicle 10/16 now expressed per stable place to avoid "jump" in cost from 90->120, and 120-240
               (milk120)                      .(frontLoader,dungGrab)
               (milk240)                      .(frontLoader,dungGrab)

               (set.youngStables) .(siloBlockCutter,shearGrab,frontLoader,dungGrab)

    $$elseif.cattle defined bulls

               (set.youngStables) .(siloBlockCutter,shearGrab,frontLoader,dungGrab)

    $$endif.cattle

 /;

 $$endif.stables

$else.mode


$onmulti

 table p_machAttr(machType,machAttr)

*
* --- Data from KTBL 2014/2015, if not otherwise stated
*
*
* --- KTBL. 82, 4 Schare, 140 cm
*
                      price        hour       ha       m3     t     varCost_ha  varCost_t  varCost_h  diesel_h  fixCost_h  fixCost_t years varCost_m3
 Plough               13000                 2000                        12.0
*
* --- KTBL. 84, Schwergrubber, angebaut, 2.5m
*
 ChiselPlough          5600                 2600                         5.0
*
* --- KTBL. 85, Federzinkenegge, angebaut, 4.5m
*
 springTineHarrow      7350                 2250                         3.5
*
* --- KTBL. 100, Hackstriegel, 4.5m
*
 fingerHarrow          3500                 2250                         2
*
* --- KTBL. 85, saatbeetkombi, 4,5 m
*
 seedBedCombi         10000                 2250                         4.0
*
* --- KTBL. 86, Kurzscheibenegge, 3 m
*
 circHarrow           13000                 3000                         5.0
*
* --- KTBL. 97, mechanic sowing machine, 3 m
*
 sowMachine           12500                 2250                         2.5
*
* --- KTBL.2012/13 98, direct sow machine, 3m, 1800 l
*
 directSowMachine     46000                 5520                        12.0
*
*  Cropsprayer , bezieht sich auf m3, bestehend aus Beh�lter und Spritzgest�nge
*                    Anbaupflanzenschutzspritze, 15 m 1000 l, 67 kW
* --- KTBL. 101+102, crop sprayer in hitch. 1000 l, 15m sprayer boom
* cropSprayer
*
    Sprayer           13500                 6000                        0.31
*
* mulcher   (Abgeleitet aus M�hwerksangaben, da keine Mulcher in KTBL 2012/13 vorhanden, S.103, 2,8m Rotationsm�hwerk, Heckanbau)
*
  mulcher             8400                  3850                        1.7
*
* --- KTBL. 100, hoe (Hackmaschine 5-reihig)
*
  hoe                 5900                  1250                         3
*
* --- KTBL S. 89, Kreiselegge 2,5 m angebaut
*
 rotaryHarrow         7600                  2500                         7.0
*
*---  KTBL S.100, Kartoffellegemaschine mite starrem Bunker, 4-reihig, 1,2 t
*
 potatoPlanter        26500                 1400                        13.0
*
*---  KTBL S. 112, Kartoffelbunkerroder angeh�ngt 1-reihig 4 t
*
 potatoLifter         70000                  500                        40.0
*
*---  KTBL S. 100, Kartoffelh�ufer mit Dammformer, 4-reihig
*
 ridger                7800                 1200                         3.0
*
*---  KTBL 12/13 S. 113, Kartoffelkrautschl�ger 2-reihig 45 kW
*
 haulmCutter           9800                 1100                         5.2

*
*--- KTBL S.98   Einzelkornlegeger�t (Mais, R�ben) 4-reihig, 3m
*

 singleSeeder          15500                750                          8.5
*
*--- KTBL 12/13 S.92   D�ngerstreuer  (Schleuderstreuer Angebaut, 800 L)
*                from (t to ha using 1 t per ha)

 fertSpreaderSmall      3600       2000                                  0.15
*
*--- KTBL 12/13 S.92   D�ngerstreuer  (Schleuderstreuer, angh�ng,t 40 km/h, 4000 l)
*                from (t to ha using 3 t per ha, lime_fert)
*
 fertSpreaderLarge     31500       3950                                  0.083
*
*--- KTBL 12/13 S.109 Feldh�cksler 250kw mit 4,5m Maisgebiss S.110(als Dienstleistung, muss hier also nicht rein)
*                   Fixcost are derived by dividing yearly fix costs by total lifetime in hours by # of years

*chopper               235000      3000                                                        64.11     43.6      94.3
 chopper                           3000                                                        64.11     43.6      94.3

 cornHeader            50000                1900                          10

*
*--- KTBL S.113   R�benroder (K�pfrodebunker, 2-reihig,gezogen 67KW)
*                    Fixcost are derived by dividing yearly fix costs by total lifetime in hours by # of years

 beetHarvester         71000                 660                          60

*
*---  KTBL S. 78, Dreiseitenkipper zweiachsig, 14 t
*
*     As for tractor, fix costs per t are derived by: a*Fix costs pro a/t Leistung
*     40000 t with 0.0375 hour/t = 1500 hour life time
*
*
threeWayTippingTrailer 17500      1500                                                          5.3               14.65

*
*--- KTBL S. 70, Frontgabelstapler, 3t Dieselmotor
*
 forkLiftTruck         47.500     9000                                                          5.84      2.0       6.13
*
*                     price        hour       ha       m3     t     varCost_ha  varCost_t  varCost_h  diesel_h  fixCost_h  fixCost_t years varCost_m3
*
* --- KTBL.12/13 S.65, tractor    (67kw)
*
*    Fixcost are derived by dividing yearly fix costs by total lifetime in hours by # of years
*
 tractorSmall          40000     10000                                                          10.54      6.3
*
* --- KTBL.12/13 S.65, tractor    (54kw)
*
*    Fixcost are derived by dividing yearly fix costs by total lifetime in hours by # of years
*
 tractor               48000     10000                                                          12.12      7.8
*
* --- KTBL combine S.112 mit Getreideschneidwerk 4,5m, Rapstisch 4,5m und Maispfl�cker 4-reihig S.111
*
*    150 kw, 7000 l
*
 combine             151000       3000                                                          36.12     27.3      58.20
 cuttingUnitCere      19500                 2800                         5.0
 cuttingAddRape        8900                 1500                         1.0
 cuttingUnitMaiz      34000                  800                        18.0
*
* --- KTBL S. 103, Rotationsm�hwerk mit M�haufbereiung, Heckanbau 2,4 m
*
 mowerConditioner    14000                  3300                         2.25
*
* --- KTBL S. 105, Kreiselzettwender, 4,5 m
*
 rotaryTedder        6500                   6150                         1.65
*
* --- KTBL S. 102, Kreiselschwader  , 3,5 m
*
 rake                5200                   3600                         2.00
*
* --- KTBL S. 88, Glattwalze 3m
*
 roller              2450                   3000                         0.20
*
* --- KTBL S. 99, Gasnachs�maschine, 2.5 m
*
 grasReSeedingUnit  14500                   2500                         2.35
*
*                     price        hour       ha       m3     t     varCost_ha  varCost_t  varCost_h  diesel_h  fixCost_h  fixCost_t years varCost_m3
*
* --- KTBL S.119, Siloblockschneider 3m�
*
 siloBlockCutter     8400                          11000                                                                               8     0.24
*
* --- KTBL S.76, Schneidzange       2m�
*
 shearGrab           7700                          24000                                                                              10     0.10
*
* --- KTBL S.71, Fontlader   1750 daN
*
 frontLoader         4600          2500                                                      0.90                                     12
*
* --- KTBL S.74, Dungzange 1.25m3
*
 dungGrab            2400                                  37500                 0.01                                                 10
*
* --- KTBL S.121, Futtermischwagen, horizontale Schnecke, 8m3
*
 fodderMixingVeh8   42500                          23000                                                                               8      0.89
*
* --- KTBL S.117, Futtermischwagen, vertikale Schnecke, 10m3
*
 fodderMixingVeh10  37500                          35000                                                                              10      0.64
*
* --- KTBL 10/11, S.117, Futtermischwagen, vertikale Schnecke, 16m3
*
 fodderMixingVeh16  55000                          60000                                                                              10      0.55
*
* --- KTBL 14/15, S.107, Rundballenpresse 1.2m Festkammer
*
balePressHay        34000                          35000                                     0.95                                     10
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


 p_machAttr(machType,"price     ") =  p_machAttr(machType,"price     ") * %EXR% ;
 p_machAttr(machType,"varCost_ha") =  p_machAttr(machType,"varCost_ha") * %EXR% ;
 p_machAttr(machType,"varCost_t ") =  p_machAttr(machType,"varCost_t ") * %EXR% ;
 p_machAttr(machType,"varCost_h ") =  p_machAttr(machType,"varCost_h ") * %EXR% ;
 p_machAttr(machType,"varCost_m3") =  p_machAttr(machType,"varCost_m3") * %EXR% ;
 p_machAttr(machType,"fixCost_h ") =  p_machAttr(machType,"fixCost_h ") * %EXR% ;
 p_machAttr(machType,"fixCost_t ") =  p_machAttr(machType,"fixCost_t ") * %EXR% ;


* --- according to KTBL 2014/15 p. 95 & 96

  p_priceMach("manbarrel",t)    = 29000 * ([1+%outputPriceGrowthRate%/100]**t.pos);
  p_priceMach("draghose",t)     = 20500 * ([1+%outputPriceGrowthRate%/100]**t.pos);
  p_priceMach("injector",t)     = 25500 * ([1+%outputPriceGrowthRate%/100]**t.pos);
  p_priceMach("trailingshoe",t) = 19000 * ([1+%outputPriceGrowthRate%/100]**t.pos);
  p_priceMach("solidManDist",t) = 67000 * ([1+%outputPriceGrowthRate%/100]**t.pos);

  p_priceMach("manbarrel",t)           = p_priceMach("manbarrel",t)     * %EXR% ;
  p_priceMach("draghose",t)            = p_priceMach("draghose",t)      * %EXR% ;
  p_priceMach("injector",t)            = p_priceMach("injector",t)      * %EXR% ;
  p_priceMach("trailingshoe",t)        = p_priceMach("trailingshoe",t)  * %EXR% ;
  p_priceMach("solidManDist",t)        = p_priceMach("solidManDist",t)  * %EXR% ;

  p_machAttr(machType,"depCost_ha")    $ p_machAttr(machType,"ha")    = ( p_machAttr(machType,"price")/p_machAttr(machType,"ha"));
  p_machAttr(machType,"depCost_hour")  $ p_machAttr(machType,"hour")  = ( p_machAttr(machType,"price")/p_machAttr(machType,"hour"));
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
  p_machNeed(syntFertilizer,till,"normal","sprayer","m3")   $ (syntFertilizer_machType(syntFertilizer,"sprayer")) = 1/1000;
  p_machNeed(syntFertilizer,till,"normal","tractor","hour") $ (syntFertilizer_machType(syntFertilizer,"sprayer")) = 1/300;
*
* --- this is defined per kg material spread (PK_18_10, ASS), see e.g. KTBL 2012/13, page 388, BLA and FA
*
  p_machNeed(syntFertilizer,till,"normal","fertSpreaderSmall","hour")   $ (syntFertilizer_machType(syntFertilizer,"fertSpreaderSmall")) = 0.25/360;
  p_machNeed(syntFertilizer,till,"normal","tractor","hour")             $ (syntFertilizer_machType(syntFertilizer,"fertSpreaderSmall")) = 0.25/360;

$endif.mode
