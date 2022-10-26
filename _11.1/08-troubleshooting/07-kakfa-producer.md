---
title: "TimeoutException when using standard Kafka producer"
excerpt: "Standard Kafka producer fails when no security settings provided."
categories: troubleshooting
slug: kafka-producer-error
toc: true
---

## Symptoms

The standard Kafka producer (`kafka-console-producer.sh`) is unable to send messages and fails with the following timeout error:

`org.apache.kafka.common.errors.TimeoutException`

## Causes

This situation occurs if the producer is invoked without supplying the required security credentials. In this case, the producer fails with
the following error:

```
Error when sending message to topic <topicname> with key: null, value: <n> bytes
```

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

When running the `kafka-console-producer.sh` command, include the `--producer.config <properties_file>` option, replacing `<properties_file>` with the name of the property file and the path to it. For example:

`kafka-console-producer.sh --broker-list <brokerIP>:<bootstrapPort> --topic <topic> --producer.config <properties_file>`
