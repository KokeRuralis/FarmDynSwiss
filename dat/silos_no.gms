********************************************************************************
$ontext

   CAPRI project

   GAMS file : SILOS_NO.GMS

   @purpose  : Introduce silo sizes and related cost - values for Norway
   @author   : Klaus
   @date     : 11.03.21
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************
$iftheni.mode "%1"=="decl"

* ---  different silo manure storage sizes


     set silos /silo0,silo100,silo10000/;

$else.mode


* --- data relating to manure silo types in m^3

  $$onmulti

        parameters p_ManStorCapSi(silos) "manure storage capacity of singel silos"

         /
           silo0       eps
           silo100     100
*           silo1000   1000
           silo10000 10000
        /;

  $$offmulti

* --- costs for addtitional coverage of silos with straw or foil


     table p_siloCovCost(silos,manStorage) "coverage costs for different types and sizes of slurry reservoirs per silo"
*                                   prices for foil coverage from LWK-NRW ("Abedeckungen von G�llebeh�ltern", Hans-Heinrich Ellersiek)

                   stornocov  storstraw    storfoil
       silo100       0          100         400
*       silo500       0          100        800
*       silo1000      0          250        2000
       silo10000     0          800        5500
     ;

p_siloCovCost(silos,manStorage) = p_siloCovCost(silos,manStorage) * %EXR%;

$iftheni.cs "%dynamics%" == "comparative-static"

* --- Annual building costs (investement and maintance, without costs for interest)
*     taken from "Betriebsplanug Landwirtschaft 2016/17" p. 153
*     (Guellebehaelter aus Betonfertigteilen, 1m im Boden mit Leakageerkennung)
*     Values for 500, 1500, 3000, and 5000 taken from KTBL, values for missing sizes are derived from them


     p_priceSilo("silo0",t)     =  1;
     p_priceSilo("silo100",t)   =  6.63  * p_ManStorCapSi("silo100")   ;
*     p_priceSilo("silo1000",t)  =  4.86  * p_ManStorCapSi("silo1000")  ;
     p_priceSilo("silo10000",t) =  1.67  * p_ManStorCapSi("silo10000") ;

     p_priceSilo(silos,t) = p_priceSilo(silos,t) * %EXR%;

* --- lifetime of silos in years - KTBL 2014/2015, p. 144

  p_lifeTimeSi(silos) = 1;


$else.cs

* --- investment costs for silo storage differentiating by size. Values taken from "Betriebsplanung Landwirtschaft 2014/15" p. 145.
*     (Guellerundbehaelter aus Ortbeton)

  p_priceSilo("silo0",t)    = 0.1;
  p_priceSilo("silo100",t)  =  63   * p_ManStorCapSi("silo100")   * ([1.+%OutputPriceGrowthRate%/100] ** t.pos);
*  p_priceSilo("silo1000",t)  = 48.5 * p_ManStorCapSi("silo1000")  * ([1.+%OutputPriceGrowthRate%/100] ** t.pos);
  p_priceSilo("silo10000",t) = 22   * p_ManStorCapSi("silo10000") * ([1.+%OutputPriceGrowthRate%/100] ** t.pos);

  p_priceSilo(silos,t) = p_priceSilo(silos,t) * %EXR%;

  p_lifeTimeSi(silos)   = 30;

$endif.cs

$endif.mode
