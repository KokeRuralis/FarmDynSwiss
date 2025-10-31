********************************************************************************
$ontext

   FarmDyn project

   GAMS file : DEBUG_BOUNDS.GMS

   @purpose  : Introduce lower/upper bound on activity levels for debugging purposes
               Steered by GUI

   @author   : W.Britz
   @date     : 27.01.18
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter.gms

$offtext
********************************************************************************
*
*  --- debug bounds as above
*
$iftheni "%forceCropResults%" == "1 ha of each system/tillage/intensity"
*
*   --- forceint tests if at least 1 ha of each crop is feasible
*
    v_cropHa.lo(crops,plot,till,intens,t_n(t,nCur)) $ (c_p_t_i(crops,plot,till,intens) $ (not catchCrops(crops))) = 1;
    p_cutLow = -inf;
$elseif "%forceCropResults%" == "Fix to table"

    v_sumCrop.lo(curCrops(arabCrops),curSys,t_n(t,nCur)) $ fixCropLevels(curCrops,"ha") = fixCropLevels(curCrops,"ha")*0.999;
*    v_sumCrop.up(curCrops(arabCrops),curSys,t_n(t,nCur)) $ fixCropLevels(curCrops,"ha") = fixCropLevels(curCrops,"ha")*1.001;

$endif



*
* --- minimal / fixed number of animals from interface
*
$iftheni.fixingAnim not "%DebugBoundsAnimals%"=="None"
   $$ifthen.sumHerd defined v_sumHerd
      $$ifthen.setCows set forceCows
      $$ifthene.fc %forceCows%>0
          v_sumherd.lo("cows",breeds,t_n(tCur,nCur))                                              = %forceCows%*1.000;
          $$ifi "%debugBoundsAnimals%"=="Fixed" v_sumherd.up("cows",breeds,t_n(tCur,nCur))        = %forceCows%*1.001;
          p_cutLow = -inf;
      $$endif.fc
      $$ifthene.fcl %forceCowsLU%>0
         v_sumgv.lo(tCur,nCur)                                      = %forceCowsLU%* (p_nArabLand + p_nGrasLand +   p_nPastLand ) ;                                       
          $$ifi "%debugBoundsAnimals%"=="Fixed"v_sumgv.up(tCur,nCur) =%forceCowsLU% * (p_nArabLand + p_nGrasLand +   p_nPastLand ) * 1.01;
          p_cutLow = -inf;
      $$endif.fcl
      $$endif.setCows

      $$ifthen.setFc set forceMotherCows
      $$ifthene.fc %forceMotherCows%>0
          v_sumherd.lo("motherCow",breeds,t_n(tCur,nCur)) = %forceMotherCows%;
          $$ifi "%debugBoundsAnimals%"=="Fixed" v_sumherd.up("motherCow",breeds,t_n(tCur,nCur)) = %forceMotherCows%*1.001;
          p_cutLow = -inf;
      $$endif.fc
      $$endif.setfc

      $$ifthen.setSows set forceSows
      $$ifthene %forceSows%>0
          v_sumHerd.lo("sows",breeds,t_n(t,nCur))                                         = %forceSows%;
          $$ifi "%debugBoundsAnimals%"=="Fixed" v_sumHerd.up("sows",breeds,t_n(t,nCur))    = %forceSows%*1.001;
          p_cutLow = -inf;
      $$endif
      $$endif.setSows

      $$ifthen.setFattners set forceFattners
      $$ifthene %forceFattners%>0
          v_sumHerd.lo("fattners",breeds,t_n(t,nCur)) = %forceFattners%;
          $$ifi "%debugBoundsAnimals%"=="Fixed" v_sumHerd.up("fattners",breeds,t_n(t,nCur)) = %forceFattners%*1.001;
          p_cutLow = -inf;
      $$endif
      $$endif.setFattners

      $$ifthen.setBulls set forceBulls
      $$ifthene %forcebulls%>0
           v_sumHerd.lo("bulls",breeds,t_n(t,nCur)) $ (v_sumHerd.up("bulls",breeds,t,nCur) ne 0)   = %forceBulls%;
          $$ifi "%debugBoundsAnimals%"=="Fixed" v_sumHerd.up("bulls",breeds,t_n(t,nCur)) = %forceBulls%*1.001;
          p_cutLow = -inf;
      $$endif
      $$endif.setBulls
   $$endif.sumHerd
$endif.fixingAnim

$iftheni.biogas "%biogas%"=="true"

$iftheni.bg %forceBiogasDynamic% == true

$iftheni.d not "%dynamics%" == "Comparative-static"
    v_useBioGasPlant.lo("500kw",eeg,"%firstYear%",nCur) $ (eeg_t(eeg,"%firstYear%") and t_n("%firstYear%",nCur)
                                                      and (eeg.pos eq smin(eeg_t(eeg1,"%firstYear%"), eeg1.pos))) = 1;
    p_cutLow = -inf;
$endif.d
$endif.bg


$iftheni.bio %forceBiogasCompStat% == true
$iftheni.dd "%dynamics%" == "Comparative-static"
    v_useBioGasPlant.lo("500kw","EM2009","%firstYear%",nCur) $ t_n("%firstYear%",nCur) = 1;
    p_cutLow = -inf;
*   v_totVolFermMonthly.lo("500KW","E2009",t,nCur,m) = 10;
   v_purchCrop.lo("500KW","EM2009",biogasFeedM,t,nCur,m) $sum(sameas(biogasFeedM,maizSilage),1) = 10;
$endif.dd
$endif.bio
$endif.biogas

