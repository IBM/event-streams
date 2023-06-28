---
title: "Setting client quotas"
excerpt: "Setting quotas"
categories: administering
slug: quotas
layout: redirects
toc: true
---

Kafka quotas enforce limits on produce and fetch requests to control the broker resources used by clients.

Using quotas, administrators can throttle client access to the brokers by imposing network bandwidth or data limits, or both.

## About Kafka quotas

In a collection of clients, quotas protect from any single client producing or consuming significantly larger amounts of data than the other clients in the collection. This prevents issues with broker resources not being available to other clients, DoS attacks on the cluster, or badly behaved clients impacting other users of the cluster.

After a client that has a quota defined reaches the maximum amount of data it can send or receive, their throughput is stopped until the end of the current quota window. The client automatically resumes receiving or sending data when the quota window of 1 second ends.

By default, clients have unlimited quotas.

For more information about quotas, see the [Kafka documentation](https://kafka.apache.org/documentation/#design_quotas){:target="_blank"}.

## Setting user quotas

To configure Kafka user quotas, either update an existing `KafkaUser` resource, or manually create a new `KafkaUser` by using the {{site.data.reuse.openshift_short}} web console or the Kubernetes command-line tool (`kubectl`), ensuring that the configuration has a `quotas` section with the relevant quotas defined. 

For example:

```yaml
spec:
   #...
   quotas:
      producerByteRate: 1048576
      consumerByteRate: 2097152
      requestPercentage: 55
```

Decide what you want to limit by defining one or more of the following quota types:

| Property         | Type             | Description      |
|:-----------------|:-----------------|:-----------------|
| `producerByteRate` | integer        | This quota limits the number of bytes that a producer application is allowed to send per second. |
| `consumerByteRate` | integer        | This quota limits the number of bytes that a consumer application is allowed to receive per second. |
| `requestPercentage` | integer       | This quota limits all clients based on [thread utilization](https://kafka.apache.org/documentation/#design_quotascpu){:target="_blank"}. |


**Note:** Quotas can only be applied to individual `KafkaUser` resources. It is advised to apply a quota to an existing `KafkaUser` custom resource, as described in the following sections. You can [create](../../security/managing-access/#creating-a-kafkauser-in-the-event-streams-ui) a `Kafkauser` custom resource beforehand.

### Using the {{site.data.reuse.openshift_short}} web console

To update an existing `KafkaUser` custom resource by using the {{site.data.reuse.openshift_short}} web console:

1. {{site.data.reuse.task_openshift_navigate_installed_operators}}
2. {{site.data.reuse.task_openshift_select_operator}}
3. Select the **Kafka User** tab, then select the `KafkaUser` resource you want to update from the list of existing users.
4. Expand the **Actions** dropdown, and select the `Edit KafkaUser` option.
5. In the YAML editor, add a [quotas section](#setting-user-quotas) with the required quotas.


### Using the CLI

To update an existing `KafkaUser` by using the CLI:

1. {{site.data.reuse.cncf_cli_login}}
2. Run one of the following commands to add or update one or more quota types:

      Setting `producerByteRate`:

     ```shell
     QUOTA=<integer value>; \
     kubectl patch kafkauser --namespace <namespace> <kafka-user-name> \
     -p "{\"spec\":{\"quotas\": \
     {\"producerByteRate\":$QUOTA}}}" \
     --type=merge
     ```

     Setting `consumerByteRate`:

     ```shell
     QUOTA=<integer value>; \
     kubectl patch kafkauser --namespace <namespace> <kafka-user-name> \
     -p "{\"spec\":{\"quotas\": \
     {\"consumerByteRate\":$QUOTA}}}" \
     --type=merge
     ```

     Setting `requestPercentage`:
     ```shell
     QUOTA=<integer value>; \
     kubectl patch kafkauser --namespace <namespace> <kafka-user-name> \
     -p "{\"spec\":{\"quotas\": \
     {\"requestPercentage\":$QUOTA}}}" \
     --type=merge
     ```

     Setting all quotas:
     ```shell
     PRODUCER_QUOTA=<integer value>; \
     CONSUMER_QUOTA=<integer value>; \
     PERCENTAGE_QUOTA=<integer value>; \
     kubectl patch kafkauser --namespace <namespace> <kafka-user-name> \
     -p "{\"spec\":{\"quotas\": \
     {\"producerByteRate\":$PRODUCER_QUOTA, \
     \"consumerByteRate\":$CONSUMER_QUOTA, \
     \"requestPercentage\":$PERCENTAGE_QUOTA}}}" \
     --type=merge
     ```

## Setting broker quotas

To configure throughput and storage limits on Kafka brokers in your {{site.data.reuse.short_name}} cluster, update an existing `EventStreams` custom resource by using the {{site.data.reuse.openshift_short}} web console or CLI, ensuring that the configuration has a `config` section with the relevant quotas defined. For example:

```yaml
spec:
  strimziOverrides:
    kafka:
      ...
      config:
        client.quota.callback.class: io.strimzi.kafka.quotas.StaticQuotaCallback
        client.quota.callback.static.produce: 1048576
        client.quota.callback.static.fetch: 2097152
        client.quota.callback.static.storage.soft: 429496729600
        client.quota.callback.static.storage.hard: 536870912000
        client.quota.callback.static.storage.check-interval: 8
```

**Warning:** When setting the broker quotas, any previously configured user quotas will be ignored and overridden without warning. Additionally, the per-client group metrics that are provided by Kafka by default will not be available. For more information, see [Strimzi GitHub issue 32](https://github.com/strimzi/kafka-quotas-plugin/issues/32){:target="_blank"}.


Decide what you want to limit by defining one or more of the following quota types:

| Property         | Type             | Description      |
|:-----------------|:-----------------|:-----------------|
| `produce` | integer        | This quota limits the number of bytes that a producer application is allowed to send per second. |
| `fetch` | integer        | This quota limits the number of bytes that a consumer application is allowed to receive per second. |
| `storage.soft` | integer       | This quota limits the number of bytes to consider as the lower soft limit for storage. |
| `storage.hard` | integer       | This quota limits the number of bytes to consider as the higher hard limit for storage. |
| `storage.check-interval` | integer  | This quota limits the number of seconds that a storage application is allowed to wait till the next check. To disable this limit, set the value to 0. |

**Note:** Quotas can only be applied to individual `EventStreams` custom resources and apply across all Kafka brokers running within the cluster.

### Using the {{site.data.reuse.openshift_short}} web console

To update an existing `EventStreams` custom resource by using the {{site.data.reuse.openshift_short}} web console:

1. {{site.data.reuse.task_openshift_navigate_installed_operators}}
2. {{site.data.reuse.task_openshift_select_operator}}
3. Select the **Event Streams** tab, then select the `EventStreams` custom resource you want to update from the list of existing instances.
4. Expand the **Actions** dropdown, and select the `Edit EventStreams` option.
5. In the YAML editor, add a [quotas section](#setting-broker-quotas) with the required quotas.

### Using the CLI

To update an existing `EventStreams` custom resource by using the {{site.data.reuse.openshift_short}} CLI:

1. {{site.data.reuse.openshift_cli_login}}
2. Run one of the following commands to add or update one or more quota types:

      Setting `produce`:

     ```shell
      PRODUCE_QUOTA=<integer value>; \
      kubectl patch eventstreams --namespace <namespace> <name-of-the-es-instance> \
      -p "{\"spec\":{\"strimziOverrides\":{\"kafka\":{\"config\": \
      {\"client.quota.callback.class\": 
      \"io.strimzi.kafka.quotas.StaticQuotaCallback\" , \
      \"client.quota.callback.static.produce\":$PRODUCE_QUOTA}}}}}" \
      --type merge
     ```

     Setting `fetch`:

     ```shell
      FETCH_QUOTA=<integer value>; \
      kubectl patch eventstreams --namespace <namespace> <name-of-the-es-instance> \
      -p "{\"spec\":{\"strimziOverrides\":{\"kafka\":{\"config\": \
      {\"client.quota.callback.class\": 
      \"io.strimzi.kafka.quotas.StaticQuotaCallback\" , \
      \"client.quota.callback.static.produce\":$FETCH_QUOTA}}}}}" \
      --type merge
     ```    
    

     Setting `storage.soft`:

     ```shell
      SOFTSTORAGE_QUOTA=<integer value>; \
      kubectl patch eventstreams --namespace <namespace> <name-of-the-es-instance> \
      -p "{\"spec\":{\"strimziOverrides\":{\"kafka\":{\"config\": \
      {\"client.quota.callback.class\": 
      \"io.strimzi.kafka.quotas.StaticQuotaCallback\" , \
      \"client.quota.callback.static.produce\":$SOFTSTORAGE_QUOTA}}}}}" \
      --type merge
     ```

     Setting `storage.hard`:

     ```shell
      HARDSTORAGE_QUOTA=<integer value>; \
      kubectl patch eventstreams --namespace <namespace> <name-of-the-es-instance> \
      -p "{\"spec\":{\"strimziOverrides\":{\"kafka\":{\"config\": \
      {\"client.quota.callback.class\": 
      \"io.strimzi.kafka.quotas.StaticQuotaCallback\" , \
      \"client.quota.callback.static.produce\":$HARDSTORAGE_QUOTA}}}}}" \
      --type merge
     ```

     Setting `storage.check-interval`:

      ```shell
      CHECKINTERVAL_QUOTA=<integer value>; \
      kubectl patch eventstreams --namespace <namespace> <name-of-the-es-instance> \
      -p "{\"spec\":{\"strimziOverrides\":{\"kafka\":{\"config\": \
      {\"client.quota.callback.class\": 
      \"io.strimzi.kafka.quotas.StaticQuotaCallback\" , \
      \"client.quota.callback.static.produce\":$CHECKINTERVAL_QUOTA}}}}}" \
      --type merge
     ```

     Setting all quotas:

     ```shell
     PRODUCE_QUOTA=<integer value>; \
     FETCH_QUOTA=<integer value>; \
     SOFTSTORAGE_QUOTA=<integer value>; \
     HARDSTORAGE_QUOTA=<integer value>; \
     CHECKINTERVAL_QUOTA=<integer value>; \
     kubectl patch eventstreams --namespace <namespace> <name-of-the-es-instance> \
     -p "{\"spec\":{\"strimziOverrides\":{\"kafka\":{\"config\": \
     {\"client.quota.callback.class\": 
     \"io.strimzi.kafka.quotas.StaticQuotaCallback\" , \
     \"client.quota.callback.static.produce\":$PRODUCE_QUOTA , \
     \"client.quota.callback.static.fetch\": $FETCH_QUOTA , \
     \"client.quota.callback.static.storage.soft\": $SOFTSTORAGE_QUOTA , \
     \"client.quota.callback.static.storage.hard\": $HARDSTORAGE_QUOTA , \
     \"client.quota.callback.static.storage.check-interval\": $CHECKINTERVAL_QUOTA}}}}}" \
     --type merge
     ```