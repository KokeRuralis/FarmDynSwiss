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
*
* --- available field working days
*
$onmulti

*
*  -- these days relate to a 80% chance that the work is feasible
*     rf2 are light operation, rf3 are operations such as ploughing
*
   table  p_fieldWorkingDays(labReqLevl,labPeriod,climateZone,soilType)
*
*
*   page 250 KTBL 2012/2013
*

               cz1.l cz1.m cz1.h     cz2.l cz2.m cz2.h   cz3.l cz3.m cz3.h   cz4.l cz4.m cz4.h      cz5.l cz5.m cz5.h    cz6.l cz6.m cz6.h


   rf2.feb2      0    0     0          0    0     0        0    0     0        0    0     0           1    0     0         1    0     0
   rf2.mar1      0    0     0          0    0     0        0    0     0        0    0     0           1    0     0         1    0     0
   rf2.mar2      0    0     0          0    0     0        2    0     0        2    0     0           3    0     0         4    0     0
   rf2.apr1      1    0     0          2    0     0        4    0     0        7    1     0           7    1     0         8    2     0
   rf2.apr2      4    0     0          6    1     0        8    2     0        9    3     1          10    4     1        11    6     0
   rf2.may1      6    1     0          8    3     0        9    5     2       10    5     3          10    6     3        11    7     2
   rf2.may2      7    1     0          9    3     1       10    6     2       11    5     2          11    7     4        12    8     5
   rf2.jun1      7    2     0          8    3     1       10    5     3        9    5     3          11    7     4        11    8     6
   rf2.jun2      7    1     0          8    3     1        9    5     2       10    5     2          11    6     3        11    8     5
   rf2.jul1      8    2     0         10    5     1       10    6     3       11    6     3          11    8     5        10    9     6
   rf2.jul2      8    1     0         10    4     1       11    5     2       10    6     3          11    7     4        12    9     5
   rf2.aug1      8    2     0         10    4     1       11    6     3       10    6     3          11    8     5        12    9     6
   rf2.aug2      8    1     0         10    4     1       10    5     2       11    6     3          11    7     4        12    9     5
   rf2.sep1      7    1     0          9    4     0       10    6     3       11    6     3          11    7     5        12    9     6
   rf2.sep2      7    1     0          9    4     1       10    5     1       11    7     4          11    8     4        10    9     6
   rf2.oct1      5    0     0          7    1     0        8    3     0       10    6     2          10    5     1        11    6     2
   rf2.oct2      4    0     0          6    1     0        8    1     0       10    3     0           9    2     0        10    4     0
   rf2.nov1      1    0     0          3    0     0        4    0     0        7    1     0           6    0     0         4    1     0
   rf2.nov2      0    0     0          0    0     0        1    0     0        2    0     0           2    0     0         1    0     0


  +            cz7.l cz7.m cz7.h    cz8.l cz8.m cz8.h    cz9.l cz9.m cz9.h  cz10.l cz10.m cz10.h   cz11.l cz11.m cz11.h cz12.l cz12.m cz12.h


   rf2.feb2      2    0     0         5    0     0         0    0     0        0    0     0           0    0     0         1    0     0
   rf2.mar1      2    0     0         5    0     0         0    0     0        0    0     0           0    0     0         1    0     0
   rf2.mar2      5    0     0         6    0     0         1    0     0        1    0     0           1    0     0         2    0     0
   rf2.apr1      9    2     1        11    5     2         3    0     0        5    0     0           5    0     0         6    1     0
   rf2.apr2     11    7     2        12    9     6         8    1     0        9    3     0          10    3     0        11    5     2
   rf2.may1     12    8     5        13   10     7         9    1     0       10    4     1          10    5     2        10    6     3
   rf2.may2     13   10     7        14   12     9        11    4     1       11    6     3          12    8     4        13    9     6
   rf2.jun1     13    9     6        13   11     8        11    7     3       11    8     5          12    8     5        12    9     7
   rf2.jun2     13    9     6        13   11     8        10    5     2       11    7     4          11    7     5        12    9     6
   rf2.jul1     13   10     8        13   12    10        10    5     1       10    6     3          11    7     4        11    8     5
   rf2.jul2     13   11     8        14   13    10        10    4     1       10    5     1          11    6     3        11    7     4
   rf2.aug1     12   11     8        13   12    10         9    4     1       10    5     1          11    7     3        11    7     4
   rf2.aug2     13   10     8        14   12     9         9    4     1       10    4     1          11    6     4        10    7     4
   rf2.sep1     12   10     8        13   12     9         8    3     1        9    3     1          11    6     3        10    7     3
   rf2.sep2     13   11     8        13   12    10         8    2     0        9    3     0          10    5     1        10    6     2
   rf2.oct1     11    8     6        12   10     4         6    0     0        6    1     0           9    3     0         9    4     1
   rf2.oct2     11    6     2        12    8     1         5    0     0        5    0     0           8    1     0         9    2     0
   rf2.nov1      9    3     0        10    5     0         1    0     0        1    0     0           4    0     0         6    0     0
   rf2.nov2      5    0     0         7    1     0         0    0     0        0    0     0           1    0     0         1    0     0
;
*
*   page 251 KTBL 2012/2013
*
   table  p_fieldWorkingDays(labReqLevl,labPeriod,climateZone,soilType)

               cz1.l cz1.m cz1.h     cz2.l cz2.m cz2.h   cz3.l cz3.m cz3.h   cz4.l cz4.m cz4.h      cz5.l cz5.m cz5.h    cz6.l cz6.m cz6.h


   rf3.feb2      0    0     0          0    0     0        2    0     0        1    0     0           5    1     0         6    2     0
   rf3.mar1      0    0     0          0    0     0        2    0     0        1    0     0           5    1     0         6    2     0
   rf3.mar2      3    0     0          3    0     0        6    0     0        7    3     0           8    2     0         9    4     1
   rf3.apr1      7    1     0          5    2     0        8    1     1        9    7     3          10    7     3        11    8     4
   rf3.apr2      9    4     1          9    5     1       11    8     5       11    8     5          12   10     6        13   11     8
   rf3.may1     11    5     2         10    7     2       12    9     6       12    9     6          12   10     7        14   11     9
   rf3.may2      9    6     2         12    8     3       13   10     7       12   10     6          13   11     8        13   12    10
   rf3.jun1      9    5     2         11    7     4       12    9     7       11    8     6          12   11     8        13   11     9
   rf3.jun2     10    6     2         11    7     4       12    9     6       11    9     7          12   10     7        13   11     9
   rf3.jul1     11    7     1         12    9     5       12   10     6       12   10     7          13   11     9        13   12    10
   rf3.jul2     11    6     1         12    9     4       13   10     7       13   10     6          13   11     8        14   12    10
   rf3.aug1     11    7     2         12    9     5       12   10     7       12    9     6          13   11     9        13   12    10
   rf3.aug2     10    6     2         12    9     5       12   10     7       13   10     7          13   11     8        14   12    10
   rf3.sep1     11    7     2         12    9     5       12   10     6       12   11     7          13   11     9        13   12    10
   rf3.sep2     10    7     1         12    9     5       12   10     4       13   11     8          13   12     9        13   12    10
   rf3.oct1      9    4     0         10    6     3       11    8     2       12   10     7          12   10     6        13   11     8
   rf3.oct2      9    2     0         11    5     1       11    7     2       12   10     5          12    9     4        13   11     7
   rf3.nov1      6    1     0          8    2     0        9    4     1       10    7     3          11    7     2        11    9     4
   rf3.nov2      1    0     0          3    0     0        6    1     0        5    2     0           7    2     0         8    4     0


  +            cz7.l cz7.m cz7.h    cz8.l cz8.m cz8.h    cz9.l cz9.m cz9.h  cz10.l cz10.m cz10.h   cz11.l cz11.m cz11.h cz12.l cz12.m cz12.h


   rf3.feb2      7    2     0         9    6     1         8    1     0        7    1     0           6    1     0         7    2     0
   rf3.mar1      7    2     0         9    6     1         8    1     0        7    1     0           6    1     0         7    2     0
   rf3.mar2     10    5     2        12    7     3         9    1     0        8    2     0           8    2     0         9    3     0
   rf3.apr1     12    9     6        13   11     8        10    4     1       10    5     1          11    5     1        10    6     0
   rf3.apr2     13   11     9        14   13    11        13    8     4       13    9     6          13   10     7        13   11     2
   rf3.may1     13   12    10        14   13    11        13    9     5       12   10     6          13   10     7        13   10     8
   rf3.may2     14   13    11        15   14    13        14   11     8       14   11     8          14   13    10        13   13    10
   rf3.jun1     13   12    10        14   13    11        13   11     9       13   11     9          13   12    10        14   13    10
   rf3.jun2     13   12    10        14   13    12        13   10     8       12   11     8          13   11     9        14   12    10
   rf3.jul1     13   13    11        14   14    13        13   10     7       12   10     7          13   11     8        13   11     9
   rf3.jul2     14   13    12        15   14    13        12   10     6       12    9     6          13   11     8        13   11     9
   rf3.aug1     13   13    11        15   14    13        12    9     6       12    9     6          13   11     8        13   11     9
   rf3.aug2     14   13    11        15   14    13        12    9     5       11    9     5          14   11     8        13   11     7
   rf3.sep1     13   13    12        14   14    13        12    9     5       12    9     5          13   10     8        13   11     8
   rf3.sep2     14   13    12        14   14    13        12    9     4       11    9     5          12   10     8        13   10     7
   rf3.oct1     13   13    10        14   13    11        10    6     2       10    7     2          12    9     7        12   10     6
   rf3.oct2     13   12     8        14   13    10        10    5     1       10    5     1          12    9     3        12   10     5
   rf3.nov1     12   10     6        13   12     8         9    1     0        9    0     0          10    5     1        11    6     1
   rf3.nov2      9    7     2        10    8     4         7    0     0        6    0     0           8    1     0         8    2     0
 ;

$offmulti
*
* --- attributes for the operations
*

  parameter p_plotSizeEffect(crops,machVar,opAttr,rounded_plotSize);


  p_crop_op_per_till(curCrops(crops),operation,labPeriod,till,intens) $sum(plot$c_p_t_i(crops,plot,till,intens),1)
     = p_crop_op_per_tilla(curCrops,operation,labPeriod,till);


$iftheni.data "%database%" == "KTBL_database"
   parameter p_crop_op_per_tillKTBL(crops,operation,labPeriod,till,amount,intens) "crop operations per labperiod for KTBL crops";

   p_crop_op_per_tillKTBL(curCrops(crops),operation,labPeriod,till,amount,intens) $sum(plot$c_p_t_i(crops,plot,till,intens),1)
      = p_crop_op_per_tillaKTBL(curCrops,operation,labPeriod,till,amount);
$endif.data
*
* --- definition of cuts for grasland
*
$ifthen.gras defined noPastOutputs


  set toSilage(noPastOutputs) / earlyGrasSil,middleGrasSil,lateGrasSil /;
  set toHay(noPastOutputs) / hay /;
  set toPast(grasOutputs) /earlyGraz,middleGraz,lateGraz /;

  set grasToOutput(crops,grasOutputs);
  grasToOutput(crops,grasOutputs) $ sum((m) $(p_grasAttr(crops,grasOutputs,m)), 1) = YES;

  table p_opPerCut(operation,noPastOutputs,till) "Field operations for one gras cut per cutting process (either silo or bales)"
                                     silo     bales  hay
     mowing.set.noPastOutputs        1.00      1.00  1.0
     tedding.set.noPastOutputs       1.00      1.00  1.0
     raking.set.noPastOutputs        1.00      1.00  1.0
*
*   --- these operations are changed by harvested biomas
*
    closeSilo.set.toSilage          1.00
    silageTrailer.set.toSilage      1.00
    balePressWrap.set.toSilage               1.00
    balePressHay.hay                               1.00
    baleTransportSil.set.toSilage            1.00
    baleTransportHay.hay                           1.00
  ;

  parameter p_bioMassOpsFac(operation) "Factor in order to correct dry matter content to witted silage content (35% DM) or hay (86% DM)"
  /
    silageTrailer        0.35
    balePressWrap        0.35
    baleTransportSil     0.35
    balePressHay         0.86
    baleTransportHay     0.86
  /;

*
* --- count lab period where gras is cut
*
  parameter p_cutPeriod(crops,*) "Count # of labour period where grass is cut";

  p_cutPeriod(curCrops(grassCrops),labPeriod)
    = sum( (labPeriod_to_month(labPeriod,m),noPastOutputs) $ p_grasAttr(grassCrops,noPastOutputs,m),1);

*  p_cutPeriod(gras,labPeriod) = sum( labPeriod_to_month(labPeriod,m),p_cutPeriod(gras,m));
*
* --- silo cut for silage
*

  p_crop_op_per_till(curCrops(grassCrops),operation,labPeriod,"org","graz")
    = p_crop_op_per_till(grassCrops,operation,labPeriod,"noTill","graz");


  p_crop_op_per_till(curCrops(grassCrops),operation,labPeriod,"org","silo")
    = p_crop_op_per_till(grassCrops,operation,labPeriod,"noTill","silo");

  p_crop_op_per_till(curCrops(grassCrops),operation,labPeriod,"org","bales")
    = p_crop_op_per_till(grassCrops,operation,labPeriod,"noTill","bales");

  p_crop_op_per_till(curCrops(grassCrops),operation,labPeriod,"org","hay")
    = p_crop_op_per_till(grassCrops,operation,labPeriod,"noTill","hay");

  set grassTill(till) / noTill,org /;

  p_crop_op_per_till(curCrops(grassCrops),operation,labPeriod,grassTill,"silo")
     $ sum(toSilage, (p_cutPeriod(grassCrops,labPeriod) $ p_opPerCut(operation,toSilage,"silo") $ grasToOutput(grassCrops,toSilage)))
    =   sum( (labPeriod_to_month(labPeriod,m),toSilage) $ p_grasAttr(grassCrops,toSilage,m),
          p_opPerCut(operation,"middleGrasSil","silo")/2
*
*            --- change machinery needs (or not) depending on harvested dry matter
*
                 * (    1 $ (not p_bioMassOpsFac(operation))
                     +  (p_grasAttr(grassCrops,toSilage,m) * ( 1 $ sameas(grassTill,"noTill") + p_organicYieldMult(grassCrops) $ sameas(grassTill,"org"))
                            /p_bioMassOpsFac(operation)/op_attr(operation,"67kw","2","amount")) $ p_bioMassOpsFac(operation))
          )/ p_cutPeriod(grassCrops,labPeriod);
*
* --- bale pressing for silage
*
  p_crop_op_per_till(curCrops(grassCrops),operation,labPeriod,grassTill,"bales")
     $ sum(toSilage,(p_cutPeriod(grassCrops,labPeriod) $ p_opPerCut(operation,toSilage,"bales") $ grasToOutput(grassCrops,toSilage)))
    =   sum( (labPeriod_to_month(labPeriod,m),toSilage) $ p_grasAttr(grassCrops,toSilage,m),
          p_opPerCut(operation,"middleGrasSil","bales")/2
*
*            --- change machinery needs (or not) depending on harvested dry matter
*
                 * (    1 $ (not p_bioMassOpsFac(operation))
                     +  (p_grasAttr(grassCrops,toSilage,m) * ( 1 $ sameas(grassTill,"noTill") + p_organicYieldMult(grassCrops) $ sameas(grassTill,"org"))
                           /p_bioMassOpsFac(operation)/op_attr(operation,"67kw","2","amount")) $ p_bioMassOpsFac(operation))
          )/ p_cutPeriod(grassCrops,labPeriod);
*
* --- bale pressing for hay
*
  p_crop_op_per_till(curCrops(grassCrops),operation,labPeriod,grassTill,"hay")
     $ (p_cutPeriod(grassCrops,labPeriod) $ p_opPerCut(operation,"hay","hay") $ grasToOutput(grassCrops,"hay"))
    =   sum( (labPeriod_to_month(labPeriod,m),toHay) $ p_grasAttr(grassCrops,toHay,m),
          p_opPerCut(operation,"hay","hay")/2
*
*            --- change machinery needs (or not) depending on harvested dry matter
*
                 * (    1 $ (not p_bioMassOpsFac(operation))
                     +  (p_grasAttr(grassCrops,toHay,m) * ( 1 $ sameas(grassTill,"minTill") + p_organicYieldMult(grassCrops) $ sameas(grassTill,"org"))
                           /p_bioMassOpsFac(operation)/op_attr(operation,"67kw","2","amount")) $ p_bioMassOpsFac(operation))
          )/ p_cutPeriod(grassCrops,labPeriod);
*
* --- remove unwanted tillage options
*
  p_crop_op_per_till(gras,operation,labPeriod,till,intens)$ (not (sameas(till, "noTill") or sameas(till,"org"))) = 0;

$endif.gras

* --- WB: 11.07.14: that is still not fully satisfactory, as phospate might be switched off
*
  p_crop_op_per_till(curCrops(crops),"NFert320",labPeriod,till,intens) = 0;
  p_crop_op_per_till(curCrops(crops),"NFert160",labPeriod,till,intens) = 0;
  p_crop_op_per_till(curCrops(crops),"basFert",labPeriod,till,intens)  = 0;

*
* --- delete tillage-crop combination for which no technology data are given
*
  set dummyLabels / idleGras /;
$iftheni.data "%database%" == "KTBL_database"
  c_p_t_i(crops,plot,till,intens) $ ( (not sum( (operation,labPeriod),p_crop_op_per_till(crops,operation,labPeriod,till,intens))
                                      and not sum( (operation,labPeriod,amount),p_crop_op_per_tillKTBL(crops,operation,labPeriod,till,amount,intens)))
                                     $ c_p_t_i(crops,plot,till,intens)
                                     $ (not (sameas(crops,"idle") or sameas(crops,"idleGras") or grasscrops(crops)))) = NO;

$endif.data

$ifthen.gras defined noPastOutputs

* --- delete unwanted grassland options from c_p_t_i

  set grasTointens(crops,intens);
  grasTointens(curCrops(grassCrops),"silo")    $ sum(grasToOutput(grasscrops,toSilage),1) = yes;
  grasTointens(curCrops(grassCrops),"bales")   $ sum(grasToOutput(grasscrops,toSilage),1) = yes;
  grasTointens(curCrops(grassCrops),"hay")     $ sum(grasToOutput(grasscrops,"hay"),1)    = yes;
  grasTointens(curCrops(grassCrops),"graz")    $ sum(grasToOutput(grasscrops,toPast),1)   = yes;

  c_p_t_i(curCrops(grasscrops),plot,till,intens) $( not grasTointens(grasscrops,intens)) =no;

  c_p_t_i("idleGras",plot,till,intens)  = no;
  c_p_t_i("idleGras",plot,till,intens)  $ (sum(plot_lt_soil(plot,"Gras",soil),1) $ (sameas(till,"noTill") or sameas(till,"org")) $ sameas(intens,"normal")) = yes;
  c_p_t_i("idleGras",plot,till,intens)  $ (sum(plot_lt_soil(plot,"past",soil),1) $ (sameas(till,"noTill") or sameas(till,"org")) $ sameas(intens,"normal")) = yes;

  $$ifi "%orgTill%"=="off" c_p_t_i("idleGras",plot,"org",intens) = no;

  p_crop_op_per_till(curCrops(mixpast),operation,labPeriod,till,"graz")
   $ (sum(grasTointens(mixpast,intens),2) $ grasTointens(mixpast,"hay")) = p_crop_op_per_till(mixpast,operation,labPeriod,till,"hay") ;

  p_crop_op_per_till(curCrops(mixpast),operation,labPeriod,till,"graz")
   $ (sum(grasTointens(mixpast,intens),2) $ grasTointens(mixpast,"silo")) = p_crop_op_per_till(mixpast,operation,labPeriod,till,"silo") ;

  p_crop_op_per_till(curCrops(mixpast),operation,labPeriod,till,"graz")
   $ (sum(grasTointens(mixpast,intens),2) $ grasTointens(mixpast,"bales")) = p_crop_op_per_till(mixpast,operation,labPeriod,till,"bales") ;

$endif.gras


  p_crop_op_per_till(curCrops(crops),operation,labPeriod,till,intens) $(not sum(plot$c_p_t_i(curCrops,plot,till,intens),1)) = 0;

$iftheni.data "%database%" == "KTBL_database"
  p_crop_op_per_tillKTBL(curCrops(crops),operation,labPeriod,till,amount,intens) $(not sum(plot$c_p_t_i(curCrops,plot,till,intens),1)) = 0;
$endif.data

  set c_t_i(crops,till,intens);
  c_t_i(curCrops,till,intens) $ sum(c_p_t_i(curCrops,plot,till,intens),1) = YES;
*
* --- abort if crops (exemption idle, idleGras, or gras which has only pasture) have no field operations at all
*
$ontext

  if ( sum(curCrops(crops)  $ (((not sum((c_t_i(crops,till,intens),operation,labPeriod),p_crop_op_per_till(crops,operation,labPeriod,till,intens)))
                                                                $ ((not idle(crops))
                                                                $$iftheni.EUcountry "%EUCountry%"=="true"
                                                                $$iftheni.e"%ecoSchemesCapPillar1%" == "true"  
                                                                $ (not ES1crops(crops))
                                                                $$endif.e
                                                                $$endif.EUcountry
                                                                $$iftheni.c "%cattle%" == true
                                                                $ (not sameas(crops,"idleGras"))
                                                                $ (not sum(grascrops, sum(nopastOutputs,grasCrops_outputs(grascrops,nopastOutputs))))
                                                                $$endif.c
                                                                   ))
      $$iftheni.data "%database%" == "KTBL_database"
        and   ((not sum((c_t_i(crops,till,intens),operation,labPeriod,amount), p_crop_op_per_tillKTBL(crops,operation,labPeriod,till,amount,intens))))
      $$endif.data
         ),1),

     curCrops(crops) $ sum((c_t_i(crops,till,intens),operation,labPeriod),p_crop_op_per_till(crops,operation,labPeriod,till,intens)) = no;
     $$iftheni.data "%database%" == "KTBL_database"
        curCrops(crops) $ sum((c_t_i(crops,till,intens),operation,labPeriod,amount),p_crop_op_per_tillKTBL(crops,operation,labPeriod,till,amount,intens)) = no;
     $$endif.data
     abort "Crops without any field operation in file: %system.fn%, line: %system.incline%",curCrops,p_crop_op_per_till;
  );
$offtext
*
* --- Change_op_intens lowers the machinery need based on the intensity.
  p_changeOpIntens(curCrops(crops),operation,labPeriod,intens)
     $ sum(till, p_crop_op_per_till(crops,operation,labPeriod,till,intens)) = 1.;

$ifthen.gras defined grasTypes

  p_changeOpIntens(curCrops(arabCrops),operation,labPeriod,"bales") = 0;
  p_changeOpIntens(curCrops(arabCrops),operation,labPeriod,"silo")  = 0;
  p_changeOpIntens(curCrops(arabCrops),operation,labPeriod,"graz")  = 0;
  p_changeOpIntens(curCrops(arabCrops),operation,labPeriod,"hay")   = 0;

$endif.gras
*
* --- Plot size effects are now covered by regression analysis - only for crops not included in KTBL database
*


* -- use mean of given crops if missing for one of the crops
*
$iftheni.data "%database%" == "KTBL_database"
   p_plotSizeEffect(crops,"67kW",opAttr,rounded_plotSize) $ ((not p_plotSizeEffect(crops,"67kW",opAttr,rounded_plotSize)) $ (not sum(till, c_p_t_i_GDX(crops,"plot",till,"normal"))))
     =  (sum( crops1,  p_plotSizeEffect(crops1,"67kW",opAttr,rounded_plotSize))
       / sum( crops1 $ p_plotSizeEffect(crops1,"67kW",opAttr,rounded_plotSize),1)) $sum(crops1, p_plotSizeEffect(crops1,"67kW",opAttr,rounded_plotSize));

   p_plotSizeEffect(crops,actMachVar,opAttr,rounded_plotSize) $ ((not p_plotSizeEffect(crops,actMachVar,opAttr,rounded_plotSize)) $ (not sum(till, c_p_t_i_GDX(crops,"plot",till,"normal"))))
     =  (sum( crops1,  p_plotSizeEffect(crops1,actMachVar,opAttr,rounded_plotSize))
       / sum( crops1 $ p_plotSizeEffect(crops1,actMachVar,opAttr,rounded_plotSize),1)) $sum(crops1, p_plotSizeEffect(crops1,actMachVar,opAttr,rounded_plotSize));

   p_plotSizeEffect(crops,"200kw",opAttr,rounded_plotSize) $ ((not p_plotSizeEffect(crops,"200kw",opAttr,rounded_plotSize)) $ (not sum(till, c_p_t_i_GDX(crops,"plot",till,"normal"))))
     =  (sum( crops1,  p_plotSizeEffect(crops1,"200kw",opAttr,rounded_plotSize))
      /sum( crops1 $ p_plotSizeEffect(crops1,"200kw",opAttr,rounded_plotSize),1)) $sum(crops1, p_plotSizeEffect(crops1,"200kW",opAttr,rounded_plotSize));
$else.data
  p_plotSizeEffect(crops,"67kW",opAttr,rounded_plotSize) $ (not p_plotSizeEffect(crops,"67kW",opAttr,rounded_plotSize))
    =  (sum( crops1,  p_plotSizeEffect(crops1,"67kW",opAttr,rounded_plotSize))
      / sum( crops1 $ p_plotSizeEffect(crops1,"67kW",opAttr,rounded_plotSize),1)) $sum(crops1, p_plotSizeEffect(crops1,"67kW",opAttr,rounded_plotSize));

   p_plotSizeEffect(crops,actMachVar,opAttr,rounded_plotSize) $ (not p_plotSizeEffect(crops,actMachVar,opAttr,rounded_plotSize))
    =  (sum( crops1,  p_plotSizeEffect(crops1,actMachVar,opAttr,rounded_plotSize))
      /sum( crops1 $ p_plotSizeEffect(crops1,actMachVar,opAttr,rounded_plotSize),1))  $sum(crops1, p_plotSizeEffect(crops1,actMachVar,opAttr,rounded_plotSize));

   p_plotSizeEffect(crops,"200kw",opAttr,rounded_plotSize) $ (not p_plotSizeEffect(crops,"200kw",opAttr,rounded_plotSize))
    =  (sum( crops1,  p_plotSizeEffect(crops1,"200kw",opAttr,rounded_plotSize))
      /sum( crops1 $ p_plotSizeEffect(crops1,"200kw",opAttr,rounded_plotSize),1)) $sum(crops1, p_plotSizeEffect(crops1,"200kW",opAttr,rounded_plotSize)) ;

$endif.data


*
* -- update price of machinery based on changes in fix costs
*

  p_priceMach(machType,t) $ ( sum(op_machType(operation,machType),1) $p_priceMach(machType,t))
    = (p_priceMach(machType,t) *  sum( (crops,actMachVar,act_rounded_plotsize), (p_plotSizeEffect(crops,actMachVar,"fixCost",act_rounded_plotsize)
                                                                    / p_plotSizeEffect(crops,"67Kw","fixCost","2") )$ p_plotSizeEffect(crops,"67Kw","fixCost","2"))
                              / sum( (crops,actMachVar,act_rounded_plotsize) $ p_plotSizeEffect(crops,actMachVar,"fixCost",act_rounded_plotsize),1))
                              ;
  p_priceMach("tractor",t)
    = p_priceMach("tractor",t) *  sum((crops,actMachVar,act_rounded_plotsize)
                                              $$iftheni.data "%database%" == "KTBL_database"
                                                 $ (not sum(till, c_p_t_i_GDX(crops,"plot",till,"normal")))
                                              $$endif.data
                                      ,(p_plotSizeEffect(crops,actMachVar,"fixCost",act_rounded_plotsize)
                                                                       /p_plotSizeEffect(crops,actMachVar,"labTime",act_rounded_plotsize)) $p_plotSizeEffect(crops,actMachVar,"labTime",act_rounded_plotsize)
                                                                      / (p_plotSizeEffect(crops,"67Kw","fixCost","2")
                                                                      / p_plotSizeEffect(crops,"67kW","labTime","2")))
                                  / sum( (crops,actMachVar,act_rounded_plotsize) $ (p_plotSizeEffect(crops,actMachVar,"fixCost",act_rounded_plotsize)
                                   $$iftheni.data "%database%" == "KTBL_database"
                                      $ (not sum(till, c_p_t_i_GDX(crops,"plot",till,"normal")))
                                   $$endif.data
                                    ),1)
;

*
* --- update of variable costs of machinery based on changes variable cost
*
  set varCosts(machAttr) / varCost_ha,varCost_h /;

  p_machAttr(machType,varCosts) $ ( sum(op_machType(operation,machType),1) or sameas(machType,"Tractor"))
   = p_machAttr(machType,varCosts)
       *  sum( (curCrops(crops),actMachVar,act_rounded_plotsize)
           $$iftheni.data "%database%" == "KTBL_database"
              $ (not sum(till, c_p_t_i_GDX(crops,"plot",till,"normal")))
           $$endif.data
           ,p_plotSizeEffect(crops,actMachVar,"varCost",act_rounded_plotsize)
                                              /p_plotSizeEffect(crops,"67Kw","varCost","2"))
       / sum( (curCrops(crops),actMachVar,act_rounded_plotsize) $ p_plotSizeEffect(crops,actMachVar,"varCost",act_rounded_plotsize),1);

*
* --- update of diesel consumption based on changes in diesel consumption
*
  p_machAttr(machType,"diesel_h") $ (sum(op_machType(operation,machType),1) or sameas(machType,"Tractor"))
   =  p_machAttr(machType,"diesel_h")
        *  sum( (curCrops(crops),actMachVar,act_rounded_plotsize)
           $$iftheni.data "%database%" == "KTBL_database"
              $ (not sum(till, c_p_t_i_GDX(crops,"plot",till,"normal")))
           $$endif.data
            ,p_plotSizeEffect(crops,actMachVar,"diesel",act_rounded_plotsize)
                                               /p_plotSizeEffect(crops,"67Kw","diesel","2"))
         / sum( (curCrops(crops),actMachVar,act_rounded_plotsize) $ p_plotSizeEffect(crops,actMachVar,"diesel",act_rounded_plotsize),1);


  op_attr(operation,actmachVar,rounded_plotsize,"diesel") $ op_attr(operation,actMachVar,rounded_plotsize,"diesel")
   = op_attr(operation,actmachVar,rounded_plotsize,"diesel")
        *  sum( (curCrops(crops),act_rounded_plotsize)
           $$iftheni.data "%database%" == "KTBL_database"
              $ (not sum(till, c_p_t_i_GDX(crops,"plot",till,"normal")))
           $$endif.data
           ,p_plotSizeEffect(crops,actMachVar,"diesel",act_rounded_plotsize)
                                               /p_plotSizeEffect(crops,"67Kw","diesel","2"))
         / sum( (curCrops(crops),act_rounded_plotsize) $ p_plotSizeEffect(crops,actMachVar,"diesel",act_rounded_plotsize),1);


  set techEval_c_t_i(crops,till,intens);
  option kill=techEval_c_t_i;
*
* --------------------------------------------------------------------------------
*
*   Here, a user chosen file might be included which defines additional
*   elements in the till set to depict alternative technologies,
*   add combination to c_p_t_i and define the p_crop_op_per_till and other
*   parameters to calculate machinery and labour hour needs for the new
*   technology
*
* --------------------------------------------------------------------------------
*

$ifi not "%additionalTechFile%"=="empty" $batinclude '%datDir%/%additionalTechFile%.gms'

 p_machNeed(curCrops,till,intens,machType,"ha") $ (p_lifeTimeM(machType,"ha")
                                              $ (    (sum(c_p_t_i(curCrops,plot,till,intens),1) $ (not grassCrops(curCrops)))
                                                  or (grassCrops(curCrops))))
   = sum( (operation,labPeriod,op_machType(operation,machType)) $ p_crop_op_per_till(curCrops,operation,labPeriod,till,intens)  ,
               p_changeOpIntens(curCrops,operation,labPeriod,intens)
                  *  p_crop_op_per_till(curCrops,operation,labPeriod,till,intens))
                 ;

*
* --- list of oprations for which no tractor is needed
*
  op_machType(operation,"tractor") $ (not ( sameas(operation,"combineCere")
                                         or sameas(operation,"CombineRape")
                                         or sameas(operation,"CombineMaiz")
                                         or sameas(operation,"forkLiftTruck")
                                         or sameas(operation,"chopper")
                                         or sameas(operation,"potatoStoring")
                                         or sameas(operation,"silageTrailer")
                                         or sameas(operation,"grinding")
                                    $$iftheni.data "%database%" == "KTBL_database"
                                         or (sum(operationID $(operationID_operation(operationID,operation)),1))
                                    $$endif.data
                                         ))       = Yes;
*
* ---- operations where light tractor is neeeded
*
  op_machType(operation,"tractorSmall") $ op_machType(operation,"fertSpreaderSmall")       = YES;
  op_machType(operation,"tractorSmall") $ op_machType(operation,"threeWayTippingTrailer")  = YES;
  op_machType(operation,"tractorSmall") $ op_machType(operation,"sprayer")                 = YES;

  op_machType("rotaryHarrow","tractorSmall")         = YES;
  op_machType("roller","tractorSmall")               = YES;
  op_machType("sowMachine","tractorSmall")           = YES;
  op_machType("singleSeeder","tractorSmall")         = YES;
  op_machType("weederLight","tractorSmall")          = YES;
  op_machType("mulcher","tractorSmall")              = YES;
  op_machType("knockOffHaulm","tractorSmall")        = YES;
  op_machType("tedding","tractorSmall")              = YES;
  op_machType("mowing","tractorSmall")               = YES;
  op_machType("raking","tractorSmall")               = YES;
  op_machType("earthingUp","tractorSmall")           = YES;
  op_machType("manDist","tractorSmall")              = YES;

  op_machType(operation,"tractor") $ op_machType(operation,"tractorSmall") = No;
*
* ---- operations where no tractor is needed
*
  op_machType("soilSample",   "tractor")      = NO;
  op_machType("weedValuation","tractor")      = NO;
  op_machType("coveringSilo","tractor")       = NO;
  op_machType("closeSilo","tractor")          = NO;
  op_machType("plantValuation","tractor")     = NO;
  op_machType("weedValuation","tractor")      = NO;
  op_machType("store_n_dry_4","tractor")      = NO;
  op_machType("store_n_dry_beans","tractor")  = NO;
  op_machType("store_n_dry_8","tractor")      = NO;
  op_machType("store_n_dry_rape","tractor")   = NO;
*
* --- default is that one person is needed
*
 op_attr(operation,machVar,rounded_plotsize,"nPers") $ (op_attr(operation,machVar,rounded_plotsize,"labTime")
                                                  $ (not op_attr(operation,machVar,rounded_plotsize,"nPers")))
     = 1;

*
* --- exclude machines for which the use of contract work is assumed
*
$onempty
  set contractMachines(machType) / set.curContractMachines /;
$offempty

*
* --- add cutting units to list of contract machines if combine is selected
*
  contractMachines("cuttingUnitCere")  $ contractMachines("combine") = YES;
  contractMachines("cuttingAddRape")   $ contractMachines("combine") = YES;
  contractMachines("cuttingUnitMaiz")  $ contractMachines("combine") = YES;

  set contractOperation(operation);
  contractOperation(operation) $ sum(op_machType(operation,contractMachines),1) = yes;

 set curOperation(operation);
 curOperation(operation) = yes;
 curOperation(operation) $ (not op_attr(operation,"67kw","2","labtime")) = no;


 p_machNeed(c_t_i(curCrops,till,intens),machType,"hour") $ p_lifeTimeM(machType,"hour")
   = sum( (curOperation(operation),actMachVar,act_rounded_plotsize,labPeriod) $ (op_machType(operation,machType)
                                                           $ op_attr(operation,"67kW","2","labTime")),
               p_changeOpIntens(curCrops,operation,labPeriod,intens)
                 * p_crop_op_per_till(curCrops,operation,labPeriod,till,intens)
                     * op_attr(operation,"67kW","2","labTime") / op_attr(operation,"67kW","2","nPers")
*
*                    -- effect of plot size and mechanisation on labour time -
*
                         * ([   p_plotSizeEffect(curCrops,actMachVar,"labTime",act_rounded_plotsize) $ (not contractOperation(operation))
                             + p_plotSizeEffect(curCrops,"200kw","labTime",act_rounded_plotsize)    $ contractOperation(operation)
                           ]
                           /p_plotSizeEffect(curCrops,"67kW","labTime","2") )
                     $$iftheni.data "%database%" == "KTBL_database"
                         $ (not sum(crops, c_p_t_i_GDX(crops,"plot",till,"normal")))
                     $$endif.data
                         );


$iftheni.data "%database%" == "KTBL_database"
*
*  --- per hectare input requirements and  variable costs of machine operations considering frequency of operation (regression analysis)
*      only available for KTBL crops


   parameter p_opIDInputReq(Crops,till,*,*) "plot size and distance specific input requirements of operationID";

   p_opIDInputReq(curCrops,till,items,operationID)
      = sum((crops_operationID(curCrops,sys,till,operationID,labperiod,amount,actMachVar),amountUnit,
              Soil) $ sum(soil_plot(soil,plot),c_p_t_i(curCrops,plot,till,"normal"))
              ,
             (
              p_noRegCoeff(operationID,amount,soil,items)
                 $ (not p_regCoeff(operationID,amount,"m","time","intercept"))
      +
              Max(p_RegCoeff(operationID,amount,Soil,items,"minvalue"),
              Min(p_regCoeff(operationID,Amount,soil,items,"maxvalue"),
          ((
               p_regCoeff(operationID,amount,Soil,items,"intercept")
            +  p_regCoeff(operationID,amount,Soil,items,"size_linear")   * p_actPlotSize
            +  p_regCoeff(operationID,amount,Soil,items,"size_sqr")      * sqr(p_actPlotSize)
            +  p_regCoeff(operationID,amount,Soil,items,"sqroot_size")   * sqrt(p_actPlotSize)
            +  p_regCoeff(operationID,amount,Soil,items,"size_distance") * p_actPlotSize * p_actPlotDist
            +  p_regCoeff(operationID,amount,Soil,items,"dist_linear")   * p_actPlotDist
            +  p_regCoeff(operationID,amount,Soil,items,"dist_sqr")      * sqr(p_actPlotDist)
             ) $ p_regCoeff(operationID,amount,"m","time","intercept"))
             )))
             * p_crops_operationID(curCrops,sys,till,operationID,labperiod,amount,amountUnit,actMachVar)
           );

   p_opIDInputReq(curCrops,till,"nPers",operationID) $ p_opIDInputReq(curCrops,till,"time",operationID)
        = sum((Crops_operationID(curCrops,sys,till,operationID,labperiod,amount,actMachVar),
                Soil),p_noRegCoeff(operationID,amount,soil,"nPers"));

    p_opIDInputReq(curCrops,till,items,"sum") = sum(operationID,p_opIDInputReq(curCrops,till,items,operationID)) ;

*
*   ---- combine items to variable and fix costs and delete items not needed
*         map items (KTBL-regression) to opattr

   p_opInputReq(curCrops,till,"labTime",operation) =  sum(operationID_operation(operationID,operation),p_opIDInputReq(curCrops,till,"time",operationID));
*fuelCons in l Diesel/ha
   p_opInputReq(curCrops,till,"diesel",operation)  =  sum(operationID_operation(operationID,operation), p_opIDInputReq(curCrops,till,"fuelCons",operationID)) ;
* KTBL assums Diesel price of 0.75 -> deduct the diesel use to have a separate accounting
   p_opInputReq(curCrops,till,"varcost",operation) =  sum(operationID_operation(operationID,operation), p_opIDInputReq(curCrops,till,"maintenance",operationID)
                                                     +  (p_opIDInputReq(curCrops,till,"lubricants",operationID) - p_opInputReq(curCrops,till,"diesel",operation) *0.75 )
                                                     +  p_opIDInputReq(curCrops,till,"others",operationID));

   p_opInputReq(curCrops,till,"fixCost",operation) =  sum(operationID_operation(operationID,operation),
                                                        p_opIDInputReq(curCrops,till,"deprec",operationID)
                                                     +  p_opIDInputReq(curCrops,till,"interest",operationID));
   p_opInputReq(curCrops,till,"deprec",operation)  =  sum(operationID_operation(operationID,operation),
                                                        p_opIDInputReq(curCrops,till,"deprec",operationID));

   p_opInputReq(curCrops,till,"amount",operation) =    sum(operationID_operation(operationID,operation),
                                                         p_opIDInputReq(curCrops,till,"amount",operationID));

*  --- machines that are depreciated by massUse or volumeUse are depreciated by m3 or t -> convert l in m3 and kg in t
   p_opInputReq(curCrops,till,"amount",operation) $sum((operationID_operation(operationID,operation),sys,labperiod,amount,actMachVar,amountUnit)
                                                        $(sameas(amountUnit,"l") or sameas(amountUnit,"kg")),
                                                        p_crops_operationID(curCrops,sys,till,operationID,labperiod,amount,amountUnit,actMachVar))

                                                    = p_opInputReq(curCrops,till,"amount",operation)*0.001 ;
   p_opInputReq(curCrops,till,"services",operation) = sum( operationID_operation(operationID,operation), p_opIDInputReq(curCrops,till,"services",operationID));
   p_opInputReq(curCrops,till,"nPers",operation)    = sum(operationID_operation(operationID,operation), p_opIDInputReq(curCrops,till,"nPers",operationID));

*   --- default: only one person is needed
    p_opInputReq(curCrops,till,"nPers",operation) $ (p_opInputReq(curCrops,till,"labtime",operation) $ (not p_opInputReq(curCrops,till,"nPers",operation))) =1;


    p_opInputReq(curCrops,till,opAttr,"sum")
      = sum(operation,p_opInputReq(curCrops,till,opAttr,operation)) ;

*
*   --- contract work for KTBL operations
*
    parameter p_investThreshold "maximum machine price for own machinery";
    p_investThreshold = %investthreshold%;

*   --- if machine price exceeds threshold defined in GUI: operation is carried out by contracter (assume 10% markup)
*        (without tractor and wheelloader)

    p_opInputReq(curCrops,till,"services",operation)   $ ((sum(machType $(op_machType(operation,machType) $ sum(machType_machineType(machType,machineType)
                                                                     $(not (sameas(machineType,"tractor") or sameas(machineType,"WheelLoader"))),1)),
                                                                    p_machAttr(machType, "price") gt  p_investThreshold)))
                                                                    =
                                                                 (p_opInputReq(curCrops,till,"diesel",operation) * p_inputPrices("Diesel","conv")
                                                                 + p_opInputReq(curCrops,till,"varcost",operation)
                                                                 + p_opInputReq(curCrops,till,"fixCost",operation)
                                                                 +p_opInputReq(curCrops,till,"services",operation)) *1.1;

*   --- contractlab used in labour.gms
    p_opInputReq(curCrops,till,"contractLab",operation)   $ ((sum(machType $(op_machType(operation,machType) $ sum(machType_machineType(machType,machineType)
                                                                     $(not (sameas(machineType,"tractor") or sameas(machineType,"WheelLoader"))),1)),
                                                                    p_machAttr(machType, "price") gt  p_investThreshold)))
                                                                    =
                                                                    p_opInputReq(curCrops,till,"labTime",operation);


*   --- delete all other prices
    p_opInputReq(curCrops,till,opAttr,operation)   $ ((not sameas(opAttr,"services")) $(not sameas(opAttr,"contractLab"))
                                                                    $ (sum(machType $(op_machType(operation,machType) $ sum(machType_machineType(machType,machineType)
                                                                     $(not (sameas(machineType,"tractor") or sameas(machineType,"WheelLoader"))),1))
                                                                 , p_machAttr(machType, "price") gt  p_investThreshold))) = 0;

*   --- delete p_opIDInputReq
    p_opIDInputReq(curCrops,till,items,operationID) = 0;


*
*   --- deprecation of KTBL machines  (per crop and hectare)
*

*
*   --- link purchasePrice and type of depreciation to all machines required for necessary operation
*
    set deprecType(machAttr) /"hour","m3","ha","t"/;

    parameter deprec(operation,machType,machAttr);

    deprec(op_machType(operation,machType),"price")
       = p_machAttr(machType, "price");

    deprec(op_machType(operation,machType),deprecType)
       = p_machAttr(machType, deprecType);

    parameter p_physDepr(crops,till,*,*,*,*) "machine deprecation costs per ha";

*
*   --- calculate first cost of machTypes depreciated by hectare
*        process is always one hectare
*
    p_physDepr(curCrops,till,operation,"","","cost")
       = p_opInputReq(curCrops,till,"deprec",operation);

    p_physDepr(curCrops,till,op_machType(operation,machType),"","areaCost")
      $ (p_machAttr(machType,"ha") $ p_physDepr(curCrops,till,operation,"","","cost"))
      = p_machAttr(machType, "price")/p_machAttr(machType,"ha") + eps;
*
*   --- calculate total depreciation cost allocated to area use
*
    p_physDepr(curCrops,till,operation,"","","areaCost")
       $ p_opInputReq(curCrops,till,"deprec",operation)
     = sum(op_machType(operation,machType)
           $ p_machAttr(machType,"ha"),
                p_physDepr(curCrops,till,operation,machType,"","areaCost"));

*
*   --- scale in case that costs allocated to hectare exceed total ones
*
    p_physDepr(curCrops,till,op_machType(operation,machType),"","areaCost")
     $ ( p_machAttr(machType,"ha") $ (p_physDepr(curCrops,till,operation,"","","areaCost")
           gt p_opInputReq(curCrops,till,"deprec",operation)))
     = p_opInputReq(curCrops,till,"deprec",operation)
        /p_physDepr(curCrops,till,operation,"","","areaCost")
        * p_physDepr(curCrops,till,operation,machType,"","areaCost") + eps;

*
*   --- subtract these costs from total depreciation
*
    p_opInputReq(curCrops,till,"deprec",operation)
     = max(0,p_opInputReq(curCrops,till,"deprec",operation)
      - sum(op_machType(operation,machType) $ p_machAttr(machType,"ha"),
          p_physDepr(curCrops,till,operation,machType,"","areaCost")));

*   --- calculate depreciation cost by time for each machType
*
    p_physDepr(curCrops,till,op_machType(operation,machType),"","timeCost")
      $ (p_machAttr(machType,"hour") $ p_opInputReq(curCrops,till,"deprec",operation))
      = p_machAttr(machType, "price")/p_machAttr(machType,"hour")
            * p_opInputReq(curCrops,till,"labtime",operation) + eps;

*
*   --- calculate total depreciation cost allocated to time use
*
    p_physDepr(curCrops,till,operation,"","","timeCost")
     = sum(op_machType(operation,machType)
           $ p_machAttr(machType,"hour"),
                p_physDepr(curCrops,till,operation,machType,"","timeCost"));
*
*   --- scale in case that total costs by time use exceed total depreciation after by area use is substracted
*
    p_physDepr(curCrops,till,op_machType(operation,machType),"","timeCost")
     $ ( (p_physDepr(curCrops,till,operation,"","","timeCost")
          gt p_opInputReq(curCrops,till,"deprec",operation))
            $ p_machAttr(machType,"hour"))
     = p_opInputReq(curCrops,till,"deprec",operation)/p_physDepr(curCrops,till,operation,"","","timecost")
       * p_physDepr(curCrops,till,operation,machType,"","timeCost");
*
*   --- calculate any remaining depreciation costs
*
    p_opInputReq(curCrops,till,"deprec",operation)
     =   max(0,p_opInputReq(curCrops,till,"deprec",operation)
           -  sum(op_machType(operation,machType)
                $ p_machAttr(machType,"hour"),
                p_physDepr(curCrops,till,operation,machType,"","timeCost")));

*
*    --- calculate depreciation cost by time for each machType depreciated according to mass(m3)) and weight (t)
*
     p_physDepr(curCrops,till,op_machType(operation,machType),"","amountCost")
       $ ( (p_machAttr(machType,"m3") or p_machAttr(machType,"t"))
           $ p_opInputReq(curCrops,till,"deprec",operation))
       = p_machAttr(machType, "price")/
                  (p_machAttr(machType,"m3")+p_machAttr(machType,"t"))
            * p_opInputReq(curCrops,till,"amount",operation) + eps;

*
*   --- calculate total depreciation cost allocated to volume and mass use
*
    p_physDepr(curCrops,till,operation,"","","amountCost")
      = sum(op_machType(operation,machType)
           $ (p_machAttr(machType,"m3") or p_machAttr(machType,"t")),
                p_physDepr(curCrops,till,operation,machType,"","amountCost"));
*
*   --- scale in case that total costs by volume and mass use exceed total depreciation after by area use is substracted
*
     p_physDepr(curCrops,till,op_machType(operation,machType),"","amountCost")
       $ ( (p_physDepr(curCrops,till,operation,"","","amountCost")
          gt p_opInputReq(curCrops,till,"deprec",operation))
         $ p_physDepr(curCrops,till,operation,"","","amountCost")
            $ (p_machAttr(machType,"m3") or p_machAttr(machType,"t"))
         )
       = p_opInputReq(curCrops,till,"deprec",operation)
        /p_physDepr(curCrops,till,operation,"","","amountCost")
            * p_physDepr(curCrops,till,operation,machType,"","amountCost");

*
*   --- calculate remaining depreciation costs in case neither time, area,volume or weight is used
*
    p_physDepr(curCrops,till,operation,"","","restCost")
       $ p_opInputReq(curCrops,till,"deprec",operation)
       = sum(op_machType(operation,machType)
           $ (not (p_machAttr(machType,"hour") or p_machAttr(machType,"ha")
                   or [ (p_machAttr(machType,"m3") or p_machAttr(machType,"t"))
                              $ p_physDepr(curCrops,till,operation,"","","amountCost") ])),
                p_machAttr(machType, "price"));

*
*   --- any remaining costs are distributed according to remaining depreciation costs
*

    p_physDepr(curCrops,till,op_machType(operation,machType),"","restCost")
      $ ( p_physDepr(curCrops,till,operation,"","","restCost")
           $ (not (p_machAttr(machType,"hour") or p_machAttr(machType,"ha"))))
      = p_opInputReq(curCrops,till,"deprec",operation)/p_physDepr(curCrops,till,operation,"","","restCost")
          * p_machAttr(machType, "price");


    set depCost / areaCost,amountCost,timeCost,restCost /;
*
*   --- sum the calcualted depreciation of all machTypes of a operation
*
    p_physDepr(curCrops,till,operation,"","","totCost")
       = sum((op_machType(operation,machType),depCost),
               p_physDepr(curCrops,till,operation,machType,"",depCost));

*
*   --- check for remaining depreciation not distributed to any machType
*
    p_physDepr(curCrops,till,operation,"","","error")
     = p_physDepr(curCrops,till,operation,"","","totCost")
    -  p_physDepr(curCrops,till,operation,"","","cost");

*
*   --- distribute remaining depreciation to machTypes (NEW)
*
    p_physDepr(curCrops,till,op_machType(operation,machType),"",depCost)
          $ (abs(p_physDepr(curCrops,till,operation,"","","error")) gt 1.E-10)
     = p_physDepr(curCrops,till,operation,machType,"",depCost)
        * ( 1 + abs(p_physDepr(curCrops,till,operation,"","","error"))
              /p_physDepr(curCrops,till,operation,"","","totCost"));

*
*   --- sum the calcualted depreciation of all machTypes of a operation (after error is distributed)
*
    p_physDepr(curCrops,till,operation,"","","totCost")
      = sum((op_machType(operation,machType),depCost),
               p_physDepr(curCrops,till,operation,machType,"",depCost));
*
*   --- check again for remaining errors
*

    p_physDepr(curCrops,till,operation,"","","error")
      =   p_physDepr(curCrops,till,operation,"","","totCost")
        - p_physDepr(curCrops,till,operation,"","","cost");

*
*   --- for operations without machTypes (e.g. drying and storing; covering of silo),
*       error reflects depreciation of buildings and facilities (storage facility, silo)
*
    p_physDepr(curCrops,till,operation,"Buildings and Facilities","","totcost")
       $ (abs(p_physDepr(curCrops,till,operation,"","","error")) gt 1)
      = abs(p_physDepr(curCrops,till,operation,"","","error"));

*
*   --- Report total costs for each machType as a sum up over all depreciation cost positions
*

     p_physDepr(curCrops,till,op_machType(operation,machType),"","cost")
       = sum(depCost,p_physDepr(curCrops,till,operation,machType,"",depCost));
*
*    --- sum depreciation of a machType over all operations of a crop (sys,till)
*
     p_physDepr(curCrops,till,"mach_crop",machType,"",depCost)
       =sum(op_machType(operation,machType) $ p_physDepr(curCrops,till,operation,"","","cost"),
          p_physDepr(curCrops,till,operation,machType,"",depCost));
*
*   --- total depreciation of a maschine over all deprec types for a crop,sys,till
*
    p_physDepr(curCrops,till,"mach_crop",machType,"","totCost")
       = sum(depCost,p_physDepr(curCrops,till,"mach_crop",machType,"",depCost));

    p_physDepr(curCrops,till,"mach_crop","","Buildings and Facilities","totCost")
      = sum(operation $ p_physDepr(curCrops,till,operation,"Buildings and Facilities","","totcost"),
        p_physDepr(curCrops,till,operation,"Buildings and Facilities","","totcost"));
*
*   --- machine costs per hectare
*

    p_machNeed(crops,till,"normal",machType,"invCost")
       = p_physDepr(crops,till,"mach_crop",machType,"","totCost");

*   --- builidng costs per hectare (e.g. deprecation of silos and storage facilities)
    p_machNeed(crops,till,"normal","Buildings and Facilities","invCost")
     = p_physDepr(crops,till,"mach_crop","","Buildings and Facilities","totcost");

*
*   --- calculate share of machine purchase price depreciated
*

    p_machNeed(crops,till,"normal",machType,"share depreciated") $( p_physDepr(crops,till,"mach_crop",machType,"","totCost") $ p_machAttr(machType,"price"))
      =    p_physDepr(crops,till,"mach_crop",machType,"","totCost")
         / p_machAttr(machType,"price");


$endif.data

 p_fieldWorkHourNeed(c_t_i(curCrops,till,intens),labPeriod,labReqLevl)
           $$iftheni.data "%database%" == "KTBL_database"
           $ (not sum(crops, c_p_t_i_GDX(crops,"plot",till,"normal")))
           $$endif.data
   =
   sum( (curOperation(operation),actMachVar,act_rounded_plotsize) $ ( op_machType(operation,"tractor")
                                                   $ op_attr(operation,"67kW","2","labTime")),
               p_changeOpIntens(curCrops,operation,labPeriod,intens)
                 * p_crop_op_per_till(curCrops,operation,labPeriod,till,intens)
                   * op_rf(operation,labReqLevl)
                     * op_attr(operation,"67kW","2","labTime") / op_attr(operation,"67kW","2","nPers")
*
*                    -- effect of plot size and mechanisation on labour time
*
                         * [   p_plotSizeEffect(curCrops,actMachVar,"labTime",act_rounded_plotsize) $ (not contractOperation(operation))
                             + p_plotSizeEffect(curCrops,"200kw","labTime",act_rounded_plotsize)    $ contractOperation(operation)
                           ]
                          /p_plotSizeEffect(curCrops,"67kW","labTime","2")
                               )

                    $$iftheni.data "%database%" == "KTBL_database"
                    + sum(operation, ((p_opInputReq(curcrops,till,"labtime",operation) / p_opInputReq(curcrops,till,"nPers",operation))
                                    * op_rf(operation,labReqLevl)  ) $ (p_opInputReq(curcrops,till,"labtime",operation) $ sum(amount, p_crop_op_per_tillaKTBL(curcrops,operation,labperiod,till,amount))))
                    $$endif.data
                            ;

$ifthen.gras defined grasTypes

 p_fieldWorkHourNeed(curCrops(grassCrops),till,"bales",labPeriod,labReqLevl) $ (sameas(till,"minTill") or sameas(till,"org"))
   = p_fieldWorkHourNeed(grassCrops,"bales","normal",labPeriod,labReqLevl);

 p_fieldWorkHourNeed(curCrops(grassCrops),till,"silo",labPeriod,labReqLevl) $ (sameas(till,"minTill") or sameas(till,"org"))
   = p_fieldWorkHourNeed(grassCrops,"silo","normal",labPeriod,labReqLevl);

  p_fieldWorkHourNeed(curCrops(grassCrops),till,"graz",labPeriod,labReqLevl) $ (sameas(till,"minTill") or sameas(till,"org"))
   = p_fieldWorkHourNeed(grassCrops,till,"normal",labPeriod,labReqLevl);

 p_machNeed(curCrops(grassCrops),"bales","normal",machType,machLifeUnit)  = 0;
 p_machNeed(curCrops(grassCrops),"silo","normal",machType,machLifeUnit)   = 0;
 p_machNeed(curCrops(grassCrops),"hay","normal",machType,machLifeUnit)    = 0;
 p_machNeed(curCrops(past),"graz","normal",machType,machLifeUnit)         = 0;
 p_machNeed(curCrops(arablecrops),till,"hay",machType,machLifeUnit)       = 0;

*
*  --- If different grasland output overwrite machinery requirement for grazing
*

 p_machNeed(curCrops(mixPast),till,"graz",machType,machLifeUnit)
  $ (sum(grasTointens(mixpast,intens),2) $ grasTointens(mixpast,"hay"))   = p_machNeed(mixPast,till,"hay",machType,machLifeUnit) ;

 p_machNeed(curCrops(mixPast),till,"graz",machType,machLifeUnit)
  $ (sum(grasTointens(mixpast,intens),2) $ grasTointens(mixpast,"silo"))  = p_machNeed(mixPast,till,"silo",machType,machLifeUnit) ;

 p_machNeed(curCrops(mixPast),till,"graz",machType,machLifeUnit)
  $ (sum(grasTointens(mixpast,intens),2) $ grasTointens(mixpast,"bales")) = p_machNeed(mixPast,till,"bales",machType,machLifeUnit) ;

 p_fieldWorkHourNeed(curCrops(grassCrops),"bales","normal",labPeriod,labReqLevl)    = 0;
 p_fieldWorkHourNeed(curCrops(grassCrops),"silo","normal",labPeriod,labReqLevl)     = 0;
 p_fieldWorkHourNeed(curCrops(grassCrops),"noTill","normal",labPeriod,labReqLevl)   = 0;
 p_fieldWorkHourNeed(curCrops(grassCrops),"org","normal",labPeriod,labReqLevl)      = 0;
 p_fieldWorkHourNeed(curCrops(grassCrops),"hay","normal",labPeriod,labReqLevl)      = 0;

$endif.gras

* --- Validation parameter to compare new technology to normal (=plough) technology for relevant
*     parameters p_crop_op_per_till, p_costQuant, p_machNeed and p_fieldWorkHourNeed.

   set techValidCat /cropOperaVal,inputVal,machNeedHaVal,machNeedHourVal,fieldworkHourVal /;

   Parameter p_techValidation(techValidCat,crops,till,intens,*);

   p_techValidation("cropOperaVal",techEval_c_t_i(crops,till,intens),operation)     = sum (labPeriod, p_crop_op_per_till(crops,operation,labPeriod,till,intens) ) ;
   p_techValidation("inputVal",techEval_c_t_i(crops,till,intens),inputs)            = p_costQuant(crops,till,intens,inputs)  ;
   p_techValidation("machNeedHaVal",techEval_c_t_i(crops,till,intens),machType)     = p_machNeed(crops,till,intens,machType,"ha") ;
   p_techValidation("machNeedHourVal",techEval_c_t_i(crops,till,intens),machType)   = p_machNeed(crops,till,intens,machType,"hour") ;
   p_techValidation("fieldworkHourVal",techEval_c_t_i(crops,till,intens),labPeriod) = sum (labReqLevl, p_fieldWorkHourNeed(crops,till,intens,labPeriod,labReqLevl) ) ;

   if (card(p_techValidation), display p_techValidation);
