#!/bin/bash

# make custom commands functions available to user bash
echo "source /tools/commands.sh" >> /root/.bashrc

# export variables that will be used for create and destroy functions
echo "export KOPS_CLUSTER_NAME=k8s-sdtd-ensimag.eu" >> /root/.bashrc
echo "export KOPS_HOSTED_ZONE_DNS=$KOPS_CLUSTER_NAME" >> /root/.bashrc
echo "export KOPS_STATE_BUCKET_NAME=ensimag.kops.k8sstate" >> /root/.bashrc
echo "export KOPS_STATE_STORE=s3://$KOPS_STATE_BUCKET_NAME" >> /root/.bashrc

# variables used in this file to configure cluster
NODE_SIZE=t2.medium
MASTER_SIZE=t2.medium
MASTER_COUNT=1
MASTER_VOLUME_SIZE=30
NODE_COUNT=1
NODE_VOLUME_SIZE=50

function delete_hosted_zone() {
	aws route53 delete-hosted-zone --id $HOSTED_ZONE_ID
}

function delete_kops_bucket() {
	aws s3api delete-objects \
		--bucket $KOPS_STATE_BUCKET_NAME \
      	--delete "$(aws s3api list-object-versions \
      	--bucket ${KOPS_STATE_BUCKET_NAME} | \
      	jq '{Objects: [.Versions[] | {Key:.Key, VersionId : .VersionId}], Quiet: false}')"

  	aws s3 rm $KOPS_STATE_STORE --recursive
  	aws s3 rb $KOPS_STATE_STORE --force
}

function create_kops_bucket() {
	aws s3api create-bucket --region $REGION --bucket $KOPS_STATE_BUCKET_NAME --create-bucket-configuration LocationConstraint=$REGION
	aws s3api put-bucket-versioning --bucket $KOPS_STATE_BUCKET_NAME --versioning-configuration Status=Enabled
	export KOPS_STATE_STORE="s3://$KOPS_STATE_BUCKET_NAME"
}

# https://github.com/kubernetes/kops/blob/master/docs/cli/kops_create_cluster.md
# https://github.com/kubernetes/kops/blob/master/docs/secrets.md
# https://github.com/kubernetes/kops/blob/master/docs/cli/kops_update.md
function create_cluster() {
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

function destroy_cluster() {
	kops delete cluster --yes
}

function create() {
	create_kops_bucket
	create_cluster
}

function destroy() {
	destroy_cluster
}
