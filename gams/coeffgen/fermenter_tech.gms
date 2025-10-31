********************************************************************************
$ontext

   FARMDYN project

   GAMS file : FERMENTER_TECH.GMS

   @purpose  : data preparation of data for fermenter technology
   @author   : David Schäfer
   @date     : 23.04.14
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : /model/Biogas_model

$offtext
********************************************************************************

********************************************************************************
*
*            Parameters for fermenter technology and plant attributes
*
********************************************************************************

*--- Methane energy content (Source: http://biogas.fnr.de/daten-und-fakten/)

parameter     p_ch4Con                               "Energy content of CH4 in kWh"
              /9.97/;

*--- Conversion efficiency of combustion engine (Source: KTBL (2013) "Faustzahlen Biogas" page. 286)

Table         p_bhkwEffic(bhkw,effic)                "Energy conversion efficiency of different BHKW sizes"

                        el      he
              150kW    .413    .392
              250kW    .37     .44
              500kW    .401    .432
;

*--- The calculated required fermenter size for one year for a biogas plant - (Source: http://daten.ktbl.de/biogas/startseite.do - using a 70% maize silage and manure input)

parameter    p_volFerm(bhkw)                        "Actual fermenter volumina depending on bhkw size in m^3"
              /
              150kW     800
              250kW     1800
              500kW     3374
              /;

parameter     p_volFermMonthly(bhkw)                 "Maximal volume of monthly inputs"
              /
              150kW     297
              250kW     568
              500kW     1039.6
              /;

*--- Methane yield of various crops (Source:FNR (2013) "Leitfaden Biogas" page 76, table 4.9)

parameter p_crop(crM)   "Methane yield for crops in m3 per ton";

$gdxin "%datDir%/%cropsFile%.gdx"
   $$load p_crop
$gdxin

 p_crop(crm) $(sum(grassil, sameas(crm,grassil))) = 98;


*--- Methane yield for various manures (Source: FNR (2013) "Leitfaden Biogas" page 76, table 4.9)

 parameter    p_manure(maM)                       "Methane yield for manures in m3 per ton"
                                  /
                                  manCatt 14
                                  manPig  17
                                  /;

*--- Recommended and converted digestion load (Source:\David\Masterarbeit\20131210_InvestmentDocumentation\20140407_Investition Verfahrenstechnik)

parameter     p_digLoad(bhkw,m)                        "The pre-set maximal digestion load";
              p_digLoad("150kW",m)= 0.09 ;
              p_digLoad("250kW",m)= 0.075;
              p_digLoad("500kW",m)= 0.075;

*--- Dry matter and organic dry matter content (Source: FNR (2013) "Leitfaden Biogas" p. 69ff)

   parameter     p_dryMatterCrop(crM)                 "dry matter content of crops in percentage";
   $$gdxin "%datDir%/%cropsFile%.gdx"
     $$load p_dryMatterCrop
   $$gdxin

   p_dryMatterCrop(crm) $(sum(grassil, sameas(crm,grassil))) = 0.35;

   parameter     p_dryMatterManure(maM)               "dry matter content of manure in percentage"
                                 /
                                  manCatt  0.10
                                  manPig   0.06
              /;

   parameter     p_orgDryMatterCrop(crM)              "organic dry matter content of crops in percentage of the dry matter content";
   $$gdxin "%datDir%/%cropsFile%.gdx"
      $$load p_orgDryMatterCrop
   $$gdxin

   p_orgDryMatterCrop(crm) $(sum(grassil, sameas(crm,grassil))) = 0.90;


parameter     p_orgDryMatterManure(maM)            "organic dry matter content of manure in percentage of the dry matter content"
              /
                                  manCatt    0.80
                                  manPig     0.80
              /;

*--- Share of sold heat of total heat produced

 parameter    p_heatsold                             "Share of heat sold on total heat production"
              /0.50/;


*--- Share of own heat consumption (Source: KTBL (2013) "Faustzahlen Biogas" p.273)

 parameter    p_ownHeatUsg                           "heat usage by the fermenter (25%)"
              /0.75/;

********************************************************************************
*
*           Parameters for digestate storage and nutrient flow
*
********************************************************************************



*---- Values taken from KTBL (2013) "Faustzahlen Biogas" p.251
   parameter     p_fugCrop(biogasFeedM)                   "fugatfactor for crops";
   $$gdxin "%datDir%/%cropsFile%.gdx"
      $$load p_fugCrop
   $$gdxin
   p_fugCrop(biogasFeedM) $(sum(grassil, sameas(biogasFeedM,grassil))) = 0.75;

parameter     p_fugMan
              /1/;


* Values for total N and P are taken from "Nährstoffvergleich NRW 2015 - LWK 2015". The ratio between NTAN and NORG for crops is taken for the ratio of the digestate
* determined by the values taken from "Faustzahlen Biogas" p. 252; e.g. NTAN share in % of TM is 4.18, while NTOT share in % of TM is 7.43. The share of NTAN is thus
* NTANshare = 4.18/7.43 = 0.562584.
*(DS 02/09/2015)

  set grassilm(biogasFeedM) / set.grasSil /;


   parameter     p_totNCrop(biogasfeedM)                       "total N in crops in kg/t";
   parameter     p_shareNTAN(biogasFeedM)                      "share of NTAN in crops in percent";

   $$gdxin "%datDir%/%cropsFile%.gdx"
      $$load p_shareNTAN p_totNCrop
   $$gdxin
   p_totNCrop(grasSilM) = 5.2;
   p_shareNTAN(grasSilM) = 0.606805;


parameter     p_nutDigCrop(manchain,nut2,biogasFeedM)    "NTan,Norg,P in biogas feeding crops in kg/t";

              p_nutDigCrop("LiquidBiogas","NTAN",biogasFeedM) = (p_totNCrop(biogasFeedM) * p_shareNTAN(biogasFeedM))  ;
              p_nutDigCrop("LiquidBiogas","NORG",biogasFeedM) = (p_totNCrop(biogasFeedM) * (1- p_shareNTAN(biogasFeedM))) ;
              p_nutDigCrop("LiquidBiogas","P", biogasFeedM) $sum(sameas(biogasFeedM,maizSilage),1)     = 1.9 ;
              p_nutDigCrop("LiquidBiogas","P",biogasFeedM) $sum(sameas(biogasFeedM,GPS),1)    = 2.4 ;
              p_nutDigCrop("LiquidBiogas","P", grasSilM)     = 1.4 ;

* Values for total N are taken from "Betriebsplanung Landwirtschaft 2014/2015 p. 581 (Cattle), p.713 (Pig)". The ratio between NTAN and NORG are taken from "Faustzahlen
* Biogas" p.252. Example equation see above. (DS 02/09/2015)
*
parameter     p_nut2manPurch(manchain,nut2,maM)       "nutrient content in purchased manure in kg/ton";
              p_nut2manPurch("LiquidBiogas","NTAN","manCatt")   =  4.6  * 0.577223  ;
              p_nut2manPurch("LiquidBiogas","NTAN","manPig")    =  12.2/1.5 * 0.7;
              p_nut2manPurch("LiquidBiogas","NORG","manCatt")   =  4.6  * (1-0.577223)  ;
              p_nut2manPurch("LiquidBiogas","NORG","manPig")    =  12.2/1.5 * (1-0.7) ;
              p_nut2manPurch("LiquidBiogas","P","manCatt")      =  3.9  ;
              p_nut2manPurch("LiquidBiogas","P","manPig")       =  5/1.5 ;

*
*  --- Content of digestates to empty storage, no losses occur in biogasplant except loss of volume, represented by p_fugCrop; during storage, different kind of
*      N losses occur. To allow application of digestate, these losses have to be reflected in p_nut2inMan

* --- Calculation of digestate content before storage losses, i.d. when coming from digester to manure storage

              p_nut2inManNoLoss(nut2,"normfeed","digMaizSil")      =   sum(sameas(maizSilage,biogasFeedM),
                                                                            p_nutDigCrop("LiquidBiogas",nut2,biogasFeedM)   / p_fugCrop(biogasFeedM) );
              p_nut2inManNoLoss(nut2,"normfeed","digWheatGPS")     =   sum(sameas(GPS,biogasFeedM),
                                                                            p_nutDigCrop("LiquidBiogas",nut2,biogasFeedM)   / p_fugCrop(biogasFeedM));
              p_nut2inManNoLoss(nut2,"normfeed","digGrasSil")      =   smax(grassilm,p_nutDigCrop("LiquidBiogas",nut2,grassilm)/ p_fugCrop(grasSilm));
              p_nut2inManNoLoss(nut2,"normfeed","manCattPurch")    =   p_nut2manPurch("LiquidBiogas",nut2,"manCatt")  / p_fugMan;
              p_nut2inManNoLoss(nut2,"normfeed","manPigPurch")     =   p_nut2manPurch("LiquidBiogas",nut2,"manPig")   / p_fugMan;

* --- p_nut2inMan is further used in manure.gms and losses are deducted there
              p_nut2inMan(nut2,manType,"LiquidBiogas") = p_nut2inManNoLoss(nut2,"normfeed", manType)$(sum(sameas(digestate,manType),1))
$ifi %herd% == true                               + sum((manChain_Type(manChain,manType)), p_nut2inMan(nut2,mantype,manchain))
 ;

p_nut2inMan(nut2,manType,manChain) $ (p_nut2InMan(nut2,manType,manChain) $(sum(sameas(digestate,manType),1)))
       =  p_nut2InMan(nut2,manType,manChain) * (1 - p_lossFactorSto(mantype,nut2,manChain));

********************************************************************************
*
*                   Parameters for fixing the electricity
*
********************************************************************************


*--- Values taken from KTBL (2013) "Faustzahlen Biogas" p.281 - Fixing the Produced Electricity


 parameter    p_silageLoss                           "silage loss coefficient"
              /0.88/;

*--- The maximal produced electricity is calculated by 8000 hours running time of the engine per year and the respective size
*--- of the biogas plant, i.e. 150kW, 250kW or 500KW. The second step accounts for transformation losses

 parameter    p_fixElecYear(bhkw)                    "maximal produced electricity for respective fermenter yearly"
              /
              150kW  1200000
              250kW  2000000
              500kW  4000000
              /;

*--- Biogas plant electricity usage: FNR (2013) "Leitfaden Biogas" Table 8.4, p.154

 parameter    p_transLosses                          "Power transformer losses equals 1%"
              /0.99/;


 parameter    p_fixElecYearLoss(bhkw)                "Yearly maximal produced electricity for respective fermenter accounting for transformation losses";
              p_fixElecYearLoss(bhkw)= p_fixElecYear(bhkw);


 parameter    p_fixElecMonth(bhkw,m)                 "maximal produced electricity for respective fermenter monthly";
              p_fixElecMonth(bhkw,m) = p_fixElecYearLoss(bhkw)/card(m);

*************************************************
*  ----- Scrapping Premium Reduction
*************************************************

parameter p_scenRed(eeg) "Reduction of input use";
          p_scenRed(eeg)  = 1 - (%scenRed%/100)$eegScen(eeg);




* --- Insert that all have digestate mantypes have to be cut out of curmantype which are not active in the GUI


curManType("digMaizSil")   $ (not sum(maizSilage, curcrops(maizSilage))) = NO;
curMantype("digWheatGPS")  $ (not sum(GPS, curCrops(GPS))) = NO;
curManType("digGrasSil")   $ (not curCrops("idleGras")) = NO;
curManType("manPigPurch")  $ (not sum(sameas("manPig",selpurchInputs),1)) = NO ;
curManType("manCattPurch") $ (not sum(sameas("manCatt",selpurchInputs),1)) = NO;

curMam("manPig")  $ sum(sameas(selpurchInputs,"manPig"),1) = YES;
curMam("manCatt") $ sum(sameas(selpurchInputs,"manCatt"),1) = YES;

$ifi %pigherd% == true curmaM("manPig") = YES;
$ifi %dairyherd% == true curmaM("manCatt") = YES;
