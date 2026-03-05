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
*

* ---KULAP  Offenhaltungsbeitrag in CHF/ha
* 0=Talzone, 1=Hügelzone, 2=Bergzone1, 3=Bergzone2, 4=Bergzone3 , 5=Bergzone4 
set mZone / m0*m5 /;

* ---  KULAP Hangbeitrag in CHF/ha
* 0=-18%, 1=18-35%, 2=35-50%, 3=>50%%, 
set sZone / s0*s3 /;

* ---  KULAP Hangbeitrag in CHF/ha
* 
set BioDivClass / Q1,Q2 /;

alias(plot,ploti)

set ccTriggers/   DivRotMaxCrop               "maximum share of crops, crop specific"
                  DivRotMax                   "maximum share of crops, summarized"
                  DivRotMinCount              "count of crops planted on the farm"
              /;

set triggerCCDim / "",set.crops /;


parameters
    p_totalLand

    p_ordSZone(sZone)
    p_ordMZone(mZone)
    P_ordBFF(BioDivClass) 

    p_premOpenLand(mZone)
    p_premSlope(sZone)

    p_premFoodSupplyBase
    p_premFoodSupplyBFF
    p_premArab(crops,sys)
    p_premDiffprods(mZone)

    p_DivRotCropNum
    p_DivRotMax
    p_DivRotMin

    p_premGMF(t,n)
    p_maxConcFeed
    p_maxMaizeFeed

    p_premAnm(herds)

    p_areaBFF
    P_premBFF(MZone,BioDivClass,*)

    p_BasisDZ
    ;

Binary variables
    v_triggerConc(t,n)
    v_triggerMaiz(t,n)
    v_triggerGMF(t,n)

$ifi "%farmbranchArable%" == "on"        v_triggerCC(ccTriggers,*,t,n)                     "Binary triggers relating to CC"

;
variables
    v_premSlopeExtreme(t,n)            "Premium for extreme slopes KULAP"
;

positive variables
    v_countryPrem(t,n)                 "Aggregated direct premiums"
    v_premOpenLand(t,n)                "Premium for open landscape KULAP"
    v_premSlope(t,n)                   "Premium for slope KULAP"


    v_premFoodSupply(t,n)              "Premium received for Food supply Basepayment Versorgungssicherheitsbeiträge"
    v_premDiffProds(t,n)               "Premium for difficult production (Produktionserschwernisbeitrag) Versorgungssicherheitsbeiträge"

$ifi "%farmbranchArable%" == "on"   v_premArab(t,n)     "Direct payment for productive arable land"
$iftheni.cattle "%cattle%"=="true"
    v_premGMF(t,n)                     "Premium paid for gras based milk and meat production"
    v_premAnimal(t,n)                  "Premium paid for animals"
    v_premBFF(t,n)                     "Premium for BFF (extensive hay)"
$endif.cattle
;


Equations
    premFoodSupply_(t,n)
    totalPayments_(t,n)
    premOpenLand_(t,n)
    premDiffProds_(t,n)
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
    bioDivProArea_(sys,t,n)                          "Biodiversity promotion area has to be at least 7% of total area"
    premBFF_(t,n)
    premSlope_(t,n)
    premSlopeExtreme_(t,n)
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
          totalPayments_(t_n(tCur,nCur)) ..
                          v_countryPrem(tCUr,nCur) =e=   
                          
                                                        v_premFoodSupply(tCur,nCur)
$ifi "%farmbranchArable%" == "on"                      + v_premArab(tCur,nCur)
$iftheni.cattle "%cattle%"=="true"
                                                       + v_premGMF(tCur,nCur)
                                                       + v_premAnimal(tCur,nCur)
                                                       + v_premBFF(tCur,nCur)
                                                       + v_premOpenLand(tCur,nCur)     
                                                       + v_premDiffProds(tCur,nCur)
                                                       + v_premslope(tCur,nCur)
                                                       + p_BasisDZ
                                                       + v_premSlopeExtreme(tCur,nCur)$((sum(plot$(p_plots(plot,"slope")>1), p_plots(plot,"sizeHa"))/ p_totalLand)>0.3)
$endif.cattle
;



* --- (I)   Food supply is subsidised covering all crops equally with the exception of extensive grassland (reduced subsidy)

       premFoodSupply_(t_n(tcur,nCur)) ..

                        v_premFoodSupply(tCur,nCur) =e= sum((curCrops(crops),plot,till,intens)$(c_p_t_i(curCrops,plot,till,intens)
                                                                                        $(not sameas(curCrops,"idle"))
                                                                                        $(not sameas(curCrops,"idlegras"))), 

                                                            v_cropHa(crops,plot,till,intens,tCur,nCur) 
                                                            *   ( p_premFoodSupplyBase $(not sameas(till,"hayExt"))
                                                                + p_premFoodSupplyBFF $(sameas(till,"hayExt")))
                                                            )
* Reductions for larger farms this is static and does not consider idling land
                                                    * (1 -0.2$(p_totalLand>60)
                                                         -0.2$(p_totalLand>80)
                                                         -0.2$(p_totalLand>100)
                                                         -0.2$(p_totalLand>120)
                                                         -0.2$(p_totalLand>140))  ;


* --- (I)   Versorgungssicherheitsbeiträge - Produktionserschwernisbeitrag
       premDiffProds_(t_n(tcur,nCur)) ..

                        v_premDiffProds(tCur,nCur) =e=sum((curCrops(crops),plot,till,intens,Mzone)$(c_p_t_i(crops,plot,till,intens)
                                                                                        $(p_plots(plot,"MZone")=p_ordMZone(mZone))
                                                                                        $(not sameas(curCrops,"idle"))
                                                                                        $(not sameas(curCrops,"idlegras"))), 

                                                            v_cropHa(crops,plot,till,intens,tCur,nCur) * p_premDiffprods(mZone));




* --- (I)   KULAP Open landscape differentiated by mountain zones
       premOpenLand_(t_n(tcur,nCur)) ..

                        v_premOpenLand(tCur,nCur) =e=sum((curCrops(crops),plot,till,intens,Mzone)$(c_p_t_i(crops,plot,till,intens)
                                                                                        $(p_plots(plot,"MZone")=p_ordMZone(mZone))
                                                                                        $(not sameas(curCrops,"idle"))
                                                                                        $(not sameas(curCrops,"idlegras"))), 

                                                            v_cropHa(crops,plot,till,intens,tCur,nCur) * p_premOpenLand(mZone));

* --- (I)  KULAP Slope premium
       premSlope_(t_n(tcur,nCur)) ..

                        v_premslope(tCur,nCur) =e=sum((curCrops(crops),plot,till,intens,sZone)$(c_p_t_i(crops,plot,till,intens)
                                                                                        $(p_plots(plot,"slope")=p_ordSZone(SZone))
                                                                                        $(not sameas(curCrops,"idle"))
                                                                                        $(not sameas(curCrops,"idlegras"))), 
                                                            v_cropHa(crops,plot,till,intens,tCur,nCur) * p_premslope(sZone));

* --- (I)  KULAP Extreme slopes (This is wrong in that it is static )
       premSlopeExtreme_(t_n(tcur,nCur)) $((sum(plot$(p_plots(plot,"slope")>1), p_plots(plot,"sizeHa"))/ p_totalLand)>0.3)..

                        v_premSlopeExtreme(tCur,nCur) =e= (sum((curCrops(crops),plot,till,intens)$(c_p_t_i(curCrops,plot,till,intens)
                                                                                        $(p_plots(plot,"slope")>1)
                                                                                        $(not sum(past$sameas(curCrops,past),1 ))
                                                                                        $(not sameas(curCrops,"idle"))
                                                                                        $(not sameas(curCrops,"idlegras"))
                                                                                        ), 

                                                            v_cropHa(crops,plot,till,intens,tCur,nCur)) * (900*100/(70*p_totalLand))-(900*30/70)+100) * sum(plot$(p_plots(plot,"slope")>1), p_plots(plot,"sizeHa")) +EPS;




$iftheni.arab "%farmbranchArable%" == "on"    
* --- (II)  All arable land receives a premium of 400
       premArab_(t_n(tCur,nCur)) ..

                       v_premArab(tCur,nCur) =e= sum(curCrops(arabcrops), v_sumCrop(arabcrops,"conv",tCur,nCur) * p_premArab(arabCrops,"conv"));
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
                         sum(herds_breeds(sumHerds,curBreeds)$ sum(actHerds(sumHerds,breeds,feedRegime,t,m),1),
                                  v_sumherd(sumHerds,curBreeds,tCur,nCur)       *  p_premAnm(sumHerds) )
                            ;

* ------------------------------------------------------------------------------------------------
*
*     Set aside - biodiversity promotion areas (BFF) 7% of farmland must be managed as BFF
*
* ------------------------------------------------------------------------------------------------


    bioDivProArea_(curSys(sys),t_n(tCur,nCur)) $(sum(c_p_t_i(curcrops(crops),plot,till,intens)$(sameas(till,"hayext") or sameas(crops,"gra3")),1)  $(v_hasFarm.up(tCur,nCur) ne 0))..

          sum(plot, v_croppedPlotLand(plot,sys,tCur,nCur)) * p_areaBFF =L=
                                          sum(c_p_t_i(curcrops(crops),plot,till,intens) 
                                                                 , v_cropHa(crops,plot,till,intens,tCur,nCur));



* ------------------------------------------------------------------------------------------------
*
*                               Premium for set aside bio diversity grasland
*
* ------------------------------------------------------------------------------------------------

* --- (IV) BFF premium
         premBFF_(t_n(tCur,nCur)) ..

                       v_premBFF(tCur,nCur) =e=     sum((curcrops(crops),plot,till,intens,BioDivClass,MZone) $(c_p_t_i(crops,plot,till,intens)
                                                                                                                $(p_plots(plot,"BioDivClass")=P_ordBFF(BioDivClass) )
                                                                                                                $(p_plots(plot,"MZone")=p_ordMZone(mZone))),   
                       
                                                                   (     P_premBFF(MZone,BioDivClass,"meadow")$sameas(till,"hayext")
                                                                       + P_premBFF(MZone,BioDivClass,"past")$sameas(crops,"gras3") ) 
    
                                                     *       v_cropHa(crops,plot,till,intens,tCur,nCur)
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

* ------------------------------------------------------------------------------------------------
*
*                               Model
*
* ------------------------------------------------------------------------------------------------

model m_policy_country
      /
* sum payments
      totalPayments_
*KULAP
      premOpenLand_
      premSlope_
      premSlopeExtreme_
* Foodsecurity / Versorgungssicherheitsbeiträge      
      premFoodSupply_
      premDiffProds_
$iftheni.arab "%farmBranchArable%" == "on"
      premArab_
      triggerDivRotMaxcrop_
      triggerDiVRotMax_
      triggerDivRotMaxConstr_
      triggerDivRotMinCount_
      triggerDivRotMinConstr_
      triggerDivRotMinNum_
$endif.arab
$iftheni.cattle "%cattle%"=="true"
*Productionsystem /PRoduktionssystembeiträge
      premGMF_
      concResGMF_
      maizeResGMF_
      triggerGMF_

      premAnimal_

      bioDivProArea_
      premBFF_
$endif.cattle


      /;
