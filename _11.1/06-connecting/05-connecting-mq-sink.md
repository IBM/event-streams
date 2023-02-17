---
title: "Running the MQ sink connector"
# permalink: /connecting/mq/sink/
excerpt: "Running MQ sink connector"
categories: connecting/mq
slug: sink
toc: true
---

You can use the {{site.data.reuse.kafka-connect-mq-sink-short}} to copy data from {{site.data.reuse.long_name}} or Apache Kafka into IBM MQ. The connector copies messages from a Kafka topic into a target MQ queue.

Kafka Connect can be run in standalone or distributed mode. This document contains steps for running the connector in distributed mode in {{site.data.reuse.openshift_short}}. In this mode, work balancing is automatic, scaling is dynamic, and tasks and data are fault-tolerant. For more details on the difference between standalone and distributed mode see the [explanation of Kafka Connect workers](../../connectors/#workers).

## Prerequisites

To follow these instructions, ensure you have the following available:

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

For example, for a queue manager called `QM1`, with user ID `alice`, creating a server-connection channel called `MYSVRCONN` and a queue called `MYQSINK`, you run the following commands in `runmqsc`:
```
DEFINE CHANNEL(MYSVRCONN) CHLTYPE(SVRCONN)
SET CHLAUTH(MYSVRCONN) TYPE(BLOCKUSER) USERLIST('nobody')
SET CHLAUTH('*') TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(NOACCESS)
SET CHLAUTH(MYSVRCONN) TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(CHANNEL) CHCKCLNT(REQUIRED)
ALTER AUTHINFO(SYSTEM.DEFAULT.AUTHINFO.IDPWOS) AUTHTYPE(IDPWOS) ADOPTCTX(YES)
REFRESH SECURITY TYPE(CONNAUTH)
DEFINE QLOCAL(MYQSINK)
SET AUTHREC OBJTYPE(QMGR) PRINCIPAL('alice') AUTHADD(CONNECT,INQ)
SET AUTHREC PROFILE(MYQSINK) OBJTYPE(QUEUE) PRINCIPAL('alice') AUTHADD(ALLMQI)
END
```

The queue manager is now ready to accept connection from the connector and put messages on a queue.

## Configuring the connector to connect to MQ

To connect to IBM MQ and to your {{site.data.reuse.long_name}} or Apache Kafka cluster, the connector requires configuration settings added to a `KafkaConnector` custom resource that represents the connector.

For IBM MQ connectors, you can generate the `KafkaConnector` custom resource YAML file from either the {{site.data.reuse.short_name}} UI or the CLI. You can also use the CLI to generate a JSON file, which you can use in distributed mode where you supply the connector configuration through REST API calls.

The connector connects to IBM MQ using a client connection. You must provide the following connection information for your queue manager (these configuration settings are added to the `spec.config` section of the `KafkaConnector` custom resource YAML):
* Comma-separated list of Kafka topics to pull events from.
* The name of the IBM MQ queue manager.
* The connection name (one or more host and port pairs).
* The channel name.
* The name of the sink IBM MQ queue.
* The user name and password if the queue manager is configured to require them for client connections.

### Using the UI

Use the {{site.data.reuse.short_name}} UI to generate and download the `KafkaConnector` custom resource YAML file for your IBM MQ sink connector.

1. {{site.data.reuse.es_ui_login_nonadmin_mq}}
2. Click **Toolbox** in the primary navigation and scroll to the **Connectors** section.
3. Go to the **Add connectors to your Kafka Connect environment** tile and click **{{site.data.reuse.kafka-connect-connecting-to-mq}}**
5. Ensure the **MQ Sink** tab is selected and click **Generate**.
6. In the dialog, enter the configuration of the `MQ Sink` connector.
7. Click **Download** to generate and download the configuration file with the supplied fields.
8. Open the downloaded configuration file and change the values of `mq.user.name` and `mq.password` to the username and password that you used to configure your instance of MQ. Also set the label `eventstreams.ibm.com/cluster` to the name of your Kafka Connect instance.

### Using the CLI

Use the {{site.data.reuse.short_name}} CLI to generate and download the `KafkaConnector` custom resource YAML file for your IBM MQ sink connector. You can also use the CLI to generate a JSON file for distributed mode.

1. {{site.data.reuse.cp_cli_login}}
2. Run the following command to initialize the {{site.data.reuse.short_name}} CLI on the cluster:\\
   `cloudctl es init`
3. Run the `connector-config-mq-sink` command to generate the configuration file for the `MQ Sink` connector.\\
   For example, to generate a configuration file for an instance of `MQ` with the following information: a queue manager called `QM1`, with a connection point of `localhost(1414)`, a channel name of `MYSVRCONN`, a queue of `MYQSINK` and connecting to the topics `TSINK`, run the following command:
   ```
   cloudctl es connector-config-mq-sink --mq-queue-manager="QM1" --mq-connection-name-list="localhost(1414)" --mq-channel="MYSVRCONN" --mq-queue="MYQSINK" --topics="TSINK" --file="mq-sink" --format yaml
   ```
   **Note**: Omitting the `--format yaml` flag will generate a `mq-sink.properties` file which can be used for standalone mode. Specifying `--format json` will generate a `mq-sink.json` file which can be used for distributed mode outside {{site.data.reuse.openshift_short}}.
4. Change the values of `mq.user.name` and `mq.password` to the username and password that you used to configure your instance of MQ. Also set the label `eventstreams.ibm.com/cluster` to the name of your Kafka Connect instance.

The final configuration file will resemble the following:
```
apiVersion: eventstreams.ibm.com/v1beta2
kind: KafkaConnector
metadata:
  name: mq-sink
  labels:
    # The eventstreams.ibm.com/cluster label identifies the KafkaConnect instance
    # in which to create this connector. That KafkaConnect instance
    # must have the eventstreams.ibm.com/use-connector-resources annotation
    # set to true.
    eventstreams.ibm.com/cluster: <kafka_connect_name>
spec:
  class: com.ibm.eventstreams.connect.mqsink.MQSinkConnector
  tasksMax: 1
  config:
    topics: TSINK
    mq.queue.manager: QM1
    mq.connection.name.list: localhost(1414)
    mq.channel.name: MYSVRCONN
    mq.queue: MYQSINK
    mq.user.name: alice
    mq.password: passw0rd
    key.converter: org.apache.kafka.connect.storage.StringConverter
    value.converter: org.apache.kafka.connect.storage.StringConverter
    mq.message.builder: com.ibm.eventstreams.connect.mqsink.builders.DefaultMessageBuilder
```

A list of all the possible flags can be found by running the command `cloudctl es connector-config-mq-sink --help`. Alternatively, See the [sample properties file](https://github.com/ibm-messaging/kafka-connect-mq-sink/tree/master/config) for a full list of properties you can configure, and also see the [GitHub README](https://github.com/ibm-messaging/kafka-connect-mq-sink#readme){:target="_blank"} for all available configuration options.

## Downloading the MQ Sink connector

1. {{site.data.reuse.es_ui_login_nonadmin_mq}}
2. Click **Toolbox** in the primary navigation and scroll to the **Connectors** section.
3. Go to the **Add connectors to your Kafka Connect environment** tile and click **{{site.data.reuse.kafka-connect-connecting-to-mq}}**
4. Ensure the `MQ Sink` tab is selected and click **Go to GitHub**. Download the JAR file from the list of assets for the latest release.

## Configuring Kafka Connect

Follow the steps in [Set up a Kafka Connect environment](../../setting-up-connectors/). When adding connectors, add the MQ connector JAR you downloaded, and when starting the connector, use the YAML file you created earlier.

Verify the log output of Kafka Connect includes the following messages that indicate the connector task has started and successfully connected to IBM MQ:
``` shell
$ oc logs <kafka_connect_pod_name>
...
INFO Created connector mq-sink
...
INFO Connection to MQ established
...
```

## Send a test message

To test the connector you will need an application to produce events to your topic.

1. {{site.data.reuse.es_ui_login_nonadmin_mq}}
1. Click **Toolbox** in the primary navigation.
1. Go to the **Starter application** tile under **Applications**, and click **Get started**.
2. Click **Download JAR from GitHUb**. Download the JAR file from the list of assets for the latest release.
2. Click **Generate properties**.
1. Enter a name for the application.
1. Go to the **Existing topic** tab and select the topic you provided in the MQ connector configuration.
1. Click **Generate and download .zip**.
1. Follow the instructions in the UI to get the application running.

Verify the message is on the queue:

1. Navigate to the UI of the [sample application](../../../getting-started/generating-starter-app/) you generated earlier and start producing messages to {{site.data.reuse.long_name}}.
2. Use the `amqsget` sample to get messages from the MQ Queue:\\
   `/opt/mqm/samp/bin/amqsget <queue_name> <queue_manager_name>`\\
   After a short delay, the messages are printed.

## Advanced configuration

For more details about the connector and to see all configuration options, see the [GitHub README](https://github.com/ibm-messaging/kafka-connect-mq-sink#readme){:target="_blank"}.
