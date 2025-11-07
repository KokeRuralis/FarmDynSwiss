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
                                 winterWheat  .""    0.6
                                 winterBarley .""    0.2
                                 summerCere   .""    0.2
                                 potatoes     .""    0.05
                                 sugarBeet    .""    0.05
                                 winterRape   .""    0.15
$ifi "%cattle%"=="true"          maizSil      .""    0.25
*                                idle         .""    0.05

$ifi set nCows                   cows         .""  %nCows%
*
*  --- Beware: the branch nam is motherCows, the label on v_sumHerd is motherCow
*
$ifi set nMotherCows                           motherCow    .""  %nMotherCows%
$ifi set nSows                                 sows         .""  %nSows%
$ifi set nFattners                             fattners     .""  %nFattners%
$ifi set nBulls                                bulls        .""  %nBulls%
$ifi set nHeifs                                heifs        .""  %nHeifs%
$ifi set nCalves                               calves       .""  %nCalves%

  /;

