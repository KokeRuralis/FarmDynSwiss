********************************************************************************
$ontext

   FARMDYN project

   GAMS file : Swiss Agr-Policy

   @purpose  :
   @author   : David Sch�fer
   @date     : 14.02.2021
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************
* -------------------------------------------------------------------------
*
*      Swiss direct payment parameters I   Ensuring food supply
*                                      II  Payments for arable land
*                                      III GMF - Gras-based milk and meat production
*
* -------------------------------------------------------------------------



* ---(I)   Ensuring food supply subsidy for all food production crops 900 CHF
        p_premFoodSupply(crops,sys) = 900;
*        p_premFoodSupply("gras3_3_2cuts_hay100",sys) = 450;

* ---(II)  All arable hectares get 400 CHF (Idle?)
         p_premArab(crops,sys) = 400;

* ---(III) Gras-based and milk and meat production premiums - Contingent on maximal use of concentrate and maximal use of maize silage in the roughages
         p_premGMF(t,n) = 200;
* --- Maximum amount of concentrates in feed
         p_maxConcFeed = 0.1;
* --- Total amount of land
         p_totalLand = p_nArabLand + p_nGrasLand + p_nPastLand;
* --- Maximum amount of maize
         p_maxMaizeFeed = 0.25;

* --- (V) Payments for animal friendly houzing and grazing - Assumed to be always fulfilled (1500 fixed value times Livestock Units)
         p_premAnm("cows")         = 280;
         p_premAnm("motherCow")    = 280;
         p_premAnm("heifs")        = 280 *  0.6;
         p_premAnm("calvs")        = 280 *  0.13;
         p_premAnm("bulls")        = 280 *  0.4;



* -------------------------------------------------------------------------
*
*         Parameter/data and sets related to diverse crop rotation (SCR)
*
* -------------------------------------------------------------------------

* --- Minimum number of crops required in rotation

         p_DivRotCropNum = 4;

* --- Minimum and maximum share of crops

         p_DivRotMax = 0.6;
         p_DivRotMin = 0.1 ;

$ontext


parameter p_areaBFF;

parameter p_feedAdditiveEmiRed;
parameter p_diffPay;

* --- Biodiversity promotion area
    p_areaBFF = 0.07;

* --- (IV) Payments for biodiversity area;
      p_premBFF = 1500;

* --- (VI) Difference in payment
      p_diffPay = %diffPay%;



$offtext
