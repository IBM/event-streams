---
title: "Setting Java applications to use schemas"
excerpt: "Set up your Java applications to use schemas."
categories: schemas
slug: setting-java-apps
toc: true
---

If you have Kafka producer or consumer applications written in Java, use the following guidance to set them up to use schemas.

**Note:** If you have Kafka clients written in other languages than Java, see the guidance about [setting up non-Java applications](../setting-nonjava-apps) to use schemas.

## Preparing the setup

To use schemas stored in the {{site.data.reuse.short_name}} schema registry, your client applications need to be able to serialize and deserialize messages based on schemas.

- Producing applications use a serializer to produce messages conforming to a specific schema, and use unique identifiers in the message headers to determine which schema is being used.
- Consuming application then use a deserializer to consume messages that have been serialized using the same schema. The schema is retrieved from the schema registry based on the unique identifiers in the message headers.

The {{site.data.reuse.short_name}} UI provides help with setting up your Java applications to use schemas.

To set up your Java applications to use the {{site.data.reuse.short_name}} schemas and schema registry, prepare the connection for your application as follows:


1. Ensure you have [added schemas](../creating) to the registry.
2. {{site.data.reuse.es_ui_login}}
3. Click the **Schemas** tab.
4. Select a schema from the list and click the row for the schema.
5. Click **Connect to the latest version**. Alternatively, if you want to use a different version of the schema, click the row for the schema version, and click **Connect to this version**.
6. Set the preferences for your connection in the **Configure the schema connection** section. Use the defaults or change them by clicking **Change configuration**.\\
   - For producers, set the method for **Message encoding**.

      - **Binary** (default): Binary-encoded messages are smaller and typically quicker to process. However the message data is not human-readable without an application that is able to apply the schema.
      - **JSON**: JSON-encoded messages are human-readable and can still be used by consumers that are not using the IBM Event Streams schema registry.

   - For consumers, set the **Message deserialization behavior** for the behavior to use when an application encounters messages that do not conform to the schema.

      - **Strict** (default): Strict behavior means the message deserializer will fail to process non-conforming messages, throwing an exception if one is encountered.
      - **Permissive**: Permissive behavior means the message deserializer will return a null message when a non-conforming message is encountered. It will not throw an exception, and so allow a Kafka consumer to continue to process further messages.

   - For both producers and consumers, set in the **Use generated or generic code** section whether your schema is to use custom Java classes that are generated based on the schema, or generic code by using the Apache Avro API.

     - **Use schema-specific code** (default): Your application will use custom Java classes that are generated based on this schema, using get and set methods to create and access objects. When you want to use a different schema, you will need to update your code to use a new set of specific schema Java classes.
     - **Use generic Apache Avro schema code**: Your application will create and access objects using the generic Apache Avro API. Producers and consumers that use the generic serializer and deserializer can be coded to produce or consume messages using any schema uploaded to this schema registry.

7. Go to the **Provide an API key** section and enter an API key with the correct permissions for your purposes (for example, to be able to produce, consume, or both). Alternatively, create one now by clicking **Generate API key**, and follow the instructions.\\
   The API key grants your application access to the cluster and its resources.
8. Click **Generate connection details**.
9. Click **Download** to download the Java truststore file which contains the server certificate.
10. Click **Java dependencies** to download the {{site.data.reuse.short_name}} schema registry JAR files, and click **Schema JAR** to download the schema JAR file to use for your application in its code.\\
   Alternatively, if you are using Maven, click the **Use Maven** tab. Follow the instructions to copy the configuration snippets for the {{site.data.reuse.short_name}} Maven repository to your project Maven POM file, and run the Maven install command to download and install project dependencies.
11. Depending on your application, click the **Producer code** or **Consumer code** tab, and copy the sample Java code snippets displayed. The sample code snippets include the settings you configured to set up your applications to use the schema.\\
   <!--Replace the `<Java_truststore_file_location>` with the path to the Java truststore file you downloaded earlier, `<my_topic>` with a topic name, and `<my_consumer_group>` with a consumer group name.-->
12. Add the snippets into your application code as described in the following sections.

## Setting up producers to use schemas

1. Ensure you have [prepared](#preparing-the-setup) for the setup, including configuring connection settings, downloading Java dependencies and schema JAR files, and copying code snippets for a producing application.
2. Ensure you add the location of the JAR files to the build path of your producer Kafka application.
3. Use the code snippets from the UI and add them to your application code.

The code snippet from the **Imports** section includes Java imports to paste into your class, and sets the up the application to use the {{site.data.reuse.short_name}} schema registry serdes library and any generated schema-specific classes, for example:

```
import java.util.Properties;

// Import the specific schema class
import com.mycompany.schemas.ABC_Assets_Schema;

import org.apache.kafka.clients.CommonClientConfigs;
import org.apache.kafka.common.config.SaslConfigs;
import org.apache.kafka.common.config.SslConfigs;
import com.ibm.eventstreams.serdes.SchemaRegistryConfig;
import com.ibm.eventstreams.serdes.SchemaInfo;
import com.ibm.eventstreams.serdes.SchemaRegistry;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;

```

The code snippet from the **Connection properties** section specifies connection and access permission details to your {{site.data.reuse.short_name}} cluster, for example:

```
Properties props = new Properties();
props.put(CommonClientConfigs.BOOTSTRAP_SERVERS_CONFIG, "192.0.2.171:30342");
props.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
props.put(SslConfigs.SSL_PROTOCOL_CONFIG, "TLSv1.2");
props.put(SslConfigs.SSL_TRUSTSTORE_LOCATION_CONFIG, <Java_truststore_file_location>);
props.put(SslConfigs.SSL_TRUSTSTORE_PASSWORD_CONFIG, "password");
props.put(SaslConfigs.SASL_MECHANISM, "PLAIN");
String saslJaasConfig = "org.apache.kafka.common.security.plain.PlainLoginModule required "
    + "username=\"token\" password=\"<api_key>";";
props.put(SaslConfigs.SASL_JAAS_CONFIG, saslJaasConfig);

props.put(SchemaRegistryConfig.PROPERTY_API_URL, "https://192.0.2.171:30546");
props.put(SchemaRegistryConfig.PROPERTY_API_SKIP_SSL_VALIDATION, true);
```

**Note:** Replace the `<Java_truststore_file_location>` with the path to the Java truststore file you downloaded earlier and replace `<api_key>` with an API key which has the permissions needed for your application.

The values are filled in as part of the process of preparing for the setup, setting the correct Kafka configuration properties, including settings such as the API endpoint of your {{site.data.reuse.short_name}} installation `PROPERTY_API_URL`.

For more information about the {{site.data.reuse.short_name}} schema registry configuration keys and values, see the `SchemaRegistryConfig` class in the [schema API reference](../../schema-api/){:target="_blank"}.

The code snippet from the **Producer code** section defines properties for the producer application that set it to use the schema registry and the correct schema, for example:

```
// Set the value serializer for produced messages to use the Event Streams serializer
props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
props.put("value.serializer", "com.ibm.eventstreams.serdes.EventStreamsSerializer");

// Set the encoding type used by the message serializer
props.put(SchemaRegistryConfig.PROPERTY_ENCODING_TYPE, SchemaRegistryConfig.ENCODING_BINARY);

// Get a new connection to the Schema Registry
SchemaRegistry schemaRegistry = new SchemaRegistry(props);

// Get the schema from the registry
SchemaInfo schema = schemaRegistry.getSchema("ABC_Assets_Schema", "1.0.0");

// Get a new specific KafkaProducer
KafkaProducer<String, ABC_Assets_Schema> producer = new KafkaProducer<>(props);

// Get a new specific record based on the schema
ABC_Assets_Schema specificRecord = new ABC_Assets_Schema();

// Add fields and values to the specific record, for example:
// specificRecord.setTitle("this is the value for a title field");

// Prepare the record, adding the Schema Registry headers
ProducerRecord<String, ABC_Assets_Schema> producerRecord =
    new ProducerRecord<String, ABC_Assets_Schema>(<my_topic>, specificRecord);

producerRecord.headers().add(SchemaRegistryConfig.HEADER_SCHEMA_ID,
    schema.getIdAsBytes());
producerRecord.headers().add(SchemaRegistryConfig.HEADER_SCHEMA_VERSION,
    schema.getVersionAsBytes());

// Send the record to Kafka
producer.send(producerRecord);

// Close the producer
producer.close();

```

The Kafka configuration property `value.serializer` is set to `com.ibm.eventstreams.serdes.EventStreamsSerializer`, telling Kafka to use the {{site.data.reuse.short_name}} serializer for message values when producing messages. You can also use the {{site.data.reuse.short_name}} serializer for message keys.

Other values are filled in based on the selected configuration, setting the correct Kafka configuration properties, including settings such as the message encoding behavior `SchemaRegistryConfig.PROPERTY_ENCODING_TYPE`.

For more information about the {{site.data.reuse.short_name}} schema registry configuration keys and values, see the `SchemaRegistryConfig` class in the [schema API reference](../../schema-api/){:target="_blank"}.

**Note:** Use the generic or generated schema-specific Java classes to set the field values in your message.
  - Specific Java classes that are generated from the schema definition will have `set<field-name>` methods that can be used to easily set the field values. For example, if the schema has a field named `Author` with type `string`, the generated schema-specific Java class will have a method named `setAuthor` which takes a string argument value.
  - The `Generic` configuration option will use the `org.apache.avro.generic.GenericRecord` class. Use the `put` method in the `GenericRecord` class to set field names and values.

**Note:** Replace `<my_topic>` with the name of the topic to produce messages to.


## Setting up consumers to use schemas

1. Ensure you have [prepared](#preparing-the-setup) for the setup, including configuring connection settings, downloading Java dependencies and schema JAR files, and copying code snippets for a consuming application.
2. Ensure you add the location of the JAR files to the build path of your consumer Kafka application.
3. Use the code snippets from the UI and add them to your application code.

The code snippet from the **Imports** section includes Java imports to paste into your class, and sets the up the application to use the {{site.data.reuse.short_name}} schema registry serdes library and any generated schema-specific classes, for example:

```
import java.time.Duration;
import java.util.Arrays;
import java.util.Properties;

// Import the specific schema class
import com.mycompany.schemas.ABC_Assets_Schema;

import org.apache.kafka.clients.CommonClientConfigs;
import org.apache.kafka.common.config.SaslConfigs;
import org.apache.kafka.common.config.SslConfigs;
import com.ibm.eventstreams.serdes.SchemaRegistryConfig;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.KafkaConsumer;

```

The code snippet from the **Connection properties** section specifies connection and access permission details to your {{site.data.reuse.short_name}} cluster, for example:

```
Properties props = new Properties();
props.put(CommonClientConfigs.BOOTSTRAP_SERVERS_CONFIG, "192.0.2.171:30342");
props.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
props.put(SslConfigs.SSL_PROTOCOL_CONFIG, "TLSv1.2");
props.put(SslConfigs.SSL_TRUSTSTORE_LOCATION_CONFIG, <Java_truststore_file_location>);
props.put(SslConfigs.SSL_TRUSTSTORE_PASSWORD_CONFIG, "password");
props.put(SaslConfigs.SASL_MECHANISM, "PLAIN");
String saslJaasConfig = "org.apache.kafka.common.security.plain.PlainLoginModule required "
    + "username=\"token\" password=\"<api_key>";";
props.put(SaslConfigs.SASL_JAAS_CONFIG, saslJaasConfig);

props.put(SchemaRegistryConfig.PROPERTY_API_URL, "https://192.0.2.171:30546");
props.put(SchemaRegistryConfig.PROPERTY_API_SKIP_SSL_VALIDATION, true);
```

**Note:** Replace the `<Java_truststore_file_location>` with the path to the Java truststore file you downloaded earlier and replace `<api_key>` with an API key which has the permissions needed for your application.

The values are filled in as part of the process of preparing for the setup, setting the correct Kafka configuration properties, including settings such as the API endpoint of your {{site.data.reuse.short_name}} installation `PROPERTY_API_URL`.

For more information about the {{site.data.reuse.short_name}} schema registry configuration keys and values, see the `SchemaRegistryConfig` class in the [schema API reference](../../schema-api/){:target="_blank"}.

The code snippet from the **Consumer code** section defines properties for the consumer application that set it to use the schema registry and the correct schema, for example:

```
// Set the value deserializer for consumed messages to use the Event Streams deserializer
props.put("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
props.put("value.deserializer", "com.ibm.eventstreams.serdes.EventStreamsDeserializer");

// Set the behavior of the deserializer when a record cannot be deserialized
props.put(SchemaRegistryConfig.PROPERTY_BEHAVIOR_TYPE, SchemaRegistryConfig.BEHAVIOR_STRICT);

// Set the consumer group ID in the properties
props.put("group.id", <my_consumer_group>);

// Get a new KafkaConsumer
KafkaConsumer<String, ABC_Assets_Schema> consumer = new KafkaConsumer<>(props);

// Subscribe to the topic
consumer.subscribe(Arrays.asList(<my_topic>));

// Poll the topic to retrieve records
while(true) {

    ConsumerRecords<String, ABC_Assets_Schema> records = consumer.poll(Duration.ofSeconds(5));

    for (ConsumerRecord<String, ABC_Assets_Schema> record : records) {
        ABC_Assets_Schema specificRecord = record.value();

        // Get fields and values from the specific record, for example:
        // String titleValue = specificRecord.getTitle().toString();
    }
}
```

The Kafka configuration property `value.serializer` is set to `com.ibm.eventstreams.serdes.EventStreamsDeserializer`, telling Kafka to use the {{site.data.reuse.short_name}} deserializer for message values when consuming messages. You can also use the {{site.data.reuse.short_name}} deserializer for message keys.

Other values are filled in based on the selected configuration, setting the correct Kafka configuration properties, including settings such as the message deserialization behavior `SchemaRegistryConfig.PROPERTY_BEHAVIOR_TYPE`.

For more information about the {{site.data.reuse.short_name}} schema registry configuration keys and values, see the `SchemaRegistryConfig` class in the [schema API reference](../../schema-api/){:target="_blank"}.

**Note:** Use the generic or generated schema-specific Java classes to read the field values from your message.
  - Specific Java classes that are generated from the schema definition will have `get<field-name>` methods that can be used to easily retrieve the field values. For example, if the schema has a field named `Author` with type `string`, the generated schema-specific Java class will have a method named `getAuthor` which returns a string argument value.
  - The `Generic` configuration option will use the `org.apache.avro.generic.GenericRecord` class. Use the `get` method in the `GenericRecord` class to set field names and values.

**Note:** Replace `<my_consumer_group>` with the name of the consumer group to use and `<my_topic>` with the name of the topic to consume messages from.

## Setting up Kafka Streams applications

Kafka Streams applications can also use the {{site.data.reuse.short_name}} schema registry serdes library to serialize and deserialize messages. For example:

```
// Set the Event Streams serdes properties, including the override option to set the schema
// and version used for serializing produced messages.
Map<String, Object> serdesProps = new HashMap<String, Object>();
serdesProps.put(SchemaRegistryConfig.PROPERTY_API_URL, "https://192.0.2.171:30546");
serdesProps.put(SchemaRegistryConfig.PROPERTY_API_SKIP_SSL_VALIDATION, true);
serdesProps.put(SchemaRegistryConfig.PROPERTY_SCHEMA_ID_OVERRIDE, "ABC_Assets_Schema");
serdesProps.put(SchemaRegistryConfig.PROPERTY_SCHEMA_VERSION_OVERRIDE, "1.0.0");
serdesProps.put(SslConfigs.SSL_PROTOCOL_CONFIG, "TLSv1.2");
serdesProps.put(SslConfigs.SSL_TRUSTSTORE_LOCATION_CONFIG, <Java_truststore_file_location>);
serdesProps.put(SslConfigs.SSL_TRUSTSTORE_PASSWORD_CONFIG, "password");
serdesProps.put(SaslConfigs.SASL_JAAS_CONFIG, "org.apache.kafka.common.security.plain.PlainLoginModule required "
    + "username=\"token\" password=\"<api_key>\";");

// Set up the Kafka StreamsBuilder
StreamsBuilder builder = new StreamsBuilder();

// Configure a Kafka Serde instance to use the Event Streams schema registry
// serializer and deserializer for message values
Serde<IndexedRecord> valueSerde = new EventStreamsSerdes();
valueSerde.configure(serdesProps, false);

// Get the stream of messages from the source topic, deserializing each message value with the
// Event Streams deserializer, using the schema and version specified in the message headers.
builder.stream(<my_source_topic>, Consumed.with(Serdes.String(), valueSerde))
    // Get the 'nextcount' int field from the record.
    // The Event Streams deserializer constructs instances of the generated schema-specific
    // ABC_Assets_Schema_Count class based on the values in the message headers.
    .mapValues(new ValueMapper<IndexedRecord, Integer>() {
        @Override
        public Integer apply(IndexedRecord val) {
            return ((ABC_Assets_Schema_Count) val).getNextcount();
        }
    })
    // Get all the records
    .selectKey((k, v) -> 0).groupByKey()
    // Sum the values
    .reduce(new Reducer<Integer>() {
        @Override
        public Integer apply(Integer arg0, Integer arg1) {
            return arg0 + arg1;
        }
    })
    .toStream()
    // Map the summed value to a field in the schema-specific generated ABC_Assets_Schema class
    .mapValues(
        new ValueMapper<Integer, IndexedRecord>() {
            @Override
            public IndexedRecord apply(Integer val) {
                ABC_Assets_Schema record = new ABC_Assets_Schema();
                record.setSum(val);
                return record;
            }
     })
     // Finally, put the result to the destination topic, serializing the message value
     // with the Event Streams serializer, using the overridden schema and version from the
     // configuration.
    .to(<my_destination_topic>, Produced.with(Serdes.Integer(), valueSerde));

// Create and start the stream
final KafkaStreams streams = new KafkaStreams(builder.build(), streamsConfig);
streams.start();
```

In this example, the Kafka StreamsBuilder is configured to use the `com.ibm.eventstreams.serdes.EventStreamsSerdes` class, telling Kafka to use the {{site.data.reuse.short_name}} deserializer for message values when consuming messages and the {{site.data.reuse.short_name}} serializer for message values when producing messages.

**Note:** The Kafka Streams `org.apache.kafka.streams.kstream` API does not provide access to message headers, so to produce messages with the {{site.data.reuse.short_name}} schema registry headers, use the `SchemaRegistryConfig.PROPERTY_SCHEMA_ID_OVERRIDE` and `SchemaRegistryConfig.PROPERTY_SCHEMA_VERSION_OVERRIDE` configuration properties. Setting these configuration properties will mean produced messages are serialized using the provided schema version and the {{site.data.reuse.short_name}} schema registry message headers will be set.

For more information about the {{site.data.reuse.short_name}} schema registry configuration keys and values, see the `SchemaRegistryConfig` class in the [schema API reference](../../schema-api/){:target="_blank"}.

**Note:** To re-use this example, replace the `<Java_truststore_file_location>` with the path to the Java truststore file you downloaded earlier, `<api_key>` with an API key which has read permissions for your {{site.data.reuse.short_name}} deployment, `<my_source_topic>` with the name of the topic to consume messages from and `<my_destination_topic>` with the name of the topic to produce messages to.
