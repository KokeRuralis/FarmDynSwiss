********************************************************************************
$ontext

   FARMDYN project

   GAMS file : TREAT_INFES.GMS

   @purpose  : Try to solve infeasible model with other option file
               and solver and abort if no feasible solution is found
   @author   : W. Britz
   @date     : 21.12.10
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter.gms

$offtext
********************************************************************************

    if (  (m_farm.modelstat eq 3) or (m_farm.modelstat eq 4)
       or (m_farm.modelstat eq 10) or (m_farm.modelstat eq 19)
       or (m_farm.modelstat eq 14),

       display " - infeasible, before relax ",m_farm.sumInfes;

       m_farm.optfile = 2;
       m_farm.solprint  = 1;
       solve m_farm using %1 maximizing v_obje;
       if (  (m_farm.modelstat eq 3) or (m_farm.modelstat eq 4)
          or (m_farm.modelstat eq 10) or (m_farm.modelstat eq 19)
          or (m_farm.modelstat eq 14),
            display " - infeasible after relax",m_farm.sumInfes;

*$ifi %solver%==CPLEX     option MIP=GUROBI;
*$ifi %solver%==ODHCPLEX  option MIP=GUROBI;
*$ifi %solver%==GUROBIE   option MIP=CPLEX;

*         solve m_farm using %1 maximizing v_obje;
          if (  (m_farm.modelstat eq 3) or (m_farm.modelstat eq 4)
             or (m_farm.modelstat eq 10) or (m_farm.modelstat eq 19)
             or (m_farm.modelstat eq 14),
            option %RMIP%=CONOPT4;
            m_farm.optfile   = 1;
            m_farm.solprint  = 1;
            m_farm.solvelink = 1;
            m_farm.reslim    = 5*60;
            m_farm.limcol    = max(%limcol%,1000);
            m_farm.limrow    = max(%limrow%,1000);
            solve m_farm using %RMIP% maximizing v_obje;

            execute 'test -e  %curDir%\flags\%scen%.flag && rm %curDir%\flags\%scen%.flag';
            $$include 'solve/del_temp_files.gms'

$iftheni.abort %herd%==true
       abort "Error in model structure, in exp_starter, %2: infeasible",actHerds,possHerds,herds_from_herds;
$else.abort
       abort "Error in model structure, in exp_starter, %2: infeasible";
$endif.abort


          );
       );
       $$ifi "%stochProg%"=="true" $include 'model/copy_stoch.gms'
    );


