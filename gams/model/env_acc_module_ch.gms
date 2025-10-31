********************************************************************************
$ontext

   FARMDYN project

   GAMS file : ENV_ACC_MODULE.GMS

   @purpose  : Equations to calculate different environmental impacts

   @author   : T.Kuhn, W.Britz
   @date     : 22.07.15
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : templ.gms

$offtext
********************************************************************************

  Variable

       v_emissions(chain,source,emissions,t,n)        "Calculation of emissions"
       v_emiCrops(crops,chain,source,emissions,t,n)   "Calculation of emissions from cropping"
$ifi %herd% == true  v_emiherds(herds,breeds,chain,source,emissions,t,n) "Calculation of emissions from herds"
       v_emiOther(chain,source,emissions,t,n)         "Other emissions not relatable to individual crops or herds"
       v_leach(t,n)                                   "Leached N per year"
       v_leachcrops(crops,t,n)                        "Leached N per crop and year"
       v_lossPhosCrops(crops,t,n)                     "Phosphorus losses through several passways per crop and year"
       v_lossPhos(t,n)                                "Phosphorus losses through several passways per year"
       v_humBalCrops(crops,t,n)                       "Humus balance per crop and year"
       v_humBal(t,n)                                  "Humus balance per year"
       v_emissionsMass(chain,source,emissions,t,n)    "Calculation of actual mass of N emissions (from NH3-N to NH3)"
       v_emissionsYear(chain,source,emissions,t,n)    "Summarizing yearly emissions, in mass"
       v_emissionsCat(chain,source,emCat,t,n)         "Categorization of emissions according to ReCipe 2016"
       v_emissionsSum(emissions,t,n)                  "Summarizing yearly emissions over sources, not in mass"
       v_emissionsCatSum(emCat,t,n)                   "Summarizing yearly categorized emissions over sources and manChain"
  ;
  positive variable

      v_leachpositive(crops,t,n)
      v_leachnegative(crops,t,n)

      v_bioMassOutput(bioMassUnit,t,n)                "Biomass output in relation to different units"
      v_bioMassOutputProds(bioMassUnit,prods,t,n)     "Biomass output in relation to different units per prodoct"
$ifi %herd% == true  v_emiEntFerm(herds,breeds,Chain,source,emissions,t,n)
$ifi %herd% == true  v_emiEntFermRedB(herds,breeds,Chain,source,emissions,t,n)
$ifi %herd% == true  v_emiEntFermRedV(herds,breeds,Chain,source,emissions,t,n)

      ;

  Equations

       emissions_(chain,source,emissions,t,n)         "Calculation of emissions"
       emiCrops_(crops,chain,source,emissions,t,n)    "Calculation of emissions directly stemming from cropping"
$$iftheni.herd %herd% == true
emiherds_(herds,breeds,chain,source,emissions,t,n)     "Calculation of emissions directly stemming from animals"
emiEntFerm_(herds,breeds,chain,source,emissions,t,n)   "Calculation of emissions directly stemming from enteric fermentation"
$iftheni.endo "%endoMeasures%" == "true"
emiEntFermRedB1_(herds,breeds,chain,source,emissions,t,n)   "Reduction of emissions directly stemming from Bovaer in enteric fermentation"
emiEntFermRedB2_(herds,breeds,chain,source,emissions,t,n)   "Reduction of emissions directly stemming from Bovaer in enteric fermentation"
emiEntFermRedV1_(herds,breeds,chain,source,emissions,t,n)   "Reduction of emissions directly stemming from VegOil inenteric fermentation"
emiEntFermRedV2_(herds,breeds,chain,source,emissions,t,n)   "Reduction of emissions directly stemming from VegOil in enteric fermentation"
$endif.endo
$$endif.herd
       emiOther_(chain,source,emissions,t,n)         "Other emissions not relatable to individual crops or herds"
       leachTotal_(t,n)                             "Leached N per year and ha"
       leachCrops_(crops,t,n)                       "Leached N per crop, year and ha"
       slackLeach_(crops,t,n)                       "Leached N per crop, year and ha"
       finalLeach_(crops,t,n)                       "Leached N per crop, year and ha"
       lossPhosCrops_(crops,t,n)                    "Phosphorus losses through multiple passways per crop and year"
       lossPhos_(t,n)                               "Phosphorus losses through multiple passways per year"
       humBal_(t,n)                                 "Humus balance per year"
       humBalCrops_(crops,t,n)                      "Humus balance per crop and year"
       emissionsMass_(chain,source,emissions,t,n)   "Calculation of actual mass of N emissions (from NH3-N to NH3)"
       emissionsYear_(chain,source,emissions,t,n)   "Summarizing yearly emissions"
       emissionsCat_(chain,source,emCat,t,n)        "Categorization of emissions according to ReCipe 2016"
       emissionsSum_(emissions,t,n)                 "Summarizing yearly emissions over sources"
       emissionsCatSum_(emCat,t,n)                  "Summarizing yearly emissions by categories "

       bioMassOutput_(biomassUnit,t,n)              "Quantification of biomass output related to different units"
       bioMassOutputProds_(biomassUnit,prods,t,n)   "Quantification of biomass output related to different units per product"

         ;

$ifi %herd% == true scalar p_MentFerm /1000000/;

*
* --- all monthly emissions, differentiated by emissions from herds, cropping and not allocatable emissions
*

  emissions_(chain_source(curChain,source),emissions,t_n(t,nCur)) $ (tCur(t) $ source_emissions(source,emissions)  $ envAcc )  ..

     v_emissions(curChain,source,emissions,t,nCur)

       =E=
$iftheni.h %herd% == true
       sum((singleHerds(herds),breeds)$ ( sum(actHerds(herds,breeds,feedRegime,t,m),1) $ source_emiHerd(source,emissions)),
                                                 v_emiherds(herds,breeds,curChain,source,emissions,t,nCur))
$endif.h
           + sum(curCrops $ source_emiCrops(source,emissions), v_emiCrops(curCrops,curChain,source,emissions,t,nCur) )

           + v_emiOther(curChain,source,emissions,t,nCur)

;

*
* --- Emissions directly related to crop production per crop and month
*


emicrops_(curCrops,chain_source(curChain,source),emissions,t_n(t,nCur)) $ (tCur(t) $ source_emiCrops(source,emissions)  $ envAcc )  ..

   v_emiCrops(curCrops,curChain,source,emissions,t,nCur)

   =E=

*  --- Calculation of CH4 from storage according to Haenel et al. (2018) p. 42 No. 3.28 and 3.29 Following IPCC, 2006, eq. 10.23;
*      in kg CH4 per month
*   Pasture:
*
   $$iftheni.ch %cattle% == true

        + [  sum( (c_p_t_i(curCrops,plot,till,"graz"),curManChain,m),  v_manQuantPast(curCrops,plot,till,"graz",curManChain,t,nCur,m)
                   *  1000 * p_avDmMan(curManchain) * p_oTSMan(curManChain) * p_BO(curManchain)
                   * p_densM * p_MCFPast)
          ] $ ( sameas(emissions,"CH4") $ sameas(source,"past") $ grasCrops(curCrops))


*     --- Calculation of NH3, N2O, NO and N2 losses from manure excretion on pasture for cattle according to Haenel et al. (2018)p.55 and p.332 and IPCC(2006)-11.6 ff
*         in kg NH3-N, N2O-N, NO-N and N2 per month

        + [
              + sum((c_p_t_i(curCrops,plot,till,intens),m)
                         $ ( (p_grazMonth(curCrops,m)>0) $ sum(actHerds(possHerds,breeds,grazRegime,t,m)
                          $ sum(nut2,p_nutExcreDueV(possHerds,grazRegime,nut2)),1)),

                     v_nut2ManurePast(curCrops,plot,till,intens,"NTAN",t,nCur,m)
                      * (  p_EFPasture("NH3")       $ sameas(emissions,"NH3")  )

                  +  (   v_nut2ManurePast(curCrops,plot,till,intens,"NTAN",t,nCur,m)
                       + v_nut2ManurePast(curCrops,plot,till,intens,"Norg",t,nCur,m))
                      * (  p_EFPasture("N2O")        $ sameas(emissions,"N2O")
                         + p_EFPasture("NOx")        $ sameas(emissions,"NOx")
                         + p_EFPasture("N2")         $ sameas(emissions,"N2")
                         ))

*     --- Calculation of N2Oind from manure excretion on grassCropsure for cattle
*         in kg N2O-N per month
                + (( v_emiCrops(curCrops," ","past","NH3",t,nCur) + v_emiCrops(curCrops," ","past","NOx",t,nCur))
                     * p_EFN2Oind ) $ sameas(emissions,"N2Oind")

          ] $ (sameas(source,"past") $ grasCrops(curCrops))

$$endif.ch

$iftheni.man %manure% == true

*     --- Calculation of NH3, N2O, NOx, N2 from manure application
*         NH3 losses depending on technology, source EMEP (2016)p.22ff for NH3; IPCC (2006)-11.7 for N2O; EMEP (2016)-3.D-11 for NOx
*         in kg NH3-N, N2O-N, NO-N and N2 per month:

     + [   sum( (c_p_t_i(curCrops,plot,till,intens),manApplicType_manType(ManApplicType,curManType),m)
                           $ (sum(sameas(curChain,curManChain) $ manChain_type(curManChain,curManType),1)
                           $ (not catchcrops(curcrops))),
              v_manDist(curCrops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                      * sum(manChain,p_nut2inMan("NTAN",curManType,manChain))
                  * p_EFapplMan(curCrops,curManType,manApplicType,"NTAN",m)) $ sameas(emissions,"NH3")

         + sum((sameas(curManChain,curChain),nut2,m) $ (not sameas(nut2,"P")),
                    v_nut2ManApplied(curCrops,curManChain,nut2,t,nCur,m)
                         * (    p_EFApplMin("N2O") $ sameas(emissions,"N2O")
                              + p_EFApplMin("NOx") $ sameas(emissions,"NOx")
                              + p_EFApplMin("N2")  $ sameas(emissions,"N2")))

         + (sum(sameas(curManChain,curChain) ,  v_emiCrops(curCrops,curChain,"manAppl","NH3",t,nCur)
                                              + v_emiCrops(curCrops,curChain,"manAppl","NOx",t,nCur))
                               * p_EFN2Oind ) $ sameas(emissions,"N2Oind")

       ] $ sameas(source,"manAppl")

$endif.man

*    --- Calculation of NH3, N2O, NOx, N2 from mineral fertilizer application
*        Based on IPCC (2006)-11.7 for N2O; EMEP (2016)-3.D-11 for NOx, Roesemann et al. 2015, pp. 316-317 for N2
*         in kg NH3-N, N2O-N, NO-N and N2 per month

     + [sum( (c_p_t_i(curcrops,plot,till,intens),curInputs(syntFertilizer),m),
                      v_syntDist(curCrops,plot,till,intens,syntFertilizer,t,nCur,m)  * p_nutInSynt(syntFertilizer,"N")
                 * (    p_EFApplMinNH3(syntFertilizer) $ sameas(emissions,"NH3")
                      + p_EFApplMin("N2O") $ sameas(emissions,"N2O")
                      + p_EFApplMin("NOx") $ sameas(emissions,"NOx")
                      + p_EFApplMin("N2")  $ sameas(emissions,"N2")))

             + (( v_emiCrops(curCrops," ","minAppl","NH3",t,nCur) + v_emiCrops(curCrops," ","minAppl","NOx",t,nCur))
                           * p_EFN2Oind ) $ sameas(emissions,"N2Oind")
       ] $  sameas(source,"minAppl")

*  --- Calculation of N2O emissions from crop residues on field in kg N2O-N per month; devided by 12 to account for monthly resolution; IPCC(2006)-11.11 ff

    + [(  sum(c_p_t_i(curcrops,plot,till,intens),
*     --- arable land residues abvove ground
           + v_cropHa(curCrops,plot,till,intens,t,%nCur%)
            * sum( (plot_soil(plot,soil),curProds) $ p_OCoeffC%l%(curCrops,soil,till,intens,curProds,t), p_OCoeffC(curCrops,soil,till,intens,curProds,t) * 1000)
             * p_cropResi(curCrops,"duration") * p_cropResi(curCrops,"freqHarv") *  p_cropResi(curCrops,"aboveRat") * p_cropResi(curCrops,"aboveN")

*     --- arable land residues below ground
           + v_cropHa(curCrops,plot,till,intens,t,%nCur%) *  sum( (plot_soil(plot,soil),curProds) $ p_OCoeffC%l%(curCrops,soil,till,intens,curProds,t) ,
              p_OCoeffC(curCrops,soil,till,intens,curProds,t) * 1000)
              * p_cropResi(curCrops,"duration") * p_cropResi(curCrops,"freqHarv")
              * ( p_cropResi(curCrops,"DMyield")$(not sameas(curCrops,"potatoes") and not sameas(curCrops,"sugarBeet"))
               + p_cropResi(curCrops,"aboveRat") * p_cropResi(curCrops,"DMresi"))
               * p_cropResi(curCrops,"belowRat") * p_cropResi(curCrops,"belowN")  )

*      --- deduction for straw removal
            -sum( c_p_t_i(curcrops,plot,till,intens) $ cropsResidueRemo(curCrops),  v_residuesRemoval(curCrops,plot,till,intens,t,nCur)
                * sum( (plot_soil(plot,soil),prodsResidues), 10 * p_OCoeffResidues(curCrops,soil,till,intens,prodsResidues,t)
                                                                   * p_nutContent(curCrops,prodsResidues,"conv","N")))

      )  * p_EFApplMin("N2O")
     ] $ ( sameas (emissions,"N2O") $ sameas (source,"field"))

* --- Calculation of CO2 emissions from liming in kg CO2 per month; divided by 12 for monthly resolution; IPCC (2006) 11.27

     +  [  sum(c_p_t_i(curcrops,plot,till,intens) $ (p_costQuant(curCrops,till,intens,"lime")),
              v_cropHa(curCrops,plot,till,intens,t,%nCur%)
                 * p_inputQuant(curCrops,till,intens,"lime","")
                      *  p_EFLime("lime"))
        ] $ ( sameas (emissions,"CO2") $ sameas (source,"field"))

*   ---- Combustion of diesel related to the total consumption on the field
                  + [
                      sum((machtype,machLifeUnit) $( p_lifeTimeM(machType,machLifeUnit) $ sameas(machLifeUnit,"hour")),
                            sum(c_p_t_i(curCrops,plot,till,intens),
                                  v_cropHa(curCrops,plot,till,intens,t,%nCur%)
                                      * p_machNeed(curCrops,till,intens,machType,machLifeUnit)
                                            * (p_machAttr(machType,"diesel_h")  * p_efDiesel("Diesel"))
                                )
                          )
                    ] $sameas(source,"field") $ sameas(emissions,"CO2")

*   ---- [Currently not applicable as manure spreading is done by contract work
*        Manure application depending on the application type/technique when investments are turned on
          $$iftheni.manure "%manure%" == true
            + [
               sum((machtype,machLifeUnit) $( p_lifeTimeM(machType,machLifeUnit) $ sameas(machLifeUnit,"hour")),
                    sum((c_p_t_i(curCrops(crops),plot,till,intens),manApplicType_manType(ManApplicType,curManType),m)
                        $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0),
                              v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                                   * p_machNeed(ManApplicType,"plough","normal",machType,machLifeUnit)))
               ] $sameas(source,"machine") $ sameas(emissions,"CO2_eq")

          $$endif.manure

* --- Calculation of particulate matter emission from cropping EMEP(2016) 3D p.19,
*     if upstream emissions are considered this is included in machine operations

$$iftheni.eco  not "%upstreamEF%" == "true"
   +  [  sum(c_p_t_i(curcrops,plot,till,intens),
            v_cropHa(curCrops,plot,till,intens,t,%nCur%)
                  * sum((operation,labperiod), p_crop_op_per_till(curCrops,Operation,labPeriod,till,intens)
                             * p_EFpmfCrops(curCrops,operation,emissions) ))
      ]   $ sameas(source,"field")
$$else.eco

* *****************************
*
* --- Database KTBL Web-Anwendung, Partly EcoInvent 3.X based
*
* *****************************

* --- Upstream emission from pesticides (herb,fung,insect), growth control and lime emissions

      +  [ sum( (c_p_t_i(curcrops,plot,till,intens),inputs) $ (p_costQuant(curCrops,till,intens,inputs)
                                                            $ (not sameas(inputs,"seed"))),
                v_cropHa(curCrops,plot,till,intens,t,%nCur%)
                        * p_inputQuant(curCrops,till,intens,inputs,"")
                                  * p_EFInput(inputs,emissions))
       ] $ ( sameas (emissions,"CO2_eq") $ sameas (source,"input"))


* --- Upstream emissions (input) related to the production of synthetic fertilizer

     +  [  sum( (c_p_t_i(curcrops,plot,till,intens),sameas(inputs,syntFertilizer),m),
                  v_syntDist(curCrops,plot,till,intens,syntFertilizer,t,nCur,m) * p_EFInput(syntFertilizer,emissions))
        ] $sameas(source,"input") $ sameas(emissions, "CO2_eq")


*   ---- Upstream emissions (input) related to the used and purchased diesel
           + [
               sum((machtype,machLifeUnit) $( p_lifeTimeM(machType,machLifeUnit) $ sameas(machLifeUnit,"hour")),
                     sum(c_p_t_i(curCrops,plot,till,intens),
                           v_cropHa(curCrops,plot,till,intens,t,%nCur%)
                               * p_machNeed(curCrops,till,intens,machType,machLifeUnit)
                                     * (p_machAttr(machType,"diesel_h")  * p_EFInput("diesel",emissions))
                         )
                   )
             ] $sameas(source,"machine") $ sameas(emissions,"CO2_eq")
$$endif.eco
;
* ***
*
* --- Emissions directly relateable to herds per herd
*
* ***
$iftheni.h %herd% == true

$$iftheni.ch %cattle% == true
emiEntFerm_(singleHerds(herds),breeds,chain_source(curChain,source),emissions,t_n(t,nCur)) $ (tCur(t) $ source_emiHerd(source,emissions)
                                $ envAcc $ sum(actHerds(herds,breeds,feedRegime,t,m),1) $ sameas(source,"entFerm")) ..
       
     v_emiEntFerm(herds,breeds,curChain,source,emissions,t,nCur) =E=       
    [
$ifi "%mitiMeasures%" == true $$ifi "%feedAddOn%" == true  sum(feeds,p_feedAdd(feeds)) *          
          {(+  sum(curFeeds(feeds),p_feedContFMton(feeds,"GE")
                 * sum((feedregime,reqsPhase,m) $ (feedRegime_feeds(feedRegime,curFeeds)
                                                      $ actHerdsf(herds,breeds,feedRegime,reqsphase,m)),
                            v_feeding(herds,breeds,feedRegime,reqsPhase,m,curfeeds,t,nCur) *
                                  [     p_Ym("dcows","") $  sum(sameas(herds,dcows),1)
                                     +  p_Ym("mcows","") $  sum(sameas(herds,mcows),1)
               $$ifi defined heifs   +  p_Ym("heifs","") $  sum(sameas(herds,heifs),1)
               $$ifi defined bulls   +  p_Ym("bulls","") $  sum(sameas(herds,bulls),1)
                                     +  p_Ym("calvs","") $  sum(sameas(herds,calvs),1) ]))
      
    )/(100 * 55.65)}
$iftheni.endo "%endoMeasures%" == "true"   
    - v_emiEntFermRedB(herds,breeds,curChain,source,emissions,t,nCur)   
    - v_emiEntFermRedV(herds,breeds,curChain,source,emissions,t,nCur)  
$endif.endo    
    
    ]    $ ( sameas(emissions,"CH4") $ sameas(source,"entFerm")  ) 


     
;

$iftheni.endo "%endoMeasures%" == "true"
* --- Here we have to work with something which uses the trigger and greather than or equal to

emiEntFermRedB1_(singleHerds(herds),breeds,chain_source(curChain,source),emissions,t_n(t,nCur)) $ (tCur(t) $ source_emiHerd(source,emissions)
                                $ envAcc $ sum(actHerds(herds,breeds,feedRegime,t,m),1) $ sameas(source,"entFerm")) ..

     v_emiEntFermRedB(herds,breeds,curChain,source,emissions,t,nCur) - ((1-v_triggerBovaer(t,nCur)) * p_MentFerm) =L=       


    [(+  sum(curFeeds(feeds),p_feedContFMton(feeds,"GE")
                 * sum((feedregime,reqsPhase,m) $ (feedRegime_feeds(feedRegime,curFeeds)
                                                      $ actHerdsf(herds,breeds,feedRegime,reqsphase,m)),
                            v_feeding(herds,breeds,feedRegime,reqsPhase,m,curfeeds,t,nCur) *
                                  [     
                                        p_YmRedB("dcows","") $  sum(sameas(herds,dcows),1)
                                     +  p_YmRedB("mcows","") $  sum(sameas(herds,mcows),1)
               $$ifi defined heifs   +  p_YmRedB("heifs","") $  sum(sameas(herds,heifs),1)
               $$ifi defined bulls   +  p_YmRedB("bulls","") $  sum(sameas(herds,bulls),1)
                                     +  p_YmRedB("calvs","") $  sum(sameas(herds,calvs),1) ]))
    )/(100 * 55.65)]    $ ( sameas(emissions,"CH4") $ sameas(source,"entFerm")  )   
;

emiEntFermRedB2_(singleHerds(herds),breeds,chain_source(curChain,source),emissions,t_n(t,nCur)) $ (tCur(t) $ source_emiHerd(source,emissions)
                                $ envAcc $ sum(actHerds(herds,breeds,feedRegime,t,m),1) $ sameas(source,"entFerm")) ..
   
     v_emiEntFermRedB(herds,breeds,curChain,source,emissions,t,nCur) $ ( sameas(emissions,"CH4") $ sameas(source,"entFerm"))
                                    - v_triggerBovaer(t,nCur) * p_MentFerm =L= 0;      


emiEntFermRedV1_(singleHerds(herds),breeds,chain_source(curChain,source),emissions,t_n(t,nCur)) $ (tCur(t) $ source_emiHerd(source,emissions)
                                $ envAcc $ sum(actHerds(herds,breeds,feedRegime,t,m),1) $ sameas(source,"entFerm")) ..

     v_emiEntFermRedV(herds,breeds,curChain,source,emissions,t,nCur) - ((1-v_triggervegOil(t,nCur)) * p_MentFerm) =L=       


    [(+  sum(curFeeds(feeds),p_feedContFMton(feeds,"GE")
                 * sum((feedregime,reqsPhase,m) $ (feedRegime_feeds(feedRegime,curFeeds)
                                                      $ actHerdsf(herds,breeds,feedRegime,reqsphase,m)),
                            v_feeding(herds,breeds,feedRegime,reqsPhase,m,curfeeds,t,nCur) *
                                  [     
                                        p_YmRedB("dcows","") $  sum(sameas(herds,dcows),1)
                                     +  p_YmRedB("mcows","") $  sum(sameas(herds,mcows),1)
               $$ifi defined heifs   +  p_YmRedB("heifs","") $  sum(sameas(herds,heifs),1)
               $$ifi defined bulls   +  p_YmRedB("bulls","") $  sum(sameas(herds,bulls),1)
                                     +  p_YmRedB("calvs","") $  sum(sameas(herds,calvs),1) ]))
    )/(100 * 55.65)]    $ ( sameas(emissions,"CH4") $ sameas(source,"entFerm")  )   
;

emiEntFermRedV2_(singleHerds(herds),breeds,chain_source(curChain,source),emissions,t_n(t,nCur)) $ (tCur(t) $ source_emiHerd(source,emissions)
                                $ envAcc $ sum(actHerds(herds,breeds,feedRegime,t,m),1) $ sameas(source,"entFerm")) ..
   
     v_emiEntFermRedV(herds,breeds,curChain,source,emissions,t,nCur) $ ( sameas(emissions,"CH4") $ sameas(source,"entFerm"))
                                    - v_triggervegOil(t,nCur) * p_MentFerm =L= 0;        
      $$endif.endo
$$endif.ch

 emiherds_(singleHerds(herds),breeds,chain_source(curChain,source),emissions,t_n(t,nCur)) $ (tCur(t) $ source_emiHerd(source,emissions)
                                $ envAcc $ sum(actHerds(herds,breeds,feedRegime,t,m),1)) ..

    v_emiherds(herds,breeds,curChain,source,emissions,t,nCur)

      =E=
*     --- Calculation of CH4 emissions from enteric fermentation linked to gross energy intake (IPCC, 2006, eq. 10.21)
*         in kg CH4 per month (yearly emissions averaged for monthly reporting),

         + v_emiEntFerm(herds,breeds,curChain,source,emissions,t,nCur) $ ( sameas(emissions,"CH4") $ sameas(source,"entFerm")  )  

*     --- Calculation of NH3, N2O, NOx, N2, N2Oind from stable and storage (staSto) Haenel et al. 55

  +    [


         sum((sameas(curManChain,curChain),m) $ sum(actherds(herds,breeds,feedregime,t,m),1),
                  (v_nut2ManureHerds(herds,breeds,curManChain,"NTAN",t,nCur,m)  $ (not sameas(curmanchain,"LiquidBiogas"))
                                              * (p_EFSta("NH3",curManChain) + p_EFSto("NH3",curManChain)))) $( sameas(emissions,"NH3"))

        + sum((sameas(curManChain,curChain),m) $ sum(actherds(herds,breeds,feedregime,t,m),1),
                                            (v_nut2ManureHerds(herds,breeds,curManChain,"NTAN",t,nCur,m)$ (not sameas(curmanchain,"LiquidBiogas"))
                                          +  v_nut2ManureHerds(herds,breeds,curManChain,"NOrg",t,nCur,m)$ (not sameas(curmanchain,"LiquidBiogas")))
                                          *  ( p_EFStaSto("N2O",curManChain)    $ sameas(emissions,"N2O")
                                             + p_EFStaSto("NOx",curManChain)    $ sameas(emissions,"NOx")
                                             + p_EFStaSto("N2",curManChain)     $ sameas(emissions,"N2")
                                             ))

        + (sum(sameas(curManChain,curChain), v_emiHerds(herds,breeds,curChain,"stasto","NOx",t,nCur)
                                            + v_emiHerds(herds,breeds,curChain,"stasto","NH3",t,nCur)
                                            ) * p_EFN2Oind ) $ sameas(emissions,"N2Oind")
      ]  $ sameas(source,"staSto")

* --- Calculation of particulate matter emission from animal husbandry EMEP(2013)
*     3.3(“Tier 2 technology-specific approach“), Haenel et al (2018) p.66

   +  [ sum((actHerds(herds,breeds,feedRegime,t,m),sameas(curmanchain,curChain))
            $ (p_manQuantMonth(herds,curManChain) $ p_prodLength(herds,breeds)),
                  v_herdSize(herds,breeds,feedRegime,t,nCur,m)  *  p_EFpmfHerds(herds,feedregime,curmanchain,emissions)/12 )
      ]   $ sameas(source,"staSto")


 $$iftheni.eco "%upstreamEF%" == "true"

* --- Calculation of emissions from machine provision and use related to herds

     +  [  sum((machtype,machLifeUnit) $ p_lifeTimeM(machType,machLifeUnit),

              sum(actHerds(herds,breeds,feedRegime,t,m) $ p_prodLength(herds,breeds),
                 v_herdSize(herds,breeds,feedRegime,t,nCur,m)
                  * p_machNeed(herds,"plough","normal",machType,machLifeUnit)
                              * 1/min(12,p_prodLength(herds,breeds)))

                  * (p_machAttr(machType,"diesel_h") * p_EFInput("diesel",emissions) ) $(sameas(machType,"tractorSmall") $sameas(machLifeUnit,"hour"))
                  )
        ] $sameas(source,"machine")$((not sum(sameas(sumherds,herds),1)) or sum(sameas(calvsRais,herds),1) )
 $$endif.eco
$endif.h
;


*
*   --- Other emissions not allocatable in model
*

emiOther_(curChain,source,emissions,t_n(t,nCur)) $ (tCur(t)  $ envAcc $source_emissions(source,emissions) $chain_source(curChain,source))  ..

   v_emiOther(curChain,source,emissions,t,nCur)

     =E=
     $$iftheni.man %manureStorage% == true

*  --- Calculation of CH4 from storage according to Haenel et al. (2018) p. 42 No. 3.28 and 3.29 Following IPCC, 2006, eq. 10.23;  in kg CH4 per month
         +   [  sum( (sameas(curManChain,curChain),manStorage,m),   v_volInStorageType(curManChain,manStorage,t,nCur,m)
                         *  1000 * p_avDmMan(curManChain) * p_oTSMan(curManChain) * p_BO(curManChain)
                         * p_densM * p_MCF(Manstorage,curManChain)
                         /12)
             ] $ ( sameas(emissions,"CH4") $ sameas(source,"staSto")  )
     $$endif.man
 $$iftheni.eco "%upstreamEF%" == "true"
*
*   --- Crop storages (Please check if these factors (p_EFBUild) are per month?
*
        +  [
                sum( (buildType_buildings(buildType,buildings),buildCapac)  $ curBuildings(buildings),
                            v_buildingsInv(buildings,t,nCur) * p_building(buildings,buildCapac)

                            * p_EFBuild(buildings,buildType,emissions)*12)
           ]$sameas(source,"building")

*   --- Manure storages (storage in stables is included in stables)
        $$iftheni.man %manure% == true
        +  [ sum( (sameas(curManChain,curChain),silos,manStorage),
                 v_siCovComb(curManChain,silos,t,nCur,manStorage)  * p_EFSilo(silos,manStorage,emissions)*12 )
           ]$sameas(source,"silo")
        $$endif.man
*   --- Stables
        $$iftheni.h %herd% == true
        +  [sum((stableTypes_to_stables(stableTypes,stables),hor),
                              v_stableInv(stables,hor,t,nCur) * p_stableSize(stables,stableTypes) * p_EFStable(stables,hor,emissions))

           ]$sameas(source,"stable")

*   --- Machines linked to stables
*        +  [ sum(machType,v_machInv(machType,"years",t,nCur) * p_EFmachines(machType,"years",emissions) )  ]$sameas(source,"machine")


* --- Calculation of emissions from bought inputs not directly allocatable to a certain crop or to a certain herd
         $$iftheni.cat %cattle% == true
        +  [
                     sum(sys$ p_inputPrice%l%("straw",sys,t),     v_buy("straw",sys,t,nCur)  *  p_EFInput("straw",emissions))
           ]$sameas(source,"straw")

        +   [ sum((sameas(feeds,inputs)) $ sum(sys $p_inputPrice%l%(inputs,sys,t),1),
                           v_feedusebuy(feeds,t,nCur)  *  p_EFInput(inputs,emissions))

           ]$sameas(source,"input")
          $$endif.cat
        $$endif.h
  $$endif.eco

  +0.0
;


*
* --- Calculation of leaching on farm level adapted from SALCA NO3 (Richner (2014)) in kg NO3-N per year
*     (only for crops with a nutrient need, exempts idling land, flowerstripes etc.)
*
 leachCrops_(curCrops,t_n(tCur(t),nCur)) $( sum((c_p_t_i(curCrops,plot,till,intens),plot_soil(plot,soil)),p_nutNeed(curCrops,soil,till,intens,"N",t))
                                          $ envAcc ) ..

    v_leachCrops(curCrops,t,ncur) =e=

*    --- leached N from applied manure
    $$iftheni.h %herd% ==true
        sum( (plot,till,intens,manApplicType_manType(ManApplicType,curManType),m)
                 $ (manApplicType_manType(ManApplicType,curManType)
                 $ (v_manDist.up(curCrops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0)
                 $ ( not catchcrops(curcrops) ) $c_p_t_i(curCrops,plot,till,intens)),
            v_manDist(curCrops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                 * sum(curManChain, p_nut2inMan("NTAN",curManType,curManChain))  * p_EfLeachFert(curCrops,m)  )

                 -  sum( (curChain,NiEmissions(Emissions)) $ chain_source(curChain,"manAppl"),
                       v_emiCrops(curCrops,curChain,"manAppl",emissions,t,nCur) )
    $$endif.h

*    --- leached N from applied mineral fertilizer
      + sum( (plot,till,intens,syntFertilizer,m)$c_p_t_i(curCrops,plot,till,intens),
            v_syntDist(curCrops,plot,till,intens,syntFertilizer,t,nCur,m) * p_nutInSynt(syntFertilizer,"N")  * p_EfLeachFert(curCrops,m) )

            -  sum( (curChain,NiEmissions(Emissions)) $ chain_source(curChain,"minAppl"),
                  v_emiCrops(curCrops,curChain,"minAppl",emissions,t,nCur) )

*    --- leached N from mineralization

     +  sum((plot,till,intens,m)$c_p_t_i(curCrops,plot,till,intens), p_LeachNorm(m) * v_cropHa(curCrops,plot,till,intens,t,%nCur%))

*    ---  correction of mineralisation for longterm effects of organic fertilization (+10% per DGVE per ha; 1DGVE = 110kgN/h and a)

  $$iftheni.h %herd% ==true
    +  sum( m,p_LeachNorm(m)) * 0.1
      *  [sum( (plot,till,intens,manApplicType_manType(ManApplicType,curManType),m)
              $ ( (v_manDist.up(curCrops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0)
                  $( not catchcrops(curcrops) )  $c_p_t_i(curCrops,plot,till,intens)),

                 v_manDist(curCrops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                   * (sum(manChain,p_nut2inMan("NORG",curManType,manChain))
                   +  sum(manChain,p_nut2inMan("NTAN",curManType,manChain)) )   )

                  -  sum( (curChain,NiEmissions(Emissions)) $ chain_source(curChain,"manAppl"),
                        v_emiCrops(curCrops,curChain,"manAppl",emissions,t,nCur)) -110  ]/110
  $$endif.h

*    --- additional mineralization in month with intensive cultivation operation

   +  sum( (plot,till,intens,m)$(c_p_t_i(curCrops,plot,till,intens) $sum(arabCrops(crops)$sameas(crops,arabcrops),1)),
          p_CfIntensTill(m,curCrops)* p_CfNLeachTill(m) * v_cropHa(curCrops,plot,till,intens,t,%nCur%) )

*      --- correction for reduced mineralization under grassland
  -  sum[ (plot,till,intens) $(c_p_t_i(curCrops,plot,till,intens) $ sum(grasCrops(crops)$sameas(crops,grascrops),1)),
         v_cropHa(curCrops,plot,till,intens,t,%nCur%) * p_CfNLeachGrass(curCrops) ]

*     --- plant removal deduction
    -   sum ( (plot_soil(plot,soil),till,intens) $c_p_t_i(curCrops,plot,till,intens),
                  p_nutNeed(curCrops,soil,till,intens,"N",t) * v_cropHa(curCrops,plot,till,intens,t,%nCur%))

*     --- leaching from grazed pastures

    $$iftheni.ch %cattle% == true
 +
          sum((plot,till,intens,m)
                      $ ( (p_grazMonth(curCrops,m)>0) $ sum(actHerds(possHerds,breeds,grazRegime,t,m)
                      $ sum(nut2,p_nutExcreDueV(possHerds,grazRegime,nut2)),1)
                      $c_p_t_i(curCrops,plot,till,intens)),
                (   v_nut2ManurePast(curCrops,plot,till,intens,"NTAN",t,nCur,m)
                  + v_nut2ManurePast(curcrops,plot,till,intens,"NORG",t,nCur,m)

                  - sum((curChain,NiEmissions(Emissions)) $ (chain_source(curChain,"past")) ,
                           v_emiCrops(curCrops,curChain,"past",emissions,t,nCur))/12

                )*p_leachPast(m)
            )$sum(grasCrops(crops)$sameas(crops,grascrops),1)

    $$endif.ch
;

* --- equations to filter for positive values only, negative emissions are not possible in this case

slackLeach_(curCrops,t_n(tCur(t),nCur)) $ (sum((c_p_t_i(curCrops,plot,till,intens),plot_soil(plot,soil)),p_nutNeed(curCrops,soil,till,intens,"N",t))
                                             $ envAcc) ..

  v_leachCrops(curCrops,t,nCur) - v_leachpositive(curCrops,t,nCur)+ v_leachnegative(curCrops,t,nCur) =E= 0;

finalLeach_(curCrops,t_n(tCur(t),nCur)) $ (sum((c_p_t_i(curCrops,plot,till,intens),plot_soil(plot,soil)),p_nutNeed(curCrops,soil,till,intens,"N",t))
                                             $ envAcc)..

 2* v_leachpositive(curCrops,t,nCur) =e= v_leachCrops(curCrops,t,nCur) + v_leachpositive(curCrops,t,nCur) + v_leachnegative(curCrops,t,nCur) ;

leachTotal_(t_n(t,nCur))  $ (tCur(t) $ envAcc) ..

        v_leach(t,nCur) =e=

      Sum(curCrops $ sum((c_p_t_i(curCrops,plot,till,intens),plot_soil(plot,soil)),p_nutNeed(curCrops,soil,till,intens,"N",t)),
          v_leachpositive(curCrops,t,nCur));

*
*  --- Calculation of phosphorus losses through erosion, leaching and runoff according to SALCA P (Prasuhn 2006)
*

lossPhosCrops_(curCrops(crops),t,nCur) $ (tCur(t) $ t_n(t,nCur) $ envAcc  )  ..

   v_lossPhosCrops(curCrops,t,nCur) =e=

*    --- Loss through erosion

      sum((plot,till,intens)$c_p_t_i(curCrops,plot,till,intens), v_cropHa(curCrops,plot,till,intens,t,%nCur%) * p_erosion * p_lossfactor * p_PContSoil * p_PAccuSoil  )

*    --- Loss through leaching grassland
$$iftheni.ch %cattle% == true

      + [sum((plot,till,intens)$c_p_t_i(curCrops,plot,till,intens), p_PLossLeach("grass") * p_soilFactLeach * p_PSoilClass * v_cropHa(curCrops,plot,till,intens,t,%nCur%))

         + p_PLossLeach("grass") * p_soilFactLeach * p_PSoilClass *
            sum((plot,till,intens,manApplicType_manType(manApplicType,curMantype),m) $(c_p_t_i(curCrops,plot,till,intens)$(not sameas (ManApplicType,"applSolidSpread"))),
                     p_PLossFert("low") * v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m) * sum((manChain),p_nut2inMan("P",curManType,manChain)))
        ]$sum(grasCrops(crops)$sameas(crops,grascrops),1)
$$endif.ch

*    --- Loss through leaching arable land

    +[ sum((plot,till,intens)$c_p_t_i(curCrops,plot,till,intens), p_PLossLeach("arable") * p_soilFactLeach * p_PSoilClass * v_cropHa(curCrops,plot,till,intens,t,%nCur%))
  $$iftheni.man %manure% == true

      + p_PLossLeach("arable") * p_soilFactLeach * p_PSoilClass * sum((plot,till,intens,manApplicType_manType(manApplicType,curMantype),m) $(c_p_t_i(curCrops,plot,till,intens)$(not sameas (ManApplicType,"applSolidSpread"))),
                        p_PLossFert("low") * v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m) * sum((manChain),p_nut2inMan("P",curManType,manChain)))

  $$endif.man
     ]$sum(arabCrops(crops)$sameas(crops,arabcrops),1)

*    --- loss thorugh runoff grassland
$$iftheni.ch %cattle% == true

      +[ sum((plot,till,intens)$c_p_t_i(curCrops,plot,till,intens), p_PLossRun("grass") * p_soilFactRun * p_PSoilClass * p_slopeFactor * v_cropHa(curCrops,plot,till,intens,t,%nCur%) )

            + p_PLossRun("grass") * p_soilFactRun * p_PSoilClass * p_slopeFactor *

                 ( sum((plot,till,intens,manApplicType_manType(manApplicType,curMantype),m) $(c_p_t_i(curCrops,plot,till,intens)$(not sameas (ManApplicType,"applSolidSpread"))),
                     p_PLossFert("high") * v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m) * sum((manChain),p_nut2inMan("P",curManType,manChain)))

                 + sum((plot,till,intens,manApplicType_manType(manApplicType,curMantype),m) $(c_p_t_i(curCrops,plot,till,intens)$sameas (ManApplicType,"applSolidSpread")),
                     p_PLossFert("medium") * v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m) * sum((manChain),p_nut2inMan("P",curManType,manChain)))

                 + sum((plot,till,intens,curInputs(syntFertilizer),m)$c_p_t_i(curCrops,plot,till,intens),
                     p_PLossFert("low") * v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m) * p_nutInSynt(syntFertilizer,"P"))  )
      ]$sum(grasCrops(crops)$sameas(crops,grascrops),1)
$$endif.ch
*    --- loss through runoff arable land

      +[ sum((plot,till,intens)$c_p_t_i(curCrops,plot,till,intens), p_PLossRun("arable") * p_soilFactRun * p_PSoilClass * p_slopeFactor * v_cropHa(curCrops,plot,till,intens,t,%nCur%) )

         + p_PLossRun("arable") * p_soilFactRun * p_PSoilClass * p_slopeFactor *  (

            $$iftheni.man %manure% == true
              sum((plot,till,intens,manApplicType_manType(manApplicType,curMantype),m) $(c_p_t_i(curCrops,plot,till,intens)$(not sameas (ManApplicType,"applSolidSpread"))),
                 p_PLossFert("high") * v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m) * sum((manChain),p_nut2inMan("P",curManType,manChain)))

            + sum((plot,till,intens,manApplicType_manType(manApplicType,curMantype),m) $(c_p_t_i(curCrops,plot,till,intens) $sameas (ManApplicType,"applSolidSpread")),
                 p_PLossFert("medium") * v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m) * sum((manChain),p_nut2inMan("P",curManType,manChain)))
            $$endif.man
            + sum((plot,till,intens,syntFertilizer,m)$c_p_t_i(curCrops,plot,till,intens),
                 p_PLossFert("low") * v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m) * p_nutInSynt(syntFertilizer,"P"))  )
       ]$sum(arabCrops(crops)$sameas(crops,arabcrops),1)
  ;

  lossphos_(t_n(t,nCur))  $ (tCur(t) $ envAcc) ..

          v_lossphos(t,nCur) =e= Sum(curCrops$ ( not (sameas(curCrops,"idle") or sameas (curCrops,"idlegras"))), v_lossphosCrops(curCrops,t,nCur));

*
*   ---   Humus balance according to VDLUFA(2010) only for arable
*

  humBalCrops_(curCrops(arabCrops),t_n(t,nCur))  $ (tCur(t) $ envAcc) ..

          v_humBalCrops(arabCrops,t,nCur) =e=

*  ---  C removal thorugh harvested products

                        - sum((plot,till,intens)$c_p_t_i(curCrops,plot,till,intens), v_cropHa(arabCrops,plot,till,intens,t,%nCur%) * p_humCrop(arabCrops) )

*  --- Additional humification if crop residues are incorporated

                        + sum( (plot,till,intens) $c_p_t_i(curCrops,plot,till,intens),  (v_cropHa(arabCrops,plot,till,intens,t,%nCur%) -v_residuesRemoval(arabCrops,plot,till,intens,t,nCur))
                               * sum( (plot_soil(plot,soil)),  p_resiCrop(arabCrops,soil,till,intens,t)) * p_resiInc(arabCrops))

*  ---  Deduction for straw removal

                        - sum( (plot,till,intens) $ (cropsResidueRemo(arabCrops)$c_p_t_i(curCrops,plot,till,intens)),  v_residuesRemoval(arabCrops,plot,till,intens,t,nCur)
                               * sum( (plot_soil(plot,soil),curProds), 10 * p_OCoeffResidues(arabCrops,soil,till,intens,curProds,t)) * p_resiInc(arabCrops))

* --- Addition through organic fertilizer inputs

$$iftheni.man %manure% == true
   + sum((plot,till,intens,manApplicType_manType(manApplicType,curMantype),m)$c_p_t_i(curCrops,plot,till,intens),
                                         v_manDist(arabCrops,plot,till,intens,ManApplicType,curManType,t,nCur,m) * p_humfact(ManApplicType) )
$endif.man
;
   humBal_(t_n(t,nCur))  $ (tCur(t) $ envAcc) ..

           v_humBal(t,nCur) =e= Sum(curCrops(arabCrops), v_humBalCrops(arabCrops,t,nCur));


*
*  --- Calculation of actual weight of N-emissions in kg NH3, N2O, NO and N2 per month
*
    emissionsMass_(chain_source(curChain,source),emissions,t_n(t,nCur)) $ (tCur(t) $ source_emissions(source,emissions)  $ envAcc  )   ..

         v_emissionsMass(curChain,source,emissions,t,nCur)  =e=

                       v_emissions(curchain,source,emissions,t,nCur) * p_corMass(emissions)
        ;

*
* --- Different emissions and sources per year, includes calculation of soil surface balance and N leaching
*     since monthly values do not make sense
*

  emissionsYear_(chain_source(curChain,source),emissions,t_n(t,nCur)) $ (tCur(t) $ source_emissions(source,emissions)  $ envAcc  )  ..

    v_emissionsYear(curChain,source,emissions,t,nCur)
        =e=  v_emissionsMass(curChain,source,emissions,t,nCur)


            +   (v_leach(t,nCur) * p_corMass("NO3"))  $ ( sameas(emissions,"NO3") $ sameas(source,"field") )
*    --- Calculation of indirect N2O emissions based on leached N based on Haenel et al. (2018) , p. 365 and IPCC (2006) Table 11.24 table 11.3)

            + [ v_leach(t,nCur) * p_EFN2OindLeach * p_corMass("N2Oind")] $ ( sameas(emissions,"N2Oind") $ sameas(source,"field") )


            +   v_lossPhos(t,nCur)   $ ( sameas(emissions,"P") $ sameas(source,"field") )  ;
*
*  --- Characterization of emission via ReCiPe 2016 in kg eq per year
*
   emissionsCat_(chain_source(curChain,source),emCat,t_n(t,nCur))$ (tCur(t) $ t_n(t,nCur) $ envAcc )..

       v_emissionsCat(curChain,source,emCat,t,ncur)  =e=
                     sum(source_emissions(source,emissions),
                           v_emissionsYear(curChain,source,emissions,t,nCur)  *  p_emCat(emCat,emissions));

*
* --- Different emissions per year (not in mass)
*
  emissionsSum_(emissions,t,nCur) $ (tCur(t) $ t_n(t,nCur) $ envAcc   )  ..

     v_emissionsSum(emissions,t,nCur)
      =e=      sum ( (chain_source(curChain,source),source_emissions(source,emissions)),
                        v_emissions(curChain,source,emissions,t,nCur) ) ;
*
* --- Different emissions by category per year
*
  emissionsCatSum_(emCat,t,nCur)$ (tCur(t) $ t_n(t,nCur) $ envAcc  )..

    v_emissionsCatSum(emCat,t,nCur)  =e=
                  sum((chain_source(curChain,source)),
                        v_emissionsCat(curChain,source,emCat,t,ncur) );

*
* --- Calculation of biomass output in different units [TK 04/08/20]
*

  bioMassOutput_(biomassUnit,tCur(t),nCur) $ (t_n(t,nCur) $ envAcc ) ..

    v_bioMassOutput(bioMassUnit,t,nCur) =e= sum (curProds(prods), v_bioMassOutputProds(bioMassUnit,prods,t,nCur)  );


  bioMassOutputProds_(bioMassUnit,curProds(prods),tCur(t),nCur) $  (t_n(t,nCur) $ envAcc) ..

    v_bioMassOutputProds(bioMassUnit,curProds,t,nCur) =e=

                v_prods(prods,t,nCur)  $ ( sameas(bioMassUnit,"mass")  )

              + v_prods(prods,t,nCur) *    p_cerealUnit(prods)  $ ( sameas(bioMassUnit,"cerealUnit")  )

                                       ;

  model m_env /
                               leachCrops_
                               slackLeach_
                               finalLeach_
                               leachTotal_
                               lossPhosCrops_
                               lossPhos_
                               humBalCrops_
                               humBal_
                               emissions_
                               emiCrops_
$iftheni.herd %herd% == true
                              emiherds_
                              emiEntFerm_
$iftheni.endo "%endoMeasures%" == "true"
                              emiEntFermRedB1_
                              emiEntFermRedB2_
                              emiEntFermRedV1_
                              emiEntFermRedV2_
$endif.endo                              
$endif.herd                              
                               emiOther_
                               emissionsMass_
                               emissionsYear_
                               emissionsCat_
                               emissionsSum_
                               emissionsCatSum_

                               bioMassOutput_
                               bioMassOutputProds_
             /;
