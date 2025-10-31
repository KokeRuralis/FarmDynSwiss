********************************************************************************
$ontext

   FARMDYN project

   GAMS file : GEN_INC_FILE.GMS

   @purpose  : Generate include file for specific scenario
   @author   : W.Britz
   @date     : 07.06.12
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : scen_gen.gms

$offtext
********************************************************************************

*
*  --- copy content of current scen file into new one
*      via OS command
*
   execute "cp %curDir%/incgen/expinc.gms %curDir%/incgen/curScen.gms"
*
*  --- put statements will append to the new scen file
*      and overwrite standard setting
*
   put scenFile;
   scenFile.ap = 1;
   scenFile.lw = 30;

$iftheni.scenType "%scenType%"=="Profits"

   put "$SETGLOBAL mode Single Farm Run" /;

$elseifi.scenType "%scenType%"=="Fertilizer Directive"

   put "$SETGLOBAL mode Single Farm Run" /;
   put "$SETGLOBAL RegulationFert FD_2007" /;
   put "$SETGLOBAL useSensLand false" /;

$elseifi.scenType "%scenType%"=="Multi Indicator"

   put "$SETGLOBAL mode Single Farm Run" /;
   put "$SETGLOBAL useSensLand false" /;

$else.scenType

   put "$SETGLOBAL mode Calculate MACs" /;

$endif.scenType
*
*  --- send scen specific parameters to include file
*
   Loop(outFactors,

          put "$SETGLOBAL ",outFactors.tl," ",p_scenParam(scen,outFactors) /;
   );

   put "$SETGLOBAL scenDes curScen " /;

   putClose scenFile;

   put_utility batch 'shell' / "cp %curDir%/incgen/curScen.gms %curDir%/incgen/"scen.tl".gms";
