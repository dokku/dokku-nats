# dokku nats [![Build Status](https://img.shields.io/github/workflow/status/dokku/dokku-nats/CI/master?style=flat-square "Build Status")](https://github.com/dokku/dokku-nats/actions/workflows/ci.yml?query=branch%3Amaster) [![IRC Network](https://img.shields.io/badge/irc-libera-blue.svg?style=flat-square "IRC Libera")](https://webchat.libera.chat/?channels=dokku)

Official nats plugin for dokku. Currently defaults to installing [nats 2.5.0](https://hub.docker.com/_/nats/).

## Requirements

- dokku 0.19.x+
- docker 1.8.x

## Installation

```shell
# on 0.19.x+
sudo dokku plugin:install https://github.com/dokku/dokku-nats.git nats
```

## Commands

```
nats:app-links <app>                        # list all nats service links for a given app
nats:create <service> [--create-flags...]   # create a nats service
nats:destroy <service> [-f|--force]         # delete the nats service/data/container if there are no links left
nats:enter <service>                        # enter or run a command in a running nats service container
nats:exists <service>                       # check if the nats service exists
nats:expose <service> <ports...>            # expose a nats service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)
nats:info <service> [--single-info-flag]    # print the service information
nats:link <service> <app> [--link-flags...] # link the nats service to the app
nats:linked <service> <app>                 # check if the nats service is linked to an app
nats:links <service>                        # list all apps linked to the nats service
nats:list                                   # list all nats services
nats:logs <service> [-t|--tail]             # print the most recent log(s) for this service
nats:promote <service> <app>                # promote service <service> as NATS_URL in <app>
nats:restart <service>                      # graceful shutdown and restart of the nats service container
nats:start <service>                        # start a previously stopped nats service
nats:stop <service>                         # stop a running nats service
nats:unexpose <service>                     # unexpose a previously exposed nats service
nats:unlink <service> <app>                 # unlink the nats service from the app
nats:upgrade <service> [--upgrade-flags...] # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to nats:help. Plugin help output in conjunction with any files in the `docs/` folder is used to generate the plugin documentation. Please consult the `nats:help` command for any undocumented commands.

### Basic Usage

### create a nats service

```shell
# usage
dokku nats:create <service> [--create-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-m|--memory MEMORY`: container memory limit (default: unlimited)
- `-p|--password PASSWORD`: override the user-level service password
- `-r|--root-password PASSWORD`: override the root-level service password
- `-s|--shm-size SHM_SIZE`: override shared memory size for nats docker container

Create a nats service named lollipop:

```shell
dokku nats:create lollipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the nats image.

```shell
export NATS_IMAGE="nats"
export NATS_IMAGE_VERSION="${PLUGIN_IMAGE_VERSION}"
dokku nats:create lollipop
```

You can also specify custom environment variables to start the nats service in semi-colon separated form.

```shell
export NATS_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku nats:create lollipop
```

### print the service information

```shell
# usage
dokku nats:info <service> [--single-info-flag]
```

flags:

- `--config-dir`: show the service configuration directory
- `--data-dir`: show the service data directory
- `--dsn`: show the service DSN
- `--exposed-ports`: show service exposed ports
- `--id`: show the service container id
- `--internal-ip`: show the service internal ip
- `--links`: show the service app links
- `--service-root`: show the service root directory
- `--status`: show the service running status
- `--version`: show the service image version

Get connection information as follows:

```shell
dokku nats:info lollipop
```

You can also retrieve a specific piece of service info via flags:

```shell
dokku nats:info lollipop --config-dir
dokku nats:info lollipop --data-dir
dokku nats:info lollipop --dsn
dokku nats:info lollipop --exposed-ports
dokku nats:info lollipop --id
dokku nats:info lollipop --internal-ip
dokku nats:info lollipop --links
dokku nats:info lollipop --service-root
dokku nats:info lollipop --status
dokku nats:info lollipop --version
```

### list all nats services

```shell
# usage
dokku nats:list 
```

List all services:

```shell
dokku nats:list
```

### print the most recent log(s) for this service

```shell
# usage
dokku nats:logs <service> [-t|--tail]
```

flags:

- `-t|--tail`: do not stop when end of the logs are reached and wait for additional output

You can tail logs for a particular service:

```shell
dokku nats:logs lollipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku nats:logs lollipop --tail
```

### link the nats service to the app

```shell
# usage
dokku nats:link <service> <app> [--link-flags...]
```

flags:

- `-a|--alias "BLUE_DATABASE"`: an alternative alias to use for linking to an app via environment variable
- `-q|--querystring "pool=5"`: ampersand delimited querystring arguments to append to the service link

A nats service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our `playground` app.

> NOTE: this will restart your app

```shell
dokku nats:link lollipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won’t be listed when calling dokku config):

```
DOKKU_NATS_LOLLIPOP_NAME=/lollipop/DATABASE
DOKKU_NATS_LOLLIPOP_PORT=tcp://172.17.0.1:4222
DOKKU_NATS_LOLLIPOP_PORT_4222_TCP=tcp://172.17.0.1:4222
DOKKU_NATS_LOLLIPOP_PORT_4222_TCP_PROTO=tcp
DOKKU_NATS_LOLLIPOP_PORT_4222_TCP_PORT=4222
DOKKU_NATS_LOLLIPOP_PORT_4222_TCP_ADDR=172.17.0.1
```

The following will be set on the linked application by default:

```
NATS_URL=nats://lollipop:SOME_PASSWORD@dokku-nats-lollipop:4222
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the `expose` subcommand. Another service can be linked to your app:

```shell
dokku nats:link other_service playground
```

It is possible to change the protocol for `NATS_URL` by setting the environment variable `NATS_DATABASE_SCHEME` on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding.

```shell
dokku config:set playground NATS_DATABASE_SCHEME=nats2
dokku nats:link lollipop playground
```

This will cause `NATS_URL` to be set as:

```
nats2://lollipop:SOME_PASSWORD@dokku-nats-lollipop:4222
```

### unlink the nats service from the app

```shell
# usage
dokku nats:unlink <service> <app>
```

You can unlink a nats service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku nats:unlink lollipop playground
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### enter or run a command in a running nats service container

```shell
# usage
dokku nats:enter <service>
```

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk.

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku nats:enter lollipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk.

```shell
dokku nats:enter lollipop touch /tmp/test
```

### expose a nats service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)

```shell
# usage
dokku nats:expose <service> <ports...>
```

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku nats:expose lollipop 4222
```

Expose the service on the service's normal ports, with the first on a specified ip adddress (127.0.0.1):

```shell
dokku nats:expose lollipop 127.0.0.1:4222
```

### unexpose a previously exposed nats service

```shell
# usage
dokku nats:unexpose <service>
```

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku nats:unexpose lollipop
```

### promote service <service> as NATS_URL in <app>

```shell
# usage
dokku nats:promote <service> <app>
```

If you have a nats service linked to an app and try to link another nats service another link environment variable will be generated automatically:

```
DOKKU_NATS_BLUE_URL=nats://other_service:ANOTHER_PASSWORD@dokku-nats-other-service:4222/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku nats:promote other_service playground
```

This will replace `NATS_URL` with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
NATS_URL=nats://other_service:ANOTHER_PASSWORD@dokku-nats-other-service:4222/other_service
DOKKU_NATS_BLUE_URL=nats://other_service:ANOTHER_PASSWORD@dokku-nats-other-service:4222/other_service
DOKKU_NATS_SILVER_URL=nats://lollipop:SOME_PASSWORD@dokku-nats-lollipop:4222/lollipop
```

### start a previously stopped nats service

```shell
# usage
dokku nats:start <service>
```

Start the service:

```shell
dokku nats:start lollipop
```

### stop a running nats service

```shell
# usage
dokku nats:stop <service>
```

Stop the service and the running container:

```shell
dokku nats:stop lollipop
```

### graceful shutdown and restart of the nats service container

```shell
# usage
dokku nats:restart <service>
```

Restart the service:

```shell
dokku nats:restart lollipop
```

### upgrade service <service> to the specified versions

```shell
# usage
dokku nats:upgrade <service> [--upgrade-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-R|--restart-apps "true"`: whether to force an app restart
- `-s|--shm-size SHM_SIZE`: override shared memory size for nats docker container

You can upgrade an existing service to a new image or image-version:

```shell
dokku nats:upgrade lollipop
```

### Service Automation

Service scripting can be executed using the following commands:

### list all nats service links for a given app

```shell
# usage
dokku nats:app-links <app>
```

List all nats services that are linked to the `playground` app.

```shell
dokku nats:app-links playground
```

### check if the nats service exists

```shell
# usage
dokku nats:exists <service>
```

Here we check if the lollipop nats service exists.

```shell
dokku nats:exists lollipop
```

### check if the nats service is linked to an app

```shell
# usage
dokku nats:linked <service> <app>
```

Here we check if the lollipop nats service is linked to the `playground` app.

```shell
dokku nats:linked lollipop playground
```

### list all apps linked to the nats service

```shell
# usage
dokku nats:links <service>
```

List all apps linked to the `lollipop` nats service.

```shell
dokku nats:links lollipop
```

### Disabling `docker pull` calls

If you wish to disable the `docker pull` calls that the plugin triggers, you may set the `NATS_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker pull` is disabled.
