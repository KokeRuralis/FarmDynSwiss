********************************************************************************
$ontext

   FarmDyn project

   FarmDyn file : CALIB.GMS

   @purpose  : Bi-level based calibration of LP at fixed integers
   @author   : Wolfgang Britz
   @date     : 01.03.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter.gms

$offtext
********************************************************************************
$onrecurse
$iftheni.mode "%1"=="fixPars"

    v_costQuant(crops,curInputs) $ sum(c_p_t_i(curCrops,plot,till,intens), p_costQuant(crops,till,intens,curInputs)) = 1;
    $$ifthen.v_reqsCorr declared v_reqsCorr
     v_reqsCorr(possHerds,breeds,"ener") $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1) = 1;
     v_reqsCorr(possHerds,breeds,"prot") $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1) = 1;
     v_reqsCorr(possHerds,breeds,"rest") $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1) = 1;
    $$endif.v_reqsCorr
    $$ifi "%parsAsVars%"=="false" $exit

    p_vPriceInv.fx(invTypes) = p_vPriceInv.l(invTypes);
*
*   --- fix parameters which are formally variables as they are used for calibration
*
    p_vCostC.fx(crops,till,intens,t) $ sum(c_p_t_i(curCrops(crops),plot,till,intens),1) = p_vCostC.l(crops,till,intens,t);

    p_OCoeffC.fx(curCrops,soil,till,intens,curProds,t) $ sum(c_p_t_i(curCrops,plot,till,intens),p_OCoeffC.l(curCrops,soil,till,intens,curProds,t))
     = p_OCoeffC.l(curCrops,soil,till,intens,curProds,t);

    p_OCoeffC.scale(curCrops,soil,till,intens,curProds,t) $ sum(c_p_t_i(curCrops,plot,till,intens),p_OCoeffC.l(curCrops,soil,till,intens,curProds,t))
     = p_OCoeffC.l(curCrops,soil,till,intens,curProds,t);


    $$iftheni.gras defined p_oCoeffM

       p_OCoeffM.fx(grassCrops(curCrops),soil,till,intens,curProds,m,t) $ sum(c_p_t_i(curCrops,plot,till,intens),p_OCoeffM.l(curCrops,soil,till,intens,curProds,m,t))
         = p_OCoeffM.l(curCrops,soil,till,intens,curProds,m,t);

    $$endif.gras


    $$ifthen.p_Vcost defined p_vCost
      p_vCost.fx(possHerds,breeds,t) $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1)
       = p_vCost.l(possHerds,breeds,t);

      p_herdLab.fx(sumHerds,feedRegime,m) $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1)
        = p_herdLab.l(sumHerds,feedRegime,m);

    $$endif.p_vCost

    $$ifthen.p_feedReqPig defined p_feedReqPig

       p_feedReqPig.fx(possHerds,feedRegime,feedAttr) $ (sum(actHerds(possHerds,"",feedRegime,tCur,m),1)
                                                         $ p_feedReqPig.l(possHerds,feedRegime,feedAttr))
          = p_feedReqPig.l(possHerds,feedRegime,feedAttr);

    $$endif.p_feedReqPig

    p_cropLab.fx(crops,till,intens,m) $ sum(c_p_t_i(curCrops(crops),plot,till,intens),1) = p_cropLab(crops,till,intens,m);


    p_price.fx(curProds,sys,t)       = p_price.l(curProds,sys,t);
    p_price.fx("youngCow",sys,t)     = p_price.l("youngCow",sys,t);
    p_Inputprice.fx(curInputs,sys,t) = p_inputPrice.l(curInputs,sys,t);
    p_price.fx("manureExport","conv",t) = p_price.l("manureExport","conv",t);
    p_price.fx("manureImport","conv",t) = p_price.l("manureImport","conv",t);
    v_costQuant.fx(crops,curInputs) $ sum(c_p_t_i(curCrops,plot,till,intens), p_costQuant(crops,till,intens,curInputs)) = 1;

    $$ifthen.v_reqsCorr declared v_reqsCorr
     v_reqsCorr.fx(possHerds,breeds,"ener") $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1) = 1;
     v_reqsCorr.fx(possHerds,breeds,"prot") $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1) = 1;
     v_reqsCorr.fx(possHerds,breeds,"rest") $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1) = 1;
    $$endif.v_reqsCorr

$elseifi.mode "%1"=="Target"
*
*   --- define calibration targets based on information provided by user
*

    set calibItems /target,unrestrMIP,boundsRMIP,mipBefore,bilevel,fixedBin,final /;
    $$iftheni.File "%calibration%"=="file"

        $$include 'calibFiles/%calibFile%.gms'

        $$iftheni.cattle "%cattle%"=="true"
           p_nCows        $ p_calibTarget("cows","")       = p_calibTarget("cows","");
           p_nMotherCows  $ p_calibTarget("motherCow","")  = p_calibTarget("motherCow","");
           p_nBulls       $ p_calibTarget("bulls","")      = p_calibTarget("bulls","");
           p_nHeifs       $ p_calibTarget("heifs","")      = p_calibTarget("heifs","");
           p_nCalves      $ p_calibTarget("calves","")     = p_calibTarget("calves","");
        $$endif.cattle

        $$iftheni.pigherd "%pigHerd%"=="true"
           p_nSows        $ p_calibTarget("sows","")       = p_calibTarget("sows","");
           p_nFattners    $ p_calibTarget("fattners","")   = p_calibTarget("fattners","");
        $$endif.pigherd

    $$endif.file
*
*   -- remove crops which are forced to zero
*
    c_p_t_i(curCrops,plot,till,intens) $ (p_calibTarget(curCrops,"") $ (p_calibTarget(curCrops,"") eq eps)) = no;

$elseifi.mode "%1"=="Bounds"

*
*   --- scale crop shares to unity
*
    $$iftheni.calibrationFile "%calibration%"=="file"

    p_calibTarget(arabCrops,"") $ (not sum(sameas(curCrops,arabCrops),1)) = 0;

    alias(curCrops,curCrops1);
    p_calibTarget(curCrops,"") $ (arabCrops(curCrops) $ p_calibTarget(curCrops,"") $ (not (sameas(curCrops,"idle") or sum(catchcrops, sameas(curCrops,catchcrops)))))
     = p_calibTarget(curCrops,"") * (1 - p_calibTarget("idle","")) / sum(arabCrops(CurCrops1)  $ (not (sameas(curCrops1,"idle") or sum(catchcrops, sameas(curCrops1,catchcrops)))),
         p_calibTarget(curCrops1,""));

    $$else.calibrationFile

        parameter p_calibTarget(*,*);
        p_calibTarget(arabCrops(curCrops),"") = p_farmData(farmId,"ha",curCrops)/p_nArabLand;;

    $$endif.calibrationFile
*
*   --- set calibration targets for herds included in model
*
    $$ifthen.herds defined actHerds
       p_calibTarget(sumHerds,breeds) $ (p_calibTarget(sumHerds,"") $ sum( (feedRegime,t,m) $ actHerds(sumHerds,breeds,feedRegime,t,m),1))
          = p_calibTarget(sumHerds,"");
    $$endif.herds


    parameter p_calibReport;
    p_calibReport("crops",curCrops,"ha","target")      = p_calibTarget(CurCrops,"")*p_nArabLand;

    $$iftheni.herds defined herds

       p_calibReport("herds",possHerds,breeds,"target")  = p_calibTarget(possHerds,breeds);

       p_calibReport("herds",sumHerds,"","target") $ (not p_calibReport("herds",sumHerds,"","target"))
         = sum(breeds,p_calibReport("herds",sumHerds,breeds,"target"));
   $$endif.herds
*
*   --- solve model without bounds
*
   $$ife %nHeuristicFixing%>0  solve m_farm using %RMIP% maximizing v_obje;
   $$ife %nHeuristicFixing%>0  $include 'model/copy_stoch.gms'
   $$ife %nHeuristicFixing%>0  $$batinclude 'solve/binary_fixing.gms'
   $$batinclude 'util/title.gms' "'%titlePrefix% Solve model as %MIP% without bounds before calibration'"
   solve m_farm using %MIP% maximizing v_obje;
   $$ifi "%stochProg%"=="true" $include 'model/copy_stoch.gms'
   $$batinclude 'calib\calibReport' 'unrestrMIP' yes

   scalar p_objeLimitLow,p_objeLimitUpp;
   p_objeLimitLow = v_obje.l * %objeLimitLow%/100;
   p_objeLimitUpp = v_obje.l * %objeLimitUpp%/100;
*
*   --- set bounds for test solve with models, should push binaries close to what is requried for calibration
*       (+/-50% for crops, +/-10% for herds)
*
    v_sumCrop.lo(curCrops,curSys,t_n(tCur,nCur)) $ (arabCrops(curCrops) $ (p_calibTarget(curCrops,"") gt eps))
      = p_calibTarget(curCrops,"") * p_nArabLand * 0.5;
    v_sumCrop.up(curCrops,curSys,t_n(tCur,nCur)) $ (arabCrops(curCrops) $ (p_calibTarget(curCrops,"") gt eps))
      = p_calibTarget(curCrops,"") * p_nArabLand * 1.5;

    v_sumCrop.FX(curCrops,curSys,t_n(tCur,nCur)) $ (arabCrops(curCrops) $ (p_calibTarget(curCrops,"") eq eps) $ p_calibTarget(curCrops,"")) = 0;

    $$ifthen.herds defined actHerds
       p_calibTarget(sumHerds,breeds) $ (p_calibTarget(sumHerds,"") $ sum( (feedRegime,t,m) $ actHerds(sumHerds,breeds,feedRegime,t,m),1))
         = p_calibTarget(sumHerds,"");

      v_sumHerd.lo(sumHerds,breeds,t_n(tCur,nCur)) $ p_calibTarget(sumHerds,breeds) =  p_calibTarget(sumHerds,breeds) * 0.95;
      v_sumHerd.up(sumHerds,breeds,t_n(tCur,nCur)) $ p_calibTarget(sumHerds,breeds) =  p_calibTarget(sumHerds,breeds) * 1.05;
    $$endif.herds
*
*   --- solve model at bounds is part of normal exp_starter
*
    p_cutLow = -inf;

$else.mode


   $$batinclude 'util/title.gms' "'%titlePrefix% Bi-level based calibration; solve model with some broader bounds and store binaries'"
*
   $$ifi     %useMIP%==on   solve m_farm using %MIP%  maximizing v_obje;
   $$ifi not %useMIP%==on   solve m_farm using %RMIP% maximizing v_obje;
   $$ifi "%stochProg%"=="true" $include 'model/copy_stoch.gms'
*
*  --- by settings the scale field, the prices are reported to the p_calib parameter
*
   p_price.scale(curProds,sys,t) $ p_price.l(curProds,sys,t) = p_price.l(curProds,sys,t);
   p_inputPrice.scale(curInputs,sys,t) $ p_inputPrice.l(curInputs,sys,t) = p_inputPrice.l(curInputs,sys,t)*(1+1.E-6);

   reportPrice = 1;
   $$batinclude 'calib\calibReport' 'mipBefore' yes
   reportPrice = 0;
*
*  --- define penalty function of bi-level estimation odel
*
   variable v_fit
   variable v_fitLevls;
   Equation e_fit
            e_fitLevls
            e_objeLimitLow
            e_objeLimitUpp;


   e_objeLimitLow .. v_obje =G= p_objeLimitLow;
   e_objeLimitUpp .. v_obje =L= p_objeLimitUpp;


   e_fit .. v_fit *0.01


    =e=
    {

     + sum( (curCrops(crops),till,intens,tCur(t)) $ (sum(c_p_t_i(crops,plot,till,intens),1)
                                                     $ p_vCostC.l(crops,till,intens,t)
                                                       $ (p_vCostC.scale(crops,till,intens,t) ne 1)),
                 sqr( (p_vCostC(crops,till,intens,t)-p_vCostC.scale(crops,till,intens,t))
                         /p_vCostC.scale(crops,till,intens,t)))

     +  sum(invTypes,sqr(p_vPriceInv(invTypes) - 1))


     + sum( (curCrops(crops),curInputs) $ v_costQuant.l(crops,curInputs),
                 sqr( (v_costQuant(crops,curInputs)-1)))

     + sum( (curProds,sys,tCur(t)) $ (p_price.scale(curProds,sys,t) ne 1),
                 sqr( (p_price(curProds,sys,t)-p_price.scale(curProds,sys,t))
                         /p_price.scale(curProds,sys,t)))

     + sum( (curInputs,sys,tCur(t)) $ (p_inputPrice.scale(curInputs,sys,t) ne 1),
                 sqr( (p_inputPrice(curInputs,sys,t)-p_inputPrice.scale(curInputs,sys,t))
                         /p_inputPrice.scale(curInputs,sys,t)))

     + sum( (curCrops(crops),soil,till,intens,curProds,tCur(t)) $  (sum(c_p_t_i(crops,plot,till,intens),1)
                                                      $ p_OCoeffC.l(curCrops,soil,till,intens,curProds,t)
                                                         $ (p_OCoeffC.scale(curCrops,soil,till,intens,curProds,t) ne 1)),

                  sqr( ( p_OCoeffC(curCrops,soil,till,intens,curProds,t)
                        -p_OCoeffC.scale(curCrops,soil,till,intens,curProds,t))
                      /  p_OCoeffC.scale(curCrops,soil,till,intens,curProds,t)))

     $$iftheni.gras defined p_oCoeffM
        + sum( (curCrops(crops),soil,till,intens,curProds,m,tCur(t)) $  (sum(c_p_t_i(crops,plot,till,intens),1)
                                                      $ p_OCoeffM.l(curCrops,soil,till,intens,curProds,m,t)
                                                         $ (p_OCoeffM.scale(curCrops,soil,till,intens,curProds,m,t) ne 1)),

                  sqr( ( p_OCoeffM(curCrops,soil,till,intens,curProds,m,t)
                        -p_OCoeffM.scale(curCrops,soil,till,intens,curProds,m,t))
                      /  p_OCoeffM.scale(curCrops,soil,till,intens,curProds,m,t))  )

     $$endif.gras

     $$ifthen.herds defined v_sumHerd
         + sum( (possHerds,breeds,tCur(t)) $ (sum(actHerds(possHerds,breeds,feedRegime,t,m),1)
                                        $ p_vCost.l(possHerds,breeds,t)
                                           $ (p_vCost.scale(possHerds,breeds,t) ne 1)),
              sqr ( (p_vCost(possHerds,breeds,t) - p_vCost.scale(possHerds,breeds,t))
                    /p_vCost.scale(possHerds,breeds,t)) )

         + sum( (sumHerds,feedRegime,m)  $ (sum(actHerds(sumHerds,breeds,feedRegime,t,m),1)
                                          $ p_herdLab.l(sumHerds,feedRegime,m)
                                          $ ( p_herdLab.scale(sumHerds,feedRegime,m) ne 1)),
              sqr( (p_herdLab(sumHerds,feedRegime,m) - p_herdLab.scale(sumHerds,feedRegime,m))
                                                     /p_herdLab.scale(sumHerds,feedRegime,m))
             )

     $$endif.herds

     $$ifthen.p_feedReqPig defined p_feedReqPig

        + sum( (possHerds,feedAttr,feedRegime) $ ( sum(actHerds(herds,"",feedRegime,tCur,m),1)
                                                                    $ p_feedReqPig.l(possHerds,feedRegime,feedAttr)),
               sqr( (p_feedReqPig(possHerds,feedRegime,feedAttr) - p_feedReqPig.scale(possHerds,feedRegime,feedAttr))
                                                                  /p_feedReqPig.scale(possHerds,feedRegime,feedAttr)))

     $$endif.p_feedReqPig

     $$ifthen.v_reqsCorr defined v_reqsCorr
         + sum( (possHerds,breeds) $ sum(actHerds(possHerds,breeds,feedRegime,tCur,m),1),
                   sqr ( (v_reqsCorr(possHerds,breeds,"ener") - 1)*10)
                +  sqr ( (v_reqsCorr(possHerds,breeds,"prot") - 1)*10)
                +  sqr ( (v_reqsCorr(possHerds,breeds,"rest") - 1)*10)
               )
     $$endif.v_reqsCorr

     + sum( (crops,till,intens,m)  $ (sum(c_p_t_i(curCrops(crops),plot,till,intens),1)
                                          $ p_cropLab.l(crops,till,intens,m)
                                          $ ( p_cropLab.scale(crops,till,intens,m) ne 1)),
              sqr( (p_cropLab(crops,till,intens,m) - p_cropLab.scale(crops,till,intens,m))
                                                     /p_cropLab.scale(crops,till,intens,m))
         )

    }
    /
    [   sum(arabCrops(curCrops) $ p_calibTarget(curCrops,""),1)
        $$ifthen.herds defined v_sumHerd
          + sum( (possHerds(sumHerds),breeds) $ p_calibTarget(sumHerds,breeds),1)
        $$endif.herds

    ] + v_fitLevls/100;

   e_fitLevls .. v_fitLevls *0.01


    =e=
    {
      [ sum( (arabCrops(curCrops)) $ (p_calibTarget(curCrops,"") gt eps),
            sqr( sum((curSys,t_n(tCur,nCur)),v_sumCrop(curCrops,curSys,tCur,nCur)*p_probN(ncur))/card(tCur) - p_calibTarget(curCrops,"")*p_nArabLand)/(p_calibTarget(curCrops,"")*p_nArabLand))
        /(sum( (arabCrops(curCrops),t_n(tCur,nCur))  $ p_calibTarget(curCrops,""),p_probN(ncur))/card(tCur)+0.001)] * 100

     $$ifthen.herds defined v_sumHerd

     + [ sum( (possHerds(sumHerds),breeds) $ p_calibTarget(sumHerds,breeds),
            sqr( sum(t_n(tCur,nCur), v_sumHerd(sumHerds,breeds,tCur,%nCur%)*p_probN(ncur))/card(tCur) - p_calibTarget(sumHerds,breeds))/p_calibTarget(sumHerds,breeds))
        /(sum( (possHerds(sumHerds),breeds,t_n(tCur,nCur)) $ p_calibTarget(sumHerds,breeds),p_probN(ncur))/card(tCur)+0.001)] * 100

     $$endif.herds
    }
    /
    [   sum(arabCrops(curCrops) $ p_calibTarget(curCrops,""),1)
        $$ifthen.herds defined v_sumHerd
          + sum( (possHerds(sumHerds),breeds) $ p_calibTarget(sumHerds,breeds),1)
        $$endif.herds
    ]

    ;

   model m_bilevel / e_fit,e_fitLevls,e_objeLimitLow,e_objeLimitUpp,m_farm /;
   option dNLP=CONOPT4;
   option MPEC=nlpec;
   m_bilevel.solprint  = 1;
   m_bilevel.limRow    = 0;
   m_bilevel.limCol    = 0;
   m_bilevel.optfile   = 1;
   m_bilevel.solvelink = 5;
   m_bilevel.holdfixed = 1;
   m_bilevel.reslim    = 15  * 60 * m_farm.numEqu/7000;
   m_bilevel.iterlim   = 10000;

*
*  --- export current levels and bounds of binaries to GDX container
*
   execute_unload "%gams.scrdir%binaries1.gdx"
   $$include "%gams.scrdir%binaries.gms";
   ;
*
* --- use embedded Phyton code to overwrite GDX file
*     such that all binaries are fixed to current solution (lower=upper=level)
*
   embeddedCode Python:
   db = gams.ws.add_database_from_gdx(r'%gams.scrdir%binaries1.gdx')
   for s in db:
     if (type(s) == GamsVariable) and (s.vartype in [VarType.Binary, VarType.Integer,
                                                     VarType.SOS1, VarType.SOS2,
                                                     VarType.SemiCont, VarType.SemiInt]):
       for r in s:
           r.lower = round(r.level)
           r.upper = round(r.level)
   db.export(r'%gams.scrdir%binaries.gdx')
   endEmbeddedCode
*
*  --- load the fixed binary levels
*
   execute_load "%gams.scrdir%binaries.gdx"
   $$include "%gams.scrdir%binaries.gms";
   ;
   m_farm.savepoint = 1;
   $$ifi     %useMIP%==on   solve m_farm using %MIP%  maximizing v_obje;
   $$ifi not %useMIP%==on   solve m_farm using %RMIP% maximizing v_obje;
   $$ifi "%stochProg%"=="true" $include 'model/copy_stoch.gms'

$onecho  > "%emp.info%"
bilevel v_fit v_fitLevls
$offecho

   embeddedCode Python:

     def fractionals(db):

       with open(r'%emp.info%', 'a') as f:

   #
   #  ---- get all variables from the GAMS data base
   #

           rlast = "dummyName"
           f.write("max v_obje\n")

           for s in db:
             if (type(s) == GamsVariable):

              if ( (s.vartype == 3) or (s.vartype == 5) ):
                 for r in s:
                   if ( (r.lower != r.upper) and (rlast != s.name) and (s.name != "v_obje")):
                     gams.printLog(" "+str(s.name)+" "+str(s.vartype))
                     f.write(str(s.name)+"\n")
                     rlast = s.name

           for s in db:
             if (type(s) == GamsEquation):
                 for r in s:
                   if ( (rlast != s.name) and (s.name != "v_obje")):
                     gams.printLog(" "+str(s.name))
                     f.write(str(s.name)+"\n")
                     rlast = s.name

           f.closed

       return 0

     rc = fractionals(gams.ws.add_database_from_gdx(r'%gams.wdir%m_farm_p.gdx'))

   endEmbeddedCode
*
*  --- quite wide bounds on calibration targets (crops and summary herds)
*
   v_sumCrop.lo(curCrops,curSys,t_n(tCur,nCur)) $ (arabCrops(curCrops) $ p_calibTarget(curCrops,""))
     =   p_calibTarget(curCrops,"") * p_nArabLand * 0.1;

   v_sumCrop.up(curCrops,curSys,t_n(tCur,nCur)) $ (arabCrops(curCrops) $ p_calibTarget(curCrops,""))
     =   inf;

   v_saleQuant.up(prodsYearly,curSys,t_n(tCur,nCur)) $ (v_saleQuant.up(prodsYearly,curSys,tCur,nCur) ne 0) = inf;
   v_prods.up(prodsYearly,t_n(tCur,nCur))            $ (v_prods.up(prodsYearly,tCur,nCur) ne 0)            = inf;


   $$ifthen.herds defined v_sumHerd
      v_sumHerd.lo(sumHerds,breeds,t_n(tCur,nCur)) $ p_calibTarget(sumHerds,breeds)
          = p_calibTarget(sumHerds,breeds) * 0.1;

      v_sumHerd.up(sumHerds,breeds,t_n(tCur,nCur)) $ p_calibTarget(sumHerds,breeds)
          = inf;

   $$endif.herds

   v_costQuant.lo(crops,curInputs) $ v_costQuant.l(crops,curInputs) = (1 - %costCalib%/100);
   v_costQuant.up(crops,curInputs) $ v_costQuant.l(crops,curInputs) = (1 + %costCalib%/100);
*
*  --- bounds and mode of uncertain parameter
*
   p_vCostC.scale(crops,till,intens,t)  $ sum(c_p_t_i(curCrops(crops),plot,till,intens),1)
    = p_vCostC.l(crops,till,intens,t);

   p_vCostC.up(crops,till,intens,t) $ sum(c_p_t_i(curCrops(crops),plot,till,intens),1) = p_vCostC.l(crops,till,intens,t)*(1 + %costCalib%/100);
   p_vCostC.lo(crops,till,intens,t) $ sum(c_p_t_i(curCrops(crops),plot,till,intens),1) = p_vCostC.l(crops,till,intens,t)*(1 - %costCalib%/100);

   $$ifthen.p_vCost defined p_vCost

     p_vCost.scale(possHerds,breeds,t) $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1)
       = p_vCost.l(possHerds,breeds,t);
     p_vCost.up(possHerds,breeds,t) $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1)
       = p_vCost.l(possHerds,breeds,t) * (1 + %costCalib%/100);
     p_vCost.lo(possHerds,breeds,t) $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1)
       = p_vCost.l(possHerds,breeds,t) * (1 - %costCalib%/100);
   $$endif.p_vCost

   $$ifthen.herds defined v_sumHerd
      p_herdLab.scale(sumHerds,feedRegime,m) $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1)
        = p_herdLab.l(sumHerds,feedRegime,m) $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1);
      p_herdLab.lo(sumHerds,feedRegime,m) $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1)
       = p_herdLab.l(sumHerds,feedRegime,m) * (1 - %labCalib%/100);
      p_herdLab.up(sumHerds,feedRegime,m) $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1)
       = p_herdLab.l(sumHerds,feedRegime,m) * (1 + %labCalib%/100);
   $$endif.herds

   p_cropLab.scale(crops,till,intens,m) $ sum(c_p_t_i(curCrops(crops),plot,till,intens),1)
    = p_cropLab.l(crops,till,intens,m);
   p_cropLab.lo(crops,till,intens,m) $ sum(c_p_t_i(curCrops(crops),plot,till,intens),1)
    = p_cropLab.l(crops,till,intens,m) * (1 - %labCalib%/100);
   p_cropLab.up(crops,till,intens,m) $ sum(c_p_t_i(curCrops(crops),plot,till,intens),1)
    = p_cropLab.l(crops,till,intens,m) * (1 + %labCalib%/100);


   p_price.lo(curProds,sys,t)    $ p_price.l(curProds,sys,t) = p_price.l(curProds,sys,t) * (1 - %outputPriceCalib%/100);
   p_price.up(curProds,sys,t)    $ p_price.l(curProds,sys,t) = p_price.l(curProds,sys,t) * (1 + %outputPriceCalib%/100);
   p_vPriceInv.lo(invTypes) = (1 - %inputPriceCalib%/100);
   p_vPriceInv.up(invTypes) = (1 + %inputPriceCalib%/100);

   p_inputPrice.lo(curInputs,sys,t)    $ p_inputPrice.l(curInputs,sys,t) = p_inputPrice.l(curInputs,sys,t) * (1 - %inputPriceCalib%/100);
   p_inputPrice.up(curInputs,sys,t)    $ p_inputPrice.l(curInputs,sys,t) = p_inputPrice.l(curInputs,sys,t) * (1 + %inputPriceCalib%/100);

   $$ifthen.v_reqsCorr defined v_reqsCorr
     v_reqsCorr.up(herds,breeds,"ener")  $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1) = (1 + %reqCalib%/100);
     v_reqsCorr.up(herds,breeds,"prot")  $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1) = (1 + %reqCalib%/100);
*    v_reqsCorr.up(herds,breeds,"rest")  $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1) = (1 + %reqCalib%/100);
     v_reqsCorr.lo(herds,breeds,"ener")  $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1) = (1 - %reqCalib%/100);
     v_reqsCorr.lo(herds,breeds,"prot")  $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1) = (1 - %reqCalib%/100);
*    v_reqsCorr.lo(herds,breeds,"rest")  $ sum(actHerds(possHerds,breeds,feedRegime,t,m),1) = (1 - %reqCalib%/100);
   $$endif.v_reqsCorr

   $$ifthen.p_feedReqPig defined p_feedReqPig

      p_feedReqPig.up(possHerds,feedRegime,feedAttr) $ (sum(actHerds(herds,"",feedRegime,tCur,m),1)
                                                         $ p_feedReqPig.l(possHerds,feedRegime,feedAttr))
       = p_feedReqPig.l(possHerds,feedRegime,feedAttr) * (1 + %reqCalib%/100* sign(p_feedReqPig.l(possHerds,feedRegime,feedAttr)));

      p_feedReqPig.lo(possHerds,feedRegime,feedAttr) $ (sum(actHerds(herds,"",feedRegime,tCur,m),1)
                                                         $ p_feedReqPig.l(possHerds,feedRegime,feedAttr))
       = p_feedReqPig.l(possHerds,feedRegime,feedAttr) * (1 - %reqCalib%/100* sign(p_feedReqPig.l(possHerds,feedRegime,feedAttr)));

      p_feedReqPig.scale(possHerds,feedRegime,feedAttr) $ (sum(actHerds(herds,"",feedRegime,tCur,m),1)
                                                         $ p_feedReqPig.l(possHerds,feedRegime,feedAttr))
         = p_feedReqPig.l(possHerds,feedRegime,feedAttr);

   $$endif.p_feedReqPig

   p_OCoeffC.scale(curCrops,soil,till,intens,prodsYearly,t) $ sum(c_p_t_i(curCrops(crops),plot,till,intens),1)
      = p_OCoeffC.l(curCrops,soil,till,intens,prodsYearly,t);
   p_OCoeffC.lo(curCrops,soil,till,intens,prodsYearly,t) $ sum(c_p_t_i(curCrops(crops),plot,till,intens),p_OCoeffC.l(curCrops,soil,till,intens,prodsYearly,t))
      = p_OCoeffC.l(curCrops,soil,till,intens,prodsYearly,t) * (1 - %yieldCalib%/100);
   p_OCoeffC.up(curCrops,soil,till,intens,prodsYearly,t) $ sum(c_p_t_i(curCrops(crops),plot,till,intens),p_OCoeffC.l(curCrops,soil,till,intens,prodsYearly,t))
      = p_OCoeffC.l(curCrops,soil,till,intens,prodsYearly,t) * (1 + %yieldCalib%/100);

   $$iftheni.gras defined p_oCoeffM

      p_OCoeffM.scale(grassCrops(curCrops),soil,till,intens,curProds,m,t) $ sum(c_p_t_i(curCrops,plot,till,intens),p_OCoeffM.l(curCrops,soil,till,intens,curProds,m,t))
         = p_OCoeffM.l(curCrops,soil,till,intens,curProds,m,t);

      p_OCoeffM.lo(grassCrops(curCrops),soil,till,intens,curProds,m,t) $ sum(c_p_t_i(curCrops,plot,till,intens),p_OCoeffM.l(curCrops,soil,till,intens,curProds,m,t))
         = p_OCoeffM.l(curCrops,soil,till,intens,curProds,m,t) *(1 - %yieldCalib%/100);

      p_OCoeffM.up(grassCrops(curCrops),soil,till,intens,curProds,m,t) $ sum(c_p_t_i(curCrops,plot,till,intens),p_OCoeffM.l(curCrops,soil,till,intens,curProds,m,t))
         = p_OCoeffM.l(curCrops,soil,till,intens,curProds,m,t) * (1 + %yieldCalib%/100);

   $$endif.gras

*
*  --- solve bi-level problem
*
   $$batinclude 'util/title.gms' "'%titlePrefix% Solve bi-level calibration framework'"
   m_bilevel.solprint = 1;
   solve m_bilevel using emp minimizing v_fit;
   $$batinclude 'calib\calibReport' 'bilevel' yes
*
   p_calibReport("fit%","","","bilevel")      = v_fit.l;
   p_calibReport("fitLevls%","","","bilevel") = v_fitLevls.l;
   p_calibReport("v_obje","","","bilevel")  = v_obje.l;
*
*  --- fix parameters (defined as varibles) to results of bi-level estimation
*
   $$ifthen.v_reqsCorr defined v_reqsCorr
      p_reqsPhaseMonths(possHerds,breeds,feedRegime,reqsPhase,reqs)
       = p_reqsPhaseMonths(possHerds,breeds,feedRegime,reqsPhase,reqs)
                            *(   v_reqsCorr(possHerds,breeds,"Ener") $ (sameas(reqs,"NEL") or sameas(reqs,"ME"))
                               + v_reqsCorr(possHerds,breeds,"Prot") $ (sameas(reqs,"XP")  or sameas(reqs,"nXP"))
                               + v_reqsCorr(possHerds,breeds,"Rest") $ (not (    sameas(reqs,"XP")  or sameas(reqs,"nXP")
                                                                             or sameas(reqs,"NEL") or sameas(reqs,"ME"))));
   $$endif.v_reqsCorr

   p_costQuant(curCrops(crops),till,intens,curInputs) $ p_costQuant(crops,till,intens,curInputs)
      =  v_costQuant.l(crops,curInputs) * p_costQuant(crops,till,intens,curInputs);

   $$batinclude 'calib\calib.gms' fixPars
*
*  --- export updated coefficients and bounds for binaries
*
   execute_unload '%resdir%/calib/%calibFile%.gdx' p_vCostC,p_oCoeffC,p_oCoeffM,
      $$ifi defined p_reqsPhaseMonths    p_reqsPhaseMonths
      $$ifi defined p_herdLab            p_herdLab
      $$ifi defined p_feedReqPig         p_feedReqPig
      $$ifi defined p_vCost              p_vCost
      p_price,p_costQuant,p_inputPrice,p_cropLab,p_vPriceInv,
      c_p_t_i,curCrops,curProds,curInputs,curFeeds,curMachines,curInv,possActs
      $$ifi defined herds actHerds,possHerds
      $$ifi defined actherdsF      actherdsf
      $$ifi defined v_feeding      v_feeding.up,v_feedUse.up
      $$ifi defined v_manDist      v_manDist.up
                                   v_syntDist.up
    $$include '%gams.scrdir%binaries.gms'
   ;
*
*  --- test solve at the results of the bi-level estimation
*
   v_sumCrop.lo(curCrops,curSys,t_n(tCur,nCur)) $ (arabCrops(curCrops) $ p_calibTarget(curCrops,"")) = v_sumCrop.l(curCrops,curSys,tCur,nCur)*0.999;
   v_sumCrop.up(curCrops,curSys,t_n(tCur,nCur)) $ (arabCrops(curCrops) $ p_calibTarget(curCrops,"")) = v_sumCrop.l(curCrops,curSys,tCur,nCur)*1.001;
   solve m_farm using %RMIP% maximizing v_obje;
   $$ifi "%stochProg%"=="true" $include 'model/copy_stoch.gms'

   p_calibReport("crops",curCrops,"duals","fixedBin")      $ p_calibReport("crops",curCrops,"ha","target")
       = sum((curSys,t_n(tCur,nCur)), v_sumCrop.m(curCrops,curSys,tCur,nCur)*p_probN(nCur)*v_sumCrop.l(curCrops,curSys,tCur,nCur))
         /sum((curSys,t_n(tCur,nCur)),p_probN(nCur)*v_sumCrop.l(curCrops,curSys,tCur,nCur));

   option kill=v_sumCrop.lo,kill=v_sumCrop.up;
   $$ifi defined v_sumHerd option kill=v_sumHerd.lo,kill=v_sumHerd.up;
*
   $$batinclude 'util/title.gms' "'%titlePrefix% Solve model at calibrated parameters and fixed binaries'"
   solve m_farm using %MIP% maximizing v_obje;
   $$ifi "%stochProg%"=="true" $include 'model/copy_stoch.gms'
   $$batinclude 'calib\calibReport' 'fixedBin' yes
*
*  -- remove prices from report which are not changed by bi-level estimator
*
   p_calibReport("price",curInputs,sys,calibItems)  $ (not p_calibReport("price",curInputs,sys,"bilevel")) = 0;
   p_calibReport("price",curProds,sys,calibItems)   $ (not p_calibReport("price",curProds,sys,"bilevel"))  = 0;

*
*  --- load the levels and bounds of the binaries from the solve before the estimation
*      and rerun model
*
   execute_load "%gams.scrdir%binaries1.gdx"
     $$include "%gams.scrdir%binaries.gms";
   ;

   $$batinclude 'util/title.gms' "'%titlePrefix% Solve model at calibrated parameters and free binaries'"
   solve m_farm using %MIP% maximizing v_obje;
   $$batinclude 'calib\calibReport' 'final' yes

   option p_calibReport:2:3:1;
   display p_calibReport;
   execute_unload "%gams.scrdir%calib.gdx" p_calibReport;

   $$ifi not exist '%resdir%/calib/farm_empty.gdx' execute_unload '%resdir%/calib/farm_empty.gdx';

$endif.mode
