********************************************************************************
$ontext

   FARMDYN project

   GAMS file : yields.gms

   @purpose  : Defines yields for different regions

   @author   : David Sch�fer
   @date     : 20.03.2017
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************


****
*
* Regional yield levels overwrites the standard yield levels given by "crop and yields" in the GUI. Growth rates (p_cropYieldInt("...","GrowthRateY"))are still given by the GUI but can be adjusted.
* (Currently German Default values)
*
****
$iftheni.Schweiz "%region%" == "Schweiz"

*
*  --- Crop yields and yield increase is defined by data from interface
*

   p_OCoeffC("winterWheat",soil,till,intens,"winterWheat",t)   $ sum(soil_plot(soil,plot),c_p_t_i("winterWheat",plot,till,intens))      =  1   * (1.00 + p_cropYieldInt("winterWheat","GrowthRateY")/100) **t.pos;
   p_OCoeffC("winterBarley",soil,till,intens,"winterBarley",t) $ sum(soil_plot(soil,plot),c_p_t_i("winterBarley",plot,till,intens))     =  7   * (1.00 + p_cropYieldInt("winterBarley","GrowthRateY")/100)**t.pos;
   p_OCoeffC("winterRape",soil,till,intens,"winterRape",t)     $ sum(soil_plot(soil,plot),c_p_t_i("winterRape",plot,till,intens))       =  1 * (1.00 + p_cropYieldInt("winterRape","GrowthRateY")/100)**t.pos;
   p_OCoeffC("summerCere",soil,till,intens,"summerCere",t)     $ sum(soil_plot(soil,plot),c_p_t_i("summerCere",plot,till,intens))       =  1 * (1.00 + p_cropYieldInt("SummerCere","GrowthRateY")/100)**t.pos;
   p_OCoeffC("potatoes",soil,till,intens,"potatoes",t)         $ sum(soil_plot(soil,plot),c_p_t_i("potatoes",plot,till,intens))         =  1 * (1.00 + p_cropYieldInt("potatoes","GrowthRateY")/100)**t.pos;
   p_OCoeffC("maizCorn",soil,till,intens,"maizCorn",t)         $ sum(soil_plot(soil,plot),c_p_t_i("maizCorn",plot,till,intens))         =  1 * (1.00 + p_cropYieldInt("maizCorn","GrowthRateY")/100)**t.pos;
   p_OCoeffC("maizCCM",soil,till,intens,"maizCCM",t)           $ sum(soil_plot(soil,plot),c_p_t_i("maizCCM",plot,till,intens))          =  1 * (1.00 + p_cropYieldInt("maizCCM","GrowthRateY")/100)**t.pos;
   p_OCoeffC("sugarBeet",soil,till,intens,"sugarBeet",t)       $ sum(soil_plot(soil,plot),c_p_t_i("sugarBeet",plot,till,intens))        =  1 * (1.00 + p_cropYieldInt("sugarBeet","GrowthRateY")/100)**t.pos;
   p_OCoeffC("summerPeas",soil,till,intens,"summerPeas",t)     $ sum(soil_plot(soil,plot),c_p_t_i("summerPeas",plot,till,intens))       =  1 * (1.00 + p_cropYieldInt("summerPeas","GrowthRateY")/100)**t.pos;
   p_OCoeffC("summerBeans",soil,till,intens,"summerBeans",t)   $ sum(soil_plot(soil,plot),c_p_t_i("summerBeans",plot,till,intens))      =  1* (1.00 + p_cropYieldInt("summerBeans","GrowthRateY")/100)**t.pos;

   $$ifthenI.dairyHerd %cattle% == true

*  --- grass lands, used for silage (after losses); (34 = KTBL page 489, 2012/13 ca. 25 t)

*   p_OCoeffC("gras20",soil,till,intens,"grasSil",t) $ sum(soil_plot(soil,plot),c_p_t_i("gras20",plot,till,intens)) = 16.6 * (1.00 + p_cropYieldInt("gras20","GrowthRateY")/100) **t.pos ;
*   p_OCoeffC("gras29",soil,till,intens,"grasSil",t) $ sum(soil_plot(soil,plot),c_p_t_i("gras29",plot,till,intens)) = 24.5 * (1.00 + p_cropYieldInt("gras29","GrowthRateY")/100) **t.pos ;
*   p_OCoeffC("gras34",soil,till,intens,"grasSil",t) $ sum(soil_plot(soil,plot),c_p_t_i("gras34",plot,till,intens)) = 32.8 * (1.00 + p_cropYieldInt("gras34","GrowthRateY")/100) **t.pos ;

*  ---  intensive pasture

*   p_OCoeffM("past33",soil,till,intens,"grasPast","APR",t) $ sum(soil_plot(soil,plot),c_p_t_i("past33",plot,till,intens))    = 16.6* 0.02 * (1.00 + p_cropYieldInt("past33","GrowthRateY")/100) **t.pos ;
*   p_OCoeffM("past33",soil,till,intens,"grasPast","MAY",t) $ sum(soil_plot(soil,plot),c_p_t_i("past33",plot,till,intens))    =  16.6* 0.29 * (1.00 + p_cropYieldInt("past33","GrowthRateY")/100) **t.pos ;
*   p_OCoeffM("past33",soil,till,intens,"grasPast","JUN",t) $ sum(soil_plot(soil,plot),c_p_t_i("past33",plot,till,intens))    =  16.6* 0.22 * (1.00 + p_cropYieldInt("past33","GrowthRateY")/100) **t.pos ;
*   p_OCoeffM("past33",soil,till,intens,"grasPast","JUL",t) $ sum(soil_plot(soil,plot),c_p_t_i("past33",plot,till,intens))    =  16.6* 0.17 * (1.00 + p_cropYieldInt("past33","GrowthRateY")/100) **t.pos ;
*   p_OCoeffM("past33",soil,till,intens,"grasPast","AUG",t) $ sum(soil_plot(soil,plot),c_p_t_i("past33",plot,till,intens))    =  16.6* 0.13 * (1.00 + p_cropYieldInt("past33","GrowthRateY")/100) **t.pos ;
*   p_OCoeffM("past33",soil,till,intens,"grasPast","SEP",t) $ sum(soil_plot(soil,plot),c_p_t_i("past33",plot,till,intens))    =  16.6* 0.10 * (1.00 + p_cropYieldInt("past33","GrowthRateY")/100) **t.pos ;
*   p_OCoeffM("past33",soil,till,intens,"grasPast","OCT",t) $ sum(soil_plot(soil,plot),c_p_t_i("past33",plot,till,intens))    =  16.6* 0.07 * (1.00 + p_cropYieldInt("past33","GrowthRateY")/100) **t.pos ;
*
*   p_OCoeffM("past33",soil,till,"fert60p","grasPast",m,t)  $ sum(soil_plot(soil,plot),c_p_t_i("past33",plot,till,"fert60p")) = p_OCoeffM("past33",soil,till,"normal","grasPast",m,t) * 0.9;
*   p_OCoeffM("past33",soil,till,"fert20p","grasPast",m,t)  $ sum(soil_plot(soil,plot),c_p_t_i("past33",plot,till,"fert20p")) = p_OCoeffM("past33",soil,till,"normal","grasPast",m,t) * 0.8;
*
*   p_OCoeffC("past33",soil,till,intens,"grasPast",t) $  sum(soil_plot(soil,plot),c_p_t_i("past33",plot,till,intens)) = sum(m, p_OCoeffM("past33",soil,till,intens,"grasPast",m,t));

*   ---  wheat GPS and silage maize

   p_OCoeffC("wheatGPS",soil,till,intens,"wheatGPS",t) $ sum(soil_plot(soil,plot), c_p_t_i("wheatGPS",plot,till,intens)) = 40 * (1.00 + p_cropYieldInt("wheatGPS","GrowthRateY")/100) **t.pos;
   p_OCoeffC("maizSil",soil,till,intens,"maizSil",t) $ sum(soil_plot(soil,plot), c_p_t_i("maizSil",plot,till,intens))   = 44  * (1.00 + p_cropYieldInt("maizSil","GrowthRateY")/100) **t.pos ;

   $$endif.dairyHerd

$endif.Schweiz




