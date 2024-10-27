From rockylinux:8.9.20231119-minimal

COPY entrypoint.sh /entrypoint.sh
COPY wikiBinFiles /wikiBinFiles
COPY thirdPackage/mysql-connector-java-5.1.45-bin.jar /wikiBinFiles/confluence/WEB-INF/lib/mysql-connector-java-5.1.45-bin.jar
COPY thirdPackage/mysql-connector-j-8.1.0.jar /wikiBinFiles/confluence/WEB-INF/lib/mysql-connector-j-8.1.0.jar
COPY msfonts /usr/share/fonts/msfonts


RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    microdnf install java-17-openjdk ncurses shadow-utils util-linux -y --setopt=keepcache=0 && \
    microdnf clean all && \
    chmod 777 /entrypoint.sh && \
    mv /wikiBinFiles/bin/setenv.sh /wikiBinFiles/bin/setenv.sh.raw

ENV \
  SET_USE_JVM_MS="1024m" \
  SET_USE_JVM_MX="1024m" \
  DATA_DIR="/data/" \
  SHARE_DIR="/sharedata"

ENTRYPOINT ["/entrypoint.sh"]