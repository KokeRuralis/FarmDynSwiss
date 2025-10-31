********************************************************************************
$ontext

   FARMDYN project

   GAMS file : CROPPING.GMS

   @purpose  : Define yields, max. rotational shares, variable costs,
               N content of crops
   @author   : Bernd Lengers
   @date     : 13.11.10
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************
******************************
*
* ---- Definition of output (yield level) under different intensities for two intensity settings, (1) default and according
*      to Heyn and Olfs; both settings are always active, depending on GUI settings, the relevant elements of intens set are switched
*      on in coeffgen.gms
*
******************************

$iftheni.intensOpt "%intensoptions%"=="Default"
*
* --- (1) Default - Definition of different crop intensities based on N fertilizer level (100% to 20%)
*
    p_OCoeffC(c_ss_t_i(curCrops(arabCrops),soil,till,"fert80p"),prods,t) $ (not sameas(till,"org"))
     = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.96;
    p_OCoeffC(c_ss_t_i(curCrops(arabCrops),soil,till,"fert60p"),prods,t) $ (not sameas(till,"org"))
     = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.90;
    p_OCoeffC(c_ss_t_i(curCrops(arabCrops),soil,till,"fert40p"),prods,t) $ (not sameas(till,"org"))
     = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.82;
    p_OCoeffC(c_ss_t_i(curCrops(arabCrops),soil,till,"fert20p"),prods,t) $ (not sameas(till,"org"))
     = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.73;

    p_OCoeffC(c_ss_t_i(curCrops(arabCrops),soil,till,"fert80p"),prods,t) $ (not sameas(till,"org"))
     = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.95;
    p_OCoeffC(c_ss_t_i(curCrops(arabCrops),soil,till,"fert60p"),prods,t) $ (not sameas(till,"org"))
     = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.85;
    p_OCoeffC(c_ss_t_i(curCrops(arabCrops),soil,till,"fert40p"),prods,t) $ (not sameas(till,"org"))
     = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.71;
    p_OCoeffC(c_ss_t_i(curCrops(arabCrops),soil,till,"fert20p"),prods,t) $ (not sameas(till,"org"))
     = p_oCoeffC(arabCrops,soil,till,"normal",prods,t) * 0.53;


$elseifi.intensOpt "%intensoptions%"=="Heyn_Olfs"


   p_yieldReducN(crops,"normal") = 100  ;

* --- Calculation of the yield level for different intensities

   p_OCoeffC(c_ss_t_i(curCrops(arabCrops),soil,till,intens),prods,t)
              $ sum(  soil_plot(soil,plot),c_p_t_i(arabCrops,plot,till,intens) )
                  =   p_OCoeffC(arabCrops,soil,till,"normal",prods,t)  * p_yieldReducN(arabCrops,intens)/100 ;

$endif.intensOpt
