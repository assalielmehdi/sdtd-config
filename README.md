01)Buy a domain on AWS rute 53 and replace in commands.sh the
"k8s-sdtd-ensimag.eu" string for your domain on this command:
echo "export KOPS_CLUSTER_NAME=k8s-sdtd-ensimag.eu" >> /root/.bashrc
02) Create a awscredentials under tools folder and  paste:
[default]
aws_access_key_id=(your access key)
aws_secret_access_key=(your secret key)

03) to start the deployment on AWS do:

sudo systemctl start docker
sudo docker build -t tools -f tools .
docker run -it -v $(pwd):/tmp/tools tools
create (and do destroy to destroy)

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

Then follow the steps of this medium to see the kubernetes dashboard (still have to automate this part):
https://medium.com/@kanrangsan/creating-admin-user-to-access-kubernetes-dashboard-723d6c9764e4
