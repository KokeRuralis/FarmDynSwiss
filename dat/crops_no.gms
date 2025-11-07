********************************************************************************
$ontext

   FarmDyn project

   GAMS file : CROPS_DE.GMS

   @purpose  : Define yields, prices and other parameters relating to crops
   @author   :
   @date     : 19.03.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************
$iftheni.mode "%1"=="gdx"

 set set_crops_and_prods "crop and products of the same name" /  WinterWheat      "Winter wheat"
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
                                                                 Idle             "Idling arable land"
                                                                /;
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


   set cashCrops(set_crops_and_prods) /

      winterWheat,winterBarley,winterRye,summerCere,summerTriticale,winterRape,summerBeans,summerPeas,
      MaizCorn,potatoes,sugarBeet,MaizCCM,
      MaizSil,WheatGPS
   /;

   set arableCrops(set_crops_and_prods) /
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
 alias(set_crops_and_prods,crops);

  PARAMETER p_cropYield(*,*) /
'WinterWheat'.'Yield' 8.0
'WinterBarley'.'Yield' 7.0
'WinterRye'.'Yield'    6.0
'SummerCere'.'Yield' 6.0
'SummerTriticale'.'Yield' 6.0
'WinterRape'.'Yield' 3.5
'Potatoes'.'Yield' 45.0
'Sugarbeet'.'Yield' 60.0
'MaizCorn'.'Yield' 9.8
'MaizCCM'.'Yield' 14.0
'Summerpeas'.'Yield' 3.5
'Summerbeans'.'Yield' 4.0
'WheatGPS'.'Yield' 36.0
'MaizSil'.'Yield' 44.0
'Alfalfa'.'Yield' 10.2
'CCclover'.'Yield' 18
 /;

 p_cropYield(crops,'GrowthRateY "%"') = eps;

 parameter p_cropPrice(*,*)/

       WinterWheat     .price       153
       WinterBarley    .price       159
       WinterRye       .price       140
       MaizCorn        .price       164
       SummerCere      .price       181
       SummerTriticale .price       181
       WinterRape      .price       347
       SummerBeans     .price       198
       SummerPeas      .price       198
       WheatGPS        .price         1
       MaizSil         .price         1
       MaizCCM         .price         1
       GrasSil         .price         1
       Alfalfa         .price       180
       Potatoes        .price       180
       SugarBeet       .price        32
       CCclover        .price       EPS
 /;

p_cropPrice(crops,'price') = p_cropPrice(crops,'price') * %EXR%;


 p_cropPrice(crops,'Growth rate "%"') = eps;

$elseifi.mode %1==decl

    Set add_crops /
      CCmustard
      CCmustardAES
      CCclover
      CCmustardAESGreening
      flowerStrip
      flowerStripGre
      waterStrip
      waterStripGre
    /;

  set acts / set.add_crops /;
  set crops(acts) / set.add_crops /;


  set catchCrops(crops) "Catch crops" /
    CCmustard,
    CCmustardAES,
    CCmustardAESGreening
    CCclover
  /;

  set standardCatchCrops(catchCrops) /
    CCmustard,
    CCclover
  /;
 set monthGrowthCrops(crops,m) "Crosssets linking crops to month when the crop is growing"/
                                             (potatoes).(APR,MAY,JUN,JUL,AUG)
                                             (WinterWheat).(JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,OCT,NOV,DEC)
                                             (WinterBarley).(JAN,FEB,MAR,APR,MAY,JUN,JUL,OCT,NOV,DEC)
                                             (WinterRye).(JAN,FEB,MAR,APR,MAY,JUN,JUL,OCT,NOV,DEC)
                                             (SummerBeans).(MAR,APR,MAY,JUN,JUL,AUG)
                                             (SummerPeas).(FEB,MAR,APR,MAY,JUN,JUL)
                                             (SummerTriticale).(MAR,APR,MAY,JUN,JUL)
                                             (SummerCere).(MAR,APR,MAY,JUN,JUL)
                                             (winterRape).(JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC)
                                             (Sugarbeet).(MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT)
                                             (maizCorn).(APR,MAY,JUN,JUL,AUG,SEP,OCT)
                                             (maizCCM).(APR,MAY,JUN,JUL,AUG,SEP,OCT)
                                             (maizSil).(APR,MAY,JUN,JUL,AUG,SEP)
                                             (WheatGPS).(JAN,FEB,MAR,APR,MAY,JUL,AUG,OCT,NOV,DEC)
                                     /;


   set cropShareGrp "Crop group with maximal shares" / cere,rootCrops,legumes,maize /;

   set cropShareGrp_crops(cropShareGrp,crops) / cere.(winterWheat,wheatGPS,winterBarley,winterRye,summerCere,summerTriticale)
                                                rootCrops.(potatoes,sugarBeet)
                                                legumes.(summerPeas,summerBeans,Alfalfa)
                                                maize.(maizSil,maizCCM,maizCorn)
                          /;

$iftheni.compStat not "%dynamics%"=="comparative-static"

    set rot "Rotations" / WC_WC_PO,WC_PO_WC,PO_WC_WC
                          WC_WC_SC,WC_SC_WC,SC_WC_WC
                          WC_WC_SU,WC_SU_WC,SU_WC_WC
                          WC_WC_OT,WC_OT_WC,OT_WC_WC
                          WC_WC_ID,WC_ID_WC,ID_WC_WC

                          WC_SC_PO,SC_PO_WC,PO_WC_SC
                          WC_SC_SU,SC_SU_WC,SU_WC_SC
                          WC_SC_OT,SC_OT_WC,OT_WC_SC
                          WC_SC_ID,SC_ID_WC,ID_WC_SC

                          SC_WC_SC,SC_SC_WC,WC_SC_SC
                          SC_SC_ID,SC_ID_SC,ID_SC_SC
                          SC_SC_PO,SC_SC_SU,SC_SC_OT
                          WC_PO_ID,WC_SU_ID,WC_OT_ID
                          SC_PO_ID,SC_SU_ID,SC_OT_ID
                          WC_ID_ID,ID_WC_ID,ID_ID_WC
                          SC_ID_ID,ID_SC_ID,ID_ID_SC
                          PO_ID_ID,SU_ID_ID,OT_ID_ID
                          ID_ID_ID
                          PO_OT_WC,OT_WC_PO,WC_PO_OT
                          SU_OT_WC,OT_WC_SU,WC_SU_OT
                          PO_OT_SC,OT_SC_PO,SC_PO_OT
                          SU_OT_SC,OT_SC_SU,SC_SU_OT
                          SU_OT_PO,OT_PO_SU,PO_SU_OT
                        /;

    set curRot(rot);




    set cropTypes / WinterCere,SummerCere,Other,Potatoes,Sugarbeet,Idle/;
    alias(cropTypes,cropTypes1,cropTypes2);

    set rot_cropTypes(rot,cropTypes,cropTypes,cropTypes)  "Rotation, first / second / third year crop type"
                                         /
                                           WC_WC_PO.WinterCere.WinterCere.potatoes
                                           WC_PO_WC.WinterCere.potatoes.WinterCere
                                           PO_WC_WC.potatoes.WinterCere.WinterCere

                                           WC_WC_OT.WinterCere.WinterCere.other
                                           WC_OT_WC.WinterCere.other.WinterCere
                                           OT_WC_WC.other.WinterCere.WinterCere

                                           WC_WC_ID.WinterCere.WinterCere.idle
                                           WC_ID_WC.WinterCere.idle.WinterCere
                                           ID_WC_WC.idle.WinterCere.WinterCere

                                           WC_WC_SU.WinterCere.WinterCere.sugarBeet
                                           WC_SU_WC.WinterCere.sugarBeet.WinterCere
                                           SU_WC_WC.sugarBeet.WinterCere.WinterCere

                                           WC_WC_SC.WinterCere.WinterCere.summerCere
                                           WC_SC_WC.WinterCere.summerCere.WinterCere
                                           SC_WC_WC.summerCere.WinterCere.WinterCere

                                           WC_SC_PO.WinterCere.summerCere.potatoes
                                           SC_PO_WC.summerCere.potatoes.WinterCere
                                           PO_WC_SC.potatoes.WinterCere.summerCere

                                           WC_SC_SU.WinterCere.summerCere.sugarBeet
                                           SC_SU_WC.summerCere.sugarBeet.WinterCere
                                           SU_WC_SC.sugarBeet.WinterCere.summerCere

                                           WC_SC_ID.WinterCere.summerCere.idle
                                           SC_ID_WC.summerCere.idle.WinterCere
                                           ID_WC_SC.idle.WinterCere.summerCere

                                           WC_SC_OT.WinterCere.summerCere.other
                                           SC_OT_WC.summerCere.other.WinterCere
                                           OT_WC_SC.other.WinterCere.summerCere


                                           SC_WC_SC.summerCere.WinterCere.summerCere
                                           WC_SC_SC.WinterCere.summerCere.summerCere
                                           SC_SC_WC.summerCere.summerCere.WinterCere

                                           WC_ID_ID.WinterCere.idle.idle
                                           ID_WC_ID.idle.WinterCere.idle
                                           ID_ID_WC.idle.idle.WinterCere

                                           SC_ID_ID.summerCere.idle.idle
                                           ID_SC_ID.idle.summerCere.idle
                                           ID_ID_SC.idle.idle.summerCere

                                           SC_SC_ID.summerCere.summerCere.idle
                                           SC_ID_SC.summerCere.idle.summerCere
                                           ID_SC_SC.idle.summerCere.summerCere

                                           SC_SC_PO.summerCere.summerCere.potatoes
                                           WC_PO_ID.WinterCere.potatoes.idle
                                           SC_PO_ID.summerCere.potatoes.idle
                                           ID_ID_ID.idle.idle.idle
                                           PO_ID_ID.potatoes.idle.idle

                                           SC_SC_SU.summerCere.summerCere.sugarBeet
                                           WC_SU_ID.WinterCere.sugarBeet.idle
                                           SC_SU_ID.summerCere.SugarBeet.idle
                                           SU_ID_ID.sugarBeet.idle.idle



                                           SC_SC_OT.summerCere.summerCere.other
                                           WC_OT_ID.WinterCere.other.idle
                                           SC_OT_ID.summerCere.other.idle
                                           OT_ID_ID.other.idle.idle

                                           PO_OT_WC.potatoes.other.WinterCere
                                           OT_WC_PO.other.WinterCere.potatoes
                                           WC_PO_OT.WinterCere.potatoes.other

                                           PO_OT_SC.potatoes.other.summerCere
                                           SU_OT_WC.SugarBeet.other.WinterCere
                                           OT_WC_SU.other.WinterCere.SugarBeet
                                           WC_SU_OT.WinterCere.SugarBeet.other

                                           SU_OT_SC.SugarBeet.other.summerCere
                                           OT_SC_SU.other.summerCere.SugarBeet
                                           SC_SU_OT.summerCere.SugarBeet.other

                                           SU_OT_PO.SugarBeet.other.potatoes
                                           OT_PO_SU.other.potatoes.SugarBeet
                                           PO_SU_OT.potatoes.SugarBeet.other

                                         /;
$else.compStat

    set rot "Rotations" / WC_WC_PO
                          WC_WC_SC
                          WC_WC_SU
                          WC_WC_OT
                          WC_WC_ID

                          WC_SC_PO
                          WC_SC_SU
                          WC_SC_OT
                          WC_SC_ID

                          SC_SC_WC
                          SC_SC_ID
                          SC_SC_PO

                          WC_PO_ID
                          SC_PO_ID
                          WC_ID_ID
                          SC_ID_ID
                          PO_ID_ID
                          ID_ID_ID

                          PO_OT_WC
                          SU_OT_WC
                          PO_OT_SC
                          SU_OT_SC
                          SU_OT_PO
                        /;

    set curRot(rot);




    set cropTypes / winterCere,SummerCere,Other,Potatoes,Sugarbeet,Idle/;
    alias(cropTypes,cropTypes1,cropTypes2);

    set rot_cropTypes(rot,cropTypes,cropTypes,cropTypes)  "Rotation, first / second / third year crop type"
                                         /
                                           WC_WC_PO.winterCere.winterCere.potatoes
                                           WC_WC_SC.winterCere.winterCere.summerCere
                                           WC_WC_SU.winterCere.winterCere.sugarBeet
                                           WC_WC_OT.winterCere.winterCere.other
                                           WC_WC_ID.winterCere.winterCere.idle

                                           WC_SC_PO.winterCere.summerCere.potatoes
                                           WC_SC_SU.winterCere.summerCere.sugarBeet
                                           WC_SC_ID.winterCere.summerCere.idle
                                           WC_SC_OT.winterCere.summerCere.other

                                           SC_SC_WC.summerCere.summerCere.winterCere
                                           SC_SC_ID.summerCere.summerCere.idle
                                           SC_SC_PO.summerCere.summerCere.potatoes

                                           WC_PO_ID.winterCere.potatoes.idle
                                           SC_PO_ID.summerCere.potatoes.idle

                                           WC_ID_ID.winterCere.idle.idle
                                           SC_ID_ID.summerCere.idle.idle
                                           PO_ID_ID.potatoes.idle.idle
                                           ID_ID_ID.idle.idle.idle

                                           PO_OT_WC.potatoes.other.winterCere
                                           SU_OT_WC.SugarBeet.other.winterCere
                                           PO_OT_SC.potatoes.other.summerCere
                                           SU_OT_SC.SugarBeet.other.summerCere
                                           SU_OT_PO.SugarBeet.other.potatoes

                                         /;
$endif.compStat

*
* --- link to first, scecond and third year crop
*
  set cropType0_rot(cropTypes,rot);cropType0_rot(cropTypes,rot) $ sum(rot_cropTypes(rot,cropTypes,cropTypes1,cropTypes2),1) = YES;
  set cropType1_rot(cropTypes,rot);cropType1_rot(cropTypes,rot) $ sum(rot_cropTypes(rot,cropTypes1,cropTypes,cropTypes2),1) = YES;
  set cropType2_rot(cropTypes,rot);cropType2_rot(cropTypes,rot) $ sum(rot_cropTypes(rot,cropTypes1,cropTypes2,cropTypes),1) = YES;

  set cropTypes_crops(cropTypes,crops) / winterCere.(winterWheat,winterBarley,winterRye)
                                         summerCere.(summerCere,summerTriticale,maizCorn,maizCCM,WheatGPS)
                                         other.(winterrape,summerBeans,summerPeas,set.CatchCrops)
                                         potatoes.potatoes
                                         sugarbeet.sugarbeet
                                         idle.idle
                      /;


  set cere(crops) / winterWheat,WinterBarley,winterRye,summerCere,summerTriticale /;

$elseifi.mode %1==param

*
* --- (A) MONTH WHEN MANURE AND CHEMICAL FERTILIZER APPLICATION IS NOT POSSIBLE FOR AGRONOMIC REASONS
*         values for chemical fertilizer old; for manure assumptions that month for harvest no application is possible (own judgement, needs revision) [TK 19/09/17]

  set doNotApplySyn(crops,m)   /
                                  summerCere     .(May,Jun,Jul)
                                  summerTriticale.(May,Jun,Jul)
                                  winterWheat  .(Jul,Aug)
                                  winterBarley .(Jun,Jul)
                                  winterRye    .(Jun,Jul)
                                  winterRape   .(May,Jun,Jul,Aug)
                                  potatoes     .(May,Jun,Jul,Aug)
                                  maizSil.(Apr,May,Jun,Jul,Aug,Sep)
                                  idle.(set.m)
                                  idleGras.(set.m)
                                /;

  set doNotApplyManure(crops,m) /
                                 (potatoes,sugarbeet,maizSil)                      .(Jun,Jul,Aug)
                                 (WinterWheat,SummerBeans)                         .(Apr,May,Jun,Jul,Aug)
                                 (WinterBarley,WinterRye)                          .(Apr,May,Jun,Jul)
                                 (SummerPeas,SummerCere,summerTriticale,WinterRape).(May,Jun,Jul)
                                 (WheatGPS)                                        .(May,Jun)
                                 (MaizCorn, MaizCCM)                               .(Jun,Jul,Aug)
                                /;


*
* --- Assumption that certain share of plant nutrient need has to be provided as mineral fertilizer
*     Assumptions are based on work from Thomas Gaiser and discussion in the USL project, see also the protocol
*     from the USL meeting 15/02/18
*
* --- Share can vary for sensitivity analysis defined by GUI, raps excludes as there is the danger of exceeding the total N need


  p_minChemFert("maizSil","P")      = 20/83.6;
  p_minChemFert("maizCCM","P")      = 20/74.2;
  p_minChemFert("maizCorn","P")     = 20/78.4;

* --- The minimum amount of mineral N in maize is based on the assumption that 20 kg of P are provided as Diammonphosphat which
*     also contains N (Diammonsphosphat 46% P, 18% N

  p_minChemFert("maizSil","N")      = 8/167.2;
  p_minChemFert("maizCCM","N")      = 8/147;
  p_minChemFert("maizCorn","N")     = 8/135.24  ;

  p_minChemFert("WinterRape","N")   = 70/117.27;
  p_minChemFert("Sugarbeet","N")    = 30/108;

  p_minChemFert("winterWheat","N")     = 40/168.8;
  p_minChemFert("winterBarley","N")    = 40/125.3;
  p_minChemFert("winterRye","N")       = 40/115.5;
  p_minChemFert("summerCere","N")      =  10/107.4;
  p_minChemFert("summerTriticale","N") = 20/107.4;
*
* --- Post harvest loss of roughages
*
   p_storageLoss("wheatGPS")     =  0.88 ;
   p_storageLoss("maizSil")      =  0.88 ;
   p_storageLoss("earlyGrasSil") =  0.9  ;
   p_storageLoss("middleGrasSil")=  0.9  ;
   p_storageLoss("lateGrasSil")  =  0.9  ;
   p_storageLoss("earlyGraz")    =  1    ;
   p_storageLoss("middleGraz")   =  1    ;
   p_storageLoss("lateGraz")     =  1    ;
   p_storageLoss("hay")          =  0.7  ;
   p_storageLoss("CCclover")     =  0.9  ;


* ---- N content of crops in kg N/dt fresh matter according to DUEV 2006, Anlage 1
* ---- P content of crops in kg P/dt fresh matter and N content of maizCCM according to LWK NRW
* ---- N and P removal via product and crop residues (Nebenernteprodukt) is calculated as HF + HNV * NF (D�V 2006, Anlage 1)
* ---- Assumption: crop residues are taken away from the field  (except of potatoes, rape, beets, beans, peas, maizCorn,MaizCCM)

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

* --- Nut content of removed residues, possible for cereal production

   p_nutContent("winterWheat","WCresidues",sys,"P")     =  0.3 ;
   p_nutContent("winterBarley","WBresidues",sys,"P")    =  0.3 ;
   p_nutContent("winterRye","WRresidues",sys,"P")       =  0.3 ;
   p_nutContent("summerTriticale","STresidues",sys,"P") =  0.3 ;
   p_nutContent("summerCere","SCresidues",sys,"P")      =  0.3 ;

   parameter p_organicYieldMult(crops) /
      (set.cere)   0.5
       wheatGPS    0.5
       maizCorn    0.6
       winterRape  0.6
       summerBeans 1.0
       summerPeas  1.0
       alfalfa     1.0
       potatoes    0.6
       sugarBeet   0.8
       maizSil     0.6
       (set.grassCrops) 0.50
    /;


* --- Calculation of N and P removal via grassland; Data for N from FO 17 Anlage 7 Tabelle3, data for P from LWK NRW (Hinweise zur Berechnung des Düngebedarfs für Phosphat nach DüV für Grünland)

$iftheni.cat %cattle% == true

    parameter p_grasYieldMult(sys) / conv 1,org 0.50 /;

    p_nutContent(grassCrops(crops),prods,sys,"N")  $ ( grasOutput(prods)  $ (sum((grasOutputs,m), p_grasAttr(grassCrops,grasOutputs,m)*p_grasYieldMult(sys)) <=4   ))  = 1.38  * (p_nutGras(prods,"DM") / 1000);
    p_nutContent(grassCrops(crops),prods,sys,"N")  $ ( grasOutput(prods)  $ (sum((grasOutputs,m), p_grasAttr(grassCrops,grasOutputs,m)*p_grasYieldMult(sys)) > 4   ))  = 1.82  * (p_nutGras(prods,"DM") / 1000);
    p_nutContent(grassCrops(crops),prods,sys,"N")  $ ( grasOutput(prods)  $ (sum((grasOutputs,m), p_grasAttr(grassCrops,grasOutputs,m)*p_grasYieldMult(sys)) > 5.5 ))  = 2.4   * (p_nutGras(prods,"DM") / 1000);
    p_nutContent(grassCrops(crops),prods,sys,"N")  $ ( grasOutput(prods)  $ (sum((grasOutputs,m), p_grasAttr(grassCrops,grasOutputs,m)*p_grasYieldMult(sys)) > 8   ))  = 2.7   * (p_nutGras(prods,"DM") / 1000);
    p_nutContent(grassCrops(crops),prods,sys,"N")  $ ( grasOutput(prods)  $ (sum((grasOutputs,m), p_grasAttr(grassCrops,grasOutputs,m)*p_grasYieldMult(sys)) > 9   ))  = 2.8   * (p_nutGras(prods,"DM") / 1000);

    p_nutContent(gras(crops),prods,sys,"P")  $ (grasOutput(prods) $ (sum(m $ sum(grasOutputs, p_grasAttr(gras,grasOutputs,m)),1) eq 6)) = 0.9;
    p_nutContent(gras(crops),prods,sys,"P")  $ (grasOutput(prods) $ (sum(m $ sum(grasOutputs, p_grasAttr(gras,grasOutputs,m)),1) eq 5)) = 0.87;
    p_nutContent(gras(crops),prods,sys,"P")  $ (grasOutput(prods) $ (sum(m $ sum(grasOutputs, p_grasAttr(gras,grasOutputs,m)),1) eq 4)) = 0.81;
    p_nutContent(gras(crops),prods,sys,"P")  $ (grasOutput(prods) $ (sum(m $ sum(grasOutputs, p_grasAttr(gras,grasOutputs,m)),1) eq 3)) = 0.71;
    p_nutContent(gras(crops),prods,sys,"P")  $ (grasOutput(prods) $ (sum(m $ sum(grasOutputs, p_grasAttr(gras,grasOutputs,m)),1) eq 2)) = 0.65;
    p_nutContent(gras(crops),prods,sys,"P")  $ (grasOutput(prods) $ (sum(m $ sum(grasOutputs, p_grasAttr(gras,grasOutputs,m)),1) eq 1)) = 0.50;

    p_nutContent(past(crops),prods,sys,"P")  $ ( (grasOutput(prods) or   pastOutput(prods) ) $ (sum((grasOutputs,m), p_grasAttr(past,grasOutputs,m)*p_grasYieldMult(sys)) <=4   ))  = 0.50 * (p_nutGras(prods,"DM") / 1000);
    p_nutContent(past(crops),prods,sys,"P")  $ ( (grasOutput(prods) or   pastOutput(prods) ) $ (sum((grasOutputs,m), p_grasAttr(past,grasOutputs,m)*p_grasYieldMult(sys)) > 4   ))  = 0.65 * (p_nutGras(prods,"DM") / 1000);
    p_nutContent(past(crops),prods,sys,"P")  $ ( (grasOutput(prods) or   pastOutput(prods) ) $ (sum((grasOutputs,m), p_grasAttr(past,grasOutputs,m)*p_grasYieldMult(sys)) > 5.5 ))  = 0.71 * (p_nutGras(prods,"DM") / 1000);
    p_nutContent(past(crops),prods,sys,"P")  $ ( (grasOutput(prods) or   pastOutput(prods) ) $ (sum((grasOutputs,m), p_grasAttr(past,grasOutputs,m)*p_grasYieldMult(sys)) > 8   ))  = 0.81 * (p_nutGras(prods,"DM") / 1000);
    p_nutContent(past(crops),prods,sys,"P")  $ ( (grasOutput(prods) or   pastOutput(prods) ) $ (sum((grasOutputs,m), p_grasAttr(past,grasOutputs,m)*p_grasYieldMult(sys)) > 9   ))  = 0.87 * (p_nutGras(prods,"DM") / 1000);

$endif.cat

* --- N fixation from legumes, enters nutrient balance and fertilizer planning according to FO 17
*     Value taken from FO 17, p. 29 assuming legume share in grassland of 5 to 10%

   p_NfromLegumes(Crops,sys) $ ( grassCrops(crops)  $ ( not sameas (crops,"idleGras")) )
      = 20 + 20 $ sameas(sys,"org");

   p_NfromLegumes("summerBeans",sys) = 50;
   p_NfromLegumes("summerPeas",sys)  = 50;
   p_NfromLegumes("alfalfa",sys)     = 50;

   p_nutContOutput("WinterWheat",nut)    =    p_nutContent("winterWheat","winterWheat","conv",nut)  * 10;
   p_nutContOutput("Winterbarley",nut)   =    p_nutContent("Winterbarley","Winterbarley","conv",nut) * 10;
   p_nutContOutput("WinterRye",nut)      =    p_nutContent("WinterRye","WinterRye","conv",nut) * 10;
   p_nutContOutput("MaizCCM",nut)        =    p_nutContent("MaizCCM","MaizCCM","conv",nut) * 10;
   p_nutContOutput("sugarbeet",nut)      =    p_nutContent("sugarbeet","sugarbeet","conv",nut) * 10;
   p_nutContOutput("winterRape",nut)     =    p_nutContent("winterRape","winterRape","conv",nut) * 10;
   p_nutContOutput("WCresidues",nut)     =    p_nutContent("winterWheat","WCresidues","conv",nut)  * 10;
   p_nutContOutput("WBresidues",nut)     =    p_nutContent("winterBarley","WBresidues","conv",nut) * 10;
   p_nutContOutput("WRresidues",nut)     =    p_nutContent("winterRye","WRresidues","conv",nut)  * 10;


*
*  --- maximum rotational shares
*
   p_maxRotShare("Cere","conv",soil)            = 4/5;
   p_maxRotShare("RootCrops","conv",soil)       = 1/2;
   p_maxRotShare("Legumes","conv",soil)         = 1/2;
   p_maxRotShare("Maize","conv",soil)           =   1;

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
   p_maxRotShare("alfala","conv",soil)          = 1/3;
   p_maxRotShare("wheatGPS","conv",soil)        = 1/3;

   p_maxRotShare("MaizSil","conv",soil)        = 1;
   p_maxRotShare("MaizCorn","conv",soil)       = 1;
   p_maxRotShare("MaizCCM","conv",soil)        = 1;
   p_maxRotShare(CatchCrops(crops),"conv",soil)      = 1;

   $$iftheni.org not "%orgTill%"=="off"
       p_maxRotShare(cropShareGrp,"org",soil)   = p_maxRotShare(cropShareGrp,"conv",soil);
       p_maxRotShare("maize","org",soil)        = 1/3;

       p_minRotShare("legumes","org",soil)       = 1/4;
* https://www.oekolandbau.de/fileadmin/redaktion/oeko_lehrmittel/Fachsschulen_Agrar/Landwirtschaft/Aktualisierung_2012/flwmd01_15_2011.pdf

       p_maxRotShare("WinterWheat","org",soil)      = 1/3;
       p_maxRotShare("WinterRape","org",soil)       = 1/3;
       p_maxRotShare("WinterBarley","org",soil)     = 0.5 * (1/2+1/3);
       p_maxRotShare("WinterRye","org",soil)        = 0.5 * (1/2+1/3);
       p_maxRotShare("SummerCere","org",soil)       = 0.5 * (1/2+1/3);
       p_maxRotShare("SummerTriticale","org",soil)  = 0.5 * (1/2+1/3);
       p_maxRotShare("Potatoes","org",soil)         = 0.5 * (1/3+1/4);
       p_maxRotShare("Sugarbeet","org",soil)        = 1/5;
       p_maxRotShare("summerPeas","org",soil)       = 1/4;
       p_maxRotShare("summerBeans","org",soil)      = 1/4;
       p_maxRotShare("alfala","org",soil)           = 1/4;

   $$else.org
       option kill=p_minRotShare;
   $$endif.org


*
*  --- cost positions taken from KTBL 2012/2013, page 250 for winterwheat
*  --- winterbarley taken from ktbl 2012/2013, p.
*  --- cost for potatoes taken from KTBL 2012/2013, inputs partly ignored, no direct seed in potatoes possible (TK)
*  --- Silomais, Koernermais, CCM und Zuckerrueben hinzugefuegt  nach KTBL 2012/2013, fEUr Mais und REUben keine Direktsaat vorhanden (BL)


   $$setglobal a
   $$setglobal m
   $$setglobal v

   $$iftheni.intens "%intensoptions%"=="Default"

      $$setglobal  normal  (normal,fert80p )
      $$setglobal  midLow  (fert60p,fert40p)
      $$setglobal  verLow  (fert20p        )
      $$setglobal   empty "                 "

   $$elseifi.intens "%intensoptions%"=="Heyn_Olfs"

      $$setglobal  normal (normal,f90p,f80p,f70p)
      $$setglobal  midLow (f60p                 )
      $$setglobal   empty "                     "
      $$setglobal v *

   $$else.intens

      $$setglobal  normal  normal
      $$setglobal   empty "      "
      $$setglobal  m *
      $$setglobal  v *

   $$endif.intens
*
*  --- the %a% defaults to an empty string, while the %m%/%v% are either empty (= entry read) or a * to comment them out when not needed
*

   table p_costQuant(crops,till,intens,inputs)
*                         %empty%            Eu/ha   kg        kg      t    EU/ha  EU/ha   EU/ha       EU/ha      mEU    1000EU     kg
%a%                        %empty%             seed   KAS   PK_18_10   Lime   Herb   Fung   Insect   growthContr   water   hailIns    KaliMag
*
%a% winterWheat.org        .%normal%           155                       1                                                 1.73
%a% winterWheat.plough     .%normal%           60.0  640        400      1     45     74    13.00             2     1.2    1.17
%m% winterWheat.plough     .%midLow%                 640        360      1     30     40    13.00             2     1.2    0.79
%v% winterWheat.plough     .%verLow%                 640        320      1     15     20    13.00             2     1.2    0.62

%a% winterWheat.minTill    .%normal%           60.0  640        400      1     44     62    13.00             2     1.2    0.87
%m% winterWheat.minTill    .%midLow%                 640        360      1     30     40    13.00             2     1.2    0.79
%v% winterWheat.minTill    .%verLow%                 640        320      1     15     20    13.00             2     1.2    0.62

%a% winterWheat.noTill     .%normal%           60.0  640        400      1     55     86    13.00             2     1.5    0.87
%m% winterWheat.noTill     .%midLow%                 640        360      1     37     58    13.00             2     1.5    0.79
%v% winterWheat.noTill     .%verLow%                 640        320      1     18     30    13.00             2     1.5    0.62
*
%a% winterBarley.org       .%normal%           110.6                     1                                                 1.27
%a% winterBarley.plough    .%normal%           60.0  640        400      1     45     74    13.00             2     1.2    1.17
%m% winterBarley.plough    .%midLow%                 640        360      1     30     40    13.00             2     1.2    0.79
%v% winterBarley.plough    .%verLow%                 640        320      1     15     20    13.00             2     1.2    0.62

%a% winterBarley.minTill   .%normal%           60.0  640        400      1     44     62    13.00             2     1.2    0.87
%m% winterBarley.minTill   .%midLow%                 640        360      1     30     40    13.00             2     1.2    0.79
%v% winterBarley.minTill   .%verLow%                 640        320      1     15     20    13.00             2     1.2    0.62

%a% winterBarley.noTill    .%normal%           60.0  640        400      1     55     86    13.00             2     1.5    0.87
%m% winterBarley.noTill    .%midLow%                 640        360      1     37     58    13.00             2     1.5    0.79
%v% winterBarley.noTill    .%verLow%                 640        320      1     18     30    13.00             2     1.5    0.62

%a% winterRye   .org       .%normal%           96                        1                                                 1.42
%a% winterRye   .plough    .%normal%           68.4  440        400      1     58     70      1              35     0.9    1.1
%m% winterRye   .plough    .%midLow%           63.6  320        300      1     48     51                     17     0.6    0.83
%v% winterRye   .plough    .%verLow%                 220        220      1     43     37                     12     0.6    0.55

%a% winterRye   .minTill   .%normal%           63.6  440        400      1     58     70      1              35     0.9    1.1
%m% winterRye   .minTill   .%midLow%                 320        300      1     48     51                     17     0.6    0.83
%v% winterRye   .minTill   .%verLow%                 220        220      1     43     37                     12     0.6    0.55

%a% winterRye   .noTill    .%normal%           63.6  440        400      1     58     70       1              35    1.2    0.79
%m% winterRye   .noTill    .%midLow%                 320        300      1     58     52                      17    0.9    0.83
%v% winterRye   .noTill    .%verLow%                 220        220      1     58     37                      12    0.9    0.55

*                                              EU/ha   kg        kg      t     EU/ha  EU/ha   EU/ha          EU/ha      mEU      1000EU     kg
*                          %empty%             seed   KAS   PK_18_10   Lime   Herb   Fung   Insect   growthContr   water   hailIns    KaliMag

%a% summerCere.org        .%normal%            128.8                     1                                                 1.21
%a% summerCere.plough     .%normal%            67.2  310        320      1     40     40      1               3     0.6    0.98
%m% summerCere.plough     .%midLow%                  310        290      1     26     24                            0.6    0.55
%v% summerCere.plough     .%verLow%                  310        250      1     13     12                            0.6    0.49

%a% summerCere.minTill    .%normal%            67.2  310        320      1     40     40      1               3     0.6    0.98
%m% summerCere.minTill    .%midLow%                  310        290      1     26     24                            0.6    0.55
%v% summerCere.minTill    .%verLow%                  310        250      1     13     12                            0.6    0.49

%a% summerCere.noTill     .%normal%            67.2  310        320      1     49     58      1               3     0.6    0.98
%m% summerCere.noTill     .%midLow%                  310        290      1     30     33                            0.6    0.55
%v% summerCere.noTill     .%verLow%                  310        250      1     12     13                            0.6    0.49
*Su mmerTriticale conv based on Summerbarley
%a% summerTriticale.org   .%normal%            174                       1                                                 1.14
%a% summerTriticale.plough.%normal%             84   350        320      1     36     89      2               8     0.6    1.24
%m% summerTriticale.plough.%midLow%             73   310        320      1     36     65      1               1     0.6    1.07
%v% summerTriticale.plough.%verLow%             73   200        200      1     33     48                            0.6    0.71

%a% summerTriticale.minTill.%normal%            84   350        320      1     45     89      2               8     0.6    1.24
%m% summerTriticale.minTill.%midLow%            73   310        320      1     36     65      1               1     0.9    1.07
%v% summerTriticale.minTill.%verLow%            73   200        200      1     32     48                            0.6    0.71

%a% summerTriticale.noTill .%normal%            84   350        320      1     45     89      2               8     0.9    1.24
%m% summerTriticale.noTill .%midLow%            73   310        320      1     45     89      1               1     0.9    1.07
%v% summerTriticale.noTill .%verLow%            73   200        200      1     45     89                            0.9    0.71
*
%a% winterRape.org        .%normal%            84.2                      1                                                 1.72
%a% winterRape.plough     .%normal%            72.6  440        360      1     65     19    16.00            28     0.9    0.99
%m% winterRape.plough     .%midLow%                  440        320      1     40     15    16.00                   0.9    2.16
%v% winterRape.plough     .%verLow%                  440        280      1     20     10    16.00                   0.9    1.94

%a% winterRape.minTill    .%normal%            72.6  440        360      1     65     19    16.00            28     0.9    0.99
%m% winterRape.minTill    .%midLow%                  440        320      1     40     15    16.00                   0.9    2.16
%v% winterRape.minTill    .%verLow%                  440        280      1     20     10    16.00                   0.9    1.94

%a% winterRape.noTill     .%normal%            72.6  440        360      1     79     35    16.00            28     1.2    0.99
%m% winterRape.noTill     .%midLow%                  440        320      1     40     18    16.00                   1.2    2.16
%v% winterRape.noTill     .%verLow%                  440        280      1     20     12    16.00                   1.2    1.94

%a% potatoes.org          .%normal%          2625                        1           168    60.00                   1800   15
%a% potatoes.plough       .%normal%          1171.6  580        400      1     126   156    13.00                   2.4    6.75       660
%m% potatoes.plough       .%midLow%
%v% potatoes.plough       .%verLow%

%a% potatoes.minTill      .%normal%          1171.6  580        400      1     126   156    13.00                   2.4    6.75       660
%m% potatoes.minTill      .%midLow%
%v% potatoes.minTill      .%verLow%

%a% potatoes.noTill       .%normal%
%m% potatoes.noTill       .%midLow%
%v% potatoes.noTill       .%verLow%

%a% maizsil.org          .%normal%            290                        1
%a% maizsil.plough       .%normal%            195.8  400         500     1     69                                   0.6
%m% maizsil.plough       .%midLow%
%v% maizsil.plough       .%verLow%

%a% maizsil.minTill      .%normal%            195.8  400         500     1     69                                   0.6
%m% maizsil.minTill      .%midLow%
%v% maizsil.minTill      .%verLow%

%a% maizsil.noTill       .%normal%
%m% maizsil.noTill       .%midLow%
%v% maizsil.noTill       .%verLow%

%a% maizcorn.org          .%normal%           264                        1                                                  2.03
%a% maizcorn.plough       .%normal%           184    240         80      1      69                                  0.6     1.49
%m% maizcorn.plough       .%midLow%
%v% maizcorn.plough       .%verLow%

%a% maizcorn.minTill      .%normal%           184    240         80      1      69                                  0.6     1.49
%m% maizcorn.minTill      .%midLow%
%v% maizcorn.minTill      .%verLow%

%a% maizcorn.noTill       .%normal%
%m% maizcorn.noTill       .%midLow%
%v% maizcorn.noTill       .%verLow%

%a% maizCCM.plough       .%normal%             184  240         80      1      69                                  0.6     1.1
%m% maizCCM.plough       .%midLow%
%v% maizCCM.plough       .%verLow%

%a% maizCCM.minTill      .%normal%             184  240         80      1      69                                  0.6     1.1
%m% maizCCM.minTill      .%midLow%
%v% maizCCM.minTill      .%verLow%

%a% maizCCM.noTill       .%normal%
%m% maizCCM.noTill       .%midLow%
%v% maizCCM.noTill       .%verLow%

%a% sugarbeet.org          .%normal%           283                       1                                                  5.25
%a% sugarbeet.plough       .%normal%           203   400         600     1     192    29      13                    0.9     2.22
%m% sugarbeet.plough       .%midLow%
%v% sugarbeet.plough       .%verLow%

%a% sugarbeet.minTill      .%normal%           203   400         600     1     192    29      13                    0.9     2.22
%m% sugarbeet.minTill      .%midLow%
%v% sugarbeet.minTill      .%verLow%

%a% sugarbeet.noTill       .%normal%
%m% sugarbeet.noTill       .%midLow%
%v% sugarbeet.noTill       .%verLow%

%a% summerbeans.org          .%normal%         227                       1                                                   1.6
%a% summerbeans.plough       .%normal%          97               360     1     64     3        9                    0.6      0.54
%m% summerbeans.plough       .%midLow%
%v% summerbeans.plough       .%verLow%

%a% summerbeans.minTill      .%normal%          97               360     1     64     3        9                    0.6      0.54
%m% summerbeans.minTill      .%midLow%
%v% summerbeans.minTill      .%verLow%

%a% summerbeans.noTill       .%normal%          97               360     1     78     3        9                    0.6      0.54
%m% summerbeans.noTill       .%midLow%
%v% summerbeans.noTill       .%verLow%

%a% summerpeas.org          .%normal%           281                      1                                                   1.37
%a% summerpeas.plough       .%normal%           92               300     1     69             10                    0.6      0.53
%m% summerpeas.plough       .%midLow%
%v% summerpeas.plough       .%verLow%

%a% summerpeas.minTill      .%normal%           92               300     1     69             10                    0.6      0.53
%m% summerpeas.minTill      .%midLow%
%v% summerpeas.minTill      .%verLow%

%a% summerpeas.noTill       .%normal%           92               300     1     78             10                    0.6      0.53
%m% summerpeas.noTill       .%midLow%
%v% summerpeas.noTill       .%verLow%

%a% alfalfa.org             .%normal%           97                      1
%a% alfalfa.plough          .%normal%           41               300   0.25    41                                            0.53
%m% alfalfa.plough          .%midLow%           41               300   0.25    41                                            0.53
%v% alfalfa.plough          .%verLow%           41               300   0.25    41                                            0.53

%a% alfalfa.minTill       .%normal%             41               300   0.25    41                                            0.53
%m% alfalfa.minTill       .%midLow%             41               300   0.25    41                                            0.53
%v% alfalfa.minTill       .%verLow%             41               300   0.25    41                                            0.53

%a% wheatGPS.org           .%normal%            126                      1
%a% wheatGPS.plough       .%normal%             60   720         700     1     45     53                            0.6
%m% wheatGPS.plough       .%midLow%
%v% wheatGPS.plough       .%verLow%

%a% wheatGPS.minTill      .%normal%             60   720         700     1     45     53                            0.6
%m% wheatGPS.minTill      .%midLow%
%v% wheatGPS.minTill      .%verLow%

%a% wheatGPS.noTill       .%normal%             60   720         700     1     56     53                            0.9
%m% wheatGPS.noTill       .%midLow%
%v% wheatGPS.noTill       .%verLow%

*                          %empty%             seed   KAS   PK_18_10   Lime   Herb   Fung   Insect   growthContr   water   hailIns    KaliMag
%a% CCmustard.org          .%normal%            51
%a% CCmustard.plough       .%normal%            31
%m% CCmustard.plough       .%midLow%
%v% CCmustard.plough       .%verLow%

%a% CCmustard.minTill      .%normal%            31
%m% CCmustard.minTill      .%midLow%
%v% CCmustard.minTill      .%verLow%

%a% CCclover.org           .%normal%            96
%a% CCclover.plough        .%normal%            31
%m% CCclover.plough        .%midLow%
%v% CCclover.plough        .%verLow%

%a% CCclover.minTill       .%normal%            31
%m% CCclover.minTill       .%midLow%
%v% CCclover.minTill       .%verLow%


%a% (set.gras).noTill      .%normal%           10    50
%a% (set.gras).org         .%normal%           10
 ;

  p_costQuant(crops,till,intens,inputs) $ (not p_costQuant(crops,till,intens,inputs)) = p_costQuant(crops,till,"normal",inputs);
*
*   --- mineral fertilizers costs are endngenous and deleted from KTBL table
*
    p_costQuant(crops,till,intens,"PK_18_10") = no;
    p_costQuant(crops,till,intens,"KAS")      = no;

$else.mode


   $$ifthen.Heyn_Olfs "%intensoptions%"=="Heyn_Olfs"


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

*    --- Calcualtion the yield reduction in % caused by a N fertilizer reduction in %

      p_yieldReducN(crops,intens) $ ( (not sameas (intens,"normal")) $ p_intens(crops,intens))
                                      =   p_NrespFunct(crops,"a") * sqr(p_intens(crops,intens)*100)
                                        + p_NrespFunct(crops,"b") * p_intens(crops,intens)*100
                                        + p_NrespFunct(crops,"c") ;

   $$endif.Heyn_Olfs

*
* --- Definition of nutrients provided from the soil required for Fertilization = Default
*

* --- Nutrient provided from atmospheric deposition

   p_basNut(crops,soil,till,"NAtmos","N",t) $ sum(prods, p_OCoeffC(crops,soil,till,"normal",prods,t))  =  18;

* --- Nutrient provided from N mineralization in spring based on LWK NRW [updated 2/2021]

   p_basNut("winterWheat",soil,till,"Nmin","N",t)       $ sum(prods, p_OCoeffC("winterWheat",soil,till,"normal",prods,t))     = 44;
   p_basNut("wheatGPS",soil,till,"Nmin","N",t)          $ sum(prods, p_OCoeffC("wheatGPS",soil,till,"normal",prods,t))        = 44;
*
*  --- the 54 kg does not work with low intensities as + 18 kg from atmosphere added (WP, 10.02.21)
*
   p_basNut("SummerCere",soil,till,"Nmin","N",t)        $ sum(prods, p_OCoeffC("SummerCere",soil,till,"normal",prods,t))      = 44;
   p_basNut("SummerTriticale",soil,till,"Nmin","N",t)   $ sum(prods, p_OCoeffC("SummerTriticale",soil,till,"normal",prods,t)) = 44;
   p_basNut("winterBarley",soil,till,"Nmin","N",t)      $ sum(prods, p_OCoeffC("winterBarley",soil,till,"normal",prods,t))    = 24;
   p_basNut("winterRye",soil,till,"Nmin","N",t)         $ sum(prods, p_OCoeffC("winterRye",soil,till,"normal",prods,t))       = 31;
   p_basNut("winterRape",soil,till,"Nmin","N",t)        $ sum(prods, p_OCoeffC("winterRape",soil,till,"normal",prods,t))      = 24;
   p_basNut("maizCorn",soil,till,"Nmin","N",t)          $ sum(prods, p_OCoeffC("maizCorn",soil,till,"normal",prods,t))        = 51;
   p_basNut("sugarBeet",soil,till,"Nmin","N",t)         $ sum(prods, p_OCoeffC("sugarBeet",soil,till,"normal",prods,t))       = 52;
   p_basNut("maizSil",soil,till,"Nmin","N",t)           $ sum(prods, p_OCoeffC("maizSil",soil,till,"normal",prods,t))         = 51;
   p_basNut("MaizCCM",soil,till,"Nmin","N",t)           $ sum(prods, p_OCoeffC("MaizCCM",soil,till,"normal",prods,t))         = 51;
   p_basNut("potatoes",soil,till,"Nmin","N",t)          $ sum(prods, p_OCoeffC("potatoes",soil,till,"normal",prods,t))        = 52;

   p_basNut(crops,soil,till,"Nmin","N",t) $ ( p_basNut(crops,soil,till,"Nmin","N",t) eq 0 ) = 30 ;

*
*   --- yield mode, define here (overwrite)
*
*       p_nutNeed(crops,soil,till,intens,nut,t)   <=> nutrient per ha of crops, needs to covered by manure speading,
*                                                     synthetic, excretion on pasture and background
*       p_basNut(crops,soil,till,nut,t)           <=> background deliveries (atmospheric deposition, mineralization ...)
*
*       p_syntAppLosShare(syntFertilizer,soil,till,intens,nutLosses)
*

*
*   --- Definition of residue removal for different crops
*       Main product - resiude relation multiplied with yield, factor based on Fertilzation Ordinance 2017, p. 31f.

   p_OCoeffResidues("winterWheat",soil,till,intens,"WCresidues",t)   $ sum(soil_plot(soil,plot), c_p_t_i("winterWheat",plot,till,intens) )
              =  0.8 *  p_OCoeffC("winterWheat",soil,till,intens,"winterWheat",t) ;
   p_OCoeffResidues("summerCere",soil,till,intens,"SCresidues",t)   $ sum(soil_plot(soil,plot), c_p_t_i("summerCere",plot,till,intens) )
              =  0.8 *  p_OCoeffC("summerCere",soil,till,intens,"summerCere",t) ;
   p_OCoeffResidues("winterBarley",soil,till,intens,"WBresidues",t) $ sum(soil_plot(soil,plot), c_p_t_i("winterBarley",plot,till,intens) )
              =  0.7 *  p_OCoeffC("winterBarley",soil,till,intens,"winterBarley",t);
   p_OCoeffResidues("summerTriticale",soil,till,intens,"STresidues",t)   $ sum(soil_plot(soil,plot), c_p_t_i("summerTriticale",plot,till,intens) )
              =  0.8 *  p_OCoeffC("summerTriticale",soil,till,intens,"summerTriticale",t) ;
   p_OCoeffResidues("winterRye",soil,till,intens,"WRresidues",t) $ sum(soil_plot(soil,plot), c_p_t_i("winterRye",plot,till,intens) )
              =  0.7 *  p_OCoeffC("winterRye",soil,till,intens,"winterRye",t);

* --- Variable costs of straw removal, based on LWK Strohpreisrechner
*     LWK Nds. 2018. Strohpreisrechner, Chamber of Agriculture Lower Saxony (LWK Nds.), https://?www.lwk-niedersachsen.de?/?download.cfm/?file/?30111.html (accessed 07.12.18).

   p_vCostStrawRemoval("winterWheat",plot,till,intens,t)   $  c_p_t_i("winterWheat",plot,till,intens)     =
                             sum ( (soil_plot(soil,plot)) ,  p_OCoeffResidues("winterWheat",soil,till,intens,"WCresidues",t))   * 75 * %EXR%;

   p_vCostStrawRemoval("winterBarley",plot,till,intens,t) $  c_p_t_i("winterBarley",plot,till,intens) =
                             sum ( (soil_plot(soil,plot)) ,  p_OCoeffResidues("winterBarley",soil,till,intens,"WBresidues",t)) * 75 * %EXR%;

   p_vCostStrawRemoval("summerCere",plot,till,intens,t)   $  c_p_t_i("summerCere",plot,till,intens)    =
                             sum ( (soil_plot(soil,plot)) ,  p_OCoeffResidues("summerCere",soil,till,intens,"SCresidues",t))   * 75 * %EXR%;

   p_vCostStrawRemoval("winterRye",plot,till,intens,t) $  c_p_t_i("winterRye",plot,till,intens) =
                             sum ( (soil_plot(soil,plot)) ,  p_OCoeffResidues("winterRye",soil,till,intens,"WRresidues",t)) * 75 * %EXR%;

   p_vCostStrawRemoval("summerTriticale",plot,till,intens,t)   $  c_p_t_i("summerTriticale",plot,till,intens)    =
                             sum ( (soil_plot(soil,plot)) ,  p_OCoeffResidues("summerTriticale",soil,till,intens,"STresidues",t))   * 75 * %EXR%;

*
*  --- Additional variable costs linked to fast rotational grazing
*
   $$ifi defined rotationalGraz p_vCostC(rotationalGraz,till,intens,t) = 37.5 * %EXR%;
*
*  --- Variable costs, inflated
*
   p_vCostC(idle,till,intens,t) $ sum(c_p_t_i(idle,plot,till,intens),1)  =   40 * %EXR% * [1+%outputPriceGrowthRate%/100]**t.pos;

$endif.mode
