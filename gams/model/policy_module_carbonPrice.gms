$ontext

   FARMDYN project

   GAMS file : carbon_policy_de.GMS

   @purpose  : Variables and equations related to agri-environmental schemes

   @author   : D.Schaefer
   @date     : 01.04.22
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : templ.gms

$offtext
********************************************************************************

parameters p_carbonPrice    "Carbon price in € per kg CO2eq - Conversion from Euro per t to Euro per kg CO2eq";
           p_carbonPrice = %carbonPrice%/1000;

positive variables
        v_carbonCost(t,n)  "Costs for carbon based on carbon price in Euro per kg CO2eq";

equations
        carbonCost_(t,n)   "Determines the carbon cost based on the total CO2eq emissions on farm";


  carbonCost_(t_n(tFull(t),nCur)) ..

      v_carbonCost(t,nCur) =G= p_carbonPrice * v_emissionsCatSum("GWP",t,nCur);

 model m_policyCarbon
      /
      carbonCost_
       /;
