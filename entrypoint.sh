#!/bin/bash



function setDefault {
  if [[ $RUNAS_USER_NAME == "" ]]; then
    RUNAS_USER_NAME=confluence
  fi
  if [[ $DATA_DIR == "" ]]; then
    DATA_DIR=/data/
  fi
  if [[ $SET_USE_JVM_MS == "" ]]; then
    SET_USE_JVM_MS=1024m
  fi
  if [[ $SET_USE_JVM_MX == "" ]]; then
    SET_USE_JVM_MX=1024m
  fi
}

function createUSER {
  if [[ $(cat /etc/shadow | grep "${RUNAS_USER_NAME}") != "" ]]; then
    return
  fi
  useradd ${RUNAS_USER_NAME}
  echo 'CONF_USER="'${RUNAS_USER_NAME}'"' > /wikiBinFiles/user.sh
  echo 'export CONF_USER' >> /wikiBinFiles/user.sh
}


function chmodDIR {
  # ls -alh ${DATA_DIR}
  chown -R ${RUNAS_USER_NAME} /wikiBinFiles/
  chmod -R 755 /wikiBinFiles/
  if [ ! -d "${DATA_DIR}" ]; then
    mkdir -p ${DATA_DIR}
  fi
  if [ ! -d "$SHARE_DIR" ]; then
    mkdir -p ${SHARE_DIR}
  fi
  if [[ $(ls -ald ${DATA_DIR} | awk '{print $3}') != "${RUNAS_USER_NAME}" ]]; then
    chown -R ${RUNAS_USER_NAME} ${DATA_DIR}
    chown -R ${RUNAS_USER_NAME} ${SHARE_DIR}
  fi
  if [[ $(ls -ald ${DATA_DIR} | awk '{print $1}') != "drwxr-xr-x" ]]; then
    chmod -R 755 ${DATA_DIR}
    chmod -R 755 ${SHARE_DIR}
  fi
}


function showHelp {
  echo 'RUN: You can add args with your run container command such as :
    docker run [-e options] <imageName> [tomcat options] [other options]
    -e options:
      SET_USE_JVM_MS="1024M" # set JVM -Xms value
      SET_USE_JVM_MX="1024M" # set JVM -Xmx value
      DATA_DIR="/data" set your data path
      SHARE_DIR="/sharedata" set your share path for cluster

    tomcat options:
      https://www.oracle.com/java/technologies/javase/vmoptions-jsp.html
      https://www.cwiki.us/display/CONFLUENCEWIKI/Recognized+System+Properties

    more:
      You can only set mysql connect num when your service is normal. After you set you need restart your service
      file youDataPath/confluence.cfg.xml
      this is  mysql connect num

      <property name="hibernate.c3p0.max_size">1000</property>

      this file have a lot of options

    '
  exit
}



function setRunArgs() {
  ARGS=""
  while [[ $# -gt 0 ]]; do
    ARGS=`echo $ARGS $1`
    shift
  done
}


function main {
  while [[ $# -gt 0 ]]; do
    if [[ $1 == "--help" || $1 == "-h" ]]; then
      showHelp
    fi
    setRunArgs $@
    shift
  done
}


function prepareRUN() {
  setDefault
  echo "set data dir to "${DATA_DIR}
  echo "confluence.home="${DATA_DIR} > /wikiBinFiles/confluence/WEB-INF/classes/confluence-init.properties
  echo "set tomcat parms"
  cat /wikiBinFiles/bin/setenv.sh.raw | grep -v  "export CATALINA_OPTS" > /var/setenv.sh
  USE_JVM_MS=`cat /var/setenv.sh | grep -E -o "Xms[0-9]+[a-zA-Z]"`
  USE_JVM_MX=`cat /var/setenv.sh | grep -E -o "Xmx[0-9]+[a-zA-Z]"`
  sed -i 's@'$USE_JVM_MS'@Xms'$SET_USE_JVM_MS'@g' /var/setenv.sh
  sed -i 's@'$USE_JVM_MX'@Xmx'$SET_USE_JVM_MX'@g' /var/setenv.sh
  echo 'CATALINA_OPTS="-Dconfluence.document.conversion.fontpath=/usr/share/fonts/msfonts ${CATALINA_OPTS}"' >> /var/setenv.sh
  echo 'CATALINA_OPTS="'${ARGS}' ${CATALINA_OPTS}"' >> /var/setenv.sh
  echo 'export CATALINA_OPTS'  >> /var/setenv.sh
  /bin/cp /var/setenv.sh /wikiBinFiles/bin/setenv.sh
  echo "Your confluence will start soon......."
  echo "welcome access my github https://github.com/mengxifl/"
  sleep 3
  createUSER
  chmodDIR
}

setRunArgs
prepareRUN
runuser -m ${RUNAS_USER_NAME} -c "/wikiBinFiles/bin/start-confluence.sh -fg"