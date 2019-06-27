---
title: "Running the MQ source connector"
# permalink: /connecting/mq/source/
excerpt: "Running MQ source connector"
categories: connecting/mq
slug: source
toc: true
---

You can use the {{site.data.reuse.kafka-connect-mq-source-short}} to copy data from IBM MQ into {{site.data.reuse.long_name}} or Apache Kafka. The connector copies messages from a source MQ queue to a target Kafka topic.

Kafka Connect can be run in standalone or distributed mode. This document contains steps for running the connector in distributed mode in a Docker container. In this mode, work balancing is automatic, scaling is dynamic, and tasks and data are fault-tolerant. For more details on the difference between standalone and distributed mode see the [explanation of Kafka Connect workers](../connectors/#workers).

## Prerequisites

The connector runs inside the Kafka Connect runtime, which is part of the Apache Kafka distribution. {{site.data.reuse.long_name}} does not run connectors as part of its deployment, so you need an Apache Kafka distribution to get the Kafka Connect runtime environment.

Ensure you have the following available:

- [IBM MQ](https://www.ibm.com/support/knowledgecenter/SSFKSJ_8.0.0/com.ibm.mq.helphome.v80.doc/WelcomePagev8r0.htm){:target="_blank"} v8 or later installed.
   **Note:** These instructions are for IBM MQ v9 running on Linux. If you're using a different version or platform, you might have to adjust some steps slightly.

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
   ```SET AUTHREC OBJTYPE(QMGR) PRINCIPAL('<user_id>') AUTHADD(CONNECT,INQ)```
11. Authorize the IBM MQ user ID to use the queue:
   ```SET AUTHREC PROFILE(<queue_name>) OBJTYPE(QUEUE) PRINCIPAL('<user_id>') AUTHADD(ALLMQI)```
12. Stop the `runmqsc` tool by typing `END`.

For example, for a queue manager called `QM1`, with user ID `alice`, creating a server-connection channel called `MYSVRCONN` and a queue called `MYQSOURCE`, you run the following commands in `runmqsc`:
```
DEFINE CHANNEL(MYSVRCONN) CHLTYPE(SVRCONN)
SET CHLAUTH(MYSVRCONN) TYPE(BLOCKUSER) USERLIST('nobody')
SET CHLAUTH('*') TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(NOACCESS)
SET CHLAUTH(MYSVRCONN) TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(CHANNEL) CHCKCLNT(REQUIRED)
ALTER AUTHINFO(SYSTEM.DEFAULT.AUTHINFO.IDPWOS) AUTHTYPE(IDPWOS) ADOPTCTX(YES)
REFRESH SECURITY TYPE(CONNAUTH)
DEFINE QLOCAL(MYQSOURCE)
SET AUTHREC OBJTYPE(QMGR) PRINCIPAL('alice') AUTHADD(CONNECT,INQ)
SET AUTHREC PROFILE(MYQSOURCE) OBJTYPE(QUEUE) PRINCIPAL('alice') AUTHADD(ALLMQI)
END
```

The queue manager is now ready to accept connection from the connector and get messages from a queue.

## Configuring the connector to connect to MQ

The connector requires details to connect to IBM MQ and to your {{site.data.reuse.long_name}} or Apache Kafka cluster. You can generate the sample connector configuration file for {{site.data.reuse.short_name}} from either the UI or the CLI. For distributed mode the configuration is in JSON format and in standalone mode it is a `.properties` file.

The connector connects to IBM MQ using a client connection. You must provide the following connection information for your queue manager:
* The name of the IBM MQ queue manager.
* The connection name (one or more host and port pairs).
* The channel name.
* The name of the source IBM MQ queue.
* The user name and password if the queue manager is configured to require them for client connections.
* The name of the target Kafka topic.

### Using the UI

Use the UI to download a `.json` file which can be used in distributed mode.

1. Log in to your {{site.data.reuse.long_name}} UI.
2. Click the **Toolbox** tab and scroll to the **Connectors** section.
3. Go to the **{{site.data.reuse.kafka-connect-connecting-to-mq}}** tile, and click **Add connectors**.
4. Click the **IBM MQ connectors** link.
5. Ensure the `MQ Source` tab is selected and click on the **Download MQ Source Configuration**, this will display another window.
6. Use the relevant fields to alter the configuration of the `MQ Source` connector. 
7. Click **Download** to generate and download the configuration file with the supplied fields.
8. Open the downloaded configuration file and change the values of `mq.user.name` and `mq.password` to the username and password that you used to configure your instance of MQ.

### Using the CLI

Use the CLI to download a `.json` or `.properties` file which can be used in distributed or standalone mode.

1. {{site.data.reuse.icp_cli_login}}
2. Run the following command to initialize the {{site.data.reuse.short_name}} CLI on the cluster:\\
   `cloudctl es init`
3. Run the `connector-config-mq-source` command to generate the configuration file for the `MQ Source` connector.\\
   For example, to generate a configuration file for an instance of `MQ` with the following information: a queue manager called `QM1`, with a connection point of `localhost(1414)`, a channel name of `MYSVRCONN`, a queue of `MYQSOURCE` and connecting to the topic `TSOURCE`, run the following command:
   ```
   cloudctl es connector-config-mq-source --mq-queue-manager="QM1" --mq-connection-name-list="localhost(1414)" --mq-channel="MYSVRCONN" --mq-queue="MYQSOURCE" --topic="TSOURCE" --file="mq-source" --json
   ```
   **Note**: Omitting the `--json` flag will generate a `mq-source.properties` file which can be used for standalone mode.
4. Change the values of `mq.user.name` and `mq.password` to the username and password that you used to configure your instance of MQ.

The final configuration file will resemble the following:
```
{
	"name": "mq-source",
	"config": {
		"connector.class": "com.ibm.eventstreams.connect.mqsource.MQSourceConnector",
		"tasks.max": "1",
		"topic": "TSOURCE",
		"mq.queue.manager": "QM1",
		"mq.connection.name.list": "localhost(1414)",
		"mq.channel.name": "MYSVRCONN",
		"mq.queue": "MYQSOURCE",
		"mq.user.name": "alice",
		"mq.password": "passw0rd",
		"mq.record.builder": "com.ibm.eventstreams.connect.mqsource.builders.DefaultRecordBuilder",
		"key.converter": "org.apache.kafka.connect.storage.StringConverter",
		"value.converter": "org.apache.kafka.connect.storage.StringConverter"
	}
}
```

A list of all the possible flags can be found by running the command `cloudctl es connector-config-mq-source --help`. Alternatively, See the [sample properties file](https://github.com/ibm-messaging/kafka-connect-mq-source/tree/master/config) for a full list of properties you can configure, and also see the [GitHub README](https://github.com/ibm-messaging/kafka-connect-mq-source){:target="_blank"} for all available configuration options.

## Downloading the MQ Source connector

1. Log in to your {{site.data.reuse.long_name}} UI.
2. Click the **Toolbox** tab and scroll to the **Connectors** section.
3. Go to the **{{site.data.reuse.kafka-connect-connecting-to-mq}}** tile, and click **Add connectors**.
4. Ensure the `MQ Source` tab is selected and click on the **Download MQ Source JAR**, this will download the `MQ Source` JAR file.

## Configuring Kafka Connect

IBM Event Streams provides help with getting a Kafka Connect Environment.

Follow the steps in [set up Kafka Connect](../../setting-up-connectors/) to get Kafka Connect running. When adding connectors add the MQ connector you downloaded earlier.

Verify that the MQ source connector is available in your Kafka Connect environment:\\
```
$ curl http://localhost:8083/connector-plugins
[{"class":"com.ibm.eventstreams.connect.mqsource.MQSourceConnector","type":"source","version":"1.1.0"}]
```

Verify that the connector is running. For example, If you started a connector called mq-source:\\
```
$ curl http://localhost:8083/connectors
[mq-source]
```

Verify the log output of Kafka Connect includes the following messages that indicate the connector task has started and successfully connected to IBM MQ:
```
 INFO Created connector mq-source
 INFO Connection to MQ established
 ```

## Send a test message

1. To add messages to the IBM MQ queue, run the `amqsput` sample and type in some messages:\\
   `/opt/mqm/samp/bin/amqsput <queue_name> <queue_manager_name>`
2. Log in to your {{site.data.reuse.long_name}} UI.
3. Navigate to the the **Topics** tab and select the connected topic. Messages will appear in the message browser of that topic.

## Advanced configuration

For more details about the connector and to see all configuration options, see the [GitHub README](https://github.com/ibm-messaging/kafka-connect-mq-source){:target="_blank"}.
