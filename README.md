# Guideline of usage

1. Buy a domain on AWS Route53 and replace in commands.sh the `sdtd-k8s.assalielmehdi.com` by your domain on line #7.

2. Under `secrets` folder, create a file named `awscredentials` containing:

   ```bash
   [default]
   aws_access_key_id=<aws_user_access_key_id>
   aws_secret_access_key=<aws_user_secret_access_key>
   ```

3. You can use `setup.sh` script to create and use toolbox container as follows:

   To create and use toolbox container:

   ```bash
   ./setup.sh create
   ```

   To use already created toolbox container:

   ```bash
   ./setup.sh
   ```

4. Commands for managing the cluster:

   Once connected to the toolbox container, you cane create, manage and delete ressources.

   - To create and setup a ressouce you can use the command: `create_<ressource>`

   - To delete and cleanup a ressouce you can use the command: `destroy_<ressource>`

   Type of ressources:

   - aws cluster: `create_cluser` or `destroy_cluster`

   - kafka cluster: `create_kafka` or `destroy_kafka`

   - flink cluster: `create_flink` or `destroy_flink`

   - cassandra cluster: `create_cassandra` or `destroy_cassandra`

   - twitter2kafka app: `create_twitter2kafka` or `destroy_twitter2kafka`

   - kafka2db app: `create_kafka2db` or `destroy_kafka2db`

   - grafana dashboard: `create_grafana` or `destroy_grafana`

   You can also use the `one push` commands to deploy or destroy the whole stack.

   - To create and setup entire stack: `create`

   - To delete and cleanup entire stack: `destroy`
