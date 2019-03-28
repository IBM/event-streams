---
title: "Standard Kafka consumer hangs and does not output messages"
excerpt: "Standard Kafka consumer hangs when no security settings provided."
categories: troubleshooting
slug: kafka-consumer-hangs
toc: true
---

## Symptoms

The standard Kafka consumer (`kafka-console-consumer.sh`) is unable to receive messages and hangs without producing any output.

## Causes

This situation occurs if the consumer is invoked without supplying the required security credentials. In this case, the consumer
hangs and does not output any messages sent to the topic.

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

When running the `kafka-console-producer.sh` command include the `--consumer.config <properties_file>` option, replacing the `<properties_file>` with the name of the property file and the path to it. For example:

```
kafka-console-consumer.sh --bootstrap-server <brokerIP>:<bootstrapPort> --topic <topic> -consumer.config <properties_file>
```
