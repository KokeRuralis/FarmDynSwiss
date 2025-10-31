$ontext

   FARMDYN project

   GAMS file : aes_module_ch.GMS

   @purpose  : Variables and equations related to Swiss Cross-Compliance and direct payments

   @author   : D.Sch�fer (based on Till Kuhn aes_module_de_NRW)
   @date     : 15.02.20
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : templ.gms

$offtext
********************************************************************************

set ccTriggers/   DivRotMaxCrop               "maximum share of crops, crop specific"
                  DivRotMax                   "maximum share of crops, summarized"
                  DivRotMinCount              "count of crops planted on the farm"
              /;

set triggerCCDim / "",set.crops /;


parameters
    p_premFoodSupply(crops,sys)
    p_premArab(crops,sys)

    p_premGMF(t,n)
    p_maxConcFeed
    p_maxMaizeFeed
    p_totalLand

    p_premAnm(*)

    p_DivRotCropNum
    p_DivRotMax
    p_DivRotMin

    p_areaBFF
*    p_premBFF
    ;

Binary variables
    v_triggerConc(t,n)
    v_triggerMaiz(t,n)
    v_triggerGMF(t,n)

$ifi "%farmbranchArable%" == "on"        v_triggerCC(ccTriggers,*,t,n)                     "Binary triggers relating to CC"

;


positive variables
    v_countryPrem(t,n)                 "Aggregated direct premiums"
    v_premFoodSupply(t,n)              "Premium received for Food supply (food production with 900 CHF) and extensive grassland (450 CHF)"

$ifi "%farmbranchArable%" == "on"   v_premArab(t,n)     "Direct payment for productive arable land"

$iftheni.cattle "%cattle%"=="true"
    v_premGMF(t,n)                     "Premium paid for gras based milk and meat production"
    v_premAnimal(t,n)                  "Premium paid for animals"
    v_premBFF(t,n)
$endif.cattle
;

Equations
    premEnsFoodSupply_(t,n)
    countryDirectPayments_(t,n)

$iftheni.cattle "%cattle%"=="true"

    concResGMF_(t,n)
    maizeResGMF_(t,n)
    triggerGMF_(t,n)
    premGMF_(t,n)
    premAnimal_(t,n)
$endif.cattle
$iftheni.arab "%farmbranchArable%" == "on"   
    premArab_(t,n)
    triggerDivRotMaxcrop_(crops,t,n)                   "Diverse crop rotation: maximum share of crops, crop specific"
    triggerDiVRotMax_(t,n)                             "Diverse crop rotation: maximum share of crops, summarized"
    triggerDivRotMaxConstr_(t,n)

    triggerDivRotMinCount_(crops,t,n)                  "count of crops planted on the farm"
    triggerDivRotMinConstr_(crops,t,n)                 "crops planted on farm have to exceed 10 of the arable land"
    triggerDivRotMinNum_(t,n)                          "a certain number of crops have to be planted on the farm"
$endif.arab
*    bioDivProArea_(sys,t,n)                          "Biodiversity promotion area has to be at least 7% of total area"
*    premBFF_(t,n)

;

* ------------------------------------------------------------------------------------------------
*
*    Swiss direct payments - I   Ensuring food supply
*                            II  Payments for arable land
*                            III GMF - Gras-based milk and meat production
*
* ------------------------------------------------------------------------------------------------

*
* --- Aggregated direct premiums
*
          countryDirectPayments_(t_n(tCur,nCur)) ..
                          v_countryPrem(tCUr,nCur) =e=   v_premFoodSupply(tCur,nCur)
$ifi "%farmbranchArable%" == "on"                      + v_premArab(tCur,nCur)
$iftheni.cattle "%cattle%"=="true"
                                                       + v_premGMF(tCur,nCur)
                                                       + v_premAnimal(tCur,nCur)
*                                                       + v_premBFF(tCur,nCur)
$endif.cattle
;



* --- (I)   Food supply is subsidised covering all crops equally with the exception of extensive grassland (reduced subsidy)

       premEnsFoodSupply_(t_n(tcur,nCur)) ..

                       v_premFoodSupply(tCur,nCur) =e= sum(curCrops(crops)$((not (sameas(curCrops,"CCClover")))
                                                                           $ (not (sameas(curCrops,"CCMustard"))))
                                                                    ,v_sumCrop(crops,"conv",tCur,nCur) * p_premfoodSupply(crops,"conv"));




$iftheni.arab "%farmbranchArable%" == "on"    
* --- (II)  All arable land receives a premium of 400
       premArab_(t_n(tCur,nCur)) ..

                       v_premArab(tCur,nCur) =e= sum(curCrops(arabcrops)$((not (sameas(curCrops,"CCClover")))
                                                                        $ (not (sameas(curCrops,"CCMustard"))))
                                                                    ,v_sumCrop(arabcrops,"conv",tCur,nCur) * p_premArab(arabCrops,"conv"));
$endif.arab

$iftheni.cattle "%cattle%"=="true"

* --- (III) Gras-based milk and meat production subsidies


* --- Trigger active if concentrate does not exceed 10% of feed mass (concentrate set)


            concResGMF_(t_n(tCur,nCur)) ..

                  sum(concentrates(feeds), v_feedUse(concentrates,tCur,nCur))
                                         - v_triggerConc(tCur,nCur) * 100000 =L= sum(feedsY,v_feedUse(feedsY,tCur,nCur)) * p_maxConcFeed;




* --- Trigger active if maize silage does not exceed 25% of the roughage-based feed (set)

            maizeResGMF_(t_n(tCur,nCur)) ..
                               v_feedUse("maizSil",tCur,nCur)
                             - v_triggerMaiz(tCur,nCur) * 10000 =L=
                         (sum( roughages(feeds) $ (sum(sameas(roughages,pastOutputs),1)),
                                              sum(m, v_feedUseM(roughages,m,tCur,nCur)))
                                            + sum( roughages(feeds) $( (sum(sameas(roughages,noPastOutputs),1))
                                                   $  (sum(sameas(roughages,"maizeSil"),1))
                                                   $  (sum(sameas(roughages,"WheatGPS"),1))
  $$ifi "%feedCatchCrop%"=="true"                  $  (sum(sameas(roughages,"CCClover"),1))
                                                   ),   sum(m, v_feedUse(roughages,tCur,nCur))))
                                                 * p_maxMaizeFeed;

* --- Combine concentrate and maize silage limiting triggers


            triggerGMF_(t_n(t,nCur)) ..
                             v_triggerGMF(t,nCur) * 2 =G= (v_triggerMaiz(t,nCur) + v_triggerConc(t,nCur)) ;

* --- Premium to be paid if both triggers are active

            premGMF_(t_n(tCur,nCur)) ..
                             v_premGMF(tCur,nCur) =L= (1- v_triggerGMF(tCur,nCur)) *   p_premGMF(tCur,nCur) * p_totalLand;



* --- (V) Animal housing/Grazing premium  - mCalvs prem is still zero, as calvs are coming out of nowhere [Has to be checked - TODO David]

          premAnimal_(t_n(tCur,nCur)) ..

              v_premAnimal(tCur,nCur) =L=
                        + sum((curBreeds),
                                  v_sumherd("cows",curBreeds,tCur,nCur)      *  p_premAnm("cows")         $ herds_breeds("cows",curBreeds)
                                + v_sumherd("motherCow",curBreeds,tCur,nCur) * p_premAnm("motherCow")    $ herds_breeds("motherCow",curBreeds)
                                + v_sumherd("heifs",curBreeds,tCur,nCur)     * p_premAnm("heifs")        $ herds_breeds("heifs",curBreeds)
*                                + (v_sumherd("fCalvsRais",curBreeds,tCur,nCur) + v_sumherd("mCalvsRais",curBreeds,tCur,nCur)) * p_premAnm("calvs")
         $$iftheni.bulls defined bulls
                                + v_sumherd("bulls",curBreeds,tCur,nCur)     * p_premAnm("bulls")        $ herds_breeds("bulls",curBreeds)
         $$endif.bulls
                                 );
$endif.cattle


* ---------------------------------------------------------------------------------------------------
*
*                     All equations related to Swiss crop rotation requirements (SCR)
*
* ---------------------------------------------------------------------------------------------------

$iftheni.arab "%farmbranchArable%" == "on"    
*
* --- (SCR) Every crop is not allowed to cover more than maximum % of arable land. The binary trigger equals one
*     if crop share is above maximum allowed share of arable land for a single crop.

  triggerDivRotMaxcrop_(curCrops(arabCrops),t_n(tCur,nCur)) $ ( (not sameas(arabCrops,"idle")) $ (not catchcrops(arabCrops))  )..

        sum(c_p_t_i(arabcrops,plot,till,intens), v_cropHa(arabcrops,plot,till,intens,tCur,nCur))
          -  v_triggerCC("DivRotMaxcrop",arabcrops,tCur,nCur) * p_nArabLand  =l=  p_nArabLand * p_DivRotMax;


*
* --- (SCR) Transfer crop specific binary trigger into single, crop independent trigger. The trigger is one if the share
*     of only one crop exceeds the maxiumum allowed land.

  triggerDiVRotMax_(t_n(tCur,nCur)) ..

    sum(curcrops(arabCrops) $ (not sameas(arabCrops,"idle") $ (not catchcrops(arabCrops)) ) , v_triggerCC("DivRotMaxcrop",arabcrops,tCur,nCur))

      - v_triggerCC("DivRotMax","",tCur,nCur) * sum(curcrops(arabCrops) $ (not sameas(arabCrops,"idle") $ (not catchcrops(arabCrops)) ),1) =l= 0;
*
* --- (SCR) The binary trigger is not allowed to exceed 0, i.e. none of the crops if allowed to exceed the maximal allowed land per crop
*

  triggerDivRotMaxConstr_(t_n(tCur,nCur))..

             v_triggerCC("DivRotMax","",tCur,nCur) =L= 0;

*
* --- (SCR) A crop count is included where the trigger is 1 for a certain crop if it is grown on farm
*

  triggerDivRotMinCount_(curCrops(arabCrops),t_n(tCur,nCur))  $ ( (not sameas(arabCrops,"idle")) $ (not catchcrops(arabCrops))  ) ..

             sum( c_p_t_i(arabcrops,plot,till,intens), v_cropHa(arabcrops,plot,till,intens,tCur,nCur))
                                                    =L= v_triggerCC("DivRotMinCount",arabCrops,tcur,nCur) * 10000;


*
* --- (SCR) Each of the crops plant on-farm has to exceed the minimal rotational requirement of 10% on land. The trigger is turns one if the crop is planted
*     on-farm from previous equation


  triggerDivRotMinConstr_(curCrops(arabCrops),t_n(tcur,nCur)) $ ( (not sameas(arabCrops,"idle")) $ (not catchcrops(arabCrops))  ) ..


                                sum(c_p_t_i(arabcrops,plot,till,intens), v_cropHa(arabcrops,plot,till,intens,tCur,nCur))
                                                          =G= v_triggerCC("DivRotMinCount",arabCrops,tcur,nCur)* p_nArabLand * p_DivRotMin;

*
* --- (SCR) The crops planted on farm have to be at least a certain amount chosen (p_divRotCropNum) by the user. In the case for Swiss it is equal to 4
*
  triggerDivRotMinNum_(t_n(tCur,nCur)) ..

           sum(curCrops(arabCrops)$ ( (not sameas(arabCrops,"idle")) $ (not catchcrops(arabCrops)) ),  v_triggerCC("DivRotMinCount",arabCrops,tcur,nCur))

                                                                                                         =G= v_hasFarm(tCur,nCur) * p_DivRotCropNum;

$endif.arab
$ontext
* ------------------------------------------------------------------------------------------------
*
*     Set aside - biodiversity promotion areas (BFF) 7% of farmland must be managed as BFF
*
* ------------------------------------------------------------------------------------------------


    bioDivProArea_(curSys(sys),t_n(tCur,nCur)) $ (v_hasFarm.up(tCur,nCur) ne 0)..

          sum(plot, v_croppedPlotLand(plot,sys,tCur,nCur)) * p_areaBFF =L=
                                          sum(c_p_t_i(crops,plot,till,intens) $ (sameas(intens,"hay"))
                                                                 , v_cropHa("Swizz_BFF_hay",plot,till,intens,tCur,nCur));

* ------------------------------------------------------------------------------------------------
*
*                               Premium for set aside bio diversity grasland
*
* ------------------------------------------------------------------------------------------------

* --- (IV) BFF premium

         premBFF_(t_n(tCur,nCur)) ..

                       v_premBFF(tCur,nCur) =L= p_premBFF *  sum(c_p_t_i(crops,plot,till,intens) $ (sameas(intens,"hay"))
                                                                    , v_cropHa("Swizz_BFF_hay",plot,till,intens,tCur,nCur));
$offtext
* ------------------------------------------------------------------------------------------------
*
*                               Model
*
* ------------------------------------------------------------------------------------------------

model m_policy_country
      /
      countryDirectPayments_
      premEnsFoodSupply_
$iftheni.cattle "%cattle%"=="true"
      premAnimal_
      premGMF_

      concResGMF_
      maizeResGMF_
      triggerGMF_
$endif.cattle

*       bioDivProArea_
*       premBFF_

$iftheni.arab "%farmBranchArable%" == "on"
      premArab_
      triggerDivRotMaxcrop_
      triggerDiVRotMax_
      triggerDivRotMaxConstr_
      triggerDivRotMinCount_
      triggerDivRotMinConstr_
      triggerDivRotMinNum_
$endif.arab


      /;
