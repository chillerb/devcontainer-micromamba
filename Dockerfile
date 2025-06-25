FROM debian:stable-slim
# For CUDA support
# FROM nvidia/cuda:12.9.1-cudnn-runtime-ubuntu24.04

ARG USER_NAME=dev
ARG USER_UID=1000
ARG USER_GID=1000


# install basic utilities and clean up afterward
RUN apt-get update --allow-releaseinfo-change && \
    apt-get upgrade -y && \
    apt-get -y install --no-install-recommends \
        procps wget curl ca-certificates unzip bzip2 git openssh-client vim tmux build-essential && \
    apt-get -y autoremove && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# add the dev user
RUN groupadd --gid $USER_GID $USER_NAME \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USER_NAME} -s /bin/bash
USER ${USER_NAME}

# create .local/bin and add it to path (Dockerfile does not update PATH on user login)
RUN mkdir -p ~/.local/bin
ENV PATH=/home/${USER_NAME}/.local/bin/:${PATH}

# install micromamba as user
## ENV MAMBA_ROOT_PREFIX=/opt/mamba
ENV MAMBA_ROOT_PREFIX=/home/${USER_NAME}/micromamba
RUN curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj -C ~/.local/bin --strip-components=1 bin/micromamba \
    && ~/.local/bin/micromamba shell init -s bash --root-prefix ${MAMBA_ROOT_PREFIX}

# copy and install environment
COPY environment.yml /tmp/environment.yml
RUN micromamba create -n dev -f /tmp/environment.yml && micromamba clean --all --yes
ENV CONDA_DEFAULT_ENV=dev

# run commands in mamba env during docker build
ENV MAMBA_DOCKERFILE_ACTIVATE=1

# activate dev environment on default
# ENV PATH="${MAMBA_ROOT_PREFIX}/envs/dev/bin:$PATH"
RUN echo "micromamba activate dev" >> ~/.bashrc

# expose mlflow, tensorboard, jupyter
EXPOSE 5000 6006 8888

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}/workspace


HEALTHCHECK CMD [ "micromamba", "--version" ]
