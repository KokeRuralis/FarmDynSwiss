********************************************************************************
$ontext

   FARMDYN project

   GAMS file : organic_fert.gms
   @purpose  : calculate nitrogen fixation and nitrogen saldo of legumes

   @author   : J.Heinrichs
   @date     : 17.04.2021
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************
$iftheni.fert %Fertilization% == "OrganicFarming"


*
* --- Amount of Nitrogen lost trough denitrification
*     referneces e.g. Hermsmeyer  1996 and KTBL Nährstoffmanagement im Ökologischen Landbau

   p_NDenitrification(crops) $ ((not sum(catchCrops, sameas(crops,catchCrops))) $ (not sameas(crops,"idle"))) = 20;

*
* --- N from mineralization in spring
*
   p_NutFromSoil(crops,soil,till,"N",t) $ sum(prods, p_OCoeffC(crops,soil,till,"normal",prods,t))         = p_Nmin(crops);
   p_NutFromSoil(crops,soil,till,"P",t) $ sum(prods, p_OCoeffC(crops,soil,till,"normal",prods,t))         = 0;

*
* --- N uptake from crop residues
*
   p_NfromCropRes(c_ss_t_i(curCrops,soil,till,intens),t) $ p_NUpCoeffRes(curcrops,soil)
    = p_Nresidues(curCrops,soil,till,intens,t) * p_NUpCoeffRes(curCrops,soil);

*
* --- Nitrogen Import by seeds respecting that seed quantity in t, and nutSeeds in dt/ha
*

   p_NfromSeeds(curCrops,till,intens) =
      sum(inputs, p_inputQuant(curCrops,till,intens,inputs,"t/ha")
        $ inputs_category(inputs,"seed")) * p_nutSeeds(curCrops) * 10;


*
* --- N fixation of legumes according to Küstermann / KTBL
*

   p_NfixLeg(c_ss_t_i(leg,soil,till,intens),t)
      = p_legshare(leg) * (p_Ndfa(leg)* p_NExtractPlant(leg,soil,till,intens,t)) ;
*

*
* --- fixed N remaining on field after legumes are harvested (total amount of N minus N from fixation in crop harvest)
*
   p_NSaldoLeg(c_ss_t_i(leg,soil,till,intens),t)
      = p_NfixLeg(leg,soil,till,intens,t) - (p_nutNeed(leg,soil,till,intens,"N",t) * p_Ndfa(leg));

*
* --- delete Nitrogen saldo in case it is negative
*
   p_NSaldoLeg(leg,soil,till,intens,t) $ (p_NSaldoLeg(leg,soil,till,intens,t) lt 0) = 0;

*
* --- amount of N from fixation covering N Need from legumes itself
*

   p_LegPoolItself(c_ss_t_i(leg,soil,till,intens),"N",t) $ p_NfixLeg(leg,soil,till,intens,t) = p_NfixLeg(leg,soil,till,intens,t);

$endif.fert
