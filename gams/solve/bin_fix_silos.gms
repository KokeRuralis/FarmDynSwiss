********************************************************************************
$ontext

   Farmdyn project

   GAMS file : BIN_FIX_SILOS.GMS

   @purpose  : Fix integers related to buying of manure silos temporary
               during pre-solve with relaxed model
   @author   :
   @date     : 20.09.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************
$$ifthen.silos defined p_manStorCapSi

    $$ifi defined p_buySilos option kill=p_buySilos;


    p_buySilos(curManChain,"size",t_n(t,nCur)) = sum(silos, v_buySilosF.l(curManChain,silos,t,nCur) * p_ManStorCapSi(silos));
    p_buySilos(curManChain,"min",t_n(t,nCur)) $ p_buySilos(curManChain,"size",t,nCur)
                                 = smax(silos $ (p_ManStorCapSi(silos) le p_buySilos(curManChain,"size",t,nCur)),p_ManStorCapSi(silos));
    p_buySilos(curManChain,"max",t_n(t,nCur)) $ p_buySilos(curManChain,"size",t,nCur)
                                 = smin(silos $ (p_ManStorCapSi(silos) gt p_buySilos(curManChain,"size",t,nCur)),p_ManStorCapSi(silos));

    option kill=v_buySilos.l;

    v_buySilos.fx(curManChain,silos,t_n(t,nCur)) $ ( (    (p_ManStorCapSi(silos) eq p_buySilos(curManChain,"min",t,nCur))
                                                       or (p_ManStorCapSi(silos) eq p_buySilos(curManChain,"max",t,nCur)))) = 1;


    v_buySilos.fx(curManChain,silos,t_n(t,nCur)) $ (  p_ManStorCapSi(silos) gt p_buySilos(curManChain,"max",t,nCur)) = 0;

$$endif.silos
