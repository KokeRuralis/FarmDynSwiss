********************************************************************************
$ontext

   FARMDYN project

   GAMS file : MANURE_MODULE

   @purpose  : equations for manure storage and application for herd and biogas plant,
               including manure import

   @author   : Till Kuhn, build on revision 761
   @date     : 03.08.16
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : model/templ.gms

$offtext
********************************************************************************

   Parameter
     p_lifeTimeSi(silos)                                 "Physical lifetime of manure silos"
     p_manStorCapSi(silos)                               "Manure sotrage capacity of different silos"
     p_LimitManureImport                                 "Maximum allowed manure import in m3/ha"
     p_emissionRights                                    "Additional manure emission rights to the initial emission rights based on land endowment"
    $$ifi "%RestrictedNInput%" == "true" p_NInOutratio    "Max. N-input output ratio when exchanging N with external biogas plant"
    $$ifi "%RestrictedNInputQuant%" == "true" p_MaxNImport "Max. Netto N-input (Netto: N in addition to biomass/fermentation substrate exchange)"
    $$ifi "%AllowBiogasExchange%"  == "true"  p_DistBiogas "Transport distance to biogasplant"
    $$ifi defined herds p_manQuantMonthStable(herds,manChain,stableStyles)  "Share of solid/light liquid manure"

   ;

   Positive Variables

      v_buySilosF(manChain,silos,t,n)                                 "Investments in new manure silos in year t (share)"

$iftheni.ms %manureStorage% == true

      v_SiloInv(manChain,silos,t,n)                                   "silo inventory for manure storage in t"
      v_volInStorageType(manChain,manStorage,t,n,m)                   "amount of manure in each storage type in a month in m3"
      v_SiloManStorCap(manChain,t,n)                                  "manure storage capacity in silo systems in m^3"
      v_ManStorCapNeed(manChain,t,n)                                  "Total manure storage Capacity needed"
      v_TotalManStorCap(manChain,t,n)                                 "Whole farm manure storage capacity in m^3"
      v_SubManStorCap(manChain,t,n)                                   "Storage under floor in stables"
      v_volInStorage(manChain,t,n,m)                                  "Manure in m^3 in storage in each month"
      v_nutPoolInStorage(manChain,nut2,t,n,m)                         "NTAN,NORG and P in storage per month"

      v_manExport(manChain,manType,t,n,m)                             "Amount of manure exported from farm (m3)"
      v_nut2Export(manChain,nut2,t,n,m)                               "Amount of nutrient exported from farm (NTAN,NORG,P)"
      v_nut2ExportMER(manChain,nut2,t,n,m)                            "Nutrient export through manure exported via manure emission rights (MER)"
      v_manExportMER(manChain,manType,t,n,m)                          "Manure exported via manure emission rights (MER)"

    $$iftheni.b %biogas% == true
      v_nut2ManurePurch(manchain,nut2,maM,t,n,m)                      "Nutrient introduced into the farm via purchased manure"
      v_nutCropBiogasM(manchain,nut2,t,n,m)                           "Nutrients introduced into the farm via purchased crops"
      v_volDigCrop(biogasfeedM,t,n,m)                                 "Volume of crop based digestate in m^3"
      v_volDigMan(t,n,m)                                              "Volume of manure based digestate in m^3"
      v_siloBiogasstorCap(t,n)                                        "Additional silo volume added via investment in biogas plant"
    $$endif.b

      v_nutLossInStorage(manChain,nut2,t,n,m)                         "NTAN,NORG and P in storage per month"
      v_SiCovComb(manChain,Silos,t,n,manStorage)                      "Possible combinations of silo types and coverage techniques"

    $$ifi %MIP%==on   binary variables
      v_buySilos(manChain,silos,t,n)                                  "Choice of investments in new manure silos in year t"

    $$ifi %MIP%==on   SOS2 variables
      v_buySilosSOS2(manChain,t,n,silos)                               "Choice of investments in new manure silos in year t"
$endif.ms
    $$iftheni.im "%AllowManureImport%" == "true"
      v_manImport(manimports,t,n,m)                                   "Imported manure in qm"
      v_nut2Import(nut2,t,n,m)                                        "Amount of nutrient imported to the farm (NTAN,NORG,P)"
    $$endif.im
    $$iftheni.bioex "%AllowBiogasExchange%" == "true"
      v_expBiomass(prods,t,n)                                         "Biomass exported to external biogas plant"
      v_nutExport(nut,t,n)                                            "Amount of nutrient exported to external biogas plant (N,P)"
      v_netImportManure(ManImports,t,n)                               "Netto import of biomass manure"
    $$endif.bioex


;

   Equations

$iftheni.ms %manureStorage% == true

      siloConcaveComb_(manChain,silos,t,n)                 "Select to silo sizes as points on concave set next to each other"
      siloBin_(manChain,silos,t,n)                         "Restrict choice fo convex combination to points from concave combination"
      siloConvexComb_(manChain,t,n)                        "Convex combinations: shares must add up to unity"
      buySilosSOS2_(manChain,t,n,silos)                     "Choice of investments in new manure silos in year t"
      convSilos_(manChain,t,n)                             "Convex combinations: shares must add up to unity"
      siloInv_(manChain,silos,t,n)                         "Silo inventory definition"
      SiloManStorCap_(manChain,t,n)                        "manure storage capacity of outdoor silos in m^3"
      siloCoverManStore_(manChain,manStorage,t,n,m)        "defines combination of coverage type and silo size"
      siloCoverInv_(manChain,silos,t,n)                    "ensures, that one silo only has one coverage"
      manStorCapGVDepend_(manChain,t,n)                    "Restrictions that farms have to hold 9 month manure storage capacity when > 3 LU/ha"
      TotalManStorCap_(manChain,t,n)                       "Overall storage capacity for manure in m^3"
      manStorCapNeed_(manChain,t,n)                        "Total manure storage capacity needed"
      manStorCap_(manChain,t,n)                            "Restriction that Manure Storage Capacity is >= the Need"
      manStorCapMonth_(manChain,t,n,m)                     "Restriction for maximal storage amount of manure volume in m^3"
      volInStorage_(manChain,t,n,m)                        "Volume of manure in storage"
      storageDistr_(manChain,t,n,m)                        "defines nutrient amounts in manure in each type of storage"
      maxManVolStorLastMonth_(manChain,t,n,m)              "Volume in last month of simulation is not allowed to be higher tahn 4/12 of last year"
      maxManNutStorLastMonth_(manChain,nut2,t,n,m)         "Nutrients in last month of simulation is not allowed to be higher tahn 4/12 of last year"
      emptyStorageVol_(manChain,t,n,m)                     "Requires the volume in storage to be emptied every may"
      emptyStorageNut_(manChain,nut2,t,n,m)                "Requires the nutrients in storage to be emptied every may"
      nutPoolInStorage_(manChain,nut2,t,n,m)               "NTAN-,NORG- and P-Pool in storage"
      nutLossInStorage_(manChain,nut2,t,n,m)               "NTAN-,NORG- and P-Pool in storage"

      nut2export_(manChain,nut2,t,n,m)                     "Amount of manure exported from farm (m3)"
      nut2ExportMER_(manChain,nut2,t,n,m)                  "Amount of manure exported from farm via manure emission rights"
      manExportMER_(t,n)                                   "Give the amount of additonal manure emission rights (MER)"

$endif.ms

$iftheni.im "%AllowManureImport%" == "true"
      ManureImport_(manImports,t,n,m)                      "Application of imported manure"
      nut2import_(nut2,t,n,m)                              "Imported nutrients"
$$ifi "%AllowManureExport%" == "false"  nutImportLimit_(t,n)
$endif.im

$iftheni.bioex "%AllowBiogasExchange%" == "true"
       biomassExport_(prods,t,n)                                "Biomass exported to external biogas plant"
       nutExport_(nut,t,n)                                      "Nutrients exported to external biogas plant"
       netImportManure_(ManImports,t,n)                         "Netto biogas-manure import (import minus biomass export)"
$$ifi "%RestrictedNInput%"      == "true" nut2importRatio_(t,n) "Quanity of N imported restricted by amount exported to external biogas plant"
$$ifi "%RestrictedNinputquant%" == "true" nut2importLimit_(t,n) "Max netto N-input restricted when importing manure (Netto: N in addition to biomass/fermentation substrate exchange)"
$endif.bioex

p_NTotPlant
      volManApplied_(manChain,t,n,m)                       "m^3 manure applicated in month m"
      nut2ManApplied_(crops,manChain,nut2,t,n,m)           "NTAN,NORG and P applied with manure"
   ;

************************************************************************************************************************************
*
*   ---- Equations related to manure storage, switched on if herds or biogas are present
*
************************************************************************************************************************************

$iftheni.ms %manureStorage% == true
*
*   -- exclude buying of not neighbouring silo types (only two points on concave set next to each other)
*
    siloConcaveComb_(curManChain(manChain),silos,t_n(tCur,nCur)) $ (v_buySilos.up(manChain,silos,tCur,nCur) ne 0) ..
        sum(silos1 $ (abs(silos1.pos - silos.pos) gt 1), v_buySilos(manChain,silos1,tCur,%nCur%))
           =L= (1 - v_buySilos(manChain,silos,tCur,%nCur%))*2;
*
*   --- restrict choice for convex combination to the two points defined above
*
    siloBin_(curManChain(manChain),silos,t_n(tCur,nCur)) $ sum(silos1,(v_buySilos.up(manChain,silos1,tCur,nCur) ne 0)) ..

         v_buySilosF(manChain,silos,tCur,nCur) =L= v_buySilos(manChain,silos,tCur,%nCur%);
*
*   --- Convex combination: the shares of the two points on the concave set must add up to unity
*
    siloConvexComb_(curManChain(manChain),t_n(tCur,nCur)) $ sum(silos,(v_buySilos.up(manChain,silos,tCur,nCur) ne 0))..

         sum(silos, v_buySilosF(manChain,silos,tCur,%nCur%)) =E= 1;

    convSilos_(curManChain(manChain),t_n(tCur,nCur)) $ sum(silos,(v_buySilosF.up(manChain,silos,tCur,nCur) ne 0))..

       sum(silos, v_buySilos(manChain,silos,tCur,%nCur%)) =E= 2;

    buySilosSOS2_(curManChain(manChain),t_n(tCur,nCur),silos) $ (v_buySilosF.up(manChain,silos,tCur,nCur) ne 0) ..

       v_buySilosSOS2(manChain,tCur,%nCur%,silos) =E= v_buySilos(manChain,silos,tCur,%nCur%);
*
*   --- Manure silo inventory (not binary), (deprecitation over time)
*
    siloInv_(curManChain(manChain),silos,tCur(t),nCur)
          $ (  (p_ManStorCapSi(silos) gt eps)
               $(   sum(t_n(t1,nCur1) $ isNodeBefore(nCur,nCur1), (v_buySilos.up(manChain,silos,t1,nCur1) ne 0))
               or sum(tOld, p_iniSilos(manChain,silos,tOld))) $ t_n(t,nCur) ) ..

       v_siloInv(manChain,silos,t,nCur)

            =L=
*
*         --- Old silo according to building date and lifetime
*             (will drop out of equation if too old)
*
           sum(tOld $ (   ((p_year(tOld) + p_lifeTimeSi(silos)) gt p_year(t))
                        $ ( p_year(told)                        le p_year(t))),
                           p_iniSilos(manChain,silos,tOld))

*
*         --- Plus (old) investments - de-investments
*
           +  sum(t_n(t1,nCur1) $ (tcur(t1) $ isNodeBefore(nCur,nCur1)
                                 and (   ((p_year(t1)  + p_lifeTimeSi(silos)) gt p_year(t))
                                       $ ( p_year(t1)                         le p_year(t)))),
                                           v_buysilosF(manChain,silos,t1,nCur1));
*
*   --- Declaration that the model knows what coverage type is on the manure silos
*
    siloCoverInv_(curManChain(manChain),silos,tCur(t),nCur)
       $ ( (    sum(t_n(t1,nCur1) $ isNodeBefore(nCur,nCur1), (v_buySilos.up(manChain,silos,t1,nCur1) ne 0))
             or sum(tOld, p_iniSilos(manChain,silos,tOld))) $ t_n(t,nCur)) ..

       v_siloInv(manChain,silos,t,nCur) =e=  sum(siloCover, v_siCovComb(manChain,silos,t,nCur,siloCover));

*
*   --- Coverage type cannot exceed silo capacity in m�
*
    siloCoverManStore_(curManChain(manChain),manStorage,tCur(t),nCur,m) $ t_n(t,nCur) ..

       v_volInStorageType(manChain,manStorage,t,nCur,m) =L=

                          sum(silos $ (   sum(t_n(t1,nCur1) $ isNodeBefore(nCur,nCur1),
                                                (v_buySilos.up(manChain,silos,t1,nCur1) ne 0))
                                       or (sum(tOld, p_iniSilos(manChain,silos,tOld)))),
                                  (v_siCovComb(manChain,silos,t,nCur,manStorage) $ (not sameas(manStorage,"storSub")))
                                         * p_ManStorCapSi(silos))

                           +  sum( manStorage_siloFloor(ManStorage,"storSub"),
                                    v_SubManStorCap(manChain,t,nCur) $(not sameas ("LiquidBiogas",manchain)))
      ;
*
*   --- Storage capacity for manure in outdoor silo systems
*
    siloManStorCap_(curManChain(manChain),tCur(t),nCur) $ t_n(t,nCur) ..

       v_SiloManStorCap(manChain,t,nCur)

          =e= sum(silos $ (    sum(t_n(t1,nCur1) $ isNodeBefore(nCur,nCur1), (v_buySilos.up(manChain,silos,t1,nCur1) ne 0))
                            or sum(tOld, p_iniSilos(manChain,silos,tOld))),
                               v_SiloInv(manChain,silos,t,nCur) * p_ManStorCapSi(silos))    ;
*
*   --- Total manure storage capacity of overall farm in m^3
*
    totalManStorCap_(curManChain(manChain),tCur(T),nCur) $ t_n(t,nCur) ..

       v_TotalManStorCap(manChain,t,nCur) =e=

$iftheni.herd %herd%  == true
                              v_SubManStorCap(manChain,t,nCur)  $ (not sameas ("LiquidBiogas",manchain))
                            + v_SiloManStorCap(manChain,t,nCur) $ (not sameas ("LiquidBiogas",manchain))
$endif.herd
$ifi %biogas% == true       + v_siloBiogasStorCap(t,nCur) $ sameas ("LiquidBiogas",manchain)
    ;

*  --- Manure storage capacity must cover at least 50% of annual manure quantity excreted following: JGA AnlagenVO

   manStorCapNeed_(curManChain(manChain),tCur(t),nCur) $ (t_n(t,nCur) $ p_ManureStorageNeed)   ..

          v_ManStorCapNeed(manChain,t,nCur)

            =e=  p_ManureStorageNeed   * (


    $$ifi %herd% == true      v_manQuant(manChain,t,nCur) $ (not sameas (manchain, "LiquidBiogas"))

*  --- required silo storage capacity for biogas plant digestate (including energy crops and purchased manure)

    $$ifi %biogas% == true    + sum((crM(biogasfeedM),m), v_voldigCrop(crM,t,nCur,m) + v_volDigMan(t,nCur,m)) $ sameas ("LiquidBiogas",manchain)

                                    );
*
*   --- Total manure storage capacity has to be greater than required storage capactiy ManStorCapNeed(t)
*
    manStorCap_(curManChain(manChain),t_n(tCur(t),nCur)) ..

       v_TotalManStorCap(manChain,t,nCur) =g= v_ManStorCapNeed(manChain,t,nCur);
*
*   --- Volume in storage per month restricted by availabilty capacity
*
    manStorCapMonth_(curManChain(manChain),t_n(tCur(t),nCur),m) ..

       v_volInStorage(manChain,t,nCur,m) =l= v_totalManStorCap(manChain,t,nCur);
*
*   --- Defines how manure amount is distributed to the single storage types
*
    storageDistr_(curManChain(manChain),t_n(tCur(t),nCur),m) ..

       v_volInStorage(manChain,t,nCur,m) =e=

              sum (manStorage,v_volInStorageType(manChain,ManStorage,t,nCur,m)) ;
*
*   --- Defines manure amount in m3 per month in each storage type
*
    volInStorage_(curManChain(manChain),tCur(t),nCur,m) $ ( t_n(t,nCur)$ ( not sameas (manchain,"LiquidImport"))  ) ..

       v_volInStorage(manChain,t,nCur,m) =e= [sum(t_n(t-1,nCur1) $ anc(nCur,nCur1),
                                  v_volInStorage(manChain,t-1,nCur1,"Dec")) $ (sameas(m,"Jan") $ tCur(t-1))
                                + v_volInStorage(manChain,t,nCur,m-1)     $ (not sameas(m,"Jan"))]


* ---- in comparative static setting, manure in Jan includes manure from Dec, assuming steady flow

                   $$iftheni.cs "%dynamics%" == "comparative-static"
                                + v_volInStorage(manChain,t,nCur,"Dec")     $ sameas(m,"Jan")
                   $$endif.cs


                   $$iftheni.herd %herd% == true
*
*                               --- m3 excreted per year divied by # of month: monthly inflow
*
                                + v_manQuantM(manChain,t,nCur,m) $ (not sameas(manchain,"LiquidBiogas"))
                   $$endif.herd

*                               --- m3 coming from biogas plant s energy crops and purchased manure
                   $$iftheni.b %biogas% == true

*                               --- Diogas digestate based on energy crops

                                +  sum(crm(biogasfeedM), v_volDigCrop(crM,t,nCur,m)) $ sameas(manchain,"LiquidBiogas")

*                               --- Biogas digestate based on manure

                                +  v_volDigMan(t,nCur,m) $ sameas(manchain,"LiquidBiogas")
                   $$endif.b
*
*                               --- m3 taken out of storage type for application to crops
*
                                - v_volManApplied(manChain,t,nCur,m)

                   $$iftheni.ExMan "%AllowManureExport%"=="true"

*                               --- m3 exported from farm

                                - sum (manChain_Type(manChain,curManType), v_manExport(manChain,curManType,t,nCur,m))
                   $$endif.ExMan

                   $$iftheni.emissionRight not "%emissionRight%"==0
*                               --- m3 exported through manure emission rights

                                - sum (manChain_Type(manChain,curManType), v_manExportMER(manChain,curManType,t,nCur,m))
                   $$endif.emissionRight
                             ;
*
* --- NTAN, NORG and P in storage
*

     nutPoolInStorage_(curManChain(manChain),nut2,tCur(t),nCur,m) $ ( t_n(t,nCur)$ ( not sameas (manchain,"LiquidImport"))  ) ..

            v_nutPoolInStorage(manChain,nut2,t,nCur,m)

              =e=  [sum(t_n(t-1,nCur1) $ anc(nCur,nCur1),
                          v_nutPoolInStorage(manChain,nut2,t-1,nCur1,"Dec")) $ (sameas(m,"Jan") $ tCur(t-1))
                        + v_nutPoolInStorage(manChain,nut2,t,nCur,m-1)       $ (not sameas(m,"Jan"))]


* ---- in comparative static setting, nutrient pool in Jan includes nutrient pool from Dec, assuming steady flow

              $$iftheni.cs "%dynamics%" == "comparative-static"

                   + v_nutPoolInStorage(manChain,nut2,t,nCur,"Dec")       $ sameas(m,"Jan")

               $$endif.cs

               $$iftheni.herd %herd% == true

                 + v_nut2ManureM(manChain,nut2,t,nCur,m) $ (not sameas(manchain,"LiquidBiogas"))

               $$endif.herd

               $$iftheni.biogas %biogas% == true

                 +  sum( (curBhkw(bhkw),curEeg(eeg),curmaM),   v_nut2ManurePurch("LiquidBiogas",nut2,curmaM,t,nCur,m)  ) $ sameas(manchain,"LiquidBiogas")

                 +  v_nutCropBiogasM("LiquidBiogas",nut2,t,nCur,m) $ sameas(manchain,"LiquidBiogas")

               $$endif.biogas

*               --- storage losses

                - v_nutLossInStorage(manChain,nut2,t,nCur,m)

*               --- Nutrients applied

                 - sum(curCrops, v_nut2ManApplied(curCrops,manChain,nut2,t,nCur,m))

*               --- Nutrients exported from farm

               $$iftheni.ExMan "%AllowManureExport%"=="true"

                 - v_nut2export(manChain,nut2,t,nCur,m)

               $$endif.ExMan

               $$iftheni.emissionRight not "%emissionRight%"==0

*               --- Nutrient exported via manure emission rights

                -  v_nut2ExportMER(manChain,nut2,t,nCur,m)

                $$endif.emissionRight
 ;
*
* --- Calculation of nutrient losses from storage, when environmental impact accounting is switched on
*
    nutLossInStorage_(curManChain(manChain),nut2,tCur(t),nCur,m) $ t_n(t,nCur)  ..

       v_nutLossInStorage(manChain,nut2,t,nCur,m) =E=

*             --- NH3 losses in stable and storage, only related to N TAN

            $$iftheni.herd %herd% == true
              [
                   + v_nut2ManureM(manChain,"NTAN",t,nCur,m) * (p_EFSta("NH3",manChain) + p_EFSto("NH3",manChain) ) $ sameas(nut2,"NTAN")

*             --- N2O, N2 and NO losses in stable and storage, related to NTAN and Norg

                   + v_nut2ManureM(manChain,"NTAN",t,nCur,m)
                    * ( p_EFStaSto("N2O",curManChain) + p_EFStaSto("NOx",curManChain) + p_EFStaSto("N2",curManChain) ) $ sameas(nut2,"NTAN")

                   + v_nut2ManureM(manChain,"NOrg",t,nCur,m)
                    * ( p_EFStaSto("N2O",curManChain) + p_EFStaSto("NOx",curManChain) + p_EFStaSto("N2",curManChain) ) $ sameas(nut2,"NOrg")

               ] $ (not sameas(manchain,"LiquidBiogas"))
            $$endif.herd

*             --- N2O, N2 and NO losses from storage from digestate, related to NTAN and Norg

            $$iftheni.biogas %biogas% == true

             + {
                     [ ( v_nutCropBiogasM(manchain,"NTAN",t,nCur,m)
                          + sum (curmaM(mam), v_nut2ManurePurch(manchain,"NTAN",curmaM,t,nCur,m)  ) )

                           *  (p_EFStaSto("N2O",curManChain) + p_EFStaSto("NOx",curManChain) + p_EFStaSto("N2",curManChain))

                      ]  $ sameas(nut2,"NTAN")

                   + [ ( v_nutCropBiogasM(manchain,"NOrg",t,nCur,m)   + sum (curmaM(mam), v_nut2ManurePurch(manchain,"NOrg",curmaM, t,nCur,m) ) )
                            *( p_EFStaSto("N2O",curManChain)   + p_EFStaSto("NOx",curManChain)  + p_EFStaSto("N2",curManChain))
                      ]  $ sameas(nut2,"NOrg")

               } $ sameas(manchain,"LiquidBiogas")

           $$endif.biogas
        ;

*
*  --- Specific equations for last year: not more than 4/12 of total excreted manure
*       in last year in storage. Currently only for dairy herd, as the ratios for nutritions
*       forbid the appropriate emptying of the manure storage
*

   maxManVolStorLastMonth_(curManChain(manChain),t_n("%lastYear%",nCur),"Dec")  ..

                        (

$ifi %herd% == true         v_manQuant(manChain,"%lastYearCalc%",nCur)$ (not sameas(manchain,"LiquidBiogas"))

$ifi %biogas% == true     + sum((crm(biogasFeedM),m), v_voldigCrop(crM,"%lastYearCalc%",nCur,m)+ v_volDigMan("%lastYearCalc%",nCur,m) ) $ sameas(manchain,"LiquidBiogas")

                         ) * 8/12

                       =G=  v_volInStorage(manChain,"%lastYear%",nCur,"Dec");


    maxManNutStorLastMonth_(curManChain(manChain),nut2,"%lastYear%",nCur,"Dec") $ t_n("%lastYear%",nCur) ..

                       (

$ifi %herd% ==true          sum(m, v_nut2ManureM(manChain,nut2,"%lastYear%",nCur,m) $ (not sameas(manchain,"LiquidBiogas")))

                         $$iftheni.biogas %biogas% == true

                          + sum((curmaM,m), v_nut2ManurePurch(manchain,nut2,curmaM,"%lastYear%",nCur,m) ) $ sameas(manchain,"LiquidBiogas")

                          + sum(m, v_nutCropBiogasM("LiquidBiogas",nut2,"%lastYear%",nCur,m))             $ sameas(manchain,"LiquidBiogas")

                         $$endif.biogas

                       ) * 8/12

                      =G=  v_nutPoolInStorage(manChain,nut2,"%lastYear%",nCur,"Dec");



$iftheni.app "%forceRegularManureAppl%" == "off"
*
*   --- Each year in may the manure storage has to be emptied
*
    emptyStorageVol_(curManChain(manChain),t_n(tCur(t),nCur),m) $ sameas(m,"apr") ..

             v_volInStorage(manChain,t,nCur,m) =L= 0;

    emptyStorageNut_(curManChain(manChain),nut2,t_n(tCur(t),nCur),m) $ sameas(m,"apr") ..

            v_nutPoolInStorage(manChain,nut2,t,nCur,m) =L= 0;

$elseif.app "%forceRegularManureAppl%" == "Monthly"

*   --- Storage has to be emtied monthly, except for Nov, Dec, Jan

    emptyStorageVol_(curManChain(manChain),t_n(tCur(t),nCur),m) $ (not (sameas(m,"Nov") or sameas(m,"Dec") or sameas(m,"Jan")))..

             v_volInStorage(manChain,t,nCur,m) =E= 0 ;

    emptyStorageNut_(curManChain(manChain),nut2,t_n(tCur(t),nCur),m) $ (not (sameas(m,"Nov") or sameas(m,"Dec") or sameas(m,"Jan")))..

            v_nutPoolInStorage(manChain,nut2,t,nCur,m) =E= 0;

$elseif.app "%forceRegularManureAppl%" == halfyear

*   --- Storage has to be emtied every 6 month, in between application is not possible

    emptyStorageVol_(curManChain(manChain),t_n(tCur(t),nCur),m)  $ ( sameas(m,"Apr") or sameas (m,"Oct") )..

             v_volInStorage(manChain,t,nCur,m) =E= 0 ;

  emptyStorageNut_(curManChain(manChain),nut2,t_n(tCur(t),nCur),m) $ ( sameas(m,"Apr") or sameas (m,"Oct") )..

            v_nutPoolInStorage(manChain,nut2,t,nCur,m) =E= 0;

  v_manDist.up(crops,plot,till,intens,manApplicType,manType,tCur(t),nCur,m) $ ((not sameas (m,"Apr") and not sameas (m,"Oct")) $ t_n(t,Ncur)) = 0   ;

$else.app

* --- Storage has to be emtied yearly, in between application is not possible

       emptyStorageVol_(curManChain(manChain),t_n(tCur(t),nCur),m)  $ sameas(m,"Apr") ..

             v_volInStorage(manChain,t,nCur,m) =E= 0 ;


       emptyStorageNut_(curManChain(manChain),nut2,t_n(tCur(t),nCur),m) $ sameas(m,"Apr") ..

            v_nutPoolInStorage(manChain,nut2,t,nCur,m) =E= 0 ;


       v_manDist.up(crops,plot,till,intens,manApplicType,manType,tCur(t),nCur,m)  $ ((not sameas (m,"Apr")) $ t_n(t,Ncur))  = 0   ;

$endif.app
*
*  --- Calculation of exportend nutrients (Norg, NTAN, P)
*
   nut2export_(curManChain(manChain),nut2,t_n(tCur(t),nCur),m)  ..

        v_nut2export(manChain,nut2,t,nCur,m) =e=
              sum (manChain_Type(manChain,curManType),
                    v_manExport(manChain,curManType,t,nCur,m) *  p_nut2inMan(nut2,curManType,manChain) ) ;
*
*  --- Nutrient export throught additional manure emission rights (MER)
*
   manExportMER_(t_n(tCur(t),nCur)) ..

      sum((manChain_Type(manChain,curManType),m),
                  v_manExportMER(manChain,curManType,t,nCur,m)) =L= p_emissionRights ;

   nut2ExportMER_(curManChain(manChain),nut2,t_n(tCur(t),nCur),m) ..

      v_nut2ExportMER(manChain,nut2,t,nCur,m)
            =E= sum(manChain_type(manChain,curManType),
                      v_manExportMER(manChain,curManType,t,nCur,m) * p_nut2inMan(nut2,curManType,manChain) ) ;
$endif.ms

************************************************************************************************************************************
*
*   ---- Equations related to manure import, switched on if manure import is allowed (also without herd)
*
************************************************************************************************************************************

   $$iftheni.im "%AllowManureImport%" == "true"

*
*   --- Manure imported to the farm (direct applicaton, no storage)
*
    ManureImport_(manImports,t_n(tCur(t),nCur),m) ..

        sum( (c_p_t_i(curCrops(crops),plot,till,intens),
                            manChain_applic(manChain,ManApplicType))
                                $ (manApplicType_manType(ManApplicType,manImports)
                                     $ (v_manDist.up(crops,plot,till,intens,manApplicType,manImports,t,nCur,m) ne 0)
                                          $ (not sameas (curCrops,"catchcrop")) ),
                                               v_manDist(crops,plot,till,intens,ManApplicType,manImports,t,nCur,m) )

                                                    =E=   v_manImport(manImports,t,nCur,m)         ;
*
*   --- Nutrients imported to the farm
*
    nut2import_(nut2,t_n(tCur(t),nCur),m) ..

        v_nut2import(nut2,t,nCur,m) =e=  sum(manImports, v_manImport(manImports,t,nCur,m) *  p_nut2inMan(nut2,manImports,"LiquidImport"))   ;

*
*   --- Equation to limit the import of manure to value defined by GUI in m3
*
   $$iftheni.lim "%AllowBiogasExchange%" == "false"
    nutImportLimit_(t_n(tCur(t),nCur)) ..

        sum ((manImports,m), v_manImport(manImports,t,nCur,m)) =L= p_LimitManureImport * sum ( c_p_t_i(curCrops(crops),plot,till,intens)
                                                       $ (  (not sameas (curCrops,"idle")) $  (not catchCrops(crops))) ,
                                                           v_cropHa(curCrops,plot,till,intens,t,%nCur%) )    ;

   $$endif.lim
   $$endif.im

************************************************************************************************************************************
*
*   ---- Equations related to nutrient exchange with external biogas plant, switched on if manure import and biogas exchange is allowed (also without herd)
*
************************************************************************************************************************************
  $$iftheni.bioex "%AllowBiogasExchange%" == "true"

*
*  --- Biomass export  needs to be lower than overall production, considering post harvest losses
*

biomassExport_(biogas_exchange,t_n(tCur(t),nCur)) ..
        v_expBiomass(biogas_exchange,t,nCur)
        $sum(c_p_t_i(curCrops,plot,till,intens), sameas(curcrops,biogas_exchange))
        =l=
         sum( (c_p_t_i(curCrops,plot,till,intens))  ,
*export of harvest
                (v_cropHa(curCrops,plot,till,intens,t,nCur) $ sameas(curCrops,biogas_exchange)
                    * sum( (plot_soil(plot,soil)) $  p_OCoeffC%l%(curCrops,soil,till,intens,biogas_exchange,t),
                                                p_OCoeffC(curCrops,soil,till,intens,biogas_exchange,t)/p_storageLoss(curCrops))
                                            )
*export of crop residues (straw)
              +
              sum(prodsResidues,
              (v_residuesRemoval(curCrops,plot,till,intens,t,nCur) $ sum(sameas(curCrops,cropsResidueRemo),1)
                  * sum( (plot_soil(plot,soil)),
                                              p_OCoeffResidues(curCrops,soil,till,intens,prodsResidues,t)/p_storageLoss(curCrops))
                                          ))
                                          )  ;


*
* --- Nutrients exported to external biogas plant,  Crop output (p_nutContent is per 100 kg, output coefficients are in tons)
*
   nutExport_(nut,t_n(tCur(t),nCur)) ..
      v_nutExport(nut,t,nCur)
      =e=
      sum((c_p_t_i(curCrops,plot,till,intens),biogas_exchange),
      v_expBiomass(biogas_exchange,t,nCur)
      * (  p_nutContent(curCrops,biogas_exchange,"conv",nut) $ (not sameas(till,"org"))
         + p_nutContent(curCrops,biogas_exchange,"org",nut)  $      sameas(till,"org")) * 10);

*
* --- netto quantity of manure imported from external biogas plant (in addition to nutrient exchanges)
*
   netImportManure_(ManImports,t_n(tCur(t),nCur)) ..
   v_netImportManure(ManImports,t,nCur) =e= (sum((m,nut2)$ (not sameas(nut2,"P")), v_nut2import(nut2,t,nCur,m)) - v_nutExport("N",t,nCur))
                                                  / sum(nut2 $ (not sameas(nut2,"P")), p_nut2inMan(nut2,ManImports,"LiquidImport")) ;


*
* --- Maximum netto N-input restricted when importing manure (Netto: N in addition to nutrient exchange)
*
   $$iftheni.NQuant "%RestrictedNInputQuant%" == "true"

    nut2importLimit_(t_n(tCur(t),nCur)) ..
     sum((nut2,m), v_nut2import(nut2,t,nCur,m) $ (not sameas(nut2,"P"))) - v_nutExport("N",t,nCur) =l=
                p_MaxNImport * sum( (landType,soil), v_croppedLand(landType,soil,tCur,nCur));

   $$endif.NQuant
*
*   --- Quanity of N imported restricted by amount exported to external biogas plant (Ratio setected in GUI)
*

  $$iftheni.im "%RestrictedNInput%" == "true"

  nut2importRatio_(t_n(tCur(t),nCur)) ..
  sum((nut2,m), v_nut2import(nut2,t,nCur,m) $ (not sameas(nut2,"P"))) =l=
  p_NInOutratio * v_nutExport("N",t,nCur);

  $$endif.im
$$endif.bioex



************************************************************************************************************************************
*
*   ---- Equations related to manure application, always included if manure is swichted on
*
************************************************************************************************************************************

*
*  --- Manure application in m3  to crops
*
   volManApplied_(curManChain(manChain),t_n(tCur(t),nCur),m) $ (v_volManApplied.up(manChain,t,nCur,m) ne 0) ..

       v_volManApplied(manChain,t,nCur,m)
         =e= sum( (c_p_t_i(curCrops(crops),plot,till,intens),
                     manChain_applic(manChain,ManApplicType),curManType)
                                           $ (manApplicType_manType(ManApplicType,curManType)
                                           $ (v_manDist.up(crops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0)
                                           $ (not sameas (curCrops,"catchcrop")) ),
                     v_manDist(crops,plot,till,intens,ManApplicType,curManType,t,nCur,m));
*
*  --- Manure application in nutrients
*
   nut2ManApplied_(curCrops,curManChain(manChain),nut2,t_n(tCur(t),nCur),m) $ (v_volManApplied.up(manChain,t,nCur,m) ne 0) ..

       v_nut2ManApplied(curCrops,manChain,nut2,t,nCur,m) =e=
                                  sum( (plot,till,intens,manChain_applic(manChain,ManApplicType),curManType)
                                          $ (manApplicType_manType(ManApplicType,curManType)
                                          $ (v_manDist.up(curCrops,plot,till,intens,manApplicType,curManType,t,nCur,m) ne 0)
                                          $ (not sameas (curCrops,"catchcrop")) $c_p_t_i(curCrops,plot,till,intens)),

                                         v_manDist(curCrops,plot,till,intens,ManApplicType,curManType,t,nCur,m)
                                                  * p_nut2inMan(nut2,curManType,manChain));

    $$ifi "%dynamics%" == "short run"          $setglobal horizon short
    $$ifi "%dynamics%" == "comparative-static" $setglobal horizon long


 model m_manure /

$iftheni.ms %manureStorage% == true

    $$iftheni.herd %herd% == true
       siloBin_
       siloConvexComb_
       convSilos_

       $$ifi "%useSOS2%"=="true"  buySilosSOS2_
       $$ifi not "%useSOS2%"=="true" siloConcaveComb_
       siloInv_
       siloCoverInv_
       SiloManStorCap_
       storageDistr_
       siloCoverManStore_
    $$endif.herd


       TotalManStorCap_
       ManStorCapNeed_
       manStorCap_
       manStorCapMonth_
       volInStorage_
       nutLossInStorage_
       nutPoolInStorage_
       maxManVolStorLastMonth_
       maxManNutStorLastMonth_

    $$iftheni.ExMan %AllowManureExport%==true
       nut2export_
    $$endif.ExMan

    $$iftheni.emissionRight not "%emissionRight%"==0
       nut2ExportMER_
       manExportMER_
    $$endif.emissionRight

    $$iftheni.horizon   not "%horizon%" == "short"
       emptyStorageVol_
       emptyStorageNut_
    $$endif.horizon

$endif.ms

$iftheni.im "%AllowManureImport%" == "true"
      ManureImport_
      nut2import_
$$ifi "%AllowBiogasExchange%" == "false"   nutImportLimit_
$endif.im
$iftheni.bioex  "%AllowBiogasExchange%" == "true"
     biomassExport_
     nutExport_
     netImportManure_
$$ifi "%RestrictedNInputQuant%" == "true"    nut2importLimit_
$$ifi "%RestrictedNInput%"    == "true" nut2importRatio_
$endif.bioex
      nut2ManApplied_
      volManApplied_

 /;
