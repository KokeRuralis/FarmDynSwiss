********************************************************************************
$ontext

   FarmDyn project

   GAMS file : TESTIT.GMS

   @purpose  :
   @author   :
   @date     : 28.02.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************
  parameter p_calibTarget(*,*) /
                                 winterWheat  .""    0.5
                                 winterBarley .""    0
                                 summerCere   .""    0
                                 potatoes     .""    0
                                 sugarBeet    .""    0.25
                                 winterRape   .""    0.25
                                 maizSil      .""    0
                                 idle         .""    0

*                                 cows         .""  %nCows%
*
*  --- Beware: the branch nam is motherCows, the label on v_sumHerd is motherCow
*
*                                 motherCow    .""  %nMotherCows%
*                                 sows         .""  %nSows%
*                                 fattners     .""  %nFattners%
*                                 bulls        .""  %nBulls%
*                                 heifs        .""  %nHeifs%
*                                 calves       .""  %nCalves%

  /;
