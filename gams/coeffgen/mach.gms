********************************************************************************
$ontext

   FARMDYN project

   GAMS file : MACH.GMS

   @purpose  : Define lifietime of machinery, investment costss and machenery needs
               for crops
   @author   : Bernd Lengers, Wolfgang britz
   @date     : 13.11.10
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************
$batinclude 'util/title.gms' "'%titlePrefix% Define coefficients relating to machinery'"

$batinclude "%datdir%/%machFile%.gms" read
*
* --- take over general machinery information if available, machine used in KTBL-regressions are depreciated based on EUR-use
*
$iftheni.data "%database%" == "Ktbl_database"
  p_lifeTimeM(machType,"ha")      $ (p_machAttr(machType,"ha")    $ (not (sum(machTypeID_machType(machTypeID,machType),1))))  = p_machAttr(machType,"ha");
  p_lifeTimeM(machType,"hour")    $ (p_machAttr(machType,"hour")  $ (not (sum(machTypeID_machType(machTypeID,machType),1))))  = p_machAttr(machType,"hour");
  p_lifeTimeM(machType,"m3")      $ (p_machAttr(machType,"m3")    $ (not (sum(machTypeID_machType(machTypeID,machType),1))))  = p_machAttr(machType,"m3");
  p_lifeTimeM(machType,"years")   $ p_machAttr(machType,"years")                                                              = p_machAttr(machType,"years");
  p_lifetimeM(machType,"invCost") $ (p_machAttr(machType,"price") $ (sum(machTypeID_machType(machTypeID,machType),1)))        = p_machAttr(machType,"price");
$else.data
    p_lifeTimeM(machType,"ha")    $ p_machAttr(machType,"ha")     = p_machAttr(machType,"ha");
  p_lifeTimeM(machType,"hour")  $ p_machAttr(machType,"hour")   = p_machAttr(machType,"hour");
  p_lifeTimeM(machType,"years") $ p_machAttr(machType,"years")  = p_machAttr(machType,"years");
$endif.data

 p_priceMach(machType,t)       $ p_machAttr(machType,"price") = p_machAttr(machType,"price") * ([1+%outputPriceGrowthRate%/100]**t.pos);

$if set invPrice  p_priceMach(machType,t) = p_priceMach(machType,t) * %invPrice%;

$iftheni.compStat "%dynamics%" == "comparative-static"

*
*  ---- in comp-static mode, assume a planning horizong of 10 years and correct lifetime of machines accordingly
*


  p_priceMach(machType,tCur) $ (p_lifeTimeM(machType,"years")
                                   $ (not (p_machAttr(machType,"ha") or p_machAttr(machType,"hour") or p_machAttr(machType,"m3"))))
     = [sum(t,p_priceMach(machType,t))/card(t)] /  p_lifeTimeM(machType,"years");

  p_priceMach(machType,tCur) $ (p_machAttr(machType,"ha") or p_machAttr(machType,"hour") or p_machAttr(machType,"m3"))
     = [sum(t,p_priceMach(machType,t))/card(t)] / 10;


  p_lifeTimeM(machType,"ha")          = p_lifeTimeM(machType,"ha")/10;
  p_lifeTimeM(machType,"hour")        = p_lifeTimeM(machType,"hour")/10;
  p_lifetimeM(machType,"m3")          = p_lifeTimeM(machType,"m3")/10;
  p_lifeTimeM(machType,"invCost") $  p_lifeTimeM(machType,"invCost") = p_lifeTimeM(machType,"invcost")/ p_lifeTimeM(machType,"years");
  p_lifeTimeM(machType,"years")       = 1 ;

$endif.compStat

  p_lifeTimeM(machType,"years") $ ( p_machAttr(machType,"ha") or p_machAttr(machType,"hour") or p_machAttr(machType,"m3") or p_lifeTimeM(machType,"invCost")) = 0;
* ---- delete machAttr years for machines depreciated by EUR (KTBL-machines)
  p_machAttr(machType,"years")  $ p_lifeTimeM(machType,"invCost") = 0;

* --- For machines working on an hourly basis deduct the diesel use to have a separate accounting
*     NOTE that "diesel_h" is given in the unit l/hour and not in â‚¬/hour as the general variable costs (varCost_h),
*     hence we have to multiply it by the correct diesel costs

      p_machAttr(machType,"varcost_h") $ p_machAttr(machType,"diesel_h")
            = p_machAttr(machType,"varcost_h")
                - (p_machAttr(machType,"diesel_h")* sum(curSys, p_inputprices("diesel",curSys)));
