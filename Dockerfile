# Dockerfile for development use only!
FROM nvidia/cuda:12.5.0-devel-ubuntu22.04 AS nvidia

FROM nvidia AS base

# Set timezone (for tzdata)
ENV TZ=America/Toronto
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Remove the Ubuntu Pro/ESM advertisements
RUN dpkg-divert --divert /etc/apt/apt.conf.d/20apt-esm-hook.conf.bak --rename --local /etc/apt/apt.conf.d/20apt-esm-hook.conf

# Update base packages
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -yq

# Install build tools
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends build-essential
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends software-properties-common

# Install most used locales
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends locales && \
    locale-gen en_US && \
    locale-gen en_US.utf8 && \
    locale-gen en_CA && \
    locale-gen en_CA.utf8 && \
    locale-gen fr_CA && \
    locale-gen fr_CA.utf8

# Install common tools
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends git curl sudo ssh ca-certificates unzip ruby-full make gcc zlib1g-dev

# Clean up APT cache
RUN apt-get autoremove -yq
RUN apt-get clean -yq
RUN rm -rf /var/lib/apt/lists/*

FROM base AS step-dependencies

# add package source for python distributions
RUN add-apt-repository ppa:deadsnakes/ppa

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends wget python3 python3-pip python3-venv libgl1 libglib2.0-0 libssl-dev libffi-dev python3-dev
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends google-perftools nano bc wget ffmpeg
RUN apt-get clean

FROM step-dependencies AS step-user

RUN useradd -m rvc
RUN adduser rvc root
RUN adduser rvc sudo
RUN echo "rvc ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER rvc

FROM step-user AS step-stable-diffusion

SHELL ["/bin/bash", "-c"]

# Clone Stable Diffusion
WORKDIR /home/rvc
COPY --chown=rvc:rvc --chmod=755 init.sh .

VOLUME /home/rvc/Retrieval-based-Voice-Conversion-WebUI

ENV COMMANDLINE_ARGS="--xformers --no-half-vae --listen --enable-insecure-extension-access"

FROM step-stable-diffusion AS step-exec

#ENTRYPOINT exec top -b
ENTRYPOINT exec ./init.sh