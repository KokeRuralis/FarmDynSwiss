********************************************************************************
$ontext

   FARMDYN project

   GAMS file : 30COWS.GMS

   @purpose  :
   @author   :
   @date     : 12.11.10
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************

$setglobal farmName 60Cows

* -----------------------------------------------------------------------------
*
*   Initial state and further run specific settings
*
* -----------------------------------------------------------------------------

    p_iniStables("milk60","1990")        = 1;
    p_iniStables("youngCattle60","1990") = 1;
    p_iniStables("calves60","1990")      = 1;

    p_iniMach("tractor")                 = 10000;
    p_iniMach("plough")                  =  4000;

    p_iniHerd("Cows60") = 60 * 0.6;
    p_iniHerd("Cows61") = 60 * 0.4;

    p_iniLand = 80;

    p_yearlyAKH(t) = 52 * 45 * 3.;

    p_prob(s) =  1/card(s);

    p_iniLiquid    = 40000;

    p_hcon(t) =  50000 * 1.03**t.pos;
*
*   -- max is half + full
*
    workOpps("workOpp1") = yes;
    workOpps("workOpp2") = yes;
    workOpps("workOpp3") = yes;
    workOpps("workOpp4") = yes;
    workOpps("workOpp5") = yes;
    workOpps("workOpp6") = yes;


