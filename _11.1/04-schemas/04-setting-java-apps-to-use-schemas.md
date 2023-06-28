---
title: "Setting Java applications to use schemas"
excerpt: "Set up your Java applications to use schemas."
categories: schemas
slug: setting-java-apps
layout: redirects
toc: true
---

If you have Kafka producer or consumer applications written in Java, use the following guidance to set them up to use schemas.

**Note:** If you have Kafka clients written in other languages than Java, see the guidance about [setting up non-Java applications](../setting-nonjava-apps) to use schemas.

{{site.data.reuse.apicurio_note}}


## Preparing the setup

To use schemas stored in the Apicurio Registry in {{site.data.reuse.short_name}}, your client applications need to be able to serialize and deserialize messages based on schemas.

- Producing applications use a serializer to produce messages conforming to a specific schema, and use unique identifiers in the message to determine which schema is being used.
- Consuming applications then use a deserializer to consume messages that have been serialized using the same schema. The schema is retrieved from the schema registry based on the unique identifiers in the message.

The {{site.data.reuse.short_name}} UI provides help with setting up your Java applications to use schemas.

**Note:** Apicurio Registry in {{site.data.reuse.short_name}} works with multiple schema registry `serdes` libraries, including the Apicurio Registry `serdes` library and the deprecated {{site.data.reuse.short_name}} schema registry `serdes` library. You can use the Apicurio Registry `serdes` library in your applications by adding Maven dependencies to your project `pom.xml` files. The following instructions and code snippets use the Apicurio Registry `serdes` library. For more information, also see the guidance about [setting up Java applications to use schemas with the Apicurio Registry serdes library](../setting-java-apps-apicurio-serdes).

To set up your Java applications to use the Apicurio Registry and the Apicurio Registry `serdes` library, prepare the connection for your application as follows:

1. {{site.data.reuse.es_ui_login}}
2. Ensure you have [added schemas](../creating) to the registry.
3. Click **Schema registry** in the primary navigation.
4. Select a schema from the list and click the row for the schema.
5. Click **Connect to the latest version**. Alternatively, if you want to use a different version of the schema, click the row for the schema version, and click **Connect to this version**.
6. Set the preferences for your connection in the **Configure the schema connection** section. Use the defaults or change them by clicking **Change configuration**.

   - For producers, set the method for **Message encoding**.

     - **Binary** (default): Binary-encoded messages are smaller and typically quicker to process. However the message data is not human-readable without an application that is able to apply the schema.
     - **JSON**: JSON-encoded messages are human-readable and can still be used by consumers that are not using the {{site.data.reuse.long_name}} schema registry.

7. If any configuration was changed, click **Save**.
8. Click **Generate credentials** to generate SCRAM or Mutual TLS credentials and follow the instructions.\\
   **Important:** Ensure you make note of the information provided upon completion as you will need this later.\\
   Alternatively you can generate credentials later by using the {{site.data.reuse.short_name}} [UI](../../security/managing-access#creating-a-kafkauser-in-the-event-streams-ui) or [CLI](../../security/managing-access#creating-a-kafkauser-in-the-event-streams-cli).
9. Click **Generate connection details**.
10. Click **Download certificate** to download the cluster PKCS12 certificate. This is the Java truststore file which contains the server certificate. Take a copy of the **Certificate password** for use with the certificate in your application.
11. If your project uses Maven, add the following dependency to your project `pom.xml` file to use the Apicurio Registry `serdes` library:

    ```
    <dependency>
      <groupId>io.apicurio</groupId>
      <artifactId>apicurio-registry-serdes-avro-serde</artifactId>
      <version>2.4.1.Final</version>
    </dependency>
    ```

    Alternatively, if your project does not use Maven, select the **Use JARs** tab and click **Java dependencies** to download the java dependencies JAR files to use for your application in its code.
12. Depending on your application, click the **Producer** or **Consumer** tab, and copy the sample Java code snippets displayed. The sample code snippets include the settings you configured to set up your applications to use the schema.
13. Add the required snippets into your application code as described in the following sections.
    - [Setting up producers to use schemas](#setting-up-producers-to-use-schemas)
    - [Setting up consumers to use schemas](#setting-up-consumers-to-use-schemas)

## Setting up producers to use schemas

1. Ensure you have [prepared](#preparing-the-setup) for the setup, including configuring connection settings, downloading Java dependencies if not using Maven, and copying code snippets for a producing application.
2. If your project does not use Maven, ensure you add the location of the JAR files to the build path of your producer Kafka application.
3. Use the code snippets you copied from the UI for a producer and add them to your application code.

The code snippet from the **Imports** section includes Java imports to paste into your class, and sets up the application to use the Apicurio Registry `serdes` library, for example:

```
import java.util.Properties;
import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringSerializer;

import io.apicurio.registry.serde.SerdeConfig;
import io.apicurio.registry.serde.avro.AvroKafkaSerializer;
import io.apicurio.registry.serde.avro.AvroKafkaSerdeConfig;
import io.apicurio.rest.client.config.ApicurioClientConfig;

```

The code snippet from the **Connection properties** section specifies connection and access permission details for your {{site.data.reuse.short_name}} cluster and the Apicurio Registry, for example:

```
Properties props = new Properties();
// TLS Properties
props.put(SslConfigs.SSL_PROTOCOL_CONFIG, "TLSv1.2");
props.put(SslConfigs.SSL_TRUSTSTORE_LOCATION_CONFIG, <ca_p12_file_location>);
props.put(SslConfigs.SSL_TRUSTSTORE_PASSWORD_CONFIG, <ca_p12_password>);

// SCRAM authentication properties - uncomment to connect using Scram
//props.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
//props.put(SaslConfigs.SASL_MECHANISM, "SCRAM-SHA-512");
//String saslJaasConfig = "org.apache.kafka.common.security.scram.ScramLoginModule required "
//    + "username="<username>" password="<password>";";
//props.put(SaslConfigs.SASL_JAAS_CONFIG, saslJaasConfig);

// Mutual authentication properties - uncomment to connect using Mutual authentication
//props.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SSL");
//props.put(SslConfigs.SSL_KEYSTORE_LOCATION_CONFIG, <user_p12_file_location>);
//props.put(SslConfigs.SSL_KEYSTORE_PASSWORD_CONFIG, <user_p12_password>);

// Apicurio Registry connection
props.put(SerdeConfig.REGISTRY_URL, <schema_registry_endpoint>);
props.put(ApicurioClientConfig.APICURIO_REQUEST_TRUSTSTORE_LOCATION, <ca_p12_file_location>);
props.put(ApicurioClientConfig.APICURIO_REQUEST_TRUSTSTORE_PASSWORD, <ca_p12_password>);
props.put(ApicurioClientConfig.APICURIO_REQUEST_TRUSTSTORE_TYPE, "PKCS12");

// SCRAM authentication properties - uncomment to connect to Apicurio Registry using Scram
//props.put(SerdeConfig.AUTH_USERNAME, <username>);
//props.put(SerdeConfig.AUTH_PASSWORD, <password>);

// Mutual authentication properties - uncomment to connect to Apicurio Registry
// using Mutual authentication
//props.put(ApicurioClientConfig.APICURIO_REQUEST_KEYSTORE_LOCATION, <user_p12_file_location>)
//props.put(ApicurioClientConfig.APICURIO_REQUEST_KEYSTORE_PASSWORD, <user_p12_password>);
//props.put(ApicurioClientConfig.APICURIO_REQUEST_KEYSTORE_TYPE, "PKCS12");

// Kafka connection
props.put(CommonClientConfigs.BOOTSTRAP_SERVERS_CONFIG, <kafka_bootstrap_address>);
```

**Note:** Follow the instructions in the code snippet to uncomment lines. Replace `<ca_p12_file_location>` with the path to the Java truststore file you downloaded earlier, `<ca_p12_password>` with the truststore password which has the permissions needed for your application, `<kafka_bootstrap_address>` with the bootstrap address (find out how to [obtain the address](../../getting-started/connecting/#obtaining-the-bootstrap-address)), and `<schema_registry_endpoint>` with the endpoint address for Apicurio Registry in {{site.data.reuse.short_name}}. For SCRAM, replace the `<username>` and `<password>` with the SCRAM username and password. For Mutual authentication, replace `<user_p12_file_location>` with the path to the `user.p12` file extracted from the `.zip` file downloaded earlier and `<user_p12_password>` with the contents of the `user.password` file in the same `.zip` file.

For more information about the configuration keys and values to use with the {{site.data.reuse.short_name}} `serdes` library, see the `SchemaRegistryConfig` class in the [schema API reference](../../schema-api/){:target="_blank"}.

The code snippet from the **Producer code** section defines properties for the producer application that set it to use the schema registry and the correct schema, for example:

```
// Set the value serializer for produced messages to use the Apicurio Avro serializer
props.put("key.serializer", StringSerializer.class);
props.put("value.serializer", AvroKafkaSerializer.class);

// Set the encoding type used by the message serializer
props.put(AvroKafkaSerdeConfig.AVRO_ENCODING, AvroKafkaSerdeConfig.AVRO_BINARY);

// Get a new Generic KafkaProducer
KafkaProducer<String, GenericRecord> producer = new KafkaProducer<>(props);

// Read the schema for the Generic record from a local schema file
Schema.Parser schemaDefinitionParser = new Schema.Parser();
Schema schema = schemaDefinitionParser.parse(
    new File("path/to/schema.avsc"));

// Get a new Generic record based on the schema
GenericRecord genericRecord = new GenericData.Record(schema);

// Add fields and values to the genericRecord, for example:
// genericRecord.put("title", "this is the value for a title field");

// Prepare the record
ProducerRecord<String, GenericRecord> producerRecord = new ProducerRecord<String, GenericRecord>(<my_topic>, genericRecord);

// Send the record to Kafka
producer.send(producerRecord);

// Close the producer
producer.close();

```

The Kafka configuration property `value.serializer` is set to `AvroKafkaSerializer.class`, telling Kafka to use the Apicurio Registry Avro Kafka serializer for message values when producing messages. You can also use the Apicurio Registry Avro Kafka serializer for message keys.

For more information about the configuration keys and values to use with the Apicurio Registry `serdes` library, see the [Apicurio Registry documentation](https://www.apicur.io/registry/docs/apicurio-registry/2.3.x/index.html){:target="_blank"}.

**Note:** Use the `put` method in the `GenericRecord` class to set field names and values in your message.

**Note:** Replace `<my_topic>` with the name of the topic to produce messages to.

## Setting up consumers to use schemas

1. Ensure you have [prepared](#preparing-the-setup) for the setup, including configuring connection settings, downloading Java dependencies if not using Maven, and copying code snippets for a consuming application.
2. If your project does not use Maven, ensure you add the location of the JAR files to the build path of your consumer Kafka application.
3. Use the code snippets you copied from the UI for a consumer and add them to your application code.

The code snippet from the **Imports** section includes Java imports to paste into your class, and sets up the application to use the Apicurio Registry `serdes` library, for example:

```
import java.time.Duration;
import java.util.Arrays;
import java.util.Properties;
import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;

import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.serialization.StringDeserializer;

import io.apicurio.registry.serde.SerdeConfig;
import io.apicurio.registry.serde.avro.AvroKafkaDeserializer;
import io.apicurio.rest.client.config.ApicurioClientConfig;

```

The code snippet from the **Connection properties** section specifies connection and access permission details for your {{site.data.reuse.short_name}} cluster, for example:

```
Properties props = new Properties();
// TLS Properties
props.put(SslConfigs.SSL_PROTOCOL_CONFIG, "TLSv1.2");
props.put(SslConfigs.SSL_TRUSTSTORE_LOCATION_CONFIG, <ca_p12_file_location>);
props.put(SslConfigs.SSL_TRUSTSTORE_PASSWORD_CONFIG, <ca_p12_password>);

// SCRAM authentication properties - uncomment to connect using Scram
//props.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
//props.put(SaslConfigs.SASL_MECHANISM, "SCRAM-SHA-512");
//String saslJaasConfig = "org.apache.kafka.common.security.scram.ScramLoginModule required "
//    + "username="<username>" password="<password>";";
//props.put(SaslConfigs.SASL_JAAS_CONFIG, saslJaasConfig);

// Mutual authentication properties - uncomment to connect using Mutual authentication
//props.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SSL");
//props.put(SslConfigs.SSL_KEYSTORE_LOCATION_CONFIG, <user_p12_file_location>);
//props.put(SslConfigs.SSL_KEYSTORE_PASSWORD_CONFIG, <user_p12_password>);

// Apicurio Registry connection
props.put(SerdeConfig.REGISTRY_URL, <schema_registry_endpoint>);
props.put(ApicurioClientConfig.APICURIO_REQUEST_TRUSTSTORE_LOCATION, <ca_p12_file_location>);
props.put(ApicurioClientConfig.APICURIO_REQUEST_TRUSTSTORE_PASSWORD, <ca_p12_password>);
props.put(ApicurioClientConfig.APICURIO_REQUEST_TRUSTSTORE_TYPE, "PKCS12");

// SCRAM authentication properties - uncomment to connect to Apicurio Registry using Scram
//props.put(SerdeConfig.AUTH_USERNAME, <username>);
//props.put(SerdeConfig.AUTH_PASSWORD, <password>);

// Mutual authentication properties - uncomment to connect to Apicurio Registry
// using Mutual authentication
//props.put(ApicurioClientConfig.APICURIO_REQUEST_KEYSTORE_LOCATION, <user_p12_file_location>)
//props.put(ApicurioClientConfig.APICURIO_REQUEST_KEYSTORE_PASSWORD, <user_p12_password>);
//props.put(ApicurioClientConfig.APICURIO_REQUEST_KEYSTORE_TYPE, "PKCS12");

// Kafka connection
props.put(CommonClientConfigs.BOOTSTRAP_SERVERS_CONFIG, <kafka_bootstrap_address>);
```

**Note:** Follow the instructions in the code snippet to uncomment lines. Replace `<ca_p12_file_location>` with the path to the Java truststore file you downloaded earlier, `<ca_p12_password>` with the truststore password which has the permissions needed for your application, `<kafka_bootstrap_address>` with the bootstrap address (find out how to [obtain the address](../../getting-started/connecting/#obtaining-the-bootstrap-address)), and `<schema_registry_endpoint>` with the endpoint address for Apicurio Registry in {{site.data.reuse.short_name}}. For SCRAM, replace the `<username>` and `<password>` with the SCRAM username and password. For Mutual authentication, replace `<user_p12_file_location>` with the path to the `user.p12` file extracted from the `.zip` file downloaded earlier and `<user_p12_password>` with the contents of the `user.password` file in the same `.zip` file.

For more information about the configuration keys and values to use with the Apicurio Registry `serdes` library, see the [Apicurio Registry documentation](https://www.apicur.io/registry/docs/apicurio-registry/2.3.x/index.html){:target="_blank"}.

The code snippet from the **Consumer code** section defines properties for the consumer application that set it to use the schema registry and the correct schema, for example:

```

// Set the value deserializer for consumed messages to use the Apicurio Avro deserializer
props.put("key.deserializer", StringDeserializer.class);
props.put("value.deserializer", AvroKafkaDeserializer.class);

// Set the consumer group ID in the properties
props.put("group.id", <my_consumer_group>);

// Get a new KafkaConsumer
KafkaConsumer<String, GenericRecord> consumer = new KafkaConsumer<>(props);

// Subscribe to the topic
consumer.subscribe(Arrays.asList(<my_topic>));

// Poll the topic to retrieve records
while(true) {
  ConsumerRecords<String, GenericRecord> records = consumer.poll(Duration.ofSeconds(5));

  for (ConsumerRecord<String, GenericRecord> record : records) {
    GenericRecord genericRecord = record.value();
    // Get fields and values from the genericRecord, for example:
    // String titleValue = genericRecord.get("title").toString();
  }
}
```

The Kafka configuration property `value.deserializer` is set to `AvroKafkaDeserializer.class`, telling Kafka to use the Apicurio Registry Avro Kafka deserializer for message values when consuming messages. You can also use the Apicurio Registry Avro Kafka deserializer for message keys.

For more information about the configuration keys and values to use with the Apicurio Registry `serdes` library, see the [Apicurio Registry documentation](https://www.apicur.io/registry/docs/apicurio-registry/2.3.x/index.html){:target="_blank"}.

**Note:** Use the `get` method in the `GenericRecord` class to get field names and values.

**Note:** Replace `<my_consumer_group>` with the name of the consumer group to use and `<my_topic>` with the name of the topic to consume messages from.

## Other clients

To configure other types of Kafka clients, such as Kafka Streams applications and Kafka Connect connectors, and for information about other configuration options for the Apicurio Registry `serdes` library, see the guidance about [setting up Java applications to use schemas with the Apicurio Registry serdes library](../setting-java-apps-apicurio-serdes).
