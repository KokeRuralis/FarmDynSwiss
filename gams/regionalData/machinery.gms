********************************************************************************
$ontext

   FARMDYN project

   GAMS file : machinery.gms

   @purpose  : Machinery costs and capacity

   @author   : David Sch�fer
   @date     : 20.03.2017
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************
****
*
*   Regional data for machinery prices and capacities
*
****

$iftheni.Schweiz "%region%" == "Schweiz"

 parameter p_machAttr(machType,machAttr) "Machinery attribute for default size (67kw, 2 ha)"

*
* --- Data from KTBL 2014/2015, if not otherwise stated
*
*
* --- KTBL. 82, 4 Schare, 140 cm
*
                      price        hour       ha       m3     t     varCost_ha  varCost_t  varCost_h  diesel_h  fixCost_h  fixCost_t years varCost_m3
 Plough               13000                  2000                        12.0
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
 potatoPlanter        40000                 1700                        20.0
*
*---  KTBL S. 112, Kartoffelbunkerroder angeh�ngt 1-reihig 4 t
*
 potatoLifter         104409                250                          354
*
*---  KTBL S. 100, Kartoffelh�ufer mit Dammformer, 4-reihig
*
 ridger                7800                 1200                         3.0
*
*---  KTBL 12/13 S. 113, Kartoffelkrautschl�ger 2-reihig 45 kW
*
 haulmCutter           11000                3200                         8.0

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
$iftheni %cattle% == true
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
$endif
;
$endif.Schweiz
