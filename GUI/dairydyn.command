#!/bin/bash
cd -- "$(dirname "$BASH_SOURCE")"
java -Xmx800m -Xverify:none -XX:+UseParallelGC -XX:PermSize=20M -XX:MaxNewSize=32M -XX:NewSize=32M -Djava.library.path=jars -jar jars/gig.jar ./dairydyn.ini ./dairydyn_default.xml
