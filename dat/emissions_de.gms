********************************************************************************
$ontext

   FarmDyn project

   GAMS file : Emissions_DE.GMS

   @purpose  : Emissions factors for on farm emissions
   @author   :
   @date     : 27.11.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************

* ------------------------------------------------------------------------------
*
*    The first block of emissions factors is needed for the manure module
*    and not only for the environmental accounting
*
* ---------------------------------- https://onlinelibrary.wiley.com/doi/epdf/10.1002/jpln.19631010204


$$iftheni.dh %cattle% == true
*Haenel et al. (2018), p. 108
  parameter p_MCFPast  "methane conversion factor for cattle manure excreted on pastures, 0.01 means 1% of VS excretion"
           /0.01/;

*--- Cattle, partial emission factor for NH3-N from housing (related to TAN) in kg kg-1
*     Haenel et al. (2018), p. 108

   $$iftheni.cattle "%cattle%"=="true"

      p_EFSta("NH3","LiquidCattle")       = 0.197;
      $$iftheni.straw "%strawManure"=="true"
    p_EFSta("NH3","SolidCattle")        = 0.197;
    p_EFSta("NH3","LightLiquidCattle")  = 0.197;
      $$endif.straw

*--- Cattle, partial emission factor for NH3-N from storage (related to TAN) in kg kg-1
*     Haenel et al. (2018), p. 109

      p_EFSto("NH3","LiquidCattle")       = 0.15;
      $$iftheni.straw "%strawManure"=="true"
    p_EFSto("NH3","SolidCattle")        = 0.15;
    p_EFSto("NH3","LightLiquidCattle")  = 0.15;
      $$endif.straw

*--- Cattle, partial emission factors for direct N2O-N from housing and storage applied to total N in system in kg kg-1
*     Haenel et al. (2018) p. 110

      p_EFStaSto("N2O","LiquidCattle")       =   0.005;
      $$iftheni.straw "%strawManure"=="true"
    p_EFStaSto("N2O","SolidCattle")        =   0.01 ;
    p_EFStaSto("N2O","LightLiquidCattle")  =   0.005;
      $$endif.straw

   $$endif.cattle

*--- Stable and Storage: NO losses  (Haenel et al. (2018) p. 54)
    p_EFStaSto("NOx",manChain)    =   0.1 * p_EFStaSto("N2O",manChain);

*--- Stable and Storage: N2 losses (Haenel et al. (2018) p. 54)
    p_EFStaSto("N2",manChain)     =   3  * p_EFStaSto("N2O",manChain);

*--- Pasture: NH3 losses (Haenel et al. (2018) p.137 /EMEP(2013): 3B , pp. 27)
    p_EFpasture("NH3")   =   0.1 ;

*--- Pasture: N2O direct losses (Haenel et al. (2018) p. 332; IPCC (2006) 11.11, table 11.1)
    p_EFpasture("N2O")   =   0.02 ;

*--- Pasture: NO  losses (Haenel et al. (2018) p. 332, STEHFEST UND BOUWMAN (2006)
    p_EFpasture("NOx")   =   0.012;

*--- Pasture: N2  losses ( R�semann et al. 2015, pp. 324) (depreciated?)
    p_EFpasture("N2")    =   0.14;

$$endif.dh

$$iftheni.pig %pigherd% == true

*  --- Stable: NH3 losses (R�semann et al. 2015 pp. 180)

   $$ifi "%farmBranchSows%"        == "on"      p_EFSta("NH3","liquidPig")       =  0.34;
   $$ifi "%farmBranchfattners%"    == "on"      p_EFSta("NH3","liquidPig")       =  0.3 ;

*  --- Storage: NH3 losses (Haenel et al. (2018) p.187)
   p_EFSto("NH3","liquidPig")       =  0.105;

*  --- Stable and Storage: N2O losses (Haenel et al. 2015 pp. 188)
   p_EFStaSto("N2O","liquidPig")    =  0.005 ;

*  --- Stable and Storage: NO losses  (Haenel et al. 2015 pp. 188)
   p_EFStaSto("NOx","liquidPig")    = 0.1 *  p_EFStaSto("N2O","liquidPig") ;

*  --- Stable and Storage: N2 losses (Haenel et al. 2015 pp. 188)
   p_EFStaSto("N2","liquidPig")     = 3 * p_EFStaSto("N2O","liquidPig")  ;

$endif.pig

$$iftheni.manure %manure% == true

$$iftheni.herd not "%herd%"=="true"

*   --- Stable: NH3 losses  (R�semann et al. 2015 pp. 47, 10, 103)
    p_EFSta("NH3",manChain)       = 0.197;

*   --- Storage: NH3 losses (R�semann et al. 2015 pp. 47, 10, 103)
    p_EFSto("NH3",manChain)       = 0.105;

*   --- Stable and Storage: N2O losses (R�semann et al. 2015, pp. 104)
    p_EFStaSto("N2O",manChain)    =   0.005 ;

*   --- Stable and Storage: NO losses  (R�semann et al. 2015, pp. 104)
    p_EFStaSto("NOx",manChain)    =   0.1 * p_EFStaSto("N2O",manChain);

*   --- Stable and Storage: N2 losses (R�semann et al. 2015, pp. 104)
    p_EFStaSto("N2",manChain)     =   3  * p_EFStaSto("N2O",manChain);
$$endif.herd



  p_lossFactorSto(mantype,"NTAN",manChain)   =    p_EFSta("NH3",manchain)    + p_efsto("NH3",manChain)    + p_EFStaSto("N2O",manChain) + p_EFStaSto("NOx",manChain) + p_EFStaSto("N2",manChain);
  p_lossFactorSto(mantype,"Norg",manChain)   =    p_EFStaSto("N2O",manChain) + p_EFStaSto("NOx",manChain) + p_EFStaSto("N2",manChain) ;

* --- For digestates from biogas, different loss factors are defined

* --- HIGH manure content means MINIMAL losses

  $$iftheni.biogas %biogas% == true
      p_lossFactorSto(mantype,"NTAN",manChain)  $ digestate(mantype)  =    p_EFStaSto("N2O",manChain) + p_EFStaSto("NOx",manChain) + p_EFStaSto("N2",manChain) ;
      p_lossFactorSto(mantype,"Norg",manChain)  $ digestate(mantype)  =    p_EFStaSto("N2O",manChain) + p_EFStaSto("NOx",manChain) + p_EFStaSto("N2",manChain) ;
  $$endif.biogas
*
* --- Factors to calculate NH3 loss from application, enters equations on fertilizing and environmental accounting
*
*     Assumptions for slurry that in months where no crops are grown, manure is incorporated in 8 h for spreading and tail hose, except for FO 2017 which
*     prescribes incorporation of 4 hours
*

  $$iftheni.dh %cattle% == true

*     --- NH3-N emission factors for application of slurry and digested manure (related to TAN) in kg kg-1  Haenel et al. (2018), pp. 111

      p_EFapplMan(grasscrops(crops),manType,"applSpreadCattle","NTAN",m) $ manApplicType_manType("applSpreadCattle",manType) = 0.6  ;
      p_EFapplMan(grasscrops(crops),manType,"applTailhCattle","NTAN",m)  $ manApplicType_manType("applTailhCattle",manType)  = 0.54 ;
      p_EFapplMan(grasscrops(crops),manType,"applInjecCattle","NTAN",m)  $ manApplicType_manType("applInjecCattle",manType)  = 0.24 ;
      p_EFapplMan(grasscrops(crops),manType,"applTShoeCattle","NTAN",m)  $ manApplicType_manType("applTShoeCattle",manType)  = 0.36 ;

      p_EFapplMan(arablecrops(crops),manType,"applInjecCattle","NTAN",m) $ manApplicType_manType("applInjecCattle",manType)   = 0.24 ;
      p_EFapplMan(arablecrops(crops),manType,"applTShoeCattle","NTAN",m) $ manApplicType_manType("applTShoeCattle",manType)   = 0.36 ;

      p_EFapplMan(arablecrops(crops),manType,"applSpreadCattle","NTAN",m) $ (sum(sys, monthGrowthCrops(crops,sys,m)) $ manApplicType_manType("applSpreadCattle",manType))  = 0.5  ;
      p_EFapplMan(arablecrops(crops),manType,"applTailhCattle","NTAN",m)  $ (sum(sys, monthGrowthCrops(crops,sys,m)) $ manApplicType_manType("applTailhCattle",manType))   = 0.46 ;

      p_EFapplMan(arablecrops(crops),manType,"applSpreadCattle","NTAN",m) $ (sum(sys, (not monthGrowthCrops(crops,sys,m)))$ manApplicType_manType("applSpreadCattle",manType)) = 0.40 ;
      p_EFapplMan(arablecrops(crops),manType,"applTailhCattle","NTAN",m)  $ (sum(sys, (not monthGrowthCrops(crops,sys,m)))$ manApplicType_manType("applTailhCattle",manType))  = 0.24 ;

*     --- NH3 losses from solid manure application Haenel et al. (2018) p.112

      $$iftheni.straw "%strawManure%"=="true"
      p_EFapplMan(arablecrops(crops),manType,"applSolidSpread","NTAN",m) $ manApplicType_manType("applSolidSpread",manType)  = 0.9 ;
      p_EFapplMan(grasscrops(crops),manType,"applSolidSpread","NTAN",m)  $ manApplicType_manType("applSolidSpread",manType)  = 0.9 ;

*     --- NH3 losses liquid manure application Haenel et al. (2018) p.111
      p_EFapplMan(grasscrops(crops),manType,"applSpreadLightCattle","NTAN",m) $ manApplicType_manType("applSpreadLightCattle",manType) = 0.2  ;
      p_EFapplMan(grasscrops(crops),manType,"applTailhLightCattle","NTAN",m)  $ manApplicType_manType("applTailhLightCattle",manType)  = 0.14 ;
      p_EFapplMan(grasscrops(crops),manType,"applInjecLightCattle","NTAN",m)  $ manApplicType_manType("applInjecLightCattle",manType)  = 0.04 ;
      p_EFapplMan(grasscrops(crops),manType,"applTShoeLightCattle","NTAN",m)  $ manApplicType_manType("applTShoeLightCattle",manType)  = 0.08 ;
      p_EFapplMan(arablecrops(crops),manType,"applSpreadLightCattle","NTAN",m)$ manApplicType_manType("applSpreadLightCattle",manType) = 0.2  ;
      p_EFapplMan(arablecrops(crops),manType,"applTailhLightCattle","NTAN",m) $ manApplicType_manType("applTailhLightCattle",manType)  = 0.18 ;
      p_EFapplMan(arablecrops(crops),manType,"applInjecLightCattle","NTAN",m) $ manApplicType_manType("applInjecLightCattle",manType)  = 0.04 ;
      p_EFapplMan(arablecrops(crops),manType,"applTShoeLightCattle","NTAN",m) $ manApplicType_manType("applTShoeLightCattle",manType)  = 0.08 ;
      $$endif.straw
  $$endif.dh


*  --- NH3 losses pig slurry application Haenel et al. (2018) p.189

  $$iftheni.ph %pigherd% == true

      p_EFapplMan(grasscrops(crops),manType,"applSpreadPig","NTAN",m)  $ manApplicType_manType("applSpreadPig",manType)  = 0.3  ;
      p_EFapplMan(grasscrops(crops),manType,"applTailhPig","NTAN",m)   $ manApplicType_manType("applTailhPig",manType)   = 0.21 ;
      p_EFapplMan(grasscrops(crops),manType,"applInjecPig","NTAN",m)   $ manApplicType_manType("applInjecPig",manType)   = 0.06 ;
      p_EFapplMan(grasscrops(crops),manType,"applTShoePig","NTAN",m)   $ manApplicType_manType("applTShoePig",manType)   = 0.12 ;

      p_EFapplMan(arablecrops(crops),manType,"applInjecPig","NTAN",m)  $ manApplicType_manType("applInjecPig",manType)   = 0.06 ;
      p_EFapplMan(arablecrops(crops),manType,"applTShoePig","NTAN",m)  $ manApplicType_manType("applTShoePig",manType)   = 0.12 ;

      p_EFapplMan(arablecrops(crops),manType,"applSpreadPig","NTAN",m) $ (sum(sys, monthGrowthCrops(crops,sys,m)) $ manApplicType_manType("applSpreadPig",manType)) = 0.25 ;
      p_EFapplMan(arablecrops(crops),manType,"applTailhPig","NTAN",m)  $ (sum(sys, monthGrowthCrops(crops,sys,m)) $ manApplicType_manType("applTailhPig",manType))  = 0.175;

      p_EFapplMan(arablecrops(crops),manType,"applSpreadPig","NTAN",m) $ (sum(sys, (not monthGrowthCrops(crops,sys,m)))$ manApplicType_manType("applSpreadPig",manType)) = 0.13 ;
      p_EFapplMan(arablecrops(crops),manType,"applTailhPig","NTAN",m)  $ (sum(sys, (not monthGrowthCrops(crops,sys,m)))$ manApplicType_manType("applTailhPig",manType))  = 0.0925;

  $$endif.ph

*  --- NH3 losses biogas digestate application Haenel et al. (2018) p. 64 (p.111 same as cattle slurry)

  $$iftheni.biogas %biogas% == true

     p_EFapplMan(grasscrops(crops),manType,"applSpreadBiogas","NTAN",m) $ manApplicType_manType("applSpreadBiogas",manType)  = 0.6  ;
     p_EFapplMan(grasscrops(crops),manType,"applTailhBiogas","NTAN",m)  $ manApplicType_manType("applTailhBiogas",manType)   = 0.54 ;
     p_EFapplMan(grasscrops(crops),manType,"applInjecBiogas","NTAN",m)  $ manApplicType_manType("applInjecBiogas",manType)   = 0.24 ;
     p_EFapplMan(grasscrops(crops),manType,"applTShoeBiogas","NTAN",m)  $ manApplicType_manType("applTShoeBiogas",manType)   = 0.36 ;

     p_EFapplMan(arablecrops(crops),manType,"applInjecBiogas","NTAN",m) $ manApplicType_manType("applInjecBiogas",manType)   = 0.24 ;
     p_EFapplMan(arablecrops(crops),manType,"applTShoeBiogas","NTAN",m) $ manApplicType_manType("applTShoeBiogas",manType)   = 0.36 ;

     p_EFapplMan(arablecrops(crops),manType,"applSpreadBiogas","NTAN",m) $ (sum(sys, monthGrowthCrops(crops,sys,m)) $ manApplicType_manType("applSpreadBiogas",manType)) =  0.5  ;
     p_EFapplMan(arablecrops(crops),manType,"applTailhBiogas","NTAN",m)  $ (sum(sys, monthGrowthCrops(crops,sys,m)) $ manApplicType_manType("applTailhBiogas",manType))   =  0.46 ;

     p_EFapplMan(arablecrops(crops),manType,"applSpreadBiogas","NTAN",m) $ (sum(sys, (not monthGrowthCrops(crops,sys,m)))$ manApplicType_manType("applSpreadBiogas",manType)) =  0.40  ;
     p_EFapplMan(arablecrops(crops),manType,"applTailhBiogas","NTAN",m)  $ (sum(sys, (not monthGrowthCrops(crops,sys,m)))$ manApplicType_manType("applTailhBiogas",manType))   =  0.24  ;

  $$endif.biogas

*  --- NH3 losses imported slurry application Haenel et al. (2018) p.189 (same as pig slurry)

  $$iftheni.import "%AllowManureImport%" == "true"

     p_EFapplMan(grasscrops(crops),manType,"applSpreadImport","NTAN",m) $ manApplicType_manType("applSpreadImport",manType)  = 0.3  ;
     p_EFapplMan(grasscrops(crops),manType,"applTailhImport","NTAN",m)  $ manApplicType_manType("applTailhImport",manType)   = 0.21 ;
     p_EFapplMan(grasscrops(crops),manType,"applInjecImport","NTAN",m)  $ manApplicType_manType("applInjecImport",manType)   = 0.06 ;
     p_EFapplMan(grasscrops(crops),manType,"applTShoeImport","NTAN",m)  $ manApplicType_manType("applTShoeImport",manType)   = 0.12 ;

     p_EFapplMan(arablecrops(crops),manType,"applInjecImport","NTAN",m)  $ manApplicType_manType("applInjecImport",manType)  = 0.06 ;
     p_EFapplMan(arablecrops(crops),manType,"applInjecImport","NTAN",m)  $ manApplicType_manType("applInjecImport",manType)  = 0.12 ;

     p_EFapplMan(arablecrops(crops),manType,"applSpreadImport","NTAN",m) $ (sum(sys, monthGrowthCrops(crops,sys,m)) $ manApplicType_manType("applSpreadImport",manType)) = 0.25 ;
     p_EFapplMan(arablecrops(crops),manType,"applTailhImport","NTAN",m)  $ (sum(sys, monthGrowthCrops(crops,sys,m)) $ manApplicType_manType("applTailhImport",manType))   = 0.175;

     p_EFapplMan(arablecrops(crops),manType,"applSpreadImport","NTAN",m)   $ (sum(sys, (not monthGrowthCrops(crops,sys,m)))$ manApplicType_manType("applSpreadImport",manType)) = 0.13 ;
     p_EFapplMan(arablecrops(crops),manType,"applTailhImport","NTAN",m)    $ (sum(sys, (not monthGrowthCrops(crops,sys,m)))$ manApplicType_manType("applTailhImport",manType))  = 0.0925;

  $$endif.import

* --- p_EFapplMan has to be 1 for Norg and P

     p_EFapplMan(crops,manType,manApplicType,nut2,m)
         $ ( (not sameas (nut2,"NTAN")) $  manApplicType_manType(manApplicType,manType) ) = 0 ;

$endif.manure

*
* --- NH3 losses from min fertilizer application, Haenel et al. (2018) p.325. Orginal emission factor is in kg Nh3 not NH3-N, therefore conversion by 14/17

     p_EFApplMinNH3("AHL") = 0.098  * (14/17) ;
     p_EFApplMinNH3("ASS") = 0.0082 * (14/17) ;

* --- N2O from fertilizer application IPCC (2006) 11.11, Haenel et al. (2018) p.326, Stehfest and Bouwman(2006)
*    N2 Roesemann et al. 2015, pp. 316-317
     p_EFApplMin("N2O")  = 0.01 ;
     p_EFApplMin("NOx")  = 0.012;
     p_EFApplMin("N2")   = 0.07 ;


$ifi not "%envAcc%"=="true" $exit

$$iftheni.h %herd% == true
* Haenel et al. (2018) p. 140 Table 4.22, p.145, p. 155, p.168, p.214, p.194 IPCC p.10.30 tab.10.12 values in %
   parameters p_Ym(*,*) " CH4 conversion factor for enteric fermentation";
            p_Ym("dcows","")   = 6.32;
            p_Ym("heifs","")   = 6.5;
            p_Ym("calvs","")   = 4.1;
            p_Ym("bulls","")   = 3;
            p_Ym("mcows","")   = 6.5;
            p_Ym("fatHerd","") = 0.46;
            p_Ym("sows","")    = 0.71 ;
$$endif.h

* --- Emission reduction value for feed additives in the enteric fermentation process
    $$ifi.feedAdd "%feedAddOn%" == true $$batinclude '%datdir%/enforcedMitigation.gms'

$$iftheni.manure %manure% ==true
* Haenel et al. (2018) p.108 and p. 185. Assumption. Biogas behaves like pigslurry
   parameter p_BO(manChain) "Maximum methane producing capacity"
         /
          $$ifi "%pigHerd%"=="true"           LiquidPig            0.3
          $$ifi "%cattle%"=="true"            LiquidCattle         0.23
          $$ifi "%strawManure"=="true"        LightLiquidCattle    0
          $$ifi "%strawManure"=="true"        SolidCattle          0.23
          $$ifi "%biogas%"=="true"            LiquidBiogas         0.3
          $$ifi "%AllowManureImport%"=="true" LiquidImport         0.3
   /;

* Haenel et al. (2018) p.108 and p. 185. Assumption. Biogas behaves like pigslurry
  $$iftheni.pig "%pigHerd%"=="true"
    table p_MCF(manStorage,manChain) " methane conversion factors for each manure management system, 0.17  means 17%"
                  LiquidPig
      storsub       0.25
      stornocov     0.15
      storstraw     0.25
      storfoil      0.25
    ;
  $$endif.pig
  $$iftheni.cattle "%cattle%"=="true"
     table p_MCF(manStorage,manChain) " methane conversion factors for each manure management system, 0.17  means 17%"

                  LiquidCattle
      storsub         0.17
      stornocov       0.1
      storstraw       0.17
      storfoil        0.17
     ;

   $$endif.cattle
   $$iftheni.straw "%strawManure%"=="true"
   $$onmulti
    table p_MCF(manStorage,manChain) " methane conversion factors for each manure management system, 0.17  means 17%"
                  LightLiquidCattle   SolidCattle
      storsub           0                 0.17
      stornocov         0                 0.17
      storstraw         0                 0.17
      storfoil          0                 0.17
      ;
$$offmulti
  $$endif.straw
   $$iftheni.biogas "%biogas%"=="true"
      table p_MCF(manStorage,manChain) " methane conversion factors for each manure management system, 0.17  means 17%"

                  LiquidBiogas
      storsub            0.25
      stornocov          0.25
      storstraw          0.25
      storfoil           0.25

     ;
   $$endif.biogas
   $$iftheni.import "%AllowManureImport%"=="true"
$$onmulti
     table p_MCF(manStorage,manChain) " methane conversion factors for each manure management system, 0.17  means 17%"
                   LiquidImport
      storsub           0.25
      stornocov         0.25
      storstraw         0.25
      storfoil          0.25
    ;
  $$offmulti
  $$endif.import

* KTBL-Schrift 502 p.2
  parameter p_avDmMan(manChain) "average dry matter content of cattle manure, 0.11 means 11%"
       /
        $$ifi "%pigHerd%"=="true"           LiquidPig               0.054
        $$ifi "%cattle%"=="true"            LiquidCattle            0.091
        $$ifi "%strawManure"=="true"        LightLiquidCattle       0.0
        $$ifi "%strawManure"=="true"        SolidCattle             0.25
        $$ifi "%biogas%"=="true"            LiquidBiogas            0.06
        $$ifi "%AllowManureImport%"=="true" LiquidImport            0.054
      /;

* KTBL-Schrift 502 p.2
  parameter p_oTSMan(manChain) "share of volatile solids(organische Trockensubstanz) as share of total dry matter"
      /
       $$ifi "%pigHerd%"=="true"           LiquidPig               0.74
       $$ifi "%cattle%"=="true"            LiquidCattle            0.8
       $$ifi "%strawManure"=="true"        LightLiquidCattle       0.0
       $$ifi "%strawManure"=="true"        SolidCattle             0.85
       $$ifi "%biogas%"=="true"            LiquidBiogas            0.72
       $$ifi "%AllowManureImport%"=="true" LiquidImport            0.74
      /;

* IPCC 2006 p.10.41
  parameter p_densM "denisty of methane in kg/m3";
      p_densM = 0.67;

$endif.manure


*--  indirect N2O losses IPCC(2006)-11.24, Table 11.3. ( Haenel et al. (2018) , p. 56)
   p_EFN2Oind    =   0.01;

*--  indirect N2O losses from leached N ( Haenel et al. (2018) , p. 365 and IPCC (2006) Table 11.24 table 11.3)
   p_EFN2OindLeach    =   0.0075;


*  --- CO2 emission from the application of lime IPCC (2006) 11.27
*      100/56 for consideration of CaO in CaCO3 (assumption is that liming is done with limestone only) and 44/12 to transform from CO2-C to CO2 weight
*      times 1000 to change from t/t to kg/t (only for limestone) 0,5 is the cao share of total weight
   p_EFlime("lime") = 0.12 * (100/56) * 44/12 * 1000 * 0.5;
*   p_EFlime("KAS")  = 0.12  * (0.128/0.27) * p_nutInSynt("KAS","N") * 44/12 ;


*  --- Diesel (Source KTBL - Klimabilanz Webanwendung) - Production & Combustion - Production
   p_EFDiesel("Diesel") = 3.013-0.349;


*  --- Table of input data for calculation of N2O emissions from crop residues
*       assumption maizcorn is same as CCM wheatccm is wheat DÜNGEVERORDNUNG(2007, Anlage 1, Tabelle 1), IPCC(2006)-11.17


parameter p_cropResi(crops,resiEle);

$$GDXIN "%datDir%/%cropsFile%.gdx"
$LOAD p_cropResi
$$GDXIN

   p_cropResi(grassCrops,"duration")$(not sameas(grassCrops,"idlegras")) = 0.1   ;
   p_cropResi(grassCrops,"DMyield") $(not sameas(grassCrops,"idlegras")) = 0.2   ;
   p_cropResi(grassCrops,"DMresi")  $(not sameas(grassCrops,"idlegras")) = 0.2   ;
   p_cropResi(grassCrops,"aboveRat")$(not sameas(grassCrops,"idlegras")) = 0.3   ;
   p_cropResi(grassCrops,"aboveN")  $(not sameas(grassCrops,"idlegras")) = 0.005 ;
   p_cropResi(grassCrops,"belowRat")$(not sameas(grassCrops,"idlegras")) = 0.8   ;
   p_cropResi(grassCrops,"belowN")  $(not sameas(grassCrops,"idlegras")) = 0.012 ;

***********************************************************************************
* --- Parameters for calculation of P losses (SALCA Phophor; Prasuhn 2006)
***********************************************************************************

* --- Average soil loss per year in kg per ha
   p_erosion = 3;

* --- share of eroded soil reaching surface waters
   p_lossfactor = 0.2;

* --- P content of the eroded soil in kg P per t
   p_PContSoil = 0.950;

* --- P accumaulation in eroded soil
   p_PAccuSoil = 1.86;

* --- Average amount of P lost htrough leaching
   p_PLossLeach("grass")    = 0.06;
   p_PLossLeach("arable")   = 0.07;
   p_PLossLeach("idle")     = 0.05;
   p_PLossLeach("idleGras") = 0.05;

* --- Correction factor for P leaching for soil types
   p_soilFactleach = 1;

* --- Correction factor for P content classes
   p_PSoilClass = 1;

* --- P fertilization factor
   p_PLossFert("low")    = (1.2-1)/(80-0);
   p_PLossFert("medium") = (1.4-1)/(80-0);
   p_PLossFert("high")   = (1.7-1)/(80-0);

* --- Average amount of P lost through run off
   p_PLossRun("grass")     =0.25;
   p_PLossRun("arable")    =0.175;
   p_PLossRun("idle")      =0.1;
   p_PLossRun("idleGrass") =0.1;

* --- Correction factor for P leaching for soil types
   p_soilFactRun = 1;

* --- Correction factor for P leaching for slope of fields
   p_slopeFactor = 1;

***********************************************************************************
* --- Parameters for N leachign losses (SACLA NITRAT; Richner 2016)
***********************************************************************************
*  ---  Leaching factor for fertilization from Richner (2014) p.20
*       For several crops values are missing (e.g. catchcrops, vegetables, fodder crops)
*       these values are, however, included in the non-public Exceltool and could possibly be requested if necessary

   $$GDXIN "%datDir%/%cropsFile%.gdx"
      $$LOAD p_EfLeachFert
   $$GDXIN


$ifthen.grasAttr defined p_grasAttr

*  ---  Lea1hing factor for fertilization on cut grasland from personal communication with Nemecek(Agroscope)
    p_EfLeachFert(gras,"JAN") =   0.2;
    p_EfLeachFert(gras,"FEB") $(sum((grasOutputs,m),p_grasAttr(gras,grasOutputs,m))>6)  =   0.1;
    p_EfLeachFert(gras,"FEB") $(sum((grasOutputs,m),p_grasAttr(gras,grasOutputs,m))<=6) =   0.2;
    p_EfLeachFert(gras,"NOV") $(sum((grasOutputs,m),p_grasAttr(gras,grasOutputs,m))>6)  =   0.1;
    p_EfLeachFert(gras,"NOV") $(sum((grasOutputs,m),p_grasAttr(gras,grasOutputs,m))<=6) =   0.2;
    p_EfLeachFert(gras,"DEC") =   0.2;

$endif.grasAttr



*  ---  Leaching from mineralization from Richner (2014) p.12
  parameter p_LeachNorm(m)
     /JAN   0
      FEB   0
      MAR   5.8
      APR   9.1
      MAY  11.6
      JUN  14.9
      JUL  17.4
      AUG  20.7
      SEP  23.2
      OCT  11.6
      NOV   5.8
      DEC   0/;


*  ---  Extra mineralization from month with intense cultivation in kg N per ha; Richner (2014) p.19
  parameter p_CfNLeachTill(m)
  / JAN          0
    FEB          0
    MAR          4
    APR          6
    MAY          8
    JUN         10
    JUL         12
    AUG         17
    SEP         15
    OCT          8
    NOV          4
    DEC          0/;


* --- Correction of Mineralisation of Legumes, 6 month after Legumes (only for month where mneralisation appears)

   $$GDXIN "%datDir%/%cropsFile%.gdx"
      $$LOAD p_MonthAfterLeg
   $$GDXIN


*  ---  correction factor for reduced mineralization under grassland Richner (2014)


   parameter p_CfNLeachGrass(crops);
$ifthen.grasAttr defined p_grasAttr

     p_CfNLeachGrass(grassCrops) $(sum((grasOutputs,m),p_grasAttr(grassCrops,grasOutputs,m))<=6) = 2.24 * 12;
     p_CfNLeachGrass(grassCrops) $(sum((grasOutputs,m),p_grasAttr(grassCrops,grasOutputs,m))>6)  = 1.72 * 12;
     p_CfNLeachGrass(grassCrops) $(sum((grasOutputs,m),p_grasAttr(grassCrops,grasOutputs,m))>10)  = 1.2 * 12;

$else.grasattr
     option kill=p_CfnLeachGrass;
$endif.grasattr


*  --- leaching factor for grazing Richner (2014)

   parameter p_leachPast(m)
      /JAN    0.078
       FEB    0.069
       MAR    0.069
       APR    0.051
       MAY    0.051
       JUN    0.051
       JUL    0.051
       AUG    0.051
       SEP    0.051
       OCT    0.069
       NOV    0.078
       DEC    0.078/;


**********************************************************************************
* Data for derivation of humus balance
**********************************************************************************


*  ---  Humus degradation through crop cultivation LFL Exceltool nach VDLUFA (2014)
*       https://www.lfl.bayern.de/mam/cms07/iab/dateien/humusbilanz_59_fruchtfolge_10_2015.xls


   $$GDXIN "%datDir%/%cropsFile%.gdx"
      $$LOAD p_humCrop
   $$GDXIN

   p_humCrop(idle) = -180;
   p_humCrop(catchCrops) $ (not p_humCrop(catchCrops)) = -100;
$$ifi defined strips p_humCrop(strips) = -180;

*  ---  Effect of crop residues on humus LFL Exceltool nach VDLUFA (2014)
*       https://www.lfl.bayern.de/mam/cms07/iab/dateien/humusbilanz_59_fruchtfolge_10_2015.xls

   parameter  p_resiInc(crops);
   $$GDXIN "%datDir%/%cropsFile%.gdx"
      $$LOAD  p_resiInc
   $$GDXIN


$iftheni.manure "%manure%"=="true"

*  ---  Humus factor of organic fertilizers LFL Exceltool nach VDLUFA (2014)
    parameter p_humfact(ManApplicType)
       /
      $$iftheni.pig "%pigHerd%"=="true"
        applSpreadPig         5
        applTailhPig          5
        applInjecPig          5
        applTShoePig          5
      $$endif.pig

      $$iftheni.cattle "%cattle%"=="true"
        applSpreadCattle     11
        applTailhCattle      11
        applInjecCattle      11
        applTShoeCattle      11
      $$endif.cattle

      $$iftheni.straw "%strawManure%"=="true"
        applSolidSpread      34
      $$endif.straw

      $$iftheni.biogas "%biogas%"=="true"
        applSpreadBiogas      8
        applTailhBiogas       8
        applInjecBiogas       8
        applTShoeBiogas       8
      $$endif.biogas

     $$iftheni.import "%AllowManureImport%"=="true"
        applSpreadImport      5
        applTailhImport       5
        applInjecImport       5
        applTShoeImport       4
     $$endif.import

       /;

$endif.manure


********************************************************************************
*Particulate matter formation calculation
********************************************************************************

* --- Particulate matter emissions from stable stage in kg emission per year and animal Haenel et al. (2018) p.139,157,165,170,175,197,205,217,365
*TSP:  Total suspended matter
*Pm2,5 and PM10: Particulate matter emission
   $$iftheni.h %herd% ==true

     Table p_EFpmfHerds(herds,feedregime,manchain,emissions)
                                                     TSP        PM10      PM25
     $$iftheni.cat "%cattle%"=="true"
       cows.          noGraz.    liquidCattle        1.81       0.83      0.54
       mCalvsRais.    noGraz.    liquidCattle        0.35       0.16      0.1
       fCalvsRais.    noGraz.    liquidCattle        0.35       0.16      0.1
       heifs.         noGraz.    liquidCattle        0.69       0.32      0.21
     $$iftheni.bulls defined bulls
       bulls.         noGraz.    liquidCattle        0.69       0.32      0.21
       motherCow.     noGraz.    liquidCattle        0.69       0.32      0.21
     $$endif.bulls
       $$iftheni.straw "%strawManure%"=="true"
       cows.          noGraz.    solidCattle         0.94       0.43      0.28
       mCalvsRais.    noGraz.    solidCattle         0.35       0.16      0.1
       fCalvsRais.    noGraz.    solidCattle         0.35       0.16      0.1
* for calves Haenel et al. 2018 do not report emission factors for slurry based system so same factor is used
       heifs.         noGraz.    solidCattle         0.52       0.24      0.16
     $$iftheni.bulls "%farmBranchBeef%"        == "on"
       bulls.         noGraz.    solidCattle         0.52       0.24      0.16
     $$endif.bulls
       motherCow.     noGraz.    solidCattle         0.52       0.24      0.16
       $$endif.straw
     $$endif.cat

     $$iftheni.sows "%farmBranchSows%"        == "on"
       sows.          normfeed.  liquidPig           0.62       0.17      0.01
       youngPiglets.  normfeed.  liquidPig           0.27       0.05      0.002
     $$endif.sows

     $$iftheni.fat "%farmBranchfattners%"    == "on"
       Fattners.      normfeed.  liquidPig           0.3        0.14      0.006
     $$endif.fat
     ;
   $$endif.h

* --- Sets for calculation of particulatematter emissions from cropping (own estimation)
*   --- cultivation operations
          set cultiOperation(operation) /plow,chiselPlow,seedBedCombi,sowMachine,directSowMachine,
                                         circHarrowSow,springTineHarrow,weederLight,weederIntens,
                                         stubble_shallow,stubble_deep,rotaryHarrow,potatoLaying/;
*   --- harvest operations
          set harvestOperation(operation)/combineCere,combineRape,combineMaiz,potatoHarvest,uprootBeets,mowing,chopper/;
*   --- processing (cleaning and drying)
          set dryingOperation(operation)/store_n_dry_8,store_n_dry_4,store_n_dry_beans,
                                         store_n_dry_rape,store_n_dry_corn,grinding/;

* --- Emission factor for particulatematter emission from EMEP (2016) 3.D p.20
*     https://www.eea.europa.eu/publications/emep-eea-guidebook-2016/part-b-sectoral-guidance-chapters/4-agriculture/3-d-crop-production-and
* --- cleaning and drying are combined, Grass only for hay making
Parameter p_EFpmfCrops(crops,operation,emissions);

    p_EFpmfCrops(crops,cultiOperation(operation),"PM10")            = 0.25;
    p_EFpmfCrops(crops,cultiOperation(operation),"PM25")            = 0.015;

    p_EFpmfCrops(grain_Wheat,harvestOperation(operation),"PM10")  = 0.49;
    p_EFpmfCrops(grain_Wheat,dryingOperation(operation),"PM10")   = 0.19 + 0.56;
    p_EFpmfCrops(grain_Wheat,harvestOperation(operation),"PM25")  = 0.02;
    p_EFpmfCrops(grain_Wheat,dryingOperation(operation),"PM25")   = 0.009 + 0.168;

    p_EFpmfCrops(grain_barley,harvestOperation(operation),"PM10") = 0.41;
    p_EFpmfCrops(grain_barley,dryingOperation(operation),"PM10")  = 0.16 + 0.43;
    p_EFpmfCrops(grain_barley,harvestOperation(operation),"PM25") = 0.016;
    p_EFpmfCrops(grain_barley,dryingOperation(operation),"PM25")  = 0.008 + 0.129;

    p_EFpmfCrops(grain_rye,harvestOperation(operation),"PM10") = 0.37;
    p_EFpmfCrops(grain_rye,dryingOperation(operation),"PM10")  = 0.16 + 0.37;
    p_EFpmfCrops(grain_rye,harvestOperation(operation),"PM25") = 0.015;
    p_EFpmfCrops(grain_rye,dryingOperation(operation),"PM25")  = 0.008 + 0.129;

    p_EFpmfCrops(grain_oat,harvestOperation(operation),"PM10") = 0.62;
    p_EFpmfCrops(grain_oat,dryingOperation(operation),"PM10")  = 0.25 + 0.66;
    p_EFpmfCrops(grain_oat,harvestOperation(operation),"PM25") = 0.025;
    p_EFpmfCrops(grain_oat,dryingOperation(operation),"PM25")  = 0.0125 + 0.198;

    p_EFpmfCrops(hay,harvestOperation(operation),"PM10") = 0.25;
    p_EFpmfCrops(hay,harvestOperation(operation),"PM25") = 0.01;


$ifthen.grasAttr defined p_grasAttr
    p_EFpmfCrops(grasscrops(crops),harvestOperation(operation),"PM10") $(sum(m,p_grasAttr(grassCrops,"hay",m))>0) = 0.25;
    p_EFpmfCrops(grasscrops(crops),harvestOperation(operation),"PM25") $(sum(m,p_grasAttr(grassCrops,"hay",m))>0) = 0.01;
$endif.grasAttr

* --- Correction of atomic weight of N emissions (own calculation based on science)

    p_corMass(emissions)=1;
    p_corMass("N2O")    =1.571428571;
    p_corMass("NOx")    =2.142857143;
    p_corMass("N2")     =1;
    p_corMass("NH3")    =1.214285714;
    p_corMass("N2Oind") =1.571428571;
    p_corMass("NO3")    =4.428571429;

********************************************************************************
*  --- Midpoint characterizationfactors according to ReCiPe 2016 hierarchist 100years
*  --- GWP values based on AR5 (https://www.ghgprotocol.org/sites/default/files/ghgp/Global-Warming-Potential-Values%20%28Feb%2016%202016%29_1.pdf)
********************************************************************************

parameter  p_emCat(emCat,emissions)
/
  GWP     .N2O        265
  GWP     .N2Oind     265
  GWP     .CH4         28
  GWP     .CO2          1
  FEP     .P            1
  MEP     .NO3          0.07
  MEP     .NH3          0.1
  MEP     .NOx          0.04
  ODPinf  .N2O          0.011
  ODPinf  .N2Oind       0.011
  PMFP    .NO3          0.08
  PMFP    .NH3          0.24
  PMFP    .NOx          0.11
  PMFP    .PM25         1
  PMFP    .PM10         1
  POFP    .NOx          1
  POFP    .NO3          0.74
  TAP     .NO3          0.27
  TAP     .NH3          1.96
  TAP     .NOx          0.36
$iftheni.upstream "%upstreamEF%" == "true"
  ALOP    .m2aA_eq      1
  GWP     .CO2_eq       1
  FDP     .oil_eq       1
  FETPinf .FETP_DCB_eq  1
  FEP     .P_eq         1
  HTPinf  .HTP_DCB_eq   1
  IRP_HE  .U235_eq      1
  METPinf .METP_DCB_eq  1
  MEP     .N_eq         1
  MDP     .Fe_eq        1
  NLTP    .m2_eq        1
  ODPinf  .CFC11_eq     1
  PMFP    .PM10_eq      1
* Somehow wrong unit in greendelta software
  POFP    .NMVOC_eq     0.18
  TAP     .SO2_eq       1
  TETPinf .TETP_DCB_eq  1
  ULOP    .m2aU_eq      1
  WDP     .m3_eq        1
$endif.upstream
/;

*
* ---- Calculation of cereal units (Getreideeinheitenschlüssel) based on
*      https://www.bmel-statistik.de/fileadmin/daten/SJT-3120100-2011.xlsx
*
*      For now: onyl arable crops
*      No data found for MaizCCM, therefore selected "sonstige Hauptfutterfrüchte"
*      No data found for catchCrops (with fodderUse), therefore selected: "Zwischenfrucht Raps"
*                        silage -> GPS / silage maize selected
*      No data found for grassland / clover grass

   $$GDXIN "%datDir%/%cropsFile%.gdx"
      $$LOAD  p_cerealUnit
   $$GDXIN

     p_cerealUnit("Idle")                 = 0    ;
     p_cerealUnit(prodsResidues)    = 0.10 ;

* --- Values need checking in relation to units

    $$iftheni.cowherd "%cowHerd%"=="true"

     p_cerealUnit("milk")         = 0.86 ;
     p_cerealUnit("oldcow")       = 0.10 ;
    $$endif.cowherd
*     p_cerealUnit("mCalvsSold")   = 0.10 ;
*     p_cerealUnit("fCalvsSold")   = 0.10 ;
