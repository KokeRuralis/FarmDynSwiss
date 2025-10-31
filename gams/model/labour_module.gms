********************************************************************************
$ontext

   FARMDYN project

   GAMS file : TEMPL.GMS

   @purpose  : Labour section of FarmDyn

   @author   : W.Britz, T.Kuhn, D.Schaefer(last modification), C.Pahmeyer, L.Kokemohr, J.Heinrichs
   @date     : 3.11.10
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : templ.gms

$offtext
********************************************************************************

    parameter

       p_yearlyLabH(t)                                 "Yearly max. labour hours from family labour"
       p_labManag(branches,regpar)                     "Labour needs for management, depending on branch size"

       p_workTime(workType)                            "Weekly work time in hours"
       p_commTime(workType)                            "Weekly commuting time in hours"
       p_workTimeLost(workType)                        "Actual reduction in willingness to work"

       p_fieldWorkHourNeed(crops,till,intens,labPeriod,labReqLevl)     "Field working hours required for operations, by soil pressure"
       p_fieldWorkingDays(labReqLevl,labPeriod,climateZone,soilType)   "Avaiable field working days for operations, by soil pressue"

       p_syntDistLab(syntFertilizer)                   "Labour need per kg N for spreading of synthetic Fertilizer"

$ifi "%parsAsVars%"=="true"         variable
       p_cropLab(crops,till,intens,m)                  "Labour requirements of crops, hours per month"

$iftheni.herd "%herd%"=="true"
       p_herdLab(sumHerds,feedRegime,m)                "Labour requirements of herds, hours per month"
     parameter
       p_herdLabStart(sumHerds,m)                      "Labour requirements of herds, hours per month, for start  of herd"
$endif.herd
$iftheni.manure "%manure%"=="true"
     parameter
       p_manDistLab(ManApplicType)                     "labour need per kg N for different manure application types"
$endif.manure

    ;
    positive variables

      v_leisureTot(t,n)                                "Total leisure"
      v_labTot(t,n)                                    "Total labour, on and off-farm, including commuting time"
      v_holidayHours(t,n,m)                            "Assumption that holiday time is taken to dampen labour peaks"

      v_labOffTot(t,n)                                 "All of farm work"
      v_labOffHourly(t,n)                              "Flexible, hourly job with meagre pay, per year"
      v_labOffFixed(t,n)                               "Work time lost for working off farm, work time and commuting time"
      v_labOffF(t,n,workType)                          "Working off-farm by worktype (full, half), fractional"

      v_labOnFarm(t,n)                                 "All farm work"
      v_labCrop(t,n)                                   "Labour in each year and SON for crops"
      v_labHerd(t,n)                                   "Labour in each year and SON for animals"
      v_labHerdM(t,n,m)                                "Labour hours in month for animals"
      v_labManag(t,n)                                  "On farm work for management"
      v_labTotM(t,n,m)                                 "Total labour, on and off-farm, including commuting time"
      v_labCropSM(t,n,m)                               "Labour in each month and SON for crops"

      v_leisureTotM(t,n,m)                             "Total leisure in each month"
      v_leisureOnFarmM(t,n,m)                          "Total leisure in each month, for family workers on farm"
      v_leisure(LeisLevL,t,n,m)                        "Leisure (= labor slack)"
      v_fieldWorkHours(plot,labReqLevl,labPerSum,t,n)  "Field working hours available for certain type of operations"

$ifi %MIP%==on   binary variables
      v_labOffB(t,n)                                   "Working off-farm or not"

*
* --- SOS1 means that nor more than one elements of a set can be 1
*     (or all zero) The set is on the last position, here worktype
*
$ifi %MIP%==on   sos1 variables
      v_labOff(t,n,workType)                           "Working off-farm by worktype (full, half), integer"

$ifi %MIP%==on   integer variables
      v_hireWorkers(t,n)                               "Hire workers, number full time, in year t"
    ;
    variables
      v_labOnFarmLost(t,n)                             "Additionally on-farm work hours lost as family member working off farm have more leisure"
      v_labManagFlex(t,n,m)                            "Flexibility in shifting management work across months"
    ;
    equations

      LabtotM_(t,n,m)                            "Labour balance per SON and month"
      Labtot_(t,n)                               "Adding up yearly labour"
      TimetotM_(t,n,m)                           "Total time restriction per month"
      TimeTot_(t,n)                              "Labour balance yearly"
      LeisureTot_(t,n)                           "Total yearly leisure"
      LeisureTotM_(t,n,m)                        "Yearly leisure in each month, adding up over leisure levels"
      LeisureTotMM_(t,n,m)                       "Yearly leisure in each month, adding up leisure of famaily members working on and off farm"
      LabHerd_(t,n)                              "Labour spent for crops"
      labHerdM_(t,n,m)                           "Labour for animals in each month"

      LabCrop_(t,n)                              "Labour spend fo herds"
      labCropSM_(t,n,m)                          "Labour in crops for each SON and month"

      hireWorkersHasFarm_(t,n)                   "Hiring workers makes sense only if there is farm"
      hireWorkersLabOffB_(t,n)                   "Hiring workers and working off farm are mutually exclusive"

      convLab_(t,n)                              "Convex combination for labour"
      convLabB_(t,n,workType)                    "SOS1 bigm"
      labOffMax_(t,n,workType)                   "Upper limit for working hours for worktype"
      labOffMin_(t,n,workType)                   "Lower limit for working hours for worktype"
      workOrder_(t,n)                            "If work off farm in t, than work off farm in t+1"
      offFarmHoursPerYearFixed_(t,n)             "Definition of total working and commuting hours off farm, half and full"
      offFarmWorkTot_(t,n)                       "Adding up of total off farm work, including working flexibly on a per hour basis"
      holidayHours_(t,n)                         "Max sum of holiday hours"
      labOnFarm_(t,n)                            "Adding up of total on farm work"
      labOnFarmLost_(t,n)                        "Additional leisure of family members workers off-farm"
      labManag_(t,n)                             "Define labour hours for management"
      labManagFlex_(t,n,m)                       "Max flexibility in management work"
      labManagFlexSum_(t,n)                      "Max flexibility in management work"

      fieldWorkHours_(plot,labReqLevl,labPerSum,t,n)        "Field working hour restriction, considers climate zone"
      labRestrFieldWorkHours_(labPerSum,labReqLevl,t,n)     "Field working hour restriction, considers # of person available"
;
*
*   --- labour use for crops, herds and biogas plant, management and off-farm, per month,
*
    labTotM_(t_n(tCur(t),nCur),m)  ..
*
*        --- sum of work in hours in current month
*
       v_LabTotM(t,nCur,m) =e=
*
*      --- labour use for crops
*
        +  v_labCropSM(t,nCur,m)
*
*      --- labour use for herds
*
$ifi %herd%==true  + v_labHerdM(t,nCur,m)
*
*      --- Management hours (for total farm and the different brenaches)
*
       + v_labManag(t,nCur)/card(m)
       + v_labManagFlex(t,nCur,m)
*
*        --- off farm labour - per month: p_workTime are weekly hours,
*            p_commTime is the commuting time in weekly hours, assumption of
*            44 weeks work in each year (binary variables)
*
       + v_labOffFixed(t,nCur)/card(m)
*
*        --- small scale work on a hourly basis (continous)
*
       + v_labOffHourly(t,nCur)/card(m)
*
*        --- totally flexible distribution of holidays
*
       - v_holidayHours(t,nCur,m)
*
*        --- labour use for biogas plant
*
$ifi %biogas%== true + sum((curBhkw(bhkw)), v_labBioGas(bhkw,t,nCur,m))
       ;
*
*   --- Yearly labour, adding up over months
*
    labTot_(t_n(tCur,nCur)) ..

        v_labTot(tCur,nCur) =E= sum(m, v_LabTotM(tCur,nCur,m)
*
*                                     --- consider holidays, otherwise, leisure is counted twice
*
                                      + v_holidayHours(tCur,nCur,m));
*
*   --- Monthly maximum labour use (peaks allowed)
*
    timeTotM_(t_n(tCur(t),nCur),m) ..

          v_LabTotM(t,nCur,m)
*
*         --- leisure of family members working on farm
*
        + v_leisureOnFarmM(t,nCur,m)

           =L=
*
*            --- part of family labour not working off farm (v_labOnFarmLost counts the hours lost from working off farm),
*                per month, plus "flexible" load from allowing uneven distribution of the work load over the year
*
             (p_yearlyLabH(t)-v_labOnFarmLost(t,nCur) $ sum(workOpps(workType), (v_labOff.up(t,nCur,workType) ne 0))
               )/365 * p_daysPerMonth(m) * (1 + %flexHoursFamily%/100)
*
*            --- plus the average montly worked load of the hired workers, wiht a flexibility of x% overtime
*
$$ifi "%allowHiring%"=="true"  + v_hireWorkers(tCur,ncur) * %workHoursHired%/card(m) * (1. + %flexHoursHired%/100)
             ;
*
*   ---- yearly labour restriction (v_labOnFarmLost is the difference between what a family member will max. work
*                                   on farm and how much is required when working off-farm)
*
    TimeTot_(t_n(tCur(t),nCur)) ..
*
*       --- total on- and off-farm labour
*
        v_labTot(t,nCur)

         =L=
*
*                         ---- max work time if all family members work on the farm
*
                          p_yearlyLabH(t)
*
*                         ---- Difference between maximal willingness to work on farm and what is required for off-farm work
*                              Assumes that family members working off-farm want more leisure
*
                          - v_labOnFarmLost(t,nCur) $ sum(workOpps(workType), (v_labOff.up(t,nCur,workType) ne 0))
*
*                         ---- labour hours of hired farm workers
*
                          $$ifi "%allowHiring%"=="true" + v_hireWorkers(tcur,nCur) * %workHoursHired%
        ;
*
*   ---- crop labour need, per year
*
    labCrop_(t_n(tCur(t),nCur))  ..

       v_labCrop(t,nCur) =e= sum( m, v_labCropSM(t,nCur,m) );

$iftheni.herd %herd%== true
*
*   ---- labour need for herds, per year
*
    labHerd_(tCur(t),nCur) $ t_n(t,nCur) ..

       v_labHerd(t,nCur) =e= sum( m, v_labHerdM(t,nCur,m));
*
*   --- labour need of herds, per month
*
    labHerdM_(tCur(t),nCur,m) $ t_n(t,nCur) ..
       v_labHerdM(t,nCur,m) =e=
*
*        --- labour for animal activities, expressed per animal and month
*            of standing herd
*
        sum(actHerds(sumHerds,breeds,feedRegime,t,m),
              v_herdSize(sumHerds,breeds,feedRegime,t,nCur,m) * p_herdLab(sumHerds,feedRegime,m))
*
*        --- labour for animal activities, per starting animal (hours for giving birth and similar)
*
      +  sum( (sumHerds,breeds) $ sum(feedRegime, actHerds(sumHerds,breeds,feedRegime,t,m)),
                v_herdStart(sumHerds,breeds,t,%nCur%,m)* p_herdLabStart(sumHerds,m))
*
*        --- fixed amount of hours for stables (maintenance, cleansing),
*            captures also labour saving effects of large stables
*
     + sum(stables $ (    sum( (t_n(t1,nCur1),hor) $ ((isNodeBefore(nCur,nCur1) or sameas(nCur,nCur1))  and (p_year(t1) le p_year(t))),
                               (v_buyStables.up(stables,hor,t1,nCur1) ne 0))
                       or sum( (tOld,hor), p_iniStables(stables,hor,tOld))),
                                (v_stableUsed(stables,t,nCur)-v_stableNotUsed(stables,t,nCur,m)) * p_stableLab(stables,m) $ (p_stableLab(stables,m) gt eps) );
$endif.herd
*
*   ---- definition of on farm work for management
*
    labManag_(t_n(tCur(t),nCur)) ..

       v_labManag(t,nCur) =e=
*
*       -- hours independent from number of branches or farm size
*
        + v_hasFarm(t,%nCur%) * p_labManag("Farm","const")
        + v_hasBranch("cap",t,%nCur%) * p_labManag("cap","const")
*
*       --- hours required for branches: block load plus
*           hours increasing in branch size
*
        + sum(branches $ sum(branches_to_acts(branches,acts), 1),
                v_hasBranch(branches,t,%nCur%)  * p_labManag(branches,"const")
             +  v_branchSize(branches,t,nCur) * p_labManag(branches,"slope"));

    labManagFlex_(t_n(tCur(t),nCur),m) ..

      v_labManag(t,nCur)/12 - v_labManagFlex(t,nCur,m) =G= (1-%managLabFlex%/100) *  v_labManag(t,nCur)/12;

    labManagFlexSum_(t_n(tCur(t),nCur)) ..

      sum(m,v_labManagFlex(t,nCur,m)) =E= 0;
*
*   ---- definition of total leisure
*
    leisureTot_(t_n(tCur(t),nCur))  ..

       v_leisureTot(t,nCur) =e= sum(m,v_leisureTotM(t,nCur,m));
*
*   ---- definition of leisure per month (leislevl stepwise convex curve,
*        where additional utility measures in Euro/hour drops with higher leisure time.
*        This helps to avoid degenerate primal solution, e.g. in which month manure is spread)
*
    leisureTotM_(t_n(tCur(t),nCur),m) ..

       v_leisureTotM(t,nCur,m) =e= sum( leisLevl, v_leisure(leisLevl,t,nCur,m));
*
*   ---- definition of total per month, considering the additional leisure
*        of family members working off-farm
*
    leisureTotMM_(t_n(tCur(t),nCur),m) ..

       v_leisureTotM(t,nCur,m) =e=
*
*                                 --- leisure hours on farm
*
                                  v_leisureOnFarmM(t,nCur,m)
*
*                                --- hours lost as family members work off-farm
*
                                 + (v_labOnFarmLost(t,nCur)/card(m)) $ sum(workOpps(workType), (v_labOff.up(t,nCur,workType) ne 0))  ;
*
*   ---- definition of on farm work (for crops, herds, management, bio-gas plant), per year
*
    labOnFarm_(t_n(tCur(t),nCur)) ..

       v_labOnFarm(t,nCur) =e=
*
*      --- labour use for crops
*
       + v_labCrop(t,nCur)
*
*      --- labour use for herds
*
$ifi %herd%==true  + v_labHerd(t,nCur)
*
*       -- labour for management of farm and branches
*
       +  v_labManag(t,nCur)
*
*       -- labour related to biogas plant
*
$ifi %biogas%== true + sum((curBhkw(bhkw),m), v_labBioGas(bhkw,t,nCur,m))
;
*
*   --- off farm work in yearly hours
*
    offFarmHoursPerYearFixed_(t_n(tCur(t),nCur)) $  sum(workOpps(workType), (v_labOff.up(t,nCur,workType) ne 0)) ..

       v_labOffFixed(t,nCur) =e=
*
*        --- off farm labour - per month: considers the work time (flexible contracts up to 40 hours a week)
*                                         plus the commuting time (3 days for contract up to 20 hours, 5 days above)

         + sum( workOpps(workType),
              v_labOffF(t,nCur,workType) + v_labOff(t,%nCur%,workType)*p_commTime(workType)*44);

*
*   --- additional leisure by farmily members working off-farm. Assumption that they will not
*       work also on the farm
*
    labOnFarmLost_(t_n(tCur(t),nCur)) $ sum(workOpps(workType), (v_labOff.up(t,nCur,workType) ne 0)) ..

       v_labOnFarmLost(t,nCur) =e=
*
*        --- Additinal leisure time of family members workers of farm. It is assumed that they do not longer
*            work on farm. WorkTimeLost is the difference between the maximal hours on farm and
*            the paid ammount of time off-farm plus the commuting time
*
         + sum( workOpps(workType),
              v_labOffF(t,nCur,workType)/(p_workTime(workType)*44) * p_workTimeLost(workType)) - v_labOffFixed(t,nCur);
*
*   --- total off farm work (binary and flexible)
*
    offFarmWorkTot_(t_n(tCur(t),nCur)) ..
*
       v_labOffTot(t,nCur) =e=
*
*         --- some hours at a very low wage rate
*
          v_labOffHourly(t,nCur)
*
*         --- contract between 20 and 40 hours a week, including commuting time
*
        + v_labOffFixed(t,nCur) $ sum(workOpps(workType), (v_labOff.up(t,nCur,workType) ne 0))

        ;

    holidayHours_(t_n(tCur(t),nCur)) ..

        sum(m, v_holidayHours(t,nCur,m)) =E=  v_labOffTot(t,nCur) * 30*8/(44*5*8 + 30*8);
*
*   --- convex combination for labour (only one type allowed), v_labOffB is a binary indicator
*
    convLab_(t_n(tCur(t),nCur)) $ sum(workOpps(workType)$ (v_labOff.up(t,nCur,workType) ne 0),1) ..

       sum(workOpps(workType), v_labOff(t,%nCur%,workType)) =E= v_labOffB(t,%nCur%);
*
*   --- farm household can decide to work more offtime in later years, but not the other way around
*       (only relevant in dynamic runs)
*
    workOrder_(tCur(t),nCur) $ ((sum(workOpps(workType) $ (v_labOff.up(t,nCur,workType) ne 0),1) $ tCur(t-1)) $ t_n(t,nCur)) ..

      sum(workOpps,  v_labOff(t,%nCur%,workOpps)*workOpps.pos)
         =G= sum((t_n(t-1,nCur1),workOpps) $ anc(nCur,nCur1), v_labOff(t-1,%nCur1%,workOpps)*workOpps.pos);
*
*   --- available field working days per half month, depending on soil type,
*       derived from tractor hours
*
    fieldWorkHours_(plot,labReqLevl,labPerSum,t_n(tCur(t),nCur)) $ (p_plotSize(plot) $ plot_landType(plot,"arab")) ..

       v_fieldWorkHours(plot,labReqLevl,labPerSum,t,nCur)

         =e=
*
       sum(labPerSum_ori(labPerSum,LabPeriod),
*
*       --- operations requiring a tractor, with the exemption top of
*           fertilizer dsitribution
*
        sum( c_p_t_i(curCrops(crops),plot,till,intens),
             v_cropHa(crops,plot,till,intens,t,%nCur%)
                 * p_fieldWorkHourNeed(crops,till,intens,labPeriod,labReqLevl)
*
*       --- distribution of synthetic fertilizer

       +   sum( (curInputs(syntFertilizer),labPeriod_to_month(labPeriod,m)),
                  v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m)
                    * p_machNeed(syntFertilizer,till,"normal","tractor","hour") ) * sameas(labReqLevl,"rf3")
           )
        );
*
*   --- field working hours, depend on average weather conditions, the soil type
*       and the required strength of the traction power required.
*
    labRestrFieldWorkHours_(labPerSum,labReqLevl,t_n(tCur(t),nCur)) ..

       sum(plot $ (p_plotSize(plot) $ plot_landType(plot,"arab")),
             v_fieldWorkHours(plot,labReqLevl,labPerSum,t,nCur))

               =L=
                sum(labPerSum_ori(labPerSum,LabPeriod),
*
*                 --- available field working days
*
                    smax((curClimateZone,soil),p_fieldWorkingDays(labReqLevl,labPeriod,curClimateZone,soil) )
*
*                 --- 12 hours a days, time # of Aks actually working on farm
*
                        * ( 12 * (%Aks% - sum(workOpps, v_labOff(t,%nCur%,workOpps) * workOpps.pos * 0.5) + v_hireWorkers(t,nCur))));
*
*   --- labour need of crops, per state of nature and month
*
    labCropSM_(t_n(tCur(t),nCur),m) ..

       v_labCropSM(t,nCur,m) =e=
*
*        --- labour need for crops, expressed per ha of land
*                                                                                +
         sum( c_p_t_i(curCrops(crops),plot,till,intens),
                v_cropHa(crops,plot,till,intens,t,%nCur%) * p_cropLab(crops,till,intens,m))


$iftheni.man %manure% == true
*
*        --- labour need for application of manure
*            (considers all field operations not out-sourced as contract work,
*             with the exemption of manure and synt fertizer application)
*
       + sum((c_p_t_i(curCrops(crops),plot,till,intens),manApplicType_manType(ManApplicType,curManType))
              $ ((v_cropHa.up(crops,plot,till,intens,t,nCur) ne 0)
              $ ( v_manDist.up(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m) ne 0)),
               v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m) * p_manDistLab(ManApplicType))
$endif.man
*
*        --- labour need for spreading synthetic fertilizer
*
       + sum((c_p_t_i(crops,plot,till,intens),curInputs(syntFertilizer)),
               v_syntDist(crops,plot,till,intens,syntFertilizer,t,nCur,m) * p_syntDistLab(syntFertilizer));
*
*   --- maximum time for a certain off-farm labour type (p_worktime is per week,
*       44 weeks per year, which reflects 30 days of holidays, bank holidays, illness)

    labOffMax_(t_n(tFull(t),nCur),workOpps(workType)) $ (v_labOff.up(t,nCur,workType) ne 0) ..

         v_labOffF(t,nCur,workType) =L= p_workTime(workType)   * 44 * v_labOff(t,%nCur%,workType);
*
*   --- minimum time for a certain off-farm labour type, must exceed the maximum of
*       the next smaller option (e.g. to work 23 hours, the option between 20 and 40 hours must be chosen)
*
    labOffMin_(t_n(tFull(t),nCur),workOpps(workType)) $ (v_labOff.up(t,nCur,workType) ne 0) ..

         v_labOffF(t,nCur,workType) =G= p_workTime(workType-1) * 44 * v_labOff(t,%nCur%,workType);

$$iftheni.hire "%allowHiring%"=="true"
*
*   -- hiring workers make sense only if there is farm
*
    hireWorkersHasFarm_(t_n(tcur,nCur)) $ (v_hireWorkers.up(tCur,nCur) ne 0) ..
       v_hireWorkers(tcur,nCur) =L= v_hasFarm(tCur,%nCur%) * v_hireWorkers.up(tCur,nCur);
*
*   --- hiring workings and working off farm are mutually exclusie
*
    hireWorkersLabOffB_(t_n(tcur,nCur)) $ (v_hireWorkers.up(tCur,nCur) ne 0) ..
       v_hireWorkers(tcur,nCur)/%maxWorkersHired% + v_labOffb(tCur,%nCur%) =L= 1;

$endif.hire

**********************************************************************************************************
*
*   Labour module model definition
*
**********************************************************************************************************

    model m_labour/

                  TimeTot_
                  leisureTot_
$$ifi not "%pmp%"=="true"  leisureTotM_
                  leisureTotMM_
                  LabtotM_
                  Labtot_
                  TimetotM_
                  labCropSM_
                  labCrop_

$iftheni.h %herd% == true
                  labHerd_
                  labHerdM_
$endif.h
                  convLab_
                  labOffMax_
                  labOffMin_
$ifi "%allowHiring%"=="true"   hireWorkersHasFarm_
$ifi "%allowHiring%"=="true"   hireWorkersLabOffB_
                  workOrder_
                  labOnFarm_
                  labOnFarmLost_
                  labManag_
                  labManagFlex_
                  labManagFlexSum_
                  offFarmWorkTot_
                  holidayHours_
                  offFarmHoursPerYearFixed_

                  fieldWorkHours_
                  labRestrFieldWorkHours_
                  /;
