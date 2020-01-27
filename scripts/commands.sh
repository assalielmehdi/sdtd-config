#!/bin/bash

# make custom commands functions available to user bash

echo "source /tools/commands.sh" >> /root/.bashrc

# export variables that will be used for create and destroy functions

echo "export KOPS_CLUSTER_NAME=assalielmehdi.com" >> /root/.bashrc
echo "export KOPS_HOSTED_ZONE_DNS=$KOPS_CLUSTER_NAME" >> /root/.bashrc
echo "export KOPS_STATE_BUCKET_NAME=k8s.assalielmehdi.config" >> /root/.bashrc
echo "export KOPS_STATE_STORE=s3://k8s.assalielmehdi.config" >> /root/.bashrc
echo "export HOSTED_ZONE_ID=Z1DENIO08UMGGK" >> /root/.bashrc

# variables used in this file to configure cluster

NODE_SIZE=t2.large
NODE_COUNT=3
NODE_VOLUME_SIZE=50

MASTER_SIZE=t2.medium
MASTER_COUNT=1
MASTER_VOLUME_SIZE=30

CASSANDRA_CLUSTER_SIZE=2
KAFKA_CLUSTER_SIZE=3

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

  export KAFKA_READY_STATUS=""

  for (( c=1; c<=$KAFKA_CLUSTER_SIZE; c++ ))
  do
    export KAFKA_READY_STATUS="${KAFKA_READY_STATUS} True"
  done

  helm install kafka-cp-kafka-headless incubator/kafka --set replicas=$KAFKA_CLUSTER_SIZE,prometheus.jmx.enabled=true
  while [[ " $(kubectl get pods -l app.kubernetes.io/name=kafka -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}')" != "${KAFKA_READY_STATUS}" ]]; do echo "waiting kafka cluster..." && sleep 15; done
  export KAFKA_CLUSTER_ENTRY_POINT="kafka-cp-kafka-headless"
}

function destroy_kafka() {
  helm uninstall kafka-cp-kafka-headless
}

# apps deployment functions

function create_metrics() {
  envsubst < /tools/metrics_deployment.yaml > /tools/metrics_deployment.yaml.tmp && mv /tools/metrics_deployment.yaml.tmp /tools/metrics_deployment.yaml

  kubectl apply -f /tools/metrics_deployment.yaml
  kubectl apply -f /tools/metrics_service.yaml
}

function destroy_metrics() {
  kubectl delete -f /tools/metrics_deployment.yaml
}

function create_burrow() {
  kubectl apply -f /tools/burrow_deployment.yaml
  kubectl apply -f /tools/burrow_service.yaml
}

function destroy_burrow() {
  kubectl delete svc burrow-api
  kubectl delete -f /tools/burrow_deployment.yaml
}

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

function create_weather2kafka() {
  envsubst < /tools/weather2kafka_deployment.yaml > /tools/weather2kafka_deployment.yaml.tmp && mv /tools/weather2kafka_deployment.yaml.tmp /tools/weather2kafka_deployment.yaml

  kubectl apply -f /tools/weather2kafka_deployment.yaml
}

function destroy_weather2kafka() {
  kubectl delete -f /tools/weather2kafka_deployment.yaml
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

  export CASSANDRA_READY_STATUS=""

  for (( c=1; c<=$CASSANDRA_CLUSTER_SIZE; c++ ))
  do
    export CASSANDRA_READY_STATUS="${CASSANDRA_READY_STATUS} True"
  done

  helm install cassandra incubator/cassandra --set config.cluster_size=${CASSANDRA_CLUSTER_SIZE}
  while [[ " $(kubectl get pods -l app=cassandra -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}')" != "${CASSANDRA_READY_STATUS}" ]]; do echo "waiting cassandra cluster..." && sleep 15; done

  export CASSANDRA_CLUSTER_ENTRY_POINT="cassandra"
  export CASSANDRA_HOSTS="cassandra"
}

function destroy_cassandra() {
  destroy_storage_ebs

  helm uninstall cassandra
}

# grafana setup functions

function add_stable_repo() {
  helm repo add stable https://kubernetes-charts.storage.googleapis.com/
}

function create_grafana() {
  add_stable_repo

  helm install grafana stable/grafana -f /tools/dashboard_helm_values.yaml --set service.type=LoadBalancer --set plugins[0]="natel-plotly-panel" --set plugins[1]="simpod-json-datasource"

  export GRAFANA_ADMIN_PW=$(kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo)

  until [[ $(kubectl get svc --namespace default grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}') ]];
  do
    echo "Waiting for Load Balancer to setup"
    sleep 5
  done

  export GRAFANA_ENTRYPOINT=$(kubectl get svc --namespace default grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
  
  envsubst < /tools/change_cname.json > /tools/change_cname.json.tmp && mv /tools/change_cname.json.tmp /tools/change_cname.json

  aws route53 change-resource-record-sets \
    --hosted-zone-id $HOSTED_ZONE_ID \
    --change-batch file:///tools/change_cname.json

  echo "In minutes you can access Grafana dashboard via:    http://grafana.assalielmehdi.com"
  echo "Admin credentials:"
  echo "    Username: admin"
  echo "    Password: $GRAFANA_ADMIN_PW"
}

function destroy_grafana() {
  helm uninstall grafana
}

# charge injection functions

function create_tweets_db() {
  helm install mysql stable/mysql --set mysqlRootPassword=root && sleep 15

  export MYSQL_POD=$(kubectl get pods | grep "mysql*" | awk '{print $1}')

  kubectl exec ${MYSQL_POD} -- apt-get update
  kubectl exec ${MYSQL_POD} -- apt-get install -y curl
  kubectl exec ${MYSQL_POD} -- curl https://sdtd-tweets-archive.s3-eu-west-1.amazonaws.com/tweets.sql --output tweets.sql
  kubectl exec ${MYSQL_POD} -- bash -c "mysql -u root -proot < tweets.sql"
}

function inject() {
  kubectl apply -f /tools/tweets_injection.yaml

  kubectl scale deployment tweets-injection-deployment --replicas=$1
}

# one push button functions

function create() {
  create_cluster

  create_cassandra

  create_kafka

  create_flink

  create_twitter2kafka

  create_kafka2db

  create_weather2kafka

  create_grafana

  create_burrow

  create_metrics

  create_tweets_db
}

function destroy() {
  destroy_metrics

  destroy_burrow

  destroy_grafana

  destroy_weather2kafka

  destroy_kafka2db
  
  destroy_twitter2kafka

  destroy_flink

  destroy_kafka

  destroy_cassandra

  destroy_cluster
}
