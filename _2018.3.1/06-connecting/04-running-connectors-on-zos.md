---
title: "Running connectors on IBM z/OS"
# permalink: /connecting/mq/zos/
excerpt: "Set up your Kafka Connect workers to run on IBM z/OS."
categories: connecting/mq
slug: zos
toc: true
---

You can use the IBM MQ connectors to connect into IBM MQ for z/OS, and you can run the connectors on z/OS as well, connecting into the queue manager using bindings mode.

Before you can run IBM MQ connectors on IBM z/OS, you must prepare your Kafka files and your system as follows.

## Setting up Kafka to run on IBM z/OS

You can run Kafka Connect workers on [IBM z/OS Unix System Services](https://www.ibm.com/support/knowledgecenter/SSLTBW_2.3.0/com.ibm.zos.v2r3.e0zc100/unixs.htm). To do so, you must ensure that the Kafka shell scripts and the Kafka Connect configuration files are converted to EBCDIC encoding.

### Download the files

Download Apache Kafka to a non-z/OS system to retrieve the `.tar` file that includes the Kafka shell scripts and configuration files.

To download the file and make it available to your z/OS system:
1. Log in to a system that is not running IBM z/OS, for example, a Linux system.
2. [Download](https://kafka.apache.org/downloads) Apache Kafka 2.0.0 or later to the system. {{site.data.reuse.long_name}} provides support for Kafka Connect if you are using a Kafka version listed in the **Kafka version shipped** column of the  [Support matrix]({{ 'support/#support-matrix' | relative_url }}).
3. Extract the downloaded `.tgz` file, for example:\\
   `gunzip -k kafka_2.11-2.0.0.tgz`
4. Copy the resulting `.tar` file to a directory on the z/OS Unix System Services.
5. Download and copy the connector `.properties` file to the z/OS System as well. Depending on the connector you want to use:\\
   - [Download the source connector files](../source/#downloading-the-connector)
   - [Download the sink connector files](../sink/#downloading-the-connector)

### Convert the files

If you want to run a standalone Kafka Connect worker, convert the following shell scripts from ISO8859-1 to EBCDIC encoding:
- `bin/connect-standalone.sh`
- `bin/kafka-run-class.sh`

If you want to run a distributed Kafka Connect worker, convert `bin/connect-distributed.sh` instead of `bin/connect-standalone.sh`.

To convert the files:
1. Log in to the IBM z/OS system and [access the Unix System Services](https://www.ibm.com/support/knowledgecenter/SSLTBW_2.3.0/com.ibm.zos.v2r3.aioc000/unixss.htm).
2. Change to an empty directory that you want to use for the Apache Kafka distribution, and copy the `.tar` file to the new directory.
3. Extract the `.tar` file, for example:\\
   `tar -xvf kafka_2.11-2.0.0.tar`
4. Change to the resulting `kafka_<version>` directory.
5. Copy the `connect-standalone.sh` shell script (or `connect-distributed.sh` for a distributed setup) into the current directory, for example:\\
   `cp bin/connect-standalone.sh ./connect-standalone.sh.orig`
5. Determine the codeset on the IBM z/OS system by running:\\
   `locale -k codeset`
5. Convert the script to EBCDIC encoding and replace the original, for example for codeset IBM-1047:\\
   `iconv -f ISO8859-1 -t IBM-1047 ./connect-standalone.sh.orig > bin/connect-standalone.sh`
6. Ensure the file permissions are set so that the script is executable, for example:\\
   `chmod +x bin/connect-standalone.sh`
7. Copy the `kafka-run-class.sh` shell script into the current directory, for example:\\
   `cp bin/kafka-run-class.sh ./kafka-run-class.sh.orig`
8. Convert the script to EBCDIC encoding and replace the original, for example for codeset IBM-1047:\\
   `iconv -f ISO8859-1 -t IBM-1047 ./kafka-run-class.sh.orig > bin/kafka-run-class.sh`
9. Ensure the file permissions are set so that the script is executable, for example:\\
   `chmod +x bin/kafka-run-class.sh`
10. Ensure that the worker and connector configuration files are also in EBCDIC encoding.\\
   If you are starting with files from the Kafka distribution, convert them by following the same steps as described here for the shell scripts.\\
   For example, if you want to use the {{site.data.reuse.kafka-connect-mq-source-short}} in a standalone setup, convert the `config/connect-standalone.properties` file from your Kafka distribution, and also convert your `mq-source.properties` file.\\
   If you are editing the files directly on z/OS, you are already using EBCDIC.

## Configuring the environment

The IBM MQ connectors use the JMS API to connect to MQ. You must set the environment variables required for JMS applications before running the connectors on IBM z/OS.

Ensure you set `CLASSPATH` to include `com.ibm.mq.allclient.jar`, and also set the JAR file for the connector you are using - this is the connector JAR file you downloaded from the {{site.data.reuse.short_name}} UI or built after cloning the GitHub project, for example, `kafka-connect-mq-source-1.0.1-jar-with-dependencies.jar`.

If you are using the bindings connection mode for the connector to connect to the queue manager, also set the following environment variables:

1. The `STEPLIB` used at run time must contain the IBM MQ `SCSQAUTH` and `SCSQANLE` libraries. Specify this library in the startup JCL, or specify it by using the `.profile` file.\\
   From UNIX and Linux System Services, you can add these using a line in your `.profile` file as shown in the following code snippet, replacing `thlqual` with the high-level data set qualifier that you chose when installing IBM MQ:\\
   ```
   export STEPLIB=thlqual.SCSQAUTH:thlqual.SCSQANLE:$STEPLIB
   ```
2. The connector needs to load a native library. Set `LIBPATH` to include the following directory of your MQ installation:\\
   ```
   <path_to_MQ_installation>/mqm/<MQ_version>/java/lib
   ```

The bindings connection mode is a configuration option for the connector as described in the [source connector GitHub README](https://github.com/ibm-messaging/kafka-connect-mq-source/blob/master/README.md#configuration) and in the [sink connector GitHub README](https://github.com/ibm-messaging/kafka-connect-mq-sink/blob/master/README.md#configuration).

## Starting Kafka Connect on z/OS

Kafka Connect is started using a bash script. If you do not already have bash installed on your z/OS system install it now.

To install bash version 4.2.53 or later:
1. Download the bash archive file from [Bash Version 4.2.53](https://www.rocketsoftware.com/product-categories/mainframe/bash-zos){:target="_blank"}
2. Extract the archive file to get the .tar file:\\
    `gzip -d bash.tar.gz`
3. FTP the .tar file to your z/OS USS directory such as `/bin`
4. Extract the .tar file to install bash:\\
   `tar -cvfo bash.tar`

If bash on your z/OS system is not in /bin you need to update the `kafka-run-class.sh` file. For example, if bash is located in `/usr/local/bin` update the first line of `kafka-run-class.sh` to have `#!/usr/local/bin/bash`

### Starting Kafka Connect in standalone mode

To start Kafka Connect in standalone mode navigate to your Kafka directory and run the `connect-standalone.sh` script, passing in your `connect-standalone.properties` and `mq-source.properties` or `mq-sink.properties`. For example:

```
cd kafka
./bin/connect-standalone.sh connect-standalone.properties mq-source.properties
```

For more details on creating the properties files see the [connecting MQ documentation](../../../connecting/mq). Make sure connection type is set to bindings mode.

### Starting Kafka Connect in distributed mode

To start Kafka Connect in distributed mode navigate to your Kafka directory and run the `connect-distributed.sh` script, passing in your `connect-distributed.properties`. Unlike in standalone mode, MQ properties are not passed in on startup. For example:

```
cd kafka
./bin/connect-distributed.sh connect-distributed.properties
```

To start an individual connector use the [Kafka Connect REST API](https://kafka.apache.org/documentation/#connect_rest). For example, given a configuration file `mq-source.json` with the following contents:
```
{
    "name":"mq-source",
        "config" : {
            "connector.class":"com.ibm.eventstreams.connect.mqsource.MQSourceConnector",
            "tasks.max":"1",
            "mq.queue.manager":"QM1",
            "mq.connection.mode":"bindings",
            "mq.queue":"MYQSOURCE",
            "mq.record.builder":"com.ibm.eventstreams.connect.mqsource.builders.DefaultRecordBuilder",
            "topic":"test",
            "key.converter":"org.apache.kafka.connect.storage.StringConverter",
            "value.converter":"org.apache.kafka.connect.converters.ByteArrayConverter"
        }
    }
```

start the connector using:
```
curl -X POST http://localhost:8083/connectors -H "Content-Type: application/json" -d @mq-source.json
```

## Advanced configuration

For more details about the connectors and to see all configuration options, see the [source connector GitHub README](https://github.com/ibm-messaging/kafka-connect-mq-source){:target="_blank"} or [sink connector GitHub README](https://github.com/ibm-messaging/kafka-connect-mq-sink){:target="_blank"}.
