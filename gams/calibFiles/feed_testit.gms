********************************************************************************
$ontext

   CAPRI project

   GAMS file : FEED_TESTIT.GMS

   @purpose  :
   @author   :
   @date     : 08.03.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************
$iftheni.mode %1==setBounds

*   execute_load "alles.gdx" v_feedUseHerds,v_herdsReqsPhase;


   parameter p_change;
  p_change(possHerds,feeds,t_n(tCur,nCur)) $  (v_feedUseHerds.l(possHerds,feeds,tCur,nCur) $ sameas(feeds,"maizSil") )
* $ sameas(possHerds,"fCalvsRais"))
* $ sameas(possHerds,"cows8500_short"))
* $ sameas(possHerds,"cows8500_long"))
    = 0.12;
*  option kill=p_change;

   p_feedCalib(possHerds,feeds,t_n(tCur,nCur),"desired") $ p_change(possHerds,feeds,tCur,nCur)
      = v_feedUseHerds.l(possHerds,feeds,tCur,nCur) * (1+p_change(possHerds,feeds,tCur,nCur));

$else.mode


$endif.mode
