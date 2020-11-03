# docker-lerna-dev

[![Build Status](https://drone.kilic.dev/api/badges/cenk1cenk2/docker-lerna-dev/status.svg)](https://drone.kilic.dev/cenk1cenk2/docker-lerna-dev) [![Docker Pulls](https://img.shields.io/docker/pulls/cenk1cenk2/lerna-dev)](https://hub.docker.com/repository/docker/cenk1cenk2/lerna-dev) [![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/cenk1cenk2/lerna-dev)](https://hub.docker.com/repository/docker/cenk1cenk2/lerna-dev) [![Docker Image Version (latest by date)](https://img.shields.io/docker/v/cenk1cenk2/lerna-dev)](https://hub.docker.com/repository/docker/cenk1cenk2/lerna-dev) [![GitHub last commit](https://img.shields.io/github/last-commit/cenk1cenk2/docker-lerna-dev)](https://github.com/cenk1cenk2/docker-lerna-dev)

<!-- toc -->

- [Description](#description)
- [Image](#image)
- [Steps](#steps)
- [Usage](#usage)
- [Environment Variables](#environment-variables)
  - [Debug Port](#debug-port)
  - [Services Overrides](#services-overrides)
  - [Run In Band Overrides](#run-in-band-overrides)

<!-- tocstop -->

# Description

Runs a [lerna](git@github.com:lerna/lerna.git) development environment inside a Docker container. This container automatically generates `run` files for [s6-overlay](https://github.com/just-containers/s6-overlay) depending on environment variables.

# Image

Latest uses the last node version, for now it is 14. `cenk1cenk2/lerna-dev:latest`

You can also select from available images below. `[latest, 12, 14]`

# Steps

1. Installs root dependencies.
2. Runs the init environment command if defined.
3. Runs packages in RUN_IN_BAND variable sequentially, if defined.
4. Runs all the packages asynchronously.
5. Crashing packages will be restarted with 5s delay automatically.

# Usage

- Mount the root lerna directory to `/data/app`.
- Expose any required ports.

# Environment Variables

This Docker container highly depends on environment variables to function properly.

**If you want to use environment variables for the packages itself, you can place a `.env` file in the root of the package directory. You can also override `PACKAGE_START_COMMAND` of that package by adding that to the environment variable.**

What I did not want to do is automatically detecting packages, because I usually disable some of them depending on the occasion.

| Variable                            | Short Description                                                                                                                                     | Default   | Override |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | -------- |
| PACKAGE_START_COMMAND               | The default NPM command for running for the package.                                                                                                  | dev:start | yes      |
| [DEBUG_PORT_START](<#(Debug-Port)>) | Debug port start.                                                                                                                                     | 9229      |          |
| INIT_ENV_FORCE_INSTALL              | If the node_modules directory is present, it will not try to do an install. But you can override this by setting this variable to not empty.          |           |          |
| INIT_ENV_COMMAND                    | You can run a command before starting to run the packages.                                                                                            |           |          |
| SERVICES                            | Define packages and their root directories relative to root of the project. [**Has overrides.**](<#(Services-Overrides)>)                             |           |          |
| PREFIX_LABEL                        | Prefixes label to the service name to get distinction.                                                                                                | true      |          |
| RUN_IN_BAND                         | Run this packages first before running the rest asynchronously. [**Has to match the relative directory of the service.**](<#(Run-In-Band-Overrides)>) |           |          |
| RUN_IN_BAND_WAIT                    | Wait for RUN_IN_BAND items to compelete in seconds.                                                                                                   | 10        |          |

## Debug Port

This creates a debug part environment variable, which is incremented by one for every package.

With this variable it is easier to access all the debug ports for the packages.

You can create a dev:start command for your packages like 'node --inspect=0.0.0.0:\${DEBUG_PORT:-'9229'} ...' utilizing this variable.

## Services Overrides

- Multiple packages shall be splitted by colon `:`.
- Package should have a relative path to the root of the repository.
- Overrides can be added by spliting them with comma `,`.
  - `off` override disables the package temporarily.
  - `no_log`, will disable log capability for this process.
  - `override='*'`, will change the `npm/yarn run` command can override the default command.

**Example**

_If you desire overrides on per package basis._

```bash
SERVICES=packages/service1,off,override='start':packages/service2,override='dev'
```

_If you do not want any overrides it is even easier._

```bash
SERVICES=packages/service1:packages/service2
```

## Run In Band Overrides

Run in band allows to build dependent packages first. Currently it will not check whether this packages are really doing what they are supposed to but, it will wait until the process finishes so it will give them a head start.

- Multiple packages again, shall be splitted by colon `:`.
- The relative paths of the packages has to match the `SERVICES` variable.

```bash
RUN_IN_BAND=packages/service1:packages/service2
RUN_IN_BAND_WAIT=30
```
