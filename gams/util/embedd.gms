********************************************************************************
$ontext

   FARMDyn project

   GAMS file : EMBEDD.GMS

   @purpose  : Use embedded Python to generate names for set elements
               (e.g. herds) from table input on GUI to increase readibility
   @author   : W.Britz
   @date     : 26.01.18
   @since    :
   @refDoc   :
   @seeAlso  :
   @calledBy : exp_starter.gms

$offtext
********************************************************************************
$setglobal arg1 %1

$ifthen.set "%arg1%"==""
  set types / type1*type3/;
  set attr  / startWgt,finalWgt,days,dressPct /;


   TABLE p_types(*,*)
           startWgt  finalWgt  days   dressPct
   type1      50       180     150      0.5
   type2     180       280     120      0.55
   type3     280       420     100      0.60
   ;


   $$setglobal tableIn  p_types
   $$setglobal tableOut p_beefAttr
   $$setglobal newSet   new

$else.set

   $$setglobal tableIn  %1
   $$setglobal tableOut %2
   $$setglobal newSet   %3


$endif.set

set %newset% / system.empty /;
set %newset%_dim1   / system.empty /;
set %newset%_dim2   / system.empty /;
set %newset%_sold    / system.empty /;
set %newset%_bought  / system.empty /;


$onEmbeddedCode Python:
    newDim1  = []
    dim1     = []
    dim2     = []
    labels =  list(gams.get('%tablein%',valueFormat=ValueFormat.SKIP))
    l = list(gams.get('%tableIn%',keyFormat=KeyFormat.SKIP))

    name =""
    i = 0
    for x in labels[:]:

#       ---  add unknown table columns to dim2 list
        if not x[1] in dim2:
            dim2.append(x[1])

#       ---  add unknown table rows to dim1 list
        if not x[0] in dim1:
            dim1.append(x[0])

#           ---  if generated name is not empty
            if name:
               newDim1.append(name)
            name=""


#       --- built new name from table values

        s1 =  str(l[i])+"_"
        name += s1.replace(".0_","_")
        i += 1

    newDim1.append(name)

#   --- remove ending "_"
    i=0
    for s in newDim1[:]:
      s = s[0:-1]
      newDim1[i] = s;
      i+=1

#   --- generate sold
    sold=[]
    i=0
    for s in newDim1[:]:
      s = "%newSet%_Sold_"+s
      sold.append(s);
      i+=1

#   --- generate bought
    bought=[]
    i=0
    for s in newDim1[:]:
      s = "%newSet%_bought_"+s
      bought.append(s);s
      i+=1

#   --- add name to original set
    i=0
    for s in newDim1[:]:
      s = "%newSet%_"+s
      newDim1[i] = s;
      i+=1



    gams.set("%newSet%",newDim1)
    gams.set("%newSet%_sold",sold)
    gams.set("%newSet%_bought",bought)
    gams.set("%newSet%_dim1",dim1)
    gams.set("%newSet%_dim2",dim2)

$offEmbeddedCode %newset% %newset%_sold %newSet%_bought %newset%_dim1 %newset%_dim2

   parameter %tableOut%(*,*);

   %tableOut%(%newset%,%newset%_dim2)
      = sum(%newset%_dim1 $ (%newset%_dim1.pos eq %newSet%.pos),%tableIn%(%newset%_dim1,%newset%_dim2));

