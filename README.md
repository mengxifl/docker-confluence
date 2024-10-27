# docker-confluence
A docker image that can let you run confluence. But there is no database but had sql lib 

mysql-connector-j-8.1.0.jar and mysql-connector-java-5.1.45-bin.jar. If you want to use other db you can use ` -v  <plugin dir>/pluginfile:/wikiBinFiles/confluence/WEB-INF/lib/pluginfile`

And You need run a db server by your self. 

## How to use

1.  download those repositories to /docker

2.  download confluence file from https://www.atlassian.com/software/confluence/download-archives. and unzip all the subdir files to wikiBinFiles
3. run `cd /docker/ && docker build -t confluence:v8 .` to build a image


```
docker run -d \
 --restart=always \
-p 0.0.0.0:8090:8090  \
-v ${YOUR_SAVE_DATA}:/data \
-e DATA_DIR=/data \
-e SET_USE_JVM_MS="1024m" \
SET_USE_JVM_MX="1024m"  \
confluence:v8 [other parms]
```

enjoy 

## Cluster

1. stop service

2. copy ${YOUR_SAVE_DATA}/shared-home to a share store

3. edit file confluence.cfg.xml

   ```
   vi ${YOUR_SAVE_DATA}/confluence.cfg.xml
   <confluence-configuration>
     ........
     <properties>
       ........
       <property name="confluence.cluster">true</property>
       <property name="confluence.cluster.authentication.enabled">true</property>
       <property name="confluence.cluster.authentication.secret">SOME_RAND_STRING</property>
   
       <property name="confluence.cluster.home">/sharedata</property>
   
       <property name="confluence.cluster.interface">PEER_INTERFACE</property>
       <property name="confluence.cluster.join.type">tcp_ip</property>
       <property name="confluence.cluster.name">CLUSTER_NAME</property>
       <property name="confluence.cluster.peers">SERVERIP_1,SERVERIP_2</property>
       ......
     </properties>
   </confluence-configuration>
   ```

4.  mount the share dir and start first server

   ```
   docker run -d \
    --restart=always \
   --network=host \
   -v ${YOUR_SAVE_DATA}:/data \
   -v ${YOUR_SHARE_DIR}:/sharedata \
   -e DATA_DIR=/data \
   -e SHARE_DIR=/sharedata \
   -e SET_USE_JVM_MS="1024m" \
   SET_USE_JVM_MX="1024m"  \
   confluence:v8 [other parms]
   ```

5. copy confluence.cfg.xml to other peers. copy ${YOUR_SAVE_DATA} to other peers. mount ${YOUR_SHARE_DIR}

6. Start your other server use step 4

7. last set proxy normal I use  nginx to proxy backend. then upstream set to ip_has;
