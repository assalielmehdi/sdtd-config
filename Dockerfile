# extend base image
FROM centos:latest

# include aws credentials to home directory
ADD ./secrets/awscredentials /root/.aws/credentials

# update OS
RUN yum -y update

# accept region as build args or
# use eu-west-1 as default
ARG REGION=eu-west-1
ENV REGION=$REGION

# accept zone as build args or
# use eu-west-1a as default
ARG ZONE=eu-west-1a
ENV ZONE=$ZONE

# add scripts to context
COPY ./scripts/*.sh /tools/

# add .yaml manifests to context
COPY ./manifests/*/*.yaml ./manifests/*/*.json /tools/

# install toolings
RUN bash /tools/install.sh \
  && bash /tools/commands.sh

# include public rsa key that will be used w/ kops
COPY ./secrets/k8s_rsa.pub /root/.ssh/id_rsa.pub