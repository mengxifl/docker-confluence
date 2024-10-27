# docker-confluence
A docker image that can let you run confluence. But there is no database. Only confluence.

you need run a db server by your self.

## How to use

1、 download those repositories to /docker
2、 download confluence file from https://www.atlassian.com/software/confluence/download-archives. and unzip all the subdir file to wikiBinFiles
2、 run `cd /docker/ && docker build -t confluence:v1 .`


```
docker run -d \
 --restart=always \
--network=host  \
-v ${YOUR_SAVE_DATA}:/data \
-e DATA_DIR=/data \
-e SET_USE_JVM_MS="1024m" \
SET_USE_JVM_MX="1024m"  \
confluence:v1 [other parms]
```

enjoy
