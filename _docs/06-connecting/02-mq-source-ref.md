---
title: "Reference for Kafka Connect source connector for IBM MQ"
permalink: /connecting/mq-source-reference/
excerpt: "Reference material for Kafka Connect source connector for IBM MQ."
last_modified_at: 
toc: true
---

## Data formats
Kafka Connect is very flexible but it is important to understand the way that it processes messages to create a reliable system. When the connector encounters a message that it cannot process, it stops rather than throwing the message away. Therefore, ensure that the configuration you use can handle the messages the connector will process.

Each message in Kafka Connect is associated with a representation of the message format known as a *schema*. Each Kafka message has two parts, key and value, and each part has its own schema. The {{site.data.reuse.kafka-connect-mq-source}} does not currently make much use of message keys, but some of the configuration options use the word *Value* because they refer to the Kafka message value.

When the connector reads a message from MQ, it chooses a schema to represent the message format, and creates an internal object called a *record* which contains the message value. This conversion is performed using a *record builder*.  Each record is then processed using a *converter* which creates the message that is published on a Kafka topic.

There are two record builders supplied with the connector. You can also write your own. If you just want the message to be passed along to Kafka unchanged, use the default record builder. If the incoming data is in JSON format and you want to use a schema based on its structure, use the JSON record builder.

There are three converters built into Apache Kafka. Ensure that the incoming message format, the setting of the *mq.message.body.jms* configuration, the record builder, and converter are all compatible. By default, everything is treated as bytes, but if you want the connector to understand the message format and apply more sophisticated processing such as single-message transforms, you will need a more complex configuration. The following table shows the basic options.

| Record builder class                                                | Incoming MQ message    | mq.message.body.jms | Converter class                                        | Outgoing Kafka message  |
| ------------------------------------------------------------------- | ---------------------- | ------------------- | ------------------------------------------------------ | ----------------------- |
| com.ibm.eventstreams.connect.mqsource.builders.DefaultRecordBuilder | Any                    | false (default)     | org.apache.kafka.connect.converters.ByteArrayConverter | **Binary data**         |
| com.ibm.eventstreams.connect.mqsource.builders.DefaultRecordBuilder | JMS BytesMessage       | true                | org.apache.kafka.connect.converters.ByteArrayConverter | **Binary data**         |
| com.ibm.eventstreams.connect.mqsource.builders.DefaultRecordBuilder | JMS TextMessage        | true                | org.apache.kafka.connect.storage.StringConverter       | **String data**         |
| com.ibm.eventstreams.connect.mqsource.builders.JsonRecordBuilder    | JSON, may have schema  | Not used            | org.apache.kafka.connect.json.JsonConverter            | **JSON, no schema**     |

No single configuration is universally applicable, the settings depend on requirements. The following are some high-level configuration examples.

* Pass unchanged binary (or string) data as the Kafka message value
```
value.converter=org.apache.kafka.connect.converters.ByteArrayConverter
```
* Message format is MQSTR, pass string data as the Kafka message value
```
mq.message.body.jms=true
value.converter=org.apache.kafka.connect.converters.StringConverter
```
* Messages are JMS BytesMessage, pass byte array as the Kafka message value
```
mq.message.body.jms=true
value.converter=org.apache.kafka.connect.converters.ByteArrayConverter
```
* Messages are JMS TextMessage, pass string data as the Kafka message value
```
mq.message.body.jms=true
value.converter=org.apache.kafka.connect.storage.StringConverter
```

### How it works
The messages received from MQ are processed by a record builder which builds a Kafka Connect record to represent the message. There are two record builders supplied with the connector. The connector has a configuration option *mq.message.body.jms* that controls whether it interprets the MQ messages as JMS messages or regular MQ messages. The following table provides details about the record builders.

| Record builder class                                                | mq.message.body.jms | Incoming message body | Value schema       | Value class        |
| ------------------------------------------------------------------- | ------------------- | --------------------- | ------------------ | ------------------ |
| com.ibm.eventstreams.connect.mqsource.builders.DefaultRecordBuilder | false (default)     | Any                   | OPTIONAL_BYTES     | byte[]             |
| com.ibm.eventstreams.connect.mqsource.builders.DefaultRecordBuilder | true                | JMS BytesMessage      | null               | byte[]             |
| com.ibm.eventstreams.connect.mqsource.builders.DefaultRecordBuilder | true                | JMS TextMessage       | null               | String             |
| com.ibm.eventstreams.connect.mqsource.builders.DefaultRecordBuilder | true                | Everything else       | *EXCEPTION*        | *EXCEPTION*        |
| com.ibm.eventstreams.connect.mqsource.builders.JsonRecordBuilder    | Not used            | JSON                  | Depends on message | Depends on message |

You must then choose a converter than can handle the value schema and class. There are three basic converters built into Apache Kafka, with possible combinations in **bold**. The following table describnes the converters.

| Converter class                                        | Output for byte[]   | Output for String | Output for compound schema |
| ------------------------------------------------------ | ------------------- | ----------------- | -------------------------- |
| org.apache.kafka.connect.converters.ByteArrayConverter | **Binary data**     | *EXCEPTION*       | *EXCEPTION*                |
| org.apache.kafka.connect.storage.StringConverter       | Works, not useful   | **String data**   | Works, not useful          |
| org.apache.kafka.connect.json.JsonConverter            | Base-64 JSON String | JSON String       | **JSON data**              |

### Key support and partitioning
By default, the connector does not use keys for the Kafka messages it publishes. It can be configured to use the JMS message headers to set the key of the Kafka records. You can use this, for example, to use the MQMD correlation identifier as the partitioning key when the messages are published to Kafka. There are three valid values for the `mq.record.builder.key.header` that controls this behavior, as described in the following table.

| mq.record.builder.key.header | Key schema      | Key class | Recommended value for key.converter                    |
| ---------------------------- |---------------- | --------- | ------------------------------------------------------ |
| JMSMessageID                 | OPTIONAL_STRING | String    | org.apache.kafka.connect.storage.StringConverter       |
| JMSCorrelationID             | OPTIONAL_STRING | String    | org.apache.kafka.connect.storage.StringConverter       |
| JMSCorrelationIDAsBytes      | OPTIONAL_BYTES  | byte[]    | org.apache.kafka.connect.converters.ByteArrayConverter |

In MQ, the message ID and correlation ID are both 24-byte arrays. As strings, the connector represents them using a sequence of 48 hexadecimal characters.

## Security

The connector supports authentication with user name and password and also connections secured with TLS using a server-side certificate and mutual authentication with client-side certificates.

### Setting up MQ connectivity using TLS with a server-side certificate

To enable use of TLS, set the configuration `mq.ssl.cipher.suite` to the name of the cipher suite which matches the CipherSpec in the SSLCIPH attribute of the MQ server-connection channel. [Use the table of supported cipher suites](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_9.0.0/com.ibm.mq.dev.doc/q113220_.htm) for MQ 9.0.x as a reference.

**Note:** The names of the CipherSpecs as used in the MQ configuration are not necessarily the same as the cipher suite names that the connector uses. The connector uses the JMS interface as it follows the Java conventions.

You will need to put the public part of the queue manager's certificate in the JSSE truststore used by the Kafka Connect worker that you are using to run the connector. If you need to specify extra arguments to the worker's JVM, you can use the `EXTRA_ARGS` environment variable.

### Setting up MQ connectivity using TLS for mutual authentication

You will need to put the public part of the client's certificate in the queue manager's key repository. You will also need to configure the worker's JVM with the location and password for the keystore containing the client's certificate.

### Troubleshooting

For troubleshooting, or to better understand the handshake performed by the IBM MQ Java client application in combination with your specific JSSE provider, you can enable debugging by setting `javax.net.debug=ssl` in the JVM environment.

## Configuration options

The following table lists the configuration options you can set in the connector properties file.

| Property Name                         | Description                                                 | Type    | Default       | Valid values                                            |
| ---------------------------- | ----------------------------------------------------------- | ------- | ------------- | ------------------------------------------------------- |
| mq.queue.manager             | The name of the MQ queue manager                            | string  |               | MQ queue manager name                                   |
| mq.connection.name.list      | List of connection names for queue manager                  | string  |               | host(port)[,host(port),...]                             |
| mq.channel.name              | The name of the server-connection channel                   | string  |               | MQ channel name                                         |
| mq.queue                     | The name of the source MQ queue                             | string  |               | MQ queue name                                           |
| mq.user.name                 | The user name for authenticating with the queue manager     | string  |               | User name                                               |
| mq.password                  | The password for authenticating with the queue manager      | string  |               | Password                                                |
| mq.record.builder            | The class used to build the Kafka Connect record            | string  |               | Class implementing RecordBuilder                        |
| mq.message.body.jms          | Whether to interpret the message body as a JMS message type | boolean | false         |                                                         |
| mq.record.builder.key.header | The JMS message header to use as the Kafka record key       | string  |               | JMSMessageID, JMSCorrelationID, JMSCorrelationIDAsBytes |
| mq.ssl.cipher.suite          | The name of the cipher suite for TLS (SSL) connection       | string  |               | Blank or valid cipher suite                             |
| mq.ssl.peer.name             | The distinguished name pattern of the TLS (SSL) peer        | string  |               | Blank or DN pattern                                     |
| topic                        | The name of the target Kafka topic                          | string  |               | Topic name                                              |
