# install python3
yum install -y python3

# install pip for python3
yum install -y python3-pip

# install groff since its required by route53
yum install -y groff-base

# install aws cli
pip3 install awscli --upgrade --user

# create aws config file from environment inferece
# including its folder since root would not have it pre
# configured
mkdir -p /root/.aws
touch /root/.aws/config
tee /root/.aws/config <<-'EOF' 
[default]
region=$REGION
output=json
EOF

# make awscli executable available in PATH
echo "export PATH=~/.local/bin:$PATH" > /root/.bashrc
