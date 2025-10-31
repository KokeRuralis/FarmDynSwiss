********************************************************************************
$ontext

   FarmDyn project

   GAMS file : DEFINE_CATTLE_HERDS.GMS

   @purpose  : Map _type1_ ... entries in tables for bulls and heifers
               to generate descriptions easier to understand
   @author   : W.Britz
   @date     : 04.03.21
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter.gms

$offtext
********************************************************************************
*
* --- embedded phython code to generate sets definition and parameters
*     from attribute tables on GUI
*
$if not set basBreed $setglobal basBreed   HF
$if not set basBreed $setglobal crossBreed CH

$iftheni.cowHerd "%cowherd%"=="true"
  $$ifi defined p_heifsAttrGuiBas $$batinclude 'util/embedd.gms' p_heifsAttrGUIBas   p_heifsAttr %basBreed%_f
  $$ifi "%crossBreeding%"=="true" $$batinclude 'util/embedd.gms' p_heifsAttrGUICross p_heifsAttrCross %CrossBreed%_f
$endif.cowHerd

$iftheni.dh   "%farmBranchMotherCows%"=="on"
  $$batinclude 'util/embedd.gms' p_heifsAttrGUIMC   p_heifsAttrMC %motherCowBreed%_f
  $$ifi "%crossBreeding%"=="true" $$batinclude 'util/embedd.gms' p_heifsAttrGUICross p_heifsAttrCross %CrossBreed%_f

  $$batinclude 'util/embedd.gms' p_BullsAttrGUIMC   p_bullsAttrMC %motherCowBreed%_m
  $$ifi "%crossBreeding%"=="true" $$batinclude 'util/embedd.gms' p_BullsAttrGUICross p_bullsAttrCross %CrossBreed%_m
$endif.dh

$iftheni.beef   "%farmBranchBeef%"=="on"
  $$iftheni.base defined  p_BullsAttrGUIBas
     $$batinclude 'util/embedd.gms' p_BullsAttrGUIBas   p_bullsAttr %basBreed%_m
     $$ifi "%crossBreeding%"=="true" $$batinclude 'util/embedd.gms' p_BullsAttrGUICross p_bullsAttrCross %CrossBreed%_m
  $$endif.base
$endif.beef

$ifi not "%crossBreeding%"=="true" $setglobal crossBreeding false

*
* --- if no basebreed for males and females is given,
*     reset cross breeding to false. This will make
*     sure that the related sets are not generated
*
$$iftheni.breedsDef not declared %basBreed%_m
  $$ifi not declared %basBreed%_f  $setglobal crossBreeding false
$$endif.breedsDef

*
* --- generate emtpy sets if no bulls are in the model
*
$$iftheni.breedsDef not declared %basBreed%_m
      set %basBreed%_m        /system.empty/;
      set %basBreed%_m_sold   /system.empty/;
      set %basBreed%_m_bought /system.empty/;
$endif.breedsDef
*
* --- generate emtpy sets if no females are in the model
*
$iftheni.breedsDef not declared %basBreed%_f
   set %basBreed%_f        /system.empty/;
   set %basBreed%_f_sold   /system.empty/;
   set %basBreed%_f_bought /system.empty/;
$endif.breedsDef

