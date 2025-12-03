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
   set grasOutputs  / earlyGraz,middleGraz,lateGraz,grasSil,grasSilM,hay,hayM,hayExt,grasS,grasSM /;

   set grasAttr     / yield,set.grasOutputs,nCuts/;


   table p_grasAttr1(GrasTypes,grasAttr,mm)
                             DM      JAN    FEB    MAR    APR    MAY    JUN    JUL    AUG    SEP    OCT    NOV    DEC
   gra1.yield                12.2
   gra1.grasS                                               35           30            20            15                   

   gra2.yield                 9.1
   gra2.grasSM                                                    45            35            20                      

   gra3.yield                12.2
   gra3.hay                                                35           30            20            15                   

   gra4.yield                 9.1
   gra4.hayM                                                     45            35            20                      

   gra5.yield                 2.7
   gra5.hayExt                                                                 80                   20               

   gra6.yield                12.2
   gra6.grasSil                                            35           30            20            15                   

   gra7.yield                 9.1
   gra7.grasSilM                                                 45            35            20                      

   gra8.yield                11.6
   gra8.earlyGraz                                          35           30            20            15                   

   gra9.yield                 8.6
   gra9.middleGraz                                               45            35            20                      

   gra10.yield                5.6
   gra10.lateGraz                                                       70                   30                      
   ;


  parameter p_grasAttrGui(grasAttr,mm,grasTypes);
  p_grasAttrGui(grasAttr,mm,grasTypes) = p_grasAttr1(GrasTypes,grasAttr,mm);


   execute_unload "C:\Users\LennartKokemohr\Documents\FarmDyn\GreeNetSwiss\FarmDynSwiss\GUI\grasAttr.gdx" p_grasattrGui;


