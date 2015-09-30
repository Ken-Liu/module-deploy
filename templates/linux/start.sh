#!/bin/bash

APPNAME=<%= appName %>
APP_PATH=/opt/$APPNAME
BUNDLE_PATH=$APP_PATH/current
ENV_FILE=$APP_PATH/config/env.list
PORT=<%= meteor_container_port %>
APP_VIRTUAL_URL=<%= virtual_host %>
USE_LOCAL_MONGO=<%= useLocalMongo? "1" : "0" %>
MONGO_URL_COMPOSE=mongodb://root:Maodou123@lighthouse.4.mongolayer.com:10107,lighthouse.5.mongolayer.com:10107/microduino?replicaSet=set-560a098fb9d501241e000a0d
# Remove previous version of the app, if exists
docker rm -f $APPNAME

# Remove frontend container if exists
docker rm -f $APPNAME-frontend

# We don't need to fail the deployment because of a docker hub downtime
set +e
#docker pull meteorhacks/meteord:base
set -e


if [ "$USE_LOCAL_MONGO" == "1" ]; then
  docker run \
    -d \
    -e VIRTUAL_HOST=$APP_VIRTUAL_URL \
    --restart=always \
    --publish=$PORT:80 \
    --volume=$BUNDLE_PATH:/bundle \
    --env-file=$ENV_FILE \
    --link=mongodb:mongodb \
    --hostname="$HOSTNAME-$APPNAME" \
    --env=MONGO_URL=mongodb://mongodb:27017/$APPNAME \
    --name=$APPNAME \
    meteorhacks/meteord:base
else
  docker run \
    -d \
    -e VIRTUAL_HOST=$APP_VIRTUAL_URL \
    --restart=always \
    --publish=$PORT:80 \
    --volume=$BUNDLE_PATH:/bundle \
    --env-file=$ENV_FILE \
    --hostname="$HOSTNAME-$APPNAME" \
    --env=MONGO_URL=$MONGO_URL_COMPOSE \
    --name=$APPNAME \
    meteorhacks/meteord:base








fi

<% if(typeof sslConfig === "object")  { %>
  # We don't need to fail the deployment because of a docker hub downtime
  set +e
  docker pull meteorhacks/mup-frontend-server:latest
  set -e
  docker run \
    -d \
    --restart=always \
    --volume=/opt/$APPNAME/config/bundle.crt:/bundle.crt \
    --volume=/opt/$APPNAME/config/private.key:/private.key \
    --link=$APPNAME:backend \
    --publish=<%= sslConfig.port %>:443 \
    --name=$APPNAME-frontend \
    meteorhacks/mup-frontend-server /start.sh
<% } %>
