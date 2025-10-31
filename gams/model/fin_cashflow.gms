********************************************************************************
$ontext

   FarmDyn project

   GAMS file : FIN_CASHFLOW.GMS

   @purpose  : Define equations related to financial cash flows
               (credits, repayments, interest payment, interest received)
               Only active with recursive_dynamic version
   @author   : W.Britz
   @date     : 25.02.21
   @since    : move from model\templ.gms
   @refDoc   :
   @seeAlso  :
   @calledBy : model\templ.gms

$offtext
********************************************************************************

parameter
      p_payBackTime(creditType)        "Payback time of credit type in years"
;

Variables
      v_finCashFlow(t,n)               "Financial cash flow"

positive variables
      v_intGain(t,n)                   "Interest gained"
      v_intPaid(t,n)                   "Interest paid"
      v_credits(creditType,t,n)        "New credits taken up in t"
      v_sumCredits(creditType,t,n)     "Sum of outstanding credits"
      v_liquidation(n)                 "Revenue from selling farm assets in last year and costs of repaying credits"
;

equations

  intPaid_(t,n)                        "Definition of interest paid"
  intGain_(t,n)                        "Definition of interest gained"
  credSum_(creditType,t,n)             "Sum of outstanding credits in current year"
  liquidation_(n)                      "Definition of rRevenue from selling farm assets in last year"
;

*
*   --- Interest gained on liquidity (on last year liquidity)
*
    intGain_(tFull(t),nCur) $ (t_n(t,nCur) $ p_interestGain) ..

       v_intGain(t,nCur) =E=
*
*         -- this considers the preceding (= ancestor) node if the stochastic
*            dynamic verison is active
*
          + sum(t_n(t-1,nCur1) $ anc(nCur,nCur1),
                v_liquid(t-1,nCur1)* p_interestGain/100);
*
*   --- Interest paid on outstanding credits
*
    intPaid_(t_n(tFull(t),nCur)) $ sum(creditType, p_interest(creditType)) ..

       v_intPaid(t,nCur) =E=
*
*       --- different creditype (payback time and interest rate differ)
*           only consider not yet paid back credit sum
*
           sum(creditType, v_sumCredits(creditType,t,nCur) * p_interest(creditType)/100);
*
*   --- financial cash flow in current period
*
    finCashFlow_(t_n(tFull(t),nCur)) ..

       v_finCashFlow(t,nCur) =E=
*
*       --- re-payments on past credits
*
         - sum((creditType,t1,nCur1) $ ( (    ((p_year(t1)    + p_payBackTime(creditType))  ge p_year(t))
                                          $   ( p_year(t1)+1                                le p_year(t)))
                                           $ tFull(t1)  $ isNodeBefore(nCur,nCur1) $ t_n(t1,nCur1)  ),
                                                v_credits(creditType,t1,nCur1) * 1/p_payBackTime(creditType))
*
*       --- new credits
*
         + sum(creditType, v_credits(creditType,t,nCur)) $ (p_year(t) lt p_year("%lastYear%"))
*
*      -- profit withdrawals by households
*
          - v_withDraw(t,nCur)
     ;
*
*   --- outstanding credits: past full amounts, paid back with specific payback time
*      (would need to be modified to account for credits not paid back in equal installments)
*
    credSum_(creditType,tFull(t),nCur) $ (t_n(t,nCur) $ (v_sumCredits.up(creditType,t,nCur) ne 0))    ..
*
       v_sumCredits(creditType,t,nCur) =e=
*
            sum( t_n(t1,nCur1) $ (  (((p_year(t1)  + p_payBackTime(creditType))  ge p_year(t))
                            $     ( p_year(t1)                                  le p_year(t)))
                            $ tCur(t1) $ isNodeBefore(nCur,nCur1)),
                                    v_credits(creditType,t1,nCur1)
                                    * (1-1/p_payBackTime(creditType) * (p_year(t)-p_year(t1))));


*
*   --- liquidation revenues from selling farm assets in last year
*
    liquidation_(nCur) $ t_n("%lastYearCalc%",nCur) ..

       v_liquidation(nCur) =e=
*
*           --- assume that past credits
*               are paid back fully in the last year (to prevent over-investments)
*
            - sum(creditType, v_sumCredits(creditType,"%lastYearCalc%",nCur))
*
*            --- sell machinery (assumption for resell avalue: non-depreciated stock
*                according to time or load, minus 33%)
*
             + [  sum( curMachines(machType) $ sum(machLifeUnit,p_lifeTimeM(machType,machLifeUnit)),
                      sum(machLifeUnit $ p_lifeTimeM(machType,machLifeUnit),
                         v_machInv(machType,machLifeUnit,"%lastYearCalc%",nCur)
                                                /p_lifeTimeM(machType,machLifeUnit)
                            * p_priceMach(machType,"%lastYearCalc%") * 2/3)
                / sum(machLifeUnit $ p_lifeTimeM(machType,machLifeUnit), 1)) ] $ card(curMachines) $ p_liquid
*
*            --- sell land (transaction costs set to 4 times the yearly land rent)
*                (only in case land can be bought or sold - eases the interpreation of the average objective value in each year)
*
$iftheni.lb %landBuy% == true
               + sum( plot, v_totPlotLand(plot,"%lastYear%",nCur)
                            * ( p_pland(plot,"%lastYear%") - 4 * p_landRent(plot,"%lastYear%")))  $ p_liquid
$endif.lb
$iftheni.dh %cowherd%==true
*
*              -- cows go for slaughter
*
             + sum( actHerds(cows,curBreeds,feedRegime,"%lastYear%","dec"),
                       v_herdSize(cows,curBreeds,feedRegime,"%lastYear%",nCur,"dec")
                          * p_OCoeff(cows,"oldCow",curBreeds,"%lastYear%") * p_price("oldCow","conv","%lastYearCalc%")) $ p_liquid
*
*              -- heifers at 30% of value of a young cow
*
             + sum( actHerds(heifs,curBreeds,feedRegime,"%lastYear%","dec"),
                       v_herdSize(heifs,curBreeds,feedRegime,"%lastYear%",nCur,"dec")
                                * p_price("youngCow","conv","%lastYearCalc%") * 0.3 ) $ p_liquid
*
*              -- raising cavles at 10% of value of a young cow
*
             + sum( actHerds("fCalvsRais",curBreeds,feedRegime,"%lastYear%","dec"),
                       v_herdSize("fCalvsRais",curBreeds,feedRegime,"%lastYear%",nCur,"dec")
                                * p_price("youngCow","conv","%lastYearCalc%") * 0.1 ) $ p_liquid
$endif.dh
       ;


model m_finCashFlow /
  intGain_
  intPaid_
  finCashFlow_
  credSum_
  liquidation_
/;
