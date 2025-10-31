********************************************************************************
$ontext

   FarmDyn project

   GAMS file : BIN_FIX_STABLES.GMS

   @purpose  : Fix two points of concave set of stabled based
               on unrestricted solution
   @author   : W.Britz
   @date     : 20.09.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : binary fixing

$offtext
********************************************************************************

$$ifthen.stables defined v_buyStables

  $$ifi defined p_buyStables option kill=p_buyStables;
*
* --- stable place actually bought in each year
*
  p_buyStables(stableTypes,"size",hor,t_n(t,nCur))
   = sum(stables, v_buyStablesF.l(stables,hor,t,nCur) * p_stableSize(stables,stableTypes));

  p_buyStables(stableTypes,"cost",hor,t_n(t,nCur))
   = sum(stables $ p_stableSize(stables,stableTypes), v_buyStablesF.l(stables,hor,t,nCur) * p_priceStables(stables,hor,t)*p_vPriceInv("stables"));
*
* --- select the stables below and above that size as the two point to interpolate between
*
  p_buyStables(stableTypes,"min",hor,t_n(t,nCur))
    = smax(stables $ (      p_stableSize(stables,stableTypes)
                       and (p_stableSize(stables,stableTypes) le p_buyStables(stableTypes,"size",hor,t,nCur))), p_stableSize(stables,stableTypes));

  p_buyStables(stableTypes,"max",hor,t_n(t,nCur))
    = smin(stables $ (      p_stableSize(stables,stableTypes)
                       and (p_stableSize(stables,stableTypes) gt p_buyStables(stableTypes,"size",hor,t,nCur))), p_stableSize(stables,stableTypes));

  p_buyStables(stableTypes,"max",hor,t_n(t,nCur)) $ ( p_buyStables(stableTypes,"max",hor,t,nCur) eq inf)
    = smax(stables, p_stableSize(stables,stableTypes));

  p_buyStables(stableTypes,"min",hor,t_n(t,nCur)) $ ( p_buyStables(stableTypes,"max",hor,t,nCur) eq p_buyStables(stableTypes,"min",hor,t,nCur))
    = smax(stables $ (p_stableSize(stables,stableTypes) lt p_buyStables(stableTypes,"max",hor,t,nCur)), p_stableSize(stables,stableTypes));
*
* --- retain the excluded options from the define_start_bounds etc.
*
  p_buyStables(stables,"fix",hor,t_n(t,nCur)) $ ( v_buyStables.range(stables,hor,t,nCur) eq 0)
      = v_buyStables.up(stables,hor,t,nCur) + eps;
*
* --- set and fix the investment decision to yield exactly the stable places bought, now ensuring
*     thatonly places from neighboring stables can be bought
*
  option kill=v_buyStables;

  v_buyStables.fx(stables,hor,t_n(t,nCur)) $ sum(stableTypes $ (not p_replaceYear(stableTypes,hor)),1)
     = 1 $ sum(stableTypes $ (  p_stableSize(stables,stableTypes) and  p_priceStables(stables,hor,t) and
                                (     (p_stableSize(stables,stableTypes) eq p_buyStables(stableTypes,"min",hor,t,nCur))
                                  or  (p_stableSize(stables,stableTypes) eq p_buyStables(stableTypes,"max",hor,t,nCur)))),1);

  v_buyStables.fx(stables,hor,t_n(t,nCur)) $ sum(stableTypes $ (   p_stableSize(stables,stableTypes) gt p_buyStables(stableTypes,"max",hor,t,nCur)),1) = 0;
*
* --- re-introduce the excluded options from define_staring_bounds
*

  v_buyStables.fx(stables,hor,t_n(t,nCur)) $ p_buyStables(stables,"fix",hor,t,nCur)
   =  p_buyStables(stables,"fix",hor,t,nCur) $ (p_buyStables(stables,"fix",hor,t,nCur) gt eps);

  v_buyStables.l(stables,hor,t_n(t,nCur))  $ (v_buyStables.range(stables,hor,t,nCur) eq 0) = v_buyStables.up(stables,hor,t,nCur);


  $$iftheni.fixIniAssets "%fixIniAssets%"=="true"

    v_minInvStables.fx(stableTypes,hor,t_n(t,nCur))
      = 1 $ p_buyStables(stableTypes,"cost",hor,t,nCur);
  $$else.fixIniAssets
    v_minInvStables.fx(stableTypes,hor,t_n(t,nCur))
      = 1 $ (p_buyStables(stableTypes,"cost",hor,t,nCur) gt p_minInvStableCost(stableTypes,hor,t));
  $$endif.fixIniAssets

  v_minInvStables.l(stableTypes,hor,t_n(t,nCur)) $ (v_minInvStables.range(stableTypes,hor,t,nCur) eq 0)
     = v_minInvStables.up(stableTypes,hor,t,nCur);

  option kill=v_stableUsed.l,kill=v_stableInv.l,kill=v_stableNotUsed.l;

$$endif.stables
