********************************************************************************
$ontext

   FarmDyn project

   GAMS file : BIN_FIX_BUILDINGS.GMS

   @purpose  : Fix integers related to buying of building temporary
               during pre-solve with relaxed model
   @author   : W.Britz
   @date     : 20.09.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : binary_fixing.gms

$offtext
********************************************************************************

$$ifthen.buildings defined v_buyBuildings

    $$ifi defined p_buyBuildings option kill=p_buyBuildings;
    p_buyBuildings(buildType,"size",t_n(t,nCur)) = sum((buildType_buildings(buildType,buildings),buildCapac),
                                                      v_buyBuildingsF.l(buildings,t,nCur) * p_building(buildings,buildCapac)) + eps;


    p_buyBuildings(buildType,"min",t_n(t,nCur))
                                 = smax((buildType_buildings(buildType,buildings),buildCapac)
                                     $ ((p_building(buildings,buildCapac) le p_buyBuildings(buildType,"size",t,nCur))
                                     $ p_building(buildings,buildCapac)),
                                                      p_building(buildings,buildCapac));

    p_buyBuildings(buildType,"max",t_n(t,nCur))
                                 = smin((buildType_buildings(buildType,buildings),buildCapac)
                                  $ (p_building(buildings,buildCapac) gt p_buyBuildings(buildType,"size",t,nCur)),
                                     p_building(buildings,buildCapac));

    option kill=v_buyBuildings.l;

    v_buyBuildings.fx(buildings,t_n(t,nCur)) $ (sum((buildType_buildings(buildType,buildings),buildCapac),
               ((p_buyBuildings(buildType,"size",t,nCur) ge eps) and
                (    (p_building(buildings,buildCapac) eq p_buyBuildings(buildType,"min",t,nCur))
                  or (p_building(buildings,buildCapac) eq p_buyBuildings(buildType,"max",t,nCur))))))
      = 1;


    v_buyBuildings.fx(buildings,t_n(t,nCur))
      $ sum((buildType_buildings(buildType,buildings),buildCapac)
                 $ (p_building(buildings,buildCapac) gt p_buyBuildings(buildType,"max",t,nCur)),1) = 0;


$$endif.buildings
