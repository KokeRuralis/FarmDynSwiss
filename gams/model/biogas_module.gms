********************************************************************************
$ontext

   FARMDYN project

   GAMS file : MODULE-Biogas.gms

   @purpose  : Variables / Equations only used if biogas module is switched on
   @author   : D.Schaefer, using existing code from rev. 476
   @date     : 11.12.14
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : model/templ.gms

$offtext
********************************************************************************
Parameter

             p_addPow(bhkw)                             "Additionally installed electricity producing capacity"
             p_bhkwEffic(bhkw,effic)                    "Energy conversion efficiency of different BHKW sizes"
             p_calYear(Tall)                            "Converts the set character of the year into an integer for calculations"
             p_capComp                                  "Capacity component"
             p_ch4Con                                   "Energy content of CH4 in kWh"
             p_consumablesB(bhkw)                       "Amount of consumables such as lubricant, igniting (?) oil (Zuendoel for 150kW plant)"
             p_corAddPow(bhkw,eeg)                      "corrected additional installed electricty producing capacity"
             p_crop(crM)                                "Metahne yield for crops in m3 per ton"
             p_digLoad(bhkw,m)                          "the pre-set maximal digestion load"
             p_dryMatterCrop(crM)                       "dry matter content of crops in percentage"
             p_dryMatterManure(maM)                     "dry matter content of manure in percentage"
             p_dmMW(m)                                  "Marktwert (market value) of the electricity at the EPEX SPOT (currently dependent on month but will be dependend on year AND month)"
             p_dmSellPriceHigh(m)                       "Selling price of electricity at daily peak average (True for 2012 but no other year)"
             p_dmSellPriceLow(m)                        "Selling price of electricity at daily low average (True for 2012 but no other year)"
             p_dmMP(bhkw,eeg,t,m)                       "Market premium for biogas plant owner"
             p_fKor                                     "Correction factor for degree of capacity utilization"
             p_flexPrem(bhkw,eeg)                       "Premium for flexible electricity production"
             p_fixElecMonth(bhkw,m)                     "maximal produced electricity for respective fermenter monthly"
             p_fixElecYear(bhkw)                        "maximal produced electricity for respective fermenter yearly"
             p_fixElecYearLoss(bhkw)                    "Yearly maximal produced electricity for respective fermenter accounting for transformation losses"
             p_heatsold                                 "Share of heat sold on total heat production"
             p_hrsYear                                  "Hours per year"
             p_iH(iH)                                   "Describes the various investment horizons"
             p_iniBioGas(bhkw,eeg,ih,tOld)              "Assigns the farm a initial BioGas Plant"
             p_iniBiogasParts(bhkw,eeg,ih,tOld)         "Initial biogas plant parts"
             p_instPow(bhkw)                            "Actuall installed capacity"
             p_labDemandkW(bhkw)                        "Labour demand per unit of KW depending of BHKW sizes"
             p_labBiogas(bhkw,t,m)                      "Labour demand per biogas plant per month"
             p_manure(maM)                              "Methane yield for manures in m3 per ton"
             p_minHeatSold                              "minimal requirement of heat sold for EEG E2012"
             p_orgDryMatterCrop(crM)                    "organic dry matter content of crops in percentage of the dry matter content"
             p_orgDryMatterManure(maM)                  "organic dry matter content of manure in percentage of the dry matter content"
             p_ownConsElec                              "Consumption of electricity contingent on own electricity production"
             p_ownHeatUsg                               "heat usage by the fermenter (25%)"
             p_priceCropAcqui(crM)                      "Price for acquisioned crops "
             p_priceManAcqui(maM)                       "Price for acquisioned manure"
             p_priceBioGasPlant(bhkw,ih)                "Investment cost for biogas plants distinguished by different investment horizons"
             p_priceFlexBioGasPlant(bhkw,eeg,ih)        "Investment cost for flexible production"
             p_priceElec(bhkw,eeg,t)                    "Prices depending on BHKW size and EEG"
             p_priceElecE2004(bhkw,eeg)                 "Base rate for EEG E2004 to account for regression"
             p_priceElecDeg(eeg)                        "Electricity price degression, rate per year"
             p_priceElecInputClass(bhkw,eeg,inputClass) "Electricity prices received for different input groups"
             p_priceElecPurch                           "Price of purchased electricity as operating supply"
             p_priceHeat(t)                             "Price for heat in Euro/kWh"
             p_powRate(bhkw,eeg)                        "Power rating (Bemessungsleistung) of the respective BHKW"
             p_scenRed(eeg)                             "Percentage of reduction connected to scrapping"
             p_scenPremium(eeg)                         "Scrapping Premium"
             p_shareEPEX(bhkw)                          "share of electricity sold durign high and low prices at Spot Market"
             p_silageLoss                               "silage loss coefficient"
             p_siloBiogas(bhkw)                         "Different silo sizes differentiated by BHKW size"
             p_transLosses                              "Power transformer losses equals 1%"
             p_varCostMiscBiogas(bhkw)                  "Yearly variable costs excluding substrate and operating supplies"
             p_volFerm(bhkw)                            "Actual fermenter volumina depending on bhkw size in m^3"
             p_volFermMonthly(bhkw)                     "Maximal volume of monthly inputs"
             p_workBioInd(bhkw)                         "Factor used to translate produced electricity into required work load"
             p_fugCrop(biogasFeedM)
             p_fugMan
             p_nutDigCrop(manchain,nut2,biogasFeedM)
             p_shareNTAN(biogasFeedM)
             p_nut2manPurch(manchain,nut2,maM)
;

   variables
            v_salRevBiogas(t,n)                                    "Revenue from biogas plants"
;

  positive variables
            v_prodElec(bhkw,eeg,t,n,m)                             "electricity output in kWh"
            v_prodElecCrop(bhkw,eeg,t,n,m)                         "electricity produced by Crop"
            v_prodElecManure(bhkw,eeg,t,n,m)                       "electricity produced by Manure"
            v_prodHeat(eeg,t,n)                                    "heat output in kWh"
            v_methManure(bhkw,eeg,t,n,m)                           "methane production by manure"
            v_methCrop(bhkw,eeg,t,n,m)                             "methane production by crop"
            v_nutCropBiogasY(manchain,nut2,t,n)                             "nutrient content in crops yearly (NTAN,NORG,P)"
            v_nutCropBiogasM(manchain,nut2,t,n,m)                           "nutrient content in crops monthly(NTAN,NORG,P)"
            v_nut2ManurePurch(manchain,nut2,maM,t,n,m)                       "nutrient content in purchased manure (NTAN,NORG,P)"

            v_nutPoolinBiogas(manchain,nut2,t,n,m)                          "steady nutrient pool in biogas plant (NTAN,NORG,P)"

            v_sellHeat(eeg,t,n)                                    "heat sold in kWh"
            v_usedCropBiogas(bhkw,eeg,biogasFeedM,t,n,m)           "Substrate amount of used crops in tons"
            v_usedManBiogas(bhkw,eeg,maM,t,n,m)                    "Substrate amount of used manure in tons"
            v_feedBioGas(bhkw,eeg,biogasFeedM,t,n,m)               "Substrate amount of crops produced in tons on farm"
            v_purchCrop(bhkw,eeg,biogasFeedM,t,n,m)                "Substrate amount of purchased crops in tons"
            v_purchManure(bhkw,eeg,maM,t,n,m)                      "Substrate amount of purchased manure in tons"

            v_volManBiogas(manchain,bhkw,eeg,maM,t,n,m)                     "m3 of manure used in biogas plants"
            v_totVolFermMonthly(bhkw,eeg,t,n,m)                    "total fermenter volume used in m3"
            v_labBioGas(bhkw,t,n,m)                                "required work load for biogas plant"
            v_varCostBiogas(bhkw,t,n)                              "variable cost of biogas plant (excluding substrate input)"
            v_operatingSupplB(bhkw,t,n)                            "Operating supplies for biogas plant"

            v_digLoad(bhkw,t,n,m)                                  "the digestion load calculated in kg(m^3 * month)"
            v_volDigCrop(biogasfeedM,t,n,m)                        "volume of crop digestate"
            v_volDigMan(t,n,m)                                     "volume of manure digestate"
            v_siloBiogasStorCap(t,n)                               "Storage silo bought when investment in biogas plant is made"

;


$ifi %MIP%==on   binary variables

            v_invBioGas(bhkw,eeg,t,n)                     "Fermenter inventory"
            v_buyBioGasPlant(bhkw,eeg,ih,t,n)             "Investment in biogas fermenter inventory"
            v_invBioGasParts(bhkw,ih,t,n)                 "Technical inventory of biogas plant"
            v_buyBioGasPlantParts(bhkw,ih,t,n)            "Investment in technical inventory"
            v_switchBioGas(bhkw,eeg,eeg,t,n)              "Switching the eeg of the biogas plant"
            v_useBioGasPlant(bhkw,eeg,t,n)                "Biogas plant under actual eeg in use"

;

  equations
            biogasObje_(t,n)                              "biogas revenue"
            biogasVolCropDigestate_(biogasFeedM,t,n,m)    "Determines digestate from crops  (volume)"
            biogasVolManDigestate_(t,n,m)                 "Determines digestate from purchased manure (volume)"
            heatSold_(eeg,t,n)                            "heat sold on the market"
            kWel_(bhkw,eeg,t,n,m)                         "electricity generation"
            kWelCrop_(bhkw,eeg,t,n,m)                     "electricity produced by crop"
            kWelManure_(bhkw,eeg,t,n,m)                   "electricity produced by manure"
            methCrop_(bhkw,eeg,t,n,m)                     "methane production by crop"
            methManure_(bhkw,eeg,t,n,m)                   "methane production by manure"
            kWth_(eeg,t,n)                                "heat generation"
            fixKW_(bhkw,eeg,t,n,m)                        "Fixing the size of biogas plant"
            fixkWel_(bhkw,eeg,t,n,m)                      "fixing the kWh output to a level depending on bhkw size"

            heatRes_(bhkw,eeg,t,n,m)                      "Restriction for 2012 EEG that 35% (with 25% own usage) of produced heat has to be sold"
            maizeRes_(bhkw,eeg,biogasFeedM,t,n,m)         "Maize restriction for 2012"
            manureRes_(bhkw,eeg,t,n,m)                    "Manure restriction for 2009"
            usedCropBioGas_(bhkw,eeg,biogasFeedM,t,n,m)   "Defines use of crop for biogas, accounts the silage losses"
            manureTot_(bhkw,eeg,maM,t,n,m)                "Account for total used manure in the biogas production process"
            totVolFerm_(bhkw,eeg,t,n,m)                   "total fermenter volume used in m3"

            invBioGasTot_(t,n)                            "Not more than one biogas plant at any time"
            invBioGas_(bhkw,eeg,ih,t,n)                   "Calculation of biogas inventory(Integer-Variable)"
            invBioGasTotParts_(bhkw,ih,t,n)               "At any time the technical inventory of the biogas plant has to existent"
            invBioGasParts_(bhkw,ih,t,n)                  "Calculating the investment in technical inventory of biogas plant"
            invSiloBiogas_(t,n)                           "Silo bought for digestate at the time of biogas investment"
            useBioGas_(bhkw,eeg,t,n)                      "Switching eeg use"
            switchBioGas_(bhkw,eeg,t,n)                   "Switching eeg use"
            fixdigLoad_(bhkw,t,n,m)                       "fixing the fermenter volume and possible input via the digestion load"
            digLoad_(bhkw,t,n,m)                          "possible digestion load"
            labBioGas_(bhkw,t,n,m)                        "Required work load for biogas plant"
            varCostB_(bhkw,t,n)                           "Variable cost for biogas plant"
            operatingSupplBiogas_(bhkw,t,n)               "Operating supplies differeantiated by biogas plant size"
            nutCropBiogasY_(manchain,nut2,t,n)                     "nutrient content in NTAN,NORG,P in biogas feeding crops yearly"
            nutCropBiogasM_(manchain,nut2,t,n,m)                   "nutrient content in NTAN,NORG,P in biogas feeding crops monthly"
            nutManBiogasM_(nut2,t,n,m)                    "nutrient content in NTAN NORG P in biogas feeding manure monthly"
            nut2ManurePurch_(manchain,nut2,maM,t,n,m)              "nutrient content in NTAN NORG P in biogas by purchased manure"
            nutPoolinBiogas_(nut2,t,n,m)                  "steady nutrient pool in biogas plant"
            purchManRestri_(manchain,bhkw,eeg,maM,t,n,m)           "Secures that not additional manure is purchased, which is not used in the fermenter"

$ifi %herd% == true      volManBioGas_(manchain,t,n)               "links the on-farm manure with the purchased manure"
;


*******************************************************************************************
*
*    Biogas - economic part
*
*******************************************************************************************
*
*   --- Yearly Revenue of BHKW
*
    bioGasObje_(tCur(t),nCur) $ t_n(t,nCur) ..
       v_salRevBioGas(t,nCur)

        =e=

*            --- Revenue stemming from electricity production with degression depending on EEG (excluding direct marketing)
                 sum( (curBhkw(bhkw),curEeg(eeg),m) $ (not(eegDM(eeg))),
                                    v_prodElec(bhkw,eeg,t,nCur,m) *  p_priceElec(bhkw,eeg,t)   )

*            --- Revenue stemming from electricity production for EEG E2012 differentiated by input class
               + sum( (curBhkw(bhkw),curEeg(eeg),m) $ (eegDif(eeg)) ,
                                        v_prodElecCrop(bhkw,eeg,t,nCur,m)   * p_priceElecInputclass(bhkw,eeg,"inputCl1")
                                      + v_prodElecManure(bhkw,eeg,t,nCur,m) * p_priceElecInputclass(bhkw,eeg,"inputCl2") )

*            --- Revenue stemming from heat
               + sum( curEeg(eeg),  v_sellHeat(eeg,t,nCur) * p_priceHeat(t) )

*            --- Revenue specification for EEG with direct marketing and flexible biogas production
               + sum( (curBhkw(bhkw),curEeg(eeg),m)$(eegDM(eeg)),
                                   + (v_prodElec(bhkw,eeg,t,nCur,m) * p_shareEPEX(bhkw) )
                                       * (p_dmMP(bhkw,eeg,t,m) + p_dmsellPriceHigh(m) )
                                   + (v_prodElec(bhkw,eeg,t,nCur,m) * (1 - p_shareEPEX(bhkw) ) )
                                       * (p_dmMP(bhkw,eeg,t,m) + p_dmsellPriceLow(m) )
                                   + (v_prodElec(bhkw,eeg,t,nCur,m) * p_flexPrem(bhkw,eeg) ) )

*            --- Revenue stemming from scenario premium
               + sum( (curBhkw(bhkw), curEeg(eeg),m)$(eegScen(eeg)),
                                      v_prodElec(bhkw,eeg,t,nCur,m) * p_scenPremium(eeg)$(eegScen(eeg)))
;
*
*  --- Variable Costs - Disaggregated such that operating supplies are variable
*      and maintenance and repairs keep constant for a given BHKW size
*

   varCostB_(curBhkW(bhkw), tCur(t),nCur) $ t_n(t,nCur) ..

         v_varCostBiogas(bhkw,t,nCur)
            =E= v_operatingSupplB(bhkw,t,nCur) + (p_varCostMiscBiogas(bhkw) + p_consumablesB(bhkw))
                                                    * sum( curEeg(eeg),v_useBioGasPlant(bhkw,eeg,t,nCur));


*  --- Externally bought electricity based on own production


   operatingSupplBiogas_(curBhkw(bhkw),tCur(t),nCur) $ t_n(t,nCur) ..

         v_operatingSupplB(bhkw,t,nCur)
            =E= sum( (curEeg(eeg), m), v_prodElec(bhkw,eeg,t,nCur,m)) * p_ownConsElec * p_priceElecPurch;


*******************************************************************************************
*
*    Biogas - plant (part) inventory
*
*******************************************************************************************
*
*   --- never more then one plant operational at any time
*
    invBioGasTot_(tCur(t),nCur) $ t_n(t,nCur) ..

       sum( (curBhkw(bhkw),curEeg(eeg)), v_invBioGas(bhkw,eeg,t,nCur)) =L=  1;
*
*   --- Inventory of biogas plants on farm: past investments, account for max life time and
*        for plant parts, the latter differentiated by investment horizon (IH)

    invBioGas_(curBhkw(bhkw),curEeg(eeg),ih,tFull(t),nCur) $ (ih20(ih) $ t_n(t,nCur))   ..

       v_invBioGas(bhkw,eeg,t,nCur)

           =L=
                 sum( (tCur(t1),nCur1)  $ (t_n(t1,nCur1) $ isNodeBefore(nCur,nCur1)
                       $  (p_year(t1) + p_ih(ih)+1 ge p_year(t)+1 )
                      and (p_year(t1)+1 le p_year(t)+1 ) ),

                                       v_buyBioGasPlant(bhkw,eeg,ih,t1,nCur1) )

                 + sum( tOld $ ( (p_year(tOld) + p_ih(ih) ge p_year(t) ) and (p_year(tOld) le p_year(t) ) ),

                                       p_iniBioGas(bhkw,eeg,ih,tOld) );

*
*   ---  Silo inventory is pegged to the biogas plant investment
*

    invSiloBiogas_(tCur(t), nCur) $ t_n(t,nCur) ..

        v_siloBiogasStorCap(t,nCur) =E= sum((curbhkw(bhkw), curEeg(eeg)), v_invBiogas(bhkw,eeg,t,ncur) * p_siloBiogas(bhkw));


*
*   --- inventory of parts restricts used of existing plant
*
    invBioGasTotParts_(curBhkw(bhkw),ih,tCur(t),nCur) $ (t_n(t,nCur) $ (not ih20(ih)))..

           v_invBioGasParts(bhkw,ih,t,nCur) =G= sum(curEeg(eeg), v_invBioGas(bhkw,eeg,t,nCur));



*
*   --- inventory of parts (have a shorted life time)
*
    invBioGasParts_(curBhkw(bhkw),ih,tFull(t),nCur) $ ( (not(ih20(ih))) $ t_n(t,nCur) ) ..

       v_invBioGasParts(bhkw,ih,t,nCur) =e=

             sum( (tCur(t1),nCur1) $ ( t_n(t1,nCur1) $ isNodeBefore(nCur,nCur1)
                                    $ (p_year(t1) + p_ih(ih) ge p_year(t)) and (p_year(t1) le p_year(t) ) ),

                                       v_buyBioGasPlantParts(bhkw,ih,t1,nCur1) )

              + sum( tOld $ ( (p_year(tOld) + p_ih(ih) ge p_year(t) ) and (p_year(tOld) le p_year(t) ) ),

                                    sum(curEeg, p_iniBioGasParts(bhkw,curEeg,ih,tOld)) );
*
*   --- Providing the possibility to switch an existing plant built under a past eeg
*       to a new EEG, technically, the switch re-assignes the plant to the new egg in the rest of the model
*       Note: the diagonal element eeg,eeg1 simply use the inventories without switch
*
    switchBioGas_(curBhkw(bhkw),curEeg(eeg1),tCur(t),nCur) $ t_n(t,nCur) ..

       v_invBioGas(bhkw,eeg1,t,nCur)

          =G= sum(newEeg_oldEeg(eeg,eeg1) $ curEeg(eeg), v_switchBioGas(bhkw,eeg1,eeg,t,nCur));
*
*   --- actual biogas plant use, restricted to "switched" inventory
*
    useBioGas_(curBhkw(bhkw),curEeg(eeg),tCur(t),nCur) $ t_n(t,nCur) ..

       v_useBioGasPlant(bhkw,eeg,t,nCur)

          =L= sum(newEeg_oldEeg(eeg,eeg1) $ curEeg(eeg1), v_switchBioGas(bhkw,eeg1,eeg,t,nCur));

*******************************************************************************************
*
*    Biogas - production and input use

*******************************************************************************************

*
*--- Fixing the maximum electricty produced by the biogas plant differentiated by plant size
*    as well as accounting for transformation losses

fixkWel_(curBhkw(bhkw),curEeg(eeg),tCur(t),nCur,m) $ (t_n(t,nCur) and (v_prodElec.up(bhkw,eeg,t,nCur,m) ne 0)) ..

       v_prodElec(bhkw,eeg,t,nCur,m)

          =l= v_useBioGasPlant(bhkw,eeg,t,nCur) * p_fixElecMonth(bhkw,m) * p_scenRed(eeg);


*       I. Stage
*
*   --- methane from crops (relates to needed substrates to meet methane requirement)
*
methCrop_(curBhkw(bhkw),curEeg(eeg),tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_methCrop(bhkw,eeg,t,nCur,m)

          =e= sum(crM(biogasFeedM), v_usedCropBiogas(bhkw,eeg,crM,t,nCur,m) * p_crop(crM) );

*   --- methane from manure per year and months

methManure_(curBhkw(bhkw),curEeg(eeg),tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_methManure(bhkw,eeg,t,nCur,m)

          =e= sum(curmaM,     v_usedManBiogas(bhkw,eeg,curmaM,t,nCur,m) * p_manure(curmaM) );


*       II. Stage
*
*--- Calculation of electricity output in kWh of biogas plant
*
kWel_(curBhkw(bhkw),curEeg(eeg),tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_prodElec(bhkw,eeg,t,nCur,m)

         =e= (v_prodElecCrop(bhkw,eeg,t,nCur,m) + v_prodElecManure(bhkw,eeg,t,nCur,m));

*--- Electricity output generated by crops

kWelCrop_(curBhkw(bhkw),curEeg(eeg),tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_prodElecCrop(bhkw,eeg,t,nCur,m)

         =e= v_methCrop(bhkw,eeg,t,nCur,m) * p_ch4Con * p_bhkwEffic(bhkw,"el") * p_transLosses;

*--- Electricity output generated by manure

kWelManure_(curBhkw(bhkw),curEeg(eeg),tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_prodElecManure(bhkw,eeg,t,nCur,m)

         =e= v_methManure(bhkw,eeg,t,nCur,m) * p_ch4Con * p_bhkwEffic(bhkw,"el") * p_transLosses;

*
*   --- Fermenter input cannot exceed fermenter capacity of existing bio-gas plants :
*       Link made to size of biogas - plant
*
    fixKW_(curBhkw(bhkw),curEeg(eeg),tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_totVolFermMonthly(bhkw,eeg,t,nCur,m)

         =l= v_useBioGasPlant(bhkw,eeg,t,nCur) *  p_volFermMonthly(bhkw) * p_scenred(eeg);

*
*   --- restriction on total volume depending on substrate input composition
*
    totVolFerm_(curBhkw(bhkw),curEeg(eeg),tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_totVolFermMonthly(bhkw,eeg,t,nCur,m)  =g=

                                          sum(crM(biogasFeedM), v_usedCropBiogas(bhkw,eeg,crM,t,nCur,m))

                                        + sum(curmaM, v_usedManBiogas(bhkw,eeg,curmaM,t,nCur,m) );

*
*   --- Losses for purchased crops and on-farm produced crops
*
    usedCropBioGas_(curBhkw(bhkw),curEeg(eeg),crM(biogasFeedM),tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_usedCropBiogas(bhkw,eeg,crM,t,nCur,m)

          =e= (    v_purchCrop(bhkw,eeg,crM,t,nCur,m)  $ selPurchInputs(crM) * p_silageLoss)
                 + v_feedBioGas(bhkw,eeg,crM,t,nCur,m) $ SUM(sameas(curProds,crM),1);

*
*   --- Aggregation of purchased manure and manure stemming from on farm
*
    manureTot_(curBhkw(bhkw), curEeg(eeg),curmaM,tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_usedManBiogas(bhkw,eeg,curmaM,t,nCur,m)
          =e=
               v_purchManure(bhkw,eeg,curmaM,t,nCur,m) $ selPurchInputs(curmaM)
$ifi %herd%==true            + sum(curmanchain $ (not sameas (curmanChain,"LiquidBiogas")) , v_volManBiogas(curmanchain,bhkw,eeg,curmaM,t,nCur,m))
    ;



*
*   --- link manure quantity on farm to volume in fermenter
*
$iftheni.h %herd%==true

    volManBioGas_(curmanchain, tCur(t),nCur) $ (t_n(t,nCur) $ (not sameas (curmanchain,"LiquidBiogas"))) ..

      v_manQuant(curManChain,t,nCur) $ (not sameas (curmanchain,"LiquidBiogas"))

          =G= sum( (manchain_mam(curmanchain,curmam),curbhkw(bhkw),curEeg(eeg),m) $(not sameas (curmanchain,"liquidBiogas")), v_volManBiogas(curmanchain,bhkw,eeg,curmaM,t,nCur,m)) ;

$endif.h

*
*   --- Volume of produced digestate
*

     biogasVolCropDigestate_(crm(biogasfeedM),tCur(t),nCur,m) $ t_n(t,nCur) ..

        v_volDigCrop(crM,t,nCur,m) =E= sum( (curBhkw(bhkw), curEeg(eeg)),
                                        v_usedCropBiogas(bhkw,eeg,crM,t,nCur,m)* p_fugCrop(crM));
*
*   --- Volume of digested manure which was purchased. Own manure is not accounted
*       in the volume flow but is directly flowing into the silos
*

     biogasVolManDigestate_(tCur(t),nCur,m) $ t_n(t,nCur) ..

        v_volDigMan(t,nCur,m) =E= sum( (curBhkw(bhkw), curEeg(eeg), curmaM) ,
                                        v_purchManure(bhkw,eeg,curmaM,t,nCur,m) $ selPurchInputs(curmaM)   * p_fugMan);






*****************************************************************
*
*   --- Nutrient pool in the fermenter
*
*****************************************************************

*
*  --- Nutrient input from crops - Summarized for the whole year and then divided by all month
*      in order to account for unrealistic fluctuating feeding patterns
*       (DS 02/09/2015)

    nutCropBiogasY_(curmanchain,nut2,tCur(t),nCur) $ (t_n(t,nCur) $ sameas(curmanchain,"LiquidBiogas")) ..

        v_nutCropBiogasY(curmanchain,nut2,t,nCur) =E=
             sum( ( crM(biogasFeedM),m,curBhkw(bhkw), curEeg(eeg) ),
                                         v_usedCropBiogas(bhkw,eeg,crM,t,nCur,m)
                                               * p_nutDigCrop(curmanchain,nut2,crM));

    nutCropBiogasM_(curmanchain,nut2,tCur(t),nCur,m) $(t_n(t,nCur) $ sameas(curmanchain,"LiquidBiogas")) ..

        v_nutCropBiogasM("LiquidBiogas",nut2,t,nCur,m) =E=  v_nutCropBiogasY("LiquidBiogas", nut2,t,nCur) / card(m);

*
* --- Nutrients from purchasing manure
*
       nut2ManurePurch_(curmanchain,nut2,curmaM,tCur(t),nCur,m) $( t_n(t,nCur) $ sameas(curmanchain,"LiquidBiogas"))  ..

         v_nut2ManurePurch(curmanchain,nut2,curmaM,t,nCur,m)
            =E=    sum ( (curBhkw(bhkw), curEeg(eeg)),
                        v_purchManure(bhkw,eeg,curmaM,t,nCur,m) * p_nut2manPurch("LiquidBiogas",nut2,curmaM)  )    ;

$ontext
*
*    --- steady nutrient pool for biogas plant [NOT USED]
*
    nutPoolinBiogas_(nut2,tCur(t),nCur,m) $ t_n(t,nCur)..

       v_nutPoolinBiogas(nut2,t,nCur,m)  =E=

       [     v_nutCropBiogasM(nut2,t,nCur,m)

           + sum((manchain,maM), v_nut2ManurePurch(manchain,nut2,maM,t,nCur,m))

           + ( sum( (curbhkw(bhkw),curEeg(eeg),maM,manchain),
                  v_volManBiogas(bhkw,eeg,maM,t,nCur,m)   * p_nut2manPurch(manchain,nut2,maM) )) ]  ;

$offtext

*
*    ----  Secures that not additional manure is purchased except the manure used in the fermenter
*
     purchManRestri_(curmanchain,curBhkw(bhkw), curEeg(eeg),curmaM,tCur(t),nCur,m) $ t_n(t,nCur)..

          v_purchManure(bhkw,eeg,curmaM,t,nCur,m) =L= v_usedManBiogas(bhkw,eeg,curmaM,t,nCur,m)
                         $$ifi %herd% == true            - v_volManBiogas(curmanchain,bhkw,eeg,curmaM,t,nCur,m) $ (not sameas (curmanchain,"LiquidBiogas"));
         ;


*****
*
*  --- Biogas Heat
*
****

*--- Calculation of heat output in kWh of biogas plant

kWth_(curEeg(eeg),tCur(t),nCur) $ t_n(t,nCur) ..

       v_prodHeat(eeg,t,nCur) =e= sum( (curBhkw(bhkw),m),
                               ( v_methManure(bhkw,eeg,t,nCur,m) + v_methCrop(bhkw,eeg,t,nCur,m) )
                                                                  * p_Ch4Con * p_bhkwEffic(bhkw,"he") )
*                                 --- deduct share for own usage of heat for fermenter

                                                        * p_ownHeatUsg;

*
*   --- Calulation of quantity of heat sold
*
    heatSold_(curEeg(eeg),tCur(t),nCur) $ t_n(t,nCur) ..

       v_sellHeat(eeg,t,nCur) =e= v_prodHeat(eeg,t,nCur)* p_heatsold;


*
*   --- Implementing the digestion load as technological constraint with regard
*       to maximal organic dry matter in the fermenter

    fixdigLoad_(curBhkw(bhkw),tCur(t),nCur,m) $ t_n(t,nCur) ..

      v_digLoad(bhkw,t,nCur,m)   =l= sum(curEeg(eeg),  v_useBioGasPlant(bhkw,eeg,t,nCur) * p_digLoad(bhkw,m))  ;
*
*    --- share of fermented volume used, in organic dry matter
*
    digLoad_(curBhkw(bhkw),tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_digLoad(bhkw,t,nCur,m) =e= (   sum ( (curEeg(eeg),crM(biogasFeedM)),
                                       v_usedCropBiogas(bhkw,eeg,crM,t,nCur,m)
                                          * p_dryMatterCrop(crM)* p_orgDryMatterCrop(crM))

                              + sum( (curEeg(eeg),curmaM),
                                         v_usedManBiogas(bhkw,eeg,curmaM,t,nCur,m)
                                           * p_dryMatterManure(curmaM)*p_orgDryMatterManure(curmaM) ) )

                                    / p_volFerm(bhkw);

*
*     --- Required monthly work load differentiated by biogas plant and depending on biogas electricity output
*

   labBioGas_(curBhkw(bhkw),tCur(t),nCur,m) $ t_n(t,nCur) ..

     v_labBioGas(bhkw,t,nCur,m) =e= sum(curEeg(eeg), v_prodElec(bhkw,eeg,t,nCur,m)) / p_workBioInd(bhkw);


*
*   --- EEG 2009:  restricitions for manure boni
*
    manureRes_(curBhkw(bhkw),eegMan(eeg),tCur(t),nCur,m) $ (t_n(t,nCur) $ curEeg(eeg)) ..

       sum(curmaM,  v_usedManBiogas(bhkw,eeg,curmaM,t,nCur,m)) =g= v_totVolFermMonthly(bhkw,eeg,t,nCur,m)*0.3 ;
*
*   --- EEG 2012 - Restrictions
*       (a) Mass restriction of 60% corn products in the fermenter at all times
*           - All boni are dependent on this restriction

    maizeRes_(curBhkw(bhkw),eegDif(eeg),biogasFeedM,tCur(t),nCur,m) $ (curEeg(eeg) $ t_n(t,nCur)) ..

        v_usedCropBiogas(bhkw,eeg,biogasFeedM,t,nCur,m) $sum(sameas(biogasFeedM,maizSilage),1)
             =l=  0.6 * v_totVolFermMonthly(bhkw,eeg,t,nCur,m);

*
*   --- EEG 2012 - Restrictions
*       b) Minimum amount of heat which has to be used/sold - All boni are dependent on the fact if that requirement
*          is fullfiled - level of sold v_prodheat has to be determined in the beginning
*           -> parameter for share of prodheat, which can be chosen. Otherwise the farmer would always opt
*              for the highest value of the parameter! Parameter set has to include the dependent eeg!

    heatRes_(curBhkw(bhkw),eegDif(eeg),tCur(t),nCur,m) $ (curEeg(eeg) $ t_n(t,nCur)) ..

       v_sellHeat(eeg,t,nCur) =g= p_minHeatSold * v_prodHeat(eeg,t,nCur);




    model m_biogas/


                  bioGasObje_
                  heatSold_
                  invBioGasTot_
                  invBioGas_
                  useBioGas_
                  switchBioGas_
                  fixkWel_
                  kWel_
                  kWelCrop_
                  kWelManure_
                  kWth_
                  methCrop_
                  methManure_
                  fixKW_
                  totVolFerm_
                  maizeRes_
                  manureRes_
                  heatRes_
                  invBioGasTotParts_
                  invBioGasParts_
                  fixdigLoad_
                  digLoad_
                  usedCropBioGas_
                  manureTot_
                  labBioGas_
                  varCostB_
                  operatingSupplBiogas_
                  nutCropBiogasY_
                  nutCropBiogasM_
*                  nutPoolinBiogas_
                  nut2ManurePurch_
                  invSiloBiogas_
                  purchManRestri_


                  biogasVolCropDigestate_
                  biogasVolManDigestate_

$ifi %herd% == true   volManBioGas_

                  /;

