********************************************************************************
$ontext

   FARMDyn project

   GAMS file : Build_data.GMS

   @purpose  : Convert Ktbl Regression results, machine data, direct cost etc.
               into format required by FarmDyn
   @author   : J. Heinrichs, C. Pahmeyer, W.Britz
   @date     : 11.12.20
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************

$offlisting

$onglobal
$setglobal curDir %system.fp%
$include 'incgen/KTBLinc.gms'
*$goto fARMdYN


*
*  --- replacement for selection of crops via GUI
*

$onmulti
* --- combine crops selected in GUI to one crop set
    sets crops / set.CerealsConv        $CerealsConv ,
                 set.FodderConv         $FodderConv,
                 set.EnergyConv         $EnergyConv,
                 set.RootCropsConv      $RootCropsConv,
                 set.OilAndProteinConv  $OilAndProteinConv,
                 set.CatchCropsConv     $CatchCropsConv,
                 set.VegetablesConv     $VegetablesConv/;
    set crops /  set.CerealsOrg         $CerealsOrg,
                 set.FodderOrg          $FodderOrg,
                 set.RootCropsOrg       $RootCropsOrg,
                 set.OilAndProteinOrg   $OilAndProteinOrg,
                 set.CatchCropsOrg      $CatchCropsOrg,
                 set.VegetablesOrg      $VegetablesOrg /;
$offmulti

    sets
       soil
       till / till,mintill,noTill,org, plough/
       sys /org,conv/
       impl                             "Specific implementaion of a procedure (such a plough/minTill/redTill, different of irrigation, ....)"
       procGroupID                      "About 20 category of procedures, such as fertilizing, harvesting"
       ProcedureID                      "Crop, system and tillage specific implementation of procedure group, here: without IDs related to fertilization (except lime)"
       operationID                    "Mechanization level specific implementation of procedure, ID"
       operation                      "Mechanization level specific implementation of procedure, name"
       taskID                           "Individual operation of a work progress"
       machineID                        "unique ID of a machine"
       machine                          "name of a machine"
       machineType                      "Type of a machine, e.g. tractor, plough"
       OpType                           "Type of a operation (e.g. soilsample)"
       intensOperation(operation)     "operations with intens soil cultivation"
       labPeriod
       amount
       amountUnit
       machVar
       machAttr
       items
       stats
       operationID_taskID(operationID,taskID)                      "crossset between operationID and taskID"
       taskID_machineID(taskID,machineID)                          "crossset between taskID and machineID"
       machine_machineType(machine,machineType)                    "assigns a machineType to each machine"
       operation_OpType(operation,OpType)                          "assigns a operationType to each operation"
       machineID_machine(machineID,machine)                        "list of all machines (ID and names)"
       operationID_operation(operationID,operation)                "list of all operations (ID and names)"
       crops_operationID(crops,sys,impl,procGroupID,operationID,procedureID,labPeriod,amount,machVar)
       labReqLevl "field working days requirement level"
       op_rf(operationID,labReqLevl) "Link between operation and available field working days requirement level"
       c_s_i_t(crops,sys,impl,till) "standard implementation IMPL for each crop - system (conv/org) - till (till/noTill/minTill) combination"
    ;

*******************************************************************************************
*                                                                                         *
*    load sets, cross sets and parameters related to machine costs (regression model)     *
*                                                                                         *
*******************************************************************************************

$GDXIN 'ktbl/ktbl.gdx'
*
*                         -- single sets, IDs are numerical identifiers defined by KTBL
*
   $$LOAD                  taskid machineID machAttr  machine operation operationID impl
   $$LOAD                  machineType machine_machineType OpType operation_OpType intensOperation
   $$LOAD                  procGroupID procedureID labperiod amount amountUnit machVar items stats soil
   $$LOAD                  labReqLevl op_rf
*
*                      --- cross sets
*
   $$LOAD                  operationID_taskID taskID_machineID machineID_machine
   $$LOAD                  operationID_operation
   $$LOAD                  crops_operationID
   $$LOAD                 c_s_i_t

$GDXIN

   parameter p_crops_operationID(crops,sys,impl,procGroupID,operationID,procedureID,labPeriod,amount,amountUnit,machVar)
             p_machineID_machAttr(machineID,machAttr)
             p_regCoeff(operationID,amount,soil,items,stats)
             p_noRegCoeff(operationID,amount,soil,items)
             p_Op_nPers(operation,items);


execute_load "ktbl/ktbl.gdx" p_machineID_machAttr,p_regCoeff,p_noRegCoeff, p_crops_operationID, p_Op_nPers;

*
* --- define Sets with currently selected set elements
*      and cross-sets to speed up processing
*
   sets
      curOperationID(operationID)
      curOperation(operation)
      curProcedureID(procedureID)
      curMachineID(machineID)
      curMachine(machine)
      curImpl(impl)
      curAmount(amount)
      curmachineType(machineType)
      curmachine_machineType(machine,machineType)
      curOpType(OpType)
      curOperation_OpType(operation,OpType)
      curintensOperation(operation)
      curOperationID_curOperation(operationID,*)
      operationID_machineID(operationID,machineID)
      crop_workProID(crops,operationID)
      crops_procedID(crops,procedureID)
      operation_labperiod(operation,labperiod)
      crops_OpID_machineID(crops,sys,till,amount,operationID,machVar,machineID)
      crops_Op_machine(crops,sys,till,amount,operation,machVar,machine)
      operationID_machine(operationID,machine)
      crops_operationID(crops,sys,impl,procGroupID,operationID,procedureID,labperiod,amount,machVar)
   ;


* --- only consider relevant combinations of crops currently selected and operationIDs, considering the chosen IMPL from c_s_i_t
*
  crop_workProID(crops,operationID)
   $ sum((crops_operationID(crops,Sys,impl,procGroupID,operationID,procedureID,labperiod,amount,machVar),till)
         $ c_s_i_t(crops,Sys,impl,till),1) = YES;

*
* --- define the list of operationID and operation names currently in use
*
  curOperationID(operationID) $ sum(crop_workProID(crops,operationID),1) = YES;
  curOperation(operation)     $ sum(operationID_operation(curOperationID,operation),1) = YES;

  curOperationID_curOperation(curOperationID,curOperation)$ sum(operationID_operation(curOperationID,curOperation),1)=YES;

*
* --- define Types of operationes currently in use
*

   curOperation_OpType(curOperation,OpType) = YES $ operation_OpType(curOperation,OpType);
   curOpType(OpType) = YES $ sum(curOperation, curOperation_OpType(curOperation,OpType));

* --- some workoperationes do not have a name - set name to its ID
 alias(curOperationID,curOperationID1);
   curOperationID_curOperation(curOperationID,curOperationID1) $(not (sum(curOperation, curOperationID_curOperation(curOperationID,curOperation))))
                           = YES  $ sameas(curOperationID,curOperationID1);

   curintensOperation(curOperation) =YES $ intensOperation(curOperation);


   set curOperation2(*) "set for curwokrprocesses and IDs when name is not available";
   curOperation2(curOperation)   $ sum(curOperationID_curOperation(curOperationID,curOperation),1) = YES;
   curOperation2(curOperationID) $ sum(curOperationID_curOperation(curOperationID1,curOperationID),1) = YES;


*
* --- Link to available field working days requirement level only for operations currently selected
*

   set curOp_rf(operation,labReqLevl);
   curOp_rf(curOperation,labReqLevl) $ sum( operationID_operation(curOperationID,curOperation), op_rf(curOperationID,labReqLevl)) =YES;

*
* --- build list of active combinations of crop and procedure ids and list of active procedure IDs
*
    crops_procedID(crops,procedureID)
       $ sum(crops_operationID(crops,sys,impl,procGroupID,operationID,procedureID,labperiod,amount,machVar),1) = YES;

    curProcedureID(procedureID) $ sum(crops_procedID(crops,procedureID),1) = YES;

*
* --- Filter out the relevant combinations of crop,system,implementation down to the indivudal work process for which
*     regression results are available. Keep procedure group ID to filter out certain groups
*      (such as fertilizer application which are endogenously determined in model)
*     replace impl by till as impl is not defined in farmDyn

   parameter p_crops_operation(crops,sys,till,operationID,labperiod,amount,amountUnit,machVar);

   p_crops_operation(crops,sys,till,curOperationID,labperiod,amount,amountUnit,machVar) =
    sum((procGroupID,curProcedureID,impl),  p_crops_operationID(crops,sys,impl,procGroupID,curOperationID,curProcedureID,labperiod,amount,amountUnit,machVar)$ c_s_i_t(crops,Sys,impl,till));


   set crops_operation(crops,sys,till,operationID,labperiod,amount,machVar);
      crops_operation(crops,sys,till,curOperationID,labperiod,amount,machVar)
       $ (sum(crops_operationID(crops,sys,impl,procGroupID,curOperationID,curProcedureID,labperiod,amount,machVar)
       $ c_s_i_t(crops,sys,impl,till),1))
         = YES;


*
* --- map KTBL-c_s_i_t(crops,sys,impl,till) to  FarmDyn- c_s_t_i(crops,plot,till,intens)
*

   set plot / plot/;
   set intens /"normal" /;
   set FarmDyn_c_s_t_i(crops,plot,*,intens) "Allowed combination of crops, plot, tillage type and intensity level";

   FarmDyn_c_s_t_i(crops,plot,"plough","normal")  $ sum(impl, c_s_i_t(crops,"conv",impl,"till"))     =YES;
   FarmDyn_c_s_t_i(crops,plot,"mintill","normal") $ sum(impl, c_s_i_t(crops,"conv",impl,"mintill"))  =YES;
   FarmDyn_c_s_t_i(crops,plot,"notill","normal")  $ sum(impl, c_s_i_t(crops,"conv",impl,"notill"))   =YES;
* --- in FarmDyn org is only available with plough based tillage -> set org to till
   FarmDyn_c_s_t_i(crops,plot,"org","normal")     $ sum(impl, c_s_i_t(crops,"org",impl,"till"))      =YES;

* --- delete organic farming with mintill / notill as it does not yet exist in FarmDyn
*    replace tillage system till under organic farming by "org"
  crops_operation(crops,"conv","plough",curOperationID,labperiod,amount,machVar) =  crops_operation(crops,"conv","till",curOperationID,labperiod,amount,machVar);
  crops_operation(crops,"conv","till",curOperationID,labperiod,amount,machVar) =  NO;
  crops_operation(crops,"org","org",curOperationID,labperiod,amount,machVar) =  crops_operation(crops,"org","till",curOperationID,labperiod,amount,machVar);
  crops_operation(crops,"org","till",curOperationID,labperiod,amount,machVar)    = NO;
  crops_operation(crops,"org","mintill",curOperationID,labperiod,amount,machVar) = NO;
  crops_operation(crops,"org","notill",curOperationID,labperiod,amount,machVar)  = NO;

  p_crops_operation(crops,"conv","plough",curOperationID,labperiod,amount,amountUnit,machVar) = p_crops_operation(crops,"conv","till",curOperationID,labperiod,amount,amountUnit,machVar);
  p_crops_operation(crops,"conv","till",curOperationID,labperiod,amount,amountUnit,machVar)   = 0;
  p_crops_operation(crops,"org","org",curOperationID,labperiod,amount,amountUnit,machVar)     = p_crops_operation(crops,"org","till",curOperationID,labperiod,amount,amountUnit,machVar);
  p_crops_operation(crops,"org","till",curOperationID,labperiod,amount,amountUnit,machVar)    = 0;
  p_crops_operation(crops,"org","mintill",curOperationID,labperiod,amount,amountUnit,machVar) = 0;
  p_crops_operation(crops,"org","notill",curOperationID,labperiod,amount,amountUnit,machVar)  = 0;

*
* --- define currently active implementations and amounts
*

  curAmount(amount)  $ sum(crops_operation(crops,sys,till,curOperationID,labperiod,amount,machVar),1) = YES;

*
* --- to control for correct mapping, list operationes and labperiod in which WPs are required
*

  operation_labperiod(curOperation,labperiod)
            $ sum((crops_operation(crops,sys,till,curOperationID,labperiod,curAmount,machVar),
             operationID_operation(curOperationID,curOperation)),1) = YES;


*
* --- machinches are linked to task (which are a sub-field of a work process)
*

   operationID_machineID(curOperationID,machineID)
       = YES $ sum((taskID) $ ( operationID_taskID(curOperationID,taskID)
             $ taskID_machineID(taskID,machineID)), 1);


*
* --- only consider relevant combinations of crops, operationIDs and machines
*

  crops_OpID_machineID(crops,sys,till,curAmount,curOperationID,machVar,machineID)
     $ sum((crops_operation(crops,sys,till,curOperationID,labperiod,curAmount,machVar),
                      operationID_machineID(curOperationID,machineID)),1) = YES;
*
* --- only consider relevant machines and machineTypes
*

  curMachineID(machineID) $ sum(crops_OpID_machineID(crops,sys,till,curAmount,curOperationID,machVar,machineID),1) = YES;
  curMachine(machine) $ sum(machineID_machine(curMachineID,machine),1) = YES;


  curmachine_machineType(curmachine,machineType)  = YES $ machine_machineType(curMachine,machineType);
  curmachineType(machineType) = YES $ sum(curmachine, curmachine_machineType(curmachine,machineType));

*
* --- map IDs to names of machines and operationes, long execution time
*
$ontext
  crops_Op_machine(crops,sys,till,curAmount,curOperation,machVar,curMachine)
   $ sum((crops_OpID_machineID(crops,sys,till,curAmount,curOperationID,machVar,curMachineID),
        operationID_operation(curOperationID,curOperation),
        machineID_machine(curMachineID,curMachine)),1) = YES;
$offtext

   set OpID_machine(operationID, machineID,machine);
       OpID_machine(operationID_machineID(curOperationID,curmachineID),curmachine)
            = YES $ machineID_machine(curmachineID,curmachine);

   set op_machType(operation,machine);
       op_machType(curOperation,curmachine) $ sum((OpID_machine(curOperationID,curMachineID,curmachine)) $ operationID_operation(curOperationID,curOperation),1)  =YES ;

* --- subset of machineID machine crossset
      set curmachineID_machine(MachineID,Machine);
          curmachineID_machine(curMachineID,curMachine) = YES $ machineID_machine(curMachineID,curMachine);

*
* --- Attributes of machines required for selected crops
*

* --- map machine attributes to machine attributes used in farmdyn

   set machAttrFarmDyn / "price", "hour", "m3", "ha", "t", "years", "varCost_ha", "varCost_h", "varCost_m3","varCost_t"/;
   set machAttr_to_machattr(machAttrFarmDyn,machAttr);
       machAttr_to_machattr("price","purchasePrice")             = YES;
       machAttr_to_machattr("hour","timeUse")                    = YES;
       machAttr_to_machattr("m3","volumeUse")                    = YES;
       machAttr_to_machattr("ha","areaUse")                      = YES;
       machAttr_to_machattr("t","massUse")                       = YES;
       machAttr_to_machattr("years","useFulLife")                = YES;
       machAttr_to_machattr("varCost_ha","repairCostsPerArea")   = YES;
       machAttr_to_machattr("varCost_h","repairCostsPerTime")    = YES;
       machAttr_to_machattr("varCost_m3","repairCostsPerVolume") = YES;
       machAttr_to_machattr("varCost_t","repairCostsPerMass")    = YES;


   parameter p_machAttr(*,machAttrFarmDyn);
             p_machAttr(curMachine,machAttrFarmDyn) = sum((machineID_machine(curMachineID,curMachine),machAttr_to_machattr(machAttrFarmDyn,machattr)),
                                          p_machineID_machAttr(curMachineID,machAttr));


*
* include information on number of persons required for operation to NoReg Parameter
*

    p_noRegCoeff(curOperationID,curAmount,soil,"nPers") $p_noRegCoeff(curOperationID,curAmount,soil,"time")
                  = sum((operation), p_Op_nPers(operation,"nPers") $ operationID_operation(curOperationID,operation));

* --- store machine related data and regressionCoefficients needed for selected crops in new parameter
parameter  p_regCoeffNew(operationID,amount,soil,items,stats)
           p_noRegCoeffNew(operationID,amount,soil,items)
           p_machineID_machAttrNew(machineID,machAttrFarmDyn);

           p_regCoeffNew(curOperationID,curAmount,soil,items,Stats)        = p_regCoeff(curOperationID,curAmount,soil,items,Stats);
           p_noRegCoeffNew(curOperationID,curAmount,soil,items)            = p_noRegCoeff(curOperationID,curAmount,soil,items);
           p_machineID_machAttrNew(curMachineID,machAttrFarmDyn)               = sum(machAttr_to_machattr(machAttrFarmDyn,machAttr), p_machineID_machAttr(curMachineID,machAttr)) ;

*
* --- build gdx with data related to the regression model (machines and field operations)
*
execute_unload "../dat/cropOp_KTBL.gdx"
*
*  --- sets
*
                               items,stats,
                               FarmDyn_c_s_t_i=c_p_t_i,
                               curOperationID=operationID,
                               curAmount=amount,amountUnit,
                               curmachine=Machine,curmachineID=MachineID,curOperation2=operation,
                               curmachine_machineType=machine_machineType, curmachineType = machineType
                               curOperation_OpType=operation_OpType, curOpType=OpType curintensOperation=intensOperation
                               crops_operation=crops_operationID,
                               curOperationID_curOperation=operationID_operation,
                               curMachineID_machine=MachineID_machine
                               op_machType
                               curOp_rf = op_rf,

*
*  --- parameters
*
*
                               p_crops_operation=p_crops_operationID
                               p_noRegCoeffNew=p_noRegCoeff,p_RegCoeffNew=p_RegCoeff
                               p_machineID_machAttrNew=p_machineID_machAttr, p_machAttr
;

*******************************************************************************************
*                                                                                         *
* ---- load data related to selceted crops to build dat-files                             *
*      (e.g. prices, yields, Nut requirements and content, Max. rotational shares.. )     *
*                                                                                         *
*******************************************************************************************


*
* ---- load data related to direct costs and revenues
*

sets
 io            "all inputs and outputs"
 curIO         "all inputs and outputs for selected crops"
 category      "amount,price, total costs"
 inputsGDX     "list of all inputs in KTBL database"
 curInputsGDX  "all inputs required for selected crops"
 prods         "all outputs"
 ioCategories  "input and output categories (e.g. seeds, herb)"
 unit          "unit of input and output quantities"
;

*load required sets, cross sets and parameters

   $$GDXIN    'ktbl/revenues_directCosts.gdx'
     $$LOAD   category,inputsGDX=inputs, io, prods, ioCategories, unit
   $$GDXIN


   parameter revenues_directCosts(crops,sys,impl,io,ioCategories,category,unit);

execute_load "ktbl/revenues_directCosts.gdx" revenues_directCosts=p_revenues_directCosts;

   parameter p_revenues_directCosts(crops,sys,impl,io,ioCategories,category,unit);
             p_revenues_directCosts(crops,sys,impl,io,ioCategories,category,unit)
                 $sum(till, (c_s_i_t(crops,Sys,impl,till)))
                 = revenues_directCosts(crops,sys,impl,io,ioCategories,category,unit);

   set revenues_Costs(crops,sys,impl,io,ioCategories,category,unit);
       revenues_Costs(crops,sys,impl,io,ioCategories,category,unit)$ p_revenues_directCosts(crops,sys,impl,io,ioCategories,category,unit)=YES;

*
* --- only inputs and outputs required for selected crops
*

   curinputsGDX(inputsGDX) $sum((revenues_Costs(crops,sys,impl,io,ioCategories,category,unit)) $ sameas(io,InputsGDX),1) = YES;
   curIo(io) $sum(revenues_Costs(crops,sys,impl,io,ioCategories,category,unit),1) = YES;

*
* --- output prices and yields
*

   Parameter
   p_cropPrice(*,*)
   p_cropYield(*,*)
   ;

* ---  Prices are with only a few exceptions independent from till & impl
*      set price level to "till"

    p_cropPrice(crops,sys)
        = sum((io,unit,impl) , p_revenues_directCosts(crops,sys,impl,io,"revenues","price",unit)$ c_s_i_t(crops,sys,impl,"till"));

    p_cropPrice(crops,'Change,conv % p.a.') $ (p_cropPrice(crops,"conv") $ sum(c_s_i_t(crops,Sys,impl,till),1)) = eps;
    p_cropPrice(crops,'Change,org % p.a.')  $ (p_cropPrice(crops,"org") $ sum(c_s_i_t(crops,Sys,impl,till),1)) = eps;

    p_cropYield(crops,sys)
       = sum((io,unit,impl) , p_revenues_directCosts(crops,sys,impl,io,"revenues","amount",unit)$ c_s_i_t(crops,sys,impl,"till"));

    p_cropYield(crops,'Change,conv % p.a.') $ sum(c_s_i_t(crops,Sys,impl,till),1) = eps;
    p_cropYield(crops,'Change,org % p.a.') $ sum(c_s_i_t(crops,Sys,impl,till),1) = eps;

*
* --- inputs, input quantities and input prices
*

$onmulti
    set intens      / normal   "Full N fertilization" /;
$offmulti


*
* --- physical quantities of inputs for crop production (seeds, ..),, for PSM only costs/ha are available
*

   parameter p_inputQuant(crops,till,intens,io,unit);

*seeds and lime
   p_inputQuant(crops,till,"normal",io,unit) $((not sameas(till,"org")) $
                           sum((impl,ioCategories), p_revenues_directCosts(crops,"conv",impl,io,ioCategories,"amount",unit)
                            $ (c_s_i_t(crops,"conv",impl,till) and not sameas(ioCategories,"others") and not sameas(ioCategories,"revenues") and not sameas(ioCategories,"fertilizer"))))
                         = sum((impl,ioCategories), p_revenues_directCosts(crops,"conv",impl,io,ioCategories,"amount",unit) $ c_s_i_t(crops,"conv",impl,till));

   p_inputQuant(crops,"org","normal",io,unit) $ sum((impl,ioCategories), p_revenues_directCosts(crops,"org",impl,io,ioCategories,"amount",unit)
                            $ (c_s_i_t(crops,"org",impl,"till") and not sameas(ioCategories,"others") and not sameas(ioCategories,"revenues") and not sameas(ioCategories,"fertilizer")))
                           = sum((impl,ioCategories), p_revenues_directCosts(crops,"org",impl,io,ioCategories,"amount",unit) $ c_s_i_t(crops,"org",impl,"till"));

*pesticides

   p_inputQuant(crops,till,"normal",io,unit) $((not sameas(till,"org")) $ sum((impl,ioCategories), p_revenues_directCosts(crops,"conv",impl,io,ioCategories,"total",unit)
                            $ (c_s_i_t(crops,"conv",impl,till) and sameas(ioCategories,"Herb") or sameas(ioCategories,"Fung") or sameas(ioCategories,"Insect") or sameas(ioCategories,"growthContr"))))
                           = sum((impl,ioCategories), p_revenues_directCosts(crops,"conv",impl,io,ioCategories,"total",unit)$ c_s_i_t(crops,"conv",impl,till));

   p_inputQuant(crops,"org","normal",io,unit) $ sum((impl,ioCategories), p_revenues_directCosts(crops,"org",impl,io,ioCategories,"total",unit)
                           $ (c_s_i_t(crops,"org",impl,"till") and sameas(ioCategories,"Herb") or sameas(ioCategories,"Fung") or sameas(ioCategories,"Insect") or sameas(ioCategories,"growthContr")))
                           = sum((impl,ioCategories), p_revenues_directCosts(crops,"org",impl,io,ioCategories,"total",unit) $ c_s_i_t(crops,"org",impl,"till"));

*water and other materials

    p_inputQuant(crops,till,"normal",io,unit) $((not sameas(till,"org")) $
                            sum(impl, p_revenues_directCosts(crops,"conv",impl,io,"Others","amount",unit)
                            $ (c_s_i_t(crops,"conv",impl,till) and not sameas(io,"Zinskosten (3 Monate)") and not sameas(io,"Hagelversicherung"))))
                            = sum(impl, p_revenues_directCosts(crops,"conv",impl,io,"Others","amount",unit) $ c_s_i_t(crops,"conv",impl,till));

    p_inputQuant(crops,"org","normal",io,unit) $ sum((impl), p_revenues_directCosts(crops,"org",impl,io,"Others","amount",unit)
                            $ (c_s_i_t(crops,"org",impl,"till") and not (sameas(io,"Zinskosten (3 Monate)") or sameas(io,"Hagelversicherung"))))
                            = sum(impl, p_revenues_directCosts(crops,"org",impl,io,"Others","amount",unit) $ c_s_i_t(crops,"org",impl,"till"));

    p_inputQuant(crops,till,"normal",io,"t/ha") $p_inputQuant(crops,till,"normal",io,"kg/ha") = p_inputQuant(crops,till,"normal",io,"kg/ha") / 1000;
    p_inputQuant(crops,till,"normal",io,"kg/ha")=0;
*
* --- map "till" to "plough"
*
   p_inputQuant(crops,"plough","normal",io,unit)   $ p_inputQuant(crops,"till","normal",io,unit)      = p_inputQuant(crops,"till","normal",io,unit);
   p_inputQuant(crops,"till","normal",io,unit)     = 0;


*
* --- direct costs related to crop production (seeds, PSM, insurance, interest...)
*
   parameter p_costQuant(crops,till,intens,*);

* --- Costs [EUR/ha] of seeds, lime, fertilizer, Herbicides, Insecticides, Fungicides and growth regulator
      p_costQuant(crops,till,"normal",ioCategories) $(not sameas(till,"org"))
                                                = sum((impl,io), p_revenues_directCosts(crops,"conv",impl,io,ioCategories,"total","EUR/ha")
                                                            $ (c_s_i_t(crops,"conv",impl,till) and not sameas(ioCategories,"others") and not sameas(ioCategories,"revenues")));
      p_costQuant(crops,"org","normal",ioCategories)
                                                = sum((impl,io), p_revenues_directCosts(crops,"org",impl,io,ioCategories,"total","EUR/ha")
                                                 $ (c_s_i_t(crops,"org",impl,"till") and not sameas(ioCategories,"others") and not sameas(ioCategories,"revenues")));

* --- HailInsurance (cost) [EUR/ha]
      p_costQuant(crops,till,"normal","hailIns")  $(not sameas(till,"org"))
                                                  = sum((impl), p_revenues_directCosts(crops,"conv",impl,"Hagelversicherung","Others","total","EUR/ha") $ (c_s_i_t(crops,"conv",impl,till)));
      p_costQuant(crops,"org","normal","hailIns") = sum((impl), p_revenues_directCosts(crops,"org",impl,"Hagelversicherung","Others","total","EUR/ha") $ (c_s_i_t(crops,"org",impl,"till")));

* --- water quantity [m3/ha]
      p_costQuant(crops,till,"normal","water")  $(not sameas(till,"org"))
                                                = sum((impl,io), p_revenues_directCosts(crops,"conv",impl,io,"Others","amount","m3/ha") $ (c_s_i_t(crops,"conv",impl,till)));
      p_costQuant(crops,"org","normal","water") = sum((impl,io), p_revenues_directCosts(crops,"org",impl,io,"Others","amount","m3/ha")  $ (c_s_i_t(crops,"org",impl,"till")));

* --- Interest cost [EUR/ha]
      p_costQuant(crops,till,"normal","interest") $(not sameas(till,"org"))
                                                    = sum((impl), p_revenues_directCosts(crops,"conv",impl,"Zinskosten (3 Monate)","Others","total","EUR/ha") $ (c_s_i_t(crops,"conv",impl,till)));
      p_costQuant(crops,"org","normal","interest")  = sum((impl), p_revenues_directCosts(crops,"org",impl,"Zinskosten (3 Monate)","Others","total","EUR/ha") $ (c_s_i_t(crops,"org",impl,"till")));

* --- tools / additional material such as foil, pipes, fleece, costs [EUR/ha]
      p_costQuant(crops,till,"normal","material")  $(not sameas(till,"org"))
                                                   = sum((impl,io), p_revenues_directCosts(crops,"conv",impl,io,"Others","total","EUR/ha")
                                                      $ (c_s_i_t(crops,"conv",impl,till) and not sameas(io,"Vermarktungsgebuehr") and not sameas(io,"Zinskosten (3 Monate)")
                                                      and not sameas(io,"Hagelversicherung") and not sameas(io,"Wasser") and not sameas(io,"Beregnungswasser")));

      p_costQuant(crops,"org","normal","material")  = sum((impl,io), p_revenues_directCosts(crops,"org",impl,io,"Others","total","EUR/ha")
                                                       $ (c_s_i_t(crops,"org",impl,"till") and not sameas(io,"Vermarktungsgebuehr") and not sameas(io,"Zinskosten (3 Monate)")
                                                        and not sameas(io,"Hagelversicherung") and not sameas(io,"Wasser") and not sameas(io,"Beregnungswasser")));

* --- sales commission (dt. Vermarktungsgebühr) [EUR/ha]
      p_costQuant(crops,till,"normal","sales commission")  $(not sameas(till,"org"))
                                                         = sum((impl,io), p_revenues_directCosts(crops,"conv",impl,io,"Others","total","EUR/ha")
                                                          $ (c_s_i_t(crops,"conv",impl,till) and sameas(io,"Vermarktungsgebuehr")));
    p_costQuant(crops,"org","normal","sales commission")  = sum((impl,io), p_revenues_directCosts(crops,"org",impl,io,"Others","total","EUR/ha")
                                                           $ (c_s_i_t(crops,"org",impl,"till") and sameas(io,"Vermarktungsgebuehr")));

*
*   --- mineral fertilizers costs are endogenous - delete costs of fertilizers
*

     p_costQuant(crops,till,intens,ioCategories) $(not sameas(till,"org") and sameas(ioCategories,"fertilizer")) = 0;
     p_costQuant(crops,"org",intens,ioCategories) $ sameas(ioCategories,"fertilizer") = 0;
*
* --- map "till" to "plough"
*
    p_costQuant(crops,"plough","normal",ioCategories)         $ p_costQuant(crops,"till","normal",ioCategories)       = p_costQuant(crops,"till","normal",ioCategories);
    p_costQuant(crops,"plough","normal","hailIns")            $ p_costQuant(crops,"till","normal","hailIns")          = p_costQuant(crops,"till","normal","hailIns");
    p_costQuant(crops,"plough","normal","water")              $ p_costQuant(crops,"till","normal","water")            = p_costQuant(crops,"till","normal","water");
    p_costQuant(crops,"plough","normal","interest")           $ p_costQuant(crops,"till","normal","interest")         = p_costQuant(crops,"till","normal","interest") ;
    p_costQuant(crops,"plough","normal","material")           $ p_costQuant(crops,"till","normal","material")         = p_costQuant(crops,"till","normal","material");
    p_costQuant(crops,"plough","normal","sales commission")   $ p_costQuant(crops,"till","normal","sales commission") = p_costQuant(crops,"till","normal","sales commission");

    p_costQuant(crops,"till","normal",ioCategories)           = 0;
    p_costQuant(crops,"till","normal","hailIns")              = 0;
    p_costQuant(crops,"till","normal","water")                = 0;
    p_costQuant(crops,"till","normal","interest")             = 0;
    p_costQuant(crops,"till","normal","material")             = 0;
    p_costQuant(crops,"till","normal","sales commission")     = 0;

*
* --- prices of required inputs
*

   parameter p_InputPrices(*,*);

* the total expenditure / ha is states in p_costQuant, therefore p_inputprice for all KTBL inputs in table = 1 (except: WATER, quantity in p_costQuant, price in p_inputPrice)
*Prices of PSM are not defined, only total expenditure. Add a placeholder
*Prices of hailinsurance and seeds depend not only on system but also on crops. In order to decrease table size in GUI, here: price = 1
*total costs included in p_costQuant table

    set inputcategories /"herb","insect","fung","growthContr","seed","hailIns","interest","material","sales comission"/;
    p_InputPrices("Herb",sys)           $sum((crops,impl,io,unit),               revenues_directCosts(crops,sys,impl,io,"Herb","total",unit))                        = 1;
    p_InputPrices("Insect",sys)         $sum((crops,impl,io,unit),               revenues_directCosts(crops,sys,impl,io,"Insect","total",unit))                      = 1;
    p_InputPrices("Fung",sys)           $sum((crops,impl,io,unit),               revenues_directCosts(crops,sys,impl,io,"Fung","total",unit))                        = 1;
    p_InputPrices("growthContr",sys)    $sum((crops,impl,io,unit),               revenues_directCosts(crops,sys,impl,io,"growthContr","total",unit))                 = 1;
    p_InputPrices("seed",sys)           $sum((crops,impl,io,unit),               revenues_directCosts(crops,sys,impl,io,"seed","total",unit))                        = 1;
    p_InputPrices("hailIns",sys)        $sum((crops,impl,unit),                  revenues_directCosts(crops,sys,impl,"Hagelversicherung","Others","total",unit))     = 1;
    p_InputPrices("interest",sys)       $sum((crops,impl,unit),                  revenues_directCosts(crops,sys,impl,"Zinskosten (3 Monate)","Others","total",unit)) = 1;
    p_InputPrices("lime",sys)           $sum((crops,impl,io,unit),               revenues_directCosts(crops,sys,impl,io,"lime","total",unit))                        = 1;
    p_InputPrices(io,sys)               $sum((crops,impl,unit),                  revenues_directCosts(crops,sys,impl,io,"fertilizer","total",unit))                  = 0;
    p_InputPrices("material",sys)       $sum((crops,impl,io,unit,ioCategories),  revenues_directCosts(crops,sys,impl,io,ioCategories,"total",unit)
                                              $((sameas(ioCategories,"others") and not sameas(io,"Vermarktungsgebuehr") and not sameas(io,"Zinskosten (3 Monate)")
                                              and not sameas(io,"Hagelversicherung") and not sameas(io,"Wasser") and not sameas(io,"Beregnungswasser"))))            = 1;
    p_InputPrices(io,sys)               $sum((crops,impl,unit,ioCategories),  revenues_directCosts(crops,sys,impl,io,ioCategories,"total",unit)
                                              $((sameas(ioCategories,"others") and not sameas(io,"Wasser") and not sameas(io,"Beregnungswasser"))))                  = 0;

    p_InputPrices("sales commission",sys)     $sum((crops,impl,unit),  revenues_directCosts(crops,sys,impl,"Vermarktungsgebuehr","Others","total",unit))             = 1;


    set inputs_category(io,ioCategories) "list of all inputs and the respective category";
    inputs_category(io,ioCategories) $ sum((crops,sys,impl,category,unit), revenues_directCosts(crops,sys,impl,io,ioCategories,category,unit)) = YES;


************************************************************************
*                                                                       *
* ---- load data for selected KTBL crops                                *
*                                                                       *
*************************************************************************

set
   cashcrops(crops)
   no_cashcrops(crops)
   arablecrops(crops)
   SummerHarvest(crops)
   ccCrops(crops)
   cere(crops)
   rootCrops(crops)
   leg(crops)
   maize(crops)
   Kreuzbluetler(crops)
   grass(crops)
   summercere(crops)
   wintercere(crops)
   wintercrops(crops)
   potatoes(crops)
   sugarbeet(crops)
   rapeseed(crops)
   other(crops)
   vegetables(crops)
   maizCCM(crops)
   grain_maize(crops)
   grain_Barley(crops)
   grain_Wheat(crops)
   grain_rye(crops)
   grain_oat(crops)
   OtherGrains(crops)
   biogas_feed(crops)  "crops that can be used as fermentation substrat"
   feed(crops)         "feed without roughages and catchcrops"
   feed_ccCrops(crops) "catchcrops harvested as feed"
   roughages(crops)    "roughages for feed use"
   feeds(crops)            "all crops with feed use (feed, cc_crops, roughages)"
   feedsPig(crops)     "crops used as pig feed"
   feedAttr            "Attributes of feeds"
   grassSilage(crops)
   maizSilage(crops)
   GPS(crops)
   hay(crops)
   grainleg(leg)      "Grain legumes"
   crops_as_input      "crops which can also be purchased as input"
   m                   "month"
   value
   resiEle
   monthGrowthCrops(Crops,sys,m)             "months of crop growth"
   monthHarvestCrops(crops,sys,m)            "months of crop harvest"
   monthHarvestBlock(crops,m)                "months between harvest and November where fertilizer application is possible"
   cropsResidueRemo(crops)                   "Crops which generally allow the removal of residues"
   cropsResidues_prods                       "Residues produced by crops which can be sold"
   crop_residues(cropsResidues_prods,crops)  "crossset linking residues to crop"
   cropGroups
   cropGroupsExceptionGAEC7
;

parameter
   p_storageLoss(crops)
   p_nutCont(crops_as_input,*)
   p_nutContent(crops,*,sys,*)
   p_maxRotShare(crops,sys,soil)
   p_NfromLegumes(crops,sys)
   p_NfromVegetables(crops)
   p_NNeed(crops)
   p_Yieldlevel(crops)
   p_addN(crops)
   p_redN(crops)
   p_NrespFunct(crops,value)
   p_Nmin(crops)
   p_residue_ratio(cropsResidues_prods)
   p_cropResi(crops,resiEle)
   p_efa(crops)   "Factors for Ecological focus area"
   p_cropGroups_to_crops(cropGroups,crops)

   p_EfLeachFert(crops,m)
   p_MonthAfterLeg(crops,m)
   p_humCrop(crops)
   p_resiInc(crops)
   p_cerealUnit(*)
   p_feedContDMgAll(*,feedAttr) "feed attributes of all crops"
   p_feedAttrPigAll(*,feedAttr) "feed attributes of all crops"
   p_feedContDMg(*,feedAttr)    "feed attributes of crops either selected in GUI or available as inputs"
   p_feedAttrPig(*,feedAttr)    "feed attributes of crops either selected in GUI or available as inputs"

   p_crop(biogas_feed) "Metahne yield for crops in m3 per ton"
   p_dryMatterCrop(biogas_feed)
   p_orgDryMatterCrop(biogas_feed)
   p_fugCrop(biogas_feed)
   p_totNCrop(biogas_feed)
   p_shareNTAN(biogas_feed)


* data related to new fertilization method
   p_NcontShoot(crops,sys)   "N content of main and by-product (without crop residues and roots)"
   p_NcontPlant(crops,sys) "N content of main, by-product, crop residues and roots)"
   p_NUpCoeffRes(crops,soil)     "Uptake coefficient of N from crop residues, subject to C/N in crop residues and length of vegetation period"
   p_nutSeeds(crops)             "Nitrogen content of seeds"
   p_NSoilDelivery(crops)        "Nitrogen delivery from N during vegetation period"
   p_legshare(leg) "legume share of legume crops"
   p_Ndfa(leg)     "share of nitrogen derived from atmosphere"

;

*
* --- include a scalar in crops_de. This enables to test in Farmdyn whether the crops_de was build from KTBL or user data.
*
Scalar KTBL_Data /1/;

   $$GDXIN 'ktbl/ktbl.gdx'
      $$LOAD cashcrops no_cashcrops arableCrops SummerHarvest ccCrops cere rootcrops leg
      $$LOAD maize Kreuzbluetler grass=grassCrops summercere wintercere potatoes wintercrops
      $$LOAD sugarbeet  rapeseed  other vegetables
      $$Load grainleg
      $$LOAD grain_maize maizCCM grain_Barley grain_Wheat grain_rye grain_oat OtherGrains
      $$LOAD feed feed_ccCrops roughages feeds feedsPig feedAttr grassSilage maizSilage GPS hay biogas_feed crops_as_input
      $$LOAD m value resiEle monthGrowthCrops monthHarvestCrops monthHarvestBlock cropsResidueRemo=cropResidueRemo cropsResidues_prods crop_residues  cropGroups cropGroupsExceptionGAEC7
      $$LOAD p_storageLoss p_nutCont p_nutContent p_NcontShoot p_NcontPlant  p_NUpCoeffRes
      $$LOAD p_legshare p_Ndfa
      $$LOAD p_maxRotShare p_NfromLegumes p_NfromVegetables
      $$LOAD p_NNeed p_Yieldlevel p_addN p_redN p_NrespFunct p_Nmin p_residue_ratio
      $$LOAD p_cropResi p_efa p_cropGroups_to_crops p_EfLeachFert p_MonthAfterLeg p_humCrop p_resiInc p_cerealUnit p_feedContDMgAll=p_feedContDMg p_feedAttrPigAll=p_feedAttrPig
      $$LOAD p_crop, p_dryMatterCrop,p_orgDryMatterCrop, p_fugCrop, p_totNCrop p_shareNTAN
      $$load p_nutSeeds, p_NSoilDelivery
   $$GDXIN

   set cropsResidues_prods2(cropsResidues_prods);
       cropsResidues_prods2(cropsResidues_prods) = sum(crops, crop_residues(cropsResidues_prods,crops)) ;


************************************************************************************
*                                                                                  *
* ---- build input data for selected KTBL crops  (replace GENERATE_SETS_GDX.gms)   *
*                                                                                  *
************************************************************************************
* --- load inputs and input prices not related to crops
$onMulti
$batinclude "%datdir%/ktbl/inputs_KTBL.gms"

* --- create list of all feeds

    set allFeeds /set.feeds/;
    set allFeeds /set.feedspig/;
*        allFeeds $ sum(sameas(allfeeds,crops_as_input),1) = NO;
    set allFeeds / set.crops_as_input /;

*
* --- only use feeding attributed of crops that are either selected in GUI or that can be bought as inputs
*

   p_feedContDMg(allFeeds,feedAttr) = p_feedContDMgAll(allFeeds,feedAttr);
   p_feedAttrPig(allFeeds,feedAttr) = p_feedAttrPigAll(allFeeds,feedAttr);

* --- combine all inputs to one input set
   set allinputs(*);
       allinputs(inputs)         = YES;
       allinputs(crops_as_input) = Yes;
       allinputs(curInputsGDX)   = Yes;

$offmulti
* --- if inputprice does not exists: use outputprice + 10%

   p_inputPrices(allinputs,sys) $ (not p_inputPrices(allinputs,sys)) = p_cropPrice(allinputs,sys) * 1.1;

* --- if organic inputprice does not exist (e.g. ConCattle), use conventional outputprice + 20%
*      do not use price markup for inputcategories (e.g. herbs, insects) as they only have a placeholder of 1
   p_inputprices(allinputs,"org")  $ ((not p_inputPrices(allinputs,"org")) $ (not sum(sameas(inputcategories,allinputs),1))) =  p_inputprices(allinputs,"conv") * 1.2 ;


*
* --- define growth rate
*
   p_InputPrices(allinputs,'Change,conv % p.a.')  $ p_InputPrices(allinputs,"conv")   =     eps;
   p_InputPrices(allinputs,'Change,org % p.a.')   $ p_InputPrices(allinputs,"org")    =     eps;

*
* --- build one large data file with all crop related & input data
*
execute_unload "../dat/crops_KTBL.gdx"


*
* --- load crop related data
*


                                 KTBL_Data, crops, p_cropYield, p_cropPrice, p_costQuant, p_inputQuant, unit
                                 cashcrops, no_cashcrops, arableCrops, SummerHarvest, ccCrops, rootcrops, cere,  leg,
                                 Kreuzbluetler, maize,  summercere, wintercere, winterCrops
                                 potatoes, sugarbeet, rapeseed, other, vegetables
                                 maizSilage, GPS, hay
                                 grain_maize, maizCCm, grain_Barley, grain_Wheat, grain_rye, grain_oat, OtherGrains
                                 grainleg
                                 feed feed_ccCrops roughages feeds FeedsPig=CereFeedsPigGDX crops_as_input feedAttr grassSilage maizSilage GPS hay biogas_feed
                                 m, value, resiEle, monthGrowthCrops, monthHarvestCrops monthHarvestBlock
                                 cropsResidueRemo, cropsResidues_prods2=cropsResidues_prods , crop_residues, cropGroups, cropGroupsExceptionGAEC7
                                 p_storageLoss, p_nutContent, p_nutCont, p_NcontShoot,  p_NcontPlant p_NUpCoeffRes
                                 p_legshare p_Ndfa
                                 p_maxRotShare, p_NfromLegumes, p_NfromVegetables,
                                 p_NNeed ,p_Yieldlevel, p_addN, p_redN, p_NrespFunct, p_Nmin
                                 p_residue_ratio, p_cropResi, p_efa, p_cropGroups_to_crops
                                 p_EfLeachFert,  p_MonthAfterLeg, p_humCrop, p_resiInc, p_cerealUnit
                                 p_feedContDMg p_feedAttrPig
                                 p_crop, p_dryMatterCrop,p_orgDryMatterCrop, p_fugCrop, p_totNCrop p_shareNTAN
                                 p_nutSeeds, p_NSoilDelivery

*
* --- load input  data
*


                                 allinputs=inputs, p_inputPrices, curInputsGDX=inputsGDX,  ioCategories, inputs_category;
;
