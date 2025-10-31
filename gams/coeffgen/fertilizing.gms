********************************************************************************
$ontext

   FARMDYN project

   GAMS file : FERTILIZING.GMS

   @purpose  : Define different attribute of organic / synthetic
               fertilizer applications (N loesses, costs, labour demand,
               months in which application is forbidden, maximual doses)

   @author   : B.Lengers
   @date     : 02.11.11
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************

$batinclude 'util/title.gms' "'%titlePrefix% Define coefficients relating to manure and synthetic fertilizing'"

* --- definition of costs for different application techniques

* --- defintion of N loss shares

   p_syntDistLab(syntFertilizer) = 1/6 * 1/200;
*
*  --- see e.g KTBL 2012/2013, page 388, BLA and FA
*
   p_syntDistLab("PK_18_10")     = 0.25* 1/360;
* --- assume same for dolophos
   p_syntDistLab("dolophos")     = 0.25* 1/360;

* --- N in synthetic fertilizer according to KTBL(2005) Faustzahlen f�r die Landwirtschaft, S.254 [TK 7.11.13]

   p_nutInSynt("AHL","N") = 0.28;
   p_nutInSynt("ASS","N") = 0.26;
   p_nutInSynt("PK_18_10","P") = 0.18;
   p_nutInSynt("dolophos","P") = 0.26;



  v_syntDist.up(crops,plot,till,intens,syntFertilizer,t,nCur,m)
       $ ( t_n(t,nCur) $ c_p_t_i(crops,plot,till,intens) $ doNotApplySyn(crops,m)  ) = 0 ;

$iftheni.v_manDist declared v_manDist
  v_manDist.up(crops,plot,till,intens,manApplicType,manType,t,nCur,m)
     $ ( t_n(t,nCur) $ c_p_t_i(crops,plot,till,intens) $ doNotApplyManure(crops,m) ) = 0  ;
$endif.v_manDist


$ifi %manure%==true  v_volManApplied.up(manChain,t,nCur,m) $ t_n(t,nCur)  = inf;

$$iftheni.PlotEndo not "%landEndo%" == "Land endowment per plot"
   $$ifthen.FO %duev% == false
     $$iftheni.cattle %cattle% ==true
        v_syntDist.up(grassCrops(crops),"plot7",till,intens,syntFertilizer,t,nCur,m) = 0;
     $$endif.cattle
   $$endif.FO
$$endif.PlotEndo
*
* --- WB: ToDO: add fertilizers allowed in organic farming
*
  v_syntDist.up(arabCrops(crops),plot,"org",intens,syntFertilizer,t,nCur,m)
                                                   $ ( t_n(t,nCur) $ c_p_t_i(crops,plot,"org",intens)
                                                     $ p_nutInSynt(syntFertilizer,"N"))  = 0 ;

* --- No N-Fertilizer in organic production

  v_syntDist.up(crops,plot,"org",intens,"AHL",t,n,m)
                                                  $ ( t_n(t,n) $ c_p_t_i(crops,plot,"org",intens) )  = 0 ;
  v_syntDist.up(crops,plot,"org",intens,"ASS",t,n,m)
                                                 $ ( t_n(t,n) $ c_p_t_i(crops,plot,"org",intens) )  = 0 ;

 v_syntDist.up(crops,plot,"org",intens,"PK_18_10",t,n,m)
                                                  $ ( t_n(t,n) $ c_p_t_i(crops,plot,"org",intens) )  = 0 ;

  v_syntDist.up(grassCrops(crops),plot,"org",intens,syntFertilizer,t,nCur,m)
                                                   $ ( t_n(t,nCur) $ c_p_t_i(grassCrops,plot,"org",intens)
                                                     $ p_nutInSynt(syntFertilizer,"N"))  = 0 ;

$iftheni.manure %manure%==true
   $$iftheni.PlotEndo not "%landEndo%" == "Land endowment per plot"
     $$iftheni.cattle %cattle% ==true
        v_manDist.up(grassCrops(crops),"plot7",till,intens,manApplicType_manType(manApplicType,curManType),t,nCur,m)
                                                      $ ( t_n(t,nCur) $ c_p_t_i(grassCrops,"plot7",till,intens)) = 0;
     $$endif.cattle
   $$endif.PlotEndo

     $$iftheni.appl "%ManureAppl%" == "Contract work"
*
*           --- manure application is based on contract work:


*       --- Manure application costs are for contract work
*        Erfahrungssaetze fuer Maschinenring-Arbeiten ab 2017" are used which provide costs per h,
*        m3 application per h is derived from KTBL homepage
*
*        Following assumptions:
*           - application of 30 m3 manure /ha, 1 km distance between farm and field
*           - broadcast spreader: 20 mm3 pump tank track -> 48.3 m3/ha
*           - drag shoe: 20 m3 pump tank track, working width 6 m -> 37.5 m3/h
*           - drag hoe: 20 m3 pump tank track, working width 15 m -> 38.4 m3/h
*           - injection: transport barrel 2 4m3, pump tank track 8 m3, working width 4.50 -> 56.7 m3/h

        option kill=p_manApplicCost;


        $$iftheni.pig "%pigHerd%"=="true"
        p_manApplicCost("applSpreadPig")     = 1.74 *  (1 + (%applCostVariation%) ) ;
           p_manApplicCost("applTailhPig")      = 2.80 *  (1 + (%applCostVariation%) ) ;
           p_manApplicCost("applInjecPig")      = 3.90 *  (1 + (%applCostVariation%) ) ;
           p_manApplicCost("applTShoePig")      = 3.01 *  (1 + (%applCostVariation%) ) ;
        $$endif.pig
        $$iftheni.cattle "%cattle%"=="true"
        p_manApplicCost("applSpreadCattle")  = 1.74 *  (1 + (%applCostVariation%) ) ;
           p_manApplicCost("applTailhCattle")   = 2.80 *  (1 + (%applCostVariation%) ) ;
           p_manApplicCost("applInjecCattle")   = 3.90 *  (1 + (%applCostVariation%) ) ;
           p_manApplicCost("applTShoeCattle")   = 3.01 *  (1 + (%applCostVariation%) ) ;
        $$endif.cattle
        $$iftheni.import "%AllowManureImport%"=="true"
        p_manApplicCost("applSpreadImport")  = 1.74 *  (1 + (%applCostVariation%) ) ;
        p_manApplicCost("applTailhImport")   = 2.80 *  (1 + (%applCostVariation%) ) ;
        p_manApplicCost("applInjecImport")   = 3.90 *  (1 + (%applCostVariation%) ) ;
        p_manApplicCost("applTShoeImport")   = 3.01 *  (1 + (%applCostVariation%) ) ;
        $$endif.import

        $$iftheni.straw "%strawManure"=="true"

*      --- Assumption that costs for new spreading techniques is 3 Euro, needs validation

        p_manApplicCost("applSolidSpread")       = 3;
        p_manApplicCost("applSpreadLightCattle") = 3;
        p_manApplicCost("applTailhLightCattle")  = 3;
        p_manApplicCost("applTShoeLightCattle")  = 3;

        $$endif.straw

        option kill=p_manDistLab;
        p_machNeed(ManApplicType,"plough","normal",machType,"m3") = 0;
        p_machNeed(ManApplicType,"plough","normal",machType,"hour") = 0;

* Accounting for manDistLab 
        $$iftheni.cattle "%cattle%"=="true"
      p_manDistLab("applSpreadCattle") = 0.57 * 1/20;
       p_manDistLab("applTailhCattle")  = 0.73 * 1/20;
       p_manDistLab("applInjecCattle")  = 0.82 * 1/20;
       p_manDistLab("applTShoeCattle")  = 0.80 * 1/20;
       p_manDistLab("applSpreadCattle") = 0.57 * 1/20;
        $$endif.cattle

   $$else.appl
*
       p_manApplicCost(manApplicType)    = 0;
*
*      --- definition of labour demand for differetn N application techniques (hours/kg N applicated) KTBL 2010pp.156
*          20m3 manure assumed per ha.
*          For solid manure with 25% DM, 5 kg N/t FM (DüV), 20t solid manure/ha with 6m working widht assumed


      $$iftheni.pig "%pigHerd%"=="true"
       p_manDistLab("applSpreadPig")    = 0.57 * 1/20;
          p_manDistLab("applTailhPig")     = 0.73 * 1/20;
          p_manDistLab("applInjecPig")     = 0.82 * 1/20;
          p_manDistLab("applTShoePig")     = 0.80 * 1/20;
        $$endif.pig
        $$iftheni.cattle "%cattle%"=="true"

       p_manDistLab("applSpreadCattle") = 0.57 * 1/20;
       p_manDistLab("applTailhCattle")  = 0.73 * 1/20;
       p_manDistLab("applInjecCattle")  = 0.82 * 1/20;
       p_manDistLab("applTShoeCattle")  = 0.80 * 1/20;
          p_manDistLab("applSpreadCattle") = 0.57 * 1/20;
        $$endif.cattle
        $$iftheni.straw "%strawManure"=="true"
       p_manDistLab("applSolidSpread")  = 0.17 * 1/20;
       p_manDistLab("applSpreadLightCattle") = 0.57 * 1/20;
       p_manDistLab("applTailhLightCattle")  = 0.73 * 1/20;
       p_manDistLab("applInjecLightCattle")  = 0.82 * 1/20;
       p_manDistLab("applTShoeLightCattle")  = 0.80 * 1/20;
        $$endif.straw
   $$endif.appl

$endif.manure
