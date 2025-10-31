********************************************************************************
$ontext

   FARMDYN project

   GAMS file : CROPPING.GMS

   @purpose  : Defines nutrient need of crops
   @author   : Till Kuhn
   @date     : 23.01.21
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************

$iftheni.fert %Fertilization% == "Default"
* --- nutrient need, taking into that output coefficient are measured in t and not dt, therefore * 10.

  p_nutNeed(c_ss_t_i(curCrops(crops),soil,till,intens),nut,t)
         = sum( prods $ p_OCoeffC(crops,soil,till,intens,prods,t), p_OCoeffC(crops,soil,till,intens,prods,t)/p_storageLoss(prods)
             * (  p_nutContent(crops,prods,"conv",nut) $ (not sameas(till,"org"))
                + p_nutContent(crops,prods,"org",nut)  $      sameas(till,"org") )*10);

$endif.fert

* --- If fertilization is according to Fertilization Ordinance, the fertilizing planning also defines p_nutNeed

$iftheni.fert %Fertilization% == "FertilizationOrdinance"

     p_nutNeed(c_ss_t_i(curCrops(crops),soil,till,"normal"),nut,t)
                 = p_NneedFerPlan(crops,soil,till,"normal",nut,t)  ;
$endif.fert


$iftheni.fert %Fertilization% == "OrganicFarming"

*
*--- Calculate N removal (N content in harvested products) , storage losses are considered,
*    taking into that output coefficient are measured in t and not dt, therefore * 10.
*    here, not only arable crops are considered but also catchcrops
p_nutNeed(c_ss_t_i(curCrops(crops),soil,till,intens),nut,t) $ (not sameas(till,"org"))
         =     p_cropYieldInt(curCrops,"conv")
              *  ((1.00 + p_cropYieldInt(curCrops,'Change,conv % p.a.')/100)**t.pos)
              *   sum(prods, p_nutContent(curCrops,prods,"conv",nut) * 10 $(sameas(curcrops,prods)))
              ;
p_nutNeed(c_ss_t_i(curCrops(crops),soil,"org",intens),nut,t)
  =  p_cropYieldInt(curCrops,"org")
       *  ((1.00 + p_cropYieldInt(curCrops,'Change,org % p.a.')/100)**t.pos)
       * sum(prods, p_nutContent(curCrops,prods,"org",nut) * 10 $(sameas(curCrops,prods)))
             ;


*
*--- Calculate N extraction of shoot (harvested product + by-product)
*

p_NextractShoot(c_ss_t_i(curCrops,soil,till,intens),t)    $ (not sameas(till,"org"))
   =     p_cropYieldInt(curCrops,"conv")
        *  ((1.00 + p_cropYieldInt(curCrops,'Change,conv % p.a.')/100)**t.pos)
        *  p_NcontShoot(curCrops,"conv") * 10
        ;

p_NExtractShoot(c_ss_t_i(curCrops,soil,"org",intens),t)
  =  p_cropYieldInt(curCrops,"org")
       *  ((1.00 + p_cropYieldInt(curCrops,'Change,org % p.a.')/100)**t.pos)
       *  p_NcontShoot(curCrops,"org") * 10
       ;

*
* "N content in plant, including main product, by-product, residues and roots"
*
    p_NExtractPlant(c_ss_t_i(curCrops,soil,till,intens),t)    $ (not sameas(till,"org"))
       =     p_cropYieldInt(curCrops,"conv")
            *  ((1.00 + p_cropYieldInt(curCrops,'Change,conv % p.a.')/100)**t.pos)
            *  p_NcontPlant(curCrops,"conv") * 10
            ;

    p_NExtractPlant(c_ss_t_i(curCrops,soil,"org",intens),t)
      =  p_cropYieldInt(curCrops,"org")
           *  ((1.00 + p_cropYieldInt(curCrops,'Change,org % p.a.')/100)**t.pos)
           *  p_NcontPlant(curCrops,"org") * 10
           ;

p_NextractShoot(c_ss_t_i(curCrops,soil,till,intens),t) $ (not p_NextractShoot(curCrops,soil,till,intens,t)) =
                p_nutNeed(curCrops,soil,till,intens,"N",t) ;

p_NExtractPlant(c_ss_t_i(curCrops,soil,till,intens),t) $ (not p_NExtractPlant(curCrops,soil,till,intens,t)) =
                 p_nutNeed(curCrops,soil,till,intens,"N",t) ;

parameter p_Nbyproduct(crops,soil,till,intens,t) "Nitrogen in non harvested byproduct";

p_Nbyproduct(c_ss_t_i(curCrops,soil,till,intens),t)
= p_NextractShoot(curCrops,soil,till,intens,t) - p_nutNeed(curCrops,soil,till,intens,"N",t);

parameter p_Nroots(crops,soil,till,intens,t) "Nitrogen in crop residues and roots";

    p_Nroots(c_ss_t_i(curCrops,soil,till,intens),t)
      = p_NExtractPlant(curCrops,soil,till,intens,t)
        - p_NExtractShoot(curCrops,soil,till,intens,t);

$endif.fert

*
* --- pasture nutrient need, taking into that output coefficient are measured in t and not dt, therefore * 10.
*       construct is important to distribute excreta from grazing to grazed grassland evenly

  p_pastNeed(c_ss_t_i(curCrops(crops),soil,till,intens),nut,t)
       = sum( pastOutput $ p_OCoeffC(crops,soil,till,intens,pastOutput,t), p_OCoeffC(crops,soil,till,intens,pastOutput,t)/p_storageLoss(pastOutput)
           * (   p_nutContent(crops,pastOutput,"conv",nut) $ (not sameas(till,"org"))
               + p_nutContent(crops,pastOutput,"org",nut)  $      sameas(till,"org")
              )*10);

$ifthen.grasAttr defined p_grasAttr

  p_pastNeedMonthly(c_ss_t_i(curCrops(crops),soil,till,intens),nut,t,m)
     $ (sum((m1,pastOutputs),p_grasAttr(curCrops,pastOutputs,m1) * p_nutGras(pastOutputs,"XP")))
       = p_pastNeed(curCrops,soil,till,intens,nut,t)
         * sum(pastOutputs, p_grasAttr(curCrops,pastOutputs,m)* p_nutGras(pastOutputs,"XP"))
     / sum((m1,pastOutputs),p_grasAttr(curCrops,pastOutputs,m1) * p_nutGras(pastOutputs,"XP"))
           ;

$endif.grasAttr


******************************
*
* ---- Definition of fertilizing level under different intensities for two intensity settings, (1) default and according
*      to Heyn and Olfs. Underlying yield changes are calculated in coeffgen/cropping_intens.gms
*
******************************

* --- (1) Calculation of the nutrient need of the different intensities. Assumption that P need of crops correponds to the
*     removal with the adjusted yield level


$ifthen.intensOpt "%intensoptions%"=="Heyn_Olfs"

    p_nutNeed(c_ss_t_i(curCrops(arabCrops),soil,till,intens),"N",t)  $ (not sameas (intens,"normal"))
                  =  p_nutNeed(arabCrops,soil,till,"normal","N",t) *  p_intens(arabCrops,intens);

$else.intensOpt


   p_nutNeed(c_ss_t_i(curCrops(arabcrops),soil,till,intens),"N",t)  $ (not sameas (intens,"normal"))
                = sum( prods, p_OCoeffC(arabcrops,soil,till,"normal",prods,t)
                   * (    p_nutContent(arabcrops,prods,"conv","N") $ (not sameas(till,"org"))
                        + p_nutContent(arabcrops,prods,"org","N")  $      sameas(till,"org")
                   )*10)  *  p_intens(arabcrops,intens)
                                                                 ;

$endif.intensOpt

* --- (2) Calculation of the nutrient need of the different intensities. Assumption that P need of crops correponds to the
*     removal with the adjusted yield level

   p_nutNeed(c_ss_t_i(curCrops(arabcrops),soil,till,intens),"P",t)  $ (not sameas (intens,"normal"))
                  = sum( prods, p_OCoeffC(arabcrops,soil,till,intens,prods,t)
                   * (    p_nutContent(arabcrops,prods,"conv","P") $ (not sameas(till,"org"))
                         + p_nutContent(arabcrops,prods,"org","P")  $      sameas(till,"org")
                   )*10);
