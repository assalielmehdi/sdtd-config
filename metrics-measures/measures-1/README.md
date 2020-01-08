# Infrastructure information

- EC2 machines
  - masters
    - \# of machines: 1
    - type of machine: t2.xlarge (4vCPU 3.0GHz | 16GiB Mem. | Moderate net.)
    - size of storage: 30GiB
  - nodes
    - \# of machines: 3
    - type of machine: t2.large (2vCPU 3.0GHz | 8GiB Mem. | Low to Moderate net.)
    - size of storage: 50GiB
- Kubernetes pods

  ```bash
    NAME                       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
    burrow                     1         1         1            1           1h
    flink-jobmanager           1         1         1            1           1h
    flink-taskmanager          2         2         2            2           1h
    grafana                    1         1         1            1           1h
    metrics                    1         1         1            1           1h
    twitter2kafka-deployment   3         3         3            3           1h
    weather2kafka-deployment   1         1         1            1           1h
  ```
