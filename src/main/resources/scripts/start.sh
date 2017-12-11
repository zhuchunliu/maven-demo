#!/bin/bash
cd `dirname $0`
BIN_DIR=`pwd`
DEPLOY_DIR=`pwd`
CONF_DIR=$DEPLOY_DIR/conf
LOGS_DIR=/usr/local/dir_samba/HC_logs/vaccine-front

PIDS=`ps -f | grep java | grep "$CONF_DIR" |awk '{print $2}'`
if [ -n "$PIDS" ]; then
    echo "ERROR: The $SERVER_NAME already started!"
    echo "PID: $PIDS"
    exit 1
fi

JAVA_OPTS=" -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Dspring.profiles.active=de"
JAVA_MEM_OPTS=""
BITS=`java -version 2>&1 | grep -i 64-bit`
if [ -n "$BITS" ]; then
 JAVA_MEM_OPTS=" -server -Xmx2g -Xms2g -Xmn512m -XX:PermSize=512m -Xss256k -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -XX:LargePageSizeInBytes=128m -XX:+UseFastAccessorMethods -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70 "
else
    JAVA_MEM_OPTS=" -server -Xms2g -Xmx4g -XX:PermSize=1024m -XX:SurvivorRatio=2 -XX:+UseParallelGC "
fi
JAVA_DEBUG_OPTS=""
if [ "$1" = "debug" ]; then
    JAVA_DEBUG_OPTS=" -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=5566,server=y,suspend=n "
fi
JAVA_JMX_OPTS=""
if [ "$1" = "jmx" ]; then
    JAVA_JMX_OPTS=" -Dcom.sun.management.jmxremote.port=1099 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false "
fi

LIB_DIR=$DEPLOY_DIR/lib
LIB_JARS=`ls $LIB_DIR|grep .jar|awk '{print "'$LIB_DIR'/"$0}'|tr "\n" ":"`

MAIN_CLASS=com.yimiao.vaccine.admin.configuration.VaccineFrontStartUp

if [ ! -d $LOGS_DIR ]; then
    mkdir $LOGS_DIR
fi
STDOUT_FILE=$LOGS_DIR/stdout.log

nohup java $JAVA_OPTS $JAVA_MEM_OPTS $JAVA_DEBUG_OPTS $JAVA_JMX_OPTS -classpath $CONF_DIR:$LIB_JARS $MAIN_CLASS > $STDOUT_FILE 2>&1 &
