# create tools temp folder
mkdir /tmp/tools
chmod +rw /tmp/tools

# create ssh folder that will hold cluster key
mkdir -p /root/.ssh

# install sudo
yum install -y sudo
yum install -y wget
yum install -y jq