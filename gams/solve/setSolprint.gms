********************************************************************************
$ontext

   FarmDyn project

   GAMS file : SETSOLPRINT.GMS

   @purpose  : Set solprint options from interface for m_farm model
   @author   : W.Britz
   @date     : 30.09.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter.gms

$offtext
********************************************************************************
    m_farm.solprint   = 0;
   $$ifi  "%Solprint%"  == "full Output"             m_farm.solprint = 1;
   $$ifi  "%Solprint%"  == "Variables and equations" m_farm.solprint = 1;
   $$ifi  "%Solprint%"  == "Suppress"                m_farm.solprint = 2;

