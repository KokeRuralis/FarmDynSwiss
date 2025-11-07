********************************************************************************
$ontext

   FARMDYN project

   GAMS file : PRICES.GMS

   @purpose  : data collection of prices and investment costs
   @author   : David Schäfer
   @date     : 23.04.14
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : /model/Biogas_model.gms

$offtext
********************************************************************************

********************************************************************************
*
*             Parameters for investment costs as well as variable costs
*
********************************************************************************

*--- Investment Cost for different biogas plant sizes and investment horizons    (Source: ...\David\Masterarbeit\20131210_InvestmentDocumentation\20140407_Investition Verfahrenstechnik)

Table         p_priceBioGasPlant(bhkw,ih)                 "Investment cost for biogas plants distinguished by different investment horizons"

                         IH7          IH10          IH20

              150kW    214000        173740        355602
              250kW    290704        302940        468740
              500kW    372583        409440        828050
;

Table         p_priceFlexBioGasPlant(bhkw,eeg,ih)               "Investment cost for flexible production"

                                  IH7            IH10

              150kW.EDM2012     122271.4           0
              250kW.EDM2012     154967.5         40000
              500kW.EDM2012     213741.2         80000
              150kW.EDM2014     122271.4           0
              250kW.EDM2014     154967.5         40000
              500kW.EDM2014     213741.2         80000
;
*--- Different investment horizons

 parameter    p_ih(ih)                               "investment horizon"
              /
              IH7    6
              IH10   10
              IH20   20
              /;

*--- Labour demand of biogas plant   (Source: N:\reso\work1\Mitarbeiter\HIWIS\David\Masterarbeit\20131210_Investment Documentation\20140428_Detailed Variable Cost)

$ontext
parameter     p_labDemandkW(bhkw)                    "Labour demand per unit of KW depending of BHKW sizes"
              /
                150kW 5.37
                250kW 3.83
                500kW 2.42
              /;

parameter     p_labBiogas(bhkw,t,m)                  "monthly total labour demand depending on plant size";

              p_labBiogas("150kW",t,m) = 150 * p_labDemandkW("150kW") / card(m);
              p_labBiogas("250kW",t,m) = 250 * p_labDemandkW("250kW") / card(m);
              p_labBiogas("500kW",t,m) = 500 * p_labDemandkW("500kW") / card(m);

$offtext
parameter     p_workBioInd(bhkw)                     "Factor used to translate produced electricity into required work load"

              /
              150kW 1489.02
              250kW 2089.21
              500kW 3307.97
              /;


*--- Variable cost calculation (Source: \David\Masterarbeit\20131210_InvestmentDocumentation\20140407_Investition Verfahrenstechnik)

parameter     p_varCostMiscBiogas(bhkw)                "Including yearly variable cost such as periodic maintenance and repairs, insurance, and general expenses"

              /
               150kW    55648
               250kW    72526
               500kW    104559
              /;

parameter     p_ownConsElec                            "Consumption of electricity contingent on own electricity production"

              /0.07/;

parameter     p_priceElecPurch                         "Price of purchased electricity as operating supply"

              /0.19/;

parameter     p_consumablesB(bhkw)                     "Amount of consumables such as lubricant, igniting (?) oil (Zündöl for 150kW plant)"

              /
               150kW   15000
               250kW    2500
               500kW    5000
              /;


********************************************************************************
*
*                     Parameters for output prices
*
********************************************************************************

scalar        p_hrsYear                              "hours per year"
              /8760/;

parameter     p_instPow(bhkw)                        "total installed electric engine capacity (Anlagenleistung)"
              /
              150kW  150
              250kW  250
              500kW  500
              /;

parameter     p_powRate(bhkw,eeg)                   "Rated output of the respective BHKW (Bemessungsleistung)";

              p_powRate(bhkw,eeg) = ((p_instPow(bhkw)*8000)/p_hrsYear)            ;
              p_powRate(bhkw,eeg)$eegScen(eeg) = ((p_instPow(bhkw)*8000)/p_hrsYear)   * p_scenRed(eeg);



scalar        p_fKor                                 "correction factor for degree of capacity utilization"
              /1.1/;

parameter     p_corAddPow(bhkw,eeg)                  "corrected additional installed electricty producing capacity";
              p_corAddPow(bhkw,eeg) = p_instPow(bhkw) - (p_fKor * p_powRate(bhkw,eeg));


scalar        p_capComp                              "capacity component"
              /130/;



* ---Electricity prices for different sizes and eegs (Source:Calculation of output prices can be seen in N:\reso\work1\Mitarbeiter\HIWIS\David\Masterarbeit\20131210_Official Documents\20140416_EEG Guaranteed Feed-In Tariffs)

 Table        p_priceElecBase(bhkw,eeg)                  "Prices depending on BHKW size and EEG"

                           E2004      E2009       EM2009      E2012      EDM2012      EDM2014    ESPEM0914    ESPEDM0914   ESPE1214   ESPEDM1214

              150kW       0.115       0.2167      0.2567      0.143       0.143       0.1366      0.2567       0.2567       0.143       0.143
              250kW       0.099       0.1918      0.2018      0.123       0.123       0.12908     0.2018       0.2018       0.123       0.123
              500kW       0.099       0.1918      0.2018      0.123       0.123       0.12344     0.2018       0.2018       0.123       0.123
;


*--- Boni for EEG E2004 to account for degression of only the base rate

parameter     p_priceElecE2004(bhkw,eeg)               "Base rate for EEG E2004 to account for regression";

              p_priceElecE2004("150kW","E2004")= 0.08;
              p_priceElecE2004("250kW","E2004")= 0.072;
              p_priceElecE2004("500kW","E2004")= 0.066;


*--- Electricity price degression according to different eeg (Source: N:\reso\work1\Mitarbeiter\HIWIS\David\Masterarbeit\20131210_Official Documents

parameter     p_priceElecDeg(eeg) "electricity price degression per year, rate"
              /
              E2004 0.015
              E2009 0.01
              EM2009 0.01
              E2012 0.02
              EDM2012 0.02
              ESPEM0914 0.01
              ESPEDM0914 0.01
              ESPE1214 0.02
              ESPEDM1214 0.02
              /;

*--- Electricty output prices based on the input used for electricity production (Source: Can be seen in N:\reso\work1\Mitarbeiter\HIWIS\David\Masterarbeit\20131210_Official Documents\20140416_EEG Guaranteed Feed-In Tariffs)

Table         p_priceElecInputClass(bhkw,eeg,inputClass) "Prices for different input groups"

                                      inputCl1         inputCl2

              150kW.E2012              0.06             0.08
              250kW.E2012              0.06             0.08
              500kW.E2012              0.06             0.08

              150kW.EDM2012            0.06             0.08
              250kW.EDM2012            0.06             0.08
              500kW.EDM2012            0.06             0.08

              150kW.ESPEDM0914         0.06             0.08
              250kW.ESPEDM0914         0.06             0.08
              500kW.ESPEDM0914         0.06             0.08

              150kW.ESPE1214           0.06             0.08
              250kW.ESPE1214           0.06             0.08
              500kW.ESPE1214           0.06             0.08

              150kW.ESPEDM1214         0.06             0.08
              250kW.ESPEDM1214         0.06             0.08
              500kW.ESPEDM1214         0.06             0.08

;
*--- Using the initial sliding scale prices -  Calculation According to §20,21,27 - Gesetz über den Vorrang Erneuerbarer Energien (EEG 09,12)
*    - Differentiating between EEG s with rated output (Bemessungsleistung)  and total installed electric engine capacity (Anlagenleistung)

parameter     p_priceElec(bhkw,eeg,t) "Sliding scale prices with degressive rate";


              p_priceElec(bhkw,eeg,tCur(t))$(eegRated(eeg)) = (p_priceElecBase("150kW",eeg) * (150/p_powRate(bhkw,eeg))
                                                          + p_priceElecBase(bhkw,eeg) * ((p_powRate(bhkw,eeg) - 150)/p_powRate(bhkw,eeg)))
                                                         ;

display p_priceElec;
              p_priceElec(bhkw,"E2004",tCur(t)) =   ( p_priceElecBase("150kW","E2004") * (150/p_powRate(bhkw,"E2004"))
                                                  + p_priceElecBase(bhkw,"E2004") * (p_powRate(bhkw,"E2004") - 150)/p_powRate(bhkw,"E2004"))
                                                        + p_priceElecE2004(bhkw,"E2004") * (150/p_powRate(bhkw,"E2004"))
                                                          + p_priceElecE2004(bhkw,"E2004") * (p_powRate(bhkw,"E2004") - 150)/p_powRate(bhkw,"E2004")

;
*--- Price for heat per kWh  (Source: Values taken from KTBL "Faustzahlen Biogas" p. 286)

 parameter    p_priceHeat(t)                    "Price for heat in €/kWh";
              p_priceHeat(t) = 0.02;



*--- Minimal heat sold (Source: Values taken from KTBL (2013) "Faustzahlen Biogas" p.273)

parameter     p_minHeatSold                              "minimal requirement of heat sold for EEG E2012"
              /0.35/;



parameter    p_scenPremium(eeg) "Premium for reducing input for the biogas production";
             p_scenPremium(eeg)  = %scenPremium% ;


********************************************************************************
*
*                                    Flexibility
*
********************************************************************************

*---  Price for flexible energy production (Source: N:\reso\work1\Mitarbeiter\HIWIS\David\Masterarbeit\20131210_Official Documents\20140512_Marktpraemien 2012)

parameter     p_dmMW(m)            "Marktwert (market value) of the electricity at the EPEX SPOT (currently dependent on month but will be dependend on year AND month)"
              /
               jan   0.04056
               feb   0.04187
               mar   0.03636
               apr   0.03517
               may   0.02931
               jun   0.02507
               jul   0.03367
               aug   0.03548
               sep   0.03896
               oct   0.03493
               nov   0.03647
               dec   0.03
              /;

parameter     p_dmSellPriceHigh(m) "Selling price of electricity at daily peak average (True for 2012 but no other year)"
              /
               jan   0.054339
               feb   0.053932
               mar   0.048007
               apr   0.048702
               may   0.044284
               jun   0.039281
               jul   0.045448
               aug   0.044583
               sep   0.053698
               oct   0.049242
               nov   0.050881
               dec   0.047250
               /;

parameter     p_dmSellPriceLow(m) "Selling price of electricity at daily low average (True only for 2012)"
              /
               jan   0.036027
               feb   0.034240
               mar   0.030052
               apr   0.029679
               may   0.027431
               jun   0.022581
               jul   0.031377
               aug   0.029274
               sep   0.032115
               oct   0.027831
               nov   0.028611
               dec   0.023765
                /;

parameter     p_dmMP(bhkw,eeg,t,m)                   "Market premium for biogas plant owner";

              p_dmMP(bhkw,"EDM2012",t,m)      =   p_priceElec(bhkw,"EDM2012",t)      - p_dmMW(m);
              p_dmMP(bhkw,"EDM2014",t,m)      =   p_priceElec(bhkw,"EDM2014",t)      - p_dmMW(m);
              p_dmMP(bhkw,"ESPEDM0914",t,m)   =   p_priceElec(bhkw,"ESPEDM0914",t)   - p_dmMW(m);
              p_dmMP(bhkw,"ESPEDM1214",t,m)   =   p_priceElec(bhkw,"ESPEDM1214",t)   - p_dmMW(m);

parameter     p_flexPrem(bhkw,eeg)                       "Premium for flexible electricity production";
              p_flexPrem(bhkw,eeg) = (p_corAddPow(bhkw,eeg) * p_capComp) / (p_powRate(bhkw,eeg)*p_hrsYear);

parameter     p_shareEPEX(bhkw)     "Share of electricty sold on EPEX during high prices, contingent on scenario premium";
              p_shareEPEX(bhkw) = p_instPow(bhkw)/(( p_instPow(bhkw)-( p_instPow(bhkw)* (%scenRed%/100)))*2);


$iftheni "%dynamics%" == "comparative-static"


  p_priceBioGasPlant(bhkw,ih) $ p_ih(ih)
     =  p_priceBioGasPlant(bhkw,ih) /   p_ih(ih);

  p_ih(ih) = 1;


$endif


