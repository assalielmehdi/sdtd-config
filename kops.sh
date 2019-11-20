# download the latest kops-1.10.0
wget https://github.com/kubernetes/kops/releases/download/1.11.1/kops-linux-amd64

# make the kubectl binary executable
chmod +x kops-linux-amd64

# move the binary in to your PATH
sudo mv kops-linux-amd64 /usr/local/bin/kops
