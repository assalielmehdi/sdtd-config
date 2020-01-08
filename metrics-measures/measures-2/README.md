# Infrastructure information

- EC2 machines
  - masters
    - \# of machines: 1
    - type of machine: t2.medium (2vCPU 3.3GHz | 4GiB Mem. | Low to Moderate net.)
    - size of storage: 30GiB
  - nodes
    - \# of machines: 2
    - type of machine: t2.medium (2vCPU 3.3GHz | 4GiB Mem. | Low to Moderate net.)
    - size of storage: 50GiB
- Kubernetes pods

  ```bash
    NAME                       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
    burrow                     1         1         1            1           39m
    flink-jobmanager           1         1         1            1           40m
    flink-taskmanager          2         2         2            2           40m
    grafana                    1         1         1            1           39m
    metrics                    1         1         1            1           39m
    twitter2kafka-deployment   3         3         3            3           40m
    weather2kafka-deployment   1         1         1            1           40m
  ```