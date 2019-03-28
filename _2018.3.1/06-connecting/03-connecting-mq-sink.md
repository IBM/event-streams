---
title: "Running the MQ sink connector"
# permalink: /connecting/mq/sink/
excerpt: "Running MQ sink connector"
categories: connecting/mq
slug: sink
toc: true
---

You can use the {{site.data.reuse.kafka-connect-mq-sink-short}} to copy data from {{site.data.reuse.long_name}} or Apache Kafka into IBM MQ. The connector copies messages from a Kafka topic into a target MQ queue.

This document contains steps for running the connector in standalone mode for development and test purposes.

![Event Streams 2018.3.1 icon](../../../images/2018.3.1.svg "In Event Streams 2018.3.1 and later.") The {{site.data.reuse.kafka-connect-mq-sink}} is supported in {{site.data.reuse.long_name}} 2018.3.1 and later.

## Prerequisites

The connector runs inside the Kafka Connect runtime, which is part of the Apache Kafka distribution. {{site.data.reuse.long_name}} does not run connectors as part of its deployment, so you need an Apache Kafka distribution to get the Kafka Connect runtime environment.

Ensure you have the following available:

- [IBM MQ](https://www.ibm.com/support/knowledgecenter/SSFKSJ_8.0.0/com.ibm.mq.helphome.v80.doc/WelcomePagev8r0.htm) v8 or later installed.
   **Note:** These instructions are for IBM MQ v9 running on Linux. If you're using a different version or platform, you might have to adjust some steps slightly.
- The Kafka Connect runtime environment that comes as part of an [Apache Kafka](http://kafka.apache.org/downloads) distribution. These instructions are for Apache Kafka 2.0.0 or later.

## Downloading the connector

You can obtain the {{site.data.reuse.kafka-connect-mq-sink}} as follows:
1. Log in to your {{site.data.reuse.long_name}} UI.
2. Click the **Toolbox** tab, and click **{{site.data.reuse.kafka-connect-mq-sink}}**.
3. Download both the `connector JAR` and the `sample connector properties` files from the page.

Alternatively, you can [clone the project from GitHub](https://github.com/ibm-messaging/kafka-connect-mq-sink). However, if you clone from GitHub, you have to build the connector yourself as described in the [README](https://github.com/ibm-messaging/kafka-connect-mq-sink/blob/master/README.md).

## Setting up the queue manager

These sample instructions set up an IBM MQ queue manager that uses its local operating system to authenticate the user ID and password. The user ID and password you provide must already be created on the operating system where IBM MQ is running.

1. Log in as a user authorized to administer IBM MQ, and ensure the MQ commands are on the path.
2. Create a queue manager with a TCP/IP listener on port 1414:
   ```crtmqm -p 1414 <queue_manager_name>```
   for example to create a queue manager called `QM1` use `crtmqm -p 1414 QM1`
3. Start the queue manager:
   ```strmqm <queue_manager_name>```
4. Start the `runmqsc` tool to configure the queue manager:
   ```runmqsc <queue_manager_name>```
5. In `runmqsc`, create a server-connection channel:
   ```DEFINE CHANNEL(<channel_name>) CHLTYPE(SVRCONN)```
6. Set the channel authentication rules to accept connections requiring userid and password:
    1. `SET CHLAUTH(<channel_name>) TYPE(BLOCKUSER) USERLIST('nobody')`
    1. `SET CHLAUTH('*') TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(NOACCESS)`
    1. `SET CHLAUTH(<channel_name>) TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(CHANNEL) CHCKCLNT(REQUIRED)`

7. Set the identity of the client connections based on the supplied context (the user ID):
   ```ALTER AUTHINFO(SYSTEM.DEFAULT.AUTHINFO.IDPWOS) AUTHTYPE(IDPWOS) ADOPTCTX(YES)```
8. Refresh the connection authentication information:
   ```REFRESH SECURITY TYPE(CONNAUTH)```
9. Create a queue for the Kafka Connect connector to use:
   ```DEFINE QLOCAL(<queue_name>)```
10. Authorize the IBM MQ user ID to connect to and inquire the queue manager:
   ```SET AUTHREC OBJTYPE(<queue_manager_name>) PRINCIPAL('<user_id>') AUTHADD(CONNECT,INQ)```
11. Authorize the IBM MQ user ID to use the queue:
   ```SET AUTHREC PROFILE(<queue_name>) OBJTYPE(QUEUE) PRINCIPAL('<user_id>') AUTHADD(ALLMQI)```
12. Stop the `runmqsc` tool by typing `END`.

For example, for a queue manager called `QM1`, with user ID `alice`, creating a server-connection channel called `MYSVRCONN` and a queue called `MYQSINK` you should have run the following commands in `runmqsc`:
```
DEFINE CHANNEL(MYSVRCONN) CHLTYPE(SVRCONN)
SET CHLAUTH(MYSVRCONN) TYPE(BLOCKUSER) USERLIST('nobody')
SET CHLAUTH('*') TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(NOACCESS)
SET CHLAUTH(MYSVRCONN) TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(CHANNEL) CHCKCLNT(REQUIRED)
ALTER AUTHINFO(SYSTEM.DEFAULT.AUTHINFO.IDPWOS) AUTHTYPE(IDPWOS) ADOPTCTX(YES)
REFRESH SECURITY TYPE(CONNAUTH)
DEFINE QLOCAL(MYQSINK)
SET AUTHREC OBJTYPE(QM1) PRINCIPAL('alice') AUTHADD(CONNECT,INQ)
SET AUTHREC PROFILE(MYQSINK) OBJTYPE(QUEUE) PRINCIPAL('alice') AUTHADD(ALLMQI)
END
```

The queue manager is now ready to accept connection from the connector and get messages from a queue.

## Setting up Apache Kafka

To send messages from {{site.data.reuse.long_name}} to IBM MQ, create a topic and obtain security information for your {{site.data.reuse.short_name}} installation. You then use this information later to configure the connection to your {{site.data.reuse.short_name}} instance.

You can also send IBM MQ messages to Apache Kafka running locally on your machine, see the [public GitHub repository](https://github.com/ibm-messaging/kafka-connect-mq-sink/blob/master/UsingMQwithKafkaConnect.md) for more details.

1. Log in to your {{site.data.reuse.long_name}} UI.
2. Click the **Topics** tab.
3. If you have not previously created the topic to use with the connector, create it now by clicking **Create topic**.
4. Select the topic in the list of topics.
5. Click **Connect to this topic** on the right.
6. On the **Connect a client** tab, copy the address from the **Bootstrap server** section. This gives the bootstrap address for Kafka clients.
7. From the **Certificates** section, download the server certificate from the **Java truststore** section, and choose a location for the downloaded file that can be accessed by the Kafka Connect worker.
8. Go to the **API key** section and follow the instructions to generate an API key authorized to connect to the cluster, and to produce to and consume from the topic.

**Note:** For the distributed worker, the API key will also need to be able to write to the Kafka Connect framework's internal topics.

## Configuring the connector to connect to MQ

The connector requires details to connect to IBM MQ and to your {{site.data.reuse.long_name}} or Apache Kafka cluster.

To provide connection details for IBM MQ, use the sample connector properties file you downloaded (`mq-sink.properties`). Create a copy of it and save it to the location where you have the connector JAR file.

The connector connects to IBM MQ using a client connection. You must provide the following connection information for your queue manager:
* Comma-separated list of Kafka topics to pull events from.
* The name of the IBM MQ queue manager.
* The connection name (one or more host and port pairs).
* The channel name.
* The name of the sink IBM MQ queue.
* The user name and password if the queue manager is configured to require them for client connections.

For example:
```
mq.queue.manager=QM1
mq.connection.name.list=localhost(1414)
mq.channel.name=MYSVRCONN
mq.queue=MYQSINK
mq.user.name=alice
mq.password=passw0rd
topics=TSINK
```

See the sample properties file for a full list of properties you can configure, and also see the [GitHub README](https://github.com/ibm-messaging/kafka-connect-mq-sink) for all available configuration options.

## Configuring the connector to connect to {{site.data.reuse.long_name}} or Apache Kafka

To provide the connection details for your Kafka cluster, the Kafka distribution includes a file called `connect-standalone.properties` that you can edit to provide the details. It should include the following connection information:
* A list of one or more Kafka brokers for bootstrapping connections.
* Whether the cluster requires connections to use SSL/TLS.
* Authentication credentials if the cluster requires clients to authenticate.

To connect to {{site.data.reuse.long_name}}, you will need the broker URL and security details you collected earlier when you [configured {{site.data.reuse.long_name}}](#setting-up-apache-kafka).

The following example shows the required properties for the Kafka Connect standalone properties file:

```
bootstrap.servers=<broker_url>
security.protocol=SASL_SSL
ssl.protocol=TLSv1.2
ssl.truststore.location=<certs.jks_file_location>
ssl.truststore.password=<truststore_password>
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="token" password="<api_key>";
consumer.security.protocol=SASL_SSL
consumer.ssl.protocol=TLSv1.2
consumer.ssl.truststore.location=<certs.jks_file_location>
consumer.ssl.truststore.password=<truststore_password>
consumer.sasl.mechanism=PLAIN
consumer.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="token" password="<api_key>";
```

You replace `<broker_url>` with your cluster's broker URL, `<certs.jks_file_location>` with the path of your downloaded truststore file, `<truststore_password>` with `"password"`, and `<api_key>` with the API key.

**Note:** If you are running Apache Kafka locally you can use the default `connect-standalone.properties` file.

## Generate a producer application

To test the connector you will need an application to produce events to your topic.

1. Log in to your {{site.data.reuse.long_name}} UI.
1. Click the **Toolbox** tab.
1. Click **Generate application** under **Starter application**
1. Enter a name for the application
1. Select only **Produce messages**
1. Select **Choose existing topic** and choose the topic you provided in the MQ connector configuration
1. Click **Generate**
1. Once the application has been generated, click **Download** and follow the instructions in the UI to get the application running

## Running the connector

1. Open a terminal window and change to the Kafka root directory. Start the connector worker as follows, replacing the `<path-to-*>` and `<jar-version>` placeholders:
    ```
    CLASSPATH=<path-to-connector-jar>/kafka-connect-mq-sink-<jar-version>-jar-with-dependencies.jar bin/connect-standalone.sh config/connect-standalone.properties <path-to-mq-properties>/mq-sink.properties
    ```
    The log output will include the following messages that indicate the connector worker has started and successfully connected to IBM MQ:
    ```
    INFO Created connector mq-sink
    INFO Connection to MQ established
    ```
1. Navigate to the UI of the [sample application](#generate-a-producer-application) you generated earlier and start producing messages to {{site.data.reuse.long_name}}.
1. Use the `amqsget` sample to get messages from the MQ Queue:
    ```/opt/mqm/samp/bin/amqsget <queue_manager_name> <queue_name>```
    After a short delay, you should see the messages printed.

## Advanced configuration

For more details about the connector and to see all configuration options, see the [GitHub README](https://github.com/ibm-messaging/kafka-connect-mq-sink).
