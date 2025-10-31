********************************************************************************
$ontext

   FARMDyn project

   GAMS file : COUNT_BINARIES.GMS

   @purpose  : Use phython code to count # of binary/integer variables
               wich are not fixed
   @author   : W.Britz
   @date     : 01.10.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : binary_fixing

$offtext
********************************************************************************

$if not declared nRelaxedBinaries scalar nRelaxedBinaries/0/,nOldFixedBinaries / 0 /;
nOldFixedBinaries = nRelaxedBinaries;

embeddedCode Python:

  nRelaxedBinaries    = [0]
  for s in gams.db:
    if (type(s) == GamsVariable) and (s.vartype in [VarType.Binary, VarType.Integer,
                                                    VarType.SOS1,
#                                                   VarType.SOS2,
                                                    VarType.SemiCont, VarType.SemiInt]):
       for r in s:
            if ( (r.level != r.upper) and (r.level !=r.lower)):
               nRelaxedBinaries[0] = nRelaxedBinaries[0] + 1

  gams.set("nRelaxedBinaries",nRelaxedBinaries)
endEmbeddedCode nRelaxedBinaries
