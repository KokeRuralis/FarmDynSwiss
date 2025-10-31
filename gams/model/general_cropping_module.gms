
********************************************************************************
$ontext

   FARMDYN project

   GAMS file : TEMPL.GMS

   @purpose  : General cropping module

   @author   : W.Britz, T.Kuhn, D.Schaefer(last modification), C.Pahmeyer, L.Kokemohr, J.Heinrichs
   @date     : 3.11.10
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : templ.gms

$offtext
********************************************************************************

    parameter
         p_maxRotShare(*,sys,soil)                         "Maximal rotation share of crops or groups of crops"
         p_minRotShare(*,sys,soil)                         "Minimal rotation share of crops or groups of crops"
         P_critShare(crops,sys,cropShareLevl)              "Crop shares at which further increase in cost occurs"
         p_pastNeedMonthly(crops,soil,till,intens,nut,t,m) "Monthly nutrient need for grazing for each crop,soil, tillage, intensity"
         p_nutSurplusMax(crops,plot,till,intens,nut,t)     "Max N losses per crop and year"
         p_basNut(crops,soil,till,soilNutSour,nut,t)       "Nutrient base deliveries from soil and air"
         p_minChemFert(crops,nut)                          "Minimum of share of N and P from mineral fertilizer"

    ;



    positive variables

    v_croplandActive(t,n)                            "Non-idling land"
    v_croppedLand(landType,soil,t,n)                 "Sum of Crop levels in ha for each year and state of nature"
    v_croppedPlotLand(plot,sys,t,n)                  "Sum of Crop levels in ha for each year and state of nature for a specific plot"
    v_unUsedLand(plot,sys,t,n)                       "Land not used (also not idling for low cost, not eligible for SFP)"
    v_rentOutPlot(plot,t,n)                          "Rent out a specific plot (yearly, need to be improved)"

    v_sumCrop(crops,sys,t,n)                         "Sum of crop acreage, system - organic or conventional"
    v_residuesRemoval(crops,plot,till,intens,t,n)    "Crops in ha which have their residues removed"
    v_residuesOwnConsum(prodsYearly,t,n)             "Residues used for own consumption in straw stables"
    v_rotHa(rot,plot,t,n)                            "Crop levels in ha for each year and state of nature"
    v_cropShareEffect(crops,sys,cropShareLevl,t,n)

    v_nutOverNeed(crops,plot,till,intens,nut,t,n)      "Amount of Ogranic nutrients applied over plant need"
    v_nutTotalApplied(nut,t,n,m)                              "Total kg nutrient applicated to land per month from fertilizer and manure"
    v_nutTotalAppliedYear(nut,t,n)                            "Total kg nutrient applicated to land per year from fertilizer and manure"
    v_nutBalCropSour(fertSour,crops,plot,till,intens,nut,t,n) "Different nutrient sources entering fertilizing equation - nutbalcrop"
    v_syntDist(crops,plot,till,intens,syntFertilizer,t,n,m)       "Applying of different Synthetic fertilizers to specific crops"

$iftheni.fert %fertilization% =="OrganicFarming"
     v_legPool(nut,t,n)                                "Total Nutrient carry over from legumes to following crops"
     v_legPoolDist(crops,plot,till,intens,nut,t,n)     "Nutrient carry over from legumes to following crops"
     v_legPoolItself(crops,plot,till,intens,nut,t,n)   "Nutrient carry over from legumes to itself"

     v_resiPool(nut,t,n)                               "Total Nutrient carry over from residues following crops"
     v_resiPoolDist(crops,plot,till,intens,nut,t,n)    "Nutrient carry over from residues to following crops"

     v_leachedFert(crops,plot,till,intens,t,n)         "Leached N from fertilization per crop, year and ha"
$endif.fert


$ifi %MIP%==on   sos1 variables

      v_plotCrop(plot,t,n,crops)                   "Binary combination, only one crop on each plot"
;

equations

      sumCrop_(crops,sys,t,n)                    "Sums up hectares over plots, tillage options and intensities"
      croppedLand_(landType,soil,t,n)            "Cropped land per year and SON"
      totPlotLand_(plot,t,n)                     "Definiton of avaialable land in each year"
      plotLand_(plot,t,n)                        "Land balance per crop"

      croppedPlotLand_(plot,sys,t,n)             "Cropped land per year and SON"
      cropLandActive_(t,n)                       "Non-idling land"

$iftheni.cropRot %cropRotations% == true

      cropRotLand_(plot,t,n)                     "Link between rotations and available land"
      rotHa0_(cropTypes,plot,t,n)                "Link between crops and crop rotations, current year"
      rotHa1_(cropTypes,plot,t,n)                "Link between crops and crop rotations, year-1"
      rotHa2_(cropTypes,plot,t,n)                "Link between crops and crop rotations, year-2"
      rotComp_(crops,plot,t,n)                   "Link between crops and crop rotations, comparative-static"

$else.cropRot

      cropRotmax_(landType,crops,sys,plot,t,n)            "Max rotational shares per crop"
      cropGrpRotmax_(landType,cropShareGrp,sys,plot,t,n)  "Max rotational shares per crop group"
      cropRotMin_(landType,crops,sys,plot,t,n)            "Min rotational shares per crop"
      cropGrpRotmin_(landType,cropShareGrp,sys,plot,t,n)  "Min rotational shares per crop group"

$endif.cropRot

      cropShareEffect_(crops,sys,cropShareLevl,t,n)  "Determines the current crop acreage aboave a certain threshold (step-wise quadratic function)"

      nutTotalApplied_(nut,t,n,m)                 "total kg nurient applicated to land from fertilizer and manure per month"
      nutTotalAppliedYear_(nut,t,n)               "total kg nurient applicated to land from fertilizer and manure per year"

      nMinMin_(crops,plot,till,intens,nut,t,n)        "Minimum share of mineral N on total N need"
      nutSurplusMax_(crops,plot,till,intens,nut,t,n)  "maximum nutrient surplus allowed exdceeding demand"
      NutBalCropSour_(fertSour,crops,plot,till,intens,nut,t,n) "Nutrient balance for each crop categorie, source specific"
      NutBalCrop_(crops,plot,till,intens,nut,t,n)     "Nutrient balance for each crop categorie"
      NutBalPast_(crops,plot,till,intens,nut,t,n,m)   "Nutrient balance for grazing"
      NutBalCrop1_(crops,plot,till,intens,nut,t,n)    "Nutrient balance for each crop categorie"
      catchCropMax_(plot,t,n)                         "Constraints acreage of catchcrop to the acreage of crops harvested in summer"
      CatchCropRequiredOrg_(t,n)                      "Requirement of growing catch crops before summer crops under organic production"
      residueRemoval_(crops,plot,till,t,n)            "Possible residues removal is linked to ha of certain crops"
      ownConsumResidue_(prodsYearly,t,n)              "Own consumption of straw residues for straw stables"
$iftheni.fert %fertilization% =="OrganicFarming"
      legPoolIn_(nut,t,n)                             "Total amount N from mineralized legume residues produced"
      legPoolOut_(nut,t,n)                            "Total uptake of N from mineralized legume residues"
      legPoolDistMax_(crops,plot,till,intens,nut,t,n) "Maximum amount of N uptake by a crop, restricted by the area of the crop and the max. mineralisation per hectare"
      legPoolItself_(crops,plot,till,intens,nut,t,n)  "N fixation providing N to the legume itself"

      resiPoolIn_(nut,t,n)                             "Total amount N from mineralized residues"
      resiPoolOut_(nut,t,n)                            "Total uptake of N from mineralized residues"
      resiPoolDistMax_(crops,plot,till,intens,nut,t,n) "Maximum amount of N uptake from residues by a crop, restricted by the area of the crop and the max. mineralisation per hectare"

      leachedFert_(crops,plot,till,intens,t,n)         "Leached N from fertilization per crop, year and ha"
$endif.fert


;


*
*  --- crop share effects, related to weed control
*
   cropShareEffect_(curCrops(crops),curSys(sys),cropShareLevl,t_n(tCur(t),%nCur%))
             $ sum((c_p_t_i(crops,plot,till,intens)) $ sys_till(sys,till),1 ) ..

        v_cropShareEffect(crops,sys,cropShareLevl,t,%nCur%) =G= v_sumCrop(crops,sys,t,%nCur%)
                                                                   -  (  p_nArabLand  $ (not grassCrops(crops))
                                                                      + (p_nGrasLand+p_nPastLand) $ grassCrops(crops)) * p_critShare(crops,sys,cropShareLevl);


*
*   --- Equation to link resiudes removal to area of certain crops
*
    residueRemoval_( curCrops(crops),plot,till,t_n(tCur(t),nCur)) ..

             sum (  c_p_t_i(crops,plot,till,intens) $ cropsResidueRemo(crops), v_residuesRemoval(crops,plot,till,intens,t,nCur)  )

                =l= sum( c_p_t_i(crops,plot,till,intens) $ cropsResidueRemo(crops),
                                               v_cropHa(crops,plot,till,intens,t,%nCur%)) ;

*
*   --- straw (or bedding material) that is used for own consumption
*
    ownConsumResidue_(prodsResidues,t_n(tCur(t),nCur)) ..
        v_residuesOwnConsum(prodsResidues,t,nCur) =L= sum( c_p_t_i(crops,plot,till,intens) $ (cropsResidueRemo(crops)
                                           )
                           ,  v_residuesRemoval(crops,plot,till,intens,t,nCur)
      *  sum(plot_soil(plot,soil), p_OCoeffResidues(crops,soil,till,intens,prodsResidues,t)) );



$iftheni.cropRot %cropRotations% == true

  $$iftheni.compStat not "%dynamics%"=="comparative-static"

      cropRotLand_(plot,t_n(tCur(t),nCur)) $ (not sum(plot_lt_soil(plot,"gras",soil),1)) ..

       sum(cropType0_rot(cropTypes,curRot(rot))
              $ sum( (cropTypes_crops(cropTypes,crops),c_p_t_i(crops,plot,till,intens))
                          $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0),1),
              v_rotHa(rot,plot,t,nCur)) =E= v_totPlotLand(plot,t,nCur);


    rotHa0_(cropTypes,plot,t_n(tCur(t),nCur)) $ (not sum(plot_lt_soil(plot,"gras",soil),1))

            $ (sum(cropType0_rot(cropTypes,curRot(rot)),1)
               $ sum( (cropTypes_crops(cropTypes,crops),c_p_t_i(crops,plot,till,intens))
                           $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0),1))) ..

        sum( (cropTypes_crops(cropTypes,crops),c_p_t_i(crops,plot,till,intens)), v_cropHa(crops,plot,till,intens,t,%nCur%))

            =E=   sum(cropType0_rot(cropTypes,curRot(rot)), v_rotHa(rot,plot,t,nCur));
*
*   --- rotation crops in second year of rotation
*
    rotHa1_(cropTypes,plot,tCur(t),nCur) $ ((not sum(plot_lt_soil(plot,"gras",soil),1) )

            $ (sum(cropType1_rot(cropTypes,curRot(rot)),1)
               $ sum( (cropTypes_crops(cropTypes,crops),c_p_t_i(crops,plot,till,intens))
                           $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0),1)
                           $ tCur(t+1)) $ t_n(t,nCur)  ) ..

        sum( (cropTypes_crops(cropTypes,crops),c_p_t_i(crops,plot,till,intens)), v_cropHa(crops,plot,till,intens,t,%nCur%))

            =E=   sum((cropType1_rot(cropTypes,curRot(rot)),t_n(t+1,nCur1)), v_rotHa(rot,plot,t+1,nCur1));
*
*   --- rotation crops in third year of rotation
*
    rotHa2_(cropTypes,plot,tCur(t),nCur) $ ((not sum(plot_lt_soil(plot,"gras",soil),1))

            $ (sum(cropType2_rot(cropTypes,curRot(rot)),1)
               $ sum( (cropTypes_crops(cropTypes,crops),c_p_t_i(crops,plot,till,intens))
                           $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0),1)
                           $ tCur(t+2)) $ t_n(t,nCur) ) ..

        sum( (cropTypes_crops(cropTypes,crops),c_p_t_i(crops,plot,till,intens)), v_cropHa(crops,plot,till,intens,t,%nCur%))

            =E=   sum((cropType2_rot(cropTypes,curRot(rot)),t_n(t+2,nCur1)), v_rotHa(rot,plot,t+2,nCur1));

  $$else.compStat

*
*   --- Links the land in crop rotations to the total land available
*

    cropRotLand_(plot,t_n(tCur(t),nCur)) $ (not sum(plot_lt_soil(plot,"gras",soil),1)) ..

       sum(crop0_rot(curcrops,currot(Rot))
              $ sum( c_p_t_i(crops,plot,till,intens)
                         $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0),1),
           
                        v_rotHa(rot,plot,t,nCur)) =E= v_totPlotLand(plot,t,nCur);

*
* ---- Ensures that the grown crops meet the crop rotations, e.g. when growing WW-WB-WW that 
*      2/3 of land is WW and 1/3 is WB
*

    rotComp_(curArabCrops,plot,t_n(tCur(t),nCur)) $( (not sum(plot_lt_soil(plot,"gras",soil),1)   

          $ sum( c_p_t_i(curArabCrops,plot,till,intens)
                           $ (v_cropHa.up(curArabCrops,plot,till,intens,t,nCur) ne 0),1)) )..


        sum( c_p_t_i(curArabCrops,plot,till,intens) , v_cropHa(curArabCrops,plot,till,intens,t,%nCur%)) 

            =E=   sum (currot(Rot) $ sum (c_p_t_i(curArabCrops,plot,till,intens),1), 
                                      v_rotHa(Rot,plot,t,nCur) * p_cropRotShare(curArabCrops,rot))  ;


  $$endif.compstat

$else.cropRot

*
*   --- crop rotation constraints: each crop can occupy a max. share on cropped land
*
    cropRotMax_(landType,crops,curSys(sys),plot,t_n(tCur(t),%nCur%))
        $ (  sum(c_p_t_i(crops,plot,till,intens)
                                 $ ((v_cropHa.up(crops,plot,till,intens,t,%nCur%) ne 0) $ sys_till(sys,till)),1)
                        $ (sum(plot_soil(plot,soil), p_maxRotShare(Crops,sys,soil)) lt 1)
                        $  crops_t_landType(crops,landType)
                        $  crops_t_landType(crops,landType)) ..

          sum( c_p_t_i(crops,plot,till,intens) $ sys_till(sys,till), v_cropHa(crops,plot,till,intens,t,%nCur%))
               =l= v_croppedPlotLand(plot,sys,t,%nCur%) * sum(plot_soil(plot,soil),p_maxRotShare(crops,sys,soil));
*
*   --- crop rotation constraints: each crop group can occupy a max. share on cropped land
*
    cropGrpRotMax_(landType,cropShareGrp,curSys(sys),plot,t_n(tCur(t),%nCur%))
        $ (  sum( (cropShareGrp_crops(cropShareGrp,crops),c_p_t_i(crops,plot,till,intens))
                                 $ ((v_cropHa.up(crops,plot,till,intens,t,%nCur%) ne 0) $ sys_till(sys,till)),1)
                        $ (sum(plot_soil(plot,soil), p_maxRotShare(cropShareGrp,sys,soil)) lt 1)
                        $  sum(plot_soil(plot,soil), p_maxRotShare(cropShareGrp,sys,soil))
                        $   sum( (cropShareGrp_crops(cropShareGrp,crops),crops_t_landType(crops,landType)),1)) ..

          sum( (cropShareGrp_crops(cropShareGrp,crops),c_p_t_i(crops,plot,till,intens)) $ sys_till(sys,till),
                             v_cropHa(crops,plot,till,intens,t,%nCur%))
               =l= v_croppedPlotLand(plot,sys,t,%nCur%) * sum(plot_soil(plot,soil),p_maxRotShare(cropShareGrp,sys,soil));
*
*   --- crop rotation constraints: each crop must occupy a min. share on cropped land
*
    cropRotMin_(landType,curCrops(crops),curSys(sys),plot,t_n(tCur(t),%nCur%))
        $ (  sum(c_p_t_i(crops,plot,till,intens)
                                 $ ((v_cropHa.up(crops,plot,till,intens,t,%nCur%) ne 0) $ sys_till(sys,till)),1)
                        $ (sum(plot_soil(plot,soil), p_minRotShare(Crops,sys,soil)) lt 1)
                        $ sum(plot_soil(plot,soil) $ p_minRotShare(Crops,sys,soil),1)
                        $  crops_t_landType(crops,landType)) ..

          sum( c_p_t_i(crops,plot,till,intens) $ sys_till(sys,till),
                    v_cropHa(crops,plot,till,intens,t,%nCur%))
               =G= [v_croppedPlotLand(plot,sys,t,%nCur%)
                       + sum(c_p_t_i("idle",plot,till,intens) $ sys_till(sys,till), v_cropHa("idle",plot,till,intens,t,%nCur%))]
                      * sum(plot_soil(plot,soil),p_minRotShare(crops,sys,soil));
*
*   --- crop rotation constraints: each crop group must occupy a min. share on cropped land
*
    cropGrpRotMin_(landType,cropShareGrp,curSys(sys),plot,t_n(tCur(t),%nCur%))
        $ (  sum( (cropShareGrp_crops(cropShareGrp,crops),c_p_t_i(crops,plot,till,intens))
                                 $ ((v_cropHa.up(crops,plot,till,intens,t,%nCur%) ne 0) $ sys_till(sys,till)),1)
                        $ (sum(plot_soil(plot,soil), p_minRotShare(cropShareGrp,sys,soil)) lt 1)
                        $ sum(plot_soil(plot,soil) $ p_minRotShare(cropShareGrp,sys,soil),1)
                        $ sum( (cropShareGrp_crops(cropShareGrp,crops),crops_t_landType(crops,landType)),1)) ..

          sum( (cropShareGrp_crops(cropShareGrp,crops),c_p_t_i(crops,plot,till,intens)) $ sys_till(sys,till),
                  v_cropHa(crops,plot,till,intens,t,%nCur%))
               =G= [v_croppedPlotLand(plot,sys,t,%nCur%)
                     - sum(c_p_t_i("idle",plot,till,intens) $ sys_till(sys,till), v_cropHa("idle",plot,till,intens,t,%nCur%))]
                        * sum(plot_soil(plot,soil),p_minRotShare(cropShareGrp,sys,soil));

$endif.cropRot
*
*   --- definition of cropped plot land
*
    croppedPlotLand_(plot,curSys(sys),t_n(tCur(t),%nCur%)) $ (p_plotSize(plot) $ (v_croppedPlotLand.up(plot,sys,t,%nCur%) ne 0)) ..

       v_croppedPlotLand(plot,sys,t,%nCur%) - v_unUsedLand(plot,sys,t,%nCur%)

          =E= sum( c_p_t_i(curCrops(crops),plot,till,intens) $ ((not catchcrops(crops))
                             $ (sameas(sys,till) or (sameas("conv",sys) and not sameas("org",till)))),
                      v_cropHa(crops,plot,till,intens,t,%nCur%));
*
*   --- land endowment definition per plot (initial size plus bought adjacent plots)
*
    totPlotLand_(plot,tCur(t),%nCur%) $ (p_plotSize(plot) $ t_n(t,%nCur%)) ..

       v_totPlotLand(plot,t,%nCur%)

            =E=
*
*            --- initialize of plots
*
             p_plotSize(plot)
*
*            --- plus bought adjacent plots (= merged)
*
$ifi %landBuy% == true + sum(t_n(t1,nCur1) $ (tcur(t1) $ isNodeBefore(%nCur%,nCur1) $ (ord(t1) le ord(t))), v_buyPlot(plot,t1,nCur1))
             ;
*
*   --- land constraint: crop levels plus renting out cannot exceed available land per plot
*                        in each year and SON
*
    plotland_(plot,t_n(tCur(t),%nCur%)) $ p_plotSize(plot) ..
*
           sum(sys,v_croppedPlotLand(plot,sys,t,%nCur%))
*
$ifi %landLease% == true + v_rentOutPlot(plot,t,%nCur%)*p_plotSize(plot)
*
              =E= v_totPlotLand(plot,t,%nCur%);

*
*   --- catchcrop constraint: catchcrop levels cannot exceed available land after harvest of summercrops
*                        in each year and SON (catchcrops are excluded)
*
    catchCropMax_(plot,t_n(tCur(t),%nCur%)) ..

      sum(c_p_t_i(curCrops(catchCrops),plot,till,intens), v_cropHa(catchCrops,plot,till,intens,t,%nCur%))

         =l= sum( c_p_t_i(curCrops(summerHarvest),plot,till,intens),
                                              v_cropHa(summerHarvest,plot,till,intens,t,%nCur%));


*
* --- Requirement of growing catch crops before summer crops under organic production
*
*

      CatchCropRequiredOrg_(tCur(t),%nCur%) $t_n(t,%nCur%) ..

      sum(c_p_t_i(curCrops(Crops),plot,"org",intens)
                 $catchcrops(crops), v_cropHa(crops,plot,"org",intens,t,%nCur%))
            =g=

         sum( c_p_t_i(curCrops(crops),plot,"org",intens) $ summerHarvest(Crops),
                                           v_cropHa(crops,plot,"org",intens,t,%nCur%)) ;


*
*  --- total cropped land in each year and SON
*
   croppedLand_(landType,soil,t_n(tCur(t),%nCur%)) ..

       v_croppedLand(landType,soil,t,%nCur%)
          =e= sum( (curCrops(crops),plot_lt_soil(plot,landType,soil),till,intens)
                    $ c_p_t_i(crops,plot,till,intens), v_cropHa(crops,plot,till,intens,t,%nCur%)
                             $( not catchcrops(crops) ));
*
*  --- reporting: crop hectares of one crop per year
*
   sumCrop_(curCrops(crops),curSys(sys),t_n(tCur(t),%nCur%)) ..

       v_sumCrop(crops,sys,t,%nCur%)
             =e= sum( c_p_t_i(crops,plot,till,intens) $ sys_till(sys,till),
                 v_cropHa(crops,plot,till,intens,t,%nCur%) );
*
*  ---- land under active management, meaning without idle
*
   cropLandActive_(t_n(tCur(t),%nCur%)) ..

        v_croplandActive(t,%nCur%) =e=
             sum(  (c_p_t_i(crops,plot,till,intens)) $ ( not (sameas(crops,"idle") or sameas (crops,"idlegras") or catchcrops(crops)  )  ) ,
                                                          v_cropHa(crops,plot,till,intens,t,%nCur%) )  ;

*
*  --- exclude over fertilization if no crop ha
*
   NutBalCrop1_(c_p_t_i(curCrops(crops),plot,till,intens),nut,t_n(tCur(t),nCur))
           $ ( (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0) $ fertCrops(crops)) ..

         v_nutOverNeed(crops,plot,till,intens,nut,t,nCur) =L=
                        10000 * v_cropHa(crops,plot,till,intens,t,%nCur%);

   NutBalCropSour_(curFertSour(fertSour),c_p_t_i(curCrops(crops),plot,till,intens),nut,t_n(tCur(t),nCur))
          $ ( (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0) $ fertCrops(crops)) ..

* --- Equation lists the N and P need of crops and different nutrient sources. Two GUI settings:
*     Default - nutrient losses are defined by environmental accounting, all possible sources and losses
*     are taken into account
*     FertilizationOrdinance: Matches exactly fertilization planning (Düngebedarfsermittlung)

*
* --- new fertilizatiion option: accoriding to organic farming practices, e.g. considering whole plant extraction
*

* --- Balance, oposing input and outputs, is in equation nutbalCrop_ to facilitate the use
*     of variable v_nutBalCropSour for validation
*

      v_nutBalCropSour(fertSour,crops,plot,till,intens,nut,t,nCur)

       =E=

* --- N and P need of crops which needs to be met.

$$iftheni.fert not %Fertilization% == OrganicFarming
         [
            sum(plot_soil(plot,soil),
                       p_nutNeed(crops,soil,till,intens,nut,t)
            ) * v_cropHa(crops,plot,till,intens,t,%nCur%)
         ] $sameas(fertSour,"NBcropNeed")
$$else.fert
     [     [
            sum(plot_soil(plot,soil),
                       p_NExtractPlant(crops,soil,till,intens,t)
            ) * v_cropHa(crops,plot,till,intens,t,%nCur%)
         ] $  sameas(nut,"N")
+    [
         sum(plot_soil(plot,soil),
                p_nutNeed(crops,soil,till,intens,nut,t)
         ) * v_cropHa(crops,plot,till,intens,t,%nCur%)
       ] $  sameas(nut,"P")
     ]$ sameas(fertSour,"NBcropNeed")
$$endif.fert

*  ---  Application over plant need of fertilizer is possible (e.g. if mineralisation
*        plus atmospheric deposition exceed crop needs, or in case too much nutrients
*        from manure are available on farm)

         + v_nutOverNeed(crops,plot,till,intens,nut,t,nCur) $sameas(fertSour,"NBOverNeed")

* ---- Nutrient delivered from mineralization, atmosphere etc.
         +  [
              sum( plot_soil(plot,soil),
                 $$iftheni.fert %Fertilization% == FertilizationOrdinance
*                   Fertilization Ordinance - Nmin in spring
                     p_NutFromSoil(crops,soil,till,nut,t)
                $$else.fert
*                    Default - p_basNut, refelct Nmin in spring, N depostion from atmosphere and asynmbiotic N fixation
                     sum(soilNutSour,p_basNut(crops,soil,till,soilNutSour,nut,t))
                 $$endif.fert
              ) * v_cropHa(crops,plot,till,intens,t,%nCur%)
            ] $sameas(fertSour,"NBbasNut")

* --- Chemcial fertilizer application
         + [
              sum ((curInputs(syntFertilizer),m),
                 v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m) * p_nutInSynt(syntFertilizer,nut))
           ] $ sameas(fertSour,"NBminFert")


* --- Chemcial fertilizer application, losses

         + [
*             --- Fertilization Ordinance - No losses, for default: losses for N
              $$iftheni.fert %Fertilization% == Default
                 sum ((curInputs(syntFertilizer),m),
                   v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m) * p_nutInSynt(syntFertilizer,nut)

                          *   (     p_EFApplMinNH3(syntFertilizer)
                                  + p_EFApplMin("N2O")
                                  + p_EFApplMin("NOx")
                                  + p_EFApplMin("N2")
                              )
                 )

             $$elseifi.fert  %Fertilization% == OrganicFarming
*            --- as we account for N2 losses in denitrification in organicfarming, we do not take them into account here
                 sum ((curInputs(syntFertilizer),m),
                   v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m) * p_nutInSynt(syntFertilizer,nut)

                          *   (     p_EFApplMinNH3(syntFertilizer)
                                  + p_EFApplMin("N2O")
                                  + p_EFApplMin("NOx")
                                                              )
                 )
               $$elseifi.fert  %Fertilization% == FertilizationOrdinance
                  0
               $$endif.fert
               ] $ (sameas(fertSour,"NBminFertLoss") $  sameas(nut,"N") )

* ---- Nutrients from manure and digestate application

    $$iftheni.man "%manure%" == "true"

           +  [
                sum ( (manApplicType_manType(ManApplicType,curManType),m)
                      $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0),
                         v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)

                   * sum( (manChain_applic(curManChain,ManApplicType),nut2_nut(nut2,nut)),
                           p_nut2inMan(nut2,curManType,curManChain))
                )
              ] $sameas(fertSour,"NBmanure")


            + [
               sum ( (manApplicType_manType(ManApplicType,curManType),m)
                    $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0),
                       v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)

                   $$iftheni.fert %Fertilization% == FertilizationOrdinance

*                        Fertilization Ordinance - standard loss factors provided by ordinance (N and P)
                          * sum( (manChain_applic(curManChain,ManApplicType),nut2_nut(nut2,nut)),
                              p_nut2inMan(nut2,curManType,curManChain)
                                 * (1 - p_nutEffFOPlan(curManType,crops,m,nut)))

                  $$elseifi.fert %Fertilization% == Default
*                        Default - different N losses from env accounting module

                         * sum( (manChain_type(curManChain,curManType),nut2N),
                                      p_nut2inMan(nut2N,curManType,curManChain)
                                         * (     p_EFapplMan(curCrops,curManType,manApplicType,nut2N,m) $ sameas(nut2N,"NTAN")
                                              +  p_EFApplMin("N2O")
                                              +  p_EFApplMin("NOx")
                                              +  p_EFApplMin("N2")   )
                              ) $ sameas(nut,"N")
                  $$elseifi.fert  %Fertilization% == OrganicFarming
*                        OrganicFarming - do not account for N2 losses
                  * sum( (manChain_type(curManChain,curManType),nut2N),
                               p_nut2inMan(nut2N,curManType,curManChain)
                                  * (     p_EFapplMan(curCrops,curManType,manApplicType,nut2N,m) $ sameas(nut2N,"NTAN")
                                       +  p_EFApplMin("N2O")
                                       +  p_EFApplMin("NOx")
                                          )
                       ) $ sameas(nut,"N")
                  $$endif.fert
                )
              ] $sameas(fertSour,"NBmanureloss")

    $$endif.man

$$iftheni.fert %Fertilization% == OrganicFarming

* --- Nitrogen import by seeds
                + [p_NfromSeeds(crops,till,intens) * v_cropHa(crops,plot,till,intens,t,%nCur%) ]
                             $ (sameas(fertSour,"NBseeds") $  sameas(nut,"N"))

* --- Nitrogen delivery from soil during vegetation period

                + [
                  p_NSoilDelivery(crops) * v_cropHa(crops,plot,till,intens,t,%nCur%)
                ]
                           $ (sameas(fertSour,"NBSoilDelivery") $ sameas(nut,"N"))

* --- Nitrogen loss through plant senescence

                + [
                  sum( plot_soil(plot,soil),
                       p_NPlantSenescence(Crops,soil,till,intens,t)  * v_cropHa(crops,plot,till,intens,t,%nCur%)
                     )
                ]
                           $ (sameas(fertSour,"NBPlantSenescence") $ sameas(nut,"N"))

* --- N loss trough denitrification

                + [sum(plot_soil(plot,soil),
                  p_NDenitrification(crops) * v_cropHa(crops,plot,till,intens,t,%nCur%)) ]
                   $ (sameas(fertSour,"NBdenitrification") $  sameas(nut,"N"))

** --- N losses through leaching

                + [
                v_leachedFert(crops,plot,till,intens,t,%nCur%)
                   ] $ (sameas(fertSour,"NBleaching") $  sameas(nut,"N"))


$ontext
                + [ (
*              amount of mineral N fertilizer
                   sum ((curInputs(syntFertilizer),m),
                        v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m) * p_nutInSynt(syntFertilizer,nut))
*              amount of N in manure
    $$iftheni.man "%manure%" == "true"
              +    sum ( (manApplicType_manType(ManApplicType,curManType),m)
                             $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0),
                                v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)

                          * sum( (manChain_applic(curManChain,ManApplicType),nut2_nut(nut2,nut)),
                                  p_nut2inMan(nut2,curManType,curManChain))
                       )
    $$endif.man
*               amount of N extracted on pasture
  $$iftheni.dh "%cattle%" == "true"
                     +  sum(  (nut2_nut(nut2,nut),m)
                                    $ (sum(actHerds(possHerds,breeds,grazRegime,t,m),p_nutExcreDueV(possHerds,grazRegime,nut2)) $ (p_grazMonth(Crops,m)>0)),
                                                 v_nut2ManurePast(crops,plot,till,intens,nut2,t,nCur,m)
                                 )  $(pastcrops(crops))
  $$endif.dh
*    0.3kg N of each kg N applied are leached (Thünen Report, Rösmann 2021 p.388)
                       ) * 0.3
                   ]    $ (sameas(fertSour,"NBleaching") $  sameas(nut,"N"))
$offtext
$$endif.fert

* --- Nutriens from excretion on pasture
*     Default - different N losses from env accounting module
*     Fertilization Ordinance - standard loss factors provided by ordinance; can be
*     fixed to one mantype as factor is the same for all cattle

    $$iftheni.dh "%cattle%" == "true"

        + [
                 sum(  (nut2_nut(nut2,nut),m)
                       $ (sum(actHerds(possHerds,breeds,grazRegime,t,m),p_nutExcreDueV(possHerds,grazRegime,nut2)) $ (p_grazMonth(Crops,m)>0)),
                                    v_nut2ManurePast(crops,plot,till,intens,nut2,t,nCur,m)
                    )  $(pastcrops(crops))
              ]  $sameas(fertSour,"NBpasture")

      + [
        $$iftheni.fert %Fertilization% == FertilizationOrdinance

           sum( (nut2_nut(nut2,nut),m)
                    $ ((p_grazMonth(Crops,m)>0) $ sum(actHerds(possHerds,breeds,grazRegime,t,m)
                              $ p_nutExcreDueV(possHerds,grazRegime,nut2),1)),
                                 v_nut2ManurePast(crops,plot,till,intens,nut2,t,nCur,m)
                                     * (1- p_nutEffFOPlan("cows",crops,m,nut) )
               )  $(pastcrops(crops))
        $$else.fert
           sum ( (nut2N,m)
                 $ (sum(actHerds(possHerds,breeds,grazRegime,t,m),p_nutExcreDueV(possHerds,grazRegime,nut2N))  $ (p_grazMonth(Crops,m)>0)),
                         v_nut2ManurePast(curCrops,plot,till,intens,nut2N,t,nCur,m)
                           * (   p_EFPasture("NH3") $ sameas(nut2N,"NTAN")
                               + p_EFPasture("N2O")
                               + p_EFPasture("NOx")
                               + p_EFPasture("N2")    )
               )  $ ( pastcrops(crops) $ sameas(nut,"N"))
         $$endif.fert
            ]  $sameas(fertSour,"NBpastureLoss")

    $$endif.dh

* --- Nutrient from N fixation from legumes and vegetables
*     Default - lowers nutrient need for legumes reflected

* --- Nutrient from N fixation from legumes and vegetables

     + [

$iftheni.fert %Fertilization% == OrganicFarming
      v_legPoolDist(crops,plot,till,intens,nut,t,nCur)
$else.fert
        v_cropHa(crops,plot,till,intens,t,%nCur%) * (
           ( p_NfromLegumes(Crops,"org")  $ sameas(till,"org")
            + p_NfromLegumes(Crops,"conv") $ (not sameas(till,"org")))
                                                  )   $ (sameas(nut,"N"))
$endif.fert

        ]  $sameas(fertSour,"NBlegumes")
*
$iftheni.fert %Fertilization% == OrganicFarming
        + [

          v_legPoolItself(crops,plot,till,intens,nut,t,nCur)

           ]  $sameas(fertSour,"NBlegumesSelf")
* --- N uptake from crop residues
   + [

      v_resiPoolDist(crops,plot,till,intens,nut,t,nCur)

      ]   $ (sameas(fertSour,"NBresiduen") $  sameas(nut,"N"))

$endif.fert
* --- N in residues from vegetables
      $$iftheni.data "%database%" == "KTBL_database"
$$iftheni.fert not %Fertilization% == OrganicFarming
    + [
          v_cropHa(crops,plot,till,intens,t,%nCur%) *  p_NfromVegetables(Crops)
                                                       $ (sameas(nut,"N"))
       ]  $sameas(fertSour,"NBvegetables")
$$endif.fert
       $$endif.data
   ;

   NutBalCrop_(c_p_t_i(curCrops(crops),plot,till,intens),nut,t_n(tCur(t),nCur))
         $ ( (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0)  $ fertCrops(Crops) ) ..

* --- Equation which oppons nutrient need, sources and losses based on the
*     definition in NutBalCropSour_

* --- Nutrient need
          v_nutBalCropSour("NBcropNeed",crops,plot,till,intens,nut,t,nCur)

* --- Nutrient application over plant need with manure
         + v_nutBalCropSour("NBOverNeed",crops,plot,till,intens,nut,t,nCur)

            =E=

* --- Nutrient delivered from soil and air
          v_nutBalCropSour("NBbasNut",crops,plot,till,intens,nut,t,nCur)

* --- Nutrient from chemical fertilizer
        + v_nutBalCropSour("NBminFert",crops,plot,till,intens,nut,t,nCur)

* --- Losses from chemical fertilizer application
        - v_nutBalCropSour("NBminFertLoss",crops,plot,till,intens,nut,t,nCur)

        $$iftheni.man "%manure%" == "true"
* --- Nutrients from manure application
        + v_nutBalCropSour("NBmanure",crops,plot,till,intens,nut,t,nCur)

* --- Losses from manure application
        - v_nutBalCropSour("NBmanureloss",crops,plot,till,intens,nut,t,nCur)
        $$endif.man

        $$iftheni.dh "%cattle%" == "true"
* --- Nutrients on pasture from grazing
        + v_nutBalCropSour("NBpasture",crops,plot,till,intens,nut,t,nCur)

* --- Losses on pasture from grazing
        - v_nutBalCropSour("NBpastureLoss",crops,plot,till,intens,nut,t,nCur)

        $$endif.dh
* ---- Nutrients from legumes
        + v_nutBalCropSour("NBlegumes",crops,plot,till,intens,nut,t,nCur)

* ---- Nutrients delivered from vegetables residues
        $$iftheni.data "%database%" == "KTBL_database"
        + v_nutBalCropSour("NBvegetables",crops,plot,till,intens,nut,t,nCur)
        $$endif.data
$$iftheni.fert %Fertilization% == OrganicFarming
        + v_nutBalCropSour("NBlegumesSelf",crops,plot,till,intens,nut,t,NCur)

        + v_nutBalCropSour("NBseeds",crops,plot,till,intens,nut,t,nCur)

        + v_nutBalCropSour("NBSoilDelivery",crops,plot,till,intens,nut,t,nCur)

        + v_nutBalCropSour("NBresiduen",crops,plot,till,intens,nut,t,nCur)

        - v_nutBalCropSour("NBdenitrification",crops,plot,till,intens,nut,t,nCur)

        - v_nutBalCropSour("NBleaching",crops,plot,till,intens,nut,t,nCur)

        - v_nutBalCropSour("NBPlantSenescence",crops,plot,till,intens,nut,t,nCur)

$$endif.fert

;
$$iftheni.fert  %Fertilization% == OrganicFarming
*
* -- equations related to nitrogen fixation of legumes
*

legPoolIn_(nut,tCur(t),nCur) $ t_n(t,nCur) ..
* hier wird von der gesamtmenge gesprochen - das müsste das Fixierung sein, nicht Saldo? aber manchmal Fixierung und Saldo unabhängig, aber auf der anderen seite it legpooltoitself auch anders

     v_legPool(nut,t,nCur) =E=
                                  sum((c_p_t_i(curCrops(leg),plot,till,intens),plot_soil(plot,soil))$ (v_cropHa.up(leg,plot,till,intens,t,nCur) ne 0),
                                     v_cropHa(leg,plot,till,intens,t,nCur) * p_NSaldoLeg(leg,soil,till,intens,t) $ sameas(nut,"N"));

 legPoolOut_(nut,tCur(t),nCur) $ t_n(t,nCur) ..
     v_legPool(nut,t,nCur) =E= sum(c_p_t_i(curCrops(crops),plot,till,intens)
                                  $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0),
                                          v_legPoolDist(crops,plot,till,intens,nut,t,nCur));

 legPoolDistMax_(c_p_t_i(curCrops(crops),plot,till,intens),nut,tCur(t),nCur)
       $ (t_n(t,nCur) $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0) $ sum(leg $ curCrops(leg),1)) ..

       v_legPoolDist(crops,plot,till,intens,nut,t,nCur)
           =L= v_cropHa(crops,plot,till,intens,t,nCur) * sum(plot_soil(plot,soil), smax(leg $ curCrops(leg), p_NSaldoLeg(leg,soil,till,intens,t))) $ (sum(arabCrops $ sameas(crops,arabCrops),1))
 ;

legPoolItself_(c_p_t_i(curCrops(crops),plot,till,intens),nut,tCur(t),nCur) $ t_n(t,nCur) ..

   v_legPoolItself(crops,plot,till,intens,nut,t,nCur) =E= sum(plot_soil(plot,soil),
        v_cropHa(crops,plot,till,intens,t,nCur)  * p_LegPoolItself(crops,soil,till,intens,nut,t))
;

*
* -- equations related to mineralization of residues
*

resiPoolIn_(nut,tCur(t),nCur) $ t_n(t,nCur) ..

     v_resiPool(nut,t,nCur) =E=
                                  sum((c_p_t_i(curCrops(crops),plot,till,intens),plot_soil(plot,soil))$ (v_cropHa.up(curCrops,plot,till,intens,t,nCur) ne 0),
                                           p_NfromCropRes(curcrops,soil,till,intens,t) * v_cropHa(curcrops,plot,till,intens,t,nCur) $ sameas(nut,"N"));

 resiPoolOut_(nut,tCur(t),nCur) $ t_n(t,nCur) ..
     v_resiPool(nut,t,nCur) =E= sum(c_p_t_i(curCrops(crops),plot,till,intens)
                                  $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0),
                                          v_resiPoolDist(crops,plot,till,intens,nut,t,nCur));

 resiPoolDistMax_(c_p_t_i(curCrops(crops),plot,till,intens),nut,tCur(t),nCur)
       $ (t_n(t,nCur) $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0)) ..

       v_resiPoolDist(crops,plot,till,intens,nut,t,nCur)
           =L= v_cropHa(crops,plot,till,intens,t,nCur) * sum(plot_soil(plot,soil), smax(crops1, p_NfromCropRes(crops1,soil,till,intens,t))) $ (sum(arabCrops $ sameas(crops,arabCrops),1))
 ;

*
* --- Leached N from fertilization  adapted from SALCA NO3 (Richner (2014)) in kg NO3-N per year
*     adapted from env_acc_module
*

leachedFert_(c_p_t_i(curCrops(crops),plot,till,intens),tCur(t),nCur)
*     $ sum(plot_soil(plot,soil),p_nutNeed(curCrops,soil,till,intens,"N",tCur))
      ..

   v_leachedFert(crops,plot,till,intens,t,ncur) =E=

*    --- leached N from manure application
   $$iftheni.man %manure% ==true
       sum( (manApplicType_manType(ManApplicType,curManType),m)
                $ (manApplicType_manType(ManApplicType,curManType)
                $ (v_manDist.up(curCrops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0)
                $ ( not catchcrops(curcrops) ) $c_p_t_i(curCrops,plot,till,intens)),
           (
* -- nut content in manure
             v_manDist(curCrops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                * sum(curManChain, p_nut2inMan("NTAN",curManType,curManChain))

* -- substracting emissions from manure application

          -  v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
              * sum( (manChain_type(curManChain,curManType),nut2N),
                           p_nut2inMan(nut2N,curManType,curManChain)
                              * (     p_EFapplMan(curCrops,curManType,manApplicType,nut2N,m) $ sameas(nut2N,"NTAN")
                                   +  p_EFApplMin("N2O")
                                   +  p_EFApplMin("NOx")
                                   +  p_EFApplMin("N2")
                                      )
                   )
                ) * p_EfLeachFert(curCrops,m)  )

   $$endif.man

* --- leached N from Chemcial fertilizer application
          +    sum ((curInputs(syntFertilizer),m),
* --- nut content in fertilizer
              ( v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m) * p_nutInSynt(syntFertilizer,"N")

* --- substracting emissions from fertilizer application
            -   v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m) * p_nutInSynt(syntFertilizer,"N")
                           *   (     p_EFApplMinNH3(syntFertilizer)
                                   + p_EFApplMin("N2O")
                                   + p_EFApplMin("NOx")
*                                   + p_EFApplMin("N2")
                               )

              ) * p_EfLeachFert(curCrops,m)    )

*     --- leaching from grazed pastures

   $$iftheni.dh "%cattle%" == "true"
    +  sum(  (nut2_nut(nut2,nut),nut2N,m)
                   $ (sum(actHerds(possHerds,breeds,grazRegime,t,m),p_nutExcreDueV(possHerds,grazRegime,nut2)) $ (p_grazMonth(Crops,m)>0)),

          (                      v_nut2ManurePast(crops,plot,till,intens,nut2,t,nCur,m)
              -
                     v_nut2ManurePast(curCrops,plot,till,intens,nut2N,t,nCur,m)
                       * (   p_EFPasture("NH3") $ sameas(nut2N,"NTAN")
                           + p_EFPasture("N2O")
                           + p_EFPasture("NOx")
                           + p_EFPasture("N2")    )
           ) *p_leachPast(m) )$ pastcrops(crops)
   $$endif.dh

;
$$endif.fert

$$iftheni.dh "%cattle%" == "true"

 NutBalPast_(c_p_t_i(pastcrops(crops),plot,till,intens),nut,t_n(tCur(t),nCur),m)
          $ ((v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0)
                  $ (p_grazMonth(crops,m)>0)
                            $ sum((actHerds(possHerds,breeds,grazRegime,t,m),nut2)
                                     $ p_nutExcreDueV(possHerds,grazRegime,nut2),1)
                                     )..


*     --- at least 50 percent of nutrient need for grazing outputs per month have to be met by excreta of grazing animals

                sum(plot_soil(plot,soil),

                    p_pastNeedMonthly(pastcrops,soil,till,intens,nut,t,m) * v_cropHa(crops,plot,till,intens,t,%nCur%)) * 0.5

                =l=
*     --- N excreted during grazing on pasture

                 +[sum( (nut2) $ ( sameas(nut2,"norg") or sameas(nut2,"ntan") ),
*     --- excretion by herds which graze only for a part of the year

                         v_nut2ManurePast(crops,plot,till,intens,nut2,t,nCur,m)
*
*                       --- N losses from excretion
*
                        -       v_nut2ManurePast(crops,plot,till,intens,"NTAN",t,nCur,m)
                                *   p_EFpasture("NH3")

                        -      (v_nut2ManurePast(crops,plot,till,intens,"NTAN",t,nCur,m)
                             +  v_nut2ManurePast(crops,plot,till,intens,"Norg",t,nCur,m))
                                * (  p_EFpasture("N2O")
                                   + p_EFpasture("NOx")
                                   + p_EFpasture("N2")
                                   ))

                            ]$( pastCrops(crops) $ sameas(nut,"N"))

*     --- P excreted during grazing pasture

                   + (
                         v_nut2ManurePast(crops,plot,till,intens,"P",t,nCur,m))
                           $(pastCrops(crops) $ sameas(nut,"P")$( (p_grazMonth(crops,m)>0) $ sum(actHerds(possHerds,breeds,grazRegime,t,m)
                                                                   $ sum(nut2,p_nutExcreDueV(possHerds,grazRegime,nut2)),1)))
    $$endif.dh
;

    $$ifthen.FO %duev% == false
*
*   --- nutrient surplus max over per ha restriction [ERASE?]
*
       nutSurplusMax_( c_p_t_i(curCrops(crops),plot,till,intens),nut,t_n(tCur(t),nCur))
        $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0) ..

          p_nutSurplusMax(crops,plot,till,intens,nut,t) * v_cropHa(crops,plot,till,intens,t,%nCur%)
               =G=  v_nutOverNeed(crops,plot,till,intens,nut,t,nCur);

    $$endif.FO
*
*   --- minimum share of mineral fertilizer restiction
*
    nMinMin_(c_p_t_i(curCrops(crops),plot,till,intens),nut,t_n(tCur(t),nCur))
        $ (  (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0)
                $ p_minChemFert(crops,nut) $ (not (sameas(till,"org") or lower(intens) or veryLow(intens))) ) ..

       sum ((curInputs(syntFertilizer),m),
                      v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)
                                                   * p_nutInSynt(syntFertilizer,nut)
              $$iftheni.fert %Fertilization% == Default

                          *   (1  - p_EFApplMinNH3(syntFertilizer)
                                  - p_EFApplMin("N2O")
                                  - p_EFApplMin("NOx")
                                  - p_EFApplMin("N2")
                              )
               $$endif.fert
              )
              =G=

                v_cropHa(crops,plot,till,intens,t,%nCur%) * p_minChemFert(crops,nut)
*
*               -- assume average fertilizer losses of 10% N with Default is active, to align with nutBalCropSour_
*
              $$ifi %Fertilization% == Default * 0.9
                  *  sum(plot_soil(plot,soil),p_nutNeed(crops,soil,till,intens,nut,t));


*   --- overall N amount applicated to crops in each month (organic as well as synthetic fertilizer N)

    nutTotalApplied_(nut,t_n(tCur(t),nCur),m) ..

       v_nutTotalApplied(nut,t,nCur,m) =e=

$iftheni.man %manure% == true

          sum( (c_p_t_i(curCrops(crops),plot,till,intens),manApplicType_manType(ManApplicType,curManType),nut2_nut(nut2,nut))
                  $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0 ),
                     v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                            * sum(manChain_applic(curManChain,ManApplicType), p_nut2inMan(nut2,curManType,curManChain))   )

$endif.man
$iftheni.dh "%cattle%" == "true"
          + sum( (c_p_t_i(curCrops(crops),plot,till,intens),nut2_nut(nut2,nut))
                $ (pastCrops(crops) $ (sum(grasscrops $(p_grazMonth(grassCrops,m)>0),1))),
                         v_nut2ManurePast(crops,plot,till,intens,nut2,t,nCur,m)  )
$endif.dh

          + sum ((c_p_t_i(crops,plot,till,intens),curInputs(syntFertilizer)),
                        v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)
                             * p_nutInSynt(syntFertilizer,nut)   );


*   --- overall N amount applicated to crops in each year (organic as well as synthetic fertilizer N)

    nutTotalAppliedYear_(nut,t_n(tCur(t),nCur)) ..

       sum(m,v_nutTotalApplied(nut,t,nCur,m))   =e=    v_nutTotalAppliedYear(nut,t,nCur);

**********************************************************************************************************
*
*   General cropping model definition
*
**********************************************************************************************************

    model m_land
                  /
      sumCrop_
      croppedLand_
      totPlotLand_
      plotLand_

      croppedPlotLand_
      cropLandActive_

$iftheni.cropRot %cropRotations% == true

      cropRotLand_

  $$iftheni.compStat not "%dynamics%"=="comparative-static"
                  rotHa0_
                  rotHa1_
                  rotHa2_
  $$else.compStat

                  rotComp_
  $$endif.compStat

$else.cropRot
                   cropRotMax_
                   cropGrpRotMax_
                   cropGrpRotMin_
                   cropRotMin_
$endif.cropRot

$$ifi not "%pmp%"=="true"  cropShareEffect_
      catchCropMax_
      CatchCropRequiredOrg_

      NutBalCrop_
      NutBalCropSour_
      NutBalCrop1_

$iftheni.fert %fertilization% =="OrganicFarming"
      legPoolIn_
      legPoolOut_
      legPoolDistMax_
      legPoolItself_
      resiPoolIn_
      resiPoolOut_
      resiPoolDistMax_
      leachedFert_
$endif.fert

$ifi %cattle%==true      NutBalPast_
      nMinMin_
      residueRemoval_
      ownConsumResidue_

      nutTotalApplied_
      nutTotalAppliedYear_

*      nutSurplusMax_
/
;
