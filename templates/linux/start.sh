#!/bin/bash

APPNAME=<%= appName %>
CONFIGNAME=<%= configname %>
CONFIG_PATH=/opt/$APPNAME/$CONFIGNAME
INNERPORT=<%= innerport %>
#ENV_FILE=$APP_PATH/config/env.list
PORT=<%= meteor_container_port %>
APP_VIRTUAL_URL=<%= virtual_host %>

# Remove previous version of the app, if exists
docker rm -f $APPNAME

# Remove frontend container if exists
docker rm -f $APPNAME-frontend

# We don't need to fail the deployment because of a docker hub downtime
set +e
docker pull liukunmcu/microduino-wiki:latest
set -e



  docker run \
    -d \
    -e VIRTUAL_HOST=$APP_VIRTUAL_URL \
    --restart=always \
    --publish=$PORT:$INNERPORT \
    --volume=$CONFIG_PATH:/app/$CONFIGNAME \
    --name=$APPNAME \
    liukunmcu/microduino-wiki



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
