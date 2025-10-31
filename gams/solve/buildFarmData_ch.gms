********************************************************************************
$ontext

   FarmDyn project

   GAMS file : BUILD_FARMDATA.GMS

   @purpose   Use the current farm id as the domain for p_farmData to only
              load data for the current farm. That is important for
              the Python code to let it only process information for the current
              farm. Part of running farm samples
   @author   : W. Britz
   @date     : 26.09.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter

$offtext
********************************************************************************

  set curFarmId / %farmIds% /;
  singleTon set farmId(curFarmId) / %farmIds% /;
  parameter p_farmData(curFarmId,*,*);
  parameter p_farmDataPlots(curFarmId,*,*);
  set plot /Plot1*Plot10/;
  set allCrops;
$gdxin "%datDir%/%cropsFile%.gdx"
  $$load allCrops=crops
$gdxin

set items;
$gdxin "%datDir%/%farmSampleFile%.gdx"
  $$load p_farmData
  $$load p_farmDataPlots
  $$load items<p_farmData.dim3
$gdxin
*
* --- generate file with $setglobal statements from p_farmData
*
*     Note: the current version of the API does not support acronyms
*           which are therefore manually defined (all negative)
*
$call 'rm %gams.scrdir%%farmIds%.gms'
$onembeddedCode Python:
  def generateGlobals(db):

    with open(r'%gams.scrdir%%farmIds%.gms', 'w') as f:
       for var in gams.get("p_farmData",valueFormat=ValueFormat.TUPLE,recordFormat=RecordFormat.TUPLE ):
           if (str(var[0][1]) == "global" ):
               gams.printLog( str(var[0][2]+" "+str(var[1][0])))
               if ( str(var[1][0]) == "-1.0" ):
                  f.write("$setglobal "+str(var[0][2])+" on\n")
               elif ( str(var[1][0]) == "-10.0" ):
                  f.write("$setglobal "+str(var[0][2])+"\n")
               elif ( str(var[1][0]) == "-2.0" ):
                  f.write("$setglobal "+str(var[0][2])+" off\n")
               elif ( str(var[1][0]) == "-3.0" ):
                  f.write("$setglobal "+str(var[0][2])+" true\n")
               elif ( str(var[1][0]) == "-4.0" ):
                  f.write("$setglobal "+str(var[0][2])+" false\n")
               elif ( str(var[1][0]) == "-5.0" ):
                  f.write("$setglobal "+str(var[0][2])+" deep_litter\n")
               elif ( str(var[1][0]) == "-6.0" ):
                  f.write("$setglobal "+str(var[0][2])+" slatted_floor\n")
               else:
                  f.write("$setglobal "+str(var[0][2])+" "+str(var[1][0])+"\n")



       f.closed

    return 0

  rc = generateGlobals(gams.ws.add_database_from_gdx(r'%gams.wdir%/../dat/%farmSampleFile%.gdx'))
$offembeddedCode
*
* --- include generated file and set farm branches, endowments and herd sizes
*

  $$include '%gams.scrdir%%farmIds%.gms'

  $$ifi %farmBranchDairy%==on       farmBranch("dairy")     = yes;
  $$ifi %farmBranchMotherCows%==on  farmBranch("motherCow") = yes;
  $$ifi %farmBranchBeef%==on        farmBranch("beef")      = yes;
  $$ifi %farmBranchSows%==on        farmBranch("sows")      = yes;
  $$ifi %farmBranchFattners%==on    farmBranch("fattners")  = yes;
  $$ifi %farmBranchArable%==on      farmBranch("arable")    = yes;
  $$ifi %farmBranchBiogas%==on      farmBranch("biogas")    = yes;

  $$log "CowStableInv       %cowStableInv%"
  $$log "MotherCowStableInv %motherCowStableInv%"
  $$log "CalvesStableInv    %calvesStableInv%"
  $$log "HeifersStableInv   %heifersStableInv%"
  $$log "BullsStableInv     %BullsStableInv%"

  scalar p_nArabLand,p_nGrasLand,p_nPastLand,
         p_nCows,p_nBulls,p_nHeifs,p_nCalves,p_nMotherCows,p_nSows,p_nFattners;
*
* --- endowments (AWU are taken from globals)
*
$$iftheni.PlotEndo not "%landEndo%" == "Land endowment per plot"

  p_nArabLand = %nArabLand%;
  p_nGrasLand = %nGrasLand%;
  p_nPastLand = %nPastLand%;

$$else.PlotEndo
p_nArabLand = sum(plot, p_farmDataPlots(farmId,plot,"sizeha") $ (p_farmDataPlots(farmId,plot,"arab") = 1));
p_nGrasLand = sum(plot, p_farmDataPlots(farmId,plot,"sizeha") $ (p_farmDataPlots(farmId,plot,"gras") = 1));
p_nPastLand = sum(plot, p_farmDataPlots(farmId,plot,"sizeha") $ (p_farmDataPlots(farmId,plot,"past") = 1));

p_plots(plot,"Soil") = p_farmDataPlots(farmId,plot,"soil");
p_plots(plot,"sizeHa") = p_farmDataPlots(farmId,plot,"sizeHa");
p_plots(plot,"maxYield") = p_farmDataPlots(farmId,plot,"maxYield");
p_plots(plot,"arab") = p_farmDataPlots(farmId,plot,"arab");
p_plots(plot,"fert") = p_farmDataPlots(farmId,plot,"fert");
p_plots(plot,"gras") = p_farmDataPlots(farmId,plot,"gras");
p_plots(plot,"past") = p_farmDataPlots(farmId,plot,"past");
p_plots(plot,"relief") = p_farmDataPlots(farmId,plot,"relief");
p_plots(plot,"margin") = p_farmDataPlots(farmId,plot,"margin");
display p_plots, p_farmDataPlots;
*p_plots(plot,*)  p_farmDataPlots(farmId,plot,*) ;

$$endif.PlotEndo
*
* --- predefined herd size
*
  p_nCows        = %nCows%; p_nHeifs = %nHeifs%; p_nCalves = %nCalves%;
  p_nMotherCows  = %nMotherCows%;
  p_nBulls       = %nBulls%;
  p_nCalves      = %nCalves%;
  p_nHeifs       = %nHeifs%;
  p_nFattners    = %nFattners%;
  p_nSows        = %nSows%;
*
* --- crops and yields (only crops with a yield will be loaded into farm)
*
  option kill=selCrops;
  selCrops(allCrops) $ p_farmData(farmId,"yields",allCrops) = yes;
  p_cropYieldInt(selCrops,"conv") = p_farmData(farmId,"yields",selCrops);
  p_cropYieldInt("idle","yield")   = 0;
*
* --- Overwrite dry matter yields of gras lands with data from p_farmData
*     (a missing entry will delete the grass option)
*
  set grasOptions / set.p_grasAttrGui_dim3 /;
  p_grasAttrGui('yield',grasOptions,'DM') = p_farmData(farmId,"yields",grasOptions);

$setglobal calibRes farm_empty
$ifi "%calibration%"=="false"    $setglobal calibFile %farmSampleFile%_%farmIDs%
$ifi "%loadCalibration%"=="true" $setglobal calibRes %farmSampleFile%_%farmIDs%
$ifi "%loadCalibration%"=="true" $setglobal startFromCalibRes true