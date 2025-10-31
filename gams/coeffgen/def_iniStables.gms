********************************************************************************
$ontext

   CAPRI project

   GAMS file : DEF_INISTABLES.GMS

   @purpose  :
   @author   :
   @date     : 23.09.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************

  p_iniStables(stables,"long","%stableYear%") $ p_stableSize(stables,"%1") = 0;

  p_iniStables(stables,"long","%stableYear%") $ (   (p_stableSize(stables,"%1") ge %2)
                                                   $ (p_stableSize(stables,"%1") eq
                                                        smin(stables1 $ (p_stableSize(stables1,"%1") ge %2),
                                                            p_stableSize(stables1,"%1")))) = YES;

  p_iniStables(stables,"long","%stableYear%") $ (   (p_stableSize(stables,"%1") lt %2) $ p_stableSize(stables,"%1")
                                                   $ (p_stableSize(stables,"%1") eq
                                                        smax(stables1 $ (p_stableSize(stables1,"%1") lt %2),
                                                            p_stableSize(stables1,"%1")))) = YES;

  minSize = smin(stables $ (p_iniStables(stables,"long","%stableYear%") $ p_stableSize(stables,"%1")), p_stableSize(stables,"%1"));
  maxSize = smax(stables $ (p_iniStables(stables,"long","%stableYear%") $ p_stableSize(stables,"%1")), p_stableSize(stables,"%1"));

  p_iniStables(stables,"long","%stableYear%") $ ( (p_stableSize(stables,"%1") eq minSize) $ p_stableSize(stables,"%1")
                                                   and (minSize ne maxSize))
    = (%2 - maxSize)/(minSize-maxSize);

  p_iniStables(stables,"long","%stableYear%") $ ( (p_stableSize(stables,"%1") eq maxSize) $ p_stableSize(stables,"%1"))
    = 1 - [(%2 - maxSize)/(minSize-maxSize)] $ (minSize ne maxSize);

