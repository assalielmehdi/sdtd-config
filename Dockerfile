# extend base image
FROM centos:latest

# include aws credentials and config to home directory
ADD awscredentials /root/.aws/credentials
ADD awsconfig /root/.aws/config

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
COPY ./*.sh /tools/

# add .yaml files to context
COPY ./*.yaml /tools/

# install toolings
RUN bash /tools/essentials.sh \
  && bash /tools/kubectl.sh \
  && bash /tools/kops.sh \
  && bash /tools/awscli.sh \
  && bash /tools/helm.sh \
  && bash /tools/commands.sh

# include public rsa key that will be used w/ kops
COPY k8s_rsa.pub /root/.ssh/id_rsa.pub

