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

* --- load crops currently selected
      set set_crops_and_prods "crop and products of the same name"

    $$GDXIN "%datDir%/%cropsFile%.gdx"
       $$LOAD set_crops_and_prods=crops
    $$GDXIN

alias(set_crops_and_prods,crops);

* --- load yield and price data for selected crops
   parameter
      p_cropPrice(*,*)
      p_cropYield(*,*)
    ;

   $$GDXIN "%datDir%/%cropsFile%.gdx"
      $$LOAD  p_cropYield, p_cropPrice
   $$GDXIN


$elseifi.mode "%1"=="decl"

  Set add_crops /
      CCmustard
      CCmustardAES
      CCclover
      CCmustardAESGreening
      flowerStrip
      flowerStripGre
      waterStrip
      waterStripGre      
      idleES1_1
      flowerStripES1_1
      idleES1_1_2
      flowerStripES1_1_2
      idleES1_2_6
      flowerStripES1_2_6
    /;

  set acts / set.add_crops /;
  set crops(acts) / set.add_crops /;


  set catchCrops(crops) "Catch crops" /
    CCmustard,
    CCmustardAES,
    CCmustardAESGreening
    CCclover
    set.catchcropsGDX
  /;

  set standardCatchCrops(catchCrops) /
    CCmustard,
    CCclover
  /;


* --- define month in which selected crops are growing
   set monthGrowthCrops(crops,sys,m) "Crosssets linking crops to month when the crop is growing";

   $$GDXIN "%datDir%/%cropsFile%.gdx"
      $$LOAD   monthGrowthCrops
   $$GDXIN


    set cropShareGrp "Crop group with maximal shares" / cere,rootCrops,legumes,maize,grainleg/;

    set cropShareGrp_crops(cropShareGrp,crops) / cere.(set.cere)
                                             rootCrops.(set.rootCrops)
                                             legumes.(set.leg)
                                             maize.(set.maize)
                                             grainleg.(set.grainleg)
                          /;
*
* --- predefined crop rotations
*

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

    set rot "Rotations" / MA_MA_MA_MA_MA_MA_MA
                          MA_WW_WB_MA_WW_WB_MA
                          WW_WB_WW_WB_WW_WB_WW
                          ID_ID_ID_ID_ID_ID_ID
                        /;

   set curRot(rot);

     alias(crops,c1,c2,c3,c4,c5,c6);

   set rot_crop(rot,crops,crops,crops,crops,crops,crops,crops)  "Rotation, first to seventh year"/
               MA_MA_MA_MA_MA_MA_MA.maizSil.maizSil.maizSil.maizSil.maizSil.maizSil.maizSil
               MA_WW_WB_MA_WW_WB_MA.maizSil.winterWheat.WinterBarley.maizSil.winterWheat.WinterBarley.maizSil
               WW_WB_WW_WB_WW_WB_WW.winterWheat.WinterBarley.winterWheat.WinterBarley.winterWheat.WinterBarley.winterWheat
               ID_ID_ID_ID_ID_ID_ID.idle.idle.idle.idle.idle.idle.idle
                                    /;

*
* --- Links the rotations to the crops in the specific year reaching from 0 to 6. The position of crops
*     in the $ operator defines which position is currently reflected. Alias do not enter.
*
   set crop0_rot(crops,rot);crop0_rot(crops,rot)  $ sum(rot_crop(rot,crops,c1,c2,c3,c4,c5,c6),1) = YES; 
   set crop1_rot(crops,rot);crop1_rot(crops,rot)  $ sum(rot_crop(rot,c1,crops,c2,c3,c4,c5,c6),1) = YES; 
   set crop2_rot(crops,rot);crop2_rot(crops,rot)  $ sum(rot_crop(rot,c1,c2,crops,c3,c4,c5,c6),1) = YES; 
   set crop3_rot(crops,rot);crop3_rot(crops,rot)  $ sum(rot_crop(rot,c1,c2,c3,crops,c4,c5,c6),1) = YES; 
   set crop4_rot(crops,rot);crop4_rot(crops,rot)  $ sum(rot_crop(rot,c1,c2,c3,c4,crops,c5,c6),1) = YES; 
   set crop5_rot(crops,rot);crop5_rot(crops,rot)  $ sum(rot_crop(rot,c1,c2,c3,c4,c5,crops,c6),1) = YES; 
   set crop6_rot(crops,rot);crop6_rot(crops,rot)  $ sum(rot_crop(rot,c1,c2,c3,c4,c5,c6,crops),1) = YES; 

   parameter p_cropRotShare "Estimates share of crops in rotation, needed to link v_cropha to v_rotHa";
     
   p_cropRotShare(crops,rot) = (      1 $ crop0_rot(crops,rot)
                                    + 1 $ crop1_rot(crops,rot)
                                    + 1 $ crop2_rot(crops,rot)
                                    + 1 $ crop3_rot(crops,rot)
                                    + 1 $ crop4_rot(crops,rot)
                                    + 1 $ crop5_rot(crops,rot)
                                    + 1 $ crop6_rot(crops,rot)
                                     ) / 7;
$endif.compStat

   set cropTypes / winterCere,SummerCere,Other,Potatoes,Sugarbeet,Idle/;








$elseifi.mode %1==param

*
* --- (A) MONTH WHEN MANURE AND CHEMICAL FERTILIZER APPLICATION IS NOT POSSIBLE FOR AGRONOMIC REASONS
*         values for chemical fertilizer old; for manure assumptions that month for harvest no application is possible (own judgement, needs revision) [TK 19/09/17]
*         The values were adopted for the KTBL crops. So far there are no values for KTBL crops that are not included in the subsets (JH 22/02/2021)

   set doNotApplySyn(crops,m)   /
                                set.summerCere     .(May,Jun,Jul)
                                set.maize          .(May,Jun,Jul)
* --- in addition to month of maize:
                                set.maizSilage     .(Apr,Aug,Sep)
                                set.winterCere     .(Jun,Jul)
                                set.potatoes       .(May,Jun,Jul,Aug)
                                set.rapeseed       .(May,Jun,Jul,Aug)
                                idle               .(set.m)
                                idleGras           .(set.m)

                               /;


   set doNotApplyManure(crops,m) /
                                 set.potatoes           .(Jun,Jul,Aug)
                                 set.maize              .(Jun,Jul,Aug)
                                 set.sugarbeet          .(Jun,Jul,Aug)
                                 set.rapeseed           .(May,Jun,Jul)
                                 set.summerCere         .(May,Jun,Jul)
                                 set.WinterCere         .(Apr,May,Jun,Jul)
                                /;

* --- manure application not allowed in the month of harvest and in the month before harvest

   set monthHarvestCrops(crops,sys,m);

 $$GDXIN "%datDir%/%cropsFile%.gdx"
    $$LOAD   monthHarvestCrops
 $$GDXIN


   doNotApplyManure(crops,m)  $ sum((sys,till), monthHarvestCrops(crops,sys,m))                          = YES ;
   doNotApplyManure(crops,m)  $(ord(m) = (sum((m1),((ord(m1)-1) $ monthHarvestCrops(crops,"conv",m1))))) = YES ;
   doNotApplyManure(crops,m)  $(ord(m) = (sum((m1),((ord(m1)-1) $ monthHarvestCrops(crops,"org",m1)))))  = YES ;

*
* --- Post harvest loss of roughages
*
 $$GDXIN "%datDir%/%cropsFile%.gdx"
   $$LOAD   p_storageLoss
 $$GDXIN

*
* --- post harvest losses not yet defined
*
   p_storageLoss(crops)          $ (not p_storageLoss(crops))          = 1   ;
   p_storageLoss(catchcrops)     $ (not p_storageLoss(catchcrops))     = 0.9 ;
$iftheni.cat %cattle% == true
   p_storageLoss("earlyGrasSil") =  0.9  ;
   p_storageLoss("middleGrasSil")=  0.9  ;
   p_storageLoss("lateGrasSil")  =  0.9  ;
   p_storageLoss("earlyGraz")    =  1    ;
   p_storageLoss("middleGraz")   =  1    ;
   p_storageLoss("lateGraz")     =  1    ;
   p_storageLoss("hay")          =  0.7  ;
   p_storageLoss("hayM")         =  0.7  ;
   p_storageLoss("grasM")        =  0.7  ;

$endif.cat

* ---- N content of crops in kg N/dt fresh matter according to DUEV 2006, Anlage 1
* ---- P content of crops in kg P/dt fresh matter and N content of maizCCM according to LWK NRW
* ---- N and P removal via product and crop residues (Nebenernteprodukt) is calculated as HF + HNV * NF (D�V 2006, Anlage 1)
* ---- Assumption: crop residues are taken away from the field  (except of potatoes, rape, beets, beans, peas, maizCorn,MaizCCM)

   $$GDXIN "%datDir%/%cropsFile%.gdx"
      $$LOAD   p_nutContent
   $$GDXIN

*
* --- load data related to fertilization  according to organic farming
*
  $$iftheni.org %Fertilization% == "OrganicFarming"

   $$GDXIN "%datDir%/%cropsFile%.gdx"
* --- nutcontent in whole plant in kg N/dt FM
     $$LOAD   p_NcontShoot p_NcontPlant
*---data related to N fixation by legumes
     $$LOAD   p_legshare p_Ndfa
* --- Nitrogen content of seeds
     $$LOAD p_nutSeeds
* --- Nitrogen delivery from soil during vegetation period
     $$LOAD p_NSoilDelivery
* --- data related to uptake from N from crop residues
     $$LOAD p_NUpCoeffRes
 $$GDXIN
$$endif.org


*for KTBL crops, org Yield is defined
   parameter p_organicYieldMult(crops) /
         (set.grassCrops)    0.50
         (set.arableCrops)   0.5
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

*
*   --- Definition of residue removal for different crops
*       Main product - resiude relation multiplied with yield, factor based on Fertilzation Ordinance 2017, p. 31f.


   set crop_residues(prodsResidues,crops) "crossset of crops to residues";

   $$GDXIN "%datDir%/%cropsFile%.gdx"
      $$LOAD   crop_residues
   $$GDXIN

* --- Nut content of removed residues, possible for cereal production

   p_nutContent(crops,prodsResidues,sys,"N") $crop_residues(prodsResidues,crops)     =  0.5 ;
   p_nutContent(crops,prodsResidues,sys,"P") $crop_residues(prodsResidues,crops)     =  0.3 ;

*
* --- Assumption that certain share of plant nutrient need has to be provided as mineral fertilizer
*     Assumptions are based on work from Thomas Gaiser and discussion in the USL project, see also the protocol
*     from the USL meeting 15/02/18
*
* --- Share can vary for sensitivity analysis defined by GUI, raps excludes as there is the danger of exceeding the total N need

** " 40 / (actual Yield * nutContent * 10)"
   p_minChemFert(wintercere,"N") $ p_cropYieldInt(wintercere,"conv")
                             = sum(prods $sameas(wintercere,prods),
                                 40 / (p_cropYieldInt(wintercere,"conv") *10 *p_nutContent(wintercere,prods,"conv","N"))) ;

   p_minChemFert(summercere,"N") $ p_cropYieldInt(summercere,"conv")
                             = sum(prods $sameas(summercere,prods),
                                 10 / (p_cropYieldInt(summercere,"conv") *10 *p_nutContent(summercere,prods,"conv","N"))) ;

   p_minChemFert(rapeseed,"N") $ p_cropYieldInt(rapeseed,"conv")
                             = sum(prods $sameas(rapeseed,prods),
                                 70 / (p_cropYieldInt(rapeseed,"conv") *10 *p_nutContent(rapeseed,prods,"conv","N"))) ;

   p_minChemFert(sugarBeet,"N") $ p_cropYieldInt(sugarBeet,"conv")
                             = sum(prods $sameas(sugarBeet,prods),
                                 30 / (p_cropYieldInt(sugarBeet,"conv") *10 *p_nutContent(sugarBeet,prods,"conv","N"))) ;

* --- The minimum amount of mineral N in maize is based on the assumption that 20 kg of P are provided as Diammonphosphat which
*     also contains N (Diammonsphosphat 46% P, 18% N


   p_minChemFert(maize,"P") $ p_cropYieldInt(maize,"conv")
                         = sum(prods $sameas(maize,prods),
                                 20 / (p_cropYieldInt(maize,"conv") *10 *p_nutContent(maize,prods,"conv","P"))) ;

   p_minChemFert(maize,"N") $ p_cropYieldInt(maize,"conv")
                         = sum(prods $sameas(maize,prods),
                                 8 / (p_cropYieldInt(maize,"conv") *10 * p_nutContent(maize,prods,"conv","N"))) ;



* --- N fixation from legumes, enters nutrient balance and fertilizer planning according to FO 17
*     Value taken from FO 17, p. 29 assuming legume share in grassland of 5 to 10% for conventionel and 10-20%


    $$GDXIN "%datDir%/%cropsFile%.gdx"
       $$iftheni.data "%database%" == "KTBL_database"
          $$LOAD   p_NfromVegetables
       $$else.data
       option kill = p_NfromVegetables;
       $$endif.data
       $$load p_NfromLegumes
    $$GDXIN


   p_NfromLegumes(Crops,sys) $ ( grassCrops(crops)  $ ( not sameas (crops,"idleGras")) )
        = 20 + 20 $ sameas(sys,"org");



*
* p_nutContentPut defined to calculate the Farm-gate balance relevant for FO 17, 20, only defined for some crops under conventionel production
*


   p_nutContOutput(prodsYearly,nut) $ sum(wintercere $sameas(prodsYearly,winterCere),1)
              =sum((wintercere) $ sameas(winterCere,prodsYearly), p_nutContent(Wintercere,prodsYearly,"conv",nut)* 10);
   p_nutContOutput(prodsYearly,nut) $ sum(maize $sameas(prodsYearly,maize),1)
              =sum((maize) $ sameas(maize,prodsYearly),  p_nutContent(maize,prodsYearly,"conv",nut)* 10);
   p_nutContOutput(prodsYearly,nut) $ sum(sugarBeet $sameas(prodsYearly,sugarBeet),1)
              =sum((sugarBeet) $ sameas(sugarBeet,prodsYearly),  p_nutContent(sugarBeet,prodsYearly,"conv",nut)* 10);
   p_nutContOutput(prodsYearly,nut) $ sum(rapeseed $sameas(prodsYearly,rapeseed),1)
              =sum((rapeseed) $ sameas(rapeseed,prodsYearly),  p_nutContent(rapeseed,prodsYearly,"conv",nut)* 10);

   p_nutContOutput(prodsYearly,nut) $ sum(prodsResidues $sameas(prodsYearly,prodsResidues),1)
             =sum((crops,prodsResidues)
             $ sameas(prodsResidues,prodsYearly),
             p_nutContent(crops,prodsYearly,"conv",nut)* 10
             $ crop_residues(prodsResidues,crops));
*
*p_nutContOutput(prodsResidues,nut) $ sum(crop_residues(prodsResidues,crops), p_cropYieldInt(crops,"conv"))
*                                  = sum(crops, p_nutContent(crops,prodsResidues,"conv",nut)  * 10 $crop_residues(prodsResidues,crops));
*

*
*  --- maximum rotational shares
*

* --- values for KTBL crops not yet approved (everything 0.5)

   $$GDXIN "%datDir%/%cropsFile%.gdx"
      $$LOAD   p_maxRotShare
   $$GDXIN

      p_maxRotShare("Cere","conv",soil)              = 4/5;
      p_maxRotShare("RootCrops","conv",soil)         = 1/2;
      p_maxRotShare("Legumes","conv",soil)           = 1/2;
      p_maxRotShare("Maize","conv",soil)             = 1.0;
      p_maxRotShare(CatchCrops(crops),"conv",soil)   = 1.0;

**   -> for now take organic value if larger!
     p_maxRotShare(crops,"conv",soil) $ (p_maxRotShare(crops,"conv",soil)
               $ (p_maxRotShare(crops,"conv",soil) lt p_maxRotShare(crops,"org",soil)))  =  p_maxRotShare(crops,"org",soil);

   $$iftheni.org not "%orgTill%"=="off"
       p_maxRotShare(cropShareGrp,"org",soil)   = p_maxRotShare(cropShareGrp,"conv",soil);
       p_maxRotShare(maize,"org",soil)               = 1/3;
       p_maxRotShare("grainleg","org",soil)          = 0.20;
       p_minRotShare("legumes","org",soil)           = 0.25;

   $$else.org
       option kill=p_minRotShare;
   $$endif.org




   $$setglobal a
   $$setglobal m
   $$setglobal v

   $$iftheni.intens "%intensoptions%"=="Default"

      $$setglobal  normal  (normal,fert80p )
      $$setglobal  midLow  (fert60p,fert40p)
      $$setglobal  verLow  (fert20p        )
   $$setglobal empty   "                                    "

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

   set unit;
   $$GDXIN "%datDir%/%cropsFile%.gdx"
      $$iftheni.data "%database%" == "KTBL_database"
         $$LOAD unit
      $$endif.data
      $$load p_costQuant p_inputQuant
   $$GDXIN


    p_costQuant("CCmustard","org","normal","seed")    = 51;
    p_costQuant("CCmustard","plough","normal","seed") = 31;
    p_costQuant("CCmustard","mintill","normal","seed")    = 31;

    p_costQuant("CCclover","org","normal","seed") = 96;
    p_costQuant("CCclover","plough","normal","seed")    = 31;
    p_costQuant("CCclover","mintill","normal","seed")    = 31;

    p_costQuant(gras,"notill","normal","seed")    = 31;
    p_costQuant(gras,"notill","normal","KAS")     = 50;
    p_costQuant(gras,"org","normal","seed")       = 10;


    p_costQuant(crops,till,intens,inputs)  $ (not p_costQuant(crops,till,intens,inputs)) =p_costQuant(crops,till,"normal",inputs);
*
*   --- mineral fertilizers costs are endngenous and deleted from KTBL table
*
    p_costQuant(crops,till,intens,"PK_18_10") = no;
    p_costQuant(crops,till,intens,"KAS")      = no;

*
* --- some plant protection costs need to be assumed to cover yield depression effects, increase in plant protection cost (in templ)
*
    p_costQuant(crops,"org",intens,"fung") $ ( not sum(pesticides, p_costQuant(crops,"org",intens,pesticides))) = 10;

   $$iftheni.data "%database%" == "KTBL_database"
      p_inputQuant(crops,till,intens,inputs,unit) $ (sum(plot, c_p_t_i(crops,plot,till,intens)) $ (not p_inputQuant(crops,till,intens,inputs,unit))) =p_inputQuant(crops,till,"normal",inputs,unit);
   $$else.data
      p_inputQuant(crops,till,intens,inputs,"") $ (sum(plot, c_p_t_i(crops,plot,till,intens))) =p_inputQuant(crops,till,"normal",inputs,"");
   $$endif.data
$else.mode


   $$ifthen.Heyn_Olfs "%intensoptions%"=="Heyn_Olfs"


*    --- (2) Heyn, Olfgs - Definition of different crop intensities
*

*    --- Calculating different crop intensities based on date in Fruchtfolge (Pahmeyer) which was derived from Heyn, J., Olfs, H.-W., 2018. Wirkungen reduzierter
*        N-Düngung auf Produktivität, Bodenfruchtbarkeit und N-Austragsgefährdung - Beurteilung anhand mehrjähriger Feldversuche,
*        VDLUFA-Schriftenreihe. VDLUFA-Verlag, Darmstadt.

*    --- Corresponding regression function: ax^2+bx + c

       set value /a,b,c/;
       parameter p_NrespFunct(crops,value);

    $$GDXIN "%datDir%/%cropsFile%.gdx"
       $$LOAD   p_NrespFunct
    $$GDXIN


*    --- Calcualtion the yield reduction in % caused by a N fertilizer reduction in %

      p_yieldReducN(crops,intens) $ ( (not sameas (intens,"normal")) $ p_intens(crops,intens))
                                      =   p_NrespFunct(crops,"a") * sqr(p_intens(crops,intens)*100)
                                        + p_NrespFunct(crops,"b") * p_intens(crops,intens)*100
                                        + p_NrespFunct(crops,"c") ;

   $$endif.Heyn_Olfs

*
* --- Definition of nutrients provided from the soil
*
   parameter p_Nmin(crops);

   $$GDXIN "%datDir%/%cropsFile%.gdx"
      $$LOAD   p_Nmin
   $$GDXIN

  $$iftheni.fert %fertilization% ==  OrganicFarming
* ---Nitrogen provided by wet, cloud/fog and dry deposition
*  (total N deposition on arable land in NRW; German average arable land: 18.68kg N/ha)
*  https://www.umweltbundesamt.de/sites/default/files/medien/461/publikationen/4444.pdf S.58

*  use p_NExtractShoot instead of  p_OCoeffC as some crops are not harvested (e.g. clover grass)
   p_basNut(crops,soil,till,"Ndepos","N",t)   $ (p_NExtractShoot(Crops,soil,till,"normal",t) $(not sum(catchcrops, sameas(crops,catchcrops)))) = 26.03;


*
* ---Nitrogen provided by asymbiotic N fixation, according to KTBL 2004: Nährstoffmanagement im Ökologischen Landbau
*
   p_basNut(crops,soil,till,"NasymFix","N",t) $ (p_NExtractShoot(Crops,soil,till,"normal",t) $(not sum(catchcrops, sameas(crops,catchcrops))))  =  5;

  $$else.fert

* --- Nutrient provided from atmospheric deposition

   p_basNut(crops,soil,till,"NAtmos","N",t) $ sum(prods, p_OCoeffC(crops,soil,till,"normal",prods,t))  =  18;

  $$endif.fert

* --- Nutrient provided from N mineralization in spring based on LWK NRW [updated 2/2021]

   p_basNut(crops,soil,till,"Nmin","N",t)       $ sum(prods, p_OCoeffC(crops,soil,till,"normal",prods,t))     = p_Nmin(crops);

* --- N mineralization in spring is 7 kg N/ha lower under organic production
*     http://www.tll.de/www/daten/untersuchungswesen/boden_duenger/pdf/nmin0710.pdf

   p_basNut(crops,soil,"org","Nmin","N",t) $ p_basNut(crops,soil,"org","Nmin","N",t) = p_basNut(crops,soil,"org","Nmin","N",t) - 7;


*
* --- not used as it assigns value to crops that shouldnt have Nmin value (catch crops, permanent grassland and multiple harvest forage crops)
*
*
*   p_basNut(crops,soil,till,"Nmin","N",t) $ ( sum(prods, p_OCoeffC(crops,soil,till,"normal",prods,t)) and
*                                               p_basNut(crops,soil,till,"Nmin","N",t) eq 0 ) = 30 ;

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

   parameter p_residue_ratio(prodsResidues) "Main product - resiude relation";

   $$GDXIN "%datDir%/%cropsFile%.gdx"
      $$LOAD   p_residue_ratio
   $$GDXIN

*parameter p_OCoeffResidues(crops,soil,till,intens,prods,t);

   p_OCoeffResidues(cropsResidueRemo,soil,till,intens,prodsResidues,t)  $ sum(soil_plot(soil,plot), c_p_t_i(cropsResidueRemo,plot,till,intens) )
            =  p_residue_ratio(prodsResidues) *  sum(prods, p_OCoeffC(cropsResidueRemo,soil,till,intens,prods,t) $sameas(prods,cropsResidueRemo)) $ crop_residues(prodsResidues,cropsResidueRemo) ;


*
* --- Variable costs of straw removal, based on LWK Strohpreisrechner
*     LWK Nds. 2018. Strohpreisrechner, Chamber of Agriculture Lower Saxony (LWK Nds.), https://?www.lwk-niedersachsen.de?/?download.cfm/?file/?30111.html (accessed 07.12.18).

    p_vCostStrawRemoval(crops,plot,till,intens,t)   $  c_p_t_i(crops,plot,till,intens)     =
                              sum((soil_plot(soil,plot),prodsResidues) ,  p_OCoeffResidues(crops,soil,till,intens,prodsResidues,t) $ crop_residues(prodsResidues,crops)) * 75  ;


*
*  --- Additional variable costs linked to fast rotational grazing
*
   $$ifi defined rotationalGraz p_vCostC(rotationalGraz,till,intens,t) = 37.5;
*
*  --- Variable costs, inflated
*
   p_vCostC(idle,till,intens,t) $ sum(c_p_t_i(idle,plot,till,intens),1)  =   40 * [1+%outputPriceGrowthRate%/100]**t.pos;

$endif.mode
