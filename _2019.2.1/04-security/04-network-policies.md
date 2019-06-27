---
title: "Network policies"
excerpt: "Learn about he network connections allowed for Event Streams each pod."
categories: security
slug: network-policies
toc: true
---

The following tables provide information about the permitted network connections for each Event Streams pod.

## Kafka pod

- Incoming connections permitted:

| **Type** | **Origin**                                                              | **Reason**                    |
|----------|-------------------------------------------------------------------------|-------------------------------|
| TCP      | REST API pods, REST Producer pods, and Geo-replicator pods to port 8084 | Kafka access                  |
| TCP      | REST API pods to port 7070                                              | Querying Kafka status         |
| TCP      | Proxy pods to port 8093                                                 | Proxied Kafka traffic         |
| TCP      | Other Kafka pods to port 9092                                           | Kafka cluster traffic         |
| TCP      | To port 8081 {{site.data.reuse.icp_master_host}}                                                          | Prometheus collecting metrics |

- Outgoing connections permitted:

| **Type** | **Destination**                     | **Reason**              |
|----------|-------------------------------------|-------------------------|
| TCP      | Port 8001 {{site.data.reuse.icp_master_host}}                   | Kubernetes API access   |
| TCP      | ZooKeeper pods on port 2181         | Cluster metadata access |
| TCP      | Other Kafka pods on port 9092       | Kafka cluster traffic   |
| TCP      | Index Manager pods on port 8080     | Kafka metrics           |
| TCP      | Access Controller pods on port 8443 | Security API access     |
| TCP      | Collector pods on port 7888         | Submitting metrics      |
| TCP      | Port 8443 {{site.data.reuse.icp_master_host}} | ICP security / IAM access  |

## ZooKeeper pod

- Incoming connections permitted:

| **Type** | **Origin**                                  | **Reason**                |
|----------|---------------------------------------------|---------------------------|
| TCP      | Kafka pods and REST API pods to port 2181   | ZooKeeper traffic         |
| TCP      | Other ZooKeeper pods to ports 2888 and 3888 | ZooKeeper cluster traffic |

- Outgoing connections permitted:

| **Type** | **Destination**                            | **Reason**                |
|----------|--------------------------------------------|---------------------------|
| TCP      | Port 8001 {{site.data.reuse.icp_master_host}}                        | Kubernetes API access     |
| TCP      | Other ZooKeeper pods on port 2888 and 3888 | ZooKeeper cluster traffic |

## Geo-replicator pod

- Incoming connections permitted:

| **Type** | **Origin**                             | **Reason**                          |
|----------|----------------------------------------|-------------------------------------|
| TCP      | REST API pods to port 8083             | Geo-replicator API traffic          |
| TCP      | Other geo-replicator pods to port 8083 | Geo-replicator cluster traffic      |
| TCP      | To port 8080 {{site.data.reuse.icp_master_host}}                          | Allow Prometheus to collect metrics |

- Outgoing connections permitted: Any

## Administration UI pod

- Incoming connections permitted: Any

- Outgoing connections permitted:

| **Type** | **Destination**                     | **Reason**                   |
|----------|-------------------------------------|------------------------------|
| TCP      | Port 8001 {{site.data.reuse.icp_master_host}}                          | Kubernetes API access        |
| TCP      | REST proxy pods on port 9080        | REST API access              |
| TCP      | Port 8443 {{site.data.reuse.icp_master_host}}                          | ICP security / IAM access    |
| TCP      | Access Controller pods on port 8443 | Access Controller API access |
| TCP      | Port 4300 {{site.data.reuse.icp_master_host}}                          | ICP identity API access      |


## Administration server pod

- Incoming connections permitted:

| **Type** | **Origin**                   | **Reason**             |
|----------|------------------------------|------------------------|
| TCP      | REST Proxy pods to port 9080 | Proxied REST API calls |

- Outgoing connections permitted:

| **Type** | **Destination**                   | **Reason**                                       |
|----------|-----------------------------------|--------------------------------------------------|
| TCP      | Port 8001 {{site.data.reuse.icp_master_host}}                        | Kubernetes API access                            |
| TCP      | Kafka pods on ports 8084 and 7070 | Kafka admin access                               |
| TCP      | Index Manager pods on port 9080   | Metric API access                                |
| TCP      | Geo-replicator pods on port 8083  | Geo-replicator API access                        |
| TCP      | ZooKeeper pods on port 2181       | ZooKeeper admin access                           |
| TCP      | Anywhere                          | Coordination with REST API in other ES instances |
| UDP      | Anywhere on port 53 {{site.data.reuse.icp_master_host}}              | Coordination with REST API in other ES instances |

## REST producer server pod

- Incoming connections permitted:

| **Type** | **Origin**                   | **Reason**                  |
|----------|------------------------------|-----------------------------|
| TCP      | REST Proxy pods to port 8080 | Proxied REST Producer calls |

- Outgoing connections permitted:

| **Type** | **Destination**         | **Reason**             |
|----------|-------------------------|------------------------|
| TCP      | Kafka pods on port 8084 | Sending Kafka messages |


## REST proxy pod

- Incoming connections permitted: Any

- Outgoing connections permitted:

| **Type** | **Destination**                 | **Reason**                   |
|----------|---------------------------------|------------------------------|
| TCP      | Port 8001 {{site.data.reuse.icp_master_host}}                      | Kubernetes API access        |
| TCP      | REST API pods on port 9080      | Proxying REST API calls      |
| TCP      | REST Producer pods on port 8080 | Proxying REST Producer calls |

## Collector pod

- Incoming connections permitted:

| **Type** | **Origin**              | **Reason**        |
|----------|-------------------------|-------------------|
| TCP      | Kafka pods to port 7888 | Receiving metrics |

- Outgoing connections permitted:

| **Type** | **Destination**         | **Reason**             |
|----------|-------------------------|------------------------|
| TCP      | Kafka pods on port 8080 | Prometheus connections |

## Network proxy pod

- Incoming connections permitted: Any

- Outgoing connections permitted:

| **Type** | **Destination**              | **Reason**            |
|----------|------------------------------|-----------------------|
| TCP      | Port 8001 {{site.data.reuse.icp_master_host}}                   | Kubernetes API access |
| TCP      | Kafka pods on port 8093      | Kafka client traffic  |
| TCP      | REST proxy pods on port 9080 | Kafka admin           |

## Access Controller pod

- Incoming connections permitted:

| **Type** | **Origin**                                          | **Reason**                           |
|----------|-----------------------------------------------------|--------------------------------------|
| TCP      | Kafka pods, REST API pods, and UI pods to port 8443 | Allow components to make auth checks |

- Outgoing connections permitted:

| **Type** | **Destination** | **Reason**                |
|----------|-----------------|---------------------------|
| TCP      | Port 8443 {{site.data.reuse.icp_master_host}}      | ICP security / IAM access |

## Index manager pod

- Incoming connections permitted:

| **Type** | **Origin**                             | **Reason**        |
|----------|----------------------------------------|-------------------|
| TCP      | Kafka pods to port 8080                | Receiving metrics |
| TCP      | Elastic and REST API pods to port 9080 | Metrics access    |

- Outgoing connections permitted:

| **Type** | **Destination**              | **Reason**                 |
|----------|------------------------------|----------------------------|
| TCP      | Elastic pods on port 9200    | Elasticsearch admin access |
| TCP      | REST proxy pods on port 9080 | REST API access            |


## Elasticsearch pod

- Incoming connections permitted:

| **Type** | **Origin**                            | **Reason**                    |
|----------|---------------------------------------|-------------------------------|
| TCP      | Index Manager pods to port 9200       | Elasticsearch admin access    |
| TCP      | Other ElasticSearch pods to port 9300 | ElasticSearch cluster traffic |

- Outgoing connections permitted:

| **Type** | **Destination**                       | **Reason**                    |
|----------|---------------------------------------|-------------------------------|
| TCP      | Index Manager pods on port 9080       | Elastic admin                 |
| TCP      | Other ElasticSearch pods on port 9300 | ElasticSearch cluster traffic |

## Install jobs pod

- Incoming connections permitted: None

- Outgoing connections permitted:

| **Type** | **Destination** | **Reason**            |
|----------|-----------------|-----------------------|
| TCP      | Port 8001 {{site.data.reuse.icp_master_host}}      | Kubernetes API access |

## Telemetry pod

- Incoming connections permitted: None

- Outgoing connections permitted: Any
