********************************************************************************
$ontext

   FARMDYN project

   GAMS file : FEEDS.GMS

   @purpose  : Nutrient content of feed types
   @author   : Bernd Lengers
   @date     : 18.11.10
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : coeffgen/coeffgen.gms

$offtext
********************************************************************************

$batinclude 'util/title.gms' "'%titlePrefix% Define coefficients relating to feed use'"

$batinclude '%datdir%/%feedsFile%.gms' param

$iftheni.cattle "%cattle%"=="true"
*
*    --- Add grass outputs from GUI
*
     p_feedContDMg(feeds,feedAttr) $ sum(sameas(feeds,grasOutput),1)
       = sum(sameas(feeds,grasOutput), p_nutGras(grasOutput,feedAttr));

*
*    --- Add N-free extracts for environmental accounting (GRUBER Futterwertabellen, ash content estimated from mineral substances)
*       eventually for further differentiation of methane emissions
*
        p_feedContDMg(feeds,"NFE") = 1000
                                   -(   p_feedContDMg(feeds,"XP")
                                      + p_feedContDMg(feeds,"XL")
                                      + p_feedContDMg(feeds,"XF")
                                      + p_feedContDMg(feeds,"CA")
                                      + p_feedContDMg(feeds,"P")
                                      + p_feedContDMg(feeds,"NA")
                                      + p_feedContDMg(feeds,"K"));

*
*    --- add gross energy for environmental accounting
*        Beyer et al. (2004) Rostocker Futterbewertungssystem p.10 in MJ/kg
*
     p_feedContDMg(feeds,"GE") =  (   0.0239 * p_feedContDMg(feeds,"XP")
                                     + 0.0398 * p_feedContDMg(feeds,"XF")
                                     + 0.0175 * p_feedContDMg(feeds,"NFE")
                                     + 0.0398 * p_feedContDMg(feeds,"XL")
                                   );
*
*    --- convert nutrient and energy contents from dry matter to fresh matter
*
     parameter p_feedContFMg(feeds,feedAttr) "1000g of FM feed contain the following nutrients/energy";

     p_feedContFMg(feeds,feedAttr) $ (not sameas(feedAttr,"DM"))
         = p_feedContDMg(feeds,feedAttr) * p_feedContDMg(feeds,"DM")/1000;

     p_feedContFMg(feeds,"DM") = p_feedContDMg(feeds,"DM");


*
*    --- Convert nutrient and energy content in different feeds in kg / ton
*
     p_feedContFMton(feeds,feedAttr) =  p_feedContFMg(feeds,feedAttr);
     p_feedContFMton(feeds,"NEL") =  p_feedContFMg(feeds,"NEL") * 1000;
     p_feedContFMton(feeds,"ME") =  p_feedContFMg(feeds,"ME") * 1000;
     p_feedContFMton(feeds,"GE") =  p_feedContFMg(feeds,"GE") * 1000;
*
*    --- only roughages will provide roughage dry matter (DMR),
*        whereas all feeds provide general dry matter (DMXX)
*
     p_feedContFMton(roughages,"DMR")   =   p_feedContFMton(roughages,"DM");
     p_feedContFMton(roughages,"DMRMX") = - p_feedContFMton(roughages,"DM");
     p_feedContFMton(feeds,"DMMX")      = - p_feedContFMton(feeds,"DM");
     p_feedContFMton(feeds,"XS+XZ")     = - p_feedContFMton(feeds,"XS+XZ");
     p_feedContFMton(feeds,"RNBmax")    = - p_feedContFMton(feeds,"RNB");
     p_feedContFMton(feeds,"RNBmin")    =   p_feedContFMton(feeds,"RNB");

$endif.cattle
