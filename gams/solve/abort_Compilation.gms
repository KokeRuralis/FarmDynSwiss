********************************************************************************
$ontext

   FarmDyn project

   GAMS file : abort_Compilation.gms

   @purpose  : Check not working GUI settings after compilation
               and throw an abort statement in case of errors
   @author   : Kokemohr
   @date     : 03.12.18
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter.gms

$offtext
********************************************************************************

*
* --- Aborts for price settings that lead to arbitrage (buying inputs cheaper than selling as outputs=

*   --- Heifs, cross-bred heifers and sloughtered old cows prices have to be lower than bought heifers

$$iftheni.cowHerd "%cowherd%"=="true"

   $$iftheni.buyH %buyheifs% == true
      $$iftheni.sellH %sellheifs% == true

         if[sum((heifs,heifBeef_HF_outputs)  $(  (heifBeef_HF_outputs.pos eq heifs.pos )
                                         $ sum(sys, (p_inputPrices("youngCow",sys)< p_outputPrices(heifBeef_HF_outputs,sys)
                                          * p_fParam(heifs,"%BasBreed%","finalWgt") * p_fParam(heifs,"%BasBreed%","dressPerc")/100))
                                       ),1 ), abort "Bought heifs cheaper than sold heifs"];

         $$iftheni.MC     "%farmBranchMotherCows%"=="on"

              if[sum((heifs,heifBeef_MC_outputs)  $(  (heifBeef_MC_outputs.pos eq heifs.pos )
                                           $sum(sys, (p_inputPrices("youngCow",sys)< p_outputPrices(heifBeef_MC_outputs,sys)
                                            * p_fParam(heifs,"%motherCowBreed%","finalWgt") * p_fParam(heifs,"%motherCowBreed%","dressPerc")/100))
                                         ),1 ), abort "Bought heifs cheaper than sold heifs"];
         $$endif.MC

         $$iftheni.crossH %crossBreeding% == true

               if[sum((heifs,heifBeef_SI_outputs)  $(  (heifBeef_SI_outputs.pos eq heifs.pos )
                                            $sum(sys,(p_inputPrices("youngCow",sys)< p_outputPrices(heifBeef_SI_outputs,sys)
                                             * p_fParam(heifs,"%CrossBreed%","finalWgt") * p_fParam(heifs,"%CrossBreed%","dressPerc")/100))
                                          ),1 ), abort "Bought cross-bred heifs cheaper than sold heifs"];

         $$endif.crossH

      $$endif.sellH

      $$iftheni.slgtC %allowSlgtCow% == true

         if[sum((sys,t)    $(p_price("youngcow",sys,t)< p_price("oldCow",sys,t) * (p_cowAttr("%cowType%","dressPerc")/100)
                                                                                * p_cowAttr("%cowType%","avgCowWeigth")
                                           ),1 ), abort "Bought heifs cheaper than sloughtered old cows"];
      $$endif.slgtC
   $$endif.buyH



   $$iftheni.heifsAttr defined p_heifsAttr
*
*   --- not matching process weights between calves and heifers in GUI lead to abort
*
       if( not sum((heifs,curBreeds) $ (p_heifsAttr(heifs,"StartWgt") eq p_calvsParam("fCalvsRais",curBreeds,"finalWgt")),1),
          abort "At least one Heifers process must start at the final weight of the calves process, in %system.incName%, line %system.incLine%");

      if(sum(heifs $ ( ((p_heifsAttr(heifs,"finalWgt")-p_heifsAttr(heifs,"startWgt"))/p_heifsAttr(heifs,"days")>1.7 )
                              $ p_heifsAttr(heifs,"days")),1),
        abort "Heifs processes with daily weight gain > 1.7 kg not allowed, in %system.incName%, line %system.incLine%");
   $$endif.heifsAttr
$$endif.cowHerd
*
*  --- Abort if no landendowment is specified
*
if[not sum(landType $ (sum((soil),p_iniLand(landType,soil))>0),1), abort "No landendowment specified"];
