********************************************************************************
$ontext

   Farmdyn project

   GAMS file : FEEDS_DE.GMS

   @purpose  : Define list of feeds and feed attributes
   @author   : W. Britz (from existing code)
   @date     : 22.03.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : model\templ_decl.gms, coeffgen\feeds.gms

$offtext
********************************************************************************

$iftheni.mode "%1" == "decl"

   set feed_ccCrops(crops),feedGDX(crops),roughagesGDX(crops);
   $$gdxin "%datDir%/%cropsFile%.gdx"
      $$load feed_ccCrops feedGDX=feed roughagesGDX=roughages
   $$gdxin

   set set_feeds /
                         set.feedGDX      "crops used as feed without roughages and ccCrops"
                         set.roughagesGDX "crops used as roughages"

                          concCattle3     "Concentrate with 7.2 MEL/kg and 20% protein"
                          concCattle2     "Concentrate with 6.9 MEL/kg and 19% protein"
                          concCattle1     "Concentrate with 6.7 MEL/kg and 18% protein"


*                          oilsForFeed    "oils for feeding"
                          earlyGraz
                          middleGraz
                          LateGraz

                          earlyGrasSil
                          middleGrasSil
                          LateGrasSil
                          grasM
                          hayM
                          Hay
                          Straw
                          soyBeanMeal    "Soy cake for feeding"
                          milkPowder     "Milk powder"
                          milkFed        "Milk for weaners"

                          
   $$iftheni.feedCatchCrop "%feedCatchCrop%"=="true"
                          CCclover
                          set.feed_ccCrops "catchcrops used as feed"
   $$endif.feedCatchCrop

* --- Feed additives for methane reduction
                          feedAdd_Bovaer
                          feedAdd_VegOil
*                          dryBeetPulp
*                          moistBeetPulp
*                          cornGlutenMeal
*                          rapeSeedMeal
   /;

* --- include crops as feeds that are not selected as crops in GUI
$iftheni.ktbl "%database%"=="KTBL_database"
   set crops_as_input;
   $$gdxin "%datDir%/%cropsFile%.gdx"
      $$load crops_as_input
   $$gdxin
$onMulti
   set set_feeds /
        set.crops_as_input
      /;
$offmulti
$endif.ktbl

$else.mode


  $$iftheni.cattle %cattle% == true


*
*       --- Nutrient and energy content in different feeds expressed in g / kg of fresh matter (FM)
*           according to Gruber Futterwerttabellen Wiederkaeuer 2014
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
*       alfalfa = Gruber Code 3775
*       summerPeas = Gruber Code 4345
*       summerBeans = Gruber Code 4305


$onmulti
        table p_feedContDMg(feeds,feedAttr)

*                   in 1000g FM   |                                 in 1000g DM
*                            g    | g     g      g    g     g    %     g      MJ     MJ    g      g     g    g     g    g    g    g
                             DM     XF   aNDF   ADF   XP   nXP   UDP   RNB    NEL    ME     XS+XZ  bSX   XL   Ca    P    Mg   Na   K

          Straw              860    430  770    445   40    74   45     -5    3.42    6.24    8     0    13   3.0   0.8  1.0  1.5  11
          concCattle1        880     68              136   168   25     -5    8.18   13.00  584   107    50   6.8   4.6  2.3  1.4   8
          concCattle2        880    105              205   184   30      3    7.61   12.24  478    66    43   8.0   4.6  1.7  1.7  10
          concCattle3        880    136              455   283   35     28    7.61   12.44  114    15    34   6.8   9.1  4.0  0.8  18
          soyBeanMeal        880     68              500   291   30     34    8.64   13.76  178    14    14   3.1   7.0  3.0  0.2  22
          milkPowder         940      1              223   161   10     10   10.23   15.87  495     2   160   9.6   6.4  2.0  5.3  20
          milkfed            135      0              262   133    5     21   12.53   19.4   345         324   8.6   7.2  0.9  3.2  11
   $$iftheni.feedCatchCrop "%feedCatchCrop%" == "true"
          ccClover           170    235  490    241  165   140   15      4    6.33   10.5   150     0    37   5.0   3.2  1.6  2.5  19
   $$endif.feedCatchCrop


          feedAdd_Bovaer     999
* --- Soyoil data taken from LFL source
          feedAdd_VegOil     999                                              19.8    30.5               999

*          dryBeetPulp        906    189               83   142   45    -10    7.32   11.73   88          10  13.8   0.8  1.8  0.5   5
*          moistBeetPulp      270    200               94   148   30    -8.6   7.52   11.99   35           4  12.4   1    2.7  0.6   5.3
*          cornGlutenMeal     880     90              258   194   25     10    7.69   12.43  224   42     41   1.5   9.5  4.8  2.8  14
*          rapeSeedMeal       890    133              387   252   35     22    7.16   11.80   80          35   8.7  11.9  6.0  0.5  14



   parameter p_feedContDMgGDX(feeds,feedAttr);

execute_load "%datDir%/%cropsFile%.gdx"  p_feedContDMgGDX = p_feedContDMg;
   p_feedContDMg(feeds,feedAttr) $ (not p_feedContDMg(feeds,feedAttr))= p_feedContDMgGDX(feeds,feedAttr);

$offmulti
   $$endif.cattle

   $$iftheni.pigHerd %pigherd% == true

   table    p_feedAttrPig(feedsPig,feedAttr) "feed attributes of pig feed in GJ/t(energ) and kg/t (crudeP,Lysin,phosphFeed) and t/t (mass)"

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

*      --- Concentrates and protein specifics

        rapeSeedMeal      9.89             361              19.8              11.6
        PlantFat          37.3
        soybeanMeal       13               449              27.8               6.4          - 1
        soybeanOil        37.3                                                              - 1
        minFu                                                80                30           - 1
        minFu2                                               80                20           - 1
        minFu3                                               100               20           - 1
        minFu4                                               100               15           - 1
       ;

parameter p_feedAttrPigGDX(feedspig,feedAttr);
execute_load "%datDir%/%cropsFile%.gdx"  p_feedAttrPigGDX = p_feedAttrPig;
p_feedAttrPig(feedsPig,feedAttr)$ (not p_feedAttrPig(feedsPig,feedAttr))= p_feedAttrPigGDX(feedspig,feedAttr);

   $$endif.pigHerd
$endif.mode
