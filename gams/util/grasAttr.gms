********************************************************************************
$ontext

   FARMDyn project

   GAMS file : GrasAttr.gms

   @purpose  : Generate names for gras activities from input on table on
               interface to improve readibility (using Python)
   @author   : W.Britz
   @date     : 26.01.18
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter.gms

$offtext
********************************************************************************

set grasTypes  / system.empty /;
set gras_grasN(grasTypes,p_grasAttrGui_dim3);

set grasOutputs  / earlyGraz,middleGraz,lateGraz,earlyGrasSil,middleGrasSil,lateGrasSil,hay,hayM,grasM /;
set grazOutputs(grasOutputs) / earlyGraz,middleGraz,lateGraz/;
set grasAttr     / yield,set.grasOutputs,nCuts/;
set m "months in each year" /JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC /;

$onEmbeddedCode Python:
    newDim0  = []
#   --- dim0 are the row groups with the attributes
    dim0     = []
#   --- dim1 are the rowsg with the gras types
    dim1     = []
#   --- dim2 months
    dim2     = []

    gras_grasN = [];

#
#   --- get labels and numerical items in vectorized format
#
    labels =  list(gams.get('p_grasAttrGui',valueFormat=ValueFormat.SKIP))
    l = list(gams.get('p_grasAttrGui',keyFormat=KeyFormat.SKIP))
#
#   --- to collect shares of grazing, silage and hay
#       dry matter yield and # of cuts for each type
    graz    = []
    grasSil = []
    hay     = []
    hayM    = []
    grasM   = []
    grasM   = []
    yld     = []
    nCut    = []
#
#   --- built list of graz types
#       and initialize vector above
#
    for x in labels[:]:
       if not x[1] in dim1:
          dim1.append(x[1])
          graz.append(0)
          grasSil.append(0)
          yld.append(0)
          hay.append(0)
          hayM.append(0)
          grasM.append(0)
          nCut.append(0)

    lenDim1 = len(dim1)

    i=0
    for x in labels[:]:
#
#       -- reset eps values introduced to show empty columns/rows
#          on interface

        if l[i] < 0.001:
           l[i] = 0
#
#       --- find index of grastype in list of row names
#
        grazType = dim1.index(x[1]);

#       --- set yield and add-up yield from grazing, silage, hay
#           count number of cuts

        if x[0] == "yield":
            yld[grazType]   = l[i]

        if x[0].endswith("Graz"):
            graz[grazType] += l[i]

        if x[0] == "hay":
            hay[grazType] += l[i]
            nCut[grazType]    += 1

        if x[0] == "hayM":
            hayM[grazType] += l[i]
            nCut[grazType]    += 1

        if x[0] == "grasM":
            grasM[grazType] += l[i]
            nCut[grazType]    += 1

        if x[0].endswith("GrasSil"):
            grasSil[grazType] += l[i]
            nCut[grazType]    += 1

        i+=1
#
#   --- construct the name
#
    for x in dim1[:]:

      i =  dim1.index(x);
#
#     --- to keep empty types: store also original name
#         beware: name is now gras* not gra* .... otherwise
#         the universal set will comprise the old gra* and the
#         order will not be correct as new names will be inserted
#         by GAMS at the end
#
      name = x.replace("gra","gras")
#
#     --- if there is output, append information
#         on share by product and number of cuts
#
      if yld[i] > 0.001:
         name += "_"+str(yld[i]).replace(".0","")
         if graz[i] > 0:
            name += "_graz"+str(graz[i]).replace(".0","")
         if nCut[i] > 0:
            name += "_"+str(nCut[i])+"cuts"
         if grasSil[i] > 0:
            name += "_sil"+str(grasSil[i]).replace(".0","")
         if hay[i] > 0:
            name += "_hay"+str(hay[i]).replace(".0","")
         if hayM[i] > 0:
            name += "_hayM"+str(hayM[i]).replace(".0","")
         if grasM[i] > 0:
            name += "_grasM"+str(grasM[i]).replace(".0","")
         newDim0.append(name)
         gras_grasN.append((name,x))

    gams.set("grasTypes",newDim0)
    gams.set("gras_grasN",gras_grasN);


$offEmbeddedCode grasTypes gras_grasN

   parameter p_grasAttr(*,grasOutputs,m);
*
*  --- scale biomass distribution (over products and monnths) to unity,
*      not considering small values (such as eps)
*

   alias(m,m1);
   alias(grasOutputs,grasOutputs1);
   p_grasAttrGui(grasOutputs,p_grasAttrGui_dim3,m)
     = [p_grasAttrGui(grasOutputs,p_grasAttrGui_dim3,m)
          /sum( (grasOutputs1,m1),p_grasAttrGui(grasOutputs1,p_grasAttrGui_dim3,m1))]
                 $ (p_grasAttrGui(grasOutputs,p_grasAttrGui_dim3,m) gt 1.E-3)
     ;
*
*  --- map to new name, pviot and change from share to DM yield for the products
*
   p_grasAttr(grasTypes,grasOutputs,m)
     = sum(gras_grasN(grasTypes,p_grasAttrGui_dim3),
          p_grasAttrGui(grasOutputs,p_grasAttrGui_dim3,m)*p_grasAttrGui("yield",p_grasAttrGui_dim3,"dm"));


*
*  --- auxiliary parameter to map month of grazing
*
parameter p_grazMonth(*,m);

p_grazMonth(grastypes,m)= sum(grazoutputs,p_grasAttr(grasTypes,grazOutputs,m));
