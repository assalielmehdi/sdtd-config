# create ssh folder that will hold cluster key
mkdir -p /root/.ssh

# install system dependencies
yum install -y sudo
yum install -y wget
yum install -y jq
yum install -y openssl
yum install -y which