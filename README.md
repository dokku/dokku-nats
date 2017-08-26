# dokku nats (beta) [![Build Status](https://img.shields.io/travis/dokku/dokku-nats.svg?branch=master "Build Status")](https://travis-ci.org/dokku/dokku-nats) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)

Official nats plugin for dokku. Currently defaults to installing [nats 0.9.4](https://hub.docker.com/_/nats/).

## requirements

- dokku 0.4.x+
- docker 1.8.x

## installation

```shell
# on 0.4.x+
sudo dokku plugin:install https://github.com/dokku/dokku-nats.git nats
```

## commands

```
nats:backup <name> <bucket> [--use-iam] NOT IMPLEMENTED
nats:backup-auth <name> <aws_access_key_id> <aws_secret_access_key> (<aws_default_region>) (<aws_signature_version>) (<endpoint_url>) NOT IMPLEMENTED
nats:backup-deauth <name>     NOT IMPLEMENTED
nats:backup-schedule <name> <schedule> <bucket> NOT IMPLEMENTED
nats:backup-unschedule <name> NOT IMPLEMENTED
nats:clone <name> <new-name>  NOT IMPLEMENTED
nats:connect <name>           NOT IMPLEMENTED
nats:create <name>            Create a nats service with environment variables
nats:destroy <name>           Delete the service and stop its container if there are no links left
nats:enter <name> [command]   Enter or run a command in a running nats service container
nats:export <name> > <file>   NOT IMPLEMENTED
nats:expose <name> [port]     Expose a nats service on custom port if provided (random port otherwise)
nats:import <name> <file>     NOT IMPLEMENTED
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
dokku nats:create lolipop

# you can also specify custom environment
# variables to start the nats service
# in semi-colon separated form
export NATS_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku nats:create lolipop

# get connection information as follows
dokku nats:info lolipop

# you can also retrieve a specific piece of service info via flags
dokku nats:info lolipop --config-dir
dokku nats:info lolipop --data-dir
dokku nats:info lolipop --dsn
dokku nats:info lolipop --exposed-ports
dokku nats:info lolipop --id
dokku nats:info lolipop --internal-ip
dokku nats:info lolipop --links
dokku nats:info lolipop --service-root
dokku nats:info lolipop --status
dokku nats:info lolipop --version

# a bash prompt can be opened against a running service
# filesystem changes will not be saved to disk
dokku nats:enter lolipop

# you may also run a command directly against the service
# filesystem changes will not be saved to disk
dokku nats:enter lolipop ls -lah /

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
#   NATS_URL=nats://dokku-nats-lolipop:4222
#
# NOTE: the host exposed here only works internally in docker containers. If
# you want your container to be reachable from outside, you should use `expose`.

# another service can be linked to your app
dokku nats:link other_service playground

# since NATS_URL is already in use, another environment variable will be
# generated automatically
#
#   DOKKU_NATS_BLUE_URL=nats://dokku-nats-other-service:4222

# you can then promote the new service to be the primary one
# NOTE: this will restart your app
dokku nats:promote other_service playground

# this will replace NATS_URL with the url from other_service and generate
# another environment variable to hold the previous value if necessary.
# you could end up with the following for example:
#
#   NATS_URL=nats://dokku-nats-other-service:4222
#   DOKKU_NATS_BLUE_URL=nats://dokku-nats-other-service:4222
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

## Changing database adapter

It's possible to change the protocol for NATS_URL by setting
the environment variable NATS_DATABASE_SCHEME on the app:

```
dokku config:set playground NATS_DATABASE_SCHEME=nats2
dokku nats:link lolipop playground
```

Will cause NATS_URL to be set as
nats2://dokku-nats-lolipop:4222/lolipop

CAUTION: Changing NATS_DATABASE_SCHEME after linking will cause dokku to
believe the service is not linked when attempting to use `dokku nats:unlink`
or `dokku nats:promote`.
You should be able to fix this by

- Changing NATS_URL manually to the new value.

OR

- Set NATS_DATABASE_SCHEME back to its original setting
- Unlink the service
- Change NATS_DATABASE_SCHEME to the desired setting
- Relink the service
