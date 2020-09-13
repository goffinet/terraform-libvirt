# Set to linux or name of OS
ARG OS=linux

# Set to arch name of your system
ARG ARCH=amd64

# Terraform Version
ARG TERRAFORM_VERSION=0.13.2

# Provider Version
ARG VERSION=0.6.2

# Grab the Terraform binary
FROM hashicorp/terraform:$TERRAFORM_VERSION AS terraform

# Get the Libvirt Plugin Docker
FROM ubuntu:18.04 as libvirt

ARG ARCH=amd64
ARG VERSION=0.6.2

# Install Needed Packages
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install \
    -y --no-install-recommends \
    wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /root/

RUN wget https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v${VERSION}/terraform-provider-libvirt-${VERSION}+git.1585292411.8cbe9ad0.Ubuntu_18.04.amd64.tar.gz \
    && tar xvf terraform-provider-libvirt-${VERSION}+git.1585292411.8cbe9ad0.Ubuntu_18.04.${ARCH}.tar.gz

# Base Image
FROM ubuntu:18.04

ARG OS=linux
ARG ARCH=amd64
ARG VERSION=0.6.2

# Install Dependencies
# libvirt0 is needed to run the provider. xsltproc needed to use XML/XSLT. mkisofs needed to use cloud init images
# ca-certificates to avoid terraform init 509 error. openssh-client to talk to remote libvirt server
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install \
    -y --no-install-recommends \
    libvirt-dev xsltproc mkisofs ca-certificates openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /root/

# Make Directory for Provider Binaries
RUN mkdir -p /root/.local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/${VERSION}/${OS}_${ARCH}/

# Copy binaries from containers
COPY --from=terraform /bin/terraform /bin/
COPY --from=libvirt /root/terraform-provider-libvirt /root/.local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/${VERSION}/${OS}_${ARCH}/

# Copy Terraform Files
# COPY libvirt.tf /root/

# Terraform commands
# RUN terraform init

# ENTRYPOINT /bin/bash

CMD /bin/terraform
