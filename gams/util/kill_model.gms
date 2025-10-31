********************************************************************************
$ontext

   CAPRI project

   GAMS file : KILL_MODEL.GMS

   @purpose  : Dummy model in modus solvelink=0 (GamsCmex will be closed),
               which reallocate memory for all symbols. In connection
               with 'option=kill mySymbol;' it will release memory.
               Regularly used in all CAPRI projects
   @module   : utils
   @author   : W.Britz
   @date     : 08.04.11
   @since    :
   @refDoc   :
   @seeAlso  : util/kill_model1.gms
   @calledBy :

$offtext
********************************************************************************

    EQUATION XDUMMX_ "Equation in Dummy model to cleanse memory";

    XDUMMX_ .. 10. =E= 10.;

    MODEL XDUMMX  / XDUMMX_/;
    XDUMMX.Limcol    = 0;
    XDUMMX.Limrow    = 0;
    XDUMMX.Solprint  = 2;
    XDUMMX.Solvelink = 0;
