********************************************************************************
$ontext

   FARMDYN project

   GAMS file : ENV_ACC.GMS

   @purpose  : Define parameter to quantify social impact
   @author   : L. Kokemohr
   @date     : 28.11.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************
*
*--- Calorie and protein content of products used for indicators
*
$$iftheni.ch %cattle% == true
* for feed stuff and crop outputs in kcal ->238 is conversion from MJ to kCal
$ifi %dairyherd%==true    p_foodCont(soci,"milk")   = p_shareFood("milk",soci) * 1000;
$ifi %cattle%==true       p_foodCont("calories",feeds(prodsall)) = p_feedContFMton(feeds,"GE") * p_shareFood(feeds,"calories") * 238.84589;
$ifi %cattle%==true       p_foodCont("protein",feeds(prodsall))   = p_feedContFMton(feeds,"XP") * p_shareFood(feeds,"protein");
* for bull meat types in kcal per kg carcass weight
$$iftheni.b "%farmBranchBeef%"=="on"
  p_foodCont(soci,beef_HF_outputs) =  sum(bullsBase $((beef_HF_outputs.pos eq bullsBase.pos)$p_mParam(bullsBase,"%basBreed%","dressPerc")), 100 / p_mParam(bullsBase,"%basBreed%","dressPerc") * p_shareFood(beef_HF_outputs,soci) );
 $$iftheni.byBull "%buyYoungBulls%"=="on"
  p_foodCont(soci,set_bullsBought) = sum((sameas(set_bullsBought,bullsBought),curbreeds)$herds_breeds(bullsBought,curBreeds),   p_shareFood(set_bullsBought,soci) * p_mParam(bullsBought,curBreeds,"FinalWgt"));
 $$endif.byBull
$$endif.b
$$iftheni.clv "%buyCalvs%"=="true"
  p_foodCont(soci,"mCalvsRaisBought") =sum((curbreeds,mcalv_prods)$(herds_breeds("mCalvsRaisBought",curbreeds)$sum((acts,t,sameas(mcalv_prods,prods))$p_OCoeff(acts,prods,curbreeds,t),1)), p_calvsParam("mCalvsRais",curBreeds,"startwgt") * p_shareFood(mcalv_prods,soci));
  p_foodCont(soci,"fCalvsRaisBought") =sum((curbreeds,fcalv_prods)$(herds_breeds("fCalvsRaisBought",curbreeds)$sum((acts,t,sameas(fcalv_prods,prods))$p_OCoeff(acts,prods,curbreeds,t),1)), p_calvsParam("fCalvsRais",curBreeds,"startwgt") * p_shareFood(fcalv_prods,soci));
$$endif.clv
$$iftheni.dh "%farmbranchDairy%" == "on"
  p_foodCont(soci,heifBeef_HF_outputs) = sum(heifsBase $((heifBeef_HF_outputs.pos eq heifsBase.pos)$p_fParam(heifsBase,"%basBreed%","dressPerc")), 100 / p_fParam(heifsBase,"%basBreed%","dressPerc") *  p_shareFood(heifBeef_HF_outputs,soci) ) ;
  p_foodCont(soci,"oldcow") =  p_shareFood("oldcow",soci) / (p_cowAttr("HF","dressPerc")/100);
  p_foodCont(soci,"mCalv_HF") = p_shareFood("mCalv_HF",soci) * p_calvsParam("mCalvsRais","%basBreed%","startwgt");
  p_foodCont(soci,"fCalv_HF") = p_shareFood("fCalv_HF",soci) * p_calvsParam("fCalvsRais","%basBreed%","startwgt");
  p_foodCont(soci,set_heifsBought) = sum((sameas(set_heifsBought,heifsBought),curbreeds)$herds_breeds(heifsBought,curBreeds),   p_shareFood(set_heifsBought,soci) * p_fParam(heifsBought,curBreeds,"FinalWgt"));
$$endif.dh
$$iftheni.mc "%farmBranchMotherCows%"=="on"
  p_foodCont(soci,beef_MC_outputs)  =  sum(bullsMC $((beef_MC_outputs.pos eq bullsMC.pos)$p_mParam(bullsMC,"%motherCowBreed%","dressPerc")),100 / p_mParam(bullsMC,"%motherCowBreed%","dressPerc") * p_shareFood(beef_MC_outputs,soci) ) ;
  p_foodCont(soci,heifBeef_MC_outputs)  =  sum(heifsMC $((heifBeef_MC_outputs.pos eq heifsMC.pos)$p_fParam(heifsMC,"%motherCowBreed%","dressPerc")), 100 / p_fParam(heifsMC,"%motherCowBreed%","dressPerc")  * p_shareFood(heifBeef_MC_outputs,soci) ) ;
  p_foodCont(soci,"oldcow") =  p_shareFood("oldcow",soci) / (p_cowAttr("MC","dressPerc")/100);
  p_foodCont(soci,"mCalv_MC") = p_shareFood("mCalv_MC",soci) * p_calvsParam("mCalvsRais","%motherCowBreed%","startwgt");
  p_foodCont(soci,"fCalv_MC") = p_shareFood("fCalv_MC",soci) * p_calvsParam("fCalvsRais","%motherCowBreed%","startwgt");
  p_foodCont(soci,set_heifsBought) = sum((sameas(set_heifsBought,heifsBought),curbreeds)$herds_breeds(heifsBought,curBreeds),   p_shareFood(set_heifsBought,soci) * p_fParam(heifsBought,curBreeds,"FinalWgt"));
$$endif.mc

$$iftheni.cross "%crossBreeding%"=="true"
 $$iftheni.b "farmBranchBeef"=="on"
  p_foodCont(soci,beef_SI_outputs) = sum(bullsCross $((beef_SI_outputs.pos eq bullsCross.pos)$p_mParam(bullsCross,"%crossBreed%","dressPerc") ), 100 / p_mParam(bullsCross,"%crossBreed%","dressPerc") * p_shareFood(beef_SI_outputs,soci));
 $$endif.b
  p_foodCont(soci,heifBeef_SI_outputs) = sum(heifsCross $((heifBeef_SI_outputs.pos eq heifsCross.pos)$p_fParam(heifsCross,"%crossBreed%","dressPerc") ), 100 / p_fParam(heifsCross,"%crossBreed%","dressPerc") * p_shareFood(heifBeef_SI_outputs,soci));
  p_foodCont(soci,"mCalv_SI") = p_shareFood("mCalv_SI",soci) * p_calvsParam("mCalvsRais","%motherCowBreed%","startwgt");
  p_foodCont(soci,"fCalv_SI") = p_shareFood("fCalv_SI",soci) * p_calvsParam("fCalvsRais","%motherCowBreed%","startwgt");
$$endif.cross
*Convert calories into kilo calories for scaling
p_foodCont("calories",prodsAll)=p_foodCont("calories",prodsAll)/1000;
$$endif.ch
