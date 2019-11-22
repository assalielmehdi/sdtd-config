# Guildeline of usage

1. Buy a domain on AWS Route53 and replace in commands.sh the `sdtd-k8s.assalielmehdi.com` by your domain on line #7.

2. Under tools folder, create a file named `awscredentials` containing:

   ```bash
   [default]
   aws_access_key_id=<aws_user_access_key_id>
   aws_secret_access_key=<aws_user_secret_access_key>
   ```

3. You can use `setup_toolbox.sh` script to create and use toolbox container as follows:

   To create and use toolbox container:

   ```bash
   ./setup_toolbox.sh create
   ```

   To use already created toolbox container:

   ```bash
   ./setup_toolbox.sh
   ```

4. Commands for managing the cluster:

   Once connected to the toolbox container, you cane create, manage and delete ressources.

   - To create and setup a ressouce you can use the command: `create_<ressource>`

   - To delete and cleanup a ressouce you can use the command: `destroy_<ressource>`

   Type of ressources:

   - aws cluster: `create_cluser` or `destroy_cluster`

   - kafka cluster: `create_kafka` or `destroy_kafka`

   - twitter2kafka app: `create_twitter2kafka` or `destroy_twitter2kafka`

   You can also use the one push commands to setup everything with one command as follows:

   - To create and setup everything: `create`

   - To delete and cleanup everything: `destroy`

<!-- kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

Then follow the steps of this medium to see the kubernetes dashboard (still have to automate this part):
https://medium.com/@kanrangsan/creating-admin-user-to-access-kubernetes-dashboard-723d6c9764e4 -->
