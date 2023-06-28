---
title: "Client receives AuthorizationException when communicating with brokers"
excerpt: "When connecting a client to Event Streams, operations return AuthorizationException errors when executing."
categories: troubleshooting
slug: authorization-failed-exceptions
layout: redirects
toc: true
---

## Symptoms

When executing operations with a Java client connected to {{site.data.reuse.short_name}}, the client fails with an error similar to the following message:

```
[err] [kafka-producer-network-thread | my-client-id] ERROR org.apache.kafka.clients.producer.internals.Sender - [Producer clientId=my-client-id] Aborting producer batches due to fatal error
[err] org.apache.kafka.common.errors.ClusterAuthorizationException: Cluster authorization failed.
```

Similar messages might also be displayed when using clients written in other languages such as NodeJS.

## Causes

The `KafkaUser` does not have the authorization to perform one of the operations:

- If there is an authorization error with a `topic` resource, then a `TOPIC_AUTHORIZATION_FAILED (error code: 29)` will be returned.
- If there is an authorization error with a `group` resource, then a `GROUP_AUTHORIZATION_FAILED (error code: 30)` will be returned.
- If there is an authorization error with a `cluster` resource, then a `CLUSTER_AUTHORIZATION_FAILED (error code: 31)` will be returned.
- If there is an authorization error with a `transactionalId` resource, then a `TRANSACTIONAL_ID_AUTHORIZATION_FAILED (error code: 32)` will be returned.

In Java, the errors are thrown in the format `<resource>AuthorizationException`. Other clients might return the error directly or translate it into an error with a similar name.

## Resolving the problem

Ensure the `KafkaUser` has the required permissions as described in [managing access](../../security/managing-access).
