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

   p_OCoeffC("winterWheat",plot,soil,till,intens,"winterWheat",t)   $ sum(soil_plot(soil,plot),c_p_t_i("winterWheat",plot,till,intens))      =  1   * (1.00 + p_cropYieldInt("winterWheat","GrowthRateY")/100) **t.pos;
   p_OCoeffC("winterBarley",plot,soil,till,intens,"winterBarley",t) $ sum(soil_plot(soil,plot),c_p_t_i("winterBarley",plot,till,intens))     =  7   * (1.00 + p_cropYieldInt("winterBarley","GrowthRateY")/100)**t.pos;
   p_OCoeffC("winterRape",plot,soil,till,intens,"winterRape",t)     $ sum(soil_plot(soil,plot),c_p_t_i("winterRape",plot,till,intens))       =  1 * (1.00 + p_cropYieldInt("winterRape","GrowthRateY")/100)**t.pos;
   p_OCoeffC("summerCere",plot,soil,till,intens,"summerCere",t)     $ sum(soil_plot(soil,plot),c_p_t_i("summerCere",plot,till,intens))       =  1 * (1.00 + p_cropYieldInt("SummerCere","GrowthRateY")/100)**t.pos;
   p_OCoeffC("potatoes",plot,soil,till,intens,"potatoes",t)         $ sum(soil_plot(soil,plot),c_p_t_i("potatoes",plot,till,intens))         =  1 * (1.00 + p_cropYieldInt("potatoes","GrowthRateY")/100)**t.pos;
   p_OCoeffC("maizCorn",plot,soil,till,intens,"maizCorn",t)         $ sum(soil_plot(soil,plot),c_p_t_i("maizCorn",plot,till,intens))         =  1 * (1.00 + p_cropYieldInt("maizCorn","GrowthRateY")/100)**t.pos;
   p_OCoeffC("maizCCM",plot,soil,till,intens,"maizCCM",t)           $ sum(soil_plot(soil,plot),c_p_t_i("maizCCM",plot,till,intens))          =  1 * (1.00 + p_cropYieldInt("maizCCM","GrowthRateY")/100)**t.pos;
   p_OCoeffC("sugarBeet",plot,soil,till,intens,"sugarBeet",t)       $ sum(soil_plot(soil,plot),c_p_t_i("sugarBeet",plot,till,intens))        =  1 * (1.00 + p_cropYieldInt("sugarBeet","GrowthRateY")/100)**t.pos;
   p_OCoeffC("summerPeas",plot,soil,till,intens,"summerPeas",t)     $ sum(soil_plot(soil,plot),c_p_t_i("summerPeas",plot,till,intens))       =  1 * (1.00 + p_cropYieldInt("summerPeas","GrowthRateY")/100)**t.pos;
   p_OCoeffC("summerBeans",plot,soil,till,intens,"summerBeans",t)   $ sum(soil_plot(soil,plot),c_p_t_i("summerBeans",plot,till,intens))      =  1* (1.00 + p_cropYieldInt("summerBeans","GrowthRateY")/100)**t.pos;

   $$ifthenI.dairyHerd %cattle% == true

*   ---  wheat GPS and silage maize

   p_OCoeffC("wheatGPS",plot,soil,till,intens,"wheatGPS",t) $ sum(soil_plot(soil,plot), c_p_t_i("wheatGPS",plot,till,intens)) = 40 * (1.00 + p_cropYieldInt("wheatGPS","GrowthRateY")/100) **t.pos;
   p_OCoeffC("maizSil",plot,soil,till,intens,"maizSil",t) $ sum(soil_plot(soil,plot), c_p_t_i("maizSil",plot,till,intens))   = 44  * (1.00 + p_cropYieldInt("maizSil","GrowthRateY")/100) **t.pos ;

   $$endif.dairyHerd

$endif.Schweiz




