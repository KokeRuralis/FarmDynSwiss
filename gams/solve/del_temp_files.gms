********************************************************************************
$ontext

   FARMDYN project

   GAMS file : DEL_TEMP_FILES.GMS

   @purpose  : Delete run specific options files at end of run
   @author   : W. Britz
   @date     : 31.10.14
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter.gms

$offtext
********************************************************************************

 execute 'rm -f %curDir%/opt/%solver%.%op3%';
 execute 'rm -f %curDir%/opt/%solver%.%op4%';
 execute 'rm -f %curDir%/opt/%solver%.%op5%';

