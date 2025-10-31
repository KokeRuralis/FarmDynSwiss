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

$iftheni.FO "%scenType%"=="Fertilizer Directive"


      p_meta("base","red0","profit","base",scen)        = p_res("base","red0","fte","sum","","mean");
      p_meta("base","red0",crops      ,"base",scen)     = p_res("base","red0",crops,"levl","","mean");

*
*     ---- Load relevant parameters for compliance costs with Fertilization Ordiance
*

*     ---- Load profit difference from FD (other experiment)

      p_meta("base","red0","profitDiff","base",scen)     =  p_res("base","red0","profitDiff","sum","","mean");
      p_meta("base","red0","GMDiffOut","base",scen)      =  p_res("base","red0","GMDiffOut","sum","","mean") ;


*     ---- Get variables for run under FO 07 and FO 17 to asses compliance strategies

      p_meta("base","red0","StrawEx_07","base",scen)   =  p_res("base","red0","StrawEx_07","sum","","mean");
      p_meta("base","red0","StrawEx_17","base",scen)   =  p_res("base","red0","StrawEx_17","sum","","mean");

      p_meta("base","red0","ManSpread_07","base",scen) =   p_res("base","red0","ManSpread_07","sum","","mean") ;
      p_meta("base","red0","ManSpread_17","base",scen) =   p_res("base","red0","ManSpread_17","sum","","mean") ;

      p_meta("base","red0","ManShoe_07","base",scen)   =   p_res("base","red0","ManShoe_07","sum","","mean")  ;
      p_meta("base","red0","ManShoe_17","base",scen)   =   p_res("base","red0","ManShoe_17","sum","","mean")  ;

      p_meta("base","red0","ManHose_07","base",scen)   =    p_res("base","red0","ManHose_07","sum","","mean")  ;
      p_meta("base","red0","ManHose_17","base",scen)   =    p_res("base","red0","ManHose_17","sum","","mean")  ;

      p_meta("base","red0","ManInj_07","base",scen)    =    p_res("base","red0","ManInj_07","sum","","mean")   ;
      p_meta("base","red0","ManInj_17","base",scen)    =    p_res("base","red0","ManInj_17","sum","","mean")   ;

      p_meta("base","red0","StorageCap_07","base",scen)      =     p_res("base","red0","StorageCap_07","sum","","mean")  ;
      p_meta("base","red0","StorageCap_17","base",scen)      =     p_res("base","red0","StorageCap_17","sum","","mean")  ;

      p_meta("base","red0","CatchCrop_07","base",scen)       =     p_res("base","red0","CatchCrop_07","sum","","mean")  ;
      p_meta("base","red0","CatchCrop_17","base",scen)       =     p_res("base","red0","CatchCrop_17","sum","","mean")  ;


$iftheni.f "%farmBranchFattners%" == "on"
      p_meta("base","red0","AnimProd_07","base",scen)        =     p_res("base","red0","AnimProd_07","sum","","mean")  ;
      p_meta("base","red0","AnimProd_17","base",scen)        =     p_res("base","red0","AnimProd_17","sum","","mean")  ;

      p_meta("base","red0","MinFuNPred_07","base",scen)      =     p_res("base","red0","MinFuNPred_07","sum","","mean")  ;
      p_meta("base","red0","MinFuNPred_17","base",scen)      =     p_res("base","red0","MinFuNPred_17","sum","","mean")  ;

      p_meta("base","red0","MinFuHighNPred_07","base",scen)  =     p_res("base","red0","MinFuHighNPred_07","sum","","mean")   ;
      p_meta("base","red0","MinFuHighNPred_17","base",scen)  =     p_res("base","red0","MinFuHighNPred_17","sum","","mean")   ;
$endif.f

$iftheni.dairy %Dairyherd% == true
      p_meta("base","red0","AnimProd_07","base",scen)        =     p_res("base","red0","AnimProd_07","sum","","mean")   ;
      p_meta("base","red0","AnimProd_17","base",scen)        =     p_res("base","red0","AnimProd_17","sum","","mean")   ;
$endif.dairy

*     ---- Load fertilizer management specifc values, for FO 07 and FO 17, respectively

      p_meta("base","red0","NSurplus_07","base",scen)     =     p_res("base","red0","NSurplus_07","sum","","mean")     ;
      p_meta("base","red0","NSurplus_17","base",scen)     =     p_res("base","red0","NSurplus_17","sum","","mean")     ;

      p_meta("base","red0","PSurplus_07","base",scen)     =     p_res("base","red0","PSurplus_07","sum","","mean")     ;
      p_meta("base","red0","PSurplus_17","base",scen)     =     p_res("base","red0","PSurplus_17","sum","","mean")     ;

      p_meta("base","red0","Norg170_07","base",scen)      =     p_res("base","red0","Norg170_07","sum","","mean")       ;
      p_meta("base","red0","Norg170_17","base",scen)      =     p_res("base","red0","Norg170_17","sum","","mean")       ;

      p_meta("base","red0","NminFert_07","base",scen)     =     p_res("base","red0","NminFert_07","sum","","mean")      ;
      p_meta("base","red0","NminFert_17","base",scen)     =     p_res("base","red0","NminFert_17","sum","","mean")      ;

      p_meta("base","red0","PminFert_07","base",scen)     =     p_res("base","red0","PminFert_07","sum","","mean")      ;
      p_meta("base","red0","PminFert_17","base",scen)     =     p_res("base","red0","PminFert_17","sum","","mean")      ;

      p_meta("base","red0","NneedMin_07","base",scen)     =     p_res("base","red0","NneedMin_07","sum","","mean")    ;
      p_meta("base","red0","NneedMin_17","base",scen)     =     p_res("base","red0","NneedMin_17","sum","","mean")    ;

      p_meta("base","red0","PneedMin_07","base",scen)     =     p_res("base","red0","PneedMin_07","sum","","mean")    ;
      p_meta("base","red0","PneedMin_17","base",scen)     =     p_res("base","red0","PneedMin_17","sum","","mean")    ;

      p_meta("base","red0","ManVolApl_07","base",scen)    =     p_res("base","red0","ManVolApl_07","sum","","mean")   ;
      p_meta("base","red0","ManVolApl_17","base",scen)    =     p_res("base","red0","ManVolApl_17","sum","","mean")   ;

      p_meta("base","red0","ManExport_07","base",scen)    =     p_res("base","red0","ManExport_07","sum","","mean")   ;
      p_meta("base","red0","ManExport_17","base",scen)    =     p_res("base","red0","ManExport_17","sum","","mean")   ;

      p_meta("base","red0","StockDen_07","base",scen)     =     p_res("base","red0","StockDen_07","sum","","mean")   ;
      p_meta("base","red0","StockDen_17","base",scen)     =     p_res("base","red0","StockDen_17","sum","","mean")   ;

      p_meta("base","red0","NQuotNeed_07","base",scen)    =     p_res("base","red0","NQuotNeed_07","sum","","mean")  ;
      p_meta("base","red0","NQuotNeed_17","base",scen)    =     p_res("base","red0","NQuotNeed_17","sum","","mean")  ;

      p_meta("base","red0","NQuotAppl_07","base",scen)    =     p_res("base","red0","NQuotAppl_07","sum","","mean")   ;
      p_meta("base","red0","NQuotAppl_17","base",scen)    =     p_res("base","red0","NQuotAppl_17","sum","","mean")   ;




$else.FO

*
*     --- filter out results of interest: profits
*
      p_meta("base","red0","margLand","base",scen)      = p_res("base","red0","margLand","sum","","mean");
      p_meta("base","red0","margArab","base",scen)      = p_res("base","red0","margArab","sum","","mean");
      p_meta("base","red0","margGras","base",scen)      = p_res("base","red0","margGras","sum","","mean");
      p_meta("base","red0","herdRand","base",scen)      = p_res("base","red0","herdRand","sum","","mean");
      p_meta("base","red0","cropRand","base",scen)      = p_res("base","red0","cropRand","sum","","mean");
      p_meta("base","red0","profit","base",scen)        = p_res("base","red0","fte","sum","","mean");
      p_meta("base","red0","hcon","base",scen)          = p_res("base","red0","hcon","sum","","mean");
      p_meta("base","red0","inv","base",scen)           = p_res("base","red0","inv","sum","","mean");
      p_meta("base","red0","sfprem","base",scen)        = p_res("base","red0","sfprem","sum","","mean");
      p_meta("base","red0",crops      ,"base",scen)     = p_res("base","red0",crops,"levl","","mean");
      p_meta("base","red0",prodsYearly,"base",scen) $ p_res("base","red0",prodsYearly,"SQuant","","mean")   =  p_res("base","red0",prodsYearly,"SQuant","","mean");
      p_meta("base","red0","animRev","base",scen)       = p_res("base","red0","animRev","sum","","mean");
      p_meta("base","red0","cropRev","base",scen)       = p_res("base","red0","cropRev","sum","","mean");
      p_meta("base","red0","cropCost","base",scen)      = p_res("base","red0","vCost","crops","","mean");
      p_meta("base","red0","cashCropCost","base",scen)  = p_res("base","red0","vCost","cashCrops","","mean");
      p_meta("base","red0","intRev","base",scen)        = p_res("base","red0","intRev","sum","","mean");
      p_meta("base","red0","rentRev","base",scen)       = p_res("base","red0","rentRev","sum","","mean");
      p_meta("base","red0",inputs,"base",scen) $ (not sum(sameas(prodsYearly,inputs),1)) = p_res("base","red0",inputs,"quant","","mean");
*
*     --- copy inputs under other name which have the same name as an outpu
*
      p_meta("base","red0","WinterWheatF","base",scen)          = p_res("base","red0","winterWheat","quant","","mean");
      p_meta("base","red0","SummerCereF","base",scen)          = p_res("base","red0","SummerCere","quant","","mean");
      p_meta("base","red0","WinterBarleyF","base",scen)        = p_res("base","red0","WinterBarley","quant","","mean");
      p_meta("base","red0","MaizCCMF","base",scen)             = p_res("base","red0","MaizCCM","quant","","mean");

      p_meta("base","red0","inv","base",scen)           = p_res("base","red0","sumInv","sum","","mean");
      p_meta("base","red0","oilsP","bas",scen)  $ p_res("base","red0","oilsForFeed","quant","","mean")
               = p_res("base","red0","oilsForFeed","sum","","mean")/p_res("base","red0","oilsForFeed","quant","","mean");
      p_meta("base","red0","VCostO","base",scen)        = p_res("base","red0","VCostO","sum","","mean");
      p_meta("base","red0","wage","base",scen)          = smax(workType, p_res("base","red0",workType,"wage","","%firstYear%"));
*
*     ---- load offfarms hours and related wage rate
*
      p_meta("base","red0",landType,"base",scen)        = p_res("base","red0","totLand",landType,"","mean");

*
*     ---- load offfarms hours and related wage rate
*
      p_meta("base","red0","offFarmQ","base",scen)      = p_res("base","red0","offFarm","hours","","mean");
      p_meta("base","red0","offFarmP","base",scen) $ p_meta("base","red0","offFarmQ","base",scen)
           = p_res("base","red0","offFarm","earn","","mean") / p_meta("base","red0","offFarmQ","base",scen);

*

$endif.FO
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
