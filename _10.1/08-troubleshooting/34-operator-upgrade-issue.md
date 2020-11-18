---
title: "Operator upgrade causes Kafka pod errors"
excerpt: "Upgrading the Event Streams operator causes errors."
categories: troubleshooting
slug: operator-upgrade-issue
toc: true
---

## Symptoms

If you have an existing {{site.data.reuse.short_name}} 10.0.0 installation created by the {{site.data.reuse.short_name}} operator version 2.0.1, and you [upgrade](../../installing/upgrading/) your operator to 2.1.0, Kafka pods show the error status `CrashLoopBackOff`, for example:

```
NAME                                             READY   STATUS             RESTARTS   AGE
<instance>-es-entity-operator-67fc545f67-wngkw   2/2     Running            0          7d7h
<instance>-es-ibm-es-admapi-7d6dd5bf96-5f29k     1/1     Running            0          28h
<instance>-es-ibm-es-metrics-df9dff954-87zwr     1/1     Running            0          28h
<instance>-es-ibm-es-recapi-5467dc886b-8k57j     1/1     Running            0          28h
<instance>-es-ibm-es-schema-0                    3/3     Running            0          28h
<instance>-es-ibm-es-ui-7bfdf7c8d4-7hvnf         2/2     Running            0          28h
<instance>-es-kafka-0                            1/2     CrashLoopBackOff   5          5m31s
<instance>-es-kafka-1                            0/2     CrashLoopBackOff   1          2m30s
<instance>-es-kafka-2                            2/2     Running            6          7d8h
<instance>-es-zookeeper-0                        1/1     Running            0          33m
<instance>-es-zookeeper-1                        1/1     Running            0          31m
<instance>-es-zookeeper-2                        1/1     Running            0          28h
```

The logs for the crashed Kafka pods show an error message similar to the following:

```
2020-10-20 20:39:20,683 ERROR Exiting Kafka due to fatal exception (kafka.Kafka$) [main]
org.apache.kafka.common.config.ConfigException: Missing required configuration
"zookeeper.connect" which has no default value.
```

## Causes

Due to a sequencing issue, some entries are missing from the Kafka ConfigMap (`<name>-es-kafka-config`) that are required at startup time.

## Resolving the problem

Contact [IBM Support]({{ 'support' | relative_url }}) to request help with fixing this issue.
