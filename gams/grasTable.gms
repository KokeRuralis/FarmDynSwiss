********************************************************************************
$ontext

   CAPRI project

   GAMS file : GRASTABLE.GMS

   @purpose  :
   @author   :
   @date     : 06.02.18
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************

   set grastypes / gra1*gra10/;
   set mm "months in each year" /DM,JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC /;
   set grasOutputs  / yield,earlyGraz,middleGraz,lateGraz,earlyGrasSil,middleGrasSil,lateGrasSil,hay,hayM,grasM /;

   table p_grasAttr1(GrasTypes,grasOutputs,mm)
                             DM      JAN    FEB    MAR    APR    MAY    JUN    JUL    AUG    SEP    OCT    NOV    DEC
   gra1.yield                10
   gra1.earlyGraz                    eps    eps     10     15    eps    eps    eps    eps
   gra1.middleGraz                                                20     20
   gra1.lateGraz                                                               15     10      10    eps    eps    eps

   gra2.yield                12
   gra2.earlyGraz                    eps    eps     10     15    eps    eps    eps    eps
   gra2.middleGraz                                                20     20
   gra2.lateGraz                                                               15     10      10    eps    eps    eps

   gra3.yield                10
   gra3.earlyGrasSil                                       30
   gra3.middleGrasSil                                                    40
   gra3.lateGrasSil                                                                           30

   gra4.yield                14
   gra4.earlyGrasSil                                       25
   gra4.middleGrasSil                                                    30          25
   gra4.lateGrasSil                                                                                  20

   gra5.yield                eps
   gra5.hay                                                                           100

   gra6.lateGrasSil          eps
   gra7.lateGrasSil          eps
   gra8.lateGrasSil          eps
   gra9.lateGrasSil          eps
   gra10.lateGrasSil         eps
   ;

  parameter p_grasAttrGui(grasOutputs,mm,grasTypes);
  p_grasAttrGui(grasOutputs,mm,grasTypes) = p_grasAttr1(GrasTypes,grasOutputs,mm);


   execute_unload "..\gui\grasAttr.gdx" p_grasattrGui;


