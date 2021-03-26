---
title: "Running the MQ source connector"
# permalink: /connecting/mq/source/
excerpt: "Running MQ source connector"
categories: connecting/mq
slug: source
toc: true
---

You can use the {{site.data.reuse.kafka-connect-mq-source-short}} to copy data from IBM MQ into {{site.data.reuse.long_name}} or Apache Kafka. The connector copies messages from a source MQ queue to a target Kafka topic.

Kafka Connect can be run in standalone or distributed mode. This document contains steps for running the connector in distributed mode in {{site.data.reuse.openshift_short}}. In this mode, work balancing is automatic, scaling is dynamic, and tasks and data are fault-tolerant. For more details on the difference between standalone and distributed mode see the [explanation of Kafka Connect workers](../../connectors/#workers).

## Prerequisites

To follow these instructions, ensure you have the following available:

- A running Kafka Connect environment on {{site.data.reuse.openshift_short}} using a `KafkaConnectS2I` custom resource
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

The connector requires details to connect to IBM MQ and to your {{site.data.reuse.long_name}} or Apache Kafka cluster. You can generate the sample connector configuration file for {{site.data.reuse.short_name}} from either the UI or the CLI.

The connector connects to IBM MQ using a client connection. You must provide the following connection information for your queue manager:
* The name of the IBM MQ queue manager.
* The connection name (one or more host and port pairs).
* The channel name.
* The name of the source IBM MQ queue.
* The user name and password if the queue manager is configured to require them for client connections.
* The name of the target Kafka topic.

### Using the UI

Use the UI to download a `.json` file which can be used in distributed mode.

1. {{site.data.reuse.es_ui_login_nonadmin_mq}}
2. Click **Toolbox** in the primary navigation and scroll to the **Connectors** section.
3. Go to the **Add connectors to your Kafka Connect environment** tile and click **{{site.data.reuse.kafka-connect-connecting-to-mq}}**
4. Ensure the `MQ Source` tab is selected and click **Generate**.
6. In the dialog, enter the configuration of the `MQ Source` connector.
7. Click **Download** to generate and download the configuration file with the supplied fields.
8. Open the downloaded configuration file and change the values of `mq.user.name` and `mq.password` to the username and password that you used to configure your instance of MQ.

### Using the CLI

Use the CLI to generate a configuration file.

1. {{site.data.reuse.cp_cli_login}}
2. Run the following command to initialize the {{site.data.reuse.short_name}} CLI on the cluster:\\
   `cloudctl es init`
3. Run the `connector-config-mq-source` command to generate the configuration file for the `MQ Source` connector.\\
   For example, to generate a configuration file for an instance of `MQ` with the following information: a queue manager called `QM1`, with a connection point of `localhost(1414)`, a channel name of `MYSVRCONN`, a queue of `MYQSOURCE` and connecting to the topic `TSOURCE`, run the following command:
   ```
   cloudctl es connector-config-mq-source --mq-queue-manager="QM1" --mq-connection-name-list="localhost(1414)" --mq-channel="MYSVRCONN" --mq-queue="MYQSOURCE" --topic="TSOURCE" --file="mq-source" --format yaml
   ```
   **Note**: Omitting the `--format yaml` flag will generate a `mq-source.properties` file which can be used for standalone mode. Specifying `--format json` will generate a `mq-source.json` file which can be used for distributed mode outside {{site.data.reuse.openshift_short}}.
4. Change the values of `mq.user.name` and `mq.password` to the username and password that you used to configure your instance of MQ.

The final configuration file will resemble the following:
```
apiVersion: eventstreams.ibm.com/v1alpha1
kind: KafkaConnector
metadata:
  name: mq-source
  labels:
    # The eventstreams.ibm.com/cluster label identifies the KafkaConnect instance
    # in which to create this connector. That KafkaConnect instance
    # must have the eventstreams.ibm.com/use-connector-resources annotation
    # set to true.
    eventstreams.ibm.com/cluster: <kafka_connect_name>
spec:
  class: com.ibm.eventstreams.connect.mqsource.MQSourceConnector
  tasksMax: 1
  config:
    topic: TSOURCE
    mq.queue.manager: QM1
    mq.connection.name.list: localhost(1414)
    mq.channel.name: MYSVRCONN
    mq.queue: MYQSOURCE
    mq.user.name: alice
    mq.password: passw0rd
    key.converter: org.apache.kafka.connect.storage.StringConverter
    value.converter: org.apache.kafka.connect.storage.StringConverter
    mq.record.builder: com.ibm.eventstreams.connect.mqsource.builders.DefaultRecordBuilder
```

A list of all the possible flags can be found by running the command `cloudctl es connector-config-mq-source --help`. Alternatively, See the [sample properties file](https://github.com/ibm-messaging/kafka-connect-mq-source/tree/master/config) for a full list of properties you can configure, and also see the [GitHub README](https://github.com/ibm-messaging/kafka-connect-mq-source){:target="_blank"} for all available configuration options.

## Downloading the MQ Source connector

1. {{site.data.reuse.es_ui_login_nonadmin_mq}}
2. Click **Toolbox** in the primary navigation and scroll to the **Connectors** section.
3. Go to the **Add connectors to your Kafka Connect environment** tile and click **{{site.data.reuse.kafka-connect-connecting-to-mq}}**
4. Ensure the `MQ Source` tab is selected and click **Go to GitHub**. Download the JAR file from the list of assets for the latest release.

## Configuring Kafka Connect

Follow the steps in [Starting Kafka Connect with your connectors](../../setting-up-connectors/). When adding connectors, add the MQ connector JAR you downloaded, and when starting the connector, use the YAML file you created earlier.

Verify the log output of Kafka Connect includes the following messages that indicate the connector task has started and successfully connected to IBM MQ:
``` shell
$ oc logs <kafka_connect_pod_name>
...
INFO Created connector mq-source
...
INFO Connection to MQ established
...
```

## Send a test message

1. To add messages to the IBM MQ queue, run the `amqsput` sample and type in some messages:\\
   `/opt/mqm/samp/bin/amqsput <queue_name> <queue_manager_name>`
2. {{site.data.reuse.es_ui_login_nonadmin_mq}}
3. Click **Topics** in the primary navigation and select the connected topic. Messages will appear in the message browser of that topic.

## Advanced configuration

For more details about the connector and to see all configuration options, see the [GitHub README](https://github.com/ibm-messaging/kafka-connect-mq-source){:target="_blank"}.
