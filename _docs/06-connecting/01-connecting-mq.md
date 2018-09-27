---
title: "Connecting to IBM MQ"
permalink: /connecting/mq/
excerpt: "Connecting to MQ."
last_modified_at: 2018-07-19T11:31:38-04:00
toc: true
---

You can use the {{site.data.reuse.kafka-connect-mq-source}} to copy data from IBM MQ into {{site.data.reuse.long_name}} or Apache Kafka. The connector copies messages from a source MQ queue to a target Kafka topic.

## When to use

Many organizations use both IBM MQ and Apache Kafka for their messaging needs. Although they're often used to solve different kinds of messaging problems, users often want to connect them together for various reasons. For example, IBM MQ is often integrated with systems of record while Apache Kafka is often used for streaming events from web applications. The ability to connect the two systems together enables scenarios in which these two environments intersect.

### About Kafka Connect

When connecting Apache Kafka and other systems, the technology of choice is the [Kafka Connect framework](https://kafka.apache.org/documentation/#connect).

Kafka Connect connectors run inside a Java process called a worker. Kafka Connect can run in either standalone or distributed mode. Standalone mode is intended for testing and temporary connections between systems. Distributed mode is more appropriate for production use. These instructions are for standalone mode for ease of understanding.

When you run Kafka Connect with a standalone worker, there are two configuration files:
* The worker configuration file contains the properties needed to connect to Kafka. This is where you provide the details for connecting to Kafka.
* The connector configuration file contains the properties needed for the connector. This is where you provide the details for connecting to IBM MQ.

When you run Kafka Connect with the distributed worker, you still use a worker configuration file but the connector configuration is supplied using a REST API. Refer to the Kafka Connect documentation for more details about the distributed worker.

For getting started and problem diagnosis, the simplest setup is to run only one connector in each standalone worker. Kafka Connect workers print a lot of information and it's easier to understand if the messages from multiple connectors are not interleaved.

**Note:** You can use an existing IBM MQ or Kafka installation, either locally or on the cloud. For performance reasons, it is recommended to run the Kafka Connect worker close to the queue manager to minimise the effect of network latency. For example, if you have a queue manager in your datacenter and Kafka in the cloud, it's best to run the Kafka Connect worker in your datacenter.

## Prerequisites

The connector runs inside the Kafka Connect runtime, which is part of the Apache Kafka distribution. {{site.data.reuse.long_name}} does not run connectors as part of its deployment, so you need an Apache Kafka distribution to get the Kafka Connect runtime environment.

Ensure you have the following available:

- [IBM MQ](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_8.0.0/com.ibm.mq.helphome.v80.doc/WelcomePagev8r0.htm) v8 or later installed. **Note:** These instructions are for IBM MQ v9 running on Linux. If you're using a different version or platform, you might have to adjust some steps slightly.
- An [Apache Kafka](http://kafka.apache.org/downloads) distribution for the Kafka Connect runtime environment. These instructions are for Apache Kafka 0.10.2.0 or later.
- The Kafka Connect source connector JAR you [download from {{site.data.reuse.long_name}} UI](#downloading).
- Configuration information for connecting to your IBM MQ queue manager. You can use the sample connector properties file that you [download from the {{site.data.reuse.long_name}} UI](#downloading).
- Configuration information for connecting to your {{site.data.reuse.long_name}} or Apache Kafka cluster (IP address and port).

## Downloading the connector

You can obtain the {{site.data.reuse.kafka-connect-mq-source}} as follows:
1. Log in to your {{site.data.reuse.long_name}} UI.
2. Click the **Toolbox** tab, and click **{{site.data.reuse.kafka-connect-mq-source}}**.
3. Download both the `connector JAR` and the `sample connector properties` files from the page.

Alternatively, you can [clone the project from Github](https://github.com/ibm-messaging/kafka-connect-mq-source). However, if you clone from Github, you have to build the connector yourself as described in the README.

## Setting up the queue manager

These sample instructions set up an IBM MQ queue manager that uses the local operating system to authenticate the user ID and password. The example uses the user ID `alice` and the password `passw0rd`.

1. Log in as a user authorized to administer IBM MQ, and ensure the MQ commands are on the path.
2. Create a queue manager with a TCP/IP listener on port 1414:\\
   `crtmqm -p 1414 MYQM`
3. Start the queue manager:\\
   `strmqm MYQM`
4. Start the `runmqsc` tool to configure the queue manager:\\
   `runmqsc MYQM`
5. In `runmqsc`, create a server-connection channel:\\
   `DEFINE CHANNEL(MYSVRCONN) CHLTYPE(SVRCONN)`
6. Set the channel authentication rules to accept connections requiring userid and password:\\
   `SET CHLAUTH(MYSVRCONN) TYPE(BLOCKUSER) USERLIST('nobody')`\\
   `SET CHLAUTH('*') TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(NOACCESS)`\\
   `SET CHLAUTH(MYSVRCONN) TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(CHANNEL) CHCKCLNT(REQUIRED)`\\

7. Set the identity of the client connections based on the supplied context (the user ID):\\
   `ALTER AUTHINFO(SYSTEM.DEFAULT.AUTHINFO.IDPWOS) AUTHTYPE(IDPWOS) ADOPTCTX(YES)`
8. Refresh the connection authentication information:\\
   `REFRESH SECURITY TYPE(CONNAUTH)`
9. Create a queue for the Kafka Connect connector to use:\\
   `DEFINE QLOCAL(MYQSOURCE)`
10. Authorize the user ID `alice` to connect to and inquire the queue manager:\\
   `SET AUTHREC OBJTYPE(QMGR) PRINCIPAL('alice') AUTHADD(CONNECT,INQ)`
11. Authorize the user ID `alice` to use the queue:\\
   `SET AUTHREC PROFILE(MYQSOURCE) OBJTYPE(QUEUE) PRINCIPAL('alice') AUTHADD(ALLMQI)`\\
12. Stop the `runmqsc` tool by typing `END`.

The queue manager is now ready to accept connection from the connector and get messages from a queue called `MYQSOURCE`.

## Setting up Apache Kafka

If you do not already have {{site.data.reuse.long_name}} or Apache Kafka, you can download it from [here](http://kafka.apache.org/downloads). Ensure you have the prerequisites installed, such as Java.

Download the latest `.tgz` file (for example, `kafka_2.11-2.0.0.tgz`) and extract it. The top-level directory of the extracted `.tgz` file is the Kafka root directory. It contains several directories including `/bin` for the Kafka executables and `/config` for the configuration files.

To run a minimal Kafka cluster, you need to start up several components.

**Tip:** For clarity, run each component in a separate terminal window, starting each in the Kafka root directory.

1. Open a terminal window and change to the Kafka root directory. Start a ZooKeeper server:\\
   `bin/zookeeper-server-start.sh config/zookeeper.properties`\\
    When the ZooKeeper server is up and running, it prints a message similar to the following:\\
    `INFO binding to port 0.0.0.0/0.0.0.0:2181`
2. Open another terminal and start a Kafka server:\\
   `bin/kafka-server-start.sh config/server.properties`\\
   When the Kafka server is up and running, it prints a message similar to the following:\\
   `INFO [KafkaServer id=0] started`
3. Now create a topic called `TSOURCE`:\\
   `bin/kafka-topics.sh --zookeeper localhost:2181  --create --topic TSOURCE --partitions 1 --replication-factor 1`
4. To check what topics exist, use the following command:\\
   `bin/kafka-topics.sh --zookeeper localhost:2181 --describe`

You now have a basic Kafka cluster setup consisting of a single node with the following configuration:
* Kafka bootstrap server: `localhost:9092`
* ZooKeeper server: `localhost:2181`
* Topic name: `TSOURCE`

**NOTE:** This configuration of Kafka writes its data in `/tmp/kafka-logs`, while ZooKeeper uses `/tmp/zookeeper`, and Kafka Connect uses `/tmp/connect.offsets`. To ensure these directories are not being used, clear them out before using Apache Kafka.

## Configuring the connector to connect to MQ

The connector requires details to connect to IBM MQ and to your {{site.data.reuse.long_name}} or Apache Kafka cluster.

To provide connection details for IBM MQ, use the sample connector properties file you downloaded (`mq-source.properties`). Create a copy of it and save it to the location where you have the connector JAR file.

The connector connects to IBM MQ using a client connection. You must provide the following connection information for your queue manager:
* The name of the IBM MQ queue manager.
* The connection name (one or more host and port pairs).
* The channel name.
* The name of the source IBM MQ queue.
* The user name and password if the queue manager is configured to require them for client connections.
* The name of the target Kafka topic.

For example, the following configuration matches the example MQ configuration above:
```
mq.queue.manager=MYQM
mq.connection.name.list=localhost(1414)
mq.channel.name=MYSVRCONN
mq.queue=MYQSOURCE
mq.user.name=alice
mq.password=passw0rd
topic=TSOURCE
```

See the sample properties file for a full list of properties you can configure, and also see the [configuration reference](../mq-source-reference/).

## Configuring the connector to connect to {{site.data.reuse.long_name}} or Apache Kafka

To provide the connection details for your Kafka cluster, the Kafka distribution includes a file called `connect-standalone.properties` that you can edit to provide the details. Specify the following connection information:
* A list of one or more Kafka brokers for bootstrapping connections.
* Whether the cluster requires connections to use SSL/TLS.
* Authentication credentials if the cluster requires clients to authenticate.

### Configuration for connecting to {{site.data.reuse.long_name}}

To connect to {{site.data.reuse.long_name}}, you will need the broker URL and to configure the worker to establish TLS connections. You will also need to create the target topic.

1. Log in to your {{site.data.reuse.long_name}} UI.
2. Click the **Topics** tab.
3. If you have not previously created the topic to use with the connector, create it now.
4. Select the topic in the list of topics.
5. Click the **Connection information** tab.
6. Copy the **broker URL**. This is the Kafka bootstrap server.
7. In the **Certificates** section, click **Download Java truststore** and choose a location for the downloaded file that can be accessed by the Kafka Connect worker.

You will also need an API key authorized to connect to the cluster and write to the topic. For the distributed worker, it will also need to be able to write to the Kafka Connect frameworks internal topics.

The following example shows the required properties for the Kafka Connect standalone properties file:

```
bootstrap.servers=<broker_url>
security.protocol=SASL_SSL
ssl.protocol=TLSv1.2
ssl.truststore.location=<certs.jks_file_location>
ssl.truststore.password=<truststore_password>
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="token" password="<api_key>";
producer.security.protocol=SASL_SSL
producer.ssl.protocol=TLSv1.2
producer.ssl.truststore.location=<certs.jks_file_location>
producer.ssl.truststore.password=<truststore_password>
producer.sasl.mechanism=PLAIN
producer.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="token" password="<api_key>";
```

You replace `<broker_url>` with your cluster's broker URL, `<certs.jks_file_location>` with the path of your downloaded truststore file, `<truststore_password>` with `"password"`, and `<api_key>` with the API key.

## Running the connector

1. Open a terminal window and change to the Kafka root directory. Start the connector worker as follows:\\
   `CLASSPATH=<path-to-connector-jar-file>/kafka-connect-mq-source-1.0-SNAPSHOT-jar-with-dependencies.jar bin/connect-standalone.sh config/connect-standalone.properties ~/mq-source.properties`\\
   When the connector worker starts, the following message is displayed:\\
   `INFO Created connector mq-source`\\
   When the connector worker successfully connects to IBM MQ, the following message is displayed:\\
   `INFO Connection to MQ established`
2. Open another terminal window and use the Kafka console consumer command to start consuming messages from your topic, and print them to the console:\\
   `bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic TSOURCE`
3. To add messages to the IBM MQ queue, run the `amqsput` sample and type in some messages:\\
   `/opt/mqm/samp/bin/amqsput MYQSOURCE MYQM`

The messages are printed by the Kafka console consumer, and are transferred from the IBM MQ queue `MYQSOURCE` into the Kafka topic `TSOURCE` using the `MYQM` queue manager.

## Stopping Apache Kafka

When you completed testing the connector, stop Apache Kafka as follows:

1. Stop any Kafka Connect workers and tools such as the console consumers you were using with the connector.
2. Change to the Kafka root directory and stop Kafka:\\
   `bin/kafka-server-stop.sh`
3. Stop ZooKeeper:\\
   `bin/zookeeper-server-stop.sh`
