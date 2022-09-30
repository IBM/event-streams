---
title: "Running Kafka Streams applications"
description: "Learn how to run Kafka Streams applications in IBM Event Streams."
permalink: /tutorials/kafka-streams-app/
toc: true
section: "Tutorials for IBM Event Streams"
cardType: "large"
---

You can run [Kafka Streams](https://kafka.apache.org/documentation/streams/){:target="_blank"} applications in {{site.data.reuse.long_name}}.

Follow the steps in this tutorial to understand how to set up your existing Kafka Streams application to run in {{site.data.reuse.short_name}}, including how to set the correct connection and permission properties to allow your application to work with Event Streams.

The examples mentioned in this tutorial are based on the [`WordCountDemo.java` sample](https://github.com/apache/kafka/blob/3.3/streams/examples/src/main/java/org/apache/kafka/streams/examples/wordcount/WordCountDemo.java){:target="_blank"} which reads messages from an input topic called `streams-plaintext-input` and writes the words, together with an occurrence count for each word, to an output topic called `streams-wordcount-output`.

## Prerequisites

- Ensure you have an {{site.data.reuse.short_name}} installation available. This tutorial is based on {{site.data.reuse.short_name}} version 11.0.3.
- Ensure you have a [Kafka Streams](https://kafka.apache.org/documentation/streams/){:target="_blank"} application ready to use. You can also use one of the Kafka Streams [sample applications](https://github.com/apache/kafka/tree/3.3/streams/examples/src/main/java/org/apache/kafka/streams/examples){:target="_blank"} such as the  `WordCountDemo.java` sample used here.

## Creating input and output topics

Create the input and output topics in {{site.data.reuse.short_name}}.

For example, you can create the topics and name them as they are named in the [`WordCountDemo.java` sample](https://github.com/apache/kafka/blob/3.3/streams/examples/src/main/java/org/apache/kafka/streams/examples/wordcount/WordCountDemo.java){:target="_blank"} application. For demonstration purposes, the topics only have 1 replica and 1 partition.

To create the topics:

1. Log in to your {{site.data.reuse.long_name}} UI.
2. Click the **Topics** tab and click **Create topic**.
3. Enter the name `streams-plaintext-input` and click **Next**.
4. Set 1 partition for the topic, leave the default retention period, and select 1 replica.
5. Click **Create topic**.
6. Repeat the same steps to create a topic called `streams-wordcount-output`.

## Sending data to input topic

To send data to the topic, first set up permissions to produce to the input topic, and then run the Kafka Streams producer to add messages to the topic.

To set up permissions:

1. Log in to your {{site.data.reuse.long_name}} UI.
1. Click the **Topics** tab.
1. Select your input topic you created earlier from the list, for example `streams-plaintext-input`.
1. Click **Connect to this topic** on the right.
1. On the **Connect a client** tab, copy the address from the **Bootstrap server** section. This gives the bootstrap address for Kafka clients.
1. From the **Certificates** section, download the server certificate from the **PKCS12 certificate** section, and make a note of the password.
1. To generate SCRAM credentials, click the **Generate SCRAM credentials** button, and follow the instructions. Ensure you select **Produce messages**. In the **A specific topic** field, enter the name of the input topic `streams-plaintext-input`.
1. Click the **Sample code** tab, and copy the snippet from the **Sample configuration properties** section into a new file called `streams-demo-input.properties`. This creates a new properties file for your Kafka Streams application.
1. Replace `<certs.PKCS12_file_location>` with the path to your truststore file, `<truststore_password>` with the password for the PKCS12 file, and `<scram_username>` and `<scram_password>` with the SCRAM username and password generated for the output topic. For example:

   ```conf
   security.protocol=SASL_SSL
   ssl.protocol=TLSv1.2
   ssl.truststore.location=/Users/john.smith/Downloads/es-cert.p12
   ssl.truststore.password=password
   sasl.mechanism=SCRAM-SHA-512
   sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required required username="<scram_username>" password="<scram_password>";
   ```

To send messages to the input topic, use the bootstrap address, the input topic name, and the new properties file you created. For example, run [`kafka-console-producer.sh`](https://github.com/apache/kafka/blob/3.3/bin/kafka-console-producer.sh){:target="_blank"} with the following options:

- `--broker-list <broker_url>`: where `<broker_url>` is your cluster's broker URL copied earlier from the **Bootstrap server** section.
- `--topic <topic_name>`: where `<topic_name>` is the name of your input topic, in this example, `streams-plaintext-input`.
- `--producer.config <properties_file>`: where `<properties_file>` is the new properties file including full path to it, in this example, `streams-demo-input.properties`.

Enter the following text in the producer shell.

```bash
This is a test message
This will be used to demo the Streams sample app
It is a Kafka Streams test message
The words in these messages will be counted by the Streams app
```

For example:

```bash
./bin/kafka-console-producer.sh \
            --broker-list 192.0.2.24:31248 \
            --topic streams-plaintext-input \
            --producer.config streams-demo-input.properties

>This is a test message
>This will be used to demo the Streams sample app
>It is a Kafka Streams test message
>The words in these messages will be counted by the Streams app
```

Another method to produce messages to the topic is by using the [{{site.data.reuse.short_name}} producer API](../../connecting/rest-producer-api/#producing-messages-using-rest).

## Running the application

Set up your Kafka Streams application to connect to your {{site.data.reuse.short_name}} instance, have permission to create topics, join consumer groups, and produce and consume messages. You can then use your application to create intermediate Kafka Streams topics, consume from the input topic, and produce to the output topic.

To set up permissions and secure the connection:

1. Log in to your {{site.data.reuse.long_name}} UI.
1. Click **Connect to this cluster** on the right.
1. From the **Certificates** section, download the server certificate from the **PKCS12 certificate** section, and make a note of the password.
1. To generate SCRAM credentials, click the **Generate SCRAM credentials** button, and follow the instructions. Ensure you select **Produce messages, consume messages and create topics and schemas**.

   The permissions are required to do the following:

   - Create topics: Kafka Streams creates intermediate topics for the operations performed in the stream.
   - Join a consumer group: to be able to read messages from the input topic, it joins the group [`streams-wordcount`](https://github.com/apache/kafka/blob/3.3/streams/examples/src/main/java/org/apache/kafka/streams/examples/wordcount/WordCountDemo.java#L62){:target="_blank"}.
   - Produce and consume messages.

1. Click the **Sample code** tab, and copy the snippet from the **Sample connection code** section into your Kafka Streams application to set up a secure connection from your application to your {{site.data.reuse.short_name}} instance.
1. Using the snippet, import the following libraries to your application:

   ```java
   import org.apache.kafka.clients.CommonClientConfigs;
   import org.apache.kafka.common.config.SaslConfigs;
   import org.apache.kafka.common.config.SslConfigs;
   ```

1. Using the snippet, reconstruct the Properties object as follows, replacing `<certs.PKCS12_file_location>` with the path to your truststore file, `<truststore_password>` with the password for the PKCS12 file, and `<scram_username>` and `<scram_password>` with the SCRAM username and password generated for the input topic. For example:

   ```java
   Properties properties = new Properties();
   properties.put(CommonClientConfigs.BOOTSTRAP_SERVERS_CONFIG, "<bootstrap-server-host:port>");
   properties.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
   properties.put(SslConfigs.SSL_PROTOCOL_CONFIG, "TLSv1.2");
   properties.put(SslConfigs.SSL_TRUSTSTORE_LOCATION_CONFIG, "<certs.PKCS12_file_location>");
   properties.put(SslConfigs.SSL_TRUSTSTORE_PASSWORD_CONFIG, "<truststore_password>");
   properties.put(SaslConfigs.SASL_MECHANISM, "SCRAM-SHA-512");
   String saslJaasConfig = "org.apache.kafka.common.security.scram.ScramLoginModule required "
      + "username=\"<scram_username>\" password=\"<scram_password>\";";
   properties.put(SaslConfigs.SASL_JAAS_CONFIG, saslJaasConfig);
   ```

1. Use the following Kafka shell command to run the `WordCountDemo` class application:

   `./kafka-run-class.sh org.apache.kafka.streams.examples.wordcount.WordCountDemo`

Run your Kafka Streams application. To view the topics, log in to your {{site.data.reuse.short_name}} UI and click the **Topics** tab.

For example, the following topics are created by the `WordCountDemo.java` Kafka Streams application:

```bash
streams-wordcount-KSTREAM-AGGREGATE-STATE-STORE-0000000003-changelog
streams-wordcount-KSTREAM-AGGREGATE-STATE-STORE-0000000003-repartition
```

## Viewing messages on output topic

To receive messages from the input topic, first set up permissions so that the output topic can consume messages, and then run the Kafka Streams consumer to send messages to the topic.

To set up permissions:

1. Log in to your {{site.data.reuse.long_name}} UI.
1. Click the **Topics** tab.
1. Select your output topic you created earlier from the list, for example `streams-wordcount-output`.
1. Click **Connect to this topic** on the right.
1. On the **Connect a client** tab, copy the address from the **Bootstrap server** section. This gives the bootstrap address for Kafka clients.
1. From the **Certificates** section, download the server certificate from the **PKCS12 certificate** section, and make a note of the password.
1. To generate SCRAM credentials, click the **Generate SCRAM credentials** button, and follow the instructions. Ensure you select **Consume only**. The name of the output topic is filled in automatically, for example `streams-wordcount-output`.
1. Click the **Sample code** tab, and copy the snippet from the **Sample configuration properties** section into a new file called `streams-demo-output.properties`. This creates a new properties file for your Kafka Streams application.
1. Replace `<certs.PKCS12_file_location>` with the path to your truststore file, `<truststore_password>` with the password for the PKCS12 file, and `<scram_username>` and `<scram_password>` with the SCRAM username and password generated for the input topic.

To view messages on the output topic, use the bootstrap address, the output topic name, and the new properties file you created. For example, run [`kafka-console-consumer.sh`](https://github.com/apache/kafka/blob/3.3/bin/kafka-console-consumer.sh){:target="_blank"} with the following options:

- `--bootstrap-server <broker_url>`: where `<broker_url>` is your cluster's broker URL copied earlier from the **Bootstrap server** section.
- `--topic <topic_name>`: where `<topic_name>` is the name of your output topic, in this example, `streams-wordcount-output`.
- `--consumer.config <properties_file>`: where `<properties_file>` is the new properties file including full path to it, in this example, `streams-demo-output.properties`.

For example:

```bash
./bin/kafka-console-consumer.sh \
   --bootstrap-server <bootstrap-host:port> \
   --topic streams-wordcount-output \
   --consumer.config streams-demo-output.properties \
   --from-beginning \
   --group streams-demo-group-consumer \
   --formatter kafka.tools.DefaultMessageFormatter \
   --property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer \
   --property value.deserializer=org.apache.kafka.common.serialization.LongDeserializer \
   --property print.key=true
this    1
is    1
a    1
test    1
message    1
this    2
will    1
be    1
used    1
to    3
demo    1
the    1
streams    5
sample    1
app    1
it    1
is    2
a    2
kafka    7
streams    6
test    2
message    2
the    2
words    1
in    1
these    1
messages    1
will    2
be    2
counted    1
by    1
the    3
streams    7
app    2

Processed a total of 34 messages
```

## Troubleshooting

If the `kafka-console-consumer` command is stuck, consider adding a partition option to the command, for example:

```bash
./bin/kafka-console-consumer.sh \
   --bootstrap-server <bootstrap-host:port> \
   --topic streams-wordcount-output \
   --consumer.config streams-demo-output.properties \
   --partition <partition-number> \
   --from-beginning \
   --group streams-demo-group-consumer \
   --formatter kafka.tools.DefaultMessageFormatter \
   --property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer \
   --property value.deserializer=org.apache.kafka.common.serialization.LongDeserializer \
   --property print.key=true
```
