********************************************************************************
$ontext

   FARMDYN project

   GAMS file : SCEN_LOAD_RES_MAC.GMS

   @purpose  : Load results from MAC experiments
   @author   : Wolfgang Britz
   @date     : 04.11.13
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : scen_gen.gms

$offtext
********************************************************************************
*
*     --- filter out results of interest (so far only macs, avAcs and totACs)
      p_meta(actInds,redLevl,"mac",actinds1,scen) = p_res(actInds,redLevl,"mac",actInds1,"mean");

*
*     --- set MACS to -1000 (= Farm exit indicator) if for all reduction levels higher than the current one
*         no cow herd is found after the 3th year
*
     option kill=years;
      years(allYears) $ (calYea(allYears) le p_scenParam(scen,"lastYear") ) = yes;

*  alt
*     p_meta(actInds,redLevl,"mac",actinds1,scen) $ (sum((redLevl1,years)  $  (   (redLevl1.pos gt  redLevl.pos)
*                                                                         and (years.pos gt 3) ), p_res(actInds,redLevl1,"cows","Levl",years)) eq 0)
*         = -1000;

      p_meta(actInds,redLevl,"mac",actinds1,scen) $ ((redLevl.pos ne card(redLevl))
                                                      and  (sum( (redLevl1,years) $  (     (redLevl1.pos gt redLevl.pos)
                                                      and (years.pos gt 3) ), p_res(actInds,redLevl1,"cows","Levl",years)) eq 0) )

          = -1000;

*
*     --- exemption for last reduction level: set to -1000 if previous reduction level was -1000
*
      p_meta(actInds,redLevl,"mac",actinds1,scen) $  (    (redLevl.pos eq card(redLevl))
                                                      and  (sum(redLevl1 $ ( (redLevl1.pos eq redLevl.pos-1)
                                                      and (p_meta(actInds,redLevl1,"mac",actinds1,scen) eq -1000)),1)eq 1))
          = -1000;




*     ---   average Abatement costs (avAC)

      p_meta(actInds,redLevl,"avAC",actinds1,scen) $ (p_meta(actInds,redLevl,"mac",actinds1,scen) ne -1000)
        = p_res(actInds,redLevl,"avAC",actInds1,"mean");

*     ---   total Abatement costs (totAC)

      p_meta(actInds,redLevl,"totAC",actinds1,scen) $ (p_meta(actInds,redLevl,"mac",actinds1,scen) ne -1000)
         = p_res(actInds,redLevl,"totAC",actInds1,"mean");

*
*     --- add scen variables to store explanatory vars
*
      p_meta(actInds,redLevl,scenItems,actInds1,scen)
       $ sum(redlevl1, p_res(actInds,redLevl1,"mac",actInds1,"mean")) = p_scenParam(scen,scenItems);

      p_meta(actInds,redLevl,actInds,actInds1,scen)
       $ sum(redlevl1, p_res(actInds,redLevl1,"mac",actInds1,"mean")) = 1;

      p_meta(actInds,redLevl,"redLevl",actInds1,scen)
       $ sum(redlevl1, p_res(actInds,redLevl1,"mac",actInds1,"mean")) =
                                                                         p_res(actInds,redLevl,"redlevl",actInds1,"mean");
*     --- for avAc
            p_meta(actInds,redLevl,scenItems,actInds1,scen)
       $ sum(redlevl1, p_res(actInds,redLevl1,"avAC",actInds1,"mean")) = p_scenParam(scen,scenItems);

      p_meta(actInds,redLevl,"redLevl",actInds1,scen)
       $ sum(redlevl1, p_res(actInds,redLevl1,"avAC",actInds1,"mean")) =
                                                                          p_res(actInds,redLevl,"redlevl",actInds1,"mean");
*     --- for totAC
            p_meta(actInds,redLevl,scenItems,actInds1,scen)
       $ sum(redlevl1, p_res(actInds,redLevl1,"totAC",actInds1,"mean")) = p_scenParam(scen,scenItems);

      p_meta(actInds,redLevl,"redLevl",actInds1,scen)
       $ sum(redlevl1, p_res(actInds,redLevl1,"totAC",actInds1,"mean")) =


















