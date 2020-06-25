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

Create a properties file with the following content, adding by uncommenting either the SCRAM or Mutual TLS authentication settings depending on how the external listener has been [configured.](../../installing/configuring#configuring-access)

```
bootstrap.servers=<kafka_bootstrap_route_url>
# SCRAM Properties
#security.protocol=SASL_SSL
#sasl.mechanism=SCRAM-SHA-512
#sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="<username>" password="<password>";
# Mutual auth properties
#security.protocol=SSL
#ssl.keystore.location=<java_keystore_file_location>
#ssl.keystore.password=<java_keystore_password>
# TLS Properties
ssl.protocol=TLSv1.2
ssl.truststore.location=<java_truststore_file_location>
ssl.truststore.password=<java_truststore_password>
```

Replace the `<kafka_bootstrap_route_url>` with the address of the [Kafka bootstrap route.](../../installing/post-installation/#connecting-clients)

If you used SCRAM authentication for the external listener, replace `<username>` with the SCRAM user name and `<password>` with the SCRAM user's password.

If you used Mutual TLS authentication for the external listener, replace `<java_keystore_file_location>` with the location of a key store containing the client certificate and `<java_keystore_password>` with the password for the key store.

Finally, replace `<java_truststore_file_location>` with the location of a trust store file containing the server certificate (for example, `certs.jks`), and `<java_truststore_password>` with the password for the trust store.

When running the `kafka-console-consumer.sh` command include the `--consumer.config <properties_file>` option, replacing the `<properties_file>` with the name of the property file and the path to it. For example:

`kafka-console-consumer.sh --bootstrap-server <brokerIP>:<bootstrapPort> --topic <topic> -consumer.config <properties_file>`
