@echo off

echo[
echo[
echo   ______                   _____                 
echo   ^|  ____^|                 ^|  __ \               
echo   ^| ^|__ __ _ _ __ _ __ ___ ^| ^|  ^| ^|_   _ _ __    
echo   ^|  __/ _` ^| '__^| '_ ` _ \^| ^|  ^| ^| ^| ^| ^| '_ \   
echo   ^| ^| ^| (_^| ^| ^|  ^| ^| ^| ^| ^| ^| ^|__^| ^| ^|_^| ^| ^| ^| ^|  
echo   ^|_^|  \__,_^|_^|  ^|_^| ^|_^| ^|_^|_____/ \__, ^|_^| ^|_^|  
echo                                    __/ ^|         
echo                                   ^|___/          
echo[
echo[
echo Economic Modeling of Agricultural Systems Group
echo Institute for Food and Resource Economics
echo University of Bonn
echo[
echo[
echo Graphical User Interface is loading...
echo[
echo[

SET PATH=%PATH%;./jars
java -Xmx800m -Xverify:none -XX:+UseParallelGC -XX:PermSize=20M -XX:MaxNewSize=32M -XX:NewSize=32M -Djava.library.path=jars -jar jars\gig.jar dairydyn.ini dairydyn_default.xml
