#!/bin/bash

# make custom commands functions available to user bash

echo "source /tools/commands.sh" >> /root/.bashrc

# export variables that will be used for create and destroy functions

echo "export KOPS_CLUSTER_NAME=sdtd-k8s.assalielmehdi.com" >> /root/.bashrc
echo "export KOPS_HOSTED_ZONE_DNS=$KOPS_CLUSTER_NAME" >> /root/.bashrc
echo "export KOPS_STATE_BUCKET_NAME=sdtd-k8s-config" >> /root/.bashrc
echo "export KOPS_STATE_STORE=s3://$KOPS_STATE_BUCKET_NAME" >> /root/.bashrc

# variables used in this file to configure cluster

NODE_SIZE=t2.large
NODE_COUNT=3
NODE_VOLUME_SIZE=50

MASTER_SIZE=t2.xlarge
MASTER_COUNT=1
MASTER_VOLUME_SIZE=30


# AWS cluster setup functions

function create_kops_bucket() {
	aws s3api create-bucket \
    --region $REGION \
    --bucket $KOPS_STATE_BUCKET_NAME \
    --create-bucket-configuration LocationConstraint=$REGION

	aws s3api put-bucket-versioning \
    --bucket $KOPS_STATE_BUCKET_NAME \
    --versioning-configuration Status=Enabled

	export KOPS_STATE_STORE="s3://$KOPS_STATE_BUCKET_NAME"
}

function create_kops_cluster() {
	kops create cluster \
		--dns-zone=${KOPS_HOSTED_ZONE_DNS} \
    --zones=${ZONE} \
    --master-size=${MASTER_SIZE} \
    --master-volume-size=${MASTER_VOLUME_SIZE} \
    --master-count=${MASTER_COUNT} \
    --node-size=${NODE_SIZE} \
    --node-volume-size=${NODE_VOLUME_SIZE} \
    --node-count=${NODE_COUNT} \
    --cloud=aws \
    --image="kope.io/k8s-1.10-debian-stretch-amd64-hvm-ebs-2018-05-27" \
    --networking=kube-router \
    --topology=private \
    --bastion=true \
    --dry-run=true \
    --name=${KOPS_CLUSTER_NAME} \
    -o=yaml > cluster.yaml

    kops create -f cluster.yaml

    kops create secret --name ${KOPS_CLUSTER_NAME} sshpublickey admin -i ~/.ssh/id_rsa.pub

    kops update cluster --yes
}

function create_cluster() {
	create_kops_bucket

	create_kops_cluster
}

function destroy_cluster() {
	kops delete cluster --yes
}

# kafka cluster setup functions

function update_helm_repo() {
  helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/

  helm repo update
}

function create_kafka() {
  update_helm_repo

  helm install confluentinc/cp-helm-charts --generate-name

  export KAFKA_CLUSTER_NAME="$(helm list -q)"
  export KAFKA_CLUSTER_ENTRY_POINT="$KAFKA_CLUSTER_NAME-cp-kafka-headless"
}

function destroy_kafka() {
  helm delete $KAFKA_CLUSTER_NAME
}

# apps deployment functions

function deploy_kafka2twitter() {
  kubectl apply -f /tools/kafka2twitter_deployment.yaml
}

function delete_kafka2twitter() {
  kubectl delete -f /tools/kafka2twitter_deployment.yaml
}