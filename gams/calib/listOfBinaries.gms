********************************************************************************
$ontext

   FarmDyn project

   GAMS file : LISTOFBINARIES.GMS

   @purpose  : generate include file with the list of binaries
               used to unload/load the status of binaries during fixing
   @author   : W.Britz
   @date     : 09.03.19
   @since    :
   @refDoc   :
   @seeAlso  : model\binary_fixing.gms
   @calledBy : exp_starter.gms

$offtext
********************************************************************************
*
* --- Create include file that comprises list of discrete variables
*
$onembeddedCode Python:

  with open(r'%gams.scrdir%binaries.gms', 'w') as f:
     for s in gams.db:
       if (type(s) == GamsVariable) and (s.vartype in [VarType.Binary, VarType.Integer,
                                                       VarType.SOS1, VarType.SOS2,
                                                       VarType.SemiCont, VarType.SemiInt]):
          f.write('  '+ s.name +'\n')
  f.closed

$offembeddedCode

*
* --- build an environment variable with the nam of all binaries
*


$iftheni.partMip "%partialMIPSolve%"=="true"
  $$setenv Binaries1
  $$setenv Binaries2
  $$setenv Binaries3

$onembeddedCode Python:
  import os
  x = ''
  i = 1
  for s in gams.db:
    if (type(s) == GamsVariable) and (s.vartype in [VarType.Binary, VarType.Integer,
                                                    VarType.SOS1, VarType.SOS2,
                                                    VarType.SemiCont, VarType.SemiInt]):
       if ( len(x)+len(s.name) > 255):
         os.environ["Binaries"+str(i)] = x
         x = ''
         i = i + 1
       x = x + ' ' + s.name

  os.environ["Binaries"+str(i)] = x
$offembeddedCode

$endif.partMip
