********************************************************************************
$ontext

   FARMDYN project

   GAMS file : LABOUR.GMS

   @purpose  :
   @author   :
   @date     : 12.11.10
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************

$batinclude 'util/title.gms' "'%titlePrefix% Define labour coefficients'"
*
* ---- parameters relating to work off farm
*

  parameter p_wages "Preliminary parameters, mapped to final parameter p_wage below";

  set wageType / "Wage rate full time ","Wage rate half time","Wage rate flexible hourly" /;

  p_wages("Hourly",t) $ p_inputPrices("Wage rate flexible hourly","conv")
    = p_inputPrices("Wage rate flexible hourly","conv") * ([1.+p_inputPrices("Wage rate flexible hourly",'Change,conv % p.a.')/100]**t.pos);

  p_wages("half",t) $ p_inputPrices("Wage rate half time","conv")
    = p_inputPrices("Wage rate half time","conv") * ([1.+p_inputPrices("Wage rate half time",'Change,conv % p.a.')/100]**t.pos);

  p_wages("full",t) $ p_inputPrices("Wage rate full time","conv")
    = p_inputPrices("Wage rate full time","conv") * ([1.+p_inputPrices("Wage rate full time",'Change,conv % p.a.')/100]**t.pos);

$ifthen setglobal wageRateHourly
   $$eval wageRateHourly round(%wageRateHourly%,2)
   p_wages("Hourly",t)       =    %wageRateHourly% * ([1+%outputPriceGrowthRate%/100]**t.pos);
$endif

$ifthen setglobal wageRateHalf
   $$eval wageRateHalf round(%wageRateHalf%,2)
   p_wages("half",t)         =   %wageRateHalf% * ([1+%outputPriceGrowthRate%/100]**t.pos);
$endif

$ifthen setglobal wageRateFull
   $$eval wageRateFull round(%wageRateFull%,2)
   p_wages("full",t)         =  %wageRateFull% * ([1+%outputPriceGrowthRate%/100]**t.pos);
$endif

  parameter p_workT,p_commT;
*
* --- weekly work time
*
  p_workT("half")         = 20;
  p_workT("full")         = 40;
*
* --- commuting time from farm to work (days per week times hours)
*
  p_commT("half")         = 3 * 1;
  p_commT("full")         = 5 * 1;
*
* --- construct a sequence of half, full, half+full, 2 full, 2 full + half, 3 full ...
*
  p_workTime(workType) =   (p_workT("Half")+p_workT("Full")*floor(workType.pos/2))  $ ( mod(workType.pos,2) eq 1)
                         +  p_workT("Full")*(workType.pos/2 )                       $ ( mod(workType.pos,2) eq 0);

  p_commTime(workType) =   (p_commT("Half")+p_commT("Full")*floor(workType.pos/2))  $ ( mod(workType.pos,2) eq 1)
                         +  p_commT("Full")*(workType.pos/2 )                       $ ( mod(workType.pos,2) eq 0);

  p_wage(workType,t)     =   ((p_workT("Half")*p_wages("half",t)+p_workT("Full")*p_Wages("full",t)*floor(workType.pos/2))  $ ( mod(workType.pos,2) eq 1)
                           +     p_workT("Full")*p_wages("full",t)*(workType.pos/2 )                                           $ ( mod(workType.pos,2) eq 0))
                              / p_workTime(workType);


  p_wage("hourly",t) = p_wages("hourly",t);
*
* --- Crop labour definition
*
  $$if not defined c_t_i set c_t_i(crops,till,intens);
  c_t_i(curCrops,till,intens) $ sum(c_p_t_i(curCrops,plot,till,intens),1) = YES;

  $$if not defined curOperation set curOperation(operation);
  curOperation(operation) = yes;
  curOperation(operation) $ (not op_attr(operation,"67kw","2","labtime")) = no;
*
*  --- sum labour hour needs over operations for each month,
*      accounting for effect of mechanisation and plot size
*
   p_cropLab(c_t_i(curCrops,till,intens),m)

     =
*
* --- crops included in KTBL database
*
$iftheni.data "%database%" == "KTBL_database"
   sum((operation),
          p_opInputReq(curCrops,till,"labTime",operation)
          $ (sum((amount,labperiod),  p_crop_op_per_tillaKTBL(curCrops,operation,labperiod,till,amount)
          $ labPeriod_to_month(labPeriod,m))))
$endif.data
*
* --- crops not included in KTBL database
*
+     sum( (curOperation(operation),actmachVar,act_rounded_plotsize,labPeriod_to_month(labPeriod,m))
                  $((not contractOperation(operation)
                  $$iftheni.data "%database%" == "KTBL_database"
                  $(not (sum(operationID $operationID_operation(operationID,operation),1)))
                  $$endif.data
                  )),
              p_crop_op_per_till(curCrops,operation,labPeriod,till,intens)
                     * op_attr(operation,"67kW","2","labTime")
*
*                    -- effect of plot size and mechanisation on labour time
*
                         * p_plotSizeEffect(curCrops,actMachVar,"labTime",act_rounded_plotsize)
                          /p_plotSizeEffect(curCrops,"67kW","labTime","2")
               )
               $$iftheni.data "%database%" == "KTBL_database"
               $ (not c_p_t_i_GDX(curCrops,"plot",till,"normal"))
               $$endif.data
 ;


* --- contract labor requirements
   p_contractLab(c_t_i(curCrops,till,intens))

     =
*     --- crops not included in KTBL database
      sum( (curOperation(operation),actmachVar,act_rounded_plotsize,labPeriod) $ contractOperation(operation) ,
              p_crop_op_per_till(curCrops,operation,labPeriod,till,intens)
                     * op_attr(operation,"67kW","2","labTime")
*
*                    -- effect of plot size and mechanisation on labour time

                         * p_plotSizeEffect(curCrops,"200kw","labTime",act_rounded_plotSize)
                          /p_plotSizeEffect(curCrops,"67kW","labTime","2")
               )

                $$iftheni.data "%database%" == "KTBL_database"
                   $ (not c_p_t_i_GDX(curCrops,"plot",till,"normal"))
*                   ---- crops included in KTBL database
                    +    sum(operation,
                            p_opInputReq(curCrops,till,"contractlab",operation)
                              $ (sum((amount,labperiod),  p_crop_op_per_tillaKTBL(curCrops,operation,labperiod,till,amount))))
               $$endif.data
               ;

$ifthen.gras defined grassTill

*
   p_cropLab(curCrops(grassCrops),till,intens,m) $ (not sum(plot,c_p_t_i(grassCrops,plot,till,intens))) = 0;

   p_cropLab(past,grassTill,intens,m) $ sum(plot,c_p_t_i(past,plot,grassTill,intens))
*
*  --- assume 1 hours a month if 0.5 tons of dry matter are grazed = 12 hours at a usable dry matter yield of 6 tons
*
    = p_cropLab(past,grassTill,intens,m)
       + 1.0 * sum(pastOutPuts,  p_grasAttr(past,pastOutputs,m)*( 1                       $ sameas(grassTill,"noTill")
                                                                  +  p_organicYieldMult(past) $ sameas(grassTill,"org")))/0.5;
*
*  --- assume extra time for fast rotationalGraz
*
   p_cropLab(rotationalGraz,grassTill,intens,m) $ sum(plot,c_p_t_i(rotationalGraz,plot,grassTill,intens))
      = p_cropLab(rotationalGraz,grassTill,intens,m)
         + 1.2 * sum(pastOutPuts,  p_grasAttr(rotationalGraz,pastOutputs,m)
              *(1 $ sameas(grassTill,"noTill") + p_organicYieldMult(rotationalGraz) $ sameas(grassTill,"org") ) /0.5);

$endif.gras

*
* --- check for crops without any labour needs
*
  if ( sum( c_p_t_i(curCrops(crops),plot,till,intens) $ (not ( sum(m, p_cropLab(crops,till,intens,m)) or idle(crops)
     $$iftheni.e"%ecoSchemesCapPillar1%" == "true"
        or ES1crops(crops)
    $$endif.e
  )),1),

      c_p_t_i(curCrops,plot,till,intens) $ ( sum(m, p_cropLab(curCrops,till,intens,m)) or idle(curCrops)) = no;
      abort "Crops without any labour requirements in file: %system.fn%, line: %system.incline%",c_p_t_i,p_cropLab%L%;
  );

*  ---------------------------------------------------------------------------------
*
*    Labour need for general management
*
*  ---------------------------------------------------------------------------------
*

*
*  -- slope/const term from page 791-793 KTBL 2014/2015,  Arable:   50 until 1000 ha
*                                                         Dairy:    30 until 300 cows
*                                                         Sows:     40 until 300 sows
*                                                         Fattener: 100 until 1500 fattener
*                                                         (DS 25/09/2015)
*
  table p_labManag(branches,regPar)
                       const               slope
    CAP                   8
    farm                200
    cashCrops           288                 0.47
  ;
  $$ifi "%farmBranchDairy%"=="on"      p_labManag("dairy","const")      = 179;p_labManag("dairy","slope")      = 6.71;
  $$ifi "%farmBranchMotherCows%"=="on" p_labManag("MotherCows","const") = 100;p_labManag("MotherCows","slope") = 1;
  $$ifi "%farmBranchBeef%"=="on"       p_labManag("Beef","const")       = 100;p_labManag("Beef","slope")       = 0.5;
  $$ifi "%farmBranchSows%"=="on"       p_labManag("sowPig","const")     = 145;p_labManag("Sowpig","slope")     = 1.974;
  $$ifi "%farmBranchFattners%"=="on"   p_labManag("fatPig","const")     = 151;p_labManag("fatPig","slope")     = 0.13;
   ;
