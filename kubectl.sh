# download the latest kubectl release
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

# make the kubectl binary executable
chmod +x ./kubectl

# move the binary in to your PATH
sudo mv ./kubectl /usr/local/bin/kubectl