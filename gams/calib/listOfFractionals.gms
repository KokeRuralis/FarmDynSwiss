********************************************************************************
$ontext

   CGEBOX project

   GAMS file : LISTOFBINARIES.GMS

   @purpose  :
   @author   :
   @date     : 09.03.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************

embeddedCode Python:

  def fractionals(db):

#     with open(r'%gams.scrdir%fracs.gms', 'w') as f:

#
#  ---- get all variables from the GAMS data base
#
#       for s in db:
#         if (type(s) == GamsVariable):
#           for r in s:
#             if (r.lower != r.upper):
#               gams.printLog(" "+str(r))

#       f.closed

    return 0

#rc = defBinaries(gams.ws.add_database_from_gdx(r'%gams.wdir%m_farm_p.gdx'))

  rc = fractionals(gams.ws.add_database_from_gdx(r'%gams.wdir%m_farm_p.gdx'))

endEmbeddedCode
