---
title: "Standard Kafka consumer hangs and does not output messages"
permalink: /troubleshooting/kafka-consumer-hangs/
excerpt: "Standard Kafka consumer hangs when no security settings provided"

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
ssl.truststore.location=TRUSTSTORE_FILE
ssl.truststore.password=TRUSTSTORE_PASSWORD
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="token" password="APIKEY";
```

Replace `TRUSTSTORE_FILE` with the location of a trust store file containing the server certificate (for example, `certs.jks`), `TRUSTSTORE_PASSWORD` with the password for the trust store and `APIKEY` with an API key able to access the {{site.data.reuse.long_name}} deployment.

When running the `kafka-console-producer.sh` command include the `--consumer.config CONSUMER_PROPERTIES` option, replacing the `CONSUMER_PROPERTIES` with the name of the property file. For example:

```
kafka-console-consumer.sh --bootstrap-server <brokerIP>:<bootstrapPort> --topic <topic> -consumer.config consumer.properties
```
