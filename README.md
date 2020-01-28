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

   Once connected to the toolbox container, you can create, manage and delete ressources.

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

5. Result visualization

    After creating the cluster and deploying all component, the results can be seen in `Grafana`, and a dashboard is already configured for that.

    `Grafana` can be accessed usin the link [grafana.assalielmehdi.com](grafana.assalielmehdi.com), using admin credentials given in the logs.

    A dashboard called `Metrics` contains the graphs illustrating the results of our app.

    > Note that `Grafana` may take a while to be ready, you just have to wait if the link given is not reachable.

6. Charge injection

    All data processed in our app is from APIs (twitter and weather), and these APIs have rate limit.

    To measure the performance of the infrastructure, you can inject already stored data to the pipeline in order to stress the infrastructure.

    Each injection app (Kubernetes pod) is serving 300.000 tweets from a database to the entry point of our pipeline, and you an create as many injection apps as you want.

    In order to create injection apps:

    ```bash
      inject <number_of_pods>
    ```

    The number of tweets injected is: `number_of_pods * 300.000`.

    After injection you can see the number of tweets processed per second increasing significantly.