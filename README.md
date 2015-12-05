# dokku nats (beta) [![Build Status](https://img.shields.io/travis/dokku/dokku-nats.svg?branch=master "Build Status")](https://travis-ci.org/dokku/dokku-nats) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)
 
Official Nats plugin for dokku. Currently defaults to installing [nats 0.6.8](https://hub.docker.com/_/nats/).

## requirements

- dokku 0.4.0+
- docker 1.8.x

## installation

```shell
# on 0.3.x
cd /var/lib/dokku/plugins
git clone https://github.com/byrnedo/dokku-nats.git nats
dokku plugins-install

# on 0.4.x
dokku plugin:install https://github.com/byrnedo/dokku-nats.git nats
```

## commands

```
nats:create <name>            Create a nats service with environment variables
nats:destroy <name>           Delete the service and stop its container if there are no links left
nats:expose <name> [port]     Expose a nats service on custom port if provided (random port otherwise)
nats:info <name>              Print the connection information
nats:link <name> <app>        Link the nats service to the app
nats:list                     List all nats services
nats:logs <name> [-t]         Print the most recent log(s) for this service
nats:promote <name> <app>     Promote service <name> as NATS_URL in <app>
nats:restart <name>           Graceful shutdown and restart of the nats service container
nats:start <name>             Start a previously stopped nats service
nats:stop <name>              Stop a running nats service
nats:unexpose <name>          Unexpose a previously exposed nats service
nats:unlink <name> <app>      Unlink the nats service from the app
```

## usage

```shell
# create a nats service named lolipop
dokku nats:create lolipop

# you can also specify the image and image
# version to use for the service
# it *must* be compatible with the
# official nats image
export NATS_IMAGE="nats"
export NATS_IMAGE_VERSION="0.6.5"

# you can also specify custom environment
# variables to start the nats service
# in semi-colon separated forma
export NATS_CUSTOM_ENV="USER=alpha;HOST=beta"

# create a nats service
dokku nats:create lolipop

# get connection information as follows
dokku nats:info lolipop

# a nats service can be linked to a
# container this will use native docker
# links via the docker-options plugin
# here we link it to our 'playground' app
# NOTE: this will restart your app
dokku nats:link lolipop playground

# the following environment variables will be set automatically by docker (not
# on the app itself, so they won’t be listed when calling dokku config)
#
#   DOKKU_NATS_LOLIPOP_NAME=/lolipop/DATABASE
#   DOKKU_NATS_LOLIPOP_PORT=tcp://172.17.0.1:4222
#   DOKKU_NATS_LOLIPOP_PORT_4222_TCP=tcp://172.17.0.1:4222
#   DOKKU_NATS_LOLIPOP_PORT_4222_TCP_PROTO=tcp
#   DOKKU_NATS_LOLIPOP_PORT_4222_TCP_PORT=4222
#   DOKKU_NATS_LOLIPOP_PORT_4222_TCP_ADDR=172.17.0.1
#
# and the following will be set on the linked application by default
#
#   NATS_URL=nats://dokku-nats-lolipop:4222/0
#
# NOTE: the host exposed here only works internally in docker containers. If
# you want your container to be reachable from outside, you should use `expose`.

# another service can be linked to your app
dokku nats:link other_service playground

# since NATS_URL is already in use, another environment variable will be
# generated automatically
#
#   DOKKU_NATS_BLUE_URL=nats://dokku-nats-other-service:4222/0

# you can then promote the new service to be the primary one
# NOTE: this will restart your app
dokku nats:promote other_service playground

# this will replace NATS_URL with the url from other_service and generate
# another environment variable to hold the previous value if necessary.
# you could end up with the following for example:
#
#   NATS_URL=nats://dokku-nats-other-service:4222/0
#   DOKKU_NATS_BLUE_URL=nats://dokku-nats-other-service:4222/0
#   DOKKU_NATS_SILVER_URL=nats://dokku-nats-lolipop:4222/lolipop

# you can also unlink a nats service
# NOTE: this will restart your app and unset related environment variables
dokku nats:unlink lolipop playground

# you can tail logs for a particular service
dokku nats:logs lolipop
dokku nats:logs lolipop -t # to tail

# finally, you can destroy the container
dokku nats:destroy lolipop
```
