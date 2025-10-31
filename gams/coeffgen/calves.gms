********************************************************************************
$ontext

   FARMDYN project

   GAMS file : CALVES.GMS

   @purpose  : Map parameters from GUI to parameters in model, define
               production length, set variable costs

   @author   : C. Pahmeyer and W.Britz
   @date     : 15.02.18
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen\coeffgen.gms

$offtext
********************************************************************************

$batinclude 'util/title.gms' "'%titlePrefix% Define coefficients relating to calves'"

 set calvsParam "Parameters defined via GUI"
                / startWgt
                  finalWgt
                  days
                  dailyWgtGain
                  dressPerc
               /;

  parameter p_calvsParam(herds,allBreeds,calvsParam);

  p_calvsParam(calvsRais,"%basBreed%",calvsParam) $ (p_calvsAttrGuiBas(calvsRais,"StartWgt") $ (herds_breeds(calvsRais,"%basBreed%")))
     = p_calvsAttrGuiBas(calvsRais,calvsParam);

  $$iftheni.mc "%farmBranchMotherCows%"=="ON"
     p_calvsParam(calvsRais,"%motherCowBreed%",calvsParam) $ (p_calvsAttrGuiMC(calvsRais,"StartWgt") $ (herds_breeds(calvsRais,"%motherCowBreed%")))
       = p_calvsAttrGuiMC(calvsRais,calvsParam);
  $$endif.mc
  $$iftheni.cross "%crossBreeding%"=="true"
     p_calvsParam(calvsRais,"%crossBreed%",calvsParam) $ (p_calvsAttrGuiCross(calvsRais,"StartWgt") $ (herds_breeds(calvsRais,"%crossBreed%")))
      = p_calvsAttrGuiCross(calvsRais,calvsParam);
  $$endif.cross

  p_calvsParam(calvsRais,curBreeds,"dailyWgtGain") $ p_calvsParam(calvsRais,curBreeds,"days")
    = round((p_calvsParam(calvsRais,curBreeds,"finalWgt")-p_calvsParam(calvsRais,curBreeds,"startWgt"))
         /p_calvsParam(calvsRais,curBreeds,"days")   * 1000);
*
* --- define parameter for calves sold from calves process
*
  p_calvsParam(calvsRaisSold,curBreeds,"finalWgt")
     = sum(calvsRais $ (calvsRais.pos eq calvsRaisSold.pos), p_calvsParam(calvsRais,curBreeds,"finalWgt"));
*
* --- one calf is sold by each of the calves selling processing
*
  p_OCoeff("mCalvsSold","mCalv_HF","%basBreed%",t)       = 1;
  $$ifi "%farmBranchMotherCows%"=="on" p_OCoeff("mCalvsSold","mCalv_MC","%motherCowBreed%",t) = 1;
  $$ifi "%crossBreeding%" =="true" p_OCoeff("mCalvsSold","mCalv_SI",crossBreeds,t) = 1;
  p_OCoeff("mCalvsRaisSold","mCalvRaisSold","%basBreed%",t) = 1;
  p_OCoeff("fCalvsSold","fCalv_HF","%basBreed%",t)          = 1;
  $$ifi "%farmBranchMotherCows%"=="on" p_OCoeff("fCalvsSold","fCalv_MC","%motherCowBreed%",t) = 1;
  $$ifi "%crossBreeding%"=="true" p_OCoeff("fCalvsSold","fCalv_SI",crossBreeds,t) = 1;
*
*   --- length of production period
*
    p_prodLength(calvsRais,curBreeds) = 0;
    p_prodLength(calvsRais,curBreeds) $ p_calvsParam(calvsRais,curBreeds,"dailyWgtGain")
         = round( (p_calvsParam(calvsRais,curBreeds,"finalWgt")
                  -p_calvsParam(calvsRais,curBreeds,"startWgt")) * 1000/p_calvsParam(calvsRais,curBreeds,"dailyWgtGain")/30.5);

    p_prodLength(calvsRaisSold,curBreeds)      =  0;
    p_prodLength(calvsRaisSold,curBreeds)   $ p_calvsParam(calvsRaisSold,curBreeds,"finalWgt")   =  1;

    p_prodLength("mCalvsSold",curBreeds)      = 1;
    p_prodLength("mCalvsRaisSold",curBreeds)  = 1;
    p_prodLength("fCalvsSold",curBreeds)      = 1;
*
*   --- costs per year if the animal would be kept for a full year
*
    $$if not set costCalvsRaisPerYear $setglobal costCalvsRaisPerYear 80
*
    p_Vcost(calvsRais,curBreeds,t) $ p_prodLength(calvsRais,curBreeds)
          =  %costCalvesPerYear% * ([1+%outputPriceGrowthRate%/100]**t.pos);
*
*   --- Calculation of the average age of calves in days
*
   p_age(calvsRais,curbreeds) = p_calvsParam(calvsRais,curbreeds,"Days")/2;
