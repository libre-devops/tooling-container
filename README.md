![example.png]

# Introduction

Hello :wave:

This repo contains the source files for building the Libre DevOps WSL Development Environment container.

This container was created due to the need to run things locally as an admin in a restricted environment, but requiring a GUI for an IDE and some other things.  As such, Podman was installed on WSL as well as `podman-compose` to run this environment

The container hosts an RDP server and was heavily based on the works of:

- https://hub.docker.com/r/danielguerra/ubuntu-xrdp/
- https://hub.docker.com/r/scottyhardy/docker-remote-desktop
- https://hub.docker.com/r/linuxserver/rdesktop


## How to to use

You can use the container right away, just pull the image from this repo via podman:

```shell
podman pull ghcr.io/libre-devops/gui-tooling-container:latest
```

You can also build it using `podman-compose` with the docker-compose linked.

## Saving state

Remember, containers are not stateful by default, as such, volumes should be used as well as `podman commit` before you exit the container or risk loosing work.