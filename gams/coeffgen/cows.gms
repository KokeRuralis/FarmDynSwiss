********************************************************************************
$ontext

   FARMDYN project

   GAMS file : COWS.GMS

   @purpose  : Define milk yields, number of lactations and variable costs
               of cows and heifers

   @author   : Bernd Lengers, Wolfgang Britz and Christoph Pahmeyer
   @date     : 12.11.10
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************

$batinclude 'util/title.gms' "'%titlePrefix% Define coefficients relating to cows and heifers'"

  p_prodLength(herds,curBreeds) $ (not p_prodLength(herds,curBreeds))  = 12;

* -----------------------------------------------------------------------------
*
*   Controlling variables for enforced mitigation options in cows
*
* -----------------------------------------------------------------------------
$iftheni.miti "%mitiMeasures%" == true
parameter p_vCostCapture(herds,Breeds,t) "Controlling parameter to prevent multiple reads"
          p_nLacCapture                  "see above"
          ;
          p_vCostCapture(cows,breeds,t) = eps;
          p_nLacCapture = eps;
          p_nLactations = eps;
$endif.miti
* -----------------------------------------------------------------------------
*
*    Heifers
*
* -----------------------------------------------------------------------------

  set heifsParam "Parameters related to heifers fron GUI"
                 / startWgt
                   finalWgt
                   days
                   dailyWgtGain
                   dressPerc
                /;

  parameter p_fParam(herds,allBreeds,heifsParam);

*
* --- accepted, map into parameters used by model
*
  $$iftheni.base defined p_heifsAttr
    p_fParam(heifs,curBreeds,heifsParam)   $ (p_heifsAttr(heifs,"startWgt") $ herds_breeds(heifs,curBreeds))
      = p_heifsAttr(heifs,heifsParam);
  $$endif.base
  $$iftheni.mc "%farmBranchMotherCows%"=="ON"
    p_fParam(heifs,curBreeds,heifsParam) $ (p_heifsAttrMC(heifs,"StartWgt") $ (herds_breeds(heifs,curBreeds)))
      = p_heifsAttrMC(heifs,heifsParam);
  $$endif.mc
  $$iftheni.cross "%crossBreeding%"=="true"
    p_fParam(heifs,crossBreeds,heifsParam) $ (p_heifsAttrCross(heifs,"StartWgt") $ herds_breeds(heifs,crossBreeds))
      = p_heifsAttrCross(heifs,heifsParam);
  $$endif.cross
*
* --- calculate daily weight gain in gram : difference between final and start weight
*     in kg divided by process length in days
*
  p_fParam(heifs,curBreeds,"dailyWgtGain") $ (p_fParam(heifs,curBreeds,"days") $ herds_breeds(heifs,curBreeds))
     = round((p_fParam(heifs,curBreeds,"finalWgt")-p_fParam(heifs,curBreeds,"startWgt"))
                                                    /p_fParam(heifs,curBreeds,"days")   * 1000);
*
* --- Use final weight and dressing percentage of raising heifers for
*     heifers solds and bought
*
  p_fParam(heifsBought,curBreeds,"finalWgt") $ herds_breeds(heifsBought,curBreeds)
    = sum(heifs $ (heifs.pos eq heifsBought.pos), p_fParam(heifs,curBreeds,"startWgt"));

  p_fParam(heifsBought,curBreeds,"dressPerc") $ herds_breeds(heifsBought,curBreeds)
    = sum(heifs $ (heifs.pos eq heifsBought.pos), p_fParam(heifs,curBreeds,"dressPerc"));

  p_fParam(heifsSold,curBreeds,"finalWgt") $ herds_breeds(heifsSold,curBreeds)
   = sum(heifs $ (heifs.pos eq heifsSold.pos), p_fParam(heifs,curBreeds,"finalWgt"));

  p_fParam(heifsSold,curBreeds,"dressPerc") $ herds_breeds(heifsSold,curBreeds)
   = sum(heifs $ (heifs.pos eq heifsSold.pos), p_fParam(heifs,curBreeds,"dressPerc"));
*
* --- calculate beef output for heifers sold from final weight and dressing precentage
*
  $$iftheni.base defined heifBeef_HF_outputs
    p_OCoeff(heifsSoldHF,heifBeef_HF_outputs,curBreeds,t) $ herds_breeds(heifsSoldHF,curBreeds)
      = sum(heifsBase $ ((heifsBase.pos eq heifsSoldHF.pos) and (heifsBase.pos eq heifBeef_HF_outputs.pos)),
        p_fParam(heifsBase,curBreeds,"finalWgt") * p_fParam(heifsBase,curBreeds,"dressPerc")/100);
  $$endif.base
  $$iftheni.mc "%farmBranchMotherCows%"=="on"
    p_OCoeff(heifsSoldMC,heifBeef_MC_outputs,curBreeds,t) $ (herds_breeds(heifsSoldMC,curBreeds) $ (heifsSold_MC_beefOutputs(heifsSoldMC, heifBeef_MC_outputs)))
      = sum(heifsMC $ ((heifsMC.pos eq heifsSoldMC.pos) and (heifsMC.pos eq heifBeef_MC_outputs.pos)),
         p_fParam(heifsMC,curBreeds,"finalWgt") * p_fParam(heifsMC,curBreeds,"dressPerc")/100);
  $$endif.mc
  $$iftheni.cross "%crossBreeding%"=="true"
    p_OCoeff(heifsSold,heifBeef_SI_outputs,crossBreeds,t) $ (heifsSold_SI_beefOutputs(heifsSold, heifBeef_SI_outputs))
        = p_fParam(heifsSold,crossBreeds,"finalWgt") * p_fParam(heifsSold,crossBreeds,"dressPerc")/100;
  $$endif.cross

  p_Vcost(heifs,curBreeds,t)         =  %costHeifsPerYear% * ([1+%outputPriceGrowthRate%/100]**t.pos);

  p_OCoeff(dcows,"milk",curBreeds,t) $ herds_breeds(dcows,curBreeds)         = %milkYield%/10;
  p_Vcost(cows,curBreeds,t)              = ( 500 +  150/6 * (smax(curBreeds1,p_OCoeff(cows,"milk",curBreeds,t))-4)/1)
                                            * ([1+%outputPriceGrowthRate%/100]**t.pos);

*
* --- Enforced mitigation option lactation variable costs for cows
*
$iftheni.lacFloor "%lacfloor%" == "true"
* --- Capture the p_vCost to prevent double calculations
        p_vCostCapture(cows,curBreeds,t) = p_vCost(cows,curBreeds,t);
        $$batInclude '%datdir%/enforcedMitigation.gms'
$endif.lacFloor

*
* ---- Production length calculations
*

  p_prodLength(heifs,curBreeds) = 0;
  p_prodLength(heifs,curBreeds) $ p_fParam(heifs,curBreeds,"dailyWgtGain")
       = round( (p_fParam(heifs,curBreeds,"finalWgt")
                -p_fParam(heifs,curBreeds,"startWgt"))*1000/p_fParam(heifs,curBreeds,"dailyWgtGain")/30.5);

  p_prodLength(heifsBought,curBreeds)    =  0;
  p_prodLength(heifsBought,curBreeds) $ p_fParam(heifsBought,curBreeds,"finalWgt") =  1;
  p_prodLength(heifsSold,curBreeds)      =  0;
  p_prodLength(heifsSold,curBreeds)   $ p_fParam(heifsSold,curBreeds,"finalWgt")   =  1;

  p_prodLength("heifsSold",curBreeds)  = 1;
  p_prodlength("heifsbought",curBreeds)= 1;

*
* --- Average age of animals in days used for calculation of exact LU
*

  p_age(heifs,curbreeds) $herds_breeds(heifs,curbreeds)=
      p_calvsParam("fCalvsrais",curbreeds,"Days") + p_fParam(heifs,curBreeds,"days")
      + sum(heifs1 $(herds_from_herds(heifs,heifs1,curbreeds) $(not sameas(heifs,heifs1))) ,   p_fParam(heifs1,curBreeds,"days")
      + sum(heifs2 $(herds_from_herds(heifs1,heifs2,curbreeds) $(not (sameas(heifs1,heifs2) ))) ,   p_fParam(heifs2,curBreeds,"days") ));

  p_age(heifs,curbreeds)$herds_breeds(heifs,curbreeds) = p_age(heifs,curbreeds) - p_fParam(heifs,curBreeds,"days")/2;

*
* --- LU calculation based on age of
*

  p_lu(heifs,curbreeds) $( (p_age("fcalvsrais",curBreeds) gt 0)$herds_breeds(heifs,curbreeds))=
      p_lu("fcalvsrais",curBreeds) + 0.3$( p_age(heifs,curbreeds) ge 365) + 0.1$(p_age(heifs,curbreeds) ge 365*2);

* -----------------------------------------------------------------------------
*
*    Dairy cows and mothercows
*
* -----------------------------------------------------------------------------

*
* --- milk yield according to genetic potential as entered on GUI
*
  p_OCoeff("motherCow","milkFed","%motherCowBreed%",t)                       = 3;
  p_OCoeff(slgtCows,"oldCow",curBreeds,t) $ herds_breeds(slgtCows,curBreeds) = 1;
*
* --- Lactations from interface
*     Beware: Model will turn infeasible below 2.3 lactations if neither sexing nor buying of heifers is allowed

  p_nLactations = p_calvAttr("%cowType%", "nLactations");
*
* --- Extended lactation period of cows based on improved herd management
*
$iftheni.lacF "%lacfloor%" == true
*     Captures the initial lactation levels
          p_nLacCapture = p_nLactations;
          $$batInclude '%datdir%/enforcedMitigation.gms'
$endif.lacF
*
* --- as the model works with integer replacements, we define two type of cows
*     (e.g. for 2.6 lactations: part of cows has 2, part 3 lactations)
*
  p_nLac("cows%MilkYield%00_short") = floor(p_nLactations);
  p_nLac("cows%MilkYield%00_long")  = ceil(p_nLactations);
* ---- Endogenous mitigation measure for extended lactation included here setting the values for p_VCost and p_nLac for dairy cows
$ifi "%endoMeasures%" == true $$batInclude '%datdir%/endogMitiMeasures.gms'



  p_nLac("motherCow") = p_calvAttr("MC", "nLactations");

*
* --- length of production period (currently all at 12 months, with the exemption of cows and heifs)
*
  p_prodLength(slgtCows,curBreeds)     = 1;
  p_prodLength("slgtCows",curBreeds)   = 1;
  p_prodLength("remonte",curBreeds)    = 1;
  p_prodLength(remonte,curBreeds)      = 1;

  p_prodLength(dcows,curBreeds) $ herds_breeds(dcows,curBreeds) = round(p_calvAttr("%cowType%","daysBetweenBirths")/365       * p_nLac(dcows)  * 12);
  p_prodLength(mcows,curBreeds) $ herds_breeds(mcows,curBreeds) = round(p_calvAttr("%motherCowType%","daysBetweenBirths")/365 * p_nLac("motherCow") *12);

  p_OCoeff(dcows,"oldCow",curBreeds,t) $ herds_breeds(dcows,curBreeds)   = p_cowAttr("HF","avgCowWeigth") * (p_cowAttr("HF","dressPerc")/100) / p_nLac(dcows)       * 365/p_calvAttr("HF","daysBetweenBirths");
  p_OCoeff(mcows,"oldCow",curBreeds,t) $ herds_breeds(mcows,curBreeds)   = p_cowAttr("MC","avgCowWeigth") * (p_cowAttr("MC","dressPerc")/100) / p_nLac("motherCow") * 365/p_calvAttr("MC","daysBetweenBirths");
