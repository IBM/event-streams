---
title: "TimeoutException when using standard Kafka producer"
excerpt: "Standard Kafka producer fails when no security settings provided."
categories: troubleshooting
slug: kafka-producer-error
toc: true
---

## Symptoms

The standard Kafka producer (`kafka-console-producer.sh`) is unable to send messages and fails with the following timeout error:

```
org.apache.kafka.common.errors.TimeoutException
```

## Causes

This situation occurs if the producer is invoked without supplying the required security credentials. In this case, the producer fails with
the following error:

```
Error when sending message to topic <topicname> with key: null, value: <n> bytes
```

## Resolving the problem

Create a properties file with the following content:

```
security.protocol=SASL_SSL
ssl.protocol=TLSv1.2
ssl.truststore.location=<certs.jks_file_location>
ssl.truststore.password=<truststore_password>
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="token" password="<api_key>";
```

Replace `<certs.jks_file_location>` with the location of a trust store file containing the server certificate (for example, `certs.jks`), `<truststore_password>` with the password for the trust store and `<api_key>` with an API key able to access the {{site.data.reuse.long_name}} deployment.

When running the `kafka-console-producer.sh` command, include the `--producer.config <properties_file>` option, replacing `<properties_file>` with the name of the property file and the path to it. For example:

```
kafka-console-producer.sh --broker-list <brokerIP>:<bootstrapPort> --topic <topic> --producer.config <properties_file>
```
