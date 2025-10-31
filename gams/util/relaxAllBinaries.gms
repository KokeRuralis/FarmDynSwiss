********************************************************************************
$ontext

   FarmDyn project

   GAMS file : RELAXALLBINARIES.GMS

   @purpose  : Set scale (= prior) field for all binaries/integers to a given
               value. Allows to relax all binaries
   @author   : W.Britz
   @date     : 27.01.21
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : model/part_mip_solve.gms

$offtext
********************************************************************************
*
* --- relax all binaries (prior) field (or reset relaxation)
*
embeddedCode Python:
     for s in gams.db:
       if (type(s) == GamsVariable) and (s.vartype in [VarType.Binary, VarType.Integer,
                                                       VarType.SOS1, VarType.SOS2,
                                                       VarType.SemiCont, VarType.SemiInt]):
#
#  Check for zero length symbol (= not defined) and add if zero
#
          l = gams.get(s.name)
          if ( len(l) == 0):
             gams.set(s.name,[])

          for r in s:
              r.scale = %1
endEmbeddedCode %sysenv.Binaries1% %sysenv.Binaries2% %sysenv.Binaries3%
