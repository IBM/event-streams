---
title: "Setting client quotas"
excerpt: "Setting quotas"
categories: administering
slug: quotas
toc: true
---

Kafka quotas enforce limits on produce and fetch requests to control the broker resources used by clients.

Using quotas, administrators can throttle client access to the brokers by imposing network bandwidth or data limits, or both.

## About Kafka quotas

In a collection of clients, quotas protect from any single client producing or consuming significantly larger amounts of data than the other clients in the collection. This prevents issues with broker resources not being available to other clients, DoS attacks on the cluster, or badly behaved clients impacting other users of the cluster.

After a client that has a quota defined reaches the maximum amount of data it can send or receive, their throughput is stopped until the end of the current quota window. The client automatically resumes receiving or sending data when the quota window of 1 second ends.

By default, clients have unlimited quotas.

For more information about quotas, see the [Kafka documentation](https://kafka.apache.org/documentation/#design_quotas){:target="_blank"}.

## Setting quotas

To configure Kafka quotas, either update an existing `KafkaUser`, or manually create a new `KafkaUser` by using the {{site.data.reuse.openshift_short}} web console or CLI, ensuring that the configuration has a `quotas` section with the relevant quotas defined. For example:

```
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
| `requestPercentage` | integer       | This quota limits all clients based on [thread utilisation](https://kafka.apache.org/documentation/#design_quotascpu){:target="_blank"}. |


**Note:** Quotas can only be applied to individual `KafkaUser` instances. It is advised to apply a quota to an existing `KafkaUser`, as described in the following sections. You can [create](../../security/managing-access/#creating-a-kafkauser-in-the-ibm-event-streams-ui) a `Kafkauser` beforehand.

### Using the {{site.data.reuse.openshift_short}} web console

To update an existing `KafkaUser` by using the {{site.data.reuse.openshift_short}} web console:

1. {{site.data.reuse.task_openshift_navigate_installed_operators}}
2. {{site.data.reuse.task_openshift_select_operator}}
3. Select the **Kafka User** tab, then select the `KafkaUser` instance you want to update from the list of existing users.
4. Expand the **Actions** dropdown, and select the `Edit KafkaUser` option.
5. In the YAML editor, add a [quotas section](#setting-quotas) with the required quotas.


### Using the {{site.data.reuse.openshift_short}} CLI

To update an existing `KafkaUser` by using the {{site.data.reuse.openshift_short}} CLI:

1. {{site.data.reuse.openshift_cli_login}}
2. Run one of the following commands to add or update one or more quota types:

      Setting `producerByteRate`:

     ```
     QUOTA=<integer value>; \
     oc patch kafkauser --namespace <namespace> <kafka-user-name> \
     -p "{\"spec\":{\"quotas\": \
     {\"producerByteRate\":$QUOTA}}}" \
     --type=merge
     ```

     Setting `consumerByteRate`:

     ```
     QUOTA=<integer value>; \
     oc patch kafkauser --namespace <namespace> <kafka-user-name> \
     -p "{\"spec\":{\"quotas\": \
     {\"consumerByteRate\":$QUOTA}}}" \
     --type=merge
     ```

     Setting `requestPercentage`:
     ```
     QUOTA=<integer value>; \
     oc patch kafkauser --namespace <namespace> <kafka-user-name> \
     -p "{\"spec\":{\"quotas\": \
     {\"requestPercentage\":$QUOTA}}}" \
     --type=merge
     ```

     Setting all quotas:
     ```
     PRODUCER_QUOTA=<integer value>; \
     CONSUMER_QUOTA=<integer value>; \
     PERCENTAGE_QUOTA=<integer value>; \
     oc patch kafkauser --namespace <namespace> <kafka-user-name> \
     -p "{\"spec\":{\"quotas\": \
     {\"producerByteRate\":$PRODUCER_QUOTA, \
     \"consumerByteRate\":$CONSUMER_QUOTA, \
     \"requestPercentage\":$PERCENTAGE_QUOTA}}}" \
     --type=merge
     ```
