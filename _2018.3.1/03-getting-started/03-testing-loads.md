---
title: "Creating and testing message loads "
excerpt: "Use the producer application as a workload generator to test message loads."
categories: getting-started
slug: testing-loads
toc: true
---

{{site.data.reuse.long_name}} provides a high-throughput producer application you can use as a workload generator to test message loads and help validate the performance capabilities of your cluster.

You can use one of the predefined load sizes, or you can specify your own settings to test throughput. Then use the test results to ensure your cluster setup is appropriate for your requirements, or make changes as needed, for example, by changing your [scaling settings](../../administering/scaling/).

## Downloading

You can [download the latest pre-built producer](https://github.com/IBM/event-streams-sample-producer/releases) application.

Alternatively, you can [clone the project from GitHub](https://github.com/IBM/event-streams-sample-producer). However, if you clone from GitHub, you have to [build the producer](#building).

## Building

If you cloned the Git repository, build the producer as follows:

1. {{site.data.reuse.maven_prereq}}
2. Ensure you have [cloned the Git project](https://github.com/IBM/event-streams-sample-producer).
3. Open a terminal and change to the root directory.
4. Run the following command: `mvn install`.\\
   You can also specify your root directory using the `-f` option as follows `mvn install -f <path_to>/pom.xml`
5. The `es-producer.jar` file is created in the `/target` directory.

## Configuring

The producer application requires configuration settings that you can set in the provided `producer.config` template configuration file.

**Note:** The `producer.config` file is located in the root directory. If you downloaded the pre-built producer, you have to run the `es-producer.jar` with the `-g` option to generate the configuration file. If you build the producer application yourself, the configuration file is created and placed in the root for you when building.

Before running the producer to test loads, you must specify the following details in the configuration file.

| Attribute                             | Description                                                                                                            |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `bootstrap.servers`                     | The URL used for bootstrapping knowledge about the rest of the cluster. You can find this address in the {{site.data.reuse.short_name}} UI as described [later](#obtaining-configuration-details).  |                                              |
| `ssl.truststore.location`               | The location of the JKS keystore used to securley communicate with your {{site.data.reuse.long_name}} instance. You can downloaded the JKS keystore file from the {{site.data.reuse.short_name}} UI as described [later](#obtaining-configuration-details).        |
| `sasl.jaas.config`                      | Set to `org.apache.kafka.common.security.plain.PlainLoginModule required username="token" password="<password>";`, where `<password>` is replaced by an API key. This is needed to authorize production to your topic. To generate API keys, go to the {{site.data.reuse.short_name}} UI as described [later](#obtaining-configuration-details).        |

### Obtaining configuration details

![Event Streams 2018.3.1 icon](../../../images/2018.3.1.svg "In Event Streams 2018.3.1.") In {{site.data.reuse.long_name}} 2018.3.1, obtain the required configuration details as follows:
1. Log in to your {{site.data.reuse.long_name}} UI.
2. Click **Connect to this cluster** on the right.
3. Go to the **Connect a client** tab.
4. Locate the details:\\
   - For the `bootstrap.servers`, copy the address from the **Bootstrap server** section.
   - To downloaded the JKS keystore file, go to the **Certificates** section, and download the server certificate from the **Java truststore** section. Set the `ssl.truststore.location` to the full path and name of the downloaded file.
   - To generate API keys, go to the **API key** section and follow the instructions.


![Event Streams 2018.3.0 icon](../../../images/2018.3.0.svg "In Event Streams 2018.3.0.") In {{site.data.reuse.long_name}} 2018.3.0, obtain the required configuration details as follows:
1. Log in to your {{site.data.reuse.long_name}} UI.
2. Click the **Topics** tab to view the topic list, click the name of a topic.
3. Click the **Connection information** tab.
4. Locate the details:\\
    - For the `bootstrap.servers`, copy the address from the **Broker URL** field.
    - To downloaded the JKS keystore file, go to the **Certificates** section and click **Download Java truststore**. Set the `ssl.truststore.location` to the full path and name of the downloaded file.
    - To generate API keys, go to the **Credentials and access control** section and follow the instructions.

**Important:** To have access to the **Connection information** tab in the UI, you must have at least one topic. For example, if you are just starting out, use the [starter application to generate topics](../generating-starter-app/).

You can secure access to your topics as described in [managing access](../../security/managing-access/).

## Running

Create a load on your {{site.data.reuse.long_name}} Kafka cluster by running the `es-producer.jar` command. You can specify the load size based on the provided predefined values, or you can provide specific values for throughput and total messages to determine a custom load.

### Using predefined loads

To use a predefined load size from the producer application, use the `es-producer.jar` with the `-s` option:

`java -jar target/es-producer.jar -t <topic-name> -s <small/medium/large>`

For example, to create a `large` message load based on the predefined `large` load size, run the command as follows:

`java -jar target/es-producer.jar -t myTopic -s large`

This example creates a `large` message load, where the producer attempts to send a total of 6,000,000 messages at a rate of 100,000 messages per second to the topic called `myTopic`.

The following table lists the predefined load sizes the producer application provides.

Size  | Messages per second  | Total messages
--|---|--
`small`  | 1000  | 60,000
`medium`  | 10,000  | 600,000
`large`  | 100,000  | 6,000,000

### Using user-defined loads

You can generate a custom message load using your own settings.

For example, to test the load to the topic called `myTopic` with custom settings that create a total load of 60,000 messages with a size of 1024 bytes each, at a maximum throughput rate of 1000 messages per second, use the `es-producer.jar` command as follows:

`java -jar target/es-producer.jar -t myTopic -T 1000 -n 60000 -r 1024`

The following table lists all the parameter options for the `es-producer.jar` command.

| Parameter             | Shorthand | Longhand              | Type     | Description                                                                                                                               | Default          |
| --------------------- | --------- | --------------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| Topic                 | -t        | --topic               | `string` | The name of the topic to send the produced message load to.                                                                                                       | `loadtest`       |
| Num Records           | -n        | --num-records         | `int`    | The total number of messages to be sent as part of the load. **Note:** The `--size` option overrides this value if used together.                                                                                    | `60000`          |
| Payload File          | -f        | --payload-file        | `string` | File to read the message payloads from. This works only for UTF-8 encoded text files. Payloads are read from this  file and a payload is randomly selected when sending messages. |   |
| Payload Delimiter     | -d        | --payload-delimiter   | `string` | Provides delimiter to be used when `--payload-file` is provided. This parameter is ignored if `--payload-file` is not provided. | `\n`             |
| Throughput            | -T        | --throughput          | `int`    | Throttle maximum message throughput to *approximately* *THROUGHPUT* messages per second. -1 sets it to as fast as possible. **Note:** The `--size` option overrides this value if used together.                   | `-1`             |
| Producer Config       | -c        | --producer-config     | `string` | Path to the producer configuration file.                                                                                                       | `producer.config`|
| Print Metrics         | -m        | --print-metrics       | `bool`   | Set whether to print out metrics at the end of the test.                                                                                       | `false`          |
| Num Threads           | -x        | --num-threads         | `int`    | The number of producer threads to run.                                                                                                     | `1`              |
| Size                  | -s        | --size                | `string` | Pre-defined combinations of message throughput and volume. If used, this option overrides any settings specified by the `--num-records` and `--throughput` options.                   |                  |
| Record Size           | -r        | --record-size         | `int`    | The size of each message to be sent in bytes.                                                                                              | `100`            |
| Help                  | -h        | --help                | `N/A`    | Lists the available parameters.                                                                                                            |                  |
| Gen Config            | -g        | --gen-config          | `N/A`    | Generates the configuration file required to run the tool (`producer.config`).                                                                                 |                  |


**Note:** You can override the parameter values by using the environment variables listed in the following table. This is useful, for example, when using containerization, and you are unable to specify parameters on the command line.

| Parameter             | Environment Variable |
| --------------------- | -------------------- |
| Throughput            | ES_THROUGHPUT        |
| Num Records           | ES_NUM_RECORDS       |
| Size                  | ES_SIZE              |
| Record Size           | ES_RECORD_SIZE       |
| Topic                 | ES_TOPIC             |
| Num threads           | ES_NUM_THREADS       |
| Producer Config       | ES_PRODUCER_CONFIG   |
| Payload File          | ES_PAYLOAD_FILE      |
| Payload Delimiter     | ES_PAYLOAD_DELIMITER |

**Note:** If you set the size using `-s` when running `es-producer.jar`, you can only override it if both the `ES_NUM_RECORDS` and `ES_THROUGHPUT` environment variables are set, or if `ES_SIZE` is set.
