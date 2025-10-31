********************************************************************************
$ontext

   FARMDYN project

   GAMS file : TEMPL.GMS

   @purpose  : Model variables and equations, partially in separate module files

   @author   : W.Britz, B.Lengers, T.Kuhn, D. Schaefer
   @date     : 3.11.10
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter.gms

$offtext
********************************************************************************

  $$iftheni.solver "%parsAsVars%"=="false"
     $$setglobal L
  $$else.solver
     $$setglobal L .l
  $$endif.solver

  scalar envAcc / 0 /;

  parameter p_cropShareLevl(crops,sys,cropShareLevl)       "Determine the increase in plant protection cost from 10% to max crop share level"
            p_maxBranch(branches,t,n)                      "BIGm for hasBranch variable"
            p_fCostC(crops,till,intens,t)                  "Fixed costs not covered by restrictions, crops"
            p_vCostStrawRemoval(crops,plot,till,intens,t)  "Costs for straw removal"

            p_wage(allWorkType,t)                          "Hourly wage in Euro"
            p_leisureVal(leisLevl)                         "Leisure value in Euro per hour"

            p_orgPrem(landType,soil,tFut)                  "Farm premiums for organic farming per ha of land"

            p_iniMachT(machType,tOld)                      "Initital machinery by buying date"
            p_machCost(machType,machLifeUnit,t)            "Variable machinery cost per ha or hour, inflated"

            p_iniBuildings(buildings,tOld)                 "Initial buildings in specific vintage category"
            p_priceBuild(buildings,t)                      "Price of buildings and structures"
            p_varCostBuild(buildings,t)                    "Variable costs per year for buildings and structures"
            p_lifeTimeBuild(buildings)                     "Lifetime of buildings"
            p_buildingNeed(prods,buildType,buildCapac)     "Storage needs for different products for specific buildings"

   $$iftheni.man "%manure%"=="true"
            p_ManApplicCost(manApplicType)                 "Application cost per kg N for manure application by different techniques"
            p_siloCovCost(silos,manStorage)                "Coverage Cost per year for whole silo type"
            p_priceSilo(silos,t)                           "Price of different manure silos"

            p_NutperQubic                                  "Amount of kg N per m3 of mixed cattle slurry (about 5kgN)" /N 4.7/
   $$endif.man

   $$iftheni.herd "%herd%"=="true"

            p_luSumHerds(sumHerds,breeds)                  "Livestock units, summary herds"
            p_strawQuant(stables,stableStyles)             "Straw quantity needed for stables"
   $$endif.herd
  ;


* -----------------------------------------------------------------------------
*
*   Declaration of variables/equations/model
*   (which relate to financial domain, work, land use;
*    specific modules deal with cattle, pigs, herds/manure/stables, biogas)
*
*   General flags:
*
*   %herd%        pigs and/or cattle present
*   %dairyHerd%   cattle present
*   %biogas%      biogas plant present
*
*
* -----------------------------------------------------------------------------
*
  variables
      v_obje                                           "Objective values, with potential penalties from risk utiltiy model"
      v_objeN(n)                                       "Discounted household withdrawals plus value of leisure, minus initial liquidity, divided by # of years"
      v_objeMean                                       "Probability weighted average of v_objeN"
      v_varCostActs(t,n)                               "Variable cost of activities (not linked to buying inputs)"
      v_buy(inputs,sys,t,n)                            "Buying of inputs (quantities/indices), by system (organic or conventional)"
      v_buyCostTot(sys,t,n)                            "Cost for buying explicitly covered inputs, sum, by system (organic or conventional)"
      v_buyCost(inputs,sys,t,n)                        "Cost for buying explicitly covered inputs, by system (organic or conventional)"
*
  variable
      v_profitTax(t,n)                                    "Profit definition for tax purposes"
      v_netCashFlow(t,n)                               "Net cash flow (operational+investive+financial) of the agricultural firm"
      v_opCashFlow(t,n)                                "Operational cash flow"
      v_invCashFlow(t,n)                               "Investive cash flow"
      v_machNeed(machType,machLifeUnit,t,n)            "Machine need in operating hours/ha/m3"
      v_machNeedGras(machType,machLifeUnit,t,n)            "Machine need in operating hours/ha/m3"

  positive variables
      v_withDraw(t,n)                                  "Household profit withdrawals from farm, before income tax"
      v_leisureVal(t,n)                                "Monetary value of leisure"
      v_offFarmWages(t,n)                              "Off-Farm wage income, before income tax"
      v_hhsldIncome(t,n)                               "Household income, after income tax"
      v_incomeToTax(t,n)                               "Total income to tax (profits, wages, income of renting out land)"
      v_incomeTaxTot(t,n)                              "Total income tax"
      v_incomeTax(taxSteps,t,n)                        "Income tax by tax band"

      v_premTot                                        "Total premium from coupled, decoupled, agri-environmental schemes, organic etc."
      v_orgPrem(t,n)                                   "Premium for organic farm"

      v_salRev(sys,t,n)                                "Revenue from selling products,total"
      v_salRevProds(prods,sys,t,n)                     "Revenue from selling products"

      v_depr(t,n)                                      "Deprecitation for tax purposes"
      v_varCost(t,n)                                   "Variable costs explictly linked to buying of inputs"
      v_varCostMach(t,n)                               "Variable cost linked to machinery use"
      v_varCostMan(t,n)                                "Variable costs for manure spreading and exporting"

      $$ifi "%herd%"=="true"   v_varCostInc(sumHerds,breeds,t,n,cropShareLevl)  "Increase in other variable cost with increasing livestock densities"

      v_sumInv(t,n)                                    "Sum of investment costs"
      v_costInv(inv,t,n)                                "Cost for different types of investments"
      v_liquid(t,n)                                    "Liquidity at end of year"

      v_saleQuant(prodsYearly,sys,t,n)                 "Sales quantities of products (production net of feed use)"
      v_prods(prods,t,n)                              "Physical production of products"
      v_prodsIntr(prods,t,n,m)                         "Physical production of grassland products, per month"
      v_machInv(machType,machLifeUnit,t,n)             "Machine inventory in year t"
      v_tracDist(plot,labPerSum,t,n)                   "Distribution of available tractors"
      v_buyMachFlex(machType,t,n)                      "Investments in new machinery in year t"
      v_buildingNeed(buildType,t,n)                    "Requirements for buildings"

      v_branchSize(branches,t,n)                       "Size of different herds"
      v_cropHa(crops,plot,till,intens,t,n)             "Crop levels in ha for each year and state of nature"
      v_totPlotLand(plot,t,n)                          "size of plot in t"

      v_nut2ManurePast(crops,plot,till,intens,allNut,t,n,m)       "Nutrients excreted on pasture, per crop"

      $$iftheni.manure "%manure%"=="true"
         v_manDist(crops,plot,till,intens,manApplicType,manType,t,n,m)   "Manure distribution to crops"
         v_volManApplied(manChain,t,n,m)                                 "m3 manure applicated to land in month m"
         v_nut2ManApplied(crops,manChain,nut2,t,n,m)                     "NTAN,NORG and P applied with manure in month m"
     $$endif.manure

     $$iftheni.biogas %biogas%==true
         v_purchManure(bhkw,eeg,maM,t,n,m)
     $$endif.biogas

      v_BuildingsInv(buildings,t,n)                                 "Inventory of new buildings and structures year t"
      v_buyBuildingsF(buildings,t,n)                                "Buying of new buildings, fractional"

      v_rentOutPlotNew(plot,t,n)                                    "Rent out a specific plot, contract start"
      $$ifi %MIP%==on   binary variables
      v_hasFarm(t,n)                                                "Indicator value for having a farm"
      v_hasBranch(branches,t,n)                                     "Indicator value for having a certain branch"
      v_labOffB(t,n)                                                "Working off-farm or not"
      v_org(t,n)                                                    "Switch for ecological farming"

      $$ifi %MIP%==on   integer variables
      v_buyPlot(plot,t,n)                                           "Buying one specific plot in year t"
      v_buyBuildings(buildings,t,n)                                 "Investments in new buildings and structures year t"
      v_buyMach(machType,t,n)                                       "Investments in new machinery in year t"
  ;

  equations

      obje_                                      "Objective function, including potential risk penalties"
      objeN_(n)                                  "Define discounted utility of household (withdrawals+leisure)"
      objeMean_                                  "Probability weighted mean of ObjeN at different final leaves"

      leisureVal_(t,n)                           "Value of leisure in money terms"
      offFarmWages_(t,n)                         "Sum of farm wages"

      opCashFlow_(t,n)                           "Definition of operational cash flow, in nominal terms"
      finCashFlow_(t,n)                          "Financial cash flow"
      invCashFlow_(t,n)                          "Cash flow linked to investments"
      netCashFlow_(t,n)                           "Definition of net cash flow for year t in nomimal terms"
      sumInv_(t,n)                                "Sum of investment in current year"
      costInv_(inv,t,n)
      hhsldIncome_(t,n)                           "Household income, after income tax"

      profitTax_(t,n)                               "Definition of profit for tax purposes"
      depr_(t,n)                                 "Definition of depreciation"
      incomeToTax_(t,n)                          "Tax basis for income tax"
      incomeTaxTot_(t,n)                         "Total income tax"
      incomeTax_(taxSteps,t,n)                   "Income tax by band"

      buyCostTot_(sys,t,n)                        "Costs for buying products,total"
      buyCost_(inputs,sys,t,n)                    "Costs for buying products"
      varCost_(t,n)                               "Sum of variable cost"

      premTot_(t,n)                               "Definition of total single farm premium received"
      orgPrem_(t,n)                              "Definition of total premium for organic farming received"
      orgPremCropped_(t,n)                       "Organic premium not paid if all land is idling"
      orgPremCond_(t,n)                          "Organic premium only if farm is organic"

      hasFarmAndOrBinWork_
      hasFarm_(branches,t,n)                     "Binary trigger for having a farm/brnaches"
      hasFarmOrder_(t,n)                         "Order over having farm: if closed in t, than closed in t+1"
      hasBranch_(branches,t,n)                   "Binary trigger for having a farm branch"

      branchSize_(branches,t,n)                  "Add up farm branch size"
      rentoutNew_(plot,t,n)                      "New renting contracts"

      tracRestrFieldWorkHours_(plot,labReqLevl,labPerSum,t,n)
      tracDistribution_(labPerSum,t,n)


      buildingInv_(buildings,t,n)                 "Building inventory definition (from current and past investments)"
      buildingsConcaveComb_(buildings,t,n)        "Only two neighbouring building sizes can be selected for investing into building"
      buildingsBin_(buildings,t,n)                "Restrict choice of points for convex combination"
      buildingsConvexComb_(buildType,t,n)         "Combine two shares of buildings, adding to one"
      convBuildings_(buildType,t,n)                "Combine two shares of buildings, adding to one"
      buildingNeed_(buildType,buildCapac,t,n)     "Bulding needs must exceed existing inventory (from current or past investment)"
      buildingNeedDef_(buildType,buildCapac,t,n)  "Bulding need defined from current farm program"
      buildingBuyB_(buildings,t,n)                "Only invest in a building in this year if there is a need for (might help solver)"

      machines_(machType,machLifeUnit,t,n)        "Machinery hour restriction"
      machinesGras_(machType,machLifeUnit,t,n)
      machInv_(machType,machLifeUnit,t,n)         "Machine inventory definition, physical use, from current and past investments"
      machInvT_(machType,t,n)                     "Machine inventory definition, by lifetime, from current and past investments"
      machBuyFlex_(machType,machLifeUnit,t,n)

      liquid_(t,n)                                "Definition of accumulated liquidity"

      salRev_(sys,t,n)                            "Revenue from selling products"
      salRevProds_(prods,sys,t,n)                 "Revenue from selling products"
      buy_(inputs,t,n)                            "Buying products"

      varCostActs_(t,n)                              "Variable costs for activities"
      varCostMach_(t,n)                              "Variable cost machinery"
      varCostMan_(t,n)                               "Variable cost manure spreading"
      $$ifi "%herd%"=="true"  varCostInc_(sumHerds,breeds,t,n,cropShareLevl) "Variable costs explictly linked to buying of inputs"
      $$ifi "%cattle%"=="true"    feedUp_(prods,t,n)


      prods_(prodsYearly,t,n)                        "Physical production"

      prodsMY_(prods,t,n,m)                          "Physical production, per month"
      saleQuant_(prods,t,n)                          "Physical sales"

      nutTotalApplied_(nut,t,n,m)                 "total kg nurient applicated to land from fertilizer and manure per month"
      nutTotalAppliedYear_(nut,t,n)               "total kg nurient applicated to land from fertilizer and manure per year"

      nMinMin_(crops,plot,till,intens,nut,t,n)        "Minimum share of mineral N on total N need"
      nutSurplusMax_(crops,plot,till,intens,nut,t,n)  "maximum nutrient surplus allowed exdceeding demand"
      NutBalCropSour_(fertSour,crops,plot,till,intens,nut,t,n) "Nutrient balance for each crop categorie, source specific"
      NutBalCrop_(crops,plot,till,intens,nut,t,n)     "Nutrient balance for each crop categorie"
      NutBalPast_(crops,plot,till,intens,nut,t,n,m)   "Nutrient balance for grazing"
      NutBalCrop1_(crops,plot,till,intens,nut,t,n)    "Nutrient balance for each crop categorie"
      catchCropMax_(plot,t,n)                         "Constraints acreage of catchcrop to the acreage of crops harvested in summer"
      residueRemoval_(crops,plot,till,t,n)            "Possible residues removal is linked to ha of certain crops"
      ownConsumResidue_(prodsYearly,t,n)              "Own consumption of straw residues for straw stables"

      buyMachLifeTimeT_(machType,t,n)
      buyMachLifeTimeO_(machType,t,n)
  ;
* ----------------------------------------------------------------------------
*
*   Definition of sub-modules
*
* ----------------------------------------------------------------------------
*
* --- Cropping/landuse module
*
  $$include 'model/general_cropping_module.gms'
*
*  --- stables and machinery linked to animals, herd module
*
  $$ifi %herd%==true       $include 'model/general_herd_module.gms'
*
* --- finacial cash flow related (credits, interest, liquidation)
*
  $$ifi not "%dynamics%"=="comparative-static"  $include 'model/fin_cashFlow.gms'
*
* ---- manure storage and nutrient flow, linked to herd and biogas
*
  $$ifi %manure% == true   $include 'model/manure_module.gms'
*
* --- feeding requirements, stocking density restrictions,
*        calves balances, binary speed ups related to herds
*
  $$ifi %cattle%==true     $include 'model/cattle_module.gms'
*
* --- biogas plant inventory, switching between EEG,
*     feedstock demand, electricity and heat production
*
  $$ifi %biogas%==true     $include 'model/biogas_module.gms'
*
* --- cereals/concentrates feeding for pigs, definition of new piglets
*
  $$ifi %pigHerd% == true  $include 'model/pig_module.gms'
*
* --- accounting of environmental impacts  (always active because necessary for nutrient flow in storage)
*
  $$ifi %envAcc%==true $include 'model/%EmissionsModule%.gms'
*
* --- accounting of social indicators
*
  $$ifi "%socialAcc%" == "true" $include 'model/soci_acc_module.gms'
*
*    --- equations / variables relatign to German Fertilizer Law
*        (Duengeverordnung)
*
  $$ifi %duev%==true       $include 'model/%fertOrdModule%.gms'
*
*
* --- equations/variables related to agri-environmental schemes

  $$ifi %agriEnvSchemes%==true       $include 'model/%aesModule%.gms'

*
* --- Labour module: on/off-farm work, branch specific work, hired worker
*
  $$include 'model/labour_module.gms'
*
* --- Policy modules:
*

* --- (1)  Common agricultural policy file

  $$ifi "%EUCountry%" == "true" $include "model/%policyCAPFile%.gms"

* --- (2) Non-EU country policy file including cross compliance and payment schemes

  $$ifi "%nonEUCountry%" == "true" $include "model/%policyCountryModule%.gms"

* --- (3) Carbon price/tax implementation

  $$ifi %carbonPriceC%==true $include 'model/policy_module_carbonPrice.gms'
*
* --- risk / stochastic programming
*
  $$ifi %stochProg%==true  $include 'model/stochProg_module.gms'

* -----------------------------------------------------------------------------
*
*   Definitions of model template
*
* -----------------------------------------------------------------------------


* -----------------------------------------------------------------------------
*
*                          Objective function structure
*
* -----------------------------------------------------------------------------
*
* --- net present value of cash balance in average per year
*     over the simulation horizon
*
  obje_ ..
*
     v_obje =L=
              v_objeMean
*
*     --- penalty for negative deviation from mean NPV (similar MOTAD) or target MOTAD / ES
*
    $$iftheni.stochProg %stochProg%==true
       + [
            - v_expNegDevNPV * p_negDevPen  $ (not p_expShortFall)
            - v_expShortFall * p_negDevPen  $ (not p_expShortFall)
            + v_expShortFall * p_negDevPen  $ p_expShortFall
            + v_uApprox                     $ p_approxUtil
            - v_objeMean                    $ p_approxUtil
         ] $ sum(t_n(tCur,nCur) $  (v_hasFarm.up(tCur,nCur) ne 0),1)
    $$endif.stochProg
  ;
*
* --- mean of yearly average discount household withdrawals (plus money value of leisure)
*     (= equal to simulated value for deterministic version)
*
  objeMean_ ..

     v_objeMean =E= sum(t_n("%lastYearCalc%",nCur), v_objeN(nCur)*p_probN(nCur));
*
* --- discounted household withdrawals (plus money value of leisure), per average year
*
  objeN_(nCur) $ t_n("%lastYearCalc%",nCur) ..

     v_objeN(nCur)  =E=
*
               [  sum(t_n(tFull,nCur1) $ isNodeBefore(nCur,nCur1),
                           [    v_hhsldIncome(tFull,nCur1)
                             +  v_leisureVal(tFull,nCur1) $ sum(leisLevl,p_leisureVal(LeisLevl))
                           ] * 1/(1+p_discountRate/100)**tFull.pos)
*
*               --- minus initial liquidity
*
                - sum(t_n("%lastOldYear%",nCur),v_liquid("%lastOldYear%",nCur))*0
               ]
*
*              --- divived by the number of years
*
           /card(tFull)
  ;

* ---------------------------------------------------------------------------------------
*
*                       Cashflow structure (feeds into objective function)
*
* ---------------------------------------------------------------------------------------
*
* --- Household income: profit withdrawals from agricultural enterpries, off-farm wages,
*                       land rental income minus income tax
*
  hhsldIncome_(t_n(tFull(t),nCur)) ..

     v_hhsldIncome(t,nCur) =E= v_withDraw(t,nCur) + v_offFarmWages(t,nCur)
*
*      --- income from renting out land (assume that land is owned by farming family, and not by agricultural enterprise
*
     $$ifi %landLease% == true + sum( plot $ p_plotsize(plot), v_rentOutPlot(plot,t,%nCur%) * p_plotSize(plot) * p_landRent(plot,t))
*
     $$ifi not "%incomeTax%"=="None"- v_incomeTaxTot(t,nCur)
      ;

*
* --- Utility in money terms from leisure
*
  leisureVal_(t_n(tCur,nCur)) $ sum(leisLevl,p_leisureVal(LeisLevl))  ..

      v_leisureVal(tCur,nCur) =L=

           $$iftheni.pmp "%pmp%"=="true"
*
* --- cash flow linked to (de)investments

*                --- the quadratic function is chosen such as to give the same monetary value of leisure at the first hour
*                    and very close also the same results at maximum possible leisure in a month, compared to the linearized
*                    version
*
                 sum(m, v_leisureTotM(tCur,nCur,m) * %leisureVal% * 5
                           - 0.75*sqr(v_leisureTotM(tCur,nCur,m))/smax(leisLevl,v_leisure.up(leisLevl,tCur,nCur,m))*%leisureVal%)
           $$else.pmp
                 sum((leisLevl,m),v_leisure(leisLevl,tCur,nCur,m) * p_leisureVal(LeisLevl))
           $$endif.pmp
  ;
*
* --- Net cash flow in current period
*
  netCashFlow_(t_n(tFull(t),nCur))  ..
*
     v_netCashFlow(t,nCur) =e=
*
*       --- financial cash flows (including household withdrawals) in rec-dyn version
*
        $$ifi not "%dynamics%"=="comparative-static"            + v_finCashFlow(t,nCur)
*
*       --- household withdrawals as sole financial cash flow in comp-stat version
*
        $$ifi     "%dynamics%"=="comparative-static"            - v_withDraw(t,nCur)
*
*       --- investment cash flows
*
        + v_InvCashFlow(t,nCur) $ sum(branches,v_hasBranch.up(branches,t,nCur))
*
*       --- operational cash flow
*
        +  v_opCashFlow(t,nCur)
     ;

*
* --- Operational cash flows: revenues - variable costs for each state of nature from agriculture
*     enterprice (does not include cost of investments and cash flows related to new credits or to
*     credit repayments, or to households withdrawals)
*
  opCashFlow_(t_n(tFull(t),nCur)) ..
*
      v_opCashFlow(t,nCur)
                              =e=
        [
*
*          --- income from selling products (by organic and conventional system)
*
           + sum(curSys,v_salRev(curSys,t,nCur))
*
*          --- revenues from selling biogas
*
           $$ifi %biogas%==true  + v_salRevBioGas(t,nCur)
*
*          --- total premiums received
*
           + v_premTot(t,nCur)

           $$iftheni.dyn not "%dynamics%"=="comparative-static"
*
*              --- interest gained from accumulated liquidity
*                (last year s liquidity minus new credits)
*
               + v_intGain(t,nCur) $ p_interestGain
*
*              --- interest paid on outstanding loans
*
               - v_intPaid(t,nCur) $ sum(creditType, p_interest(creditType))

           $$endif.dyn
*
*          --- variable cost
*
           - v_varCost(t,nCur)
*
*          --- Deduction of carbon price
*
           $$ifi %carbonPriceC% == true - v_carbonCost(t,nCur)



        ] $ tCur(t)

        $$iftheni.dyn not "%dynamics%"=="comparative-static"
*
*          --- weighted average of past expected gross margins beyond full planning horizon
*              (take into account only the last 40 years)
*
           + [   sum( (t1,nCur1) $ ( isNodeBefore(nCur,nCur1) $ tCur(t1) $ t_n(t1,nCur1)),
*
*                    --- discounted past revenues minus costs
*
                     (v_opCashFlow(t1,nCur1)
                         -v_intGain(t1,nCur1)+v_intPaid(t1,nCur1))
                    )/card(tCur)

                + v_intGain(t,nCur) $ p_interestGain
                - v_intPaid(t,nCur) $ sum(creditType, p_interest(creditType))


             ]  $ ( (not tCur(t)) and p_prolongCalc)
        $$endif.dyn
      ;

*
* --- Cash flow linked to (de)investments
*
  InvCashFlow_(t_n(tFull(t),nCur)) ..

     v_InvCashFlow(t,nCur) =E=
*
*      --- de-investment in last period (only in rec-dyn version)
*
       $$ifi not "%dynamics%"=="comparative-static" + v_liquidation(nCur) $ sameas(t,"%lastYearCalc%")
*
*      --- investments
*
       - v_sumInv(t,nCur)$ (v_hasFarm.up(t,nCur) ne 0);
*
* --- accumulated liquidity (determines interest gained by agricultural enterprise
*     and required credits (cannot become negtive)
*
  Liquid_(tFull(t),nCur) $ t_n(t,nCur) ..
*
     v_liquid(t,nCur) =e=
*
*       --- last years liquidity
*
        + sum(t_n(t-1,nCur1) $ anc(nCur,nCur1), v_liquid(t-1,nCur1))
*
*       --- total cash flow of the agricultural enterprise
*
        + v_netCashFlow(t,nCur)
     ;
*
* --- off farm wages
*
  offFarmWages_(t_n(tFull(t),nCur)) ..

     v_offFarmWages(t,nCur) =E=
*
*        --- off farm income, flexible on a hourly basis (max 100 hours per month)
*
         + v_labOffHourly(t,nCur) *  p_wage("hourly",t)
           $$iftheni.sp "%stochProg%"=="true"
              * ( 1 + (p_randVar("priceInputs",nCur)-1) $ randProbs("hourly") )
           $$endif.sp
*
*          --- off farm, requires at least a half-time contract (20 hours a week),
*              beyond this point flexible. The term 52/44 considers that 52 weeks are paid,
*              but solely 44 actually worked (holidays, bank holidays, sick leave)
*
         + sum( workOpps(workType) $ (v_labOff.up(t,nCur,workType) ne 0),
                v_labOffF(t,nCur,workType)  * p_wage(workType,t) * 52/44
              $$iftheni.sp "%stochProg%"=="true"
                * ( 1 + (p_randVar("priceInputs",nCur)-1) $ randProbs(workType) )
              $$endif.sp
     );

* -----------------------------------------------------------------------------
*
*                              Income tax calculations
*
* -----------------------------------------------------------------------------
*
* --- The profit is only relevant to determine income taxes.
*     The primary income flow the agricultural enterprise stems from household withdrawals
*
  profitTax_(t_n(tFull(t),nCur)) ..
*
     v_profitTax(t,nCur) =E=
*
*       --- operational cash flow
*
        v_opCashFlow(t,nCur)
*
        $$iftheni.dyn not "%dynamics%"=="comparative-static"
*
*          --- Sell firm (extraordinary revenues)
*
           + v_liquidation(nCur) $ sameas(t,"%lastYearCalc%")

        $$endif.dyn
*
*       --- depreciation for profit accounting
*           for tax purposes (not a cash flow!)
*
        - v_depr(t,nCur)
    ;
*
* --- Total income tax in any year
*
  incomeTaxTot_(t_n(tFull(t),nCur)) ..

     v_incomeTaxTot(t,nCur) =E= sum(taxSteps $ p_taxes%incomeTax%(taxSteps,"rate"), v_incomeTax(taxSteps,t,nCur));
*
* --- (Additional) Taxes for the different steps in the tax scheme,
*     Charged on all income flows to the household
*
  incomeTax_(taxSteps,t_n(tFull(t),nCur)) ..

     v_incomeTax(taxSteps,t,nCur) =G= (v_inComeToTax(t,nCur)
                                         -  p_taxes%incomeTax%(taxSteps,"step")) * p_taxes%incomeTax%(taxSteps,"rate")/100;
*
* --- total income to tax: full farm profit are taxed, not only the
*                          profit withdrawals by the houseold in current year
*
  incomeToTax_(t_n(tFull(t),nCur)) ..

     v_incomeToTax(t,nCur) =G=  v_profitTax(t,nCur) + v_offFarmWages(t,nCur)
*
*      --- income from renting out land (assume that land is owned by farming family, and not by the legal person farm
*
       $$ifi %landLease% == true  + sum( plot $ p_plotsize(plot), v_rentOutPlot(plot,t,%nCur%) * p_plotSize(plot) * p_landRent(plot,t))
     ;
*
*  --- depreciation accounting for tax purposes
*
   depr_(tFull(t),nCur) $ t_n(t,nCur) ..

       v_depr(t,nCur) =E=
*
          $$iftheni.dyn not "%dynamics%"=="comparative-static"
*
*            --- this simple implementation assume a linear depreciation
*                over 10 years for tax reasons
*
             sum( (t_n(t1,nCur1)) $ (isNodeBefore(nCur,nCur1)
                                          and (p_Year(t1)+10 ge p_year(t))
                                          and (p_Year(t1) lt p_year(t))),
                                            v_sumInv(t1,nCur1)/10)
          $$else.dyn
*
*            --- in comparative static mode, it is assumed that the implicitly
*                assumed medium-term horizon allows to depreciate all
*                investments for tax reasons
*
             v_sumInv(t,nCur)
          $$endif.dyn
   ;

* ------------------------------------------------------------------------------------
*
*                                   Premium Section
*
* ------------------------------------------------------------------------------------

* --- Single farm premiums, decoupled and coupled, organic schmes and agro-environmental schemes premiums

  premTot_(t_n(tCur(t),nCur)) ..

     v_premTot(t,nCur) =L=
*
*       --- income from single farm payments (CAP - EU Country)
*
        $$ifi %EUCountry% == true              + v_sfPrem(t,nCur)

*       --- additional payments for the first ha, redistribution of payments (CAP - EU Country)

        $$ifi %EUCountry% == true    $$ifi %policyCAPfile% == "Policy_CAP_de_2023"   + v_sfPremRedi(t,nCur)


        $$ifthenI.cattle "%Cattle%"==true
*
*           --- income from coupled payments per head of cattle
*
            + sum((curBreeds),
             $$ifi set cowPrem               v_sumherd("cows",curBreeds,t,%nCur%)      * %cowPrem%    $ herds_breeds("cows",curBreeds)
             $$ifi set mowPrem             + v_sumherd("motherCow",curBreeds,t,%nCur%) * %mcowPrem%   $ herds_breeds("motherCow",curBreeds)
             $$ifi set heifsPrem           + v_sumherd("heifs",curBreeds,t,%nCur%)     * %heifsPrem%  $ herds_breeds("heifs",curBreeds)
                                           + (v_sumherd("fCalvsRais",curBreeds,t,%nCur%) + v_sumherd("mCalvsRais",curBreeds,t,nCur)) * %calvsPrem%

             $$ifthenI.bulls defined bulls
                 $$ifi set bullsPrem           + v_sumherd("bulls",curBreeds,t,%nCur%)     * %bullsPrem%  $ herds_breeds("bulls",curBreeds)
             $$endif.bulls

            )

        $$endif.cattle
*
*        --- premiums for organic farming
*

        $$ifi not "%orgTill%"=="off" + v_orgPrem(t,nCur)
*
*       --- payments received for voluntary agri-environmental schemes and/or eco-schemes
*           under CAP 2023
*

        $$iftheni.EUcountry "%EUCountry%"=="true"

            $$ifi %agriEnvSchemes%==true               + v_aesPrem(t,nCur)
            $$ifi  "%ecoSchemesCapPillar1%" == "true"  + v_esPrem(tCur,nCur)

        $$endif.EUcountry
*
*       --- premium for country specific payments
*
        $$ifi %nonEUCountry%==true + v_countryPrem(t,nCur)
   ;


   $$iftheni.org not "%orgTill%"=="off"
*
*     --- Premiums for organic production
*
      orgPrem_(t_n(tCur,nCur))..

         v_orgPrem(tCur,nCur) =L=
                sum( (landtype,soil), v_croppedLand(landType,soil,tCur,%nCur%) * p_orgPrem(landType,soil,tCur));

*
*     --- eco premiums cannot exceed total organic land, times
*         max subsidies, might help solver
*
      orgPremCropped_(t_n(tCur,nCur)) $ curSys("org") ..

         v_orgPrem(tCur,nCur) =L=
                + sum(c_p_t_i(curCrops(crops),plot,"org",intens) $ (not idle(crops)),
                    v_cropHa(crops,plot,"org",intens,tCur,%nCur%)) * smax((landType,soil),p_orgPrem(landType,soil,tCur)) * 10;
*
*     --- eco premiums paid out only if whole farm in organic system
*
      orgPremCond_(t_n(tCur,nCur)) $ curSys("org") ..

         v_orgPrem(tCur,nCur) =L=  v_org(tCur,%nCur%)
                                   *  sum(plot_lt_soil(plot,landType,soil), v_totPlotLand.up(plot,tCur,nCur)*p_orgPrem(landType,soil,tCur));
*
*     --- case of endogenous switched between conventional and organic, add additional constraints into model
*
      $$ifi "%orgTill%"=="optional" $include 'model/org_opt.gms'

  $$endif.org

* ------------------------------------------------------------------------------------
*
*                Sales revenues and production levels
*
* ------------------------------------------------------------------------------------

*
* --- total revenue from sales, by organic and conventional system
*
  salRev_(curSys(sys),t_n(tCur,nCur))   ..
*
     v_salRev(sys,tCur,nCur)  =e= sum(  (curProds(prodsYearly)) $ (v_saleQuant.up(prodsYearly,sys,tCur,nCur) ne 0),
                                              v_salRevProds(curProds,sys,tCur,nCur));
*
* --- revenue from sales of animal and crop products, n each state of nature
*    (SON specific price times SON specific production quantities)
*
  salRevProds_(curProds(prodsYearly),curSys(sys),tCur(t),nCur) $ (t_n(t,nCur) $ (v_saleQuant.up(prodsYearly,sys,t,nCur) ne 0))  ..
*
     v_salRevProds(curProds,sys,t,nCur)  =e=
         p_price(prodsYearly,sys,t)
               $$iftheni.sp "%stochProg%"=="true"
                       * ( 1 + (p_randVar("priceOutputs",nCur)-1) $ randProbs(prodsYearly) )
               $$endif.sp

                    * v_saleQuant(prodsYearly,sys,t,nCur);


  $$iftheni.cattle "%cattle%"=="true"
*
*     --- balance of feeds without price
*
      feedUp_(curProds(prodsYearly),t_n(tCur(t),nCur)) $ (not sum(curSys,p_price%l%(prodsYearly,curSys,t))) ..

         sum( sameas(prodsYearly,curFeeds(feedsY)), v_feedUseProds(feedsY,t,nCur)) =L=
                    sum( c_p_t_i(curCrops(crops),plot,till,intens), v_cropHa(crops,plot,till,intens,t,nCur)
                      * sum(plot_soil(plot,soil) $ p_OCoeffC%l%(crops,soil,till,intens,prodsYearly,t),
                                                   p_OCoeffC(crops,soil,till,intens,prodsYearly,t)));
  $$endif.cattle

*
* --- balances for products, define sold quantities
*
  saleQuant_(curProds(prodsYearly),t_n(tCur(t),nCur)) $ (sum(curSys,p_price%l%(prodsYearly,curSys,t)) or sameas(curProds,"milkfed"))  ..

     v_prods(prodsYearly,t,nCur) =G=

        sum(curSys $ p_price%l%(prodsYearly,curSys,t),v_saleQuant(prodsYearly,curSys,t,nCur))
*
*       ---- consider on-farm use for feed (competes with selling of produced quantities)
*
        $$iftheni.cattle "%cattle%"=="true"
            + sum( sameas(prodsYearly,curFeeds(feedsY)), v_feedUseProds(feedsY,t,nCur))
        $$endif.cattle
*
        $$iftheni "%biogas%"=="true"
           +  sum( sameas(prodsYearly,crM),
                   sum( (curBhkw(bhkw),curEeg(eeg),m),
                           v_feedBiogas(bhkw,eeg,crM,t,nCur,m) ) )
        $$endif
*
        $$iftheni.pig "%pigherd%"=="true"
           +  sum(sameas(prodsYearly,feedsPig), v_feedOwnPig(feedspig,t,nCur))
        $$endif.pig
*
*       --- consider biomass export to external biogas plant
*
        $$iftheni.biomassex "%AllowBiogasExchange%" == "true"
           + sum(sameas(prodsYearly,biogas_exchange), v_expBiomass(biogas_exchange,t,nCur))
        $$endif.biomassex
     ;
*
* --- annual production output
*
  prods_(prodsYearly,t_n(tCur(t),nCur)) $ sum(sameas(prodsYearly,curProds),1) ..

     v_prods(prodsYearly,t,nCur)

       =e=
*
*      --- crop main output
*
       sum( c_p_t_i(curCrops(crops),plot,till,intens), v_cropHa(crops,plot,till,intens,t,%nCur%)
           * sum(plot_soil(plot,soil) $ p_OCoeffC%l%(crops,soil,till,intens,prodsYearly,t),
               p_OCoeffC(crops,soil,till,intens,prodsYearly,t)
                  $$iftheni.sp "%stochProg%"=="true"
                     $$iftheni.stochYield "%stochYields%"=="true"
                                   * (p_randVar(crops,nCur) + (p_randVar("gras",nCur)-1))
                     $$endif.stochYield
                  $$endif.sp
               ))

*      --- crop residues such as straw
*
       +  sum( c_p_t_i(crops,plot,till,intens) $ cropsResidueRemo(crops),
                v_residuesRemoval(crops,plot,till,intens,t,nCur)
                  *  sum(plot_soil(plot,soil), p_OCoeffResidues(crops,soil,till,intens,prodsyearly,t)
                     $$iftheni.sp "%stochProg%"=="true"
                        $$iftheni.stochYield "%stochYields%"=="true"
                                      * p_randVar(crops,nCur)
                        $$endif.stochYield
                     $$endif.sp
                  ) )

       $$iftheni.straw %strawManure% == true
*
*         --- minus crop residues such as straw used for own Consumption
*
          - v_residuesOwnConsum(prodsYearly,t,nCur) $ (sum(sameas (prodsYearly,prodsResidues),1))
       $$endif.straw
*
       $$iftheni.herd %herd% == true
*
*         --- animal output
*
          +  sum( (possHerds,breeds) $ (sum((feedRegime,m),actherds(possHerds,breeds,feedRegime,t,m))
                                      $ p_OCoeff(possHerds,prodsYearly,breeds,t)),
*
*           -- herd size in different month times output yearly coefficient (milk, young animals ..)
*
                         ( sum(actHerds(possHerds,Breeds,feedRegime,t,m),v_herdSize(possHerds,breeds,feedRegime,t,nCur,m))
                                     * ( [1/min(12,p_prodLength(possHerds,breeds))]
                                             $ ( ((p_prodLength(possHerds,breeds) gt 1)
            $$ifi "%farmBranchSows%" == "on" and  (p_prodLength(possHerds,breeds) gt 2)
                                                 )
            $$ifi "%farmBranchFattners%" == "on" or ((p_prodLength(possHerds,breeds) le 1) $ (sameas(possHerds,"fattners") and sameas(prodsYearly,"pigMeat")))
                                      ))
*
*            --- cases where herd start counts (that is usucally the case if the production length is one month)
*
                            + sum(m $ sum(feedRegime,actherds(possHerds,breeds,feedRegime,t,m)),  v_herdStart(possHerds,breeds,t,%nCur%,m))
                                             $ ( (p_prodLength(possHerds,breeds) le 1)

          $$ifi "%farmBranchFattners%" == "on" and (not (sameas(possHerds,"fattners") and sameas(prodsYearly,"pigMeat")))
          $$ifi "%farmBranchSows%" == "on"    or ((p_prodLength(possHerds,breeds) le 2) $ sameas(prodsYearly,"pigletsSold"))
                                          )
                         )

               * p_OCoeff(possHerds,prodsYearly,breeds,t)
         )
       $$endif.herd
   ;

* ------------------------------------------------------------------------------------
*
*                Variable costs from purchasing levels, machinery, activies, etc.
*
* ------------------------------------------------------------------------------------

*
* --- Total variable costs
*
  varCost_(tCur(t),nCur) $ t_n(t,nCur)  ..

     v_varCost(t,nCur) =e=
*
*      --- variable costs of buying inputs
*
       sum(curSys,v_buyCostTot(curSys,tcur,nCur))
*
*      --- variable costs of crop and animal production (as far as not covered by constraints)
*          and variable machinery costs (KTBL regression)
*
       + v_varCostActs(t,nCur)

*      --- variable costs for machinery (per ha, hour or year)

       + v_varCostMach(t,nCur)

       $$iftheni.man %manure% == true
*
*         --- variable cost for manure application / coverage / storage / export  / import
*
          + v_varCostMan(t,nCur)
       $$endif.man

       $$iftheni.h %herd% == true
*
*         --- repair and insurance costs for stables, calculated as an average from page 516, KTBL 16/17,
*             fraction of investment cost depending on lifetime
*
          + sum( (stables,hor) $ v_stableInv.up(stables,hor,t,nCur),
                v_stableUsed(stables,t,nCur) * p_priceStables(stables,hor,t-1)
                       * (  0.01 $ sameas(hor,"long")
                          + 0.02 $ sameas(hor,"middle")
                          + 0.03 $ sameas(hor,"short") ) )
       $$endif.h
*
*      --- variable costs for buildings
*
       + sum( curBuildings(buildings)
              $ (     sum(t_n(t1,nCur1) $ isNodeBefore(nCur,nCur1), (v_buyBuildings.up(buildings,t1,nCur1) ne 0))
                  or  sum(tOld, p_iniBuildings(buildings,tOld))),

              v_buildingsInv(buildings,t,nCur) * p_varCostBuild(buildings,t) )

       $$iftheni.bg %biogas%==true
*
*         --- variable cost related to biogas production
*
          + sum( curBhkw(bhkw) ,  v_varCostBiogas(bhkw,t,nCur))
       $$endif.bg
    ;
*
* --- variable costs from machinery (covering maintenance, lubricants (excl. diesel) and "others")
*
  varCostMach_(t_n(tCur(t),nCur)) ..

     v_varCostMach(t,nCur) =G=

*        --- variable costs for machinery (per ha, hour or year)

         + sum( curMachines(machType) $ p_lifeTimeM(machType,"ha"),
             v_machNeed(machType,"ha",t,nCur)   * p_machCost(machType,"ha",t))

         + sum( curMachines(machType) $ p_lifeTimeM(machType,"hour"),
            v_machNeed(machType,"hour",t,nCur) * p_machCost(machType,"hour",t))

         + sum( curMachines(machType) $ p_machAttr(machType,"varCost_year"),
               v_machInv(machType,"years",t,nCur) * p_machCost(machType,"years",t))

*        --- variable machinery cost for KTBL crops

         $$iftheni.data "%database%" == "KTBL_database"
            + sum((c_p_t_i(curCrops(crops),plot,till,intens),operation),
                     v_cropHa(curcrops,plot,till,intens,t,%nCur%) * p_opInputReq(curCrops,till,"varcost",operation))
         $$endif.data
         ;
*
  $$iftheni.man %manure% == true

*
*   --- Variable costs for manure handling
*
*
    varCostMan_(tCur(t),nCur) $ t_n(t,nCur) ..

       v_varCostMan(t,nCur) =G=

*
*         --- for application
*
          + sum( (c_p_t_i(curCrops(crops),plot,till,intens),manApplicType_manType(ManApplicType,curManType),m)
                   $ ( (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0)  $ (not catchcrops(curCrops) )   ),

                       v_manDist(crops,plot,till,intens,manApplicType,curManType,t,nCur,m)
                          * p_manApplicCost(ManApplicType)

*                         --- that is only intended to help with degenerate solutions
*                             very small additional cost depending on how, what type, when and on which crop manure is spread
                           * (1 + 1.E-4 * manApplicType.pos + 1.E-4*curManType.pos + 1.E-4 * m.pos + 1.E-4 * crops.pos) )
*
          $$iftheni.herd %herd% == true
*
*             --- additional cost for coverage with straw or foil
*
              + sum((curManChain(manChain),silos,manStorage)
                  $ (      sum(t_n(t1,nCur1) $ IsNodeBefore(nCur,nCur1), (v_buySilos.up(manChain,silos,t1,nCur1) ne 0))
                           or (sum(tOld, p_iniSilos(manChain,silos,tOld)))),
                  v_siCovComb(manChain,silos,t,nCur,manStorage)*p_siloCovCost(silos,manStorage))
*
*             --- storage cost for manure
*
              + sum( (curManChain(manChain),manStorage,m),
                   v_volInStorageType(manChain,manStorage,t,nCur,m)/p_nutPerQubic("N")
                                        * (0.10 + 0.01 $ sameas(manStorage,"storSub")))
          $$endif.herd
*
          $$iftheni.ExMan %AllowManureExport%==true
*
*             --- manure export cost
*
              +  sum( (manChain_type(manChain,curManType),m),v_manExport(manChain,curManType,t,nCur,m) )
                    * p_price%l%("manureExport","conv",t)
          $$endif.ExMan
*
          $$iftheni.im "%AllowManureImport%" == "true"
             $$iftheni.bioex "%AllowBiogasExchange%" == "false"
*
*                --- manure import cost
*
                 + sum ((m,manImports,sys),  v_manImport(manImports,t,nCur,m) *  p_inputprice%l%("manImport",sys,t))
                                                                        /      sum(sys $ p_inputprice%l%("manImport",sys,t),1)
             $$elseifi.bioex "%AllowBiogasExchange%" == "true"
*
*                --- costs of netto manure import from external biogas plant
*
                  + sum ((manImports,sys),  v_netImportManure(ManImports,t,nCur) *  p_inputprice%l%("ManBiogasImport",sys,t))
                                                                      /        sum(sys $ p_inputprice%l%("ManBiogasImport",sys,t),1)
*
*                --- Costs related to biomass export to biogas plant
*                    (for each tonne: 2€ + 0.35 * km; by Strobel, Martin: Biomasse-Ernte Logistik: Planzahlen, Methode und Anwendung für den Praxiseinsatz
*                    cost for transport to farm is already considered in KTBL database: substract costs for distance to farm!

                 + (2 + 0.35 * (p_DistBiogas-p_actPlotDist)) * sum(biogas_exchange, v_expBiomass(biogas_exchange,t,nCur))



*
*                ---- transport costs: manure import
*                     based on KTBL Feldarbeitsrechner, Gülletransport zum Feld, Tauchmotorpumpe Elektromotor,
*                     25kW, Gülletransportanhänger 21m³, 83kW; Schlaggröße 2ha; Hof-Feld-Entfernung 5km, Transportmenge: 7m³/ha
*               --- machine costs: 0.38 €/m3 je km
                +    sum((manImports,m), v_manImport(manImports,t,nCur,m)) * p_DistBiogas * 0.38
*                    -- labour requirements: 0.013 h/m3 je km
                +    sum((manImports,m), v_manImport(ManImports,t,nCur,m)) * p_DistBiogas * 0.013 * p_wage("hourly",t)


             $$endif.bioex
          $$endif.im
       $$endif.man
             ;

  $$iftheni.herd %herd% == true

*
*    --- very moderate increase of variable costs of herds per year with increasing livestock densities
*        [helps with calibration of model]
*
     varCostInc_(sumHerds,breeds,t_n(tCur,nCur),cropShareLevl) $ sum(actHerds(sumHerds,breeds,feedRegime,t,m),p_luSumHerds(sumHerds,breeds)) ..

         v_varCostInc(sumHerds,breeds,tCur,nCur,cropShareLevl)
            =G= v_sumHerd(sumHerds,breeds,tCur,%nCur%) * p_luSumHerds(sumHerds,breeds)
                  - %maxStockingRate%*(p_nArabLand+p_nGrasLand+p_nPastLand)*cropShareLevl.pos/card(cropShareLevl);
  $$endif.herd

*
* --- variable costs from activities
*
  varCostActs_(t_n(tCur(t),nCur)) ..

     v_varCostActs(t,nCur) =G=
*
*       --- variable costs of crop production (as far as not covered by constraints)
*
        + sum( c_p_t_i(curCrops(crops),plot,till,intens),
                    v_cropHa(crops,plot,till,intens,t,%nCur%)
                       * (p_vCostC(crops,till,intens,t) + p_fCostC(crops,till,intens,t)))
*
*       --- variable costs from straw production and storing
*
        + sum (  c_p_t_i(curCrops(crops),plot,till,intens),  v_residuesRemoval(crops,plot,till,intens,t,nCur)
                        * p_vCostStrawRemoval(crops,plot,till,intens,t) )
*
*       --- variable costs of animal production (as far as not covered by constraints)
*
        $$iftheni.herd %herd% == true
*
*          --- increase of up to 5 Euro per head if LU density of the herd reaches 2 LU/ha
*
           $$iftheni.pmp "%pmp%"=="true"

               +  sum( (sumHerds,Breeds) $ sum(actHerds(sumHerds,breeds,feedRegime,t,m),p_luSumHerds(sumHerds,breeds)),
                    0.1 * sqr(v_sumHerd(sumHerds,breeds,tCur,%nCur%)) * p_luSumHerds(sumHerds,breeds)
                          /(p_nArabLand+p_nGrasLand+p_nPastLand))

           $$else.pmp

               + sum( (sumHerds,Breeds,cropShareLevl) $ sum(actHerds(sumHerds,breeds,feedRegime,t,m),p_luSumHerds(sumHerds,breeds)),
                         v_varCostInc(sumHerds,breeds,t,nCur,cropShareLevl) * 5/card(cropShareLevl))

           $$endif.pmp

           + sum( (actHerds(possHerds,breeds,feedRegime,t,m)),
                      v_herdSize(possHerds,breeds,feedRegime,t,nCur,m)

*                   --- (1) effect of monthly resolution, e.g. if yearly = 1/1, if monthly 1/12
                  * [    { 1/card(m)
*                   --- (2) reflect production length
                            * min(12,p_prodLength(possHerds,breeds))/12 } $ cattle(possHerds)
                       + 1 $ (not cattle(possHerds)) ]
*                   --- cost per year for doing the process one time (e.g. rais one calv) for cows and sows
*                       monthly value for piglets and fattners
                            * p_vCost(possHerds,breeds,t) )
        $$endif.herd
        ;

* ------------------------------------------------------------------------------------
*
*                Input purchasing levels and associated costs
*
* ------------------------------------------------------------------------------------

*
* --- total costs of buying inputs, by organic and conventional system
*
  buyCostTot_(curSys(sys),t_n(tCur,nCur)) ..

   v_buyCostTot(sys,tcur,nCur)
*
*      --- cost of buying inputs (explicitly covered by constraints, such a feed, fertilizer ...)
*
         =E=     sum(curInputs(inputs) $ (v_buy.up(inputs,sys,tCur,nCur) ne 0), v_buyCost(inputs,sys,tCur,nCur));
*
* --- costs of buying specific inputs
*     (SON specific price times SON specific production quantities)
*
  buyCost_(curInputs(inputs),curSys(sys),t_n(tCur(t),nCur)) $ (p_inputprice%l%(inputs,sys,t) $ (v_buy.up(inputs,sys,t,nCur)  ne 0))  ..

     v_buyCost(inputs,sys,t,nCur) =e= p_inputprice(inputs,sys,t)
                                       $$iftheni.sp %stochProg%==true
                                             * ( 1 + (p_randVar("priceInputs",nCur)-1) $ randProbs(inputs) )
                                       $$endif.sp
                                    * v_buy(inputs,sys,t,nCur);
*
* --- physical ammounts of inputs bought
*
  buy_(curinputs(inputs),t_n(tCur(t),nCur)) $ sum(sys $ p_inputprice%l%(inputs,sys,t),1) ..

    sum(curSys,v_buy(inputs,curSys,t,nCur) $  p_inputprice%l%(inputs,curSys,t))

        =G=
*
*         --- related to crop production (p_costQuant covers cost/ha, not! physical amounts)
*
          + sum( c_p_t_i(curCrops(crops),plot,till,intens) $ p_costQuant(crops,till,intens,inputs),
               v_cropHa(crops,plot,till,intens,t,%nCur%) * p_costQuant(crops,till,intens,inputs) * v_costQuant(crops,inputs)
*
*         --- yield depression effects in case of herbicides, first hectare has only 75% of herbicide cost
*
                   * ( 1 - 0.25  $ pesticides(inputs)))
          $$iftheni.pmp "%pmp%"=="true"
*
*            --- yield depression effects, increase in plant protection cost
*

             + sum( (curCrops(Crops),sys) $ [sum(c_p_t_i(crops,plot,till,intens) $ sys_till(sys,till),1) $ p_critShare(crops,sys,"dep1")],

               0.5 * sqr(v_sumCrop(crops,sys,t,%nCur%))
                                       /[  (  p_nArabLand  $ (not grassCrops(crops))
                                           + (p_nGrasLand+p_nPastLand) $ grassCrops(crops))
                                             * smax(cropShareLevl,p_critShare(crops,sys,cropShareLevl))
                                        ] * 0.5
          $$else.pmp

            + sum( (curCrops(Crops),cropShareLevl,sys) $ sum(c_p_t_i(crops,plot,till,intens) $ sys_till(sys,till),1),
                     v_cropShareEffect(crops,sys,cropShareLevl,t,%nCur%)*p_cropShareLevl(crops,sys,cropShareLevl)

          $$endif.pmp
*
              *[{    sum(c_p_t_i(crops,plot,till,intens) $ sys_till(sys,till),  p_costQuant(crops,till,intens,inputs) * v_costQuant(crops,inputs))
                 /   sum(c_p_t_i(crops,plot,till,intens) $ (sys_till(sys,till) $ p_costQuant(crops,till,intens,inputs)),1)
                } $  sum(c_p_t_i(crops,plot,till,intens) $ (sys_till(sys,till) $ p_costQuant(crops,till,intens,inputs)),1)
*
*                --- some moderate effect (6 Euro max: 3 * 8 = 24 * 0.25 effect of crop shares)
*                    if no herbicide costs are present
*
                 + 8 $  (not sum(c_p_t_i(crops,plot,till,intens) $ (sys_till(sys,till) $ p_costQuant(crops,till,intens,inputs)),1))
               ])  $ pesticides(inputs)

          $$iftheni.cattle %cattle%==true
*
*            --- feed bought from markets for cattle
*
             + sum( sameas(inputs,curFeeds(feedsY)), v_feedUseBuy(feedsY,t,nCur))
          $$endif.cattle

          $$iftheni.dh  %cowherd%==true
*
*            --- heifers bought
*
             + sum( (heifsBought,curBreeds,m) $ (sum(feedRegime,actHerds(heifsBought,curBreeds,feedRegime,t,m)) $ sameas(heifsBought,inputs)),
                                                  v_herdStart(heifsBought,curBreeds,t,%nCur%,m))
*
*            --- costs of sexing
*
             + sum((breeds,m),v_sexingF(breeds,t,nCur,m) * (%additionalIE% + 1)) $ sameas(inputs,"femaleSexing")
             + sum((breeds,m),v_sexingM(breeds,t,nCur,m) * (%additionalIE% + 1)) $ sameas(inputs,"maleSexing")
          $$endif.dh

          $$iftheni.beef "%farmBranchBeef%"=="on"
*
*            --- bulls bought
*
             + sum((bullsBought,curBreeds,m) $ (sum(feedRegime,actHerds(bullsBought,curBreeds,feedRegime,t,m)) $ sameas(bullsBought,inputs)),
                                                   v_herdStart(bullsBought,curBreeds,t,%nCur%,m))
          $$endif.beef

          $$iftheni.cb "%buyCalvs%"=="true"
             $$ifthen.herdStart defined v_herdstart
*
*               --- calves bought
*
                + sum((calvesBought,curBreeds,m) $ (sum(feedRegime,actHerds(calvesBought,curBreeds,feedRegime,t,m)) $ sameas(calvesBought,inputs)),
                                                     v_herdStart(calvesBought,curBreeds,t,%nCur%,m))
             $$endif.herdstart
          $$endif.cb

          $$iftheni.straw %strawManure% == true

              + (sum(stables_to_stableStyles(stables,stableStyles),
*
*                 --- straw used in stables, minus ammount produced (= ammount bought)
*
                     p_strawQuant(stables,stableStyles) * 365
                   * sum(stableTypes, p_stableSize(stables,stableTypes)) * v_stableUsed(stables,t,nCur)) / 1000
                 - sum(prodsResidues, v_residuesOwnConsum(prodsResidues,t,nCur))) $ sameas(inputs,"straw")
          $$endif.straw
*
          $$iftheni.sows "%farmBranchSows%"=="on"
*
*            --- young sows
*
             + sum( m $  sum(feedRegime,actHerds("youngSows","",feedRegime,t,m)),    v_herdStart("youngSows","",t,%nCur%,m)
                        $ sameas(inputs,"youngSow"))
          $$endif.sows

          $$iftheni.fattners "%farmBranchFattners%"=="on"
*
*            --- piglets for fattners branch
*
             + sum( m $ sum(feedRegime,actHerds("pigletsBought","",feedRegime,t,m)), v_herdStart("pigletsBought","",t,%nCur%,m)
                   $ sameas(inputs,"pigletsBought"))

          $$endif.fattners

          $$iftheni.pigs %pigHerd%==true
*
*            --- feeds for pigs
*
             + sum( (sameas(inputs,feedspig)),  v_feedPurchPig(feedspig,t,nCur))
          $$endif.pigs

          $$iftheni.biogas %biogas%==true
*
*             --- crops and manure bought for biogas production
*
              + sum( (curBhkw(bhkw),curEeg(eeg),sameas(crM,inputs),m) $ selPurchInputs(crM),
                        v_purchCrop(bhkw,eeg,crM,t,nCur,m))

              + sum( (curBhkw(bhkw),curEeg(eeg),sameas(curmaM,inputs),m) $ selPurchInputs(curmaM),
                      v_purchManure(bhkw,eeg,curmaM,t,nCur,m))

          $$endif.biogas
*
*         --- synthetic fertilizers
*
          + sum(  (c_p_t_i(curCrops(crops),plot,till,intens),sameas(inputs,syntFertilizer),m),
                  v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m))

*         --- variable costs for diesel from tractor

          + sum(curMachines(machType),
              v_machNeed(machType,"hour",t,nCur) * p_machAttr(machType,"diesel_h"))
                $ sameas(inputs,"diesel")

          $$iftheni.data "%database%" == "KTBL_database"

*            --- diesel requirements of KTBL field operations

             + sum(  (operation,c_p_t_i(curCrops(crops),plot,till,intens)),
                 p_opInputReq(crops,till,"diesel",operation)
                    * v_cropHa(crops,plot,till,intens,t,%nCur%)
               )
                      $ sameas(inputs,"diesel")
          $$endif.data
*
*         --- hired labour
*
          $$ifi "%allowHiring%"=="true"       + v_hireWorkers(tCur,nCur) $ sameas(inputs,"hiredLabour")
*
*         --- cropInsurance
*
          $$iftheni.sp "%stochProg%"=="true"
               $$iftheni.stochYield "%stochYields%"=="true"
                     + sum((crops,sys) $ sum(c_p_t_i(crops,plot,till,intens) $ sys_till(sys,till),1),
                         v_buyCropIns(crops,sys,tCur) * p_cropIns(crops,sys,tCur,nCur))
                            $ sameas(inputs,"cropIns")
               $$endif.stochYield
          $$endif.sp
         ;

* ------------------------------------------------------------------------------------
*
*                Investment and related costs
*
* ------------------------------------------------------------------------------------

*
* --- sum of investments in current year
*
  sumInv_(t_n(tFull(t),nCur)) ..
*
     v_sumInv(t,nCur) =e=
*
*      --- new land bought
*
       $$ifi %landBuy% == true  sum( plot, v_buyPlot(plot,t,nCur)*p_buyPlotSize*p_pland(plot,t)) $ tCur(t)
*
*      --- stables, silos, buildings and machines
*
       + sum(inv $ curInv(inv), v_costinv(inv,t,nCur)) $ tCur(t)
*
*      --- new biogas plant bought
*
       $$iftheni.biogas %biogas%==true

                  + sum((curBhkw(bhkw), curEeg(eeg)),
                        v_buyBioGasPlant(bhkw,eeg,"ih20",t,nCur) $tCur(t)
                                                * p_priceBioGasPlant(bhkw,"ih20"))

                  + sum((curBhkw(bhkw), ih),
                        v_buyBioGasPlantParts(bhkw,ih,t,nCur)
                                                * ( p_priceBioGasPlant(bhkw,ih) $ (not(ih20(ih)))
*                                                 + p_priceFlexBioGasPlant(bhkw,eeg,ih)$eegDM(eeg) )
                                                  ))
       $$endif.biogas
      ;
*
*   --- costs of different types of investment (different stables, buildings, machinery, manure silos)
*
    costInv_(inv,t_n(tCur(t),nCur)) $ curInv(inv) ..

      v_costInv(inv,t,nCur) =E=

         $$ifthen.stables "%herd%"=="true"
*
*           --- new stables bought
*
              sum( (stables,hor) $ ((v_buyStables.up(stables,hor,t,nCur) ne 0) and (v_hasFarm.up(t,nCur) ne 0) and sameas(inv,stables)),
                 v_buyStablesF(stables,hor,t,nCur)*p_priceStables(stables,hor,t)*p_vPriceInv("stables"))

            + sum( (stableTypes,hor) $ ((v_minInvStables.up(stableTypes,hor,t,nCur) ne 0) and (v_hasFarm.up(t,nCur) ne 0) and sameas(inv,stableTypes)),
                  v_minInvStables(stableTypes,hor,t,%nCur%) * p_minInvStableCost(stableTypes,hor,t))

         $$endif.stables
*
*        --- buildings and structures
*
         + sum(curBuildings(buildings) $ sameas(inv,buildings), p_priceBuild(buildings,t) * p_vPriceInv("buildings") *
                                         v_buyBuildingsF(buildings,t,nCur))
*
*        --- new machinery bought (integer and continous depreciation solution)
*
         +   sum(curMachines(machType) $ sameas(machType,inv),
                 (v_buyMach(machType,t,%nCur%) $(v_buyMachFlex.up(machType,t,%nCur%) eq 0)

                 +v_buyMachFlex(machType,t,nCur))*p_priceMach(machType,t)*p_vPriceInv("machines")
             )
*
*        --- new manure silos bought
*
         $$ifthen.silos defined v_buySilos.up

          + sum( (curManChain(manChain),silos) $ ((v_hasFarm.up(t,nCur) ne 0) $ sameas(silos,inv)),
                   v_buySilosF(manChain,silos,t,nCur)*p_priceSilo(silos,t)*p_vPriceInv("silos"))
         $$endif.silos
    ;

* ------------------------------------------------------------------------------------
*
*                Machinery use, machinery and building need, building acquisition
*                decision etc.
*
* ------------------------------------------------------------------------------------

*
* --- tractor restriction for labour use for herds and biogas plant, management and off-farm, per month,
*
  tracRestrFieldWorkHours_(plot,labReqLevl,labPerSum,t_n(tCur(t),nCur)) $ (p_plotSize(plot) $ plot_landType(plot,"arab")) ..

     v_fieldWorkHours(plot,labReqLevl,labPerSum,t,nCur)

      =L=
           sum(labPerSum_ori(labPerSum,LabPeriod),
             sum(plot_soil(plot,soil),
                    sum(curClimateZone, p_fieldWorkingDays(labReqLevl,labPeriod,curClimateZone,soil)) * 12)
                            * v_tracDist(plot,labPerSum,t,nCur));
*
* --- tractor use distribution (in number of tractors)
*     in each labor period per soil
*
  tracDistribution_(labPerSum,t_n(tCur(t),nCur)) ..

     sum(plot $ p_plotSize(plot), v_tracDist(plot,labPerSum,t,nCur))
        =L=
*            --- The number of actively used tractors can not be higher than family labor workers
             ceil(%Aks%)
*            --- and hired workers
            $$ifi "%allowHiring%"==true  + v_hireWorkers(t,nCur)
*           --- minus those who are working off farm
            -  sum(workOpps, v_labOff(t,%nCur%,workOpps) * workOpps.pos * 0.5);
*
* --- need of machineries per SON, the SON with the highest need
*     defines the machinery park investments
*
  machines_(curMachines(machType),machLifeUnit,t_n(tCur(t),nCur))     $ p_lifeTimeM(machType,machLifeUnit) ..
*
*    --- less than total machinery need
*
     v_machNeed(machType,machLifeUnit,t,nCur) =G=
*
*       --- crops times their request for specific machine type
*           crops and machines not included in the KTBL Regression in ha/ha: hour/ha ...
*           machines inclueded in KTBL Regression: EUR depreciation costs

        sum( c_p_t_i(curCrops(crops),plot,till,intens) $(p_machNeed(crops,till,intens,machType,machLifeUnit) gt 1E-6) ,
            v_cropHa(crops,plot,till,intens,t,%nCur%)
             * p_machNeed(crops,till,intens,machType,machLifeUnit))
*
*       --- yield depression effects (increase plant protection cost)
*
        $$iftheni.pmp "%pmp%"=="true"
            + sum( (curCrops(Crops),sys) $ [sum(c_p_t_i(crops,plot,till,intens) $ (sys_till(sys,till)
                                             $ p_critShare(crops,sys,"dep1") $ (p_machNeed(crops,till,intens,machType,machLifeUnit) gt 0)),1)
                                                                                        $ sameas(machType,"sprayer")],
                  sqr(v_sumCrop(crops,sys,t,nCur))
                                               /[  (  p_nArabLand  $ (not grassCrops(crops))
                                                    + (p_nGrasLand+p_nPastLand) $ grassCrops(crops))
                                                      * smax((sys_till(sys,till),cropShareLevl),p_critShare(crops,sys,cropShareLevl))
                                                      ]
        $$else.pmp

            + sum( (curCrops(Crops),sys,cropShareLevl) $ (sum(c_p_t_i(crops,plot,till,intens) $ sys_till(sys,till),
                                                           p_machNeed(crops,till,intens,machType,machLifeUnit))
                                                                                      $ sameas(machType,"sprayer")),
                  v_cropShareEffect(crops,sys,cropShareLevl,t,nCur)*p_cropShareLevl(crops,sys,cropShareLevl)

        $$endif.pmp

           *    sum(c_p_t_i(crops,plot,till,intens) $ sys_till(sys,till),p_machNeed(crops,till,intens,machType,machLifeUnit))
              / sum(c_p_t_i(crops,plot,till,intens) $ (sys_till(sys,till) $ p_machNeed(crops,till,intens,machType,machLifeUnit)),1))

*       ---- machine need for the application of N (syntfert)

        +  sum( (c_p_t_i(curCrops(crops),plot,till,intens),curInputs(syntFertilizer),m),
                 v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m) * (1 + m.pos*1.E-3)
                    * p_machNeed(syntFertilizer,till,"normal",machType,machLifeUnit))


        $$iftheni.man "%manure%"=="true"

*          ---- machine need for the application of manure

           + sum((c_p_t_i(curCrops(crops),plot,till,intens),manApplicType_manType(ManApplicType,curManType),m)
                 $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0),
                   v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                     * p_machNeed(ManApplicType,"plough","normal",machType,machLifeUnit))

        $$endif.man

        $$iftheni.herd "%herd%"=="true"
        

            + v_machNeedHerds(machType,machLifeUnit,t,nCur)
                 $ sum(actHerds(sumHerds,breeds,feedRegime,t,m),
                     p_machNeed(sumHerds,"plough","normal",machType,machLifeUnit))
        $$endif.herd
    ;

  machinesGras_(curMachines(machType),machLifeUnit,t_n(tCur(t),nCur))     $ p_lifeTimeM(machType,machLifeUnit) ..


  v_machNeedGras(machType,machLifeUnit,t,nCur) =G=
    
*       --- crops times their request for specific machine type
*           crops and machines not included in the KTBL Regression in ha/ha: hour/ha ...
*           machines inclueded in KTBL Regression: EUR depreciation costs

        sum( c_p_t_i(curCrops(crops),plot,till,intens) $(p_machNeed(crops,till,intens,machType,machLifeUnit) gt 1E-6) ,
            v_cropHa(crops,plot,till,intens,t,%nCur%)
             * p_machNeed(crops,till,intens,machType,machLifeUnit))
*
*       --- yield depression effects (increase plant protection cost)
*
        $$iftheni.pmp "%pmp%"=="true"
            + sum( (curCrops(Crops),sys) $ [sum(c_p_t_i(crops,plot,till,intens) $ (sys_till(sys,till)
                                             $ p_critShare(crops,sys,"dep1") $ (p_machNeed(crops,till,intens,machType,machLifeUnit) gt 0)),1)
                                                                                        $ sameas(machType,"sprayer")],
                  sqr(v_sumCrop(crops,sys,t,nCur))
                                               /[  (  p_nArabLand  $ (not grassCrops(crops))
                                                    + (p_nGrasLand+p_nPastLand) $ grassCrops(crops))
                                                      * smax((sys_till(sys,till),cropShareLevl),p_critShare(crops,sys,cropShareLevl))
                                                      ]
        $$else.pmp

            + sum( (curCrops(Crops),sys,cropShareLevl) $ (sum(c_p_t_i(crops,plot,till,intens) $ sys_till(sys,till),
                                                           p_machNeed(crops,till,intens,machType,machLifeUnit))
                                                                                      $ sameas(machType,"sprayer")),
                  v_cropShareEffect(crops,sys,cropShareLevl,t,nCur)*p_cropShareLevl(crops,sys,cropShareLevl)

        $$endif.pmp

           *    sum(c_p_t_i(crops,plot,till,intens) $ sys_till(sys,till),p_machNeed(crops,till,intens,machType,machLifeUnit))
              / sum(c_p_t_i(crops,plot,till,intens) $ (sys_till(sys,till) $ p_machNeed(crops,till,intens,machType,machLifeUnit)),1))

*       ---- machine need for the application of N (syntfert)

        +  sum( (c_p_t_i(curCrops(crops),plot,till,intens),curInputs(syntFertilizer),m),
                 v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m) * (1 + m.pos*1.E-3)
                    * p_machNeed(syntFertilizer,till,"normal",machType,machLifeUnit))


        $$iftheni.man "%manure%"=="true"

*          ---- machine need for the application of manure

           + sum((c_p_t_i(curCrops(crops),plot,till,intens),manApplicType_manType(ManApplicType,curManType),m)
                 $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0),
                   v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                     * p_machNeed(ManApplicType,"plough","normal",machType,machLifeUnit))

        $$endif.man
        ;

*
* --- existing building inventory must exceed need in curren year and node
*
  buildingNeed_(curBuildType(buildType),buildCapac,tCur(t),nCur)
       $ (sum(curProds(prods),p_buildingNeed(prods,buildType,buildCapac)) $ t_n(t,nCur) ) ..

     sum(buildType_buildings(buildType,buildings)
             $ (  (     sum(t_n(t1,nCur1) $ isNodebefore(nCur,nCur1), (v_buyBuildings.up(buildings,t1,nCur1) ne 0))
                    or  sum(tOld, p_iniBuildings(buildings,tOld)))
                     $ curBuildings(buildings)),

          v_buildingsInv(buildings,t,nCur) * p_building(buildings,buildCapac))

        =G= v_buildIngNeed(buildType,t,nCur);

*
* --- capacities required for the different building types (e.g. potato storage)
*
  buildingNeedDef_(curBuildType(buildType),buildCapac,t_n(tCur(t),nCur))
       $ sum(curProds(prods), p_buildingNeed(prods,buildType,buildCapac)) ..

     v_buildIngNeed(buildType,t,nCur)
        =G= sum((curProds(prods)), v_prods(prods,t,nCur) * p_buildingNeed(prods,buildType,buildCapac));
*
* --- buildings are bought only if there is a need (might help solver)
*
  buildingBuyB_(curBuildings(buildings),t_n(tCur(t),nCur))
       $ (  (v_buyBuildings.up(buildings,tCur,nCur) ne 0)
                                                      $ sum(buildCapac $ (p_building(buildings,buildCapac) gt eps),1)) ..

     v_BuyBuildingsF(buildings,t,nCur)
        =L= sum( (curProds(prods),buildType,buildCapac)
                      $ (buildType_buildings(buildType,buildings) $ p_building(buildings,buildCapac)),
                         v_prods(prods,t,nCur) * p_buildingNeed(prods,buildType,buildCapac));
*
* --- define inventory of buildings and structures, from current and past investments
*
  buildingInv_(curBuildings(buildings),tCur(t),nCur)
      $ ( (    sum(t_n(t1,nCur1) $ isNodeBefore(nCur,nCur1), (v_buyBuildings.up(buildings,t1,nCur1) ne 0))
               or (sum(tOld, p_iniBuildings(buildings,tOld)))) $ t_n(t,nCur) ) ..

     v_buildingsInv(buildings,t,nCur)
        =L=
*
*       --- old building / silo according to building date and lifetime
*           (will drop out of year is too far in the past)
*
        sum(tOld $ (   ((p_year(tOld) + p_lifeTimeBuild(buildings)) gt p_year(t))
                      $ ( p_year(told)                               le p_year(t))),
                         p_iniBuildings(buildings,tOld))
*
*       --- plus (old) investments - de-investments
*
        + sum(t_n(t1,nCur1) $ (   ((p_year(t1)  + p_lifeTimeBuild(buildings)) gt p_year(t))
                              $ ( p_year(t1)                         le p_year(t))
                              $ tcur(t1) $ isNodeBefore(nCur,nCur1)),
                                + v_buyBuildingsF(buildings,t1,nCur1));
*
*   --- concave combinations (actual size is between two points on the concave set)
*
    buildingsConcaveComb_(curBuildings(buildings),t_n(tCur,nCur)) $ (sum(buildType_buildings(curBuildType,buildings1)
                                                              $ ( (v_buyBuildings.up(buildings1,tCur,nCur) ne 0)
                                                                     $ buildType_buildings(curBuildType,buildings)),1) gt 1) ..

       sum(buildType_buildings(curBuildType,buildings1) $ (buildType_buildings(curBuildType,buildings)
*              --- that counts building which are not neighbouring in size (not allowed)
               $ (abs(buildings.pos - buildings1.pos) gt 1)), v_buyBuildings(buildings1,tCur,%nCur%))
           =L=
*              --- the choice is not allowed if that type of buildings is invested in
                (1 - v_buyBuildings(buildings,tCur,%nCur%))*2;
*
*  --- restrict fractional choice to the two points selected above
*
   buildingsBin_(curBuildings,t_n(tCur,nCur)) $ ((v_buyBuildings.up(curBuildings,tCur,nCur) ne 0)
                                                     $ (v_buyBuildings.up(curBuildings,tCur,nCur) le 1)
                                                     $ (v_hasFarm.up(tCur,nCur) ne 0)) ..

        v_buyBuildingsF(curBuildings,tCur,ncur) =L= v_buyBuildings(curBuildings,tCur,%ncur%);
*
*  --- Shares must add up to one
*
   buildingsConvexComb_(curBuildType,t_n(tCur,nCur)) $ (sum(buildType_buildings(curBuildType,curBuildings),1) gt 1)  ..

        sum(buildType_buildings(curBuildType,curBuildings) $ (v_buyBuildings.up(curBuildings,tCur,nCur) ne 0),
                                                                    v_buyBuildingsF(curBuildings,tCur,nCur)) =E= 1;
*
*  --- two points on concave set must be chosen
*
   convBuildings_(curBuildType,t_n(tCur,nCur)) $ (sum(buildType_buildings(curBuildType,curBuildings)
                                                        $ (v_buyBuildings.up(curBuildings,tCur,nCur) ne 0),1) gt 1)  ..

        sum(buildType_buildings(curBuildType,curBuildings),v_buyBuildings(curBuildings,tCur,%nCur%)) =E= 2;
*
*  --- buying of machines, continous (= fractional investments)
*      according to need in operation hours / mass flow etc. (not lifetime on years)
*
   machBuyFlex_(curMachines(machType),machLifeUnit,tFull(t),nCur)
       $ (   (v_machInv.up(machType,machLifeUnit,t,nCur) ne 0)
           $ v_buyMachFlex.up(machType,t,nCur)  $ p_lifeTimeM(machType,machLifeUnit)
           $ (not sameas(machLifeUnit,"years")) $ p_priceMach(machType,t) $ t_n(t,nCur))  ..

      v_buyMachFlex(machType,t,nCur) * p_lifeTimeM(machType,MachLifeUnit)
           =L= v_machNeed(machType,machLifeUnit,t,nCur) $ tCur(t)

             + [sum( (t_n(t1,nCur1)) $ ( tCur(t1) $ isNodeBefore(nCur,nCur1)),
                                v_machNeed(machType,machLifeUnit,t1,nCur1))/card(tCur)
                ]  $ ( (not tCur(t)) and p_prolongCalc);
*
*  --- inventory of machines according to operation hours / mass flow etc. (not lifetime on years)
*
   machInv_(curMachines(machType),machLifeUnit,tFull(t),nCur)
        $ (     (v_machInv.up(machType,machLifeUnit,t,nCur) ne 0)
              $ p_lifeTimeM(machType,machLifeUnit)  $ p_priceMach(machType,t)
              $ (not sameas(machLifeUnit,"years"))  $ t_n(t,nCur) )  ..
*
*    --- inventory end of current year (in operating hours, hectares etc.)
*
     v_machInv(machType,machLifeUnit,t,nCur)

           =e=
*
*      --- inventory end of last year (in operating hours)
*
       sum(t_n(t-1,nCur1) $ anc(nCur,nCur1), v_machInv(machType,machLifeUnit,t-1,nCur1))
*
*      --- new machines, converted in operation time
*
       + (v_buyMach(machType,t,%nCur%) $(v_buyMachFlex.up(machType,t,%nCur%) eq 0) +v_buyMachFlex(machType,t,nCur)) * p_lifeTimeM(machType,MachLifeUnit)
*
*      --- minus operating hours in current year if in normal planning period
*
       - v_machNeed(machType,machLifeUnit,t,nCur)  $ tCur(t)
*
*      --- minus operating hours of weighted average over normal planning period
*          if beyond the normal planning period
*
        - [sum( (t_n(t1,nCur1)) $ ( tCur(t1) $ isNodeBefore(nCur,nCur1)),
                        v_machNeed(machType,machLifeUnit,t1,nCur1))/card(tCur)
         ] $ ( (not tCur(t)) and p_prolongCalc)
     ;
*
* --- inventory of mach according to maximal lifetime in years
*     (not linked to need of actual operations)
*
  machInvT_(curMachines(machType),tFull(t),nCur)
      $ (      (v_machInv.up(machType,"years",t,nCur) ne 0)
              $ p_lifeTimeM(machType,"years")
              $ p_priceMach(machType,t) $ t_n(t,nCur)  )  ..
*
*    --- inventory end of current year (in operating hours)
*
     v_machInv(machType,"years",t,nCur)

   +  sum( t_n(t1,nCur1) $ (  (p_year(t1) gt smax( tOld $ p_iniMachT(machType,told),
                                                   p_year(tOld) + p_lifeTimeM(machType,"years")))
                           $  (p_year(t1)+p_prolongLen gt p_year(t))
                           $ tCur(t1)  $ isNodeBefore(nCur,nCur1)),
               v_machInv(machType,"years",t1,nCur1)/p_proLongLen)
                                              $ ( (not tCur(t)) and p_prolongCalc)

        =L=
*
*       --- old machines according to investment dates
*           (will drop out of equation if too old)
*
        sum( tOld $ (   ((p_year(tOld) + p_lifeTimeM(machType,"years")) gt p_year(t))
                            $ ( p_year(told)                            le p_year(t))),
                               p_iniMachT(machType,tOld))

*
*       --- plus (old) investments - de-investments
*
     +  sum( t_n(t1,nCur1) $ (  ((p_year(t1)  + p_lifeTimeM(machType,"years") ) gt p_year(t))
                              $ ( p_year(t1)                                    le p_year(t))
                              $ isNodeBefore(nCur,nCur1)),
                                              v_buyMach(machType,t1,%nCur1%));
     ;
*
* --- helper equations for binary solver: only buy a machine once over a period equal to its lifetime
*
  buyMachLifeTimeT_(curMachines(machType),t_n(tCur(t),nCur)) $ ((v_buyMach.up(machType,tCur,nCur) ne 0) $ p_lifeTimeM(machType,"years")
                                                                  $ ( mod(t.pos,p_lifeTimeM(machType,"years")) eq 1) $ (Card(tCur) gt 1) ) ..

        sum( (tFull(t1),nCur1) $ ( t_n(t1,nCur1)
                                   $ (p_year(t1) + p_lifeTimeM(machType,"years") lt p_year(t))
                                   $ (v_buyMach.up(machType,t1,nCur1) ne 0)),

                 v_buyMach(machType,t1,%nCur1%)) =L= 1;
*
* ---- help equations, only buy machine if there some future need for it
*
  buyMachLifeTimeO_(curMachines(machType),tCur(t),nCur) $ ((v_buyMach.up(machType,tCur,nCur) ne 0) $ (not p_lifeTimeM(machType,"years"))
                                                               $ ( mod(t.pos,10) eq 1) $ t_n(tCur,nCur) $ (Card(tCur) gt 1)  ) ..

     sum( (tFull(t1),nCur1) $ (t_n(t1,nCur1)
                               $ (p_year(t1)+10 lt p_year(t))
                               $ (v_buyMach.up(machType,t1,nCur1) ne 0)),

             sum(machLifeUnit, v_buyMach(machType,t1,%nCur1%)*p_lifeTimeM(machType,machLifeUnit)))

     =L= sum( (tFull(t1),nCur1) $ (t_n(t1,nCur1)
                                   $ tFull(t1) $ (p_year(t1)+ 10 lt p_year(t))
                                   $ (v_buyMach.up(machType,t1,nCur1) ne 0)),
             sum(machLifeUnit, v_machNeed(machType,machLifeUnit,t,nCur)
               + [sum( (t_n(t1,nCur1)) $ (tCur(t1) $ isNodeBefore(nCur,nCur1)),
                                             v_machNeed(machType,machLifeUnit,t1,nCur1))/card(tCur)
                  ] $ ( (not tCur(t)) and p_prolongCalc)
              ));

* ------------------------------------------------------------------------------------
*
*                Farm exists, farm size extensions, and branch sizes
*
* ------------------------------------------------------------------------------------
*
* --- off-farm work or having a farm must be active, if off-farm is available
*
  hasFarmAndOrBinWork_(t_n(tCur,nCur)) $ (sum(workOpps(workType)$ (v_labOff.up(tCur,nCur,workType) ne 0),1) $ t_n(tCur,nCur) ) ..

     v_hasFarm(tCur,%nCur%) + v_labOffB(tCur,%nCur%) =G= 1;
*
* --- trigger for having a farm (steer general management labour need)
*
  hasFarm_(branches,t_n(tCur(t),nCur)) $ ((not (sameas(branches,"farm") or sameas(branches,"cap"))) $ (v_hasBranch.range(branches,t,nCur) ne 0)) ..

     v_hasBranch(branches,t,%nCur%)  =l= v_hasFarm(t,%nCur%);
*
* --- if the farm is there in t, it must have been there in t-1
*
  hasFarmOrder_(tCur(t),nCur) $ (tCur(t-1) $ t_n(t,nCur)) ..

     v_hasFarm(t,%nCur%) =L= sum(t_n(t-1,nCur1) $ anc(nCur,nCur1), v_hasFarm(t-1,%nCur1%));
*
* --- trigger for having branches (steers management labour need)
*
  hasBranch_(branches,t_n(tCur(t),nCur))  $ (sum(branches_to_acts(branches,acts) ,1)
                                        $$ifi %biogas%==true  or sum(sameas(branches,"biogas"),1)
                                   )..

     v_branchSize(branches,t,nCur) =l= v_hasBranch(branches,t,%nCur%) * p_maxBranch(branches,t,nCur);
*
* --- definition of branch size in ha or number of animals
*
  branchSize_(branches,t_n(tCur(t),nCur)) $ ( sum(branches_to_acts(branches,possActs) ,1)
                                        $$ifi "%biogas%"=="true"  or sum(sameas(branches,"biogas"),1)
                                         )  ..

     v_branchSize(branches,t,nCur) =E= sum((branches_to_acts(branches,curCrops(crops)),plot,till,intens)
                                        $( c_p_t_i(crops,plot,till,intens) $ ( not catchcrops(crops)) ) ,
                                           v_cropHa(crops,plot,till,intens,t,%nCur%))

                              $$iftheni.herd "%herd%" == "true"
                                + sum( (branches_to_acts(branches,possHerds),breeds,feedRegime,m)
                                     $ (actHerds(possHerds,breeds,feedRegime,t,m) $ p_prodLength(possHerds,breeds)),
                                         v_herdSize(possHerds,breeds,feedRegime,t,nCur,m)
                                            * 1/min(12,p_prodLength(possHerds,breeds))
                                         )
                             $$endif.herd

                             $$iftheni %biogas% == true
                                + [sum( (curBhkw,curEeg,m), v_prodElec(Curbhkw,curEeg,t,nCur,m))/100000]
                                              $ sameas(branches,"biogas")
                             $$endif
   ;

*
*  --- renting out for x years
*
  $$setglobal rentContractLength 10

  rentOutNew_(plot,tCur(t),%nCur%) $ (p_plotSize(plot) $ t_n(t,%nCur%)) ..

       v_rentOutPlot(plot,t,%nCur%) =E= sum(t_n(t1,nCur1) $ ( sameScen(%nCur%,nCur1) $ (ord(t1) le ord(t))
                                                           $ (ord(t1)+%rentContractLength% gt ord(t))),
          v_rentOutPlotNew(plot,t1,nCur1));

**********************************************************************************************************
*
*   Models definition, including solver selection etc.
*
**********************************************************************************************************

  model m_farm
  /  obje_
     objeMean_
     objeN_
     leisureVal_
     offFarmWages_

      $$ifi %stochProg%==true m_stochProg

      $$iftheni.taxes not "%incomeTax%"=="None"
         incomeToTax_
         incomeTaxTot_
         incomeTax_
      $$endif.taxes
      hhsldIncome_
      profitTax_
      depr_
      netCashFlow_
      opCashFlow_
      invCashFlow_
      salRev_
      salRevProds_
      premTot_
      buy_
      costInv_
      buyCost_
      buyCostTot_
      varCost_
      varCostActs_
      varCostMach_

      $$ifi %manure%==true   varCostMan_
      $$ifi "%cattle%"=="true"  feedUp_

      prods_
      saleQuant_
      $$iftheni.eco not "%orgTill%"=="off"
         $$ifi "%orgTill%"=="optional" m_orgOpt
         orgPrem_
         orgPremCond_
      $$endif.eco

      $$ifi %landLease% == true rentOutNew_


      $$iftheni.herd %herd%==true
          $$ifi not "%pmp%"=="true"            varCostInc_
      $$endif.herd

      liquid_
      sumInv_

      machines_
      machinesGras_
      tracRestrFieldWorkHours_
      tracDistribution_
      machBuyFlex_
      machInv_
      buyMachLifeTimeT_
      buyMachLifeTimeO_
      machInvT_

      buildingInv_
      buildingsBin_
      buildingsConvexComb_
      convBuildings_
      buildingsConcaveComb_
      buildingBuyB_
      buildingNeed_
      buildingNeedDef_

      hasFarmAndOrBinWork_
      hasFarm_
      hasBranch_
      hasFarmOrder_
      branchSize_
*
*     --- blocks of equations defined in specific modules
*
      m_land
      m_labour
      $$ifi %biogas%==true        m_biogas
      $$ifi %manure% == true      m_manure
      $$ifi %herd%==true          m_herd
      $$ifi %pigHerd% == true     m_pigs
      $$ifi %cattle% == true      m_cattle
      $$ifi %duev% == true        m_duev
      $$ifi %envAcc%==true        m_env
      $$iftheni.c %cattle%==true
         $$ifi "%socialAcc%" == "true"   m_soci
      $$endif.c

      $$ifi not "%dynamics%"=="comparative-static" m_finCashFlow

      $$ifi %agriEnvSchemes%==true    m_aes
      $$ifi %EUCountry% == true m_policy_CAP
      $$ifi %nonEUCountry% == true m_policy_country
      $$ifi %carbonPriceC% ==true m_policyCarbon
  /;


  option limRow = 0;
  option limCol = 0;
  option LP=CONOPT;
  option CNS=CONOPT;
  option DNLP=CONOPT;

  $$if not setGlobal optcr $setGlobal optcr 0.5
  $$evalGlobal optcr round(%optcr%*100)/(100*100)
  option optcr =   %optcr%;
  option optca =   %optca%;

  option kill=v_nutTotalApplied;

  m_farm.solvelink  = 5;
  m_farm.holdfixed  = 1;
  m_farm.prioropt   = 0;
  m_farm.tryint     = 0.5;
  m_farm.iterlim    = 1.E+9;
  m_farm.limcol     = 10000;
  m_farm.optcr      = %optcr%;
  m_farm.optca      = %optCa%;
  m_farm.tolinfeas  = 1.E-7;
  m_farm.tolInfRep  = 1.E-7;
  m_farm.holdFixed  = 1;
  m_farm.trylinear  = 1;
  $$evalglobal reslim %reslim%
  m_farm.reslim = %reslim%;

  $$setglobal useMip ON
  $$ifi "%useRmip%"=="true" $setglobal useMip OFF

  $$setglobal QP off
  $$ifi "%parsAsVars%"=="true" $setglobal QP on
  $$ifi "%pmp%"=="true"        $setglobal QP on

  $$iftheni.QP "%QP%"=="off"
     $$setglobal RMIP RMIP
     $$setglobal MIP   MIP
  $$else.QP
     $$setglobal RMIP RMIQCP
     $$setglobal MIP  MIQCP
  $$endif.QP

  option integer1=1;
  option integer4=1;

  option %MIP%=%Solver%;
  $$iftheni %SOLVER%==ODHCPLEX
     option   MIP =ODHCPLEX;
     option %RMIP%=CPLEX;
     option  RMIP=CPLEX;
  $$else
     option   MIP =%solver%;
     option %RMIP%=%solver%;
     option  RMIP =%solver%;
  $$endif
