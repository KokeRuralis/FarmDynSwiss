********************************************************************************
$ontext

   Farmdny project

   GAMS file : DUEV_MODULE.GMS

   @purpose  : Variable and equation definitions related to German
               Fertilizer Law
   @author   : Till Kuhn, Wolfgang Britz
   @date     : 03.03.18
   @since    :
   @refDoc   :
   @seeAlso  : model\templ.gms
   @calledBy :

$offtext
********************************************************************************

  set NType / cattle,pig /;

  parameter
     p_NLimitInAutumn(crops,plot)                   "Naximum N in autumn allowed according to FO"
     p_nutManApplLimit(crops,t)                     "Maximum of organic N allowed per ha following DueV for different years"
     p_nutEffectivDueVNvBiogas(nut)                 "Defines share of N and P in digestates that has to enter crop balance according to DueV"
     p_surplusDueVMax(t,nut)                        "Naximun N and P surplus according to FO 07"
     p_NincludeBioDigest                            "Parameter to include or exclude accounting for digestate from plant origin"

     p_soilShareNutEnriched                         "Share of highly P enriched soils, no surplus allowed"
     p_nutContInput(inputs,nut)                     "N and P2O5 content of inputs in relation to v_buy"
     p_nutContOutput(prodsYearly,nut)               "N and P2O5 content of outputs in relation to v_saleQuant"
     p_NneedFerPlan(crops,soil,till,intens,nut,t)   "N Need for fertilizer planning following FO"
     p_balancedFert(nut)                            "Parameter to introduced balanced fertilization, no manure application over plant need possible when parameter = 0"
     p_bigNumber                                    "Large number for binary trigger" / 1000 /
     p_bigNumberFO                                  "Big number needed to make equation on ferilizer quota binding depending on FO"
     p_bigNumberFOAppLimCrop                        "Big number needed to make equation on crop specific manure limit depending on FO"


     p_ManureStorageNeedGV                          "Need of manure storage capacity in FO 17 depending on GV, calculated as share of annual manure excretion"

     p_nutEffectivDueVNv (nut)                      "Defines share of N and P in manure that has to enter crop balance according to DueV"
     p_nutEffectivDuevBiogas
     p_nutEffectivDueVAlBiogasPlantDig              "Share of Norg from biogas digestate for organic N application limit (AOG) from DueV 2016/17"

     p_CatchCropRequFO                              "Parameter to activate required catch crop area under FO 20"
     p_FertQuotaRed                                 "Parameter to change the allowed target value of fertilizing quota"

$iftheni.biogas %biogas% == true
     p_nutEffectivDueVAlBiogasPurchMan(maM)         "Share of Norg from biogas purchased manure for organic application limit from DueV"
$endif.biogas

  ;

  positive variables

   v_synthAppliedDueV(nut,t,n)                      "Application of kg N and P with mineral feritlizer entering nutrient balance for DueV"
   v_nutRemovalDuev(nut,t,n)                        "N and P removal by crop output for calculation of nutrient balance for DueV"

   v_nutExcrDueV(nut,nType,t,n)                     "N and P excretion in stable for calculation of Norg threshold and nutrient balance for FO"

   v_nutBiogasDuev(nut,t,n)                         "Nutrients from digestates for DueV indicators, comprising imported manure, on farm grown and imported crops"
   v_nutBiogasDueVAccAL(t,n)                        "Nutrients from digestates for DueV Organic N application limit, losses already substrated"

   v_FertQuotaInput(crops,plot,till,intens,nut,t,n) "N input according to the fertilizer quota system from the FO 17"
   v_FertQuotaNeed(crops,plot,till,intens,nut,t,n)  "N need according to the fertilizer quota system from the FO 17"

   v_FarmGateInput(nut,t,n)                         "Nutrient input to farm according to farmgate balance"
   v_FarmGateOutput(nut,t,n)                        "Nutrient output from farm according to farmgate balance"
   v_FarmGateAllowedSaldo(t,n)                      "Farm specific allowed nutrient saldo according to farmgate balance"

  $$ifi %MIP%==on   binary variables
    v_triggerStorageGVha(t,n)                       "Binary trigger for storage capacity over 3 LU/ha"
   ;

  variable

    v_surplusDueV (t,n,nut)                         "Yearly P and N surplus according to D�V (Fl�chenbilanz)"
    v_FarmGateSaldo(nut,t,n)                        "Nutrient saldo according to farmgate balance"
  ;

* --- N Org surplus can become negative for biogas production, therefore only as positive varible defined when biogas switched off

   $$iftheni.b %biogas% == true
      variables          v_DueVOrgN(t,n) "Organic N in kg according to DueV for calculatin organic N limitation (Ausbringungsobergrenze)"
   $$else.b
      positive variables v_DueVOrgN(t,n) "Organic N in kg according to DueV for calculatin organic N limitation (Ausbringungsobergrenze)"
   $$endif.b



  equations

       synthAppliedDueV_(nut,t,n)                     "Application of kg N and P with mineral feritlizer entering nutrient balance for DueV"
       nutRemovalDuev_(nut,t,n)                       "calcution of nutrient removal by crop output for calculation of nutrient balance"
       nutBalDueV_(nut,t,n)                           "Annual Nutrient balance (N�hrstoffbilanz) according to D�V 2006"
       nutSurplusDueVRestr_ (t,n,nut)                 "Restriction of N and P surplus according to D�V 2006"
*
*      --- the following equations are only present if animals are present
*

       nutExcrDueV_(nut,nType,t,n)                    "N and P excretion for calculation of Norg threshold and nutrient balance for FO, only stable"
       DuevOrgN_(t,n)                                 "Calculation of organic N that is limited by Duev 2006 (Ausbringungsobergrenze)"
       DuevOrgNLimit_(t,n)                            "Restriction for application of organic N given bei the D�ngeverordnung (Ausbringungsobergrenze)"
       DuevOrgNLimitCrop_(crops,t,n)                  "Restriction for application of organic N, crop specific for FO 2020"

       NLimitAutumn_ (crops,plot,till,intens,t,n)      "Restriction of N application after harvest of the main crop"

       nutBiogasDuev_(nut,t,n)                        "Nutrients from digestates for DueV indicators, comprising imported manure, on farm grown and imported crops"
       nutBiogasDueVAccAL_(t,n)                       "Nutrients from digestates for DueV Organic N application limit, losses already substrated"

       FertQuota_(crops,plot,till,intens,nut,t,n)          "Ensures that fertilizer need and fertilizer use meet the requirements of the fertilizer quota under FO 17"
       FertQuotaNZone_(t,n)                           "In Nitrate polluted zones, the fertilizer need is reduced at regional scale under FO 20"
       FertQuotaInput_(crops,plot,till,intens,nut,t,n)     "Calculates N input according to the fertilizer quota system from the FO 17"
       FertQuotaNeed_(crops,plot,till,intens,nut,t,n)      "Calculates N need according to the fertilizer quota system from the FO 17"
       triggerStorageGVha_(t,n)                       "Binary trigger if wich is switched on when farms exceed 3 LU/ha under FO 2017"

       FarmGateInput_(nut,t,n)                        "Nutrient input to farm according to farmgate balance"
       FarmGateOutput_(nut,t,n)                       "Nutrient output from farm according to farmgate balance"
       FarmGateSaldo_(nut,t,n)                        "Nutrient saldo according to farmgate balance"
       FarmGateAllowedSaldo_(t,n)                     "Farm specific allowed nutrient saldo according to farmgate balance"
$iftheni.fb "%farmgateBalance%" == "true"
       FarmGateBalRestr_(t,n)                         "Restriction of N saldo of farmgate balance"
$endif.fb

      nutOrganicOverNeed_(crops,plot,till,intens,nut,t,n)  "Equation enforces balanced fertilization, no manure application above plant need possible"

      CatchCropRequiredFO_(t,n)                         "Requirement of planting catch crops in nitrate polluted zones"
  ;

********************************************************************************************
*
* ---- The German Fertilization Ordinance (FO) consists of numerous, partly interlinked measures. The following measures are represented
*      in FarmDyn.
*      1) Nutrient balance (FO 07,17),
*      2) Manure application limit (FO 07,17,20)
*      3) Fertilizing planning (FO 07,17)
*      4) Farm gate balance (FO 07,17),
*      5) Required manure storage capacity (FO 07,17,20),
*      6) Restriction of fertilizer application after harvest of main crop
*
*      The following measures are defined in the corresponding dat files (e.g.dat/fertord_duev2017.gms) due to the model structure:
*
*      7) Banning periods (FO 07,17,20)
*      8) Required manure application technique (FO 07,17,20)
*
*********************************************************************************************

*
* ---- The following equations are linked to several measures
*

* --- 0) Calculation of annual chemical fertilizer applied entering nutrient balance accourding to DueV (in kg P and N)

  synthAppliedDueV_(nut,tCur(t),nCur)  $ t_n(t,nCur)..

           v_synthAppliedDueV(nut,t,nCur)    =e=

                              sum( (c_p_t_i(curCrops(crops),plot,till,intens),curInputs(syntFertilizer),m),
                                 v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)
                                           * p_nutInSynt(syntFertilizer,nut) )      ;

* --- 0) Calcution of nutrient removal by crop output for calculation of nutrient balance according to DueV
*       Crop output (p_nutContent is per 100 kg, output coefficients are in tons)


  nutRemovalDuev_(nut,tCur(t),nCur) $ t_n(t,nCur) ..

       v_nutRemovalDuev(nut,t,nCur)
             =e=

                sum( (c_p_t_i(curCrops,plot,till,intens)), v_cropHa(curCrops,plot,till,intens,t,%nCur%)
                            * sum( (plot_soil(plot,soil),curProds) $  p_OCoeffC%l%(curCrops,soil,till,intens,curProds,t),
                                                        p_OCoeffC(curCrops,soil,till,intens,curProds,t)/p_storageLoss(curCrops)
                                     * (  p_nutContent(curCrops,curProds,"conv",nut) $ (not sameas(till,"org"))
                                        + p_nutContent(curCrops,curProds,"org",nut)  $      sameas(till,"org"))
                                     *10 )   )

               +   sum( (c_p_t_i(curCrops,plot,till,intens)) $ cropsResidueRemo(curCrops),  v_residuesRemoval(curCrops,plot,till,intens,t,nCur)
                          *sum( (plot_soil(plot,soil),curProds),  p_OCoeffResidues(curCrops,soil,till,intens,curProds,t)
                                     *  (  p_nutContent(curCrops,curProds,"conv",nut)$ (not sameas(till,"org"))
                                         + p_nutContent(curCrops,curProds,"org",nut) $      sameas(till,"org"))
                                          * 10  )  )

                                                                      ;

$iftheni.herd "%herd%"==true

* --- 0) Calculation of N and P excretion of animal for nutrient balance and organic application limit
*      according to DueV, only in stable

  nutExcrDueV_(nut,nType,tCur(t),nCur)  $ t_n(t,nCur)..

       v_nutExcrDuev(nut,nType,t,nCur) =e=

           sum((actHerds(possHerds,breeds,feedRegime,t,m)) $ (
                               $$ifi defined cattle               (cattle(possHerds)  and sameas(nType,"cattle")) or
                               $$ifi defined pigherds             (pigHerds(possHerds) and sameas(nType,"pig"))
                               $$ifi not defined pigherds         ( 1 eq 2)
                                                               ),
                v_herdSize(possHerds,breeds,feedRegime,t,nCur,m)

                             * ( 1 - 1   $ sameas(feedRegime,"fullGraz")
                                   - 0.5 $ sameas(feedRegime,"partGraz"))

                              * 1/card(m)   *  p_nutExcreDueV(possHerds,feedRegime,nut) );
$endif.herd

*
*  --- 1) Nutrient Balance according to FO, relevant for FO 07 and 17
*

* --- 1a) Calculating the balance, opposing nutrient imput and removal

  nutBalDueV_(nut,tCur(t),nCur) $ t_n(t,nCur) ..

   v_surplusDueV(t,nCur,nut)

         =e=

*   --- Nutrients excreted from animals in stable time specific loss factor

    $$ifi %herd% == true      sum(nType,v_nutExcrDuev(nut,nType,t,nCur))  *  p_nutEffectivDueVNv(nut)

*   --- Nutrients excreted during grazing

    $$iftheni.cattle "%cattle%" == "true"

            +  sum(m $(  sum(grasscrops $(p_grazMonth(grassCrops,m)>0),1)
                       $ sum(actHerds(possHerds,breeds,grazRegime,t,m),1) ),
                  v_nutExcrPast(nut,t,nCur,m)    *  p_nutEffectivDueVNv(nut))

    $$endif.cattle

*  --- Nutrients coming from biogas plant (including energy crops and purchased manure)

    $$ifi %biogas% == true + v_nutBiogasDuev(nut,t,nCur)  *  p_nutEffectivDueVNvBiogas(nut)

*  --- Applied synthetic fertilizer

         + v_synthAppliedDueV(nut,t,nCur)

*  --- Nutrient from N fixation from legumes in grassland
         + sum(  (c_p_t_i(crops,plot,till,intens)) ,
                   v_cropHa(crops,plot,till,intens,t,%nCur%) *   (   p_NfromLegumes(Crops,"org")   $ sameas(till,"org")
                                                                  +  p_NfromLegumes(Crops,"conv")  $ (not sameas(till,"org"))
                                                                ))       $ (sameas (nut,"N") )
      $$iftheni.data "%database%" == "KTBL_database"
*
*     --- Nutrient from vegetables
*
         + sum(  (c_p_t_i(crops,plot,till,intens)) ,
                   v_cropHa(crops,plot,till,intens,t,%nCur%) *   (   p_NfromVegetables(Crops))
                                                                 )       $ (sameas (nut,"N") )
      $$endif.data
*
* --- Import of manure
*
       $$iftheni.im "%AllowManureImport%" == "true"

         +   sum ( (nut2_nut(nut2,nut),m,manImports),   v_manImport(manImports,t,nCur,m) *    p_nut2inMan(nut2,manImports,"LiquidImport") )   * (1- (p_nutEffectivDueVAl("import") - p_nutEffectivDueVNv("N") ))   $ sameas (nut,"N")
         +   sum ( (nut2_nut(nut2,nut),m,manImports),   v_manImport(manImports,t,nCur,m) *    p_nut2inMan(nut2,manImports,"LiquidImport") )      $ sameas (nut,"P")

       $$endif.im

*  --- Crop output (nutrient removal)

         -   v_NutRemovalDuev(nut,t,nCur)

$iftheni.h %herd% == true

*   --- Nutrients exported from farm

      $$iftheni.ExMan %AllowManureExport%==true

        -  sum( (curManChain,m,nut2) $(not sameas (nut2,"P")), v_nut2export(curManChain,nut2,t,nCur,m) )   $ sameas (nut,"N")
        -  sum( (curManChain,m), v_nut2export(curManChain,"P",t,nCur,m) )                                 $ sameas (nut,"P")

      $$endif.ExMan

* --- Nutrients exported from farm to external biogas plant
      $$iftheni.biogasex "%AllowBiogasExchange%"== "true"

        - v_nutExport(nut,t,nCur)

      $$endif.biogasex




      $$iftheni.emissionRight not "%emissionRight%"==0

        -  sum( (curManChain,m,nut2) $(not sameas (nut2,"P")), v_nut2exportMER(curManChain,nut2,t,nCur,m) )  $ sameas (nut,"N")
        -  sum( (curManChain,m),                               v_nut2exportMER(curManChain,"P",t,nCur,m) )   $ sameas (nut,"P")

      $$endif.emissionRight

$endif.h
      ;

$iftheni.biogas %biogas% == true

* --- 1b) Calculation of N and P from digestates for nutrient balance according to DueV

      nutBiogasDuev_(nut,tCur(t),nCur)  $ t_n(t,nCur)..

          v_nutBiogasDuev(nut,t,nCur) =e=

                sum( (curmanchain, m,nut2) $ (not sameas (nut2,"P")),
                    v_nutCropBiogasM(curmanchain,nut2,t,nCur,m)   + sum(curmaM, v_nut2ManurePurch(curmanchain,nut2,curmaM,t,nCur,m) ))  $ (sameas (nut,"N") $ sum(sameas(manchain,"LiquidBiogas"),1))

                     +  sum( (curmanchain,m) , v_nutCropBiogasM(curmanchain,"P",t,nCur,m) + sum(curmaM, v_nut2ManurePurch(curmanchain,"P",curmaM,t,nCur,m))) $ (sameas (nut,"P")  $ sum(sameas(manchain,"LiquidBiogas"),1))
              ;
$endif.biogas


* ---- 1c) Restriction of N and P surplus according to DueV

  nutSurplusDueVRestr_ (tCur(t),nCur,nut)   $ (p_surPlusDueVMax(t,nut) $ t_n(t,nCur))  ..

       v_surplusDueV(t,nCur,nut)

         =L=  p_surplusDueVMax(t,nut) * v_croplandActive(t,nCur) *  ( 1 - p_soilShareNutEnriched $ sameas (nut,"P"));
*
* --- 2) Manure application limit (170 kg/ha), relevant for FO 07,17,20
*

* --- 2a) Calculation of organic nutrients on the farm

$iftheni.manure %manure%==true

    DuevOrgN_(tCur(t),nCur) $ t_n(t,nCur) ..

        v_DueVOrgN (t,nCur)  =E=

*          --- Nutrients excreted in stable
           $$ifi "%herd%" == "true"  sum(nType,v_nutExcrDuev("N",nType,t,nCur)*   p_nutEffectivDueVAl(nType))

*          --- Nutrients excreted during grazing
           $$iftheni.cattle "%cattle%" == "true"

            +  sum(m $(  sum(grasscrops $(p_grazMonth(grassCrops,m)>0),1)
                       $ sum(actHerds(possHerds,breeds,grazRegime,t,m),1) ),
                  v_nutExcrPast("N",t,nCur,m) * p_nutEffectivDueVAlPast)
            $$endif.cattle

*           --- Nutrients imported to the farm

            $$ifi "%AllowManureImport%" == "true" +  sum ( (nut2N,m,ManImports), v_manImport(manImports,t,nCur,m) * p_nut2inMan(nut2N,manImports,"LiquidImport") )

*           --- Nutrients exported from farm

            $$ifi "%AllowManureExport%"=="true"  -  sum( (curManChain,m,nut2N), v_nut2export(curManChain,nut2N,t,nCur,m) )
            $$ifi not "%emissionRight%"==0       -  sum( (curManChain,m,nut2N), v_nut2exportMER(curManChain,nut2N,t,nCur,m) )
            $$ifi "%AllowBiogasExchange"=="true" -  sum( (nut)                , v_nutExport(nut,t,nCur) )

*           --- Nutrients coming from biogas plant, included depending on FD, calculated in fermenter tech

           $$ifi %biogas% == true +  v_nutBiogasDueVAccAL(t,nCur)
;

$iftheni.biogas %biogas% == true

* --- 2b) Calculation of N from Biogas digestate

  nutBiogasDueVAccAL_(tCur(t),nCur)  $ t_n(t,nCur)..

      v_nutBiogasDueVAccAL(t,nCur) =e=

           sum( (curmanchain,m,nut2N), v_nutCropBiogasM(curmanchain,nut2N,t,nCur,m)        * p_nutEffectivDueVAlBiogasPlantDig

*                 --- Depending of the Fertilizer Ordinance, the inclusion of digestate N from plant origin
*                      can be switched on/off (GUI=optional, FO07 = off, FO17 = on)
                             *  p_NincludeBioDigest )

        +  sum ( (curBhkw(bhkw), curEeg(eeg),curmaM,m,nut2N),
                                 v_purchManure(bhkw,eeg,curmaM,t,nCur,m) * p_nut2manPurch("LiquidBiogas",nut2N,curmaM)
                                                                        *  p_nutEffectivDueVAlBiogasPurchMan(curmaM)  ) ;
$endif.biogas

*
* --- 2b) Restriction of the manure present on the farm
*      Depending on the verion of the FO, certain areas are excluded which is reflected
*      in the parameter p_nutManApplLimit

  DuevOrgNLimit_ (tCur(t),nCur) $ t_n(t,nCur) ..

      v_DueVOrgN (t,nCur)

            =L=

             sum(  (c_p_t_i(curCrops(crops),plot,till,intens))  $ ( not catchcrops(crops) )  ,
                       p_nutManApplLimit(crops,t) * v_cropHa(crops,plot,till,intens,t,%nCur%)) ;
*
* ---- 2c) Plot/crop specific manure application limit relevant for FO 2020 in nitrate polluted areas
*      Not clear from FO how calculation will work as farm specific application limit is calculated via
*      animal stock and not application - recheck with tools from LWK etc.
*
  DuevOrgNLimitCrop_ (curCrops(crops),tCur(t),nCur) $ ( t_n(t,nCur) $ ( not catchcrops(crops) )  ) ..

      sum( (c_p_t_i(crops,plotInNO3zone(plot),till,intens),manApplicType_manType(ManApplicType,curManType),m,nut2N)
               $  ( v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0),

                     v_manDist(crops,plotInNO3zone,till,intens,manApplicType,curManType,t,nCur,m)
                         * sum(manChain_applic(manChain,ManApplicType), p_nut2inMan(nut2N,curManType,manChain)) )

      $$iftheni.dh "%cattle%" == "true"
*                --- excretion on pasture
              +  sum( (c_p_t_i(pastCrops(crops),plotInNO3zone(plot),till,intens),nut2N,m)
                          $ ((p_grazMonth(Crops,m)>0)
                                $ sum(actHerds(possHerds,breeds,grazRegime,t,m)  $ p_nutExcreDueV(possHerds,grazRegime,nut2N),1)),
                                              v_nut2ManurePast(crops,plot,till,intens,nut2N,t,nCur,m) )
      $$endif.dh

                    =L=

                     sum( (c_p_t_i(crops,plotInNO3zone(plot),till,intens))   ,
                               p_nutManApplLimit(crops,t)
                                   * v_cropHa(crops,plotInNO3zone,till,intens,t,%nCur%) * p_bigNumberFOAppLimCrop  )  ;


$endif.manure
*
* --- 3) Fertilizing planning = fertilizer quota, relevant for FO 17, 20
*

* --- 3a) N fertilizer input at farm level

  FertQuotaInput_(c_p_t_i(curCrops(crops),plot,till,intens),nut,t_n(tCur(t),nCur))    ..

     v_FertQuotaInput(crops,plot,till,intens,nut,t,nCur)

            =e=

                  sum (  (curInputs(syntFertilizer),m) $ (v_syntDist.up(crops,plot,till,intens,syntFertilizer,t,nCur,m) ne 0),
                              v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)     * p_nutInSynt(syntFertilizer,nut) )

*
*          --- note that the fertilizer ordinance already considers in the crop need (!)
*              nutrient excreted curing the grazing
*
$iftheni.man %manure% == true

               +  sum ( (manApplicType_manType(ManApplicType,curManType),m)
                                     $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0) ,

                          v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                              * sum( (nut2_nut(nut2,nut),manChain_applic(curManChain,ManApplicType)),
                                      p_nut2inMan(nut2,curManType,curManChain)*p_nutEffFOPlan(curManType,crops,m,nut)))
$endif.man

     ;

* --- 3b) N fertilizer need at farm level

 FertQuotaNeed_(c_p_t_i(curCrops(crops),plot,till,intens),nut,tCur(t),nCur) $ ( card(p_nNeedFerPlan)
         $ (not (catchCrops(crops) or sameas(crops,"idle") or sameas(crops,"idleGras")))) ..

     v_FertQuotaNeed(crops,plot,till,intens,nut,t,nCur)

                 =e=

                    v_cropHa(crops,plot,till,intens,t,%nCur%)
                          * sum(plot_soil(plot,soil),
*                           --- N need depending on yield level which is reflected in p_NneedFerPlan
                                  p_NneedFerPlan(crops,soil,till,intens,nut,t)
*                           --- Nmin in spring. For grassland, the value is always 30. Nmin of crop is accounted
*                               for the same crop as crop rotation is not reflected in the standard setting.
                              -   p_NutFromSoil(crops,soil,till,nut,t))
                            ;


* ---  3c) Nutrient need must not be exceed by N and P input

  FertQuota_(c_p_t_i(curCrops(crops),plot,till,intens),nut,t_n(tCur(t),nCur))
        $ (sum(plot_soil(plot,soil), p_NneedFerPlan(crops,soil,till,intens,nut,t))
             $ (not (catchcrops(crops) or sameas(crops,"idle") or sameas (crops,"idleGras")))) ..

       v_FertQuotaInput(crops,plot,till,intens,nut,t,nCur)  =l=    v_FertQuotaNeed(crops,plot,till,intens,nut,t,nCur)  * p_bigNumberFO  ;

* ---- 3d) Nutrient need in Nitrate polluted zones

  FertQuotaNZone_(tCur(t),nCur) $ ( t_n(t,nCur)) ..


     sum (c_p_t_i(curCrops(crops),plotInNO3zone,till,intens)
          $ (not (catchcrops(crops) or sameas(crops,"idle") or sameas (crops,"idleGras"))),
                  v_FertQuotaInput(crops,plotInNO3zone,till,intens,"N",t,nCur))

             =l=

    sum (c_p_t_i(curCrops(crops),plotInNO3zone,till,intens)
         $ (not (catchcrops(crops) or sameas(crops,"idle") or sameas(crops,"idleGras"))),
                 v_FertQuotaNeed(crops,plotInNO3zone,till,intens,"N",t,nCur) ) * p_FertQuotaRed ;


*     [?? CAn be deleted, not wanted restriction of nutbalcrop? ]
* --- Restriction that organic nutrient application is not allowed to exceed plant need, can be activated as balanced fertilization or with FO 17
*     p_balancedFert(nut) is INF if balanced fertilization inactive, and zero if balanced fertilization active (in coeffgen/manure.gms defined)
*

*    nutOrganicOverNeed_(c_p_t_i(curCrops(crops),plot,till,intens),nut,tCur(t),nCur)
*        $ ((v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0) $ t_n(t,nCur) $ (p_balancedFert(nut) eq 0)) ..
*                 v_nutOrganicOverNeed(crops,plot,till,intens,nut,t,nCur)  =L=   p_balancedFert(nut) ;



* ---- 4) Farm-gate balance calculation, relevant for FO 17, 20

* --- 4a) Calculation of nutrient input according to farmgate balance

  FarmGateInput_(nut,tCur(t),nCur) $ t_n(t,nCur)..

    v_FarmGateInput(nut,t,nCur) =e=

* --- Nutrient applied with chemical fertilizer

              v_synthAppliedDueV(nut,t,nCur)

* ---- Nutrient imported with seeds, animal feed and animals. There is no value for p_nutContInput for bought fertilizers.

         +     sum ( (curInputs(inputs),sys) $  p_inputprice%l%(inputs,sys,t), v_buy(inputs,sys,t,nCur) * p_nutContInput(inputs,nut) )

* ---- Manure import

      $$iftheni.im "%AllowManureImport%" == "true"

           +   sum ( (nut2_nut(nut2,nut),m,ManImports),   v_manImport(manImports,t,nCur,m) *    p_nut2inMan(nut2,manImports,"LiquidImport") )

       $$endif.im
                                ;

* --- 4b) Calculation of nutrient output according to farmgate balance  (kg N and kg P2O5)

  FarmGateOutput_(nut,tCur(t),nCur) $ t_n(t,nCur)..

     v_FarmGateOutput(nut,t,nCur) =e=

* --- Nutrients from selling of prodcuts

        sum ( (curProds(prodsYearly),sys),  v_saleQuant(prodsYearly,sys,t,nCur) *    p_nutContOutput(prodsYearly,nut))

* --- Nutrients from manure export

   $$iftheni.ExMan %AllowManureExport%==true

     $$ifi defined v_nut2Export  +  sum( (curManChain,m,nut2N), v_nut2export(curManChain,nut2N,t,nCur,m) )  $ sameas (nut,"N")
     $$ifi defined v_nut2Export  +  sum( (curManChain,m),       v_nut2export(curManChain,"P",t,nCur,m)   )  $ sameas (nut,"P")

   $$endif.ExMan

* --- Nutrients from biomass export to external biogas plant

    $$iftheni.biogasex "%AllowBiogasExchange%"== "true"

      - v_nutExport(nut,t,nCur)

    $$endif.biogasex
                               ;

* --- 4c) Calculation of nutrient saldo according to farmgate balance (kg N and kg P2O5)

   FarmGateSaldo_(nut,tCur(t),nCur)  $ t_n(t,nCur)..

      v_FarmGateSaldo(nut,t,nCur) =e=   v_FarmGateInput(nut,t,nCur) -   v_FarmGateOutput(nut,t,nCur) ;


* --- 4d) Calculation of allowed saldo individually calculated for farm

     FarmGateAllowedSaldo_(tCur(t),nCur) $ t_n(t,nCur)..

        v_FarmGateAllowedSaldo(t,nCur) =e=

          v_croplandActive(t,%nCur%) * 50

       +  sum(nType,v_nutExcrDuev("N",nType,t,nCur)) * (0.2 + 0.05)

    $$iftheni.ExMan %AllowManureExport%==true
       -   sum( (curManChain,m,nut2) $(not sameas (nut2,"P")), v_nut2export(curManChain,nut2,t,nCur,m) )   * 0.05
    $$endif.ExMan

    $$iftheni.im "%AllowManureImport%" == "true"
      +   sum ( (nut2_nut(nut2,"N"),m,manImports),   v_manImport(manImports,t,nCur,m) *    p_nut2inMan(nut2,manImports,"LiquidImport") )  * 0.05
    $$endif.im

    $$iftheni.BiogasEx "%AllowBiogasExchange%"=="true"
       -    v_nutExport("N",t,nCur)   * 0.05
    $$endif.BiogasEx
      ;


* --- 4e) Binding restriction for farmgate balance approach.
*     Farmer can select two different values as threshold 175 kg N ha-1 or a farm individual threshold, v_FarmGateAllowedSaldo.
*     However, we only use 175 in the binding equation as 175 will always be the less binding value

   $$iftheni.fb "%farmgateBalance%" == "true"

   FarmGateBalRestr_(tCur(t),nCur)  $ t_n(t,nCur)..

     v_FarmGateSaldo("N",t,nCur)  =l=      v_croplandActive(t,nCur)   * 175  ;

   $$endif.fb

   option kill=v_FarmGateAllowedSaldo;

*
* --- 5) Required manure storage capacity
*
*      General manure storage capacity needed according to FO defined in manure_module.gms, manStorCapNeed_
*
*      Binary trigger for having more than 3 LU/ha, v_triggerStorageGVha must be 1 if stocking density is above treshold
*     8 as multiplicator of trigger is sufficient as stocking density - 3 will not exceed 8
*     L.K: 8 is not sufficient for some farms, changed that to 200
*

$iftheni.herd "%herd%"=="true"

      triggerStorageGVha_(tCur(t),nCur) $t_n(t,nCur) ..

             (    v_sumGV(t,nCur)   /   sum(plot, p_plotSize(plot))  ) - 3  =l= v_triggerStorageGVha(t,%nCur%) *  200 ;

* --- Under the FO 17, 9 months manure storage capacity is required for farms having >3 LU/ha; added as condition in additional
*     equation to use binary trigger

      manStorCapGVDepend_(curManChain(manChain),tCur(t),nCur) $ t_n(t,nCur) ..

            v_TotalManStorCap(manChain,t,nCur)
                     =g= v_manQuant(manChain,t,nCur) *  p_ManureStorageNeedGV
                                        - ( (1 -  v_triggerStorageGVha(t,%nCur%) ) * p_bigNumber ) ;

$endif.herd


*
* ---- 6) Restriction of fertilizer application in autumn
*


      NLimitAutumn_ (c_p_t_i(curCrops(crops),plot,till,intens),t_n(tCur(t),nCur))
                              $ (v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0) ..


$iftheni.man %manure% == true

                     sum( (manChain_type(curManChain,curManType),manApplicType_manType(ManApplicType,curManType),nut2N,m)
                          $ ((v_manDist.up(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m) ne 0)  $ monthHarvestBlock(crops,m)),
                                v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                                    *   p_nut2inMan(nut2N,curManType,curManChain) )

$endif.man

                     +    sum( (syntFertilizer,m) $ monthHarvestBlock(crops,m),
                              v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)
                                 *   p_nutInSynt(syntFertilizer,"N")  )

                      =l=       v_cropHa(crops,plot,till,intens,t,%nCur%)  *   p_NLimitInAutumn(crops,plot)

                       ;


*
* --- 7) Requirement of growing catch crops before summer crops in nitrate polluted zones (only FO 2020)
*

      CatchCropRequiredFO_(tCur(t),nCur) $t_n(t,nCur) ..

      sum(c_p_t_i(curCrops(Crops),plotInNO3zone,till,intens)
                 $catchcrops(crops), v_cropHa(crops,plotInNO3zone,till,intens,t,%nCur%))
            =g=

         sum( c_p_t_i(curCrops(crops),plotInNO3zone,till,intens) $ summerHarvest(Crops),
                                           v_cropHa(crops,plotInNO3zone,till,intens,t,%nCur%) ) * p_CatchCropRequFO ;



 model m_duev /

    synthAppliedDueV_
    nutBalDueV_
    nutRemovalDuev_
    nutSurplusDueVRestr_

    FertQuota_
    FertQuotaNZone_
    FertQuotaInput_
    FertQuotaNeed_


    $$iftheni.manure "%manure%"=="true"


    DuevOrgN_
    DuevOrgNLimit_
    DuevOrgNLimitCrop_
    NLimitAutumn_



    $$endif.manure

    $$iftheni.herd "%herd%"=="true"

       nutExcrDueV_
       triggerStorageGVha_
       manStorCapGVDepend_

    $$endif.herd

    $$iftheni.biogas %biogas% == true
        nutBiogasDuev_
        nutBiogasDueVAccAL_
    $$endif.biogas


*    FarmGateAllowedSaldo_
  $$iftheni.fb "%farmgateBalance%" == "true"
    FarmGateInput_
    FarmGateOutput_
    FarmGateSaldo_
    FarmGateBalRestr_
  $$endif.fb
*    nutOrganicOverNeed_
 CatchCropRequiredFO_

/;
