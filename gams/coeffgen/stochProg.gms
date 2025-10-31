********************************************************************************
$ontext

   FARMDYN project

   GAMS file : stochprog.gs
   @purpose  : Introduce stochastic programming information (scenarios,
               node relation)
   @author   : W.Britz
   @date     : 19.02.16
   @since    :
   @refDoc   :
   @seeAlso  : model/templ_decl.gms, model/templ.gms
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************

$setglobal randVars %stochPrices%_%stochYields%
$ifi "%randVars%"=="false_false" $abort "Choose at least one source of risk"

   scalar mrp / 0 /;
   set tnum / t1*t%nt% /;
   set tn(tnum,n);
   option kill=randProbs;
   option kill=p_randVar;
   set randVars(*);
   option kill=randVars;

$iftheni.stochYields "%stochYields%"=="true"
*
*    --- define distributions for crops, current, a multi-variate normal is used

*
*  -- all main crops' and on demand grasland's yields are stochastic
*
   randVars(curCrops)     = YES;
   randVars(gras)         = no;
   randVars(past)         = no;
   randVars("idle")       = no;
   randVars("idleGras")   = no;
   randVars(curCrops) $ (not mainCrops(curCrops)) = no;
   $$ifi "%stochGrasYields%"=="true" randVars("gras") $ (card(gras) or card(past)) = YES;
*
*  --- generate a second set of random vars which relate to insured crop yields
*
   set cropsIns(*),cropsIns_crops(*,*);
   $$onEmbeddedCode Python:
       cropsIns = []
       cropsIns_crops = []
       labels =  gams.get('crops')
       for s in labels:
          cropsIns.append(s+"_ins")
          cropsIns_crops.append((s+"_ins",s))
       gams.set("cropsIns",cropsIns)
       gams.set("cropsIns_crops",cropsIns_crops)

   $$offEmbeddedCode cropsIns cropsIns_crops

$iftheni.cropYield "%useYieldTimeSeries%"=="false"
*
*  --- cov matrix of crop yields from user interface
*
   parameter p_cov(*,*);
   alias(randVars,randVars1);
   p_cov(randVars,randVars1) = %crossYieldVar%;
   p_cov(randVars,randVars)  = %ownYieldVar%;

   $$ifthene.basisRisk %baseRiskCov%<>1

*
*     --- add insured crop yields (= basis risk) to random variables
*
      randvars(cropsIns) $ sum(cropsIns_crops(cropsIns,crops) $ randVars(Crops),1) = YES;
      p_cov(cropsIns,cropsIns) $ randVars(cropsIns) = %ownYieldVar%;


      alias (cropsIns,cropsIns1);

      p_cov(cropsIns,cropsIns1) = sum( (randVars,randVars1) $ (cropsIns_crops(cropsIns,randVars) $ cropsIns_crops(cropsIns1,randVars1)),
          p_cov(randVars,randVars1));

      p_cov(cropsIns,randVars) $ sum(sameas(crops,randVars),1)
         = sum( randVars1 $ cropsIns_crops(cropsIns,randVars1),p_cov(randVars,randVars1)) * %baseRiskCov%;

      p_cov(randVars,cropsIns) $ sum(sameas(crops,randVars),1)
       = sum( randVars1 $ cropsIns_crops(cropsIns,randVars1),  p_cov(randVars,randVars1)) * %baseRiskCov%;
*
      p_cov(randVars,randVars1) = ( p_cov(randVars,randVars1) + p_cov(randVars1,randVars) )/2;

   $$endif.basisRisk


   mrp = card(randVars);

   parameter p_mean(*)  "Mean, normalized to unity"
             p_mvn(*,*) "Draws from multivariate normal";
   p_mean(randVars) = 1.0;

   EmbeddedCode Python:
     import numpy as np

     from numpy.random import default_rng
   #
   # --- set static seed to avoid that repeated call produce different random sequences
   #
     nr = default_rng(0)
   #
   # --- set up maps from curX (= index space of dependents) and i to index position 0..|curX|-1 and 0..|i|-1 (and back)
   #
     n2u_d1 = np.array(list(gams.get('randVars', keyType=KeyType.INT, valueFormat=ValueFormat.SKIP)),dtype=int)
     u2n_d1 = np.zeros(n2u_d1[-1]-n2u_d1[0]+1, dtype=int)
     for n,u in enumerate(n2u_d1):
       u2n_d1[u-n2u_d1[0]] = n
   #
   # --- set up maps from curX (= index space of dependents) and i to index position 0..|curX|-1 and 0..|i|-1 (and back)
   #
     n2u_d2 = np.array(list(gams.get('n', keyType=KeyType.INT, valueFormat=ValueFormat.SKIP)),dtype=int)
     u2n_d2 = np.zeros(n2u_d2[-1]-n2u_d2[0]+1, dtype=int)
     for n,u in enumerate(n2u_d2):
       u2n_d2[u-n2u_d2[0]] = n
   #
   # --- generate an empty matrix of zeros to host the covariance matrix
   #
     nRandVars =len(n2u_d1)
     cov = np.zeros(shape=(nRandVars,nRandVars))

     for r in gams.get('p_cov', keyType=KeyType.INT, keyFormat=KeyFormat.FLAT):
        cov[u2n_d1[r[1]-n2u_d1[0]],u2n_d1[r[0]-n2u_d1[0]]] = r[2]
   #
   # --- get the mean from GAMS
   #
     mu  = np.array(list(gams.get('p_mean', keyFormat=KeyFormat.SKIP)))
   #
   # --- draw from multi-variate normal
   #
     mvn = nr.multivariate_normal(mu, cov, size=%nNode%, method='cholesky')
   #
   # --- map to list of tuples and store in GAMS parameter p_mvn. Manual assignement from linear index to draw and random variable
   #
     gams.set('p_mvn', [(n2u_d1[int(r[0]%len(n2u_d1))],n2u_d2[int(r[0]/len(n2u_d1))],float(r[1])) for r in enumerate( mvn.flatten() ) ], mapKeys=int)

   PauseEmbeddedCode p_mvn
*
*  --- make sure drawn mean is unity
*
   p_randVar(randVars,"n1") = 0;
   p_randVar(randVars,n)    = min(1.25,sqrt(max(0.05,p_mvn(randVars,n))));
   p_mean(randVars)         = sum(n, p_randVar(randVars,n) )/card(n);

   p_randVar(randVars,n)    = p_randVar(randVars,n)/p_mean(randVars);

   p_randVar(randVars,"n1") = 1;
   p_mean(randVars)         = 1;
$else.cropYield


   $$include '..\dat\%CropYieldFile%.gms'

   parameter p_yieldStat;
   p_yieldStat(curcrops,"mean") $ sum(n $ p_yield(n,curcrops),1)
    = sum(n, p_yield(n,curcrops))/sum(n $ p_yield(n,curcrops),1);

   p_yield(n,curCrops) $ ((n.pos gt 20) and  p_yieldStat(curcrops,"mean") and (n.pos le %nLeaves%))
      = sum(n1 $ (n1.pos+20 eq n.pos), p_yield(n1,curCrops) + uniform(-0.01,0.01));
   p_yieldStat(curcrops,"mean") $ sum(n $ p_yield(n,curcrops),1)
    = sum(n, p_yield(n,curcrops))/sum(n $ p_yield(n,curcrops),1);

   set nnCur(n);nncur(n) $ sum(curCrops, p_yield(n,curCrops)) = YES;

   p_Yield(nnCur,"t") = nnCur.pos;
   p_yieldStat("t","mean") = sum(nnCur,p_yield(nnCur,"t"))/card(nnCur);

   p_yieldStat(curcrops,"xx") = sum(nnCur $  p_yield(nnCur,curcrops), sqr(p_yield(nnCur,"t")-p_yieldStat("t","mean")));
   p_yieldStat(curcrops,"xy") = sum(nnCur $  p_yield(nnCur,curcrops), (p_yield(nnCur,curcrops)-p_yieldStat(curcrops,"mean"))*(p_yield(nnCur,"t")-p_yieldStat("t","mean")));

   p_yieldStat(curcrops,"b") $  p_yieldStat(curcrops,"xx")   = p_yieldStat(curcrops,"xy")/p_yieldStat(curcrops,"xx");
   p_yieldStat(curcrops,"a") $  p_yieldStat(curcrops,"xx")   = p_yieldStat(curcrops,"mean") - p_yieldStat(curcrops,"b")*p_yieldStat("t","mean");

   parameter p_testR(crops,n,*);
   p_testR(curCrops,n,"obs") = p_yield(n,curCrops);
   p_testR(curCrops,n,"est") $ p_yield(n,curCrops) = p_yieldStat(curcrops,"a") + p_yieldStat(curcrops,"b")* p_yield(n,"t");
   p_testR(curCrops,n,"err") $ p_yield(n,curCrops) = p_testR(curCrops,n,"obs")-p_testR(curCrops,n,"est");

   p_cropYieldInt(curCrops,"conv") $ p_yieldStat(curcrops,"mean") = [p_yieldStat(curcrops,"a") + p_yieldStat(curcrops,"b") * smax(n,p_yield(n,"t"))]/10;

   p_randVar(curCrops,n) $ p_yieldStat(curcrops,"mean")  = ( p_cropYieldInt(curCrops,"conv") +  p_testR(curCrops,n,"err")/10)/ p_cropYieldInt(curCrops,"conv");
   p_randVar(curCrops,n) $ (Not nnCur(n)) = 0;
   tn(tnum,n) $ (tnum.pos eq %nt%) = YES;

$endif.cropYield
$$endif.stochYields

   $$iftheni.stochPrices "%stochPrices%"=="true"
*
*      ---- define which products are subject to randomization
*           (attention: order is important, e.g. if dariy herd is on, crop outputs are deterministic)
*
      $$iftheni.stochOPrices "%StochPricesOutputs%"=="Core branch outputs"
*
         $$ifi "%farmBranchArable%" == "on"   randProbs(set_crop_prods)  = yes;
         $$ifi "%pigHerd%"          == "true" randProbs(set_pig_prods)   = yes;
         $$ifi "%farmBranchDairy%"  == "on"   randProbs(set_dairy_prods) = yes;
         $$ifi "%farmBranchBeef%"   == "on"   randProbs(allBeef_outputs) = yes;

      $$endif.stochOPrices

      $$iftheni.stochIPrices "%StochPricesInputs%"=="Feed"

         randProbs(feeds) = YES;

      $$elseif.stochIPrices "%StochPricesInputs%"=="Inputs"

         randProbs(inputs) = YES;

      $$elseif.stochIPrices "%StochPricesInputs%"=="Wages"

         randProbs("hourly") = YES;
         randProbs(workType) = YES;

      $$endif.stochIprices

      $$setglobal randPrices %StochPricesOutputs%_%StochPricesInputs%
      $$if "%randPrices%"=="None_None" abort "No random price variable seleceted for stochastic programming";

      $$ifi not "%StochPricesOutputs%"=="None" mrp  = mrp+1;
      $$ifi not "%StochPricesInputs%"=="None"  mrp  = mrp+1;
*
*     --- generate two MRP processes
*
      execute "del %scrdir%\\mrp.gdx";
      set dummyPrice / price /;

      set mrpPrice / P1,P2 /;

      $$ifi not "%StochPricesOutputs%"=="None" $setglobal stochO true
      $$ifi not "%StochPricesInputs%"=="None"  $setglobal stochI true

      $$iftheni.randPrices "%stochO%_%stochI%"=="true_true"
*
*        --- both output and input price levels are stochastic: generate two mean-reverting processing with zero co-variance
*
         randVars("priceOutputs") = YES;
         randVars("priceInputs") = YES;
         execute "java -Djava.library.path=..\gui\jars -jar ..\gui\mrpfan.jar %nt% %nOriScen% %scrdir%\\mrp.gdx 1 1 %varOutputs% %lambdaOutputs% 1 1 %varInputs% %lambdaInputs% 0.0 2>1"
         execute_loadpoint "%scrdir%\\mrp.gdx" p_randVar,tn,anc;
         p_randVar("priceOutputs",n) = p_randVar("P1",n);
         p_randVar("priceInputs",n)  = p_randVar("P2",n);

      $$elseifi.randPrices not "%StochPricesOutputs%"=="None"
*
*        --- MRP pross for output price level according to desired variance and speed of revision
*
         randVars("priceOutputs") = YES;
         execute "java -Djava.library.path=..\gui\jars -jar ..\gui\mrpfan.jar %nt% %nOriScen% %scrdir%\\mrp.gdx 1 1 %varOutputs% %lambdaOutputs% 2>1"
         execute_loadpoint "%scrdir%\\mrp.gdx" p_randVar,tn,anc;
         p_randVar("priceOutputs",n) = p_randVar("P1",n);

      $$elseifi.randPrices not "%StochPricesInputs%"=="None"
*
*        --- MRP pross for input price level according to desired variance and speed of revision
*
         randVars("priceInputs") = YES;
         execute "java -Djava.library.path=..\gui\jars -jar ..\gui\mrpfan.jar %nt% %nOriScen% %scrdir%\\mrp.gdx 1 1 %varInputs% %lambdaInputs% 2>1"
         execute_loadpoint "%scrdir%\\mrp.gdx" p_randVar,tn,anc;
         p_randVar("priceInputs",n) = p_randVar("P1",n);

      $$endif.randPrices
*
*     --- remove the helper random variables P1 and P2 used by Java
*
      p_randVar("P1",n)       = 0;
      p_randVar("P2",n)       = 0;

   $$else.stochPrices
*
*     --- The java process in case of stochastic yield only generates the set which connect the nodes to time t_n
*         and the ancestor set anc
*
      execute "java -Djava.library.path=..\gui\jars -jar ..\gui\mrpfan.jar %nt% %nOriScen% %scrdir%\\mrp.gdx 1 1 %varInputs% %lambdaInputs% 2>1"
      execute_loadpoint "%scrdir%\\mrp.gdx" tn,anc;

   $$endif.stochPrices

   nCur(n) = YES;



$iftheni.compstat "%dynamics%" == "Comparative-static"
*
* --- remove all years / node betwen root and final leaves (we are simulating on year only)
*
  tn(tnum,n) $ (not ((tnum.pos eq 1) or (tnum.pos eq card(tnum)))) =  NO;
  option kill=anc;
  option kill=nCur;
  nCur(n) $ sum(tn(tnum,n),1) = YES;
  nCur(n) $ (n.pos le %nLeaves%) = YES;
  anc(nCur,"n1") = YES;
  anc("n1","n1") = no;
  p_randVar(randVars,n) $ (not nCur(n)) = no;

$endif.compstat

$iftheni.cropYield "%useYieldTimeSeries%"=="false"
*
*  --- all outcomes are equally likely
*
   p_probN(nCur)   = 1/%nOriScen%;
*
*  --- and share the root node
*
   p_probN('n1') = 1;
*
*  --- pass the information abort the desired numnber of final leaves to SCENRED2
*      via option file
*
   $$call echo red_num_leaves %nLeaves% > sr2Test.opt
*
*  --- results from SCENRED: reduced ancestor matrix and updated probabilities for the reduced
*      node set
*
   set ancRed(n,n1);
   parameter p_probRed(n);

   $$setglobal sr2prefix test
   $$setglobal treeGen on

   $$iftheni.runSR2 %treeGen%==on
*
*     --- scenario tree construction from fan
*
      $$libinclude scenRed2
*
*     --- information for SCENRED: option file and options from interface
*
      ScenredParms('sroption')       = 1;
      ScenredParms('visual_red')     = 1;
*
*     --- run scenario tree reduction
*
      $$libinclude runScenRed2 %sr2Prefix% tree_con nCur anc p_probN ancRed p_probRed p_randVar

   $$endif.runSr2
*
*  --- load information from ScenRed2
*
   execute_load 'sr2%sr2Prefix%_out.gdx' ancRed=red_ancestor,p_probRed=red_prob;

$else.cropYield

   parameter p_probRed(n);
   p_probN(n)   $ (n.pos le %nLeaves%)  = 1/%nLeaves%;
   p_probRed(n) $ (n.pos le %nLeaves%)  = 1/%nLeaves%;

$endif.cropYield

*  --- actives nodes are those which have an updated probability
*
   option kill=nCur;
   nCur(n) $ p_probRed(n) = YES;
*
*  --- cleanse link between time points and nodes from unused nodes
*
   tn(tnum,n) $ (not nCur(n)) = no;
*
*  --- map into year set used by model
*
   $$iftheni.dyn "%dynamics%" == "Comparative-static"

      option kill=t_n;

      t_n(tCur,nCur) $ sum(tn(tnum,nCur) $ (tnum.pos eq %nt%),1) = YES;

      alias(nCur,nCur1);
      nCur(nCur1) $ (not sum(t_n(tCur,nCur1),1)) = no;

      p_probN(nCur) = p_probN(nCur) * 1 / sum(nCur1, p_probN(nCur1));

      option kill=anc;
      sameScen(nCur,nCur) = YES;
      anc(nCur,nCur)      = YES;
      isNodeBefore(nCur,nCur) = YES;
      leaves(nCur) $ t_n("%lastYearCalc%",nCur) = YES;

      firstLeave(nCur) $ (nCur.pos eq 1) = YES;

      $$setglobal nt 1

   $$else.dyn

     t_n(tCur,nCur) $ sum(tn(tnum,nCur) $ (tnum.pos eq tCur.pos),1) = YES;
     t_n(tBefore,"n1") = YES;
*
*    --- take over cleansed ancestor matrix and probabilities
*
     option kill=anc;
     anc(nCur,nCur1) = ancRed(nCur,nCur1);
     anc("n1","n1")    = YES;
     p_probN(n)  = p_probRed(n);
*
*    --- build cross-set with preceeding nodes for each node
*
     isNodeBefore(nCur,nCur1) $ anc(nCur,nCur1) = YES;

     isNodeBefore(nCur,nCur)= YES;

     loop(tCur,
        loop(anc(nCur,nCur1),
          isNodeBefore(nCur,nCur2) $ isNodeBefore(nCur1,nCur2) = YES;
        );
     );

      sameScen(nCur,nCur1) $ (isNodeBefore(nCur,nCur1) or isNodeBefore(nCur1,nCur)) = YES;

      leaves(nCur) $ t_n("%lastYearCalc%",nCur) = YES;

   $$endif.dyn
   p_randVar(randVars,n) $ (not nCur(n)) = 0;
   p_probn(n) $ (not nCur(n)) = 0;


   parameter p_testIns(*,*,*),p_resIns;

   $$iftheni.stochYields "%stochYields%"=="true"

      parameter p_testIns,p_resIns;

      $$ifthen.cropIns "%cropInsurance%"=="true"
*
           randvars(cropsIns) $ sum(cropsIns_crops(cropsIns,crops) $ randVars(Crops),1) = YES;
           p_randVar(cropsIns,nCur) $ (not p_randVar(cropsIns,nCur)) = sum(cropsIns_crops(cropsIns,crops),p_randVar(crops,nCur));
*
*         --- crop yield indemnities paid out in future nCur:
*             (Beware crop yield is a cost, negative value indicate a pay out from the insurance)
*
          p_cropIns(curCrops(crops),sys,t,nCur) $ p_randVar(crops,nCur)
            = -[
*
*               --- expected yield times expected prices
*
                p_cropYieldInt(crops,sys) * p_cropPrice(crops,sys)
*
*               --- relative difference to 1 (e.g. if randvar == 0.7, 30% are paid out)
*
                 * (1-sum(cropsIns_crops(cropsIns,curCrops),p_randVar(cropsIns,nCur)))
                       $ (sum(cropsIns_crops(cropsIns,curCrops),p_randVar(cropsIns,nCur)) le %nInsLevelCropYield%/100)];
*
          p_resIns(curCrops(crops),sys,"inDem",t,nCur) = -p_cropIns(crops,sys,t,nCur);
          p_resIns(curCrops(crops),sys,"damag",t,nCur) $ p_randVar(crops,nCur)
            = p_cropYieldInt(crops,sys) * p_cropPrice(crops,sys) * (p_randVar(crops,nCur)-1);
*
*         --- indemntities plus premium in each future
*
          p_cropIns(curCrops(crops),sys,t,nCur) $ (p_randVar(crops,nCur) $ sum(nCur1,p_cropIns(crops,sys,t,nCur1)*p_probN(nCur1)))
            =
*
*           --- pay out (zero if yield is above threshold)
*
            p_cropIns(crops,sys,t,nCur)
*
*              --- premium: expected sum of paid out indemnities plus x% transactions cost, plus 10 Euro per hectare
*
               - sum(nCur1,p_cropIns(crops,sys,t,nCur1)*p_probN(nCur1)) * (1 + %nCropsInsTransCost%/100) + 10;

          p_inputprice("cropIns",sys,t) = 1;

          p_resIns(curCrops(crops),sys,"yld",t,nCur) $ p_randVar(crops,nCur)
             =  p_cropYieldInt(crops,sys) * p_cropPrice(crops,sys) *  p_randVar(crops,nCur);

          p_resIns(curCrops(crops),sys,"cost",t,nCur) $ (p_randVar(crops,nCur) $  p_cropIns(crops,sys,t,nCur))
             = sum(nCur1,p_cropIns(crops,sys,t,nCur1)*p_probN(nCur1)) * (1 + %nCropsInsTransCost%/100) + 10;

          p_resIns(curCrops(crops),sys,"withIns",t,nCur) $ (p_randVar(crops,nCur) $  p_resIns(crops,sys,"cost",t,nCur)  )
           =   p_resIns(crops,sys,"damag",t,nCur)
             - p_resIns(crops,sys,"cost",t,nCur)
             + p_resIns(crops,sys,"inDem",t,nCur);

          p_testIns(crops,sys,t) = sum(nCur, p_cropIns(crops,sys,t,nCur) * p_probN(nCur));
          p_resIns(curCrops(crops),sys,"mWithIns",t,nCur) $ (p_randVar(crops,nCur) $  p_resIns(crops,sys,"cost",t,nCur)  )
                 = p_testIns(crops,sys,t);

*   execute_unload "test.gdx";
*   abort "test";


      $$else.cropIns

         option kill=p_cropIns,kill=p_testIns;

      $$endif.cropIns

      $$endif.stochYields
*
*  --- make sure that the expected mean is equal to unity for all random variables
*

   set dep  / t /;
   parameter p_stats(*,*);
   p_stats(randVars,"mean") = sum(nCur, p_probN(nCur) * p_randVar(randVars,nCur));

   $$iftheni.dyn "%dynamics%" == "Comparative-static"
      p_randVar(randVars,nCur) $  p_stats(randVars,"mean") = p_randVar(randVars,nCur)/ p_stats(randVars,"mean");
   $$endif.dyn
*
*  --- covariance
*
    alias(randVars,randVars1);
    p_stats(randVars,randVars1) = sum(nCur, p_probN(nCur) * (p_randVar(randVars,nCur)-p_stats(randVars,"mean") )*(p_randVar(randVars1,nCur)-p_stats(randVars,"mean") ));
*
*  --- skewness
*
   p_stats(randVars,"skew") = sum(nCur, p_probN(nCur) * power((p_randVar(randVars,nCur)-p_stats(randVars,"mean"))/sqrt(p_stats(randVars,randVars)),3));




   p_stats(randVars,"mean") = sum(nCur, p_probN(nCur) * p_randVar(randVars,nCur))/card(tCur);
   p_stats(randVars,"max")  = smax(nCur,p_randVar(randVars,nCur));
   p_stats(randVars,"min")  = smin(nCur,p_randVar(randVars,nCur));


   p_randVar(curCrops,nCur) $ (not randVars(curCrops)) = 1;
   p_randVar("gras",nCur)   $ (not randVars("gras")) = 1;
*
*   ---- value at risk is switched on
*
$iftheni.riskModel "%RiskModel%" == "Npv At Risk"

*
*   --- set quantile limit relative to simulated NPV
*
    p_npvAtRiskLim = %npvAtRiskLim%/100;
*
*   --- maximum percentage
*
    p_npvAtRiskmaxProb = %npvAtRiskmaxProb%/100;
    v_expShortFall.fx  = 0;

$elseifi.riskModel "%RiskModel%" == "MOTAD against NPV"

    p_negDevPen = %weightNegDev%/100;
    v_expShortFall.fx  = 0;


$elseifi.riskModel "%RiskModel%" == "MOTAD against target"

    p_npvAtRiskLim = %npvAtRiskLim%/100;
    p_negDevPen = %weightNegDev%/100;
    p_maxShortFall = -1;
    v_shortFall.lo(nCur) $ t_n("%lastYear%",nCur) = 0;


$elseifi.riskModel "%RiskModel%" == "Target-Motad"

    p_npvAtRiskLim = %npvAtRiskLim%/100;
    p_maxShortFall = %maxShortFall%/100;
    v_shortFall.lo(nCur) $ t_n("%lastYear%",nCur) = 0;

$elseifi.riskModel "%RiskModel%" == "Expected shortfall"

    p_npvAtRiskmaxProb = %npvAtRiskmaxProb%/100;
    p_expShortFall = 1;
    p_negDevPen = %weightNegDev%/100;
    p_npvAtRiskLim = 0;

$endif.riskModel

v_withDraw.lo(t_n(tCur,nCur)) = -inf;
v_hhsldIncome.lo(t_n(tCur,nCur)) = -inf;


$include 'util/kill_model1.gms'
