********************************************************************************
$ontext

   FARMDYN project

   GAMS file : CREDIT.GMS

   @purpose  : Define repayment period and interest rates for
               different types of credits

   @author   : Bernd Lengers
   @date     : 12.11.10
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************

    p_paybackTime("2years")  = 2;
    p_paybackTime("5Years")  = 5;
    p_paybackTime("10Years") = 10;
    p_paybackTime("20Years") = 20;

    p_interest("2years")  = %credit2YIntRate%;
    p_interest("5Years")  = %credit5YIntRate%;
    p_interest("10Years") = %credit10YIntRate%;
    p_interest("20Years") = %credit20YIntRate%;

