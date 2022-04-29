---
title: "Setting Java applications to use schemas with the Apicurio Registry serdes library"
excerpt: "Set up your Java applications to use schemas with the Apicurio Registry serdes library."
categories: schemas
slug: setting-java-apps-apicurio-serdes
toc: true
---

If you have Kafka producer or consumer applications written in Java, use the following guidance to set them up to use schemas and the Apicurio Registry `serdes` library.

**Note:** If you have Kafka clients written in other languages than Java, see the guidance about [setting up non-Java applications](../setting-nonjava-apps) to use schemas.

## Preparing the setup

To use schemas stored in the Apicurio Registry in {{site.data.reuse.short_name}}, your client applications need to be able to serialize and deserialize messages based on schemas.

- Producing applications use a serializer to produce messages conforming to a specific schema, and use unique identifiers in the message headers to determine which schema is being used.
- Consuming applications then use a deserializer to consume messages that have been serialized using the same schema. The schema is retrieved from the schema registry based on the unique identifiers in the message headers.

The {{site.data.reuse.short_name}} UI provides help with setting up your Java applications to use schemas.

**Note:** Apicurio Registry in {{site.data.reuse.short_name}} works with multiple schema registry `serdes` libraries, including the Apicurio Registry `serdes` library. The following instructions and code snippets use the Apicurio Registry `serdes` library.

To set up your Java applications to use the Apicurio Registry `serdes` library with Apicurio Registry in {{site.data.reuse.short_name}}, prepare the connection for your application as follows:

1. {{site.data.reuse.es_ui_login}}
2. Ensure you have [added schemas](../creating) to the registry.
3. Click **Schema registry** in the primary navigation.
4. Select a schema from the list and click the row for the schema.
5. Click **Connect to the latest version**. Alternatively, if you want to use a different version of the schema, click the row for the schema version, and click **Connect to this version**.
6. Set the preferences for your connection in the **Configure the schema connection** section. Use the defaults or change them by clicking **Change configuration**.

   - For producers, set the method for **Message encoding**.

     - **Binary** (default): Binary-encoded messages are smaller and typically quicker to process. However the message data is not human-readable without an application that is able to apply the schema.
     - **JSON**: JSON-encoded messages are human-readable and can still be used by consumers that are not using the {{site.data.reuse.long_name}} schema registry.

   - For consumers, set the **Message deserialization behavior** for the behavior to use when an application encounters messages that do not conform to the schema.

     - **Strict** (default): Strict behavior means the message deserializer will fail to process non-conforming messages, throwing an exception if one is encountered.
     - **Permissive**: Permissive behavior means the message deserializer will return a null message when a non-conforming message is encountered. It will not throw an exception, and will allow a Kafka consumer to continue to process further messages.

7. If any configuration was changed, click **Save**.
8. Click **Generate credentials** to generate SCRAM or Mutual TLS credentials and follow the instructions.\\
   **Important:** Ensure you make note of the information provided upon completion as you will need this later.\\
   Alternatively you can generate credentials later by using the {{site.data.reuse.short_name}} [UI](../../security/managing-access#creating-a-kafkauser-in-the-ibm-event-streams-ui) or [CLI](../../security/managing-access#creating-a-kafkauser-in-the-ibm-event-streams-cli).
9. Click **Generate connection details**.
10. Click **Download certificate** to download the cluster PKCS12 certificate. This is the Java truststore file which contains the server certificate. Take a copy of the **Certificate password** for use with the certificate in your application.
11. Add the following dependency to your project Maven `pom.xml` file to use the Apicurio Registry  `serdes` library:

    ```
    <dependency>
        <groupId>io.apicurio</groupId>
        <artifactId>apicurio-registry-utils-serde</artifactId>
        <version>1.3.2.Final</version>
    </dependency>
    ```
12. If you want to generate specific schema classes from your project Avro schema files, add the following Avro plugin to your project Maven `pom.xml` file, replacing `SCHEMA-FILE-NAME` with the name of your schema file.

    ```
    <profile>
      <id>avro</id>
      <build>
        <plugins>
          <plugin>
            <groupId>org.apache.avro</groupId>
            <artifactId>avro-maven-plugin</artifactId>
            <version>1.9.2</version>
            <executions>
              <execution>
                <phase>generate-sources</phase>
                <goals>
                  <goal>schema</goal>
                </goals>
                <configuration>
                    <sourceDirectory>${project.basedir}/src/main/resources/avro-schemas/</sourceDirectory>
                    <includes>
                        <include>SCHEMA-FILE-NAME.avsc</include>
                    </includes>
                    <outputDirectory>${project.build.directory}/generated-sources</outputDirectory>
                </configuration>
              </execution>
            </executions>
          </plugin>
        </plugins>
      </build>
    </profile>
    ```

13. Add snippets into your application code as described in the following sections.
    - [Setting up producers to use schemas](#setting-up-producers-to-use-schemas)
    - [Setting up consumers to use schemas](#setting-up-consumers-to-use-schemas)

If you are connecting to a bootstrap address that is configured to use [OAuth authentication](../../installing/configuring/#enabling-oauth), complete the following additional steps:

14. Download the OAuth authentication PKCS12 certificate. This is the Java truststore file which contains the OAuth server certificate. You will also need to know the truststore password as this will need to be configured in your application.
15. You might need to configure the OAuth client libraries as dependencies in your project Maven `pom.xml` file, for example, to use the Strimzi OAuth client library:

    ```
    <dependency>
        <groupId>io.strimzi</groupId>
        <artifactId>kafka-oauth-client</artifactId>
        <version>0.9.0</version>
    </dependency>
    ```

## Additional configuration options for Apicurio `serdes` library

The Apicurio `serdes` library supports the following configuration options that can be specified to change how data is serialized.

| Key         | Value        | Description
| apicurio.registry.use.headers  | true     | Use this option to store the schema ID in the header of the message rather than within the payload.
| apicurio.avro.encoding | JSON or BINARY | Specify whether to use BINARY (default) or JSON encoding within the Avro serializer

**Note:** If you are using headers to store the schema ID, you can override the keys used in the header with the following values:

- `apicurio.key.artifactId.name`
- `apicurio.value.artifactId.name`
- `apicurio.key.version.name`
- `apicurio.value.version.name`
- `apicurio.key.globalId.name`
- `apicurio.value.globalId.name`

By setting these values you can change the name of the header that the Apicurio `serdes` library uses when adding headers for the `artifactId`, `version`, or `globalId` in the Kafka message.


## Setting up producers to use schemas

1. Ensure you have [prepared](#preparing-the-setup) for the setup, including configuring connection settings, downloading Java dependencies if not using Maven, and copying code snippets for a producing application.
2. If your project does not use Maven, ensure you add the location of the JAR files to the build path of your producer Kafka application.
3. Add the following code snippets to your application code.

### Imports
```
import java.io.File;
import java.util.Properties;

import io.apicurio.registry.utils.serde.AbstractKafkaStrategyAwareSerDe;
import io.apicurio.registry.utils.serde.AvroKafkaSerializer;

import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;

import org.apache.kafka.clients.CommonClientConfigs;
import org.apache.kafka.common.config.SaslConfigs;
import org.apache.kafka.common.config.SslConfigs;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
```

### Connection properties
```
Properties props = new Properties();

// TLS Properties
props.put(SslConfigs.SSL_PROTOCOL_CONFIG, "TLSv1.2");
props.put(SslConfigs.SSL_TRUSTSTORE_LOCATION_CONFIG, "<ca_p12_file_location>");
props.put(SslConfigs.SSL_TRUSTSTORE_PASSWORD_CONFIG, "<ca_p12_password>");

//If your Kafka and Schema registry endpoints do not use the same authentication method, you will need
//to duplicate the properties object - and add the Schema Registry authentication and connection properties
//to 'props', and the Kafka authentication and connection properties to 'kafkaProps'. The different properties objects
//are then supplied to the Serializer and Producer/Consumer respectively.
//Uncomment the next two lines.
//Properties kafkaProps = new Properties();
//kafkaProps.putAll(props);

// TLS Properties for Apicurio Registry connection
props.put(AbstractKafkaStrategyAwareSerDe.REGISTRY_REQUEST_TRUSTSTORE_LOCATION, "<ca_p12_file_location>");
props.put(AbstractKafkaStrategyAwareSerDe.REGISTRY_REQUEST_TRUSTSTORE_PASSWORD, "<ca_p12_password>");

// SCRAM authentication properties - uncomment to connect using Scram
//props.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
//props.put(SaslConfigs.SASL_MECHANISM, "SCRAM-SHA-512");
//String saslJaasConfig = "org.apache.kafka.common.security.scram.ScramLoginModule required "
//+ "username=\"<username>\" password=\"<password>\";";
//props.put(SaslConfigs.SASL_JAAS_CONFIG, saslJaasConfig);

// OAuth authentication properties - uncomment to connect using OAuth
//props.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
//props.put(SaslConfigs.SASL_MECHANISM, "OAUTHBEARER");
//String saslJaasConfig = "org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required \
  oauth.ssl.truststore.location=<keycloak_ca_p12_file_location>> \
  oauth.ssl.truststore.type=PKCS12 \
  oauth.ssl.truststore.password=<ca_p12_password> \
  oauth.ssl.endpoint.identification.algorithm="" \
  oauth.client.id="<oauth_username>" \
  oauth.client.secret="<oauth_password>" \
  oauth.token.endpoint.uri="<oauth_token_endpoint_uri>";";
//props.put(SaslConfigs.SASL_JAAS_CONFIG, saslJaasConfig);
// You may need to provide a Callback Handler for OAuth. This example shows the Strimzi OAuth callback handler.
//props.put(SaslConfigs.SASL_LOGIN_CALLBACK_HANDLER_CLASS, "io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler")
//
// URL for Apicurio Registry connection including basic auth parameters
//props.put(AbstractKafkaStrategyAwareSerDe.REGISTRY_URL_CONFIG_PARAM, "https://<username>:<password>@<Schema registry endpoint>");

// Mutual authentication properties - uncomment to connect using Mutual authentication
//props.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SSL");
//props.put(SslConfigs.SSL_KEYSTORE_LOCATION_CONFIG, "<user_p12_file_location>");
//props.put(SslConfigs.SSL_KEYSTORE_PASSWORD_CONFIG, "<user_p12_password>");
//
// Mutual authentication properties for Apicurio Registry connection
//props.put(AbstractKafkaStrategyAwareSerDe.REGISTRY_REQUEST_KEYSTORE_LOCATION, "<user_p12_file_location>");
//props.put(AbstractKafkaStrategyAwareSerDe.REGISTRY_REQUEST_KEYSTORE_LOCATION, "<user_p12_file_location>");
//
// URL for Apicurio Registry connection
//props.put(AbstractKafkaStrategyAwareSerDe.REGISTRY_URL_CONFIG_PARAM, "https://<Schema registry endpoint>");

// Set the ID strategy to use the fully-qualified schema name (including namespace)
props.put(AbstractKafkaStrategyAwareSerDe.REGISTRY_ARTIFACT_ID_STRATEGY_CONFIG_PARAM, "io.apicurio.registry.utils.serde.strategy.RecordIdStrategy");

// Kafka connection
props.put(CommonClientConfigs.BOOTSTRAP_SERVERS_CONFIG, "<Kafka listener>");
```

**Note:** Uncomment lines depending on your authentication settings. Replace:
 - `<ca_p12_file_location>` with the path to the Java truststore file you downloaded earlier.
 - `<ca_p12_password>` with the truststore password which has the permissions needed for your application.
 - `<Kafka listener>` with the bootstrap address (find out how to [obtain the address](../../getting-started/connecting/#obtaining-the-bootstrap-address))
 - `<Schema registry endpoint>` with the endpoint address for Apicurio Registry in {{site.data.reuse.short_name}}.
 - For SCRAM, replace `<username>` and `<password>` with the SCRAM username and password.
 - For Mutual authentication, replace `<user_p12_file_location>` with the path to the `user.p12` file extracted from the `.zip` file downloaded earlier and `<user_p12_password>` with the contents of the `user.password` file in the same `.zip` file.
 - For OAuth, replace `<ca_p12_file_location>` with the path to the OAuth authentication server truststore file you downloaded earlier, `<ca_p12_password>` with the password for this truststore, `<oauth_username>` and `<oauth_password>` with the OAuth client credentials, and `<oauth_token_endpoint_uri>` with the OAuth servers token endpoint URI.

 **Note:** You can use OAuth for connection to the Kafka brokers if an OAuth listener has been [configured](../../installing/configuring/#enabling-oauth). However, you cannot use OAuth for the Apicurio Registry. You must use either SCRAM or Mutual TLS for the connection to the registry.

### Producer code example

```
// Set the value serializer for produced messages to use the Apicurio Registry serializer
props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
props.put("value.serializer", "io.apicurio.registry.utils.serde.AvroKafkaSerializer");

// Get a new Generic KafkaProducer
KafkaProducer<String, GenericRecord> producer = new KafkaProducer<>(props);

// Read in the local schema file
Schema.Parser schemaDefinitionParser = new Schema.Parser();
Schema schema = schemaDefinitionParser.parse(new File("<path_to_schema_file.avsc>"));

// Get a new Generic record based on the schema
GenericRecord genericRecord = new GenericData.Record(schema);

// Add fields and values to the genericRecord, for example:
// genericRecord.put("title", "this is the value for a title field");

// Prepare the record
ProducerRecord<String, GenericRecord> producerRecord =
    new ProducerRecord<String, GenericRecord>("<my_topic>", genericRecord);

// Send the record to Kafka
producer.send(producerRecord);

// Close the producer
producer.close();

```

The Kafka configuration property `value.serializer` is set to `io.apicurio.registry.utils.serde.AvroKafkaSerializer`, telling Kafka to use the Apicurio Registry Avro serializer for message values when producing messages. You can also use the Apicurio Registry Avro serializer for message keys.

**Note:** Use the `put` method in the `GenericRecord` class to set field names and values in your message.

**Note:** Replace:
 - `<my_topic>` with the name of the topic to produce messages to.
 - `<path_to_schema_file.avsc>` with the path to the Avro schema file.

**Note:** If you want to retrieve the schema from the registry instead of loading the file locally, you can use the following code:

```
// Convert kafka connection properties to a Map
Map<String, Object> config = (Map) props;
// Create the client
RegistryRestClient client = RegistryRestClientFactory.create(REGISTRY_URL, config);

try {
    // Get the schema from apicurio and convert to an avro schema
    Schema schema = new Schema.Parser().parse(client.getLatestArtifact(artifactId));
} catch (Exception e) {
    e.printStackTrace();
}
```

## Setting up consumers to use schemas

1. Ensure you have [prepared](#preparing-the-setup) for the setup, including configuring connection settings, downloading Java dependencies if not using Maven, and copying code snippets for a consuming application.
2. If your project does not use Maven, ensure you add the location of the JAR files to the build path of your consumer Kafka application.
3. Add the following code snippets to your application code.

### Imports
```
import java.time.Duration;
import java.util.Arrays;
import java.util.Properties;

import io.apicurio.registry.utils.serde.AbstractKafkaSerDe;

import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;

import org.apache.kafka.clients.CommonClientConfigs;
import org.apache.kafka.common.config.SaslConfigs;
import org.apache.kafka.common.config.SslConfigs;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.KafkaConsumer;
```

### Connection properties
```
Properties props = new Properties();

// TLS Properties
props.put(SslConfigs.SSL_PROTOCOL_CONFIG, "TLSv1.2");
props.put(SslConfigs.SSL_TRUSTSTORE_LOCATION_CONFIG, "<ca_p12_file_location>");
props.put(SslConfigs.SSL_TRUSTSTORE_PASSWORD_CONFIG, "<ca_p12_password>");

//If your Kafka and Schema registry endpoints do not use the same authentication method, you will need
//to duplicate the properties object - and add the Schema Registry authentication and connection properties
//to 'props', and the Kafka authentication and connection properties to 'kafkaProps'. The different properties objects
//are then supplied to the Serializer and Producer/Consumer respectively.
//Uncomment the next two lines.
//Properties kafkaProps = new Properties();
//kafkaProps.putAll(props);

// TLS Properties for Apicurio Registry connection
props.put(AbstractKafkaSerDe.REGISTRY_REQUEST_TRUSTSTORE_LOCATION, "<ca_p12_file_location>");
props.put(AbstractKafkaSerDe.REGISTRY_REQUEST_TRUSTSTORE_PASSWORD, "<ca_p12_password>");

// SCRAM authentication properties - uncomment to connect using Scram
//props.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
//props.put(SaslConfigs.SASL_MECHANISM, "SCRAM-SHA-512");
//String saslJaasConfig = "org.apache.kafka.common.security.scram.ScramLoginModule required "
//+ "username=\"<username>\" password=\"<password>\";";
//props.put(SaslConfigs.SASL_JAAS_CONFIG, saslJaasConfig);
//
// URL for Apicurio Registry connection including basic auth parameters
//props.put(AbstractKafkaSerDe.REGISTRY_URL_CONFIG_PARAM, "https://<username>:<password>@<Schema registry endpoint>");

// Mutual authentication properties - uncomment to connect using Mutual authentication
//props.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SSL");
//props.put(SslConfigs.SSL_KEYSTORE_LOCATION_CONFIG, "<user_p12_file_location>");
//props.put(SslConfigs.SSL_KEYSTORE_PASSWORD_CONFIG, "<user_p12_password>");
//
// Mutual authentication properties for Apicurio Registry connection
//props.put(AbstractKafkaSerDe.REGISTRY_REQUEST_KEYSTORE_LOCATION, "<user_p12_file_location>");
//props.put(AbstractKafkaSerDe.REGISTRY_REQUEST_KEYSTORE_LOCATION, "<user_p12_file_location>");
//
// URL for Apicurio Registry connection
//props.put(AbstractKafkaSerDe.REGISTRY_URL_CONFIG_PARAM, "https://<Schema registry endpoint>");

// Kafka connection
props.put(CommonClientConfigs.BOOTSTRAP_SERVERS_CONFIG, "<Kafka listener>");
```

**Note:** Uncomment lines depending on your authentication settings. Replace:
 - `<ca_p12_file_location>` with the path to the Java truststore file you downloaded earlier.
 - `<ca_p12_password>` with the truststore password which has the permissions needed for your application.
 - `<Kafka listener>` with the bootstrap address (find out how to [obtain the address](../../getting-started/connecting/#obtaining-the-bootstrap-address))
 - `<Schema registry endpoint>` with the endpoint address for Apicurio Registry in {{site.data.reuse.short_name}}.
 - For SCRAM, replace `<username>` and `<password>` with the SCRAM username and password.
 - For Mutual authentication, replace `<user_p12_file_location>` with the path to the `user.p12` file extracted from the `.zip` file downloaded earlier and `<user_p12_password>` with the contents of the `user.password` file in the same `.zip` file.

### Consumer code example
```
// Set the value deserializer for consumed messages to use the Apicurio Registry deserializer
props.put("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
props.put("value.deserializer", "io.apicurio.registry.utils.serde.AvroKafkaDeserializer");

// Set the consumer group ID in the properties
props.put("group.id", "<my_consumer_group>");

KafkaConsumer<String, GenericRecord> consumer = new KafkaConsumer<>(props);

// Subscribe to the topic
consumer.subscribe(Arrays.asList("<my_topic>"));

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

The Kafka configuration property `value.serializer` is set to `io.apicurio.registry.utils.serde.AvroKafkaDeserializer`, telling Kafka to use the Apicurio Registry Avro deserializer for message values when consuming messages. You can also use the Apicurio Registry Avro deserializer for message keys.

**Note:** Use the `get` method in the `GenericRecord` class to get field names and values.

**Note:** Replace:
 - `<my_consumer_group>` with the name of the consumer group to use.
 - `<my_topic>` with the name of the topic to consume messages from.

## Setting up Kafka Streams applications

Kafka Streams applications can also use the Apicurio Registry `serdes` library to serialize and deserialize messages. In particular, the `io.apicurio.registry.utils.serde.AvroSerde` class can be used to provide the Apicurio Avro serializer and deserializer for the `"default.value.serde"` or `"default.key.serdes"` properties. Additionally, setting the `"apicurio.registry.use-specific-avro-reader"` property to `"true"` tells the Apicurio Registry `serdes` library to use specific schema classes that have been generated from your project Avro schema files. For example:

```
import io.apicurio.registry.utils.serde.AbstractKafkaSerDe;
import io.apicurio.registry.utils.serde.AvroSerde;
import io.apicurio.registry.utils.serde.avro.AvroDatumProvider;

import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.StreamsConfig;

import java.util.Properties;


...

final Properties streamsConfiguration = new Properties();

// URL for Apicurio Registry connection (including basic auth parameters)
streamsConfiguration.put(AbstractKafkaSerDe.REGISTRY_URL_CONFIG_PARAM, "https://<username>:<password>@<Schema registry endpoint>");

// Specify default serializer and deserializer for record keys and for record values.
streamsConfiguration.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass().getName());
streamsConfiguration.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, AvroSerde.class);

// Specify using specific (generated) Avro schema classes
streamsConfiguration.put(AvroDatumProvider.REGISTRY_USE_SPECIFIC_AVRO_READER_CONFIG_PARAM, "true");
```

## Setting up Kafka Connect connectors

The Apicurio Registry `converter` library can be used in Kafka Connect to provide the converters that are required to convert between Kafka Connect's format and the Avro serialized format. Source connectors can use the converter to write Avro-formatted values, keys, and headers to Kafka. Sink connectors can use the converter to read Avro-formatted values, keys, and headers from Kafka. In particular, the `io.apicurio.registry.utils.converter.AvroConverter` class can be used to provide the Apicurio Avro converter for the `"key.converter"`, `"value.converter"`, or `"header.converter"` properties. For example:

```
key.converter=io.apicurio.registry.utils.converter.AvroConverter
key.converter.apicurio.registry.url=https://<username>:<password>@<Schema registry endpoint>

value.converter=io.apicurio.registry.utils.converter.AvroConverter
value.converter.apicurio.registry.url=https://<username>:<password>@<Schema registry endpoint>
```

To use the Apicurio Registry  `converter` library, add the following dependency to your project Maven `pom.xml` file:

```
<dependency>
    <groupId>io.apicurio</groupId>
    <artifactId>apicurio-registry-utils-converter</artifactId>
    <version>1.3.2.Final</version>
</dependency>
```
Alternatively, if you are not building your connector, you can download the Apicurio converter artifacts from [Maven](https://repo1.maven.org/maven2/io/apicurio/apicurio-registry-distro-connect-converter/1.3.2.Final/apicurio-registry-distro-connect-converter-1.3.2.Final-converter.tar.gz){:target="_blank"}.

After downloading, extract the `tar.gz` file and place the folder with all the JARs into a subdirectory within the folder where you are building your `KafkaConnect` image.

To enable Kafka properties to be pulled from a file, add the following to your `KafkaConnector` or `KafkaConnect` custom resource definition:

```
config.providers: file
config.providers.file.class: org.apache.kafka.common.config.provider.FileConfigProvider
```

Then reference the Kafka connection details in the `KafkaConnector` custom resource of your connector. For example, the following shows a value converter with SCRAM credentials specified in the custom resource:

```
value.converter.apicurio.registry.url: <username>:<password>@<Schema registry endpoint>
value.converter.apicurio.registry.global-id: io.apicurio.registry.utils.serde.strategy.GetOrCreateIdStrategy
value.converter.apicurio.registry.request.ssl.truststore.location: "${file:/tmp/strimzi-connect.properties:ssl.truststore.location}"
value.converter.apicurio.registry.request.ssl.truststore.password: "${file:/tmp/strimzi-connect.properties:ssl.truststore.password}"
value.converter.apicurio.registry.request.ssl.truststore.type: "${file:/tmp/strimzi-connect.properties:ssl.truststore.type}"
```
