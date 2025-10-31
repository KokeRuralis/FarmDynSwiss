# ---------------------------------------------------------------------
#
#   Use Latin Hypercube sampling to populate the GAMS parameter
#
#   p_doe(draws,factors)
#
#   and output it to GDX
#
#   where draws   are the design draws
#         factors are the orthogonal factor
#
#   # of draws and set factor are read from GDX
#
# ---------------------------------------------------------------------
sink(stdout(), type="message")
#options(echo=TRUE)


#install.packages("d:\r\R-2.15.1\library\mc2d_0.1-13.zip",repos=NULL);
#install.packages("d:\r\R-2.15.1\library\mvtnorm_0.9-9992.zip",repos=NULL);
#install.packages("d:\r\R-2.15.1\library\lhs_0.10.zip",repos=NULL);
#install.packages("d:\\temp\\gclus_1.3.1.zip",repos=NULL);
# install.packages("t:\\britz\\gdxrrw_0.0-2.zip",repos=NULL);
# install.packages("D:\\temp\\gdxrrw_1.0.2.zip", repos = NULL, type="source");
 library(lhs);
 library(gdxrrw);
 igdx("N:/soft/gams24.7new/24.7");
 library(mc2d);
 library(mvtnorm);
 library(Matrix);
 library(gclus);
 library(reshape2);
#useCorr    <- Sys.getenv("useCorr")
#useColors  <- Sys.getenv("useColors")
#inputFile  <- Sys.getenv("inputFile");
#plotFile   <- Sys.getenv("plotFile")
#outputFile <- Sys.getenv("outputFile");
#maxRunTime <- as.numeric(Sys.getenv("maxRunTime"))


rm(list=ls(all=TRUE));
incFile <- commandArgs(trailingOnly = TRUE);

#incFile <- "d:\\temp\\toLHS.r";

if ( is.na(incFile[1]) )
  incFile[1] <- "d:\\temp\\tolhs.r"

source(incFile[1], echo=TRUE);


 if ( exists("inputFile") ){


 if (!file.exists(inputFile)) stop(paste("inputFile ",inputFile," file doesn't exist! Check the code!"));


#
# --- determine GDX file with input data
#

#
# --- number of draws as requested by GAMS
#
      n = rgdx.scalar(inputFile,"p_n");

#
# --- name of the set which comprises the scenario name
#
      scen_name = rgdx.set(inputFile,"scen_name",compress="true");
      scenName  <- levels(scen_name[scen_name$i == 'name',2])
#
# --- name of the set which comprises the factors
#
      factor_name = rgdx.set(inputFile,"factor_name",compress="true");
      set_to_load <- levels(factor_name[factor_name$i == 'name',2])
#
# --- load that set
#
      factors = rgdx.set(inputFile,set_to_load,compress="true");

      k = nrow(factors);
 } else {
  k = length(factors);
 }

 print(paste("factor ",k));
#
# --- the number of factors is equal to the number of set elements
#
 LHSType <- "improvedLHS";



 if ( LHSType == "optimumLHS" ){
    out <- optimumLHS(n,k,2,0.01)
    reportDraws = 1;
 } else {
    out <- improvedLHS(n,k)
    reportDraws = 1;
 }

 print(useCorr);
 if ( useCorr == "true" )
 {

    begTime <- as.numeric(Sys.time(),units="seconds");
    runTime <- 0;
#
#   --- load correlation matrix from GAMS
#
    t <- rgdx.param(inputFile,"p_cor",names=c("f1","f2"),compress="true");
    t
    t<-acast(t, f1~f2, value.var="value")
    t<-as.matrix(t);

#
#   --- find nearest positive definite matrix
#

    t1<-nearPD(t);

    t <- as.matrix(t1$mat);

    bestFit <- 10;
    iDraw <- 0;


    while( runTime < maxRunTime ){

       iDraw <- iDraw + 1;

       if ( LHSType == "optimumLHS" ) {
          out1 <- optimumLHS(n,k,2,0.01);

          print("shit");

       } else {
          out1 <- improvedLHS(n,k);
       }

#
# --- use cornode to apply Iman & conover 1982 to impose correlation
#     t on the LHS matrix out
#
       out1  <- cornode(out1,target=t)
       c <- cor(out1);

       fit = 0;
       for ( i in 1:k )
            for ( j in 1:k )
                if ( fit < bestFit )

       if ( fit < bestFit )
       {
          out     <-out1;
          bestFit <-fit;

          meanDev = sqrt(fit/k)*100;
       };

       if ( iDraw %% reportDraws == 0){
          curTime <- as.numeric(Sys.time(),units="seconds");
          runTime <- curTime - begTime;
          print(paste(" draw :",iDraw," runTime ",round(runTime)," of ",maxRunTime,"seconds, mean sqrt of squared diff between given corr and best draw: ",round(meanDev,2),"%"));
       }

# --- meanDev threshold: if mean % dev. of randomized correlation matrix is lower than "1%" the draw is taken for the sample and repetition of sample draws is stopped

       if ( meanDev < 1 ){
            print(paste(" draw :",iDraw," runTime ",round(runTime)," of ",maxRunTime,"seconds, mean sqrt of squared diff between given corr and best draw: ",round(meanDev,2),"%"));
            runTime <- maxRunTime;
       }

    }
 }

 c <- cor(out);
 c;

 test <- summary(out);

 p <- c(0.05,0.10,0.15,0.20,0.25,0.30,0.35,0.40,0.50,0.55,0.60,0.65,0.70,0.75,0.80,0.85,0.90,0.95);
 t(apply(out, 2, quantile, probs = p))

#
# --- convert matrix to data frame
#
 out <- data.frame(out)
#
# --- use the set elements as names for the data frame
#
 if ( exists("inputFile") ){
   colnames(out) <- factors$i
 } else {
   colnames(out) <- factors
 }

#
# --- scatter plot parts
#

 colors <- dmat.color(c,
                     breaks=c(-1.0,-0.9,-0.8,-0.7,-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0),
                     terrain.colors(21));

nRow <- k;


 panel.smoother <-
   function (x, y,pch = par("pch"),
             col.smooth = "red", span = 2/3, iter = 3, digits = 2, prefix="", ...)
{

  xm <- mean(x,na.rm=TRUE)
  ym <- mean(y,na.rm=TRUE)
  xs <- sd(x,na.rm=TRUE)
  ys <- sd(y,na.rm=TRUE)
  .GlobalEnv$nCount <- nCount+1;

  r = cor(x, y)

  i <- ceiling(nCount / nRow);
  j <- (nCount-1) %% nRow  + 1;
  if ( useColors == "true" )
     rect(par("usr")[1],par("usr")[3],par("usr")[2],par("usr")[4],col = colors[i,j]);

  points(x, y, pch = pch, ...)

  ok <- is.finite(x) & is.finite(y)
  if (any(ok))
      lines(stats::lowess(x[ok], y[ok], f = span, iter = iter),
          col = col.smooth, ...)

}

#
# --- diagonal: name of series and histogram
#

panel.hist <- function(x, ...)
{
    .GlobalEnv$nCount <- nCount+1;
    usr <- par("usr"); on.exit(par(usr))
    par(usr = c(usr[1:2], 0, 1.5) )
    h <- hist(x, plot = FALSE, breaks=max(10,n/20))
    breaks <- h$breaks; nB <- length(breaks)
    y <- h$counts; y <- y/max(y)
    rect(breaks[-nB], 0, breaks[-1], y, col="grey")
}


nCount <- 0;



#
# --- upper part correlation coefficient
#
panel.corUpp <- function(x, y, digits=2, prefix="",cex.cor, ...)
     {
         usr <- par("usr"); on.exit(par(usr))
         par(usr = c(0, 1, 0, 1))


         r = (cor(x, y))
         txt1 <- format(c(r, 0.123456789), digits=digits)[1]
         txt1 <- paste(prefix, txt1,sep="")


         .GlobalEnv$nCount <- nCount+1;

         i <- ceiling(nCount / nRow);
         j <- (nCount-1) %% nRow  + 1;

         if ( useColors == "true" )
            rect(par("usr")[1],par("usr")[3],par("usr")[2],par("usr")[4],col = colors[i,j]);

         if ( useCorr == "true" ){
            r = t[i,j];
            if ( abs(r) < 1.E-7)
               r = 0;

            txt2 <- format(c(r, 0.123456789), digits=digits)[1]
            txt2 <- paste(" (",prefix, txt2,")",sep="")
         } else {
           txt2="";
         }

         txt <- paste(txt1,txt2,sep="");
#   text size
         cex = 0.8;
         text(0.5, 0.5, txt, cex = cex)

     }

#
# --- combine the plots
#


 posVec <-grep("jpg",plotFile,fixed=TRUE);

 if ( length(posVec) > 0 )
 {

    jpeg(plotFile,quality=99,width=1200,height=1200);
    print("use jpg");

 } else
    pdf(plotFile);

 subTitle="";
 if ( useCorr == "true" )
    subTitle= paste("mean deviation between given and drawn corr ",round(meanDev,2),"%," ,n, " draws per factor ", sep= "")


 pairs(out, pch=20,cex.labels = 0.8,gap=1,
            main="",
            lower.panel=panel.smoother,
            diag.panel=panel.hist,
            upper.panel=panel.corUpp);

title(paste("Scatterplot matrix for LHS draws, scenario ",scenName,sep=""),
               sub = subTitle,
               cex.main = 1, font.main= 2, col.main= "black");

 dev.off()

#
# --- add a row with names draws01 ... draws n
#
 if ( n < 0 )  {
   out$draws  = paste("draws",sprintf("%03d",as.numeric(row.names(out))),sep="")
 } else {
   out$draws  = paste("draws",sprintf("%04d",as.numeric(row.names(out))),sep="")
 }

#
# --- use that name as the id and melt the data frame
#
 out <- melt(out,id=ncol(out));
#
# --- GAMS expects a factor
#
 out$draws    = as.factor(out$draws)
#
# --- determine GDX file stem for output
#

#
# --- store the draws in the GDX
#
 attr(out,"symType") = "parameter";
 attr(out,"symName") = "p_doe";


 fn = paste(outputFile,"_doe",sep="");
 wgdx.df(fn,out);

 print(fn);

