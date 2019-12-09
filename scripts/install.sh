#!/bin/bash

############ essentials.sh ############

mkdir -p /root/.ssh

yum install -y sudo
yum install -y wget
yum install -y jq
yum install -y openssl
yum install -y which
yum install -y gettext

#######################################

############ kubectl.sh ############

curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin/kubectl

####################################


############ kops.sh ############

wget https://github.com/kubernetes/kops/releases/download/1.11.1/kops-linux-amd64

chmod +x kops-linux-amd64

sudo mv kops-linux-amd64 /usr/local/bin/kops

#################################


############ awscli.sh ############

yum install -y python3
yum install -y python3-pip
yum install -y groff-base

pip3 install awscli --upgrade --user

mkdir -p /root/.aws
touch /root/.aws/config
tee /root/.aws/config <<-'EOF' 
[default]
region=eu-west-1
output=json
EOF

echo "export PATH=~/.local/bin:$PATH" > /root/.bashrc

###################################


############ helm.sh ############

curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh

chmod 700 get_helm.sh

./get_helm.sh

#################################