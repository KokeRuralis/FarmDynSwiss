********************************************************************************
$ontext

   FARMDYN project

   GAMS file : FARM_INI.GMS

   @purpose  : Define land endowments, climate zone, soils and
               plot sizes and their link to soil/land type

   @author   : W.Britz and other FarmDyn group members
   @date     : 31.07.13
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter.gms

$offtext
********************************************************************************

   curClimateZone("%curClimateZone%") = YES;
*
*  --- scale soil shares edited by user to add up to unity
*
   p_soilShare(soil,"Share") = p_soilShare(soil,"Share") * 1 / sum(soil1, p_soilShare(soil1,"Share"));


*
*  --- Regional climate and soil data (overwrites the data given in the GUI for climate zone and soil)
*
$ifi "%useRegionalDataSoilAndClimate%"=="ON" $include 'regionalData/Climate_soil.gms'

$iftheni.task not "%task%"=="Farm sample run"

$ifi not set nArabland $setglobal nArabland 0
   p_nArabLand = %nArabland%;
$ifi not set nGrasLand $setglobal nGrasLand 0
   p_nGrasLand = %nGrasLand%;
$ifi not set nPastLand $setglobal nPastLand 0
   p_nPastLand = %nPastLand%;
$ifi not set nTotLand $setglobal nTotLand 0
   p_nTotLand  = %nTotLand%;
$ifi not set LandscapeElements $setglobal LandscapeElements 0
   p_landscapeElements =  %LandscapeElements% ;

   p_totalLand = p_nArabLand + p_nGrasLand + p_nPastLand + p_landscapeElements ;
    
*---------------------------------------------------------------------------------
*
*      Number of animals
*
*---------------------------------------------------------------------------------

* ---- Number of animals given by GUI

  $$ifi  %cowHerd% == true              p_nCows       = round(%nCows%) ; p_nHeifs = round(%nHeifs%); p_nCalves = round(%nCalves%);
  $$ifi "%farmBranchFattners%"=="on"    p_nFattners   = round(%nFattners%) ;
  $$ifi "%farmBranchSows%"=="on"        p_nSows       = round(%nSows%) ;
  $$ifi "%farmBranchMotherCows%"=="on"  p_nMotherCows = round(%nMotherCows%);
  $$ifi "%farmBranchBeef%"=="on"        p_nBulls      = round(%nBulls%) ;
*
* --- When flexible land endowment (two different ways to define) is chosen, animal number can be defined based on LU/ha
*

* --- (1) Based on total amount of grass and arable land

$iftheni.laEnd "%landEndo%" == "Total arab and grass land"

    $$iftheni.LUdens "%DefineHerdSize%" == "LU per ha"

* --- Animal number derived from GUI land endownment and LU/ha, for dairy, a correction factor is needed

      $$ifi %cowHerd% == true             p_nCows       = round ( ( %nArabland% + %nArabland% + %nPastLand%) * %CowsLUdensity% * 0.81 / 1) ;
      $$ifi %cowHerd% == true             $evalglobal  nCows      round ( ( %nArabland% + %nGrasLand% + %nPastLand% ) * %CowsLUdensity% * 0.81 / 1)
      $$ifi "%farmBranchFattners%"=="on"  p_nFattners   = round( %nArabland% * %fattnersLUdensity%   /  0.16);
      $$ifi "%farmBranchFattners%"=="on"  $evalglobal nFattners  round( %nArabland% * %fattnersLUdensity%   /  0.16)
      $$ifi "%farmBranchSows%"=="on"      p_nSows       = round ( %nArabland% * %SowsLUdensity%  / 0.48) ;
      $$ifi "%farmBranchSows%"=="on"      $evalglobal nSows round ( %nArabland% * %SowsLUdensity%  / 0.48)


    $$endif.LUdens

* --- (2) Based on total amount of land and share of grassland

$elseifi.laEnd "%landEndo%" == "Total land and grass share"

    $$iftheni.LUdens "%DefineHerdSize%" == "LU per ha"

*     --- Animal number derived from GUI land endownment and LU/ha, for dairy, a correction factor is needed

      $$ifi  %cowHerd% == true            p_nCows       = round ( p_nTotLand * %CowsLUdensity% * 0.81 / 1) ;
      $$ifi  %cowHerd% == true            $evalglobal  nCows   round( %nTotLand% * %CowsLUdensity% * 0.81 / 1)
      $$ifi "%farmBranchFattners%"=="on"  p_nFattners   = round( p_nTotLand * %fattnersLUdensity%   /  0.16);
      $$ifi "%farmBranchFattners%"=="on"  $evalglobal nFattners round( %nTotLand% * %fattnersLUdensity%   /  0.16)
      $$ifi "%farmBranchSows%"=="on"      p_nSows       = round ( %nTotLand% * %SowsLUdensity%  / 0.48 );
      $$ifi "%farmBranchSows%"=="on"      $evalglobal nSows round ( %nArabland% * %SowsLUdensity%    / 0.48)
    $$endif.LUdens

$elseifi.laEnd "%landEndo%" == "Land endowment per plot"
*
* ---- Land endowment per plot: The user can define the land endowment for specific plots with specific attributes
*
*

   p_nArabLand=sum(plot$(p_plots(plot,"arab")=1),p_plots(plot,"sizeHa"));
   p_nGrasLand=sum(plot$((not p_plots(plot,"arab")=1) and (p_plots(plot,"gras")=1)),p_plots(plot,"sizeHa"));
   p_nPastLand=sum(plot$((not p_plots(plot,"arab")=1) and (not p_plots(plot,"gras")=1)),p_plots(plot,"sizeHa"));
$endif.laEnd

* --------------------------------------------------------------------------------
*
*      Land endowment
*
* --------------------------------------------------------------------------------


$iftheni.cowHerd %cowHerd% == true

*  --- initial milk yield of the herd and its size
*      as edited by user in GUI
*
   $$ifi %dairyHerd% == true              p_iniHerd(dcows,"%basBreed%") = p_nCows / 2;
   $$ifi "%farmBranchMotherCows%" == "on" p_iniHerd("motherCow","%motherCowBreed%") = %nMotherCows%;

*  --- default settings for maximum stocking rate and share of arable land
*
   $$if not setGlobal maxStockingRate $setGlobal maxStockingRate 2.00

   $$ifi not "%farmBranchArable%" == on $setGlobal cowsPerHaArab 0.0
$endif.cowHerd

$iftheni.beef "%farmBranchBeef%" == on
   p_iniHerd("bulls",curBreeds) = p_nBulls;
$endif.beef
*
*  ----- Land endowment: given hectares, total and shares, per animal or per AWU
*

$iftheni.laEnd "%landEndo%" == "Total arab and grass land"

*  ---- Flexible land endowment: The user can set the initial land endowment
*                                without any connection to average working units and animals

   p_iniLand("arab", soil) = p_nArabLand * p_soilShare(soil,"Share");
   $$iftheni.gras %cattle% == true
       p_iniLand("gras", soil) = p_nGrasLand * p_soilShare(soil,"Share");
       p_iniLand("past", soil) = p_nPastLand * p_soilShare(soil,"Share");
   $$endif.gras


$elseifi.laEnd "%landEndo%" == "Total land and grass share"
*
*  ----  Flexible land endowment can also be defined as total land and share of grasland;
*         only relevant for dairy farms for other
*        branches same result like using "Flexible land endowment (total arab and grass land)"

   $$iftheni.cattle %cattle% == true

      p_iniLand("gras", soil) = p_nTotLand * %ShareGrassLand%         * p_soilShare(soil,"Share") ;
      p_iniLand("past", soil) = p_nTotLand * %SharePastLand%          * p_soilShare(soil,"Share") ;
      p_iniLand("arab", soil) = p_nTotLand * ( 1 - %ShareGrassLand%  - %sharePastLand% ) * p_soilShare(soil,"Share") ;

   $$else.cattle

      p_iniLand("arab", soil) = p_nTotLand * p_soilShare(soil,"Share");

   $$endif.cattle

$elseifi.laEnd "%landEndo%" == "Land endowment per animal"

* ---- Land endowment per animal: The user can set the initial land endowment per initial animal herd for cows, sows and fattners

   $$iftheni.dh %cowherd% == true
      $$ifi %arable% == true  p_iniLand("arab",soil)  = (%nCows%+%nMotherCows%-0.75) * %cowsPerHaArab% * p_soilShare(soil,"Share");
*     p_iniLand("gras",soil) + p_iniLand("past",soil)  = (%nCows%+%nMotherCows%-0.75) * %cowsPerHaGras% * p_soilShare(soil,"Share");
      p_iniLand("gras",soil) = (%nCows%+%nMotherCows%-0.75) * %cowsPerHaGras% * p_soilShare(soil,"Share");
      p_iniLand("past",soil) = 0;
   $$endif.dh
   $$iftheni.ft "%farmBranchFattners%" == "on"
      p_iniLand("arab",soil)  = %nFattners% * %fattnersPerHaArab% * p_soilShare(soil,"Share");
   $$endif.ft
   $$iftheni.sow "%farmBranchSows%" == "on"
      p_iniLand("arab",soil)  = %nSows% * %sowsPerHaArab% * p_soilShare(soil,"Share");
   $$endif.sow

$elseifi.laEnd "%landEndo%" == "Land endowment per AWU"
*
* ---- Land endowment per AWU: The user can set initial land endwoment
*      per average working unit. The initial land will be adjusted depending
*      on plot size and for animal herds.

       p_iniLand("arab",soil) = %Aks% * 52 * 40 /sum(act_rounded_plotsize,
                                              20 $ sameas(act_rounded_plotsize,"2")
                                           +  25 $ sameas(act_rounded_plotsize,"1")
                                           +  18 $ sameas(act_rounded_plotsize,"5")
                                           +  15 $ sameas(act_rounded_plotsize,"20")) * p_soilShare(soil,"Share")
                       * (1
      $$ifi %pigHerd% == true     - 0.75
      $$ifi %dairyherd% == true   - 0.35
                       );
      $$iftheni.dh %dairyherd% == true
         p_iniLand("gras",soil) = %Aks% * 52 * 40    * 0.45 * p_soilShare(soil,"Share");
      $$endif.dh

$elseifi.laEnd "%landEndo%" == "Land endowment per plot"
*
* ---- Land endowment per plot: The user can define the land endowment for specific plots with specific attributes
*
   p_nArabLand=sum(plot$(p_plots(plot,"arab")=1),p_plots(plot,"sizeHa"));
   p_nGrasLand=sum(plot$((not p_plots(plot,"arab")=1) and (p_plots(plot,"gras")=1)),p_plots(plot,"sizeHa"));
   p_nPastLand=sum(plot$((not p_plots(plot,"arab")=1) and (not p_plots(plot,"gras")=1)),p_plots(plot,"sizeHa"));

$endif.laEnd


$ifi not "%farmBranchArable%" == on p_iniLand("arab",soil) = 0;


* --- Initializing the pig herd

$iftheni.ph %pigherd% == true

  $$ifi "%farmBranchFattners%"=="on"    p_iniHerd("fattners","")           = p_nFattners ;
  $$ifi "%farmBranchSows%"=="on"        p_iniHerd("sows","")                  = p_nSows ;

*
* --- As we have piglets who are 2 months before in the herd before they are sold we have an initial herd of a
*     sixth of the total piglets a sow is birthing each year
  $$ifi "%farmBranchSows%"=="on"        p_iniHerd("piglets","")               = p_nSows * 26.63 / 6 ;

$endif.ph

$else.task

    p_iniLand("arab", soil) = p_nArabLand * p_soilShare(soil,"Share");
   $$iftheni.gras %cattle% == true
       p_iniLand("gras", soil) = p_nGrasLand * p_soilShare(soil,"Share");
       p_iniLand("past", soil) = p_nPastLand * p_soilShare(soil,"Share");
   $$endif.gras

  $$ifi "%farmBranchFattners%"=="on"    p_iniHerd("fattners","")           = p_nFattners ;
  $$ifi "%farmBranchSows%"=="on"        p_iniHerd("sows","")                  = p_nSows ;
*
* --- As we have piglets who are 2 months before in the herd before they are sold we have an initial herd of a
*     sixth of the total piglets a sow is birthing each year
  $$ifi "%farmBranchSows%"=="on"        p_iniHerd("piglets","")               = p_nSows * 26.63 / 6 ;

  $$ifi "%farmBranchDairy%"      == "on" p_iniHerd(dcows,"%basBreed%") = p_nCows / 2;
  $$ifi "%farmBranchMotherCows%" == "on" p_iniHerd("motherCow","%motherCowBreed%") = p_nMotherCows;
  $$ifi "%farmBranchBeef%" == "on"       p_iniHerd("bulls",curBreeds)              = p_nBulls;


$endif.task



$$iftheni.PlotEndo not "%landEndo%" == "Land endowment per plot"

   $$iftheni.nPlot not "%nPlot%" == "1"

*
*  --- average plot size (= total land divided by # of plots)
*
   scalar p_pertub; p_perTub = min(0.90,1-1/%nPlot%);

   scalar p_ii / 0 /;
   if ( card(plot) eq card(p_iniLand),

      loop((landType,soil) $ p_iniLand(landType,soil),
          p_ii = p_ii+1;

         p_plotSize(plot) $ ( plot.pos eq p_ii)
           = p_iniLand(landType,soil);
       );

   else
       p_plotSize(plot) = sum( (landType,soil), p_iniLand(landType,soil))/card(plot)
                                           * (1-p_perTub + 2*p_perTub/card(plot) * plot.pos);
   );
*
*  --- assign # of plot to soil accorind to shares (~ approx. due to
*      integer character)
*
   SOS1 variables

        v_plotSoil(plot,soil)
        v_plotLandType(plot,landType)
   ;

   positive variable
        v_plotSize(plot)
        v_landTypeSize(landType)
        v_soilSize(soil)
   ;

   free variables
        v_objePlot
   ;
   equation

     e_plotSoil(plot)
     e_plotLandtype(plot)
     e_sumLandType(landType)
     e_sumSoil(soil)
     e_sumLand
     e_objePlot
   ;

  e_plotSoil(plot) ..

        sum(soil, v_plotSoil(plot,soil)) =E= 1;

  e_plotLandtype(plot) ..

        sum(landType, v_plotLandType(plot,landType)) =E= 1;

  e_sumLandType(landType) ..

        sum(plot, v_plotLandType(plot,landType) * v_plotSize(plot)) =E= v_landTypeSize(landType);

  e_sumSoil(soil) ..

        sum(plot, v_plotSoil(plot,soil)         * v_plotSize(plot)) =E= v_soilSize(soil);

  e_sumLand ..

        sum(landType, v_landTypeSize(landType)) =E= sum( (landType,soil), p_iniLand(landType,soil));



  e_objePlot ..

        v_objePlot =G=
                      + sum( landType $ sum(soil, p_iniLand(landType,soil)),
                           sqr( (v_landTypeSize(landType)
                                - sum(soil, p_iniLand(landType,soil)))
                                     /sum(soil,p_iniLand(landType,soil))))/card(landType)

                      + sum( soil $ sum(landType, p_iniLand(landType,soil)),
                           sqr( (v_soilSize(soil)
                             - sum(landType, p_iniLand(landType,soil)))/sum(landType,p_iniLand(landType,soil))))/card(soil)

                      + 0.1*sum( plot, sqr((v_plotSize(plot) - p_plotSize(plot))/p_plotSize(plot)))/card(plot)
        ;



  model m_plot /

     e_plotSoil
     e_plotLandtype
     e_sumLandType
     e_sumSoil
     e_sumLand
     e_objePlot

  /;

 v_plotSize.l(plot) = p_plotSize(plot);
 m_plot.solprint  = 2;
 m_plot.solvelink = 5;
 solve m_plot using RMINLP minimizing v_objePlot;

 alias (plot,plot1,plot2);
 alias(landType,landType1);

 set curPlot(plot);
 alias(curPlot,curPlot1);

 loop(plot1,

    curPlot(plot) = yes $ (smax( (plot2,landType) $ (v_plotLandType.range(plot2,landType) ne 0),
                                            v_plotSize.l(plot2))
                             eq v_plotSize.l(plot));
    curPlot(curPlot1) $ ( (card(curPlot) gt 1) and (curPlot1.pos ne 1) ) = no;

    v_plotSoil.fx(curPlot,soil)         = 1 $ (smax(soil1,     v_plotSoil.l(curPlot,soil1))         eq v_plotSoil.l(curPlot,soil));

    v_plotLandType.fx(curPlot,landType) = 1 $ (smax(landType1, v_plotLandType.l(curPlot,landType1)) eq v_plotLandType.l(curPlot,landType));
    solve m_plot using RMINLP minimizing v_objePlot;


 );


 m_plot.holdfixed = 0;
 solve m_plot using RMINLP minimizing v_objePlot;

 p_plotSize(plot) = v_plotSize.l(plot);

 plot_soil(plot,soil) $ (v_plotSoil.l(plot,soil) gt 0.5) = YES;
 plot_lt_soil(plot,landType,soil) $ ( (v_plotSoil.l(plot,soil) gt 0.5) $ ( (v_plotLandType.l(plot,landType) gt 0.5))) = YES;


$else.nPlot
*
*   --- only one plot arab / grassland
*

   $$iftheni.FO2020 not %fertOrdFile% == "fertord_duev2020"

      $$iftheni.arab not %arabShare% == 0.0

        plot_lt_soil("plot1","arab","l") = YES;
        plot_lt_soil("plot2","arab","m") = YES;
        plot_lt_soil("plot3","arab","h") = YES;

      $$endif.arab

      $$iftheni.cattle %cattle% ==true

        plot_lt_soil("plot4","gras","l") = YES;
        plot_lt_soil("plot5","gras","m") = YES;
        plot_lt_soil("plot6","gras","h") = YES;

        plot_lt_soil("plot7","past","l") = YES;
        plot_lt_soil("plot8","past","m") = YES;
        plot_lt_soil("plot6","past","h") = YES;

      $$endif.cattle

        plot_soil(plot,soil)          = sum(plot_lt_soil(plot,landType,soil),1);
        p_plotSize(plot)              = sum(plot_lt_soil(plot,landType,soil), p_iniLand(landType,soil));



   $$else.FO2020

      $$iftheni.arab not %arabShare% == 0.0
         plot_lt_soil("plot1","arab","l") = YES;
         plot_lt_soil("plot2","arab","l") = YES;

         p_plotSize("plot1") =  p_nArabLand * (1 - %ShareArableLandRedZone%) ;
         p_plotSize("plot2") =  p_nArabLand *  %ShareArableLandRedZone%      ;
      $$endif.arab

      $$iftheni.cattle %cattle% ==true
         plot_lt_soil("plot4","gras","l") = YES;
         plot_lt_soil("plot5","gras","l") = YES;
         plot_lt_soil("plot7","past","l") = YES;
         plot_lt_soil("plot8","past","l") = YES;

         p_plotSize("plot4") =  p_nGrasLand * (1 - %ShareGrassLandRedZone%) ;
         p_plotSize("plot5") =  p_nGrasLand *  %ShareGrassLandRedZone% ;
         p_plotSize("plot7") =  p_nPastLand *  (1- %SharePastureRedZone%) ;
         p_plotSize("plot8") =  p_nPastLand * %SharePastureRedZone%;
      $$endif.cattle

         plot_soil(plot,soil)     = sum(plot_lt_soil(plot,landType,soil),1);

      $$endif.FO2020

$endif.nPlot
$$else.PlotEndo
p_plotSize(plot) = p_plots(plot,"sizeHa");

plot_soil(plot,"l") $(p_plots(plot,"soil")=1) = Yes;
plot_soil(plot,"m") $(p_plots(plot,"soil")=2) = Yes;
plot_soil(plot,"h") $(p_plots(plot,"soil")=3) = Yes;

plot_lt_soil(plot,"arab",soil) $(plot_soil(plot,soil) $(p_plots(plot,"arab")=1) )= Yes;
plot_lt_soil(plot,"gras",soil) $(plot_soil(plot,soil) $( (not p_plots(plot,"arab")=1) and (p_plots(plot,"gras")=1)))= Yes;
plot_lt_soil(plot,"past",soil) $(plot_soil(plot,soil) $(not p_plots(plot,"gras")=1) and (not p_plots(plot,"arab")=1) and ( p_plots(plot,"past")=1)) = Yes;

*Adjust soil share
   p_iniLand(landtype, soil) = sum(plot $plot_lt_soil(plot,landtype,soil), p_plots(plot,"sizeHa"));

$$endif.PlotEndo
*
*  --- remove plot without size or linked to land type (arab,gras,past) which size is zero
*
   plot_lt_soil(plot,landType,soil) $ (not p_plotSize(plot))         = No;
   plot_lt_soil(plot,landType,soil) $ (not p_iniLand(landType,soil)) = No;
   plot_soil(plot,soil)             $ (not sum(plot_lt_soil(plot,landType,soil),1)) = NO;

   plot_landType(plot,landtype)  = sum(plot_lt_soil(plot,landType,soil),1);

   soil_plot(soil,plot) = plot_soil(plot,soil);
