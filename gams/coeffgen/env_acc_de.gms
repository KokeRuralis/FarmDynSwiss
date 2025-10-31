********************************************************************************
$ontext

   FARMDYN project

   GAMS file : ENV_ACC.GMS

   @purpose  : Define parameter to quantify environmental impact
   @author   : T.Kuhn, W.Britz; Revised L.K 28.11.2019
   @date     : 12.06.15
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************

*
* --- Calculation of manure content (kg nutrient/qm) after storage related to minimal and maximal losses, differnt for digestates and animal manure
*

* --- HIGH manure content means MINIMAL losses

* Data needed for calculation of crop residues for N losses from crop residues


$iftheni.grasAttr defined p_grasAttr

  p_cropResi(grassCrops,"freqHarv") $(sum(m $ sum(grasOutputs, p_grasAttr(grassCrops,grasOutputs,m)),1) ge 1)
             = 1 / sum(m $ sum(grasOutputs, p_grasAttr(grassCrops,grasOutputs,m)),1);

$endif.grasAttr

* --- Month and crops with intense cultivation (1 is intense cultivation); heavy cultivation is determined via Richner 2014 p. 13
*      Needed for calculation of N leaching

  set intensOperation(operation) /plow,circHarrowSow,rotaryHarrow,potatoHarvest,uprootBeets/;
  Parameter p_CfIntensTill(m,crops);
* --- load intensoperation of KTBL database
$iftheni.data "%database%"=="KTBL_database"
   $$gdxin '%datDir%/cropop_ktbl.gdx'
     $$onmulti
     $$load intensOperation
     $$offmulti
   $$gdxin
$endif.data

  Parameter p_CfIntensTill(m,crops);
  p_CfIntensTill(m,crops) = sum((labPeriod_to_month(labPeriod,m),intensOperation(operation),till,intens),
                                            p_crop_op_per_till(crops,intensOperation,labPeriod,till,intens)$ p_crop_op_per_till(crops,intensOperation,labPeriod,till,intens))
                        $$iftheni.data "%database%" == "KTBL_database"
                        + sum((labPeriod_to_month(labPeriod,m),intensOperation(operation),till,intens,amount),
                                          + p_crop_op_per_tillKTBL(crops,intensOperation,labPeriod,till,amount,intens) $p_crop_op_per_tillKTBL(crops,intensOperation,labPeriod,till,amount,intens))
                        $$endif.data
                        ;
*
* --- The SALCA method does not explicitly consider the case of two intensive operations in a month,
*     upper limit of one
*

p_CfIntensTill(m,crops) = Min(1,p_CfIntensTill(m,crops))$p_CfIntensTill(m,crops);
;



* --- Amount of crop residues per crop, derived based on IPCC(2006)-11.11 ff and Haenel et al. 2018 p.367
*     multiplied by 10 to gain dt/ha; needed for humus balance


p_resiCrop(crops,soil,till,intens,t)=
      [   sum( Prods, p_OCoeffC(crops,soil,till,intens,Prods,t))
                  * p_cropResi(crops,"duration") * p_cropResi(crops,"freqHarv") *  p_cropResi(crops,"aboveRat")

        + sum( Prods, p_OCoeffC(crops,soil,till,intens,Prods,t))
                  * p_cropResi(crops,"duration") * p_cropResi(crops,"freqHarv") * p_cropResi(crops,"belowRat")
                  * ( p_cropResi(crops,"DMyield")$(not sameas(crops,"potatoes") and not sameas(crops,"sugarBeet"))
                      + p_cropResi(crops,"aboveRat") * p_cropResi(crops,"DMresi"))
      ] * 10 ;


* remapping of EF for particulate matter formation from herds to sumherds
   $$iftheni.dh %cattle% == true

     p_EFpmfHerds(cows,"noGraz",manChain,emissions)     =  p_EFpmfHerds("cows","noGraz",manChain,emissions) ;
     $$ifi defined heifs p_EFpmfHerds(heifs,"noGraz",manChain,emissions)    =  p_EFpmfHerds("heifs","noGraz",manChain,emissions) ;
     $$ifi defined bulls p_EFpmfHerds(bulls,"noGraz",manChain,emissions)    =  p_EFpmfHerds("bulls","noGraz",manChain,emissions) ;

     p_EFpmfHerds(cattle(herds),"partGraz",manChain,emissions) =  p_EFpmfHerds(herds,"noGraz",manChain,emissions) * 0.5;
     p_EFpmfHerds(cattle(herds),"fullGraz",manChain,emissions) =  0;

   $$endif.dh
*
* --- processing of ecoinvent raw data
*
$$iftheni.eco "%upstreamEF%" == "true"
$$iftheni.ecoInvent defined inputsEmissions

   option kill=p_EFInput,kill=p_EFBuild,kill=p_EFSilo,kill=p_EFStable;

* ---- for fertilizers EF have to be converted from kg N and kg P2O5 to kg fertilizer
   p_EFInput(syntFertilizer,emissions) $(not sum(nut,p_nutInSynt(syntFertilizer,nut))) = inputsEmissions(emissions,syntFertilizer) * 0.3 ;
   p_EFInput(syntFertilizer,emissions) $p_nutInSynt(syntFertilizer,"N") = inputsEmissions(emissions,syntFertilizer) * p_nutInSynt(syntFertilizer,"N") ;
   p_EFInput(syntFertilizer,emissions) $p_nutInSynt(syntFertilizer,"P") = inputsEmissions(emissions,syntFertilizer) * p_nutInSynt(syntFertilizer,"P");

* --- straw has to be scaled up to tons
   p_EFInput("straw",emissions) = inputsEmissions(emissions,"straw") * 1000;

* --- feeds have to be scaled up to tons
   p_EFInput(inputs,emissions)$sum(feeds$sameas(feeds,inputs),1) = feedsEmissions(emissions,inputs) * 1000;

*  --- Milkreplacer is estimated on market composition of protein and energy feed, error through aggregation because market mix is mostly plant based and milk replacer animal based
   p_EFInput("milkPowder",emissions) =   feedsEmissions(emissions,"ProteinFeed") * p_feedContFMton("milkPowder","XP")
                                       + feedsEmissions(emissions,"EnergyFeed") * p_feedContFMton("milkPowder","GE");

* --- Sugarbeetpulp calculation as intermediate step for cattle concentrates, 75.198 kg xP per ton FM and 20038.138 MJ GE per ton
   feedsEmissions(emissions,"dryBeetPulp") = feedsEmissions(emissions,"beetPulpProt") * 75.198
                                           + feedsEmissions(emissions,"beetPulpEner") * 20038.138;

* ---For concentrates assumptions are made
*           concentrate1: 0.36% straw, 65.55% barley, 2.23%beetpulp dry,  7.09% rapeSeedMeal, 1.88% soyoil, 22.85% maizegrain
*           concentrate2: 0.82% straw, 8% wheat, 50.85% barley, 0.5%beetpulp, 0.2893% rapeSeedMeal, 0.8%soybeanOil, 10.07%maizegrain
*           concentrate3: 0.05% straw, 42.98% soyBeanMeal, 56.98% rapeseedmeal
   p_EFInput("ConcCattle1",emissions) =  0.0036 * p_EFInput("straw",emissions) + 0.0223 * feedsEmissions(emissions,"dryBeetPulp")
                                       + (0.6555 * feedsEmissions(emissions,"winterBarley") + 0.0709 * feedsEmissions(emissions,"rapeSeedMeal")
                                        + 0.0188 * feedsEmissions(emissions,"soybeanOil") + 0.2285 * feedsEmissions(emissions,"maizegrain") ) * 1000;

   p_EFInput("ConcCattle2",emissions) = 0.0082 * p_EFInput("straw",emissions) + 0.0053 * feedsEmissions(emissions,"drybeetpulp")
                                       + (0.08 * feedsEmissions(emissions,"winterWheat") + 0.5085 * feedsEmissions(emissions,"winterBarley")
                                        + 0.2893 * feedsEmissions(emissions,"rapeSeedMeal") + 0.0080 * feedsEmissions(emissions,"soybeanOil")
                                        + 0.1007 * feedsEmissions(emissions,"maizegrain") ) * 1000;

   p_EFInput("ConcCattle3",emissions) =  0.0005 * p_EFInput("straw",emissions) + (0.4298 * feedsEmissions(emissions,"soyBeanMeal")
                                       + 0.5698 * feedsEmissions(emissions,"rapeseedmeal") )* 1000;




*  --- Crop specific inputs

*  --- lime and water
   p_EFInputCrops(crops,till,intens,"lime",emissions) $sum(plot$c_p_t_i(crops,plot,till,intens),p_costQuant(crops,till,intens,"lime"))
    = inputsEmissions(emissions,"lime") * 1000;
   p_EFInputCrops(crops,till,intens,"water",emissions)$sum(plot$c_p_t_i(crops,plot,till,intens),p_costQuant(crops,till,intens,"water"))
      = inputsEmissions(emissions,"water") * 1000;
*  --- seed
   p_EFInputCrops(crops,till,intens,"seed",emissions)
        = seedsemissions(emissions,crops) * seedsemissions("seeduse",crops);

   p_EFInputCrops(grassCrops,till,intens,"seed",emissions)
       = seedsemissions(emissions,"grass") * seedsemissions("seeduse","grass");

* --- Operations

    $$include "%datdir%/%cropOpFile%.gms"
    $$include "%datdir%/%cropOpKTBLFile%.gms"
*     --- if there is a comparable EF for operations available take the respective file
     p_EFoperations(c_p_t_i(crops,plot,till,intens),operation,emissions,t)
                       = operationsemissions(operation,emissions);

*    --- pesticde production is included in operations, a generalised factor for all pesticides and growthcontroll is used
*        assumption is 1kg per ha and application
     p_EFoperations(c_p_t_i(crops,plot,till,intens),"herb",emissions,t)
                    =  operationsemissions("herb",emissions) + inputsEmissions(emissions,"pesticides") ;

*    --- transport operations are based on yields because the unit of the EF is t*km, average field transport distance is assumed to be 2km
*        seed poatatotransport missing
     p_EFoperations(crops,plot,till,intens,operation,emissions,t)$sum(transport$sameas(transport,operation),1)
              =
               (sum( (plot_soil(plot,soil),prods)$sum(pastOutput$(not pastOutput(prods)),1),
                     p_OCoeffC(crops,soil,till,intens,prods,t) )  * operationsemissions(operation,emissions) *2

*            --- in case of bale transport the loading of the bales is included. Ef is per bale (0.7t)
              + ( sum( (plot_soil(plot,soil),prods)$sum(pastOutput$(not pastOutput(prods)),1),
                      p_OCoeffC(crops,soil,till,intens,prods,t) ) / 0.7   * operationsemissions("loadingbales",emissions)
                      )$(sameas(operation,"baletransportSil") or sameas(operation,"baleTransportHay")));

*     --- For bale pressing the EF has to be converted from 700 kg bale to per ha via the individual yield
      p_EFoperations(crops,plot,till,intens,operation,emissions,t)$(sameas(operation,"balePressWrap") or sameas(operation,"balePressHay"))
              =
               sum( (plot_soil(plot,soil),prods)$sum(pastOutput$(not pastOutput(prods)),1),
                    p_OCoeffC(crops,soil,till,intens,prods,t) ) / 0.7
                  * operationsemissions(operation,emissions);

*     --- storage and drying, assumption is that water content is decreased by two percent
       p_EFoperations(c_p_t_i(crops,plot,till,intens),operation,emissions,t) $ sum(drying$sameas(operation,drying),1)
              =
               sum( (plot_soil(plot,soil),prods)$sum(pastOutput$(not pastOutput(prods)),1),
                    p_OCoeffC(crops,soil,till,intens,prods,t) ) * 1000 * 0.02
                  * operationsemissions(operation,emissions);

* in case no responding operation in ecoinvent is present emissions are estimated based on diesel use for operation
* energy density of diesel is 9.79KWh/liter with 1kwh = 3.6MJ
p_EFoperations(crops,plot,till,intens,operation,emissions,t)$(p_EFoperations(crops,plot,till,intens,operation,emissions,t)=0)
    =   sum( (actMachVar,act_rounded_plotsize), op_attr(operation,actMachVar,act_rounded_plotsize,"diesel")) *  9.79 * 3.6 * operationsemissions("dieselBurned",emissions);

* kill unwanted combinations
p_EFoperations(crops,plot,till,intens,operation,emissions,t) =
p_EFoperations(crops,plot,till,intens,operation,emissions,t) $(c_p_t_i(crops,plot,till,intens)$sum(labPeriod,p_crop_op_per_till(crops,operation,labperiod,till,intens))$(not sameas ("manDist",operation)))
 + (operationsemissions("mandist",emissions) $(c_p_t_i(crops,plot,till,intens) $sameas(operation,"mandist")))
;

$$else.ecoInvent

     option kill=p_EFOperations;
     option kill=p_EFInputCrops;


$$endif.ecoInvent
*add manure disposal for all combinations at is not standard for most crops in p_crop_op_per_till

*+ operationsemissions("manDist",emissions);


* --- animals bought to the herd
*default is 0
p_EFInputAnimal(inputs,emissions,source) =0;

$$endif.eco
