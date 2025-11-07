********************************************************************************
$ontext

   FARMDYN project

   GAMS file : BUILDINGS_DE.GMS

   @purpose  : Enforced mitigation options
   @author   : David Sch�fer
   @date     : 17.08.2022
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy

$offtext
********************************************************************************
$$iftheni.feedAO "%feedAddOn%" == true
* --- Determines the required amount of feed additive as a share on the total dry matter
*     intake of cows

  $$ifi "%vegetableOil%" =="true"   p_feedAddRationShare("feedAdd_VegOil") = 0.06;
  $$ifi "%Bovaer%" =="true"         p_feedAddRationShare("feedAdd_Bovaer") = 0.0006;

* --- Corresponding emission reduction to the feed additive at hand. It will be multiplied by
*     the enteric fermentation emissions
  $$ifi "%vegetableOil%" =="true"   p_feedAdd("feedAdd_vegOil") = 0.8;

* --- Based on information from DSM and Bovaer papers. The more maize compared to grass silage
*     is in the feeding ratio the higher the reduction (Ranging from 27% to 40%)
*     https://www.wur.nl/en/research-results/research-institutes/livestock-research/show-wlr/bovaer-reduced-methane-emissions-in-dairy-cows-in-different-rations.htm
*     Data on the price and emission reduction based on expert opinion researched by John Helming and PW Blokland (WEcR) (17500€/ton)
  $$ifi "%Bovaer%" =="true"   p_feedAdd("feedAdd_Bovaer") = 0.7;
$$endif.feedAO

*------------------------------------------------------------------------------
*
*   Extended lactation period of cows based on an improved animal health.
*   The improved animal health is generated through higher variable costs per animal
*   which cover veterinarian costs
*   (currently only for dairy cows)
*   Source:
*   https://smallfarms.cornell.edu/2021/04/older-cows-are-more-profitable/
*   https://www.researchgate.net/profile/Anke-Roemer-2/publication/263858401_Investigations_on_longevity_of_German_Holstein_cows/links/0f31753c38637a56d2000000/Investigations-on-longevity-of-German-Holstein-cows.pdf
*   The argumentation in the sources is that it actually is not a problem to maintain
*   or even increase the milk yield in cows with a longer lifespan but the number of
*   average lactations per herd is limited by the high culling rate in first lactaters
*   due to mastitis issues. Highest milk yield levels are achieved between the 6th and 7th lactation
*   Management options are discussed and given a variable cost factor of 50€



*------------------------------------------------------------------------------
$iftheni.lac "%lacfloor%" == true
* --- Change the number of lactations given that it is not larger than the initial value +X
          p_nLactations $ (p_nLacCapture +4 gt p_nLactations) = p_nLactations + 4;

* --- We have the assumption that the variable costs per cow are increasing due to
*    additional veterinarian cowStables
          p_VCost(cows,curBreeds,t)$(p_vCostCapture(cows,curBreeds,t) + 50 gt p_VCost(cows,curBreeds,t))   = p_VCost(cows,curBreeds,t) + 50;
$endif.lac

* ----------------------------------------------------------------------------
*
*   Application techniques close to the ground that prevent N-related emissions
*   (currently only for cattle manure)
*
*-----------------------------------------------------------------------------

$iftheni.appltech "%appltech%" == true
    $$iftheni.c "%cattle%"=="true"
        v_manDist.up(c_p_t_i(arabCrops(crops),plot,till,intens),manApplicType_manType("applSpreadCattle",curManType),tCur,nCur,m) $ (t_n(tCur,Ncur)) = 0;
        v_manDist.up(c_p_t_i(grassCrops(crops),plot,till,intens),manApplicType_manType("applSpreadCattle",curManType),tCur,nCur,m) $ (t_n(tCur,Ncur)) = 0;
    $$endif.c
$endif.appltech
