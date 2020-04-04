# dokku nats [![Build Status](https://img.shields.io/travis/dokku/dokku-nats.svg?branch=master "Build Status")](https://travis-ci.org/dokku/dokku-nats) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)

Official nats plugin for dokku. Currently defaults to installing [nats 1.4.1](https://hub.docker.com/_/nats/).

## Requirements

- dokku 0.12.x+
- docker 1.8.x

## Installation

```shell
# on 0.12.x+
sudo dokku plugin:install https://github.com/dokku/dokku-nats.git nats
```

## Commands

```
nats:app-links <app>                               # list all nats service links for a given app
nats:backup <service> <bucket-name> [--use-iam]    # creates a backup of the nats service to an existing s3 bucket
nats:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url> # sets up authentication for backups on the nats service
nats:backup-deauth <service>                       # removes backup authentication for the nats service
nats:backup-schedule <service> <schedule> <bucket-name> [--use-iam] # schedules a backup of the nats service
nats:backup-schedule-cat <service>                 # cat the contents of the configured backup cronfile for the service
nats:backup-set-encryption <service> <passphrase>  # sets encryption for all future backups of nats service
nats:backup-unschedule <service>                   # unschedules the backup of the nats service
nats:backup-unset-encryption <service>             # unsets encryption for future backups of the nats service
nats:clone <service> <new-service> [--clone-flags...] # create container <new-name> then copy data from <name> into <new-name>
nats:connect <service>                             # connect to the service via the nats connection tool
nats:create <service> [--create-flags...]          # create a nats service
nats:destroy <service> [-f|--force]                # delete the nats service/data/container if there are no links left
nats:enter <service>                               # enter or run a command in a running nats service container
nats:exists <service>                              # check if the nats service exists
nats:export <service>                              # export a dump of the nats service database
nats:expose <service> <ports...>                   # expose a nats service on custom port if provided (random port otherwise)
nats:import <service>                              # import a dump into the nats service database
nats:info <service> [--single-info-flag]           # print the connection information
nats:link <service> <app> [--link-flags...]        # link the nats service to the app
nats:linked <service> <app>                        # check if the nats service is linked to an app
nats:links <service>                               # list all apps linked to the nats service
nats:list                                          # list all nats services
nats:logs <service> [-t|--tail]                    # print the most recent log(s) for this service
nats:promote <service> <app>                       # promote service <service> as NATS_URL in <app>
nats:restart <service>                             # graceful shutdown and restart of the nats service container
nats:start <service>                               # start a previously stopped nats service
nats:stop <service>                                # stop a running nats service
nats:unexpose <service>                            # unexpose a previously exposed nats service
nats:unlink <service> <app>                        # unlink the nats service from the app
nats:upgrade <service> [--upgrade-flags...]        # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to nats:help. Please consult the `nats:help` command for any undocumented commands.

### Basic Usage
### list all nats services

```shell
# usage
dokku nats:list 
```

examples:

List all services:

```shell
dokku nats:list
```
### create a nats service

```shell
# usage
dokku nats:create <service> [--create-flags...]
```

examples:

Create a nats service named lolipop:

```shell
dokku nats:create lolipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the ${plugin_image} image. :

```shell
export NATS_IMAGE="${PLUGIN_IMAGE}"
export NATS_IMAGE_VERSION="${PLUGIN_IMAGE_VERSION}"
dokku nats:create lolipop
```

You can also specify custom environment variables to start the nats service in semi-colon separated form. :

```shell
export NATS_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku nats:create lolipop
```
### print the connection information

```shell
# usage
dokku nats:info <service> [--single-info-flag]
```

examples:

Get connection information as follows:

```shell
dokku nats:info lolipop
```

You can also retrieve a specific piece of service info via flags:

```shell
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
```
### print the most recent log(s) for this service

```shell
# usage
dokku nats:logs <service> [-t|--tail]
```

examples:

You can tail logs for a particular service:

```shell
dokku nats:logs lolipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku nats:logs lolipop --tail
```
### link the nats service to the app

```shell
# usage
dokku nats:link <service> <app> [--link-flags...]
```

examples:

A nats service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our 'playground' app. :

> NOTE: this will restart your app

```shell
dokku nats:link lolipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won’t be listed when calling dokku config):

```
DOKKU_NATS_LOLIPOP_NAME=/lolipop/DATABASE
DOKKU_NATS_LOLIPOP_PORT=tcp://172.17.0.1:4222
DOKKU_NATS_LOLIPOP_PORT_4222_TCP=tcp://172.17.0.1:4222
DOKKU_NATS_LOLIPOP_PORT_4222_TCP_PROTO=tcp
DOKKU_NATS_LOLIPOP_PORT_4222_TCP_PORT=4222
DOKKU_NATS_LOLIPOP_PORT_4222_TCP_ADDR=172.17.0.1
```

The following will be set on the linked application by default:

```
NATS_URL=nats://lolipop:SOME_PASSWORD@dokku-nats-lolipop:4222/lolipop
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the 'expose' subcommand. Another service can be linked to your app:

```shell
dokku nats:link other_service playground
```

It is possible to change the protocol for nats_url by setting the environment variable nats_database_scheme on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding. :

```shell
dokku config:set playground NATS_DATABASE_SCHEME=nats2
dokku nats:link lolipop playground
```

This will cause nats_url to be set as:

```
nats2://lolipop:SOME_PASSWORD@dokku-nats-lolipop:4222/lolipop
```
### unlink the nats service from the app

```shell
# usage
dokku nats:unlink <service> <app>
```

examples:

You can unlink a nats service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku nats:unlink lolipop playground
```
### delete the nats service/data/container if there are no links left

```shell
# usage
dokku nats:destroy <service> [-f|--force]
```

examples:

Destroy the service, it's data, and the running container:

```shell
dokku nats:destroy lolipop
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### connect to the service via the nats connection tool

```shell
# usage
dokku nats:connect <service>
```

examples:

Connect to the service via the nats connection tool:

```shell
dokku nats:connect lolipop
```
### enter or run a command in a running nats service container

```shell
# usage
dokku nats:enter <service>
```

examples:

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk. :

```shell
dokku nats:enter lolipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk. :

```shell
dokku nats:enter lolipop touch /tmp/test
```
### expose a nats service on custom port if provided (random port otherwise)

```shell
# usage
dokku nats:expose <service> <ports...>
```

examples:

Expose the service on the service's normal ports, allowing access to it from the public interface (0. 0. 0. 0):

```shell
dokku nats:expose lolipop ${PLUGIN_DATASTORE_PORTS[@]}
```
### unexpose a previously exposed nats service

```shell
# usage
dokku nats:unexpose <service>
```

examples:

Unexpose the service, removing access to it from the public interface (0. 0. 0. 0):

```shell
dokku nats:unexpose lolipop
```
### promote service <service> as NATS_URL in <app>

```shell
# usage
dokku nats:promote <service> <app>
```

examples:

If you have a nats service linked to an app and try to link another nats service another link environment variable will be generated automatically:

```
DOKKU_NATS_BLUE_URL=nats://other_service:ANOTHER_PASSWORD@dokku-nats-other-service:4222/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku nats:promote other_service playground
```

This will replace nats_url with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
NATS_URL=nats://other_service:ANOTHER_PASSWORD@dokku-nats-other-service:4222/other_service
DOKKU_NATS_BLUE_URL=nats://other_service:ANOTHER_PASSWORD@dokku-nats-other-service:4222/other_service
DOKKU_NATS_SILVER_URL=nats://lolipop:SOME_PASSWORD@dokku-nats-lolipop:4222/lolipop
```
### graceful shutdown and restart of the nats service container

```shell
# usage
dokku nats:restart <service>
```

examples:

Restart the service:

```shell
dokku nats:restart lolipop
```
### start a previously stopped nats service

```shell
# usage
dokku nats:start <service>
```

examples:

Start the service:

```shell
dokku nats:start lolipop
```
### stop a running nats service

```shell
# usage
dokku nats:stop <service>
```

examples:

Stop the service and the running container:

```shell
dokku nats:stop lolipop
```
### upgrade service <service> to the specified versions

```shell
# usage
dokku nats:upgrade <service> [--upgrade-flags...]
```

examples:

You can upgrade an existing service to a new image or image-version:

```shell
dokku nats:upgrade lolipop
```

### Service Automation

Service scripting can be executed using the following commands:

### list all nats service links for a given app

```shell
# usage
dokku nats:app-links <app>
```

examples:

List all nats services that are linked to the 'playground' app. :

```shell
dokku nats:app-links playground
```
### create container <new-name> then copy data from <name> into <new-name>

```shell
# usage
dokku nats:clone <service> <new-service> [--clone-flags...]
```

examples:

You can clone an existing service to a new one:

```shell
dokku nats:clone lolipop lolipop-2
```
### check if the nats service exists

```shell
# usage
dokku nats:exists <service>
```

examples:

Here we check if the lolipop nats service exists. :

```shell
dokku nats:exists lolipop
```
### check if the nats service is linked to an app

```shell
# usage
dokku nats:linked <service> <app>
```

examples:

Here we check if the lolipop nats service is linked to the 'playground' app. :

```shell
dokku nats:linked lolipop playground
```
### list all apps linked to the nats service

```shell
# usage
dokku nats:links <service>
```

examples:

List all apps linked to the 'lolipop' nats service. :

```shell
dokku nats:links lolipop
```

### Data Management

The underlying service data can be imported and exported with the following commands:

### import a dump into the nats service database

```shell
# usage
dokku nats:import <service>
```

examples:

Import a datastore dump:

```shell
dokku nats:import lolipop < database.dump
```
### export a dump of the nats service database

```shell
# usage
dokku nats:export <service>
```

examples:

By default, datastore output is exported to stdout:

```shell
dokku nats:export lolipop
```

You can redirect this output to a file:

```shell
dokku nats:export lolipop > lolipop.dump
```

### Backups

Datastore backups are supported via AWS S3 and S3 compatible services like [minio](https://github.com/minio/minio).

You may skip the `backup-auth` step if your dokku install is running within EC2 and has access to the bucket via an IAM profile. In that case, use the `--use-iam` option with the `backup` command.

Backups can be performed using the backup commands:

### sets up authentication for backups on the nats service

```shell
# usage
dokku nats:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url>
```

examples:

Setup s3 backup authentication:

```shell
dokku nats:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
```

Setup s3 backup authentication with different region:

```shell
dokku nats:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION
```

Setup s3 backup authentication with different signature version and endpoint:

```shell
dokku nats:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_SIGNATURE_VERSION ENDPOINT_URL
```

More specific example for minio auth:

```shell
dokku nats:backup-auth lolipop MINIO_ACCESS_KEY_ID MINIO_SECRET_ACCESS_KEY us-east-1 s3v4 https://YOURMINIOSERVICE
```
### removes backup authentication for the nats service

```shell
# usage
dokku nats:backup-deauth <service>
```

examples:

Remove s3 authentication:

```shell
dokku nats:backup-deauth lolipop
```
### creates a backup of the nats service to an existing s3 bucket

```shell
# usage
dokku nats:backup <service> <bucket-name> [--use-iam]
```

examples:

Backup the 'lolipop' service to the 'my-s3-bucket' bucket on aws:

```shell
dokku nats:backup lolipop my-s3-bucket --use-iam
```
### sets encryption for all future backups of nats service

```shell
# usage
dokku nats:backup-set-encryption <service> <passphrase>
```

examples:

Set a gpg passphrase for backups:

```shell
dokku nats:backup-set-encryption lolipop
```
### unsets encryption for future backups of the nats service

```shell
# usage
dokku nats:backup-unset-encryption <service>
```

examples:

Unset a gpg encryption key for backups:

```shell
dokku nats:backup-unset-encryption lolipop
```
### schedules a backup of the nats service

```shell
# usage
dokku nats:backup-schedule <service> <schedule> <bucket-name> [--use-iam]
```

examples:

Schedule a backup:

> 'schedule' is a crontab expression, eg. "0 3 * * *" for each day at 3am

```shell
dokku nats:backup-schedule lolipop "0 3 * * *" my-s3-bucket
```

Schedule a backup and authenticate via iam:

```shell
dokku nats:backup-schedule lolipop "0 3 * * *" my-s3-bucket --use-iam
```
### cat the contents of the configured backup cronfile for the service

```shell
# usage
dokku nats:backup-schedule-cat <service>
```

examples:

Cat the contents of the configured backup cronfile for the service:

```shell
dokku nats:backup-schedule-cat lolipop
```
### unschedules the backup of the nats service

```shell
# usage
dokku nats:backup-unschedule <service>
```

examples:

Remove the scheduled backup from cron:

```shell
dokku nats:backup-unschedule lolipop
```

### Disabling `docker pull` calls

If you wish to disable the `docker pull` calls that the plugin triggers, you may set the `NATS_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker pull` is disabled.