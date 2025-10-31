********************************************************************************
$ontext

   FARMDYN project

   GAMS file : CROPPING.GMS

   @purpose  : Define yields, max. rotational shares, variable costs,
               N content of crops
   @author   : Bernd Lengers
   @date     : 13.11.10
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************
$batinclude 'util/title.gms' "'%titlePrefix% Define coefficients relating to crops'"

********************************************************************************
*
* --- Parameter needed for crop parameter specification
*
********************************************************************************

 op_machType(operation,machType) $ (not p_machAttr(machType,"price")) = no;

 set c_ss_t_i(crops,soil,till,intens);
  c_ss_t_i(curCrops,soil,till,intens) $ sum(soil_plot(soil,plot),c_p_t_i(curCrops,plot,till,intens)) = YES;
*
*   --- Crop yields and yield increase is defined by data from interface
*
  p_storageLoss(crops) $ (not p_storageLoss(crops)) = 1;
  p_storageLoss(prods) $ (not p_storageLoss(prods)) = 1;


  if (sum(curCrops(arabCrops) $ (   (     (not sum(sameas(arabCrops,prods), p_cropYieldInt(arabCrops,"conv")))
                                      and (not sum(sameas(arabCrops,prods), p_cropYieldInt(arabCrops,"org")))
                                    ) $ mainCrops(curCrops) $ (not NoCashcrops(curCrops)) $ (not sameas(curCrops,"idle"))
                                       $$iftheni.e"%ecoSchemesCapPillar1%" == "true"
                                      $ (not ES1crops(curcrops))
                                      $$endif.e
                                         ),1),
     option kill=curCrops;
*    --- curCrops now modified to comprise the crops with missing yields, only
     curCrops(arabCrops) $ ( sum(sameas(arabCrops,prods), p_cropYieldInt(arabCrops,"conv")) and sum(sameas(arabCrops,prods), p_cropYieldInt(arabCrops,"org")) or sameas(arabCrops,"idle")) = no;
     curCrops(arabCrops) $ ( not mainCrops(arabCrops)) = no;
     abort "Missing crop yields in file: %system.fn%, line: %system.incline%",curCrops,p_cropYieldInt;
  );

    p_OCoeffC(c_ss_t_i(curCrops(arabCrops),soil,till,intens),prods,t)   $(sameas(arabCrops,prods) $ (not sameas(till,"org")))
       =  p_cropYieldInt(arabCrops,"conv")
            $$iftheni.data "%database%" == "KTBL_database"
            *  ((1.00 + p_cropYieldInt(arabCrops,'Change,conv % p.a.')/100)**t.pos)
            $$endif.data
            ;

   p_OCoeffC(c_ss_t_i(curCrops(arabCrops),soil,"org",intens),prods,t)   $ sameas(arabCrops,prods)
      =  p_cropYieldInt(arabCrops,"org")
           $$iftheni.data "%database%" == "KTBL_database"
           *  ((1.00 + p_cropYieldInt(arabCrops,'Change,org % p.a.')/100)**t.pos)
           $$endif.data
           ;

*
* --- consider storage losses
*
  p_OCoeffC(c_ss_t_i(curCrops(arabCrops),soil,till,intens),prods,t) $ (sameas(arabCrops,prods) and p_storageLoss(prods))
    = p_OCoeffC(arabCrops,soil,till,intens,prods,t) * p_storageLoss(prods);

*
* --- yields in organic farming
*     (yield differences from dat/crop_xx.gms file)
*
*
  p_OCoeffC(c_ss_t_i(curCrops,soil,"org",intens),prods,t) $ (not p_OCoeffC(curCrops,soil,"org",intens,prods,t))
             = p_oCoeffC(curCrops,soil,"plough",intens,prods,t) * p_organicYieldMult(curCrops);


$ifthen.grasOutput defined grasOutputs
*
*   --- grass lands and grazing in fresh matter (from GUI attribute table)
*

    p_oCoeffc(c_ss_t_i(curCrops(grassCrops),soil,till,intens),grasOutput,t)
         = sum( (sameas(grasOutput,grasOutputs),m),p_grasAttr(grassCrops,grasOutputs,m)
                                              / (p_nutGras(grasOutput,"DM") / 1000) )
               * p_storageLoss(grasOutput);

*   --- monthly outputs for grazing in t fresh matter (from GUI attribute table)
*
    p_oCoeffM(c_ss_t_i(curCrops(grassCrops),soil,till,intens),grasOutput,m,t)
         = sum( sameas(grasOutput,pastOutputs),p_grasAttr(grassCrops,pastOutputs,m)/ (p_nutGras(grasOutput,"DM") / 1000) );

* --- yields in organic farming

  p_OCoeffM(c_ss_t_i(curCrops(grassCrops),soil,"org",intens),grasOutput,m,t)
   = p_OCoeffM(grassCrops,soil,"org",intens,grasOutput,m,t) * p_organicYieldMult(curCrops);

$endif.grasOutput


*
* --- Definition of nutrient need depending on crop removal required for Fertilization = Default
*
$iftheni.fert %Fertilization% == "Default"

* --- nutrient need, taking into that output coefficient are measured in t and not dt, therefore * 10.

  p_nutNeed(c_ss_t_i(curCrops(crops),soil,till,intens),nut,t)
         = sum( prods $ p_OCoeffC(crops,soil,till,intens,prods,t), p_OCoeffC(crops,soil,till,intens,prods,t)/p_storageLoss(prods)
             * (  p_nutContent(crops,prods,"conv",nut) $ (not sameas(till,"org"))
                + p_nutContent(crops,prods,"org",nut)  $      sameas(till,"org") )*10);
$endif.fert

 $$iftheni.fert %Fertilization% == "OrganicFarming"

*
*--- Calculate N removal (N content in harvested products) , storage losses are considered,
*    taking into that output coefficient are measured in t and not dt, therefore * 10.
*    here, not only arable crops are considered but also catchcrops

  p_nutNeed(c_ss_t_i(curCrops(crops),soil,till,intens),nut,t) $ (not sameas(till,"org"))
         =   p_cropYieldInt(curCrops,"conv")  * p_storageLoss(curCrops)
              *  ((1.00 + p_cropYieldInt(curCrops,'Change,conv % p.a.')/100)**t.pos)
              *   sum(prods, p_nutContent(curCrops,prods,"conv",nut) * 10 $(sameas(curcrops,prods)))
              ;
  p_nutNeed(c_ss_t_i(curCrops(crops),soil,"org",intens),nut,t)
         =  p_cropYieldInt(curCrops,"org") * p_storageLoss(curCrops)
             *  ((1.00 + p_cropYieldInt(curCrops,'Change,org % p.a.')/100)**t.pos)
             *    sum(prods, p_nutContent(curCrops,prods,"org",nut) * 10 $(sameas(curCrops,prods)))
             ;
*
*--- Calculate N extraction of shoot (harvested product + by-product)
*

  p_NextractShoot(c_ss_t_i(curCrops,soil,till,intens),t)    $ (not sameas(till,"org"))
          =  p_cropYieldInt(curCrops,"conv")
              *  ((1.00 + p_cropYieldInt(curCrops,'Change,conv % p.a.')/100)**t.pos)
              *  p_NcontShoot(curCrops,"conv") * 10
             ;

  p_NExtractShoot(c_ss_t_i(curCrops,soil,"org",intens),t)
          =  p_cropYieldInt(curCrops,"org")
              *  ((1.00 + p_cropYieldInt(curCrops,'Change,org % p.a.')/100)**t.pos)
              *  p_NcontShoot(curCrops,"org") * 10
            ;

*
* --- "N content in plant, including main product, by-product, residues and roots"
*
   p_NExtractPlant(c_ss_t_i(curCrops,soil,till,intens),t)    $ (not sameas(till,"org"))
           =  p_cropYieldInt(curCrops,"conv")
               *  ((1.00 + p_cropYieldInt(curCrops,'Change,conv % p.a.')/100)**t.pos)
               *  p_NcontPlant(curCrops,"conv") * 10
             ;

   p_NExtractPlant(c_ss_t_i(curCrops,soil,"org",intens),t)
           =  p_cropYieldInt(curCrops,"org")
            *  ((1.00 + p_cropYieldInt(curCrops,'Change,org % p.a.')/100)**t.pos)
            *  p_NcontPlant(curCrops,"org") * 10
            ;

* --- for crops for whoch p_NextractShoot is not defined (e.g. CCclover)
   p_NextractShoot(c_ss_t_i(curCrops,soil,till,intens),t) $ (not p_NextractShoot(curCrops,soil,till,intens,t))
           =  p_nutNeed(curCrops,soil,till,intens,"N",t) ;

   p_NExtractPlant(c_ss_t_i(curCrops,soil,till,intens),t) $ (not p_NExtractPlant(curCrops,soil,till,intens,t))
           =  p_nutNeed(curCrops,soil,till,intens,"N",t) ;

* --- Nitrogen in crop residues and roots

    p_Nroots(c_ss_t_i(curCrops,soil,till,intens),t)
       = p_NExtractPlant(curCrops,soil,till,intens,t)
         - p_NExtractShoot(curCrops,soil,till,intens,t);

*
* --- Nitrogen in non harvested byproduct
*
    p_Nbyproduct(c_ss_t_i(curCrops,soil,till,intens),t)
      = p_NExtractShoot(curCrops,soil,till,intens,t)
       - p_nutNeed(curCrops,soil,till,intens,"N",t);

*
* --- N in crop residues remaining on the field (by-product as well as crop residues and roots)
*

   p_Nresidues(c_ss_t_i(curCrops,soil,till,intens),t)
     = p_Nbyproduct(curCrops,soil,till,intens,t) + p_Nroots(curCrops,soil,till,intens,t)  ;

*
*  ---- Nitrogen loss through plant senescence (such loss ranges from 2 to 8% of aboveground plant N) -> 5% implemented
*

    p_NPlantSenescence(c_ss_t_i(curCrops,soil,till,intens),t)
     =  p_NextractShoot(curCrops,soil,till,intens,t) * 0.05;

 $$endif.fert

 $$ifthen.grasOutput defined grasOutputs
*
* --- pasture nutrient need, taking into that output coefficient are measured in t and not dt, therefore * 10.
*       construct is important to distribute excreta from grazing to grazed grassland evenly

   p_pastNeed(c_ss_t_i(curCrops(crops),soil,till,intens),nut,t)
       = sum( pastOutput $ p_OCoeffC(crops,soil,till,intens,pastOutput,t), p_OCoeffC(crops,soil,till,intens,pastOutput,t)/p_storageLoss(pastOutput)
           * (   p_nutContent(crops,pastOutput,"conv",nut) $ (not sameas(till,"org"))
               + p_nutContent(crops,pastOutput,"org",nut)  $      sameas(till,"org")
              )*10);

  p_pastNeedMonthly(c_ss_t_i(curCrops(crops),soil,till,intens),nut,t,m)
     $ (sum((m1,pastOutputs),p_grasAttr(curCrops,pastOutputs,m1) * p_nutGras(pastOutputs,"XP")))
       = p_pastNeed(curCrops,soil,till,intens,nut,t)
         * sum(pastOutputs, p_grasAttr(curCrops,pastOutputs,m)* p_nutGras(pastOutputs,"XP"))
     / sum((m1,pastOutputs),p_grasAttr(curCrops,pastOutputs,m1) * p_nutGras(pastOutputs,"XP"))
           ;

 $$endif.grasOutput

* --- Surplus restriction need if Fertilization Ordinance is swichted off to avoid very high manure application

$iftheni.fert not %Fertilization% == "FertilizationOrdinance"
  p_nutSurplusMax(c_p_t_i(curCrops(crops),plot,till,intens),nut,t)
            = min(200,sum(plot_soil(plot,soil),p_nutNeed(crops,soil,till,intens,nut,t) * 0.5));

$elseif.fert %Fertilization% == "FertilizationOrdinance"

  p_nutSurplusMax(c_p_t_i(curCrops(crops),plot,till,intens),nut,t)
            = 200 ;

$endif.fert


  p_maxRotShare(GRAS,curSys,soil)       =  1;
  p_maxRotShare(past,curSys,soil)       =  1;
  p_maxRotShare(catchCrops,curSys,soil) =  1;
  p_maxRotShare(idle,curSys,soil)       =  1;

  p_maxRotShare(curCrops,curSys,soil) $ (not p_maxRotShare(curCrops,curSys,soil)) = 1;

  p_critShare(crops ,curSys,cropShareLevl)
     = (cropShareLevl.pos/(card(cropShareLevl)+1))**1.5
                                               * smax(soil, p_maxRotShare(crops,curSys,soil))
                                               * uniform(1-0.75/card(cropShareLevl),1+0.75/card(cropShareLevl));
*
* --- at the maximal share, the plant protection cost increase by 50%
*
  p_cropShareLevl(crops,curSys,cropShareLevl) $ p_critShare(crops ,curSys,cropShareLevl)
     = 0.50 * (p_critShare(crops ,curSys,cropShareLevl)-p_critShare(crops,curSys,cropShareLevl-1))
                       /[smax(soil, p_maxRotShare(crops,curSys,soil))];
*
* --- Parameters for costs related to cropping
*

$batinclude "%datdir%/%cropsGmsFile%.gms" yields

   parameter p_checkCost(crops,till,intens,t);

  p_checkCost(curCrops,till,intens,t) $ sum(c_p_t_i(curCrops,plot,till,intens),1)
         = sum(inputs, p_costQuant(curCrops,till,intens,inputs) * sum(sys_till(sys,till),p_price(inputs,sys,t)));

  p_checkCost(curCrops,till,intens,t) $ sum(c_p_t_i(curCrops,plot,till,intens),1)
    =
* --- not KTBL crops
    sum( (operation,actMachVar,act_rounded_plotsize,labPeriod),
            p_crop_op_per_till(curCrops,operation,labPeriod,till,intens)
                *    op_attr(operation,actMachVar,act_rounded_plotsize,"varCost"))
$iftheni.data "%database%" == "KTBL_database"
* ---  KTBL crops
   + sum((operation),
            p_opInputReq(curCrops,till,"varcost",operation))
$endif.data
              ;
   p_vCostC(curCrops,till,intens,"%firstYear%") $ p_checkCost(curCrops,till,intens,"%firstYear%")
     =
       [

*
*      variable cost of builidngs and facilities not explicitly modelled
*
$iftheni.data "%database%" == "KTBL_database"
      +  p_machNeed(curcrops,till,"normal","Buildings and Facilities","invCost") $ sum((maizSilage, GPS, potatoes), not (sameas(curcrops,maizSilage) and sameas(curcrops,GPS) and sameas(curCrops,potatoes)))
$endif.data
*
*       variable machinery cost for machinery not explicitly modelled
*
      +  sum( (operation,actMachVar,act_rounded_plotsize,labPeriod)
            $ (not sum(op_machType(operation,machType) $ (not sameas(machType,"tractor")),1)),
                  p_crop_op_per_till(curCrops,operation,labPeriod,till,intens)
                  * (  op_attr(operation,actMachVar,act_rounded_plotsize,"varCost")  $ (not contractOperation(operation))
*
*                --- subtract costs for tractor
                      -   p_machAttr("tractor","varCost_h") $ op_machType(operation,"tractor")
                            *op_attr(operation,actMachVar,act_rounded_plotsize,"labTime")))
       ];

  p_costQuant(curCrops,till,intens,"contractWork") $ p_checkCost(curCrops,till,intens,"%firstYear%")
   =
*
*      --- costs charged by contract operator for machine use
*
         sum(contractMachines(machType) $ p_lifeTimeM(machType,"ha"),
           p_machNeed(curCrops,till,intens,machType,"ha")
            * (    p_priceMach(machType,"%firstYear%")/p_lifeTimeM(machType,"ha")
                 + p_machAttr(machType,"varCost_ha"))
          )
       + sum(contractMachines(machType) $ p_lifeTimeM(machType,"hour"),
           p_machNeed(curCrops,till,intens,machType,"hour")
            * (   p_priceMach(machType,"%firstYear%")/p_lifeTimeM(machType,"hour")
                + p_machAttr(machType,"varCost_h")
                + p_machAttr(machType,"fixCost_h")
*
*               --- the assumption is that diesel costs per hour are comprised in varCost per hour,
*                   with a price of 0.9, see dat\mach_de
*
                + p_machAttr(machType,"diesel_h") * (p_price("diesel","conv","%firstYear%")-0.9))
         )
*
*      --- plus 35 Euro per hour of work
*
       + p_contractLab(curCrops,till,intens) * 35

*
*  --- plus contract operation costs reported by KTBL (e.g. for operations requiring high mechanisation, soil samples)
*
$iftheni.data "%database%" == "KTBL_database"
         + sum((operation,labperiod,amount), p_opInputReq(curCrops,till,"services",operation)
          * p_crop_op_per_tillKTBL(curcrops,operation,labperiod,till,amount,intens))
$endif.data
;

*
*  --- delete machine need for operations based on contract work
*
   p_machNeed(curCrops,till,intens,contractMachines,"hour") = 0;
   p_machNeed(curCrops,till,intens,contractMachines,"ha")   = 0;
*
*  --- increase from year to year by output price growth
*
   p_vCostC(curCrops,till,intens,t) $ p_checkCost(curCrops,till,intens,t)
     =  p_vCostC(curCrops,till,intens,"%firstYear%") * [1+%outputPriceGrowthRate%/100]**t.pos;


   p_fCostC(curCrops,till,intens,"%firstYear%") $ p_checkCost(curCrops,till,intens,"%firstYear%")

     =
       [
*
*       fixed machinery cost for machinery not explicitly modelled
*
      +  sum( (operation,actMachVar,act_rounded_plotsize,labPeriod)
           $ (not sum(op_machType(operation,machType) $ (not sameas(machType,"tractor")),1)),
                  p_crop_op_per_till(curCrops,operation,labPeriod,till,intens)
                  * (  op_attr(operation,actMachVar,act_rounded_plotsize,"fixCost") $ (not contractOperation(operation))
*
*                --- subtract costs for tractor
                      - p_machAttr("tractor","fixCost_h") $ op_machType(operation,"tractor")
                            *op_attr(operation,actMachVar,act_rounded_plotsize,"labTime")))
       ];
$ifi "%debugOutput%"=="true"  display p_vCostC,p_fCostc;
*  --- increase from year to year by output price growth
*
   p_fCostC(curCrops,till,intens,t) $ p_checkCost(curCrops,till,intens,t)
     =  p_fCostC(curCrops,till,intens,"%firstYear%") * [1+%outputPriceGrowthRate%/100]**t.pos;

$ifthen.gras defined grasTypes


  p_fCostC(curCrops,"noTill",intens,"%firstYear%") $ (sameas(intens,"silo"))
      = p_fCostC(curCrops,"silo","silo","%firstYear%");

  p_fCostC(curCrops,"noTill",intens,"%firstYear%") $ (sameas(intens,"bales"))
      = p_fCostC(curCrops,"bales","bales","%firstYear%");

  p_fCostC(curCrops,"noTill",intens,"%firstYear%") $ (sameas(intens,"hay"))
      = p_fCostC(curCrops,"hay","hay","%firstYear%");


  p_fCostC(curCrops,"noTill",intens,"%firstYear%") $ (sameas(intens,"hayM"))
      = p_fCostC(curCrops,"hayM","hayM","%firstYear%");

  
  p_fCostC(curCrops,"noTill",intens,"%firstYear%") $ (sameas(intens,"grasM"))
      = p_fCostC(curCrops,"grasM","grasM","%firstYear%");
$endif.gras

$if setglobal cropInputsPrice  p_vCostC(curCrops,till,intens,t) $ p_checkCost(curCrops,till,intens,t) =  p_vCostC(curCrops,till,intens,t)*%cropInputsPrice%;
$if setglobal cropInputsPrice  p_fCostC(curCrops,till,intens,t) $ p_checkCost(curCrops,till,intens,t) =  p_fCostC(curCrops,till,intens,t)*%cropInputsPrice%;

   p_machCost(machType,"hour",t) = p_machAttr(machType,"varCost_h") * [1.+%OutputPriceGrowthRate%/100] ** t.pos;
   p_machCost(machType,"ha",t)   = p_machAttr(machType,"varCost_ha") * [1.+%OutputPriceGrowthRate%/100] ** t.pos;

   p_costQuant(crops,till,intens,inputs) $ (not c_t_i(crops,till,intens)) = no;


$ifi "%debugOutput%"=="true" display p_costQuant;
