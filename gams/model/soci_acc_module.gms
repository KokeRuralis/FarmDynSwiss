********************************************************************************
$ontext

   FARMDYN project

   GAMS file : SOCI_ACC_MODULE.GMS

   @purpose  : Equations to calculate different social impacts

   @author   : L. Kokemohr
   @date     : 28.11.19
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : templ.gms

$offtext
********************************************************************************
 parameter
              p_foodCont(*,*)

 ;

  Variable

       v_foodProd(soci,t,n)                                "Total edible food (kg protein and kcalorie) production"
       v_foodVeg(soci,t,n)                                 "Total edible food (kg protein and kcalorie) produced"
       v_foodProdAni(soci,t,n)                             "Total edible food (kg protein and kcalorie) production from animals"
       v_foodFeed(soci,t,n)                                "Total edible food (kg protein and kcalorie) used for feeding"
      ;

  Equations

       foodProd_(soci,t,n)                               "Total edible food (kg protein and kcalorie) production"
       foodVeg_(soci,t,n)                                "Total edible food (kg protein and kcalorie) produced"
       foodProdAni_(soci,t,n)                            "Total edible food (kg protein and kcalorie) production from animals"
       foodFeed_(soci,t,n)                               "Total human edible food (kg protein and kcalorie) used for feeding"
      ;



$$iftheni.ch %cattle% == true
*
* --- Human edible protein output in kg
*
  foodProd_(soci,t,nCur)$ (tCur(t) $ t_n(t,nCur) $ envAcc  )..

     v_foodProd(soci,t,nCur)  =e=
            sum((curProds(prodsYearly),sys), v_saleQuant(prodsYearly,sys,t,nCur) * p_foodCont(soci,prodsYearly))
* substract bought animals if no information on upstream emissions is present
           - sum((youngAnim(inputs),sys) $p_inputPrice%l%(inputs,sys,t), v_buy(inputs,sys,t,nCur) * p_foodCont(soci,inputs));

*
* --- Human edible calorie output from animals in kcal
*
  foodProdAni_(soci,t,nCur)$ (tCur(t) $ t_n(t,nCur) $ envAcc  )..

     v_foodProdAni(soci,t,nCur)  =e=
                                    sum((animalprods(prodsyearly)), v_prods(prodsyearly,t,nCur) * p_foodCont(soci,prodsyearly))
* substract bought animals if no information on upstream emissions is present
                                  - sum((youngAnim(inputs),sys) $p_inputPrice%l%(inputs,sys,t), v_buy(inputs,sys,t,nCur) * p_foodCont(soci,inputs))

            ;

*
* --- Human edible protein used for feeding
*
 foodFeed_(soci,t,nCur)$ (tCur(t) $ t_n(t,nCur) $ envAcc  )..

    v_foodFeed(soci,t,nCur)  =e=
           sum(curFeeds(feeds) $(not sameas(feeds,"milkfed")), v_feeduse(feeds,t,nCur) * p_foodCont(soci,feeds))
           ;

*
* --- Human edible protein production without animal Production (including bought inputs)
*
 foodVeg_(soci,t,nCur)$ (tCur(t) $ t_n(t,nCur) $ envAcc  )..

     v_foodVeg(soci,t,nCur)  =e=
            sum((curProds(prodsYearly),sys) $(not animalProds(prodsyearly)),
                      v_saleQuant(prodsYearly,sys,t,nCur) * p_foodCont(soci,prodsYearly)) + v_foodFeed(soci,t,nCur);

$$endif.ch

  model m_soci /
                               foodProd_
                               foodVeg_
                               foodFeed_
                               foodProdAni_

             /;
