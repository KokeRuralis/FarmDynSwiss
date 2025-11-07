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

$setglobal farmName 30Cows

* -----------------------------------------------------------------------------
*
*   Initial state and further run specific settings
*
* -----------------------------------------------------------------------------

    p_iniStables("milk30","2000")        = 1;
    p_iniStables("youngCattle30","2000") = 1;
    p_iniStables("calves30","2000")      = 1;

    p_iniMach("tractor")                 = 5000;
    p_iniMach("plough")                  = 2000;

    p_iniHerd("Cows60") = 30 * 0.6;
    p_iniHerd("Cows61") = 30 * 0.4;

    p_iniLand      = 40;

    p_yearlyAKH(t) = 52 * 45 * 1.5;

    p_iniLiquid    = 100000;

    p_hcon(t)      =  25000 * 1.02**t.pos;
*
*   -- max is half + full
*
    workOpps("workOpp1") = yes;
    workOpps("workOpp2") = yes;
    workOpps("workOpp3") = yes;
