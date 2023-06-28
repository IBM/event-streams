---
title: "Creating and testing message loads"
excerpt: "Use the producer application as a workload generator to test message loads."
categories: getting-started
slug: testing-loads
layout: redirects
toc: true
---

{{site.data.reuse.long_name}} provides a high-throughput producer application you can use as a workload generator to test message loads and help validate the performance capabilities of your cluster.

You can use one of the predefined load sizes, or you can specify your own settings to test throughput. Then use the test results to ensure your cluster setup is appropriate for your requirements, or make changes as needed, for example, by changing your [scaling settings](../../administering/scaling/).


## Downloading

You can [download the latest pre-built producer](https://github.com/IBM/event-streams-sample-producer/releases){:target="_blank"} application.

Alternatively, you can [clone the project from GitHub](https://github.com/IBM/event-streams-sample-producer){:target="_blank"}. However, if you clone from GitHub, you have to [build the producer](#building).


## Building

If you cloned the Git repository, build the producer as follows:

1. {{site.data.reuse.maven_prereq}}
2. Ensure you have [cloned the Git project](https://github.com/IBM/event-streams-sample-producer){:target="_blank"}.
3. Open a terminal and change to the root directory of the `event-streams-sample-producer` project.
4. Run the following command: `mvn install`.\\
   You can also specify your root directory using the `-f` option as follows `mvn install -f <path_to>/pom.xml`
5. The `es-producer.jar` file is created in the `/target` directory.


## Configuring

The producer application requires configuration settings that you can set in the provided `producer.config` template configuration file.

**Note:** The `producer.config` file is located in the root directory. If you downloaded the pre-built producer, you have to run the `es-producer.jar` with the `-g` option to generate the configuration file. If you build the producer application yourself, the configuration file is created and placed in the root for you when building.

Before running the producer to test loads, you must specify the `bootstrap.servers` and any required security configuration details in the configuration file.

### Obtaining configuration details

The bootstrap servers address can be obtained from the {{site.data.reuse.short_name}} UI as described in the following steps. Other methods to obtain the bootstrap servers address are described in [connecting client](../connecting/).

1. {{site.data.reuse.es_ui_login_nonadmin}}
2. Click **Connect to this cluster** on the right.
3. Click the **Resources** tab.
4. Go to the **Kafka listener and credentials** section.
5. Copy the address from one of the **External** listeners.

The producer application might require credentials for the listener chosen in the previous step. For more information about these credentials, see the information about [managing access](../../security/managing-access/).

Obtain the required credentials as follows:
1. {{site.data.reuse.es_ui_login_nonadmin}}
2. Click **Connect to this cluster** on the right.
3. Go to the **Resources** tab.
4. Scroll down to the **Kafka listener and credentials** section.
5. Click the button next to the listener chosen as the `bootrap.servers` configuration. If present, the button will either be labelled **Generate SCRAM credentials** or **Generate TLS credentials**.
6. Select **Produce messages, consume messages and create topics and schemas** and click **Next**.
7. Select **A specific topic**, enter the name of a topic to produce to and click **Next**.
8. Select **All consumer groups** and click **Next**.
9. Select **No transactional IDs** and click **Generate credentials**.
10. Retrieve the generated credentials:\\
   - If using SCRAM note down the **Username and password**.
   - If using TLS click **Download certificates** and extract the contents of the resulting .zip file to a preferred location.

Obtain the {{site.data.reuse.short_name}} certificate as follows:
1. {{site.data.reuse.es_ui_login_nonadmin}}
2. Click **Connect to this cluster** on the right.
3. Go to the **Resources** tab.
5. Scroll down to the **Certificates** section.
6. In the **PKCS12 certificate** section click **Download certificate**.
7. Note down the generated password displayed in the **Certificate password** section.

### Updating the configuration file

Before updating the file, obtain the credentials by following the steps in [Obtaining configuration details](#obtaining-configuration-details).

Update the `producer.config` file with your configuration details using the following table as guidance.

| Attribute                               | Description                                                                                                            |
| -------------------------------------   | ---------------------------------------------------------------------------------------------------------------------- |
| `bootstrap.servers`                     | The bootstrap address for the chosen external listener.  |                                              |
| `security.protocol`                     | Set to `SSL`. Can be ommitted if the chosen external listener has TLS disabled.   |
| `ssl.truststore.location`               | The full path and name of the {{site.data.reuse.short_name}} PKCS12 certificate file. Can be ommitted if the chosen external listener has TLS disabled.        |
| `ssl.truststore.password`               | The password for the {{site.data.reuse.short_name}} PKCS12 certificate file. Can be ommitted if the chosen external listener has TLS disabled.        |
| `sasl.mechanism`                        | Set to `SCRAM-SHA-512` if using SCRAM credentials, otherwise ommitted.   |
| `sasl.jaas.config`                      | Set to `org.apache.kafka.common.security.scram.ScramLoginModule required username="<username>" password="<password>";`, where `<username>` and `<password>` are replaced with the SCRAM credentials. Omitted if not using SCRAM credentials.    |
| `ssl.keystore.location`                 | Set to the full path and name of the `user.p12` keystore file downloaded from the {{site.data.reuse.short_name}} UI. Ommitted if not using TLS credentials.   |
| `ssl.keystore.password`                 | Set to the password listed in the `user.password` file downloaded from the {{site.data.reuse.short_name}} UI. Ommitted if not using TLS credentials.       |

## Running

Create a load on your {{site.data.reuse.long_name}} Kafka cluster by running the `es-producer.jar` command. You can specify the load size based on the provided predefined values, or you can provide specific values for throughput and total messages to determine a custom load.

### Using predefined loads

To use a predefined load size from the producer application, use the `es-producer.jar` with the `-s` option:

`java -jar target/es-producer.jar -t <topic-name> -s <small/medium/large>`

For example, to create a `large` message load based on the predefined `large` load size, run the command as follows:

`java -jar target/es-producer.jar -t my-topic -s large`

This example creates a `large` message load, where the producer attempts to send a total of 6,000,000 messages at a rate of 100,000 messages per second to the topic called `my-topic`.

The following table lists the predefined load sizes the producer application provides.

Size     | Messages per second | Total messages |
-------- | ------------------- | -------------- |
`small`  | 1000                | 60,000         |
`medium` | 10,000              | 600,000        |
`large`  | 100,000             | 6,000,000      |

### Specifying a load

You can generate a custom message load using your own settings.

For example, to test the load to the topic called `my-topic` with custom settings that create a total load of `60,000` **messages** with a **size of 1024 bytes each**, at a **maximum throughput rate of 1000 messages per second**, use the `es-producer.jar` command as follows:

```
java -jar target/es-producer.jar -t my-topic -T 1000 -n 60000 -r 1024
```

The following table lists all the parameter options for the `es-producer.jar` command.

| Parameter             | Shorthand | Longhand              | Type     | Description                                                                                                                               | Default          |
| --------------------- | --------- | --------------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| Topic                 | -t        | --topic               | string   | The name of the topic to send the produced message load to.                                                                                                       | `loadtest`       |
| Num Records           | -n        | --num-records         | integer  | The total number of messages to be sent as part of the load. **Note:** The `--size` option overrides this value if used together.                                                                                    | `60000`          |
| Payload File          | -f        | --payload-file        | string   | File to read the message payloads from. This works only for UTF-8 encoded text files. Payloads are read from this  file and a payload is randomly selected when sending messages. |   |
| Payload Delimiter     | -d        | --payload-delimiter   | string   | Provides delimiter to be used when `--payload-file` is provided. This parameter is ignored if `--payload-file` is not provided. | `\n`             |
| Throughput            | -T        | --throughput          | integer  | Throttle maximum message throughput to *approximately* *THROUGHPUT* messages per second. -1 sets it to as fast as possible. **Note:** The `--size` option overrides this value if used together.                   | `-1`             |
| Producer Config       | -c        | --producer-config     | string   | Path to the producer configuration file.                                                                                                       | `producer.config`|
| Print Metrics         | -m        | --print-metrics       | boolean  | Set whether to print out metrics at the end of the test.                                                                                       | `false`          |
| Num Threads           | -x        | --num-threads         | integer  | The number of producer threads to run.                                                                                                     | `1`              |
| Size                  | -s        | --size                | string   | Pre-defined combinations of message throughput and volume. If used, this option overrides any settings specified by the `--num-records` and `--throughput` options.                   |                  |
| Record Size           | -r        | --record-size         | integer  | The size of each message to be sent in bytes.                                                                                              | `100`            |
| Help                  | -h        | --help                | N/A      | Lists the available parameters.                                                                                                            |                  |
| Gen Config            | -g        | --gen-config          | N/A      | Generates the configuration file required to run the tool (`producer.config`).                                                                                 |                  |


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
