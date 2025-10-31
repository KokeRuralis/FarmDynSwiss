********************************************************************************
$ontext

   FARMDYN project

   GAMS file : PRICES.GMS

   @purpose  : Define prices for inputs/outputs
   @author   : Bernd Lengers
   @date     : 12.11.10
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************

$batinclude 'util/title.gms' "'%titlePrefix% Define prices'"

    p_disCountRate = %DiscountRate%;
    p_interestGain = %intLiquidRate%;

*
*   --- single farm payment - KTBL 2014/2015, p. 799
*
    $$ifi "%EUCountry%" == "true" p_sfPrem(landtype,soil,tFut)     =  %sfb%;
    $$ifi not set orgPrem $set orgPrem 0
    p_orgPrem(landtype,soil,tFut)    =  %orgPrem%;
*
*   --- land rent on an annual basis
*
    p_landRent(plot,tFut)
     = sum( plot_lt_soil(plot,landType,soil), %landRent% * ([1+%outputPriceGrowthRate%/100]**tFut.pos));
*
*   --- price of land: accumulated land rent plus 100% for speculative value
*
    p_pland(plot,tFut)
       = sum( tFut1 $ (p_Year(tFut1) gt p_year(tFut)), p_landRent(plot,tFut1)) * 2;

$if not set milkprice         $setglobal milkprice         0
$if not set oldSowPrice       $setglobal oldSowPrice       0
$if not set BeefPriceOld      $setglobal BeefPriceOld      0

$eval milkPriceCor %milkPrice%*10

$onmulti
$onempty
   parameter p_outputPrices(prods,sys) /

$iftheni.ph %pigHerd%==true
        $$iftheni.fh "%farmBranchFattners%" == on
       pigMeat.conv             %porkPrice%
        $$endif.fh
       $$iftheni.sows "%farmBranchSows%" == on
       pigletsSold .conv        %pigletPrice%
       youngPiglet .conv        1.E-10
       oldSow      .conv        %oldSowPrice%
       $$endif.sows
$endif.ph
$iftheni.cows "%cowherd%"=="true"
       milk    .conv            %milkPriceCor%
       mCalv_HF.conv            %mCalv_HF_Price%
       fCalv_HF.conv            %fCalv_HF_Price%
       mCalv_SI.conv            %mCalv_SI_Price%
       fCalv_SI.conv            %fCalv_SI_Price%
       mCalv_MC.conv            %mCalv_HF_Price%
       fCalv_MC.conv            %fCalv_HF_Price%
$endif.cows

   /;
$offempty



$iftheni.bulls "%farmBranchBeef%"=="on"


   $$ifi defined beef_HF_outputs p_outputPrices(beef_HF_outputs,"conv") = sum(meatTypes $ (ord(beef_HF_outputs) eq ord(meatTypes)), p_bullsAttrGuiBas(meatTypes , "Price")   * 1);
   $$ifi defined beef_MC_outputs p_outputPrices(beef_MC_outputs,"conv") = sum(meatTypes $ (ord(beef_MC_outputs) eq ord(meatTypes)), p_bullsAttrGuiMC(meatTypes , "Price")    * 1);
   $$ifi defined beef_SI_outputs p_outputPrices(beef_SI_outputs,"conv") = sum(meatTypes $ (ord(beef_SI_outputs) eq ord(meatTypes)), p_bullsAttrGuiCross(meatTypes , "Price") * 1);

$endif.bulls

$iftheni.cows "%cowHerd%"=="true"

   $$ifi defined heifBeef_HF_outputs p_outputPrices(heifBeef_HF_outputs,"conv") = sum(meatTypes $ (ord(heifBeef_HF_outputs) eq ord(meatTypes)), p_heifsAttrGuiBas(meatTypes , "Price")   * 1);
   $$ifi defined heifBeef_MC_outputs p_outputPrices(heifBeef_MC_outputs,"conv") = sum(meatTypes $ (ord(heifBeef_MC_outputs) eq ord(meatTypes)), p_heifsAttrGuiMC(meatTypes , "Price")    * 1);
   $$ifi defined heifBeef_SI_outputs p_outputPrices(heifBeef_SI_outputs,"conv") = sum(meatTypes $ (ord(heifBeef_SI_outputs) eq ord(meatTypes)), p_heifsAttrGuiCross(meatTypes , "Price") * 1);

$endif.cows


$offmulti

$iftheni.dh %cowHerd%==true
  $$iftheni.SI %breedSI% == ON
     p_outputPrices("mCalvRais_SI","conv") = %mCalv_SI_Price%;
  $$endif.SI
  $$iftheni.MC "%farmBranchMotherCows%"=="on"
     p_outputPrices("mCalvRais_SI","conv") = %mCalv_SI_Price%;
  $$endif.MC
  $$iftheni.HF %breedHF% == ON
     p_outputPrices("mCalvRais_HF","conv") = %mCalv_HF_Price%;
  $$endif.HF

  p_outputPrices("milkFed","conv") = eps;

$endif.dh


*
* --- crop prices
*
  p_outputPrices(prods,sys) $ sum(sameas(crops,prods),1)
    = sum(sameas(crops,prods),p_cropPrice(crops,sys));

*
*   --- Crop output prices per ton for experiments
*

        $$if setglobal WinterWheatPrice p_outputPrices("WinterWheat","conv")         = %WinterWheatPrice%       ;
        $$if setglobal WinterBarleyPrice p_outputPrices("WinterBarley","conv")       = %WinterBarleyPrice%      ;
        $$if setglobal WinterRyePrice p_outputPrices("WinterRye","conv")             = %WinterRyePrice%         ;
        $$if setglobal SummertriticalePrice p_outputPrices("Summertriticale","conv") = %SummertriticalePrice%   ;
        $$if setglobal SummerCerePrice p_outputPrices("SummerCere","conv")           = %SummerCerePrice%        ;
        $$if setglobal MaizCornPrice p_outputPrices("MaizCorn","conv")               = %MaizCornPrice%          ;
        $$if setglobal WinterRapePrice p_outputPrices("WinterRape","conv")           = %WinterRapePrice%        ;
        $$if setglobal SummerBeansPrice p_outputPrices("SummerBeans","conv")         = %SummerBeansPrice%       ;
        $$if setglobal SummerPeasPrice p_outputPrices("SummerPeas","conv")           = %SummerPeasPrice%        ;
        $$if setglobal PotatoesPrice p_outputPrices("Potatoes","conv")               = %PotatoesPrice%          ;
        $$if setglobal SugarbeetPrice p_outputPrices("Sugarbeet","conv")             = %SugarbeetPrice%         ;

  p_inputPrices(grassil,sys)           $ (not sameas(grasSil,"hay")) = p_inputPrices("grassil",sys);
*
* --- if input price are not given but output prices are given, and outputs are also inputs (such as crops for feeding), use output price +2%
*
  p_inputPrices(inputs,sys)  $( (not p_inputPrices(inputs,sys))  $sum(sameas(prods,inputs),p_outputPrices(prods,sys))) = sum(sameas(prods,inputs),p_outputPrices(prods,sys))/0.98;
*
* --- set prices for sexing & hired labor
*
$if set costMaleSexing   p_inputPrices("maleSexing",sys)   = %costMaleSexing%;
$if set costfemaleSexing p_inputPrices("femaleSexing",sys) = %costfemaleSexing%;

$$ifi "%allowHiring%"=="true" p_inputPrices("hiredLabour",sys)  = %wageHoursHired% * %workHoursHired%;
*
* --- If output prices are not set, set them as 98 of input prices
*
  p_outputPrices(prods,sys)    $ (not p_outputPrices(prods,sys)) = p_inputPrices(prods,"price") * 0.98;
* --- To ensure that inputs are more expensive than outputs in experiments with varying prices (currently only conv)
  $$ifi "%workstep%" == "Experiments" p_inputPrices(prods,"conv")$sum((sameas(prods,crops)),1) = p_outputPrices(prods,"conv") * 1.03;

*
* --- consider growth rates
*
  p_inputprice(inputs,"conv",t)   $ p_inputPrices(inputs,"conv")   = p_InputPrices(inputs,"conv") * ([1.+p_inputPrices(inputs,'Change,conv % p.a.')/100]**t.pos);
  p_inputprice(inputs,"org",t) $ p_inputPrices(inputs,"org")   = p_InputPrices(inputs,"org") * ([1.+p_inputPrices(inputs,'Change,conv % p.a.')/100]**t.pos);
  p_price(prods,sys,t)                                      = p_outputPrices(prods,sys)         * ([1+%outputPriceGrowthRate%/100]**t.pos);
*
* --- prices for organic products, should be mostly beef
*
  p_price(prods,"org",t) $ (not p_price(prods,"org",t))           = p_price(prods,"conv",t)        * 1.2;
  p_price("milk","org",t) $ (not p_price("milk","org",t))         = p_price("milk","conv",t)       * 1.4;

*
* --- prices for organic products (from KTBL 2012/13)
*     for all KTBL crops, that do not have an organic price, do not exist under organic production!
$if defined cere  p_price(cere,"org",t) $ (not p_price(cere,"org",t))     = p_price(cere,"conv",t)          * 392/148;


* --- assume that organic crop residues are 20% more expensive
*
 p_price(prodsResidues,"conv",t) = %cerealStrawPrice% ;
 p_price(prodsResidues,"org",t) =  %cerealStrawPrice% * 1.2;

* --- Correction of prices for regional data


$ifi "%useRegionalDataPrices%"=="ON" $include 'regionalData/prices.gms'

*
*   ---- Specifics for animal outputs
*
$iftheni.herd %Herd%==true

*
*    ---- Prices of dairy production related products
*
*   --- slaughter cow
*
$if not setglobal beefPrice $setglobal beefPrice 2

$iftheni.shortrun "%dynamics%" == "short run"
      p_price("oldCow","conv",t)   = 0.1;
$else.shortrun
$iftheni.mc  "%farmBranchMotherCows%"=="on"
  p_price("oldCow","conv",t)   = p_cowAttr("%motherCowType%","oldCowPrice") * ([1+%outputPriceGrowthRate%/100]**t.pos);
$endif.mc
$iftheni.d  "%farmBranchDairy%"=="on"
  p_price("oldCow","conv",t)   = p_cowAttr("%CowType%","oldCowPrice") * ([1+%outputPriceGrowthRate%/100]**t.pos);
$endif.d


$endif.shortrun
    p_price("youngCow",sys,t) = p_inputPrices("youngCow",sys) * ([1+%outputPriceGrowthRate%/100]**t.pos);
*
*   --- male/female calves: KTBL, 2008/2009, p. 511
*
$iftheni.d %cowHerd% == true
*
  $$iftheni.SI %breedSI% == ON
     p_price("mCalv_mc","conv",t)      =  p_price("mCalv_SI","conv",t);
     p_price("fCalv_mc","conv",t)      =  p_price("fCalv_SI","conv",t);
  $$endif.SI

*   --- Price of heifers

  $$iftheni.base defined HeifsBoughtHF
      p_price(HeifsBoughtHF,"conv",t) $ sum(herds_breeds(HeifsBoughtHF,curBreeds), p_fParam(HeifsBoughtHF,curBreeds,"finalWgt"))
        = sum((herds_breeds(HeifsBoughtHF,curBreeds), heifBeef_HF_outputs) $ (HeifsBoughtHF.pos eq heifBeef_HF_outputs.pos),
          p_fParam(HeifsBoughtHF,curBreeds,"finalWgt")
          * p_fParam(HeifsBoughtHF,curBreeds,"dressPerc")/100
          * p_price(heifBeef_HF_outputs,"conv",t) * 1.3
      );
  $$endif.base

    $$iftheni.mc "%farmBranchMotherCows%"=="on"
      p_price(HeifsBoughtMC,"conv",t) $ sum(herds_breeds(HeifsBoughtMC,curBreeds), p_fParam(HeifsBoughtMC,curBreeds,"finalWgt"))
        = sum((herds_breeds(HeifsBoughtMC,curBreeds), heifBeef_MC_outputs) $ (HeifsBoughtMC.pos eq heifBeef_MC_outputs.pos),
          p_fParam(HeifsBoughtMC,curBreeds,"finalWgt")
          * p_fParam(HeifsBoughtMC,curBreeds,"dressPerc")/100
          * p_price(heifBeef_MC_outputs,"conv",t) * 1.3
      );

    $$endif.mc

    $$iftheni.cross "%crossBreeding%"=="true"
      p_price(HeifsBoughtSI,"conv",t) $ sum(herds_breeds(HeifsBoughtSI,curBreeds), p_fParam(HeifsBoughtSI,curBreeds,"finalWgt"))
        = sum((herds_breeds(HeifsBoughtSI,curBreeds), heifBeef_SI_outputs) $ (HeifsBoughtSI.pos eq heifBeef_SI_outputs.pos),
          p_fParam(HeifsBoughtSI,curBreeds,"finalWgt")
          * p_fParam(HeifsBoughtSI,curBreeds,"dressPerc")/100
          * p_price(heifBeef_SI_outputs,"conv",t) * 1.3
      );
    $$endif.cross
    p_inputPrice(inputs,sys,t) $ sum(sameas(inputs,heifsBought),1)
      = sum(sameas(inputs,heifsBought),p_price(heifsBought,sys,t));

$endif.d

$iftheni.d "%farmBranchBeef%"=="on"
*   Calculation of price for male calves/starters/weaners bought for fattening
*   HF exclusive

    $$iftheni.base defined bullsBoughtHF
    p_price(bullsBoughtHF,"conv",t) $ sum(herds_breeds(bullsBoughtHF,curBreeds), p_mParam(bullsBoughtHF,curBreeds,"finalWgt"))
      = sum((herds_breeds(bullsBoughtHF,curBreeds), beef_HF_outputs) $ (bullsBoughtHF.pos eq beef_HF_outputs.pos),
        p_mParam(bullsBoughtHF,curBreeds,"finalWgt")
        * p_mParam(bullsBoughtHF,curBreeds,"dressPerc")/100
        * p_price(beef_HF_outputs,"conv",t) * 1.3
    );
    $$endif.base

    $$iftheni.mc "%farmBranchMotherCows%"=="on"
      p_price(bullsBoughtMC,"conv",t) $ sum(herds_breeds(bullsBoughtMC,curBreeds), p_mParam(bullsBoughtMC,curBreeds,"finalWgt"))
        = sum((herds_breeds(bullsBoughtMC,curBreeds),beef_MC_outputs) $ (bullsBoughtMC.pos eq beef_MC_outputs.pos),
        p_mParam(bullsBoughtMC,curBreeds,"finalWgt")
        * p_mParam(bullsBoughtMC,curBreeds,"dressPerc")/100
        * p_price(beef_MC_outputs,"conv",t) * 1.3
      );
    $$endif.mc

    $$iftheni.cross "%crossBreeding%"=="true"
      p_price(bullsBoughtSI,"conv",t) $ sum(herds_breeds(bullsBoughtSI,curBreeds), p_mParam(bullsBoughtSI,curBreeds,"finalWgt"))
        = sum((herds_breeds(bullsBoughtSI,curBreeds),beef_SI_outputs) $ (bullsBoughtSI.pos eq beef_SI_outputs.pos),
        p_mParam(bullsBoughtSI,curBreeds,"finalWgt")
        * p_mParam(bullsBoughtSI,curBreeds,"dressPerc")/100
        * p_price(beef_SI_outputs,"conv",t) * 1.3
      );
    $$endif.cross

*
*  --- only define input price if buying of bulls is allowed
*
  $$iftheni.bb %buyYoungBulls%=="true"
      p_inputPrice(inputs,sys,t) $ sum(sameas(inputs,bullsBought),1)
        = sum(sameas(inputs,bullsBought),p_price(bullsBought,sys,t));
    $$endif.bb
    $$iftheni.cb %buyCalves%=="true"
      p_inputPrice(inputs,sys,t) $ sum(sameas(inputs,calvesBought),1)
        = sum(sameas(inputs,calvesBought),p_price(calvesBought,sys,t));
    $$endif.cb
$endif.d

*
*   --- Feed concentrates per ton (entered per 100 kg in interface!)
*       for experiments
*
$if setglobal conc3Price        p_InputPrice("concCattle3","conv",t)   = %conc3Price%       * ([1+%outputPriceGrowthRate%/100]**t.pos);
$if setglobal conc2Price        p_InputPrice("concCattle2","conv",t)   = %conc2Price%       * ([1+%outputPriceGrowthRate%/100]**t.pos);
$if setglobal conc1Price        p_InputPrice("concCattle1","conv",t)   = %conc1Price%       * ([1+%outputPriceGrowthRate%/100]**t.pos);
$if setglobal SoybeanMealPrice  p_inputPrice("SoybeanMeal","conv",t)   = %SoybeanMealPrice% * ([1+%outputPriceGrowthRate%/100]**t.pos);

  p_inputPrice(inputs,"org",t) $ sum(sameas(youngAnim,inputs),1) = p_inputPrice(inputs,"conv",t) * 1.2;
$endif.herd

  p_inputPrice("contractWork",sys,t) = ([1+%outputPriceGrowthRate%/100]**t.pos);
*   --- shifter for crop inputs in experiments
      $$if setglobal cropInputsPrice  p_inputPrice(inputs,sys,t) $ sum(sameas(cropInputs,inputs),1) = sum(sameas(cropInputs,inputs),p_inputPrice(inputs,sys,t))* %cropInputsPrice%;


$iftheni "%dynamics%" == "comparative-static"

     set priceItems;
     priceItems(inputs)      = YES;
     priceItems(prodsYearly) = YES;
     priceItems("youngCow")  = YES;

     p_price(priceItems,"conv",tCur)      = sum(t, p_price(priceItems,"conv",t))     /card(t);
     p_landRent(plot,tcur) = sum(t, p_landRent(plot,t))/card(t);
     p_pland(plot,tcur)    = sum(t, p_pland(plot,t))/card(t);

*
*     --- assume amortization over 20 years
*
      p_pland(plot,tcur) = p_pland(plot,"mean")/20;

$endif

*
* --- Prices for manure import and export
*

$iftheni.ExMan %AllowManureExport%==true

     p_price("manureExport","conv",t)  =   %CostsManureExport% * (1 + %CostsManureExpInc%) ;

$endif.ExMan

$iftheni.im "%AllowManureImport%" == "true"

p_InputPrice(inputs,sys,t)  $sum(ManImports$sameas(inputs,ManImports),1)=     %CostsManureImport%;
$endif.im

*
* --- assume that orgnanic inputs are more expensive
*

  p_inputPrice(inputs,"org",t) $(sum(sameas(feeds,inputs),1) $ (not p_InputPrice(inputs,"org",t))) = p_inputPrice(inputs,"conv",t) * 2;

  p_inputPrice(inputs,"org",t) $ (sum(sameas(inputs,prods),p_price(prods,"org",t)) $ (not p_InputPrice(inputs,"org",t)))
      = p_inputPrice(inputs,"conv",t) * sum(sameas(inputs,prods),p_price(prods,"org",t)/p_price(prods,"conv",t));

  p_price(prods,sys,t) $ (not p_outputPrices(prods,sys) and sum(sameas(inputs,prods),p_inputPrice(inputs,sys,t)))
    = sum(sameas(prods,inputs),p_inputprice(inputs,sys,t)) * 0.98;

  p_price(prods,"org",t) $ (not p_price(prods,"org",t)) = p_price(prods,"conv",t);


$iftheni.feedCatchCrop %feedCatchCrop%  == "true"
p_price("CCclover",sys,t) = EPS;
$endif.feedCatchCrop

* kill prices for eco/conv if not selected in the interface
$ifi  "%orgTill%" == "enforced" p_price(prods,"conv",t) = 0;
$ifi  "%orgTill%" == "enforced" p_inputprice(inputs,"conv",t) = 0;

$ifi  "%orgTill%" == "off"      p_price(prods,"org",t) = 0;
$ifi  "%orgTill%" == "off"      p_inputprice(inputs,"org",t) = 0;

*
* --- check for reasonsable price (input price > output price for same product)
*     use 0.981 instead of 0.98 to ignore slightly less price differences provoked by rounding
*
if (sum((inputs,prods,sys,t) $ ((sameas(prods,inputs))
              $p_InputPrice(inputs,sys,t)
              $p_price(prods,sys,t)
              $$iftheni.cows "%cowHerd%"=="true"
              $(not sameas(inputs,"YoungCow"))
              $sum(heifsbought, (not sameas(inputs,heifsBought)))
              $$endif.cows
            $$iftheni.beef "%farmBranchBeef%"=="on"
              $ sum(bullsbought, (not sameas(inputs,bullsBought)))
            $$endif.beef
      $((p_price(prods,sys,t)/p_InputPrice(inputs,sys,t)) gt 0.981))
                                                                    ,1),
  p_price(prods,sys,t) $(p_price(prods,sys,t)
            $sum(inputs $ (sameas(prods,inputs)
                 $p_InputPrice(inputs,sys,t)
                   $((p_price(prods,sys,t)/p_InputPrice(inputs,sys,t)) le 0.98)),1)) = 0;

  p_price(prods,sys,t) $ ((not sum(inputs $ (sameas(prods,inputs)), p_InputPrice(inputs,sys,t)))) = 0;

abort "Differences between input and output price less than 2% in: %system.fn%, line: %system.incline%",p_price%L%;

);
