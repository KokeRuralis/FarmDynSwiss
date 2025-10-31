$offlisting

    set ind "Individual indicators" / ind1*ind20 /;
    alias(ind,ind1);

    set mid "Nodes aggregated from individual indicators" / mid1*mid7/;
    alias(mid,mid1);

    set top "Top nodes" / eco,env,soc /;
    alias(top,top1);

    set top_mid_ind(top,mid,ind) "Aggregator logic"  /
       eco .  mid1    .ind1
       eco .  mid1    .ind2
       eco .  mid1    .ind3
       eco .  mid2    .ind4
       eco .  mid2    .ind5
       env .  mid3    .ind6
       env .  mid3    .ind7
       env .  mid4    .ind8
       env .  mid4    .ind9
       env .  mid4    .ind10
       env .  mid4    .ind11
       env .  mid5    .ind12
       env .  mid5    .ind13
       env .  mid5    .ind14
       soc .  mid6    .ind15
       soc .  mid6    .ind16
       soc .  mid7    .ind17
       soc .  mid7    .ind18
       soc .  mid7    .ind19
       soc .  mid7    .ind20
    /;
$ontext
    set ind / ind1*ind2 /;
    alias(ind,ind1);

    set mid / mid1*mid1/;
    alias(mid,mid1);

    set top / eco /;
    alias(top,top1);


    set top_mid_ind(top,mid,ind) /


    eco .  mid1    .ind1
    eco .  mid1    .ind2
    /;
$offtext

    set minMax / min,max /;
    set mid_ind(mid,ind);
    mid_ind(mid,ind) $ sum(top_mid_ind(top,mid,ind),1) = YES;

    set top_mid(top,mid);
    top_mid(top,mid) $ sum(top_mid_ind(top,mid,ind),1) = YES;


    set draws / draws1*draws10/;
$eval combMax 2**6
    set comb / c1*c%combMax% /;

    parameter p_ranges(ind,minMax,draws)      "Minimm and maximzm range of indicators, by draw"
              p_ind(ind,*)                    "Indicator values for current farm"
              p_weightsMid(mid,ind,draws)     "Aggregator weights from indicator to middle nodes"
              p_weightsTop(top,mid,draws)     "Aggregator weights from middle nodes to social/env/eco nodes"
              p_weightsFin(top,draws)         "Aggregator weights from social/env/eco nodes to composite indicator"
              p_res(*,*,*)                    "Indicator results"
    ;

*
*   --- draw ranges stochastically
*
    p_ranges(ind,"min",draws) = uniform(1,5);
    p_ranges(ind,"max",draws) = p_ranges(ind,"min",draws) + uniform(95,99);
*
*   --- draw indicators stochastically
*
    p_ind(ind,"") = uniform(10,90);
*
*   --- logistic transformation
*
    p_ind(ind,draws) = sigmoid( [ (p_ind(ind,"")            -p_ranges(ind,"min",draws))
                                 /(p_ranges(ind,"max",draws)-p_ranges(ind,"min",draws))-0.5]*5);
    display p_ranges,p_ind;
*
*   --- draw weights and scale to unity
*
    p_weightsMid(mid,ind,draws) $ sum(mid_ind(mid,ind),1) = uniform(0,1);
*  p_weightsMid(mid,"ind1",draws) $ sum(mid_ind(mid,ind),1) = 0.75;
*  p_weightsMid(mid,"ind2",draws) $ sum(mid_ind(mid,ind),1) = 0.25;

    p_weightsMid(mid,ind,draws) $ sum(mid_ind(mid,ind),1) = 1/sum(mid_ind(mid,ind1),1);

    p_weightsMid(mid,ind,draws) $ p_weightsMid(mid,ind,draws)
      = p_weightsMid(mid,ind,draws)/sum(top_mid_ind(top,mid,ind1), p_weightsMid(mid,ind1,draws));

    p_weightsTop(top,mid,draws) $ sum(top_mid(top,mid),1) = uniform(0,1);
    p_weightsTop(top,mid,draws) $ sum(top_mid(top,mid),1) = 1/sum(top_mid(top,mid1),1);

    p_weightsTop(top,mid,draws) $ p_weightsTop(top,mid,draws)
      = p_weightsTop(top,mid,draws)/sum(mid1 $ sum(ind,top_mid_ind(top,mid1,ind)), p_weightsTop(top,mid1,draws));

    p_weightsFin(top,draws) = uniform(0,1);
    p_weightsFin(top,draws) = p_weightsFin(top,draws)/sum(top1,p_weightsFin(top1,draws));

    display p_weightsMid,p_weightsTop,p_WeightsFin;

*
*   --- that is a binary decomposition (like a bit mask)
*
$macro m_binInd(comb,ind) ( mod(comb.pos-1-sum(ind1 $ (ind1.pos lt ind.pos),mod(comb.pos-1,2**(ind1.pos))),2**(ind.pos)) gt 0)

    set actComb(comb);

    set actInd(ind);
*
*   --- aggregate from individual indicators to nodes
*
    loop(mid,
       option kill=actInd;
       actInd(ind) $ sum(mid_ind(mid,ind),1) = YES;

       option kill=actComb;
       actComb(comb) $ (comb.pos-0.001 le 2**card(actInd)) = YES;

       p_res(draws,mid,"bc") = sum(actComb,smin(mid_ind(mid,actInd),
                                                      p_ind(actInd,draws)  $ (m_binInd(actComb,actInd) eq 0)
                                                  +(1-p_ind(actInd,draws)) $ (m_binInd(actComb,actInd) eq 1))
                                      *  sum(mid_ind(mid,actInd) $ (m_binInd(actComb,actInd) eq 0),p_weightsMid(mid,actInd,draws)))

*                              / sum(actComb,      sum(mid_ind(mid,actInd) $ (m_binInd(actComb,actInd) eq 0),p_weightsMid(mid,actInd,draws)));

                               /sum(actComb,smin(mid_ind(mid,actInd),
                                                       p_ind(actInd,draws)  $ (m_binInd(actComb,actInd) eq 0)
                                                   +(1-p_ind(actInd,draws)) $ (m_binInd(actComb,actInd) eq 1)));

       p_res(draws,mid,"lin") = sum(mid_ind(mid,ind), p_ind(ind,draws) * p_weightsMid(mid,ind,draws));
    );
*
*   --- aggregate from nodes to eco / social / env
*
    set actMid(mid);

    loop(top,

       option kill=actMid;
       actMid(mid) $ sum(top_mid(top,mid),1) = YES;

       option kill=actComb;
       actComb(comb) $ (comb.pos-1 le 2**card(actMid)) = YES;

       p_res(draws,top,"bc") = sum(actComb, smin(top_mid(top,actMid),
                                                      p_res(draws,actMid,"bc")  $ (m_binInd(actComb,actMid) eq 0)
                                                  +(1-p_res(draws,actMid,"bc")) $ (m_binInd(actComb,actMid) eq 1))
                                       * sum(top_mid(top,actMid) $ (m_binInd(actComb,actMid) eq 0),p_weightsTop(top,actMid,draws)))
*                            /sum(actComb,sum(top_mid(top,actMid) $ (m_binInd(actComb,actMid) eq 0),p_weightsTop(top,actMid,draws)));
                              / sum(actComb, smin(top_mid(top,actMid),
                                                       p_res(draws,actMid,"bc")  $ (m_binInd(actComb,actMid) eq 0)
                                                   +(1-p_res(draws,actMid,"bc")) $ (m_binInd(actComb,actMid) eq 1)));

       p_res(draws,top,"lin") = sum( top_mid(top,mid), p_res(draws,mid,"lin") * p_weightsTop(top,mid,draws));
    );

*
*   --- aggregate social  / env / eco to compositve indicator
*
    option kill=actComb;
    actComb(comb) $ (comb.pos-1 le 2**card(top)) = YES;

    p_res(draws,"fin","bc") = sum(actcomb, smin(top,
                                                   p_res(draws,top,"bc")  $ (m_binInd(actcomb,top) eq 0)
                                               +(1-p_res(draws,top,"bc")) $ (m_binInd(actcomb,top) eq 1))
                                    * sum(top $ (m_binInd(actcomb,top) eq 0),p_weightsFin(top,draws)))
*                            /sum(actComb, sum(top $ (m_binInd(actcomb,top) eq 0),p_weightsFin(top,draws)));
                           / sum(actcomb,    smin(top,
                                                     p_res(draws,top,"bc")  $ (m_binInd(actcomb,top) eq 0)
                                                 +(1-p_res(draws,top,"bc")) $ (m_binInd(actcomb,top) eq 1)));
*
    p_res(draws,"fin","lin") = sum(top, p_res(draws,top,"lin") * p_weightsFin(top,draws));

   option p_res:2:1:2;
   display p_res;

