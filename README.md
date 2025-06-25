# devcontainer-micromamba

> vscode config files for a devcontainer with micromamba

## Requirements

- docker
- vscode with `Dev Containers` (`ms-vscode-remote.remote-containers`) extension installed

## Quickstart (rootful-docker)

Adjust the name of the image in `docker-build.sh` and `.devcontainer/devcontainer.json`.

```sh
# build devcontainer-micromamba docker image
$ chmod +x docker-build.sh
$ ./docker-build.sh
```

Adjust the required conda dependencies in `environment.yml`.
This Dev Container is meant to be used for developing a Python package.
Therefore, the `post-install.sh` script will attempt to install the current project via `pip install -e .`.
If you don't need this, comment out the `postCreateCommand` in `.devcontainer/devcontainer.json`

```sh
# make post-install script executable
$ chmod +x .devcontainer/post-install.sh
```

To launch the devcontainer, in vscode:

- open the command palette (F1 / CTRL+SHIFT+P)
- select `Dev Containers: Open Folder in Container`
- select the current project folder

## Container Setup

- non-root user `dev`, with `uid` and `gid` mapped to the local user (configurable via docker build args)
- workspace: `~/workspace`
- default micromamba env: `dev` (automatically activated by `.bashrc`)

## git with ssh inside the devcontainer

The Dev Containers extension already allows you to use your Git credentials from inside the container.
However, you might still need to forward your local *SSH Agent* when using SSH keys:

- enable `AllowAgentForwarding` in `/etc/ssh/sshd_config`
- make sure your local ssh agent is running
- add the required keys via `ssh-add`

For more information, see [Sharing Git credentials with your container](https://code.visualstudio.com/remote/advancedcontainers/sharing-git-credentials).

## With GPU/CUDA support

For CUDA support, you can change the base image in the Dockerfile to something like `nvidia/cuda:12.9.1-cudnn-runtime-ubuntu24.04`.


## Rootless Docker

This is where the fun begins: if you are using rootless docker, you will find that the non-root container user (i.e., `dev`) can't create any files in the workspace.
Inside the container, the workspace is owned by `root`, which is mapped back to your local users `uid`.
And while your non-root container user `dev` has the same `uid` inside the container, it is mapped to an arbitrary `uid` outside the container.
Unfortunately, there does currently not seem to be a good solution that handles bot rootless, as well as rootful Docker...
Please see the `rootless` files and be aware, that you will be the root user inside the container...
