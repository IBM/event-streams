---
title: "Connecting over HTTP with Kafka Bridge"
excerpt: "Use Kafka Bridge to connect to your Event Streams Kafka cluster over HTTP."
categories: connecting
slug: kafka-bridge
toc: true
---

Connect client applications to your {{site.data.reuse.short_name}} Kafka cluster over HTTP by making HTTP requests.

## Overview

With [Kafka Bridge](https://strimzi.io/blog/2019/07/19/http-bridge-intro/){:target="_blank"}, you can connect client applications to your {{site.data.reuse.short_name}} Kafka cluster over HTTP, providing a standard web API connection to {{site.data.reuse.short_name}} rather than the custom Kafka protocol.

Apache Kafka uses a custom protocol on top of TCP/IP for communication between applications and the Kafka cluster. With Kafka Bridge, clients can communicate with your {{site.data.reuse.short_name}} Kafka cluster over the HTTP/1.1 protocol. You can manage consumers and send and receive records over HTTP.

## Prerequisites

Ensure you enable Kafka Bridge for {{site.data.reuse.short_name}} as described in [configuring](../../installing/configuring/#enabling-and-configuring-kafka-bridge).

## Security

Authentication and encryption between client applications and Kafka Bridge is not supported. Requests sent from clients to Kafka Bridge are not encrypted and must use HTTP (not HTTPS), and are sent without authentication.

You can configure TLS (`tls`) or SASL-based (`scram-sha-512`) user authentication between Kafka Bridge and your {{site.data.reuse.short_name}} Kafka cluster.

To configure authentication between Kafka Bridge and your Kafka cluster, use the `KafkaBridge` custom resource.

- The following example includes an {{site.data.reuse.short_name}} cluster that requires TLS authentication for user access, and the user `<username>` was [created](../../security/managing-access/#managing-access-to-kafka-resources) for Kafka Bridge earlier. In addition, it includes TLS authentication for the connection between the {{site.data.reuse.short_name}} instance (called `development`) and the Kafka Bridge.

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: KafkaBridge
metadata:
  name: my-bridge
  namespace: <namespace>
  labels:
    eventstreams.ibm.com/cluster: <cluster-name>
spec:
  replicas: 1
  bootstrapServers: '<cluster-name>-kafka-bootstrap:9093'
  http:
     port: 8080
  authentication:
     type: tls
     certificateAndKey:
        certificate: user.crt
        key: user.key
        secretName: <username>
  tls:
     trustedCertificates:
        - certificate: ca.crt
           secretName: <cluster-name>-cluster-ca-cert
  template:
    bridgeContainer:
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop:
            - ALL
        privileged: false
        readOnlyRootFilesystem: true
        runAsNonRoot: true
```

- The following example includes an {{site.data.reuse.short_name}} cluster that requires SCRAM-SHA-512 authentication for user access, and the user `<username>` was [created](../../security/managing-access/#managing-access-to-kafka-resources) for Kafka Bridge earlier. In addition, it includes TLS authentication for the connection between the {{site.data.reuse.short_name}} instance (called `development`) and the Kafka Bridge.

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: KafkaBridge
metadata:
  name: my-bridge
  namespace: <namespace>
  labels:
    eventstreams.ibm.com/cluster: <cluster-name>
spec:
  replicas: 1
  bootstrapServers: '<cluster-name>-kafka-bootstrap:9093'
  http:
    port: 8080
  authentication:
    type: scram-sha-512
    username: <username>
    passwordSecret:
      secretName: <username>
      password: password
  tls:
    trustedCertificates:
      - certificate: ca.crt
        secretName: <cluster-name>-cluster-ca-cert
  template:
    bridgeContainer:
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop:
            - ALL
        privileged: false
        readOnlyRootFilesystem: true
        runAsNonRoot: true
```


## Client access

### Internal access

Client applications running within the same OpenShift cluster as Kafka Bridge can access Kafka Bridge on the port configured in the `KafkaBridge` custom resource (the default is `8080`).

### External access

Client applications running outside of the OpenShift cluster can access the Kafka Bridge through an OpenShift route, as described in [enabling Kafka Bridge](../../installing/configuring/#enabling-and-configuring-kafka-bridge).


## Using Kafka Bridge


After enabling and configuring the Kafka Bridge, use the bridge to connect applications to your Kafka cluster over HTTP.



### Available HTTP requests

With Kafka Bridge, you can make the following HTTP requests to your Kafka cluster:
- Send messages to a topic.
- Retrieve messages from topics.
- Retrieve a list of partitions for a topic.
- Create and delete consumers.
- Subscribe consumers to topics, so that they start receiving messages from those topics.
- Retrieve a list of topics that a consumer is subscribed to.
- Unsubscribe consumers from topics.
- Assign partitions to consumers.
- Commit a list of consumer offsets.
- Seek on a partition, so that a consumer starts receiving messages from the first or last offset position, or a given offset position.

The related request operations are the following:
- `GET /`
- `POST /consumers/{groupid}`
- `DELETE /consumers/{groupid}/instances/{name}`
- `POST /consumers/{groupid}/instances/{name}/assignments`
- `POST /consumers/{groupid}/instances/{name}/offsets`
- `POST /consumers/{groupid}/instances/{name}/positions`
- `POST /consumers/{groupid}/instances/{name}/positions/beginning`
- `POST /consumers/{groupid}/instances/{name}/positions/end`
- `GET /consumers/{groupid}/instances/{name}/records`
- `POST /consumers/{groupid}/instances/{name}/subscription`
- `GET /consumers/{groupid}/instances/{name}/subscription`
- `DELETE /consumers/{groupid}/instances/{name}/subscription`
- `GET /healthy`
- `GET /openapi`
- `GET /ready`
- `GET /topics`
- `POST /topics/{topicname}`
- `GET /topics/{topicname}`
- `GET /topics/{topicname}/partitions`
- `POST /topics/{topicname}/partitions/{partitionid}`
- `GET /topics/{topicname}/partitions/{partitionid}`
- `GET /topics/{topicname}/partitions/{partitionid}/offsets`

For more detailed information about the request paths, see the [Strimzi documentation](https://strimzi.io/docs/bridge/latest/#_paths){:target="_blank"}.

### Content types

The following are supported for the value of the `Content-Type` header.

- For consumer operations, `POST` requests must provide the following `Content-Type` header:
   ```
   Content-Type: application/vnd.kafka.v2+json
   ```
- For producer operations, `POST` requests must provide `Content-Type` headers specifying the embedded data format of the messages produced (JSON or binary:

   Embedded data format  | `Content-Type` header
   -------------------------|-----------------------------------------------------
   JSON                     |  `Content-Type: application/vnd.kafka.json.v2+json`
   Binary                   |  `Content-Type: application/vnd.kafka.binary.v2+json`


### Producing

After setting up Kafka Bridge, you can produce to specified topics over HTTP. To produce to a topic, [create a topic](../../getting-started/creating-topics/), and run the following curl command.

**Note:** If automatic topic creation is enabled (set by `auto.create.topics.enable` in the broker configuration, default is `true`), then you can specify a new topic in the following command and it will be created before messages are written to the topic.

```
curl -X POST \
   http://<route-name>.apps.<cluster-name>.<namespace>.com/topics/<topic-name> \
   -H 'content-type: application/vnd.kafka.json.v2+json' \
   -d '{
     "records": [
        {
            "key": "key-1",
            "value": "value-1"
        },
        {
            "key": "key-2",
            "value": "value-2"
        }
    ]
}'
```

For example, to produce two messages about temperature readings to a topic called `my-topic`, you can use the following command:

```
curl -X POST \
   http://my-bridge-route-es-kafka-bridge.apps.example.com/topics/my-topic \
   -H 'content-type: application/vnd.kafka.json.v2+json' \
   -d '{
     "records": [
        {
            "key": "temperature-1",
            "value": "20"
        },
        {
            "key": "temperature-2",
            "value": "25"
        }
    ]
}'

```

If the request to produce to the topic is successful, the Kafka Bridge returns an HTTP status code `200 OK` and a JSON payload describing for each message the partition that the message was sent to and the offset the messages are written to.

```
#...
{
  "offsets":[
    {
      "partition":0,
      "offset":0
    },
    {
      "partition":2,
      "offset":0
    }
  ]
}
```

### Consuming

To consume messages over HTTP with Kafka Bridge:
1. [Create a Kafka Bridge consumer](#creating-a-kafka-bridge-consumer)
2. [Subscribe to a topic](#subscribing-to-topics)
3. [Retrieve messages from the topic](#retrieving-messages-from-topics)

#### Creating a Kafka Bridge consumer

To interact with your Kafka cluster, the Kafka Bridge requires a consumer. To create the Kafka Bridge [consumer endpoint](https://strimzi.io/docs/bridge/latest/#_createconsumer){:target="_blank"}, create a consumer within a consumer group. For example, the following command creates a Kafka Bridge consumer called `my-consumer` in a new consumer group called `my-group`:

```
curl -X POST http://my-bridge-route-es-kafka-bridge.apps.example.com/consumers/my-group \
-H 'content-type: application/vnd.kafka.json.v2+json' \
-d '{
  "name": "my-consumer",
  "format": "json",
  "auto.offset.reset": "earliest",
  "enable.auto.commit": false
}'
```

If the request is successful, the Kafka Bridge returns an HTTP status code `200 OK` and a JSON payload containing the consumer ID (`instance_id`) and the base URL (`base_uri`). The base URL is used by the HTTP client to interact with the consumer and receive messages from topics. The following is an example response:

```
{
   "instance_id":"my-consumer",
   "base_uri":"http://my-bridge-bridge-service:80/consumers/my-group/instances/my-consumer"
}
```

#### Subscribing to topics

After creating a Kafka Bridge consumer, you can subscribe the Kafka Bridge consumer to topics by creating a [subscription endpoint](https://strimzi.io/docs/bridge/latest/#_subscribe){:target="_blank"}. For example, the following command subscribes the consumer to the topic called `my-topic`:

```
curl -X POST http://my-bridge-route-es-kafka-bridge.apps.example.com/consumers/my-group/instances/my-consumer/subscription \
-H 'content-type: application/vnd.kafka.json.v2+json' \
-d '{
    "topics": [
        "my-topic"
    ]
}'
```
If the request is successful, the Kafka Bridge returns an HTTP status code `200 OK` with an empty body.

After subscribing, the consumer receives all messages that are produced to the topic.

#### Retrieving messages from topics

After subscribing a Kafka Bridge consumer to a topic, your client applications can retrieve the messages on the topic from the Kafka Bridge consumer. To retrieve the latest messages, request data from the [records endpoint](https://strimzi.io/docs/bridge/latest/#_poll){:target="_blank"}. The fopllowing is an example command to retrieve messages from `my-topic`:

```
curl -X GET http://my-bridge-route-es-kafka-bridge.apps.example.com/consumers/my-group/instances/my-consumer/records \
-H 'accept: application/vnd.kafka.json.v2+json'
```

If the request is successful, the Kafka Bridge returns an HTTP status code `200 OK` and the JSON body containing the messages from the topic. Messages are retrieved from the latest offset by default.

**Note:** If you receive an empty response, [produce more records](#producing) to the consumer, and then try retrieving messages again.

In production, HTTP clients can call this endpoint repeatedly (in a loop), for example:

```
while true; do sleep 1;  curl -X GET http://my-bridge-route-es-kafka-bridge.apps.example.com/consumers/my-group/instances/my-consumer/records \
-H 'accept: application/vnd.kafka.json.v2+json'; echo ; done
```

#### Deleting a Kafka Bridge consumer

If you no longer need a Kafka Bridge consumer, delete it to free up resources on the bridge.

Use the [delete consumer endpoint](https://strimzi.io/docs/bridge/latest/#_deleteconsumer){:target="_blank"} to delete a consumer instance. For example, to delete the consumer [created earlier](#creating-a-kafka-bridge-consumer), run the following command:

```
curl -X DELETE http://my-bridge-bridge-service:80/consumers/my-group/instances/my-consumer/
```


For more information about using Kafka Bridge to produce to and consume from your Kafka cluster, including committing offsets, see the following [blog post](https://strimzi.io/blog/2019/11/05/exposing-http-bridge/){:target="_blank"}.
