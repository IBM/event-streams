---
title: "TimeoutException when using standard Kafka producer"
permalink: /troubleshooting/kafka-producer-error/
excerpt: "Standard Kafka producer fails when no security settings provided"
last_modified_at:
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
ssl.truststore.location=TRUSTSTORE_FILE
ssl.truststore.password=TRUSTSTORE_PASSWORD
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="token" password="APIKEY";
```

Replace `TRUSTSTORE_FILE` with the location of a trust store file containing the server certificate (for example, `certs.jks`), `TRUSTSTORE_PASSWORD` with the password for the trust store and `APIKEY` with an API key able to access the {{site.data.reuse.long_name}} deployment.

When running the `kafka-console-producer.sh` command include the `--producer.config PRODUCER_PROPERTIES` option, replacing the `PRODUCER_PROPERTIES` with the name of the property file. For example:

```
kafka-console-producer.sh --broker-list <brokerIP>:<bootstrapPort> --topic <topic> --producer.config producer.properties
```
