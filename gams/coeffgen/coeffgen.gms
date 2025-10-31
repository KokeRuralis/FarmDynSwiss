********************************************************************************
$ontext

   FARMDYN project

   GAMS file : COEFFGEN.GMS

   @purpose  : Define coefficient matrix for template model

   @author   : Wolfgang Britz
   @date     : 12.11.10
   @since    :
   @refDoc   :
   @seeAlso  : model/templ.gms
   @calledBy : exp_starter.gms

$offtext
********************************************************************************

*
*  --- define crops currently in model depending on user choice
*
   set label/arable/;

   curCrops(crops) = Yes;
   curCrops(arabCrops) $ (not selCrops(arabCrops)) = NO;
   curCrops(arabCrops) $ (not farmBranch("arable")) = NO;

* --- Catch crops always activated

   curCrops(standardCatchcrops) = YES;

   curArabCrops(arabCrops) = Yes;
   curArabCrops(arabCrops) $ (not selCrops(arabCrops))  = NO;
   curArabCrops(arabCrops) $ (not farmBranch("arable")) = NO;

   curCrops("idle")     =YES;
   curArabCrops("idle") =YES;

   $$ifi not "%cattle%"=="true" curCrops(gras)       = NO;
   $$ifi not "%cattle%"=="true" curCrops(past)       = NO;
   $$ifi not "%cattle%"=="true" curCrops("idleGras") = NO;

* --- Following code makes sure that only crop rotations are selected for which all crops of 
*     the rotation are present (in curCrops)
   
   crop0_rot(crops,rot)   $ (not sum(crop0_rot(curcrops,rot) ,1))    = NO;
   crop0_rot(crops,rot)   $ (not sum(crop1_rot(curcrops,rot) ,1))    = NO;
   crop0_rot(crops,rot)   $ (not sum(crop2_rot(curcrops,rot) ,1))    = NO;
   crop0_rot(crops,rot)   $ (not sum(crop3_rot(curcrops,rot) ,1))    = NO;
   crop0_rot(crops,rot)   $ (not sum(crop4_rot(curcrops,rot) ,1))    = NO;
   crop0_rot(crops,rot)   $ (not sum(crop5_rot(curcrops,rot) ,1))    = NO;
   crop0_rot(crops,rot)   $ (not sum(crop6_rot(curcrops,rot) ,1))    = NO;

   crop1_rot(crops,rot)   $ (not sum(crop0_rot(curcrops,rot) ,1))    = NO;
   crop1_rot(crops,rot)   $ (not sum(crop1_rot(curcrops,rot) ,1))    = NO;
   crop1_rot(crops,rot)   $ (not sum(crop2_rot(curcrops,rot) ,1))    = NO;
   crop1_rot(crops,rot)   $ (not sum(crop3_rot(curcrops,rot) ,1))    = NO;
   crop1_rot(crops,rot)   $ (not sum(crop4_rot(curcrops,rot) ,1))    = NO;
   crop1_rot(crops,rot)   $ (not sum(crop5_rot(curcrops,rot) ,1))    = NO;
   crop1_rot(crops,rot)   $ (not sum(crop6_rot(curcrops,rot) ,1))    = NO;

   crop2_rot(crops,rot)   $ (not sum(crop0_rot(curcrops,rot) ,1))    = NO;
   crop2_rot(crops,rot)   $ (not sum(crop1_rot(curcrops,rot) ,1))    = NO;
   crop2_rot(crops,rot)   $ (not sum(crop2_rot(curcrops,rot) ,1))    = NO;
   crop2_rot(crops,rot)   $ (not sum(crop3_rot(curcrops,rot) ,1))    = NO;
   crop2_rot(crops,rot)   $ (not sum(crop4_rot(curcrops,rot) ,1))    = NO;
   crop2_rot(crops,rot)   $ (not sum(crop5_rot(curcrops,rot) ,1))    = NO;
   crop2_rot(crops,rot)   $ (not sum(crop6_rot(curcrops,rot) ,1))    = NO;

   crop3_rot(crops,rot)   $ (not sum(crop0_rot(curcrops,rot) ,1))    = NO;
   crop3_rot(crops,rot)   $ (not sum(crop1_rot(curcrops,rot) ,1))    = NO;
   crop3_rot(crops,rot)   $ (not sum(crop2_rot(curcrops,rot) ,1))    = NO;
   crop3_rot(crops,rot)   $ (not sum(crop3_rot(curcrops,rot) ,1))    = NO;
   crop3_rot(crops,rot)   $ (not sum(crop4_rot(curcrops,rot) ,1))    = NO;
   crop3_rot(crops,rot)   $ (not sum(crop5_rot(curcrops,rot) ,1))    = NO;
   crop3_rot(crops,rot)   $ (not sum(crop6_rot(curcrops,rot) ,1))    = NO;

   crop4_rot(crops,rot)   $ (not sum(crop0_rot(curcrops,rot) ,1))    = NO;
   crop4_rot(crops,rot)   $ (not sum(crop1_rot(curcrops,rot) ,1))    = NO;
   crop4_rot(crops,rot)   $ (not sum(crop2_rot(curcrops,rot) ,1))    = NO;
   crop4_rot(crops,rot)   $ (not sum(crop3_rot(curcrops,rot) ,1))    = NO;
   crop4_rot(crops,rot)   $ (not sum(crop4_rot(curcrops,rot) ,1))    = NO;
   crop4_rot(crops,rot)   $ (not sum(crop5_rot(curcrops,rot) ,1))    = NO;
   crop4_rot(crops,rot)   $ (not sum(crop6_rot(curcrops,rot) ,1))    = NO;

   crop5_rot(crops,rot)   $ (not sum(crop0_rot(curcrops,rot) ,1))    = NO;
   crop5_rot(crops,rot)   $ (not sum(crop1_rot(curcrops,rot) ,1))    = NO;
   crop5_rot(crops,rot)   $ (not sum(crop2_rot(curcrops,rot) ,1))    = NO;
   crop5_rot(crops,rot)   $ (not sum(crop3_rot(curcrops,rot) ,1))    = NO;
   crop5_rot(crops,rot)   $ (not sum(crop4_rot(curcrops,rot) ,1))    = NO;
   crop5_rot(crops,rot)   $ (not sum(crop5_rot(curcrops,rot) ,1))    = NO;
   crop5_rot(crops,rot)   $ (not sum(crop6_rot(curcrops,rot) ,1))    = NO;

   crop6_rot(crops,rot)   $ (not sum(crop0_rot(curcrops,rot) ,1))    = NO;
   crop6_rot(crops,rot)   $ (not sum(crop1_rot(curcrops,rot) ,1))    = NO;
   crop6_rot(crops,rot)   $ (not sum(crop2_rot(curcrops,rot) ,1))    = NO;
   crop6_rot(crops,rot)   $ (not sum(crop3_rot(curcrops,rot) ,1))    = NO;
   crop6_rot(crops,rot)   $ (not sum(crop4_rot(curcrops,rot) ,1))    = NO;
   crop6_rot(crops,rot)   $ (not sum(crop5_rot(curcrops,rot) ,1))    = NO;
   crop6_rot(crops,rot)   $ (not sum(crop6_rot(curcrops,rot) ,1))    = NO;


* --- Makes sure that only rotations are activated for which all crops
*     are switche on (crop0_rot etc. is above switched off for crop
*     that are not selected in the GUI)

   curRot(rot) = YES;

   curRot(rot) $ (not sum(crop0_rot(crops,rot),1)) = NO;
   curRot(rot) $ (not sum(crop1_rot(crops,rot),1)) = NO;
   curRot(rot) $ (not sum(crop2_rot(crops,rot),1)) = NO;
   curRot(rot) $ (not sum(crop3_rot(crops,rot),1)) = NO;
   curRot(rot) $ (not sum(crop4_rot(crops,rot),1)) = NO;
   curRot(rot) $ (not sum(crop5_rot(crops,rot),1)) = NO;
   curRot(rot) $ (not sum(crop6_rot(crops,rot),1)) = NO;
  
$if not declared curRotations set curRotations /""/;

* --- Now switch off rotations that are not selected in the GUI, although all crops
*     of the rotation are selected

   curRot(rot) $ (not curRotations(rot)) = NO;

* ---- Rotations with only idle needs to be always included
 
   curRot("ID_ID_ID_ID_ID_ID_ID") = YES;


*   ----------------------------------------------------------------------------
*
*      Allowed combinations of crop,soil,tillage type and intensity
*
*   ----------------------------------------------------------------------------

set c_p_t_i_base(crops,*,till,*);

* -------------------------------------------------------------------------------------
*
* --- KTBL: load allowed combination of KTBL crops, plot, tillage type and intensity level
*
* -------------------------------------------------------------------------------------
$onempty
$iftheni.data "%database%"=="KTBL_database"
   set c_p_t_i_GDX(crops,*,till,*);

   $$GDXIN "%datDir%/cropop_ktbl.gdx"
     $$LOAD   c_p_t_i_GDX=c_p_t_i
   $$GDXIN

*  --- implement c_p_t_i for KTBL crops
   c_p_t_i(curCrops,plot,till,"normal") $c_p_t_i_GDX(curCrops,"plot",till,"normal") = YES;
*
*  --- standard mode is: plough and only one intensity level for crops
*      implement c_p_t_i for crops not included in KTBL database
   c_p_t_i(curCrops,plot,"plough","normal") $ (not (sum(till, c_p_t_i_GDX(curCrops,"plot",till,"normal")))) = YES;



*   --- delete notill, mintill and org option of KTBL crops if mintill / notill / org is not selected
    $$ifi not %noTill%     == true  c_p_t_i(curCrops,plot,"noTill","normal")  = NO;
    $$ifi not %minTill%    == true  c_p_t_i(curCrops,plot,"minTill","normal") = NO;
    $$ifi "%orgTill%"      =="off"  c_p_t_i(curCrops,plot,"org","normal")     = NO;


    $$ifi %noTill%     == true  c_p_t_i(curCrops,plot,"noTill","normal") $ (c_p_t_i(curCrops,plot,"plough","normal") $ (not (sum(till, c_p_t_i_GDX(curCrops,"plot",till,"normal")))))   = YES;
    $$ifi %minTill%    == true  c_p_t_i(curCrops,plot,"minTill","normal") $ (c_p_t_i(curCrops,plot,"plough","normal")  $ (not (sum(till, c_p_t_i_GDX(curCrops,"plot",till,"normal"))))) = YES;
    $$ifi not "%orgTill%"=="off"  c_p_t_i(curCrops,plot,"org","normal")  $ (c_p_t_i(curCrops,plot,"plough","normal") $ (not (sum(till, c_p_t_i_GDX(curCrops,"plot",till,"normal")))))   = YES;


$else.data

* --------------------------------------------------------------------------------------------------
*
* User: load allowed combination of user defined crops, plot, tillage type and intensity level
*
* ----------------------------------------------------------------------------------------------------


     c_p_t_i(curCrops,plot,"plough","normal") = YES;
     $$ifi %noTill%     == true  c_p_t_i(curCrops,plot,"noTill","normal") $ (c_p_t_i(curCrops,plot,"plough","normal"))   = YES;
     $$ifi %minTill%    == true  c_p_t_i(curCrops,plot,"minTill","normal") $ (c_p_t_i(curCrops,plot,"plough","normal"))  = YES;
     $$ifi not "%orgTill%"=="off"  c_p_t_i(curCrops,plot,"org","normal")  $ (c_p_t_i(curCrops,plot,"plough","normal"))   = YES;


$endif.data
$offempty

$ifi %ploughTill% == false c_p_t_i(curCrops,plot,"org","normal") $ c_p_t_i(curCrops,plot,"plough","normal")      = NO;

* --- If different crop intensities are active, the corresponding intensity levels are activated

$ifi not "%intensoptions%"=="false"  c_p_t_i(curCrops,plot,till,intens) $  c_p_t_i(curCrops,plot,till,"normal") = YES;

* --- Strips and catch crops are only in normal intensity available

$iftheni.intes not %intensOptions%  == false

   $$ifi "%agriEnvSchemes%"=="true"   c_p_t_i(aesCrops(curCrops),plot,till,intens)  $ ( not sameas (intens,"normal") )  = NO ;

   c_p_t_i(catchcrops(curCrops),plot,till,intens)  $ ( not sameas (intens,"normal") )  = NO ;

$endif.intes


   c_p_t_i(catchcrops(curCrops),plot,till,intens)  $ (( not sameas (till,"plough") ) and (not sameas(till,"org")))   = NO ;


*
* --- grass lands are always handled as noTill and default intensity
*
  c_p_t_i("idleGras",plot,till,intens) = NO;
  c_p_t_i(gras,plot,till,intens)       = NO;
  c_p_t_i(past,plot,till,intens)       = NO;
  c_p_t_i(mixPast,plot,till,intens)    = NO;

  c_p_t_i(arabCrops,plot,till,intens)  $ ( sameas(intens,"graz") or sameas(intens,"bales") or sameas(intens,"silo") or sameas(intens,"hay") or sameas(intens,"hayM") or sameas(intens,"grasM")) = NO;
  c_p_t_i(gras,plot,till,intens)       $ ( sameas(till,"noTill")  and (sameas(intens,"bales") or sameas(intens,"silo") or sameas(intens,"hay")or sameas(intens,"hayM") or sameas(intens,"grasM")) ) = YES;
  c_p_t_i(past,plot,till,intens)       $ ( sameas(till,"noTill")  and sameas(intens,"graz"))   = YES;
  c_p_t_i(mixPast,plot,till,intens)    $ ( sameas(till,"noTill")  and  (sameas(intens,"bales") or sameas(intens,"silo") or sameas(intens,"graz") or sameas(intens,"hay") or sameas(intens,"hayM") or sameas(intens,"grasM")) ) = YES;
  c_p_t_i("idleGras",plot,till,intens) $ ( sameas(till,"noTill")  and sameas(intens,"normal")) = YES;
*
* --- idle land as "noTill" and default intensity
*
  c_p_t_i(idle,plot,till,intens) = NO;
  c_p_t_i(idle,plot,till,intens) $ (curCrops(idle) and (sameas(till,"noTill") and sameas(intens,"normal"))) = YES;
  c_p_t_i(crops,plot,till,intens) $ ( not p_plotSize(plot)) = NO;
*
* --- exclude arable crops from grass lands and vice versa
*
  c_p_t_i(arabCrops,plot,till,intens)   $ sum(plot_lt_soil(plot,"gras",soil),1) = NO;
  c_p_t_i(arabCrops,plot,till,intens)   $ sum(plot_lt_soil(plot,"past",soil),1) = NO;

  c_p_t_i(mixPast,plot,till,intens)     $ sum(plot_lt_soil(plot,"arab",soil),1) = NO;
  c_p_t_i(mixPast,plot,till,intens)     $ sum(plot_lt_soil(plot,"past",soil),1) = NO;
  c_p_t_i(past,plot,till,intens)        $ sum(plot_lt_soil(plot,"arab",soil),1) = NO;
  c_p_t_i(gras,plot,till,intens)        $ sum(plot_lt_soil(plot,"past",soil),1) = NO;
*
*     WB: Without this, grasland for cutting only on arable land would be allowed. But this is at odds with the equation
*         fixGrasLand_ in the cattle module which makes sure that the amount of gras/past activities don't exdeed the
*         total amount of gras+pasture land
*
$iftheni.grasOnArab not "%grasOnArab%"=="true"
   c_p_t_i(gras,plot,till,intens)        $ sum(plot_lt_soil(plot,"arab",soil),1) = NO;
$$endif.grasOnArab


  c_p_t_i("idleGras",plot,till,intens)  = no;
  c_p_t_i("idleGras",plot,till,intens)  $ (sum(plot_lt_soil(plot,"Gras",soil),1) $ sameas(till,"noTill") $ sameas(intens,"normal")) = yes;
  c_p_t_i("idleGras",plot,till,intens)  $ (sum(plot_lt_soil(plot,"past",soil),1) $ sameas(till,"noTill") $ sameas(intens,"normal")) = yes;


  c_p_t_i(crops,plot,till,intens) $ (not p_plotSize(plot)) = no;
  c_p_t_i(crops,plot,till,intens) $ (not curCrops(crops))  = no;

$iftheni.org not "%orgTill%"=="off"

   $$ifthen.gras defined grasTypes
     c_p_t_i(grassCrops,plot,"org","Bales")   $ c_p_t_i(grassCrops,plot,"noTill","Bales")   = YES;
     c_p_t_i(grassCrops,plot,"org","Silo")    $ c_p_t_i(grassCrops,plot,"noTill","Silo")    = YES;
     c_p_t_i(grassCrops,plot,"org","Graz")    $ c_p_t_i(grassCrops,plot,"noTill","Graz")    = YES;
     c_p_t_i("idleGras",plot,"org","normal")  $ c_p_t_i("idleGras",plot,"noTill","normal")  = YES;
   $$endif.gras
   c_p_t_i("idle",plot,"org","normal")      $ c_p_t_i("idle",plot,"noTill","normal")      = YES;
   curSys("org")   = yes;
   $$ifi "%orgTill%"=="optional" curSys("conv") = yes;

$else.org
   c_p_t_i(crops,plot,"org","normal")  = no;
   curSys("conv") = yes;
   curSys("org")  = no;
$endif.org

*
*   --- limit grassland options per plot based on max attainable yield from interface 
$$iftheni.PlotEndo  "%landEndo%" == "Land endowment per plot"

$iftheni.cattle "%cattle%"=="true"
  c_p_t_i(grassCrops,plot,till,intens) 
    $ (sum((grasOutputs,m),p_grasAttr(grassCrops,grasOutputs,m) ) > p_plots(plot,"maxYield") )= NO;
$$endif.cattle 

$$endif.PlotEndo

$ifi %stochProg%==true $include 'coeffgen/stochProg.gms'

$ifi "%cattle%"  == true       $include '%datdir%/%cattleFile%.gms'
$ifi "%cattle%"=="true"        $include 'coeffgen/calves.gms'
$ifi "%cowHerd%"=="true"       $include 'coeffgen/cows.gms'
$ifi "%farmBranchBeef%"=="on"  $include 'coeffgen/beef.gms'


$iftheni.herd "%herd%"=="true"
   $$include 'coeffgen/feeds.gms'
   $$include 'coeffgen/requ.gms'
$endif.herd

parameter  p_intens(crops,intens);
   p_intens(crops,"normal") =     1.0;
$onmulti
$ifthen.intensOpt "%intensoptions%"=="Heyn_Olfs"
*
* -- this information is required in the %cropsGmsFile%.gms to assign
*    the yields at the 10-20-30-40% reduction in N-fertilization
*
  Parameter p_yieldReducN(crops,intens);

  p_intens(crops,"normal") =   1.0;
  p_intens(crops,"f90p") =     0.9;
  p_intens(crops,"f80p") =     0.8;
  p_intens(crops,"f70p") =     0.7;
  p_intens(crops,"f60p") =     0.6;

*
* --- the lower / veryLow sets used in tech.gms to remove certain crop-operations
*
  set lower(intens)   / f80p,f70p,f60p /;
  $$onEmpty
    set verylow(intens) //;
  $$offEmpty
$elseifi.intensOpt "%intensoptions%"=="default"

   p_intens(crops,"fert80p") =     1.0;
   p_intens(crops,"fert80p") =     0.8;
   p_intens(crops,"fert60p") =     0.6;
   p_intens(crops,"fert40p") =     0.4;
   p_intens(crops,"fert20p") =     0.2;

  set lower(intens)   / fert80p,fert60p /;
  set verylow(intens) / fert40p,fert20p /;

$else.intensopt

  $$onEmpty
    set lower(intens) //;
    set verylow(intens) //;
  $$offEmpty
$endif.intensOpt
$offmulti

$batinclude '%datDir%/%cropsGmsFile%.gms' param
$include 'coeffgen/mach.gms'
*
* --- read crop operations, add information in AES crops
*
parameter p_changeOpIntens(crops,operation,labPeriod,intens);
$$include "%datdir%/%cropOpFile%.gms"
$ifi "%agriEnvSchemes%" == "true" $include "%datdir%/%aesfile%.gms"

* --- TO DO TILL - INCLUDE CROPS FOR CAP IN CROPPING STRUCTURE, FOR NOW IN COEFFGEN.GMS

* --- Flower strip, based on data from AES NRW, now for 5 years strip

    p_costQuant("flowerStripES1_1",till,intens,"seed")   = 300/5 ;

    p_crop_op_per_tilla("flowerStripES1_1","plow","AUG2",till)          =  0.2 ;
    p_crop_op_per_tilla("flowerStripES1_1","SeedBedCombi","AUG2",till)  =  0.2 ;
    p_crop_op_per_tilla("flowerStripES1_1","sowmachine","AUG2",till)    =  0.2 ;
    p_crop_op_per_tilla("flowerStripES1_1","mowing","MAR2",till)        =  1  ;
    p_crop_op_per_tilla("flowerStripES1_1","mowing","AUG1",till)        =  1  ;

* --- Costs and field operations are the same for all flower strips for ES 1

    p_costQuant("flowerStripES1_1_2",till,intens,inputs)  = p_costQuant("flowerStripES1_1",till,intens,inputs)  ;
    p_crop_op_per_tilla("flowerStripES1_1_2",operation,labPeriod,till) = p_crop_op_per_tilla("flowerStripES1_1",operation,labPeriod,till) ;

    p_costQuant("flowerStripES1_2_6",till,intens,inputs)  = p_costQuant("flowerStripES1_1",till,intens,inputs)  ;
    p_crop_op_per_tilla("flowerStripES1_2_6",operation,labPeriod,till) = p_crop_op_per_tilla("flowerStripES1_1",operation,labPeriod,till) ;

* ---- ES1: different idle types needed for differentiated payments

    p_costQuant("idleES1_1",till,intens,inputs)  = p_costQuant("idle",till,intens,inputs)  ;
    p_crop_op_per_tilla("idleES1_1",operation,labPeriod,till) = p_crop_op_per_tilla("idle",operation,labPeriod,till) ;

    p_costQuant("idleES1_1_2",till,intens,inputs)  = p_costQuant("idle",till,intens,inputs)  ;
    p_crop_op_per_tilla("idleES1_1_2",operation,labPeriod,till) = p_crop_op_per_tilla("idle",operation,labPeriod,till) ;

    p_costQuant("idleES1_2_6",till,intens,inputs)  = p_costQuant("idle",till,intens,inputs)  ;
    p_crop_op_per_tilla("idleES1_2_6",operation,labPeriod,till) = p_crop_op_per_tilla("idle",operation,labPeriod,till) ;


$ifi "%nonEUCountry%" == "true" $include "%datdir%/%policyDataFile%.gms"
$include 'coeffgen/tech.gms'
$include 'coeffgen/labour.gms'
$ifi not "%dynamics%"=="comparative-static" $include 'coeffgen/credit.gms'
  option c_p_t_i:2:3:1;
$include 'coeffgen/prices.gms'
  option c_p_t_i:2:3:1;
$ifi "%debugOutput%"=="true"  display c_p_t_i;

$ifi "%pigherd%"== true  $include '%datdir%/%pigsFile%.gms'
$ifi "%pigHerd%"=="true" $include 'coeffgen/pigs.gms'

$ifi %herd%==true $include 'coeffgen/stables.gms'

$include 'coeffgen/buildings.gms'
$include 'coeffgen/cropping.gms'
$include 'coeffgen/cropping_intes.gms'



$iftheni.duev "%duev%"=="true"

$include "%datdir%/%fertOrdFile%.gms"
* --- Nutrient need according to Fertilization Ordinance is always included
$include "%datdir%/fertor_fertplan.gms"
$endif.duev

$ifi "%mitiMeasures%" == true $include '%datdir%/enforcedMitigation.gms'

$include 'coeffgen/cropping_nutNeed.gms'
$include 'coeffgen/fertilizing.gms'

$ifi "%Fertilization%" == "OrganicFarming" $include 'coeffgen/organic_fert.gms'
$ifi "%upstreamEF%" == "true" $include "%datdir%/%upstreamEFFile%.gms"
$include "%datdir%/%EmissionsFile%.gms"
$ifi "%envAcc%"=="true" $include 'coeffgen/%EmissionsCoef%.gms'

$iftheni.soci "%socialAcc%" == "true"
 $$include "%datdir%/%socialFile%.gms"
 $$include 'coeffgen/soci_acc.gms'
$endif.soci


$ifi "%manure%"=="true" $include 'coeffgen/manure.gms'
$include 'coeffgen/silos.gms'

$iftheni.biogas %biogas%==true
  $$include 'coeffgen/fermenter_tech.gms'
  $$include 'coeffgen/prices_eeg.gms'
$endif.biogas


$if declared p_herdLabStart $if not defined p_herdLabStart option kill=p_herdLabStart;

