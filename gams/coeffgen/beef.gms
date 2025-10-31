********************************************************************************
$ontext

   FARMDYN project

   GAMS file : BEEF.GMS

   @purpose  :

   @author   : C. Pahmeyer and W.Britz
   @date     : 10.01.18
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************

$batinclude 'util/title.gms' "'%titlePrefix% Define coefficients relating to animals'"

  set bullsParam / startWgt
                   finalWgt
                   days
                   dailyWgtGain
                   dressPerc
                   price
                 /;


  parameter p_mParam(herds,allBreeds,bullsParam);
*
* -- plausibility checks on data entered by user
*

  $$ifthen.bullsBasBreed defined p_bullsAttr


     if(sum(bulls $ ((p_bullsAttr(bulls,"finalWgt") < p_bullsAttr(bulls,"startWgt")+14) $ p_bullsAttr(bulls,"startWgt")),1),
       abort "Final weights for bulls should exceed start weight at least by 15 kg, in %system.incName%, line %system.incLine%");

     if(sum(bulls $ ((p_bullsAttr(bulls,"days") < 30) $ p_bullsAttr(bulls,"days")),1),
       abort "Bulls processes should at least cover 30 days, in %system.incName%, line %system.incLine%");

     if(sum(bulls $ ( ((p_bullsAttr(bulls,"finalWgt")-p_bullsAttr(bulls,"startWgt"))/p_bullsAttr(bulls,"days")>2 )
                             $ p_bullsAttr(bulls,"days")),1),
       abort "Bulls processes with daily weight gain > 2 kg not allowed, in %system.incName%, line %system.incLine%");

     if(sum(bulls $ ( ((p_bullsAttr(bulls,"finalWgt")-p_bullsAttr(bulls,"startWgt"))/p_bullsAttr(bulls,"days")<0.5 )
                             $ p_bullsAttr(bulls,"days")),1),
       abort "Bulls processes with daily weight gain < 0.5 kg not allowed, in %system.incName%, line %system.incLine%");
*
*    -- accepted, map into parameters used by model
*
     p_mParam(bulls,curBreeds,bullsParam)   $ (p_bullsAttr(bulls,"StartWgt") $ (herds_breeds(bulls,curBreeds)))
        = p_bullsAttr(Bulls,bullsParam);
  $$endif.bullsBasBreed

  $$iftheni.mc "%farmBranchMotherCows%"=="ON"
   p_mParam(bulls,curBreeds,bullsParam) $ (p_bullsAttrMC(bulls,"StartWgt") $ (herds_breeds(bulls,curBreeds)))
     = p_bullsAttrMC(bulls,bullsParam);
  $$endif.mc
  $$iftheni.cross "%crossBreeding%"=="true"
    p_mParam(bulls,crossBreeds,bullsParam) $ (p_bullsAttrCross(bulls,"StartWgt") $ (herds_breeds(bulls,crossBreeds)))
      = p_bullsAttrCross(bulls,bullsParam);
  $$endif.cross
  p_mParam(bulls,curBreeds,"dailyWgtGain") $ (p_mParam(bulls,curBreeds,"days") $ herds_breeds(bulls,curBreeds))
      = round((p_mParam(bulls,curBreeds,"finalWgt")-p_mParam(bulls,curBreeds,"startWgt"))
           /p_mParam(bulls,curBreeds,"days")   * 1000);
*
*   --- define parameter for bulls sold from bulls process
*
    p_mParam(bullsBought,curBreeds,"finalWgt") $ herds_breeds(bullsBought,curBreeds)
       = sum(bulls $ (bulls.pos eq bullsBought.pos), p_mParam(bulls,curBreeds,"startWgt"));
    p_mParam(bullsBought,curBreeds,"dressPerc") $ herds_breeds(bullsBought,curBreeds)
       = sum(bulls $ (bulls.pos eq bullsBought.pos), p_mParam(bulls,curBreeds,"dressPerc"));

    p_mParam(bullsSold,curBreeds,"finalWgt") $ herds_breeds(bullsSold,curBreeds)
       = sum(bulls $ (bulls.pos eq bullsSold.pos), p_mParam(bulls,curBreeds,"finalWgt"));

    p_mParam(bullsSold,curBreeds,"dressPerc") $ herds_breeds(bullsSold,curBreeds)
       = sum(bulls $ (bulls.pos eq bullsSold.pos), p_mParam(bulls,curBreeds,"dressPerc"));


   $$ifthen.bas defined beef_HF_outputs
    p_OCoeff(bullsSoldHF,beef_HF_outputs,curBreeds,t) $ herds_breeds(bullsSoldHF,curBreeds)
      = sum(bullsBase $ ((bullsBase.pos eq bullsSoldHF.pos) and (bullsBase.pos eq beef_HF_outputs.pos)),
          p_mParam(bullsBase,curBreeds,"finalWgt") * p_mParam(bullsBase,curBreeds,"dressPerc")/100);
   $$endif.bas

  $$iftheni.mc "%farmBranchMotherCows%"=="on"
    p_OCoeff(bullsSoldMC,beef_MC_outputs,curBreeds,t) $ (herds_breeds(bullsSoldMC,curBreeds) $ (bullsSold_MC_beefOutputs(bullsSoldMC, beef_MC_outputs)))
      = sum(bullsMC $ ((bullsMC.pos eq bullsSoldMC.pos) and (bullsMC.pos eq beef_MC_outputs.pos)),
         p_mParam(bullsMC,curBreeds,"finalWgt") * p_mParam(bullsMC,curBreeds,"dressPerc")/100);
  $$endif.mc

  $$iftheni.cross "%crossBreeding%"=="true"
    p_OCoeff(bullsSoldSI,beef_SI_outputs,curBreeds,t) $ (herds_breeds(bullsSoldSI,curBreeds) $ (bullsSold_SI_beefOutputs(bullsSoldSI, beef_SI_outputs)))
      = sum(bullsCross $ ((bullsCross.pos eq bullsSoldSI.pos) and (bullsCross.pos eq beef_SI_outputs.pos)),
         p_mParam(bullsCross,curBreeds,"finalWgt") * p_mParam(bullsCross,curBreeds,"dressPerc")/100);
  $$endif.cross
*  abort p_OCoeff,bullsSold,p_mParam;
*
*   --- length of production period (currently all at 12 months, with the exemption of cows and heifs)
*
    p_prodLength(bulls,curBreeds) = 0;
    p_prodLength(bulls,curBreeds) $ (p_mParam(bulls,curBreeds,"dailyWgtGain") $ (herds_breeds(bulls,curBreeds)))
         = round( (p_mParam(bulls,curBreeds,"finalWgt")
                  - p_mParam(bulls,curBreeds,"startWgt")) * 1000/p_mParam(bulls,curBreeds,"dailyWgtGain") / 30.5);

    p_prodLength(bullsBought,curBreeds)    =  0;
    p_prodLength(bullsBought,curBreeds) $ p_mParam(bullsBought,curBreeds,"finalWgt") =  1;
    p_prodLength(bullsSold,curBreeds)      =  0;
    p_prodLength(bullsSold,curBreeds)   $ p_mParam(bullsSold,curBreeds,"finalWgt")   =  1;


    p_prodLength("bulls",curBreeds)     = 12;


*
*   --- costs per year if the animal would be kept for a full year
*

$if not set costBullsPerYear $setglobal costBullsPerYear 80

*
    p_Vcost(bulls,curBreeds,t) $ p_prodLength(bulls,curBreeds)
          =  %costBullsPerYear% * ([1+%outputPriceGrowthRate%/100]**t.pos);


*
* --- Average age of animals in days used for calculation of exact LU
*


    p_age(bulls,curbreeds)$herds_breeds(bulls,curbreeds) = p_calvsParam("mCalvsrais",curbreeds,"Days") + p_mParam(bulls,curBreeds,"days")
                         + sum(bulls1 $(herds_from_herds(bulls,bulls1,curbreeds) $(not sameas(bulls,bulls1))) ,   p_mParam(bulls1,curBreeds,"days")
                         + sum(bulls2 $(herds_from_herds(bulls1,bulls2,curbreeds) $(not (sameas(bulls1,bulls2) ))) ,   p_mParam(bulls2,curBreeds,"days") ));

    p_age(bulls,curbreeds) $herds_breeds(bulls,curbreeds)= (2*p_age(bulls,curbreeds) - p_mParam(bulls,curBreeds,"days"))/2;


*
* --- LU calculated based on age of animals
*


    p_lu(bulls,curbreeds) $( (p_age("mcalvsrais",curBreeds) gt 0) $ herds_breeds(bulls,curbreeds)) =
        p_lu("mcalvsrais",curbreeds) + 0.3$(p_age(bulls,curbreeds) ge 365) + 0.1$(p_age(bulls,curbreeds) ge 365*2);
