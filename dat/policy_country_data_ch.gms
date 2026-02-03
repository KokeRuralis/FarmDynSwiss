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

        p_ordSZone("s0") = 0;
        p_ordSZone("s1") = 1;
        p_ordSZone("s2") = 2;
        p_ordSZone("s3") = 3;

        p_ordMZone("m0") = 0;
        p_ordMZone("m1") = 1;
        p_ordMZone("m2") = 2;
        p_ordMZone("m3") = 3;
        p_ordMZone("m4") = 4;
        p_ordMZone("m5") = 5;

        P_ordBFF("Q1") = 1;
        P_ordBFF("Q2") = 2;


* ---(I)  Offenhaltungsbeitrag in CHF/ha
* 0=Talzone, 1=Hügelzone, 2=Bergzone1, 3=Bergzone2, 4=Bergzone3 , 5=Bergzone4 
        p_premOpenLand("m0") = 0   ; 
        p_premOpenLand("m1") = 100 ;
        p_premOpenLand("m2") = 230 ;
        p_premOpenLand("m3") = 320 ;
        p_premOpenLand("m4") = 380 ;
        p_premOpenLand("m5") = 390 ;

* ---(I)  Offenhaltungsbeitrag in CHF/ha
* 0=-18%, 1=18-35%, 2=35-50%, 3=>50%%, 
        p_premSlope("s0") =      0 ; 
        p_premSlope("s1") =    410 ;
        p_premSlope("s2") =    700 ;
        p_premSlope("s3") =   1000 ;

* ---(I)   Ensuring food supply subsidy for all food production crops 600 CHF Versorgungssicherheitsbeiträge
        p_premFoodSupplyBase = 600;
        p_premFoodSupplyBFF  = 300;

* ---(I)   Produkltionserschwernisbeitrag Versorgungssicherheitsbeiträge
* 0=Talzone, 1=Hügelzone, 2=Bergzone1, 3=Bergzone2, 4=Bergzone3 , 5=Bergzone4 
        p_premDiffprods("m0") = 0   ; 
        p_premDiffprods("m1") = 390 ;
        p_premDiffprods("m2") = 510 ;
        p_premDiffprods("m3") = 550 ;
        p_premDiffprods("m4") = 570 ;
        p_premDiffprods("m5") = 590 ;

* ---(II)  All arable hectares get 400 CHF (Idle?) (Offene Ackerflächen)
         p_premArab(crops,sys) = 400;
         p_premArab("Idle",sys) = 0;

* ---(III) Gras-based and milk and meat production premiums - Contingent on maximal use of concentrate and maximal use of maize silage in the roughages
         p_premGMF(t,n) = 200;
* --- Maximum amount of concentrates in feed
         p_maxConcFeed = 0.1;
* --- Total amount of land
         p_totalLand = p_nArabLand + p_nGrasLand + p_nPastLand;
* --- Maximum amount of maize
         p_maxMaizeFeed = 0.25;

* --- (V) Payments for animal friendly houzing and grazing - Assumed to be always fulfilled (1500 fixed value times Livestock Units)
         p_premAnm("cows")         = 425;
         p_premAnm("motherCow")    = 425;
         p_premAnm("heifs")        = 425 *  0.33;
         p_premAnm("calvs")        = 530 *  0.13;
         p_premAnm("bulls")        = 425 *  0.4;

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


* --- Biodiversity promotion area
         p_areaBFF = 0.07;

* --- (IV) Payments for biodiversity area;


* --- Beitrag für die regionale Biodiversität und Landschaftsqualität
         p_BasisDZ = %BasisDZ%;


* --- Biodiversitäts beitrag
* 0=Talzone, 1=Hügelzone, 2=Bergzone1, 3=Bergzone2, 4=Bergzone3 , 5=Bergzone4 
        P_premBFF("m0","Q1","meadow") = 780 ; 
        P_premBFF("m1","Q1","meadow") = 560 ;
        P_premBFF("m2","Q1","meadow") = 300 ;
        P_premBFF("m3","Q1","meadow") = 300 ;
        P_premBFF("m4","Q1","meadow") = 300 ;
        P_premBFF("m5","Q1","meadow") = 300 ;

        P_premBFF("m0","Q2","meadow") = 1920 ; 
        P_premBFF("m1","Q2","meadow") = 1840 ;
        P_premBFF("m2","Q2","meadow") = 1700 ;
        P_premBFF("m3","Q2","meadow") = 1700 ;
        P_premBFF("m4","Q2","meadow") = 1100 ;
        P_premBFF("m5","Q2","meadow") = 1100 ;

        P_premBFF("m0","Q1","past") = 300 ; 
        P_premBFF("m1","Q1","past") = 300 ;
        P_premBFF("m2","Q1","past") = 300 ;
        P_premBFF("m3","Q1","past") = 300 ;
        P_premBFF("m4","Q1","past") = 300 ;
        P_premBFF("m5","Q1","past") = 300 ;

        P_premBFF("m0","Q2","past") = 700 ; 
        P_premBFF("m1","Q2","past") = 700 ;
        P_premBFF("m2","Q2","past") = 700 ;
        P_premBFF("m3","Q2","past") = 700 ;
        P_premBFF("m4","Q2","past") = 700 ;
        P_premBFF("m5","Q2","past") = 700 ;