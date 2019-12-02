#!/bin/bash

# make custom commands functions available to user bash

echo "source /tools/commands.sh" >> /root/.bashrc

# export variables that will be used for create and destroy functions

echo "export KOPS_CLUSTER_NAME=assalielmehdi.com" >> /root/.bashrc
echo "export KOPS_HOSTED_ZONE_DNS=$KOPS_CLUSTER_NAME" >> /root/.bashrc
echo "export KOPS_STATE_BUCKET_NAME=k8s.assalielmehdi.config" >> /root/.bashrc
echo "export KOPS_STATE_STORE=s3://k8s.assalielmehdi.config" >> /root/.bashrc

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

    until [ $(kops validate cluster 2> /dev/null| grep -e "is ready" | wc -l | xargs) -eq 1 ]; 
    do
      echo "Waiting for cluster to setup..."
      sleep 15
    done
}

function create_cluster() {
  create_kops_bucket

  create_kops_cluster
}

function destroy_cluster() {
  kops delete cluster --yes
}

# flink cluster setup functions

function create_flink() {
  envsubst < /tools/flink_jobmanager_service.yaml > /tools/flink_jobmanager_service.yaml.tmp && mv /tools/flink_jobmanager_service.yaml.tmp /tools/flink_jobmanager_service.yaml
  envsubst < /tools/flink_jobmanager_deployment.yaml > /tools/flink_jobmanager_deployment.yaml.tmp && mv /tools/flink_jobmanager_deployment.yaml.tmp /tools/flink_jobmanager_deployment.yaml
  envsubst < /tools/flink_taskmanager_deployment.yaml > /tools/flink_taskmanager_deployment.yaml.tmp && mv /tools/flink_taskmanager_deployment.yaml.tmp /tools/flink_taskmanager_deployment.yaml

  kubectl create -f /tools/flink_jobmanager_service.yaml
  kubectl create -f /tools/flink_jobmanager_deployment.yaml
  kubectl create -f /tools/flink_taskmanager_deployment.yaml
}

function destroy_flink() {
  kubectl delete -f /tools/flink_jobmanager_deployment.yaml
  kubectl delete -f /tools/flink_taskmanager_deployment.yaml
  kubectl delete -f /tools/flink_jobmanager_service.yaml
}

# kafka cluster setup functions

function add_kafka_helm_repo() {
  helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/

  helm repo update
}

function create_kafka() {
  add_kafka_helm_repo

  helm install kafka confluentinc/cp-helm-charts --generate-name 2>/dev/null

  export KAFKA_CLUSTER_ENTRY_POINT="kafka-cp-kafka-headless"
}

function destroy_kafka() {
  helm uninstall kafka
}

# apps deployment functions

function create_twitter2kafka() {
  envsubst < /tools/twitter2kafka_deployment.yaml > /tools/twitter2kafka_deployment.yaml.tmp && mv /tools/twitter2kafka_deployment.yaml.tmp /tools/twitter2kafka_deployment.yaml
  
  kubectl apply -f /tools/twitter2kafka_deployment.yaml
}

function destroy_twitter2kafka() {
  kubectl delete -f /tools/twitter2kafka_deployment.yaml
}

function create_kafka2db() {
  kubectl apply -f /tools/kafka2db_deployment.yaml
}

function destroy_kafka2db() {
  kubectl delete -f /tools/kafka2db_deployment.yaml
}

# cassandra deployment functions

function create_storage_ebs() {
  kubectl apply -f /tools/create_storage_ebs.yaml
}

function destroy_storage_ebs() {
  kubectl delete -f /tools/create_storage_ebs.yaml
}

function add_cassandra_helm_repo() {
  helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/

  helm repo update
}

function create_cassandra() {
  create_storage_ebs

  add_cassandra_helm_repo

  helm install cassandra incubator/cassandra
}

function destroy_cassandra() {
  destroy_storage_ebs

  helm uninstall cassandra
}

# one push button functions

function create() {
  create_cluster

  create_cassandra

  create_kafka

  create_flink

  create_twitter2kafka

  create_kafka2db
}

function destroy() {
  destroy_kafka2db
  
  destroy_twitter2kafka

  destroy_flink

  destroy_kafka

  destroy_cassandra

  destroy_cluster
}
