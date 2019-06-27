---
title: "Unable to connect to Kafka cluster"
excerpt: "Error is displayed when trying to connect to your Kafka cluster."
categories: troubleshooting
slug: kafka-connection-issue
toc: true
---

## Symptoms

The following error is displayed when trying to connect to your Kafka cluster using SSL, for example, when [running the {{site.data.reuse.kafka-connect-mq-source}}](../../connecting/mq/):

```
org.apache.kafka.common.errors.SslAuthenticationException: SSL handshake failed
```

## Causes

The Java process might replace the IP address of your cluster with the corresponding `hostname` value found in your `/etc/hosts` file.

For example, to be able to access Docker images from your {{site.data.reuse.icp}} cluster, you might have added an entry in your `/etc/hosts` file that corresponds to the IP address of your cluster, such as `192.0.2.24 mycluster.icp`.

In such cases, the following Java exception is displayed after the previously mentioned error message:

```
Caused by: java.security.cert.CertificateException: No subject alternative DNS name matching XXXXX found.
```

## Resolving the problem

If you see the exception mentioned previously, comment out the `hostname` value in your `/etc/hosts` file to solve this connection issue.
