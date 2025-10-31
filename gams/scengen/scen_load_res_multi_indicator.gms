********************************************************************************
$ontext

   FARMDYN project

   GAMS file : SCEN_LOAD_RES_PROFITS.GMS

   @purpose  : Load results from MAC experiments
   @author   : Wolfgang Britz
   @date     : 04.11.13
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : scen_gen.gms

$offtext
********************************************************************************


*p_meta("base","red0",herds,prods,scen) = sum(breeds, p_res("base","red0",herds,prods,breeds,"mean")) ;

*p_meta("base","red0","levl",prods,scen)$sum(beefout$sameas(beefout,prods),1) = p_res("base","red0",prods,"Price","","mean");

*
*     --- Crop summary
*
* Area and yield
p_meta("base","red0","levl",crops,scen)  = p_res("Base","red0",crops,"levl","","mean");
p_meta("base","red0","yield",crops,scen) = p_res("Base","red0",crops,"yield","","mean");

* Fertilizer application
p_meta("base","red0","NmanAplHa",crops,scen) = p_res("Base","red0",crops,"NmanAplHa","","mean");
p_meta("base","red0","PmanAplHa",crops,scen) = p_res("Base","red0",crops,"PmanAplHa","","mean");
p_meta("base","red0","NGrazHa",crops,scen)   = p_res("Base","red0",crops,"NGrazHa","","mean");
p_meta("base","red0","PGrazHa",crops,scen)   = p_res("Base","red0",crops,"PGrazHa","","mean");
p_meta("base","red0","NMin",crops,scen)      = p_res("Base","red0",crops,"NMin","","mean");
p_meta("base","red0","PMin",crops,scen)      = p_res("Base","red0",crops,"PMin","","mean");

*
*     --- Herd summary
*
$$iftheni.h %herd% == true
$$ifthen.dairy %cowherd% == true
    p_meta("base","red0","sumHerdCows",breeds,scen)       = p_res("base","red0","sumHerdCows","Quant",Breeds,"mean");
    p_meta("base","red0","sumHerdheifs",breeds,scen)      = p_res("base","red0","sumHerdheifs","Quant",Breeds,"mean");
    p_meta("base","red0","sumHerdremonte","base",scen)    = p_res("base","red0","sumHerdremonte","Quant","%basBreed%","mean");
    p_meta("base","red0","sumHerdfCalvsRais",breeds,scen) = p_res("base","red0","sumHerdfCalvsRais","Quant",Breeds,"mean");
    p_meta("base","red0","sumHerdMothercows",breeds,scen) = p_res("base","red0","sumHerdMothercows","Quant",Breeds,"mean");
    p_meta("base","red0","sumHerdremonte","base",scen)    = p_res("base","red0","sumHerdremonte","Quant","%motherCowBreed%","mean");
    p_meta("base","red0","sumHerdmCalvsRais",breeds,scen) = p_res("base","red0","sumHerdmCalvsRais","Quant",Breeds,"mean");
    p_meta("base","red0","sumHerdfCalvsSold",breeds,scen) = p_res("base","red0","sumHerdfCalvsSold","Quant",Breeds,"mean");
    p_meta("base","red0","sumHerdmCalvsSold",breeds,scen) = p_res("base","red0","sumHerdmCalvsSold","Quant",Breeds,"mean");
    p_meta("base","red0","sumHerdheifsSold",breeds,scen)  = p_res("base","red0","sumHerdheifsSold","Quant",Breeds,"mean");
    p_meta("base","red0","sumHerdoldcow",breeds,scen)     = p_res("base","red0","sumHerdoldcow","Quant","","mean");
$$endif.dairy
$$iftheni.beef "%farmBranchBeef%"=="on"
    p_meta("base","red0","sumHerdBulls",breeds,scen) = p_res("base","red0","sumHerdBulls","Quant",Breeds,"mean");
    p_meta("base","red0","sumHerdBullsSold",breeds,scen) = p_res("base","red0","sumHerdBullsSold","Quant",Breeds,"mean");
$$endif.beef
    p_meta("base","red0","LUtot","base",scen)   = p_res("base","red0","LUtot","Quant","","mean");
    p_meta("base","red0","LUperha","base",scen) = p_res("base","red0","LUperha","Quant","","mean");
$$endif.h

*
*     --- Economic Indicators
*
* profit
 p_meta("base","red0","profit","base",scen) = p_res("Base","red0","profit","sum","","mean");
* Income
 p_meta("base","red0","income","base",scen) = p_res("Base","red0","income","sum","","mean");
* Sales revenues
 p_meta("base","red0","SalesRevenue","base",scen) =  p_res("Base","red0","SalesRevenue","sum","","mean");
 p_meta("base","red0","cropRev","base",scen)      =  p_res("Base","red0","cropRev","sum","","mean");
 p_meta("base","red0","cattleRev","base",scen)    =  p_res("base","red0","cattleRev","sum","","mean");
 p_meta("base","red0","beefRev","base",scen)      =  p_res("base","red0","beefRev","sum","","mean");
 p_meta("base","red0","milkRev","base",scen)      =  p_res("Base","red0","milkRev","sum","","mean") ;
 p_meta("base","red0","calvRev","base",scen)      =  p_res("base","red0","calvRev","sum","","mean");

* Subsidies
 p_meta("Base","red0","sfPrem","base",scen)  = p_res("Base","red0","sfPrem","sum","","mean") ;
 p_meta("Base","red0","dirPaym","base",scen) = p_res("Base","red0","dirPaym","sum","","mean");
 p_meta("Base","red0","coupSup","base",scen) = p_res("Base","red0","coupSup","sum","","mean");

* Interest gained
 p_meta("Base","red0","intGain","base",scen) = p_res("Base","red0","intGain","sum","","mean");

* Variable Costs
 p_meta("Base","red0","sumVarCost","base",scen)  = p_res("Base","red0","sumVarCost","sum","","mean");
* Variable costs from buying inputs
 p_meta("Base","red0","inputCost","base",scen)     = p_res("Base","red0","inputCost","sum","","mean");
 p_meta("Base","red0","feedBuyCost","base",scen)   = p_res("Base","red0","feedBuyCost","sum","","mean");
 p_meta("Base","red0","syntfertCost","base",scen)  = p_res("Base","red0","syntfertCost","sum","","mean");
 p_meta("Base","red0","phytoSaniCost","base",scen) = p_res("Base","red0","phytoSaniCost","sum","","mean");
* Other variable costs
 p_meta("Base","red0","machCost","base",scen)       = p_res("Base","red0","machCost","sum","","mean");
 p_meta("Base","red0","manCost","base",scen)        = p_res("Base","red0","manCost","sum","","mean");
 p_meta("Base","red0","vcostsActivity","base",scen) = p_res("Base","red0","vcostsActivity","sum","","mean");
 p_meta("Base","red0","buildCost","base",scen)      = p_res("Base","red0","buildCost","sum","","mean");
* interest paid and depreciation
 p_meta("Base","red0","depr","base",scen)    = p_res("Base","red0","depr","sum","","mean")   ;
 p_meta("Base","red0","intPaid","base",scen) = p_res("Base","red0","intPaid","sum","","mean");


*     --- LCA and sLCA
*
p_meta("base","red0",prods,emCat,scen)     =  p_res("base","red0",prods,emCat,"","mean")         ;
p_meta("base","red0",prods,feeds,scen)     =  p_res("base","red0",prods,feeds,"","mean")         ;
p_meta("base","red0",prods,soci,scen)      =  p_res("base","red0",prods,soci,"","mean")          ;


*
*     --- set MACS to -1000 (= Farm exit indicator) if for all reduction levels higher than the current one
*         no cow herd is found after the 3th year
*
     option kill=years;
     years(allYears) $ (calYea(allYears) le p_scenParam(scen,"lastYear") ) = yes;

* p_meta("base","red0","WinterWheatPrice","base",scen)    =   p_res("base","red0","WinterWheat","Price","","mean")   ;
*
*     --- add scen variables to store explanatory vars
*
* p_meta("base","red0","WinterRapePrice","base",scen)     =   p_res("base","red0","WinterRape","Price","","mean")   ;
 p_meta("base","red0",scenItems,"base",scen) $ p_scenParam(scen,scenItems) = p_scenParam(scen,scenItems);



 p_meta("Base","red0","SalesRevenueAlocation","base",scen) = p_res("Base","red0","SalesRevenueAlocation","sum","","mean") ;
 p_meta("Base","red0","profitAllocation","base",scen)      = p_res("Base","red0","profitAllocation","sum","","mean")      ;
 p_meta("Base","red0","sumVarCostAllocation","base",scen)  = p_res("Base","red0","sumVarCostAllocation","sum","","mean")  ;
 p_meta("Base","red0","inputCostAllocation","base",scen)   = p_res("Base","red0","inputCostAllocation","sum","","mean")   ;
 p_meta("Base","red0","sfPremAllocation","base",scen)      = p_res("Base","red0","sfPremAllocation","sum","","mean")      ;
 p_meta("Base","red0","OQuantBeefAllocation","base",scen)  = p_res("Base","red0","OQuantBeefAllocation","sum","","mean")  ;
