********************************************************************************
$ontext

   CAPRI project

   GAMS file : GENERATE_SETS_GDX.GMS

   @purpose  :
   @author   :
   @date     : 11.03.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy :

$offtext
********************************************************************************
$offlisting

$setglobal EXR 10

$batinclude 'crops_no.gms' GDX

 SET  inputs "Inputs"/
  'Wage rate full time       ' "Wage rate full time       "
  'Wage rate half time       ' "Wage rate half time       "
  'Wage rate flexible hourly ' "Wage rate flexible hourly "
  'MaizSil                   ' "MaizSil                   "
  'GrasSil                   ' "GrasSil                   "
  'ManCatt                   ' "ManCatt                   "
  'ConcCattle1               ' "ConcCattle1               "
  'ConcCattle2               ' "ConcCattle2               "
  'ConcCattle3               ' "ConcCattle3               "
  'milkPowder                ' "milkPowder                "
  'OilsForFeed               ' "OilsForFeed               "
  'WinterWheat               ' "WinterWheat               "
  'WinterRye                 ' "WinterRye                 "
  'SummerCere                ' "SummerCere                "
  'SummerTriticale           ' "SummerTriticale           "
  'MaizCCM                   ' "MaizCCM                   "
  'WinterBarley              ' "WinterBarley              "
  'SoyBeanMeal               ' "SoyBeanMeal               "
  'SoybeanOil                ' "SoybeanOil                "
  'rapeSeedMeal              ' "rapeSeedMeal              "
  'Alfalfa                   ' "Alfalfa                   "
  'PlantFat                  ' "PlantFat                  "
  'MinFu                     ' "MinFu                     "
  'MinFu2                    ' "MinFu2                    "
  'MinFu3                    ' "MinFu3                    "
  'MinFu4                    ' "MinFu4                    "
  'Diesel                    ' "Diesel                    "
  'ASS                       ' "ASS                       "
  'AHL                       ' "AHL                       "
  'seed                      ' "seed                      "
  'KAS                       ' "KAS                       "
  'PK_18_10                  ' "PK_18_10                  "
  'KaliMag                   ' "KaliMag                   "
  'Lime                      ' "Lime                      "
  'Herb                      ' "Herb                      "
  'Fung                      ' "Fung                      "
  'Insect                    ' "Insect                    "
  'growthContr               ' "growthContr               "
  'water                     ' "water                     "
  'hailIns                   ' "hailIns                   "
  'pigletsBought             ' "pigletsBought             "
  'ManPig                    ' "ManPig                    "
  'youngSow                  ' "youngSow                  "
  'straw                     ' "straw                     "
  'Hay                       ' "Hay                       "
  'YoungCow                  ' "YoungCow                  "
  'femaleSexing              ' "femaleSexing              "
  'maleSexing                ' "maleSexing                "
  'fCalvsRaisBought          ' "fCalvsRaisBought          "
  'mCalvsRaisBought          ' "mCalvsRaisBought          "
 /;



 PARAMETER p_inputPrices "Inputs"/
'Wage rate full time       '.'Price' 17.5
'Wage rate half time       '.'Price' 11.5
'Wage rate flexible hourly '.'Price' 9.0
'MaizSil                   '.'Price' 40.0
'GrasSil                   '.'Price' 31.0
'ManCatt                   '.'Price' 0.001
'ConcCattle1               '.'Price' 220.0
'ConcCattle2               '.'Price' 230.0
'ConcCattle3               '.'Price' 270.0
'milkPowder                '.'Price' 2110.0
'OilsForFeed               '.'Price' 1150.0
'WinterWheat               '.'Price' 205.0
'SummerCere                '.'Price' 220.0
'SummerTriticale           '.'Price' 220.0
'MaizCCM                   '.'Price' 86.0
'WinterBarley              '.'Price' 145.0
'WinterRye                 '.'Price' 205.0
'SoyBeanMeal               '.'Price' 338.0
'SoybeanOil                '.'Price' 1150.0
'rapeSeedMeal              '.'Price' 220.0
'Alfalfa                   '.'Price' 184.0
'PlantFat                  '.'Price' 1000.0
'MinFu                     '.'Price' 700.0
'MinFu2                    '.'Price' 700.0
'MinFu3                    '.'Price' 700.0
'MinFu4                    '.'Price' 700.0
'Diesel                    '.'Price' 0.7
'ASS                       '.'Price' 0.29
'AHL                       '.'Price' 0.238
'seed                      '.'Price' 1.0
'KAS                       '.'Price' 0.31
'PK_18_10                  '.'Price' 0.236
'KaliMag                   '.'Price' 0.449
'Lime                      '.'Price' 0.054
'Herb                      '.'Price' 1.0
'Fung                      '.'Price' 1.0
'Insect                    '.'Price' 1.0
'growthContr               '.'Price' 1.0
'water                     '.'Price' 2.5
'hailIns                   '.'Price' 9.91
'pigletsBought             '.'Price' 48.2
'ManPig                    '.'Price' 0.01
'youngSow                  '.'Price' 570.0
'straw                     '.'Price' 115.0
'Hay                       '.'Price' 132.0
'YoungCow                  '.'Price' 1775.0
'femaleSexing              '.'Price' 10
'maleSexing                '.'Price' 10
'fCalvsRaisBought          '.'Price' 144.0
'mCalvsRaisBought          '.'Price' 144.0
 /;

p_inputPrices(inputs,'Growth rate') = eps;

p_inputPrices(inputs,'Price') = p_inputPrices(inputs,'Price') * %EXR%;



Execute_unload "inputs_no.gdx" inputs,p_inputPrices;
Execute_unload "crops_no.gdx"  p_cropYield,p_cropPrice,set_crops_and_prods=crops,summerHarvest,cashCrops,arableCrops;
