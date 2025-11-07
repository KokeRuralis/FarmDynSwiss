********************************************************************************
$ontext

   FarmDyn project

   GAMS file : social_DE.GMS

   @purpose  : Factors for social accounting
   @author   : L. Kokemohr
   @date     : 28.11.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************
$$iftheni.ch %cattle% == true

$$iftheni.data "%database%"=="User_database"

Table p_shareFood(*,soci)
                               protein      calories
           WinterWheat          0.66           0.68
           WinterBarley         0.61           0.63
           WinterRye            0.61           0.63
           SummerCere           0.66           0.68
           SummerTriticale      0.66           0.68
           WinterRape           0              0.57
           Potatoes             0              0
           Sugarbeet            0              0
           MaizCorn             0.15           0.63
           MaizCCM              0.15           0.63
           Summerpeas           0.74           0.75
           Summerbeans          0.92           0.83
           WheatGPS             0              0
           MaizSil              0.1            0.32
           ConcCattle1          0.9            0.23
           ConcCattle2          0.7            0.51
           ConcCattle3          0.7            0.62
           milkPowder           0.3            0.3
           SoyBeanMeal          0.61           0.54
           oldCow               0.1            1568
           milk                 0.031          612.07
           mCalv_HF             0.1           1481
           fCalv_HF             0.1           1481
           mCalv_SI             0.1           1439
           fCalv_SI             0.1           1439
           mCalv_MC             0.1           1439
           fCalv_MC             0.1           1439
;


  p_shareFood(allBeef_outputs(prods),"protein") = 0.1;
  p_shareFood(youngAnim,"protein")              = 0.1;


$ifi  defined set_bullsBough       p_shareFood(set_bullsBought,"calories")       = 1436;
$$ifi defined beef_HF_outputs      p_shareFood(beef_HF_outputs,"calories")       = 1436;
$$ifi defined heifbeef_HF_outputs  p_shareFood(heifBeef_HF_outputs,"calories")   = 1562;
p_shareFood("oldcow","calories")              = 1568;

$iftheni.mc "%farmBranchMotherCows%"=="on"
   p_shareFood(beef_MC_outputs,"calories")       = 1517;
   p_shareFood(heifBeef_MC_outputs,"calories")   = 1562;
   p_shareFood(set_heifsBought,"calories")       = 1562;
   p_shareFood("oldcow","calories")              = 1566;
$endif.mc

$iftheni.cross "%crossBreeding%"=="true"
   p_shareFood(beef_SI_outputs,"calories")       = 1517;
   p_shareFood(heifBeef_SI_outputs,"calories")   = 1562;
$endif.cross

$else.data

abort "Factors for social accounting not defined for KTBL crops, in %system.incName%, line %system.incLine%");

$endif.data

$$endif.ch
