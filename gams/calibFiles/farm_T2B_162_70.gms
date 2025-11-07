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
                                 winterWheat  .""    0.66
                                 winterBarley .""    0.33
                                 summerCere   .""    eps
                                 potatoes     .""    eps
                                 sugarBeet    .""    eps
                                 winterRape   .""    eps
                                 maizSil      .""    eps
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
