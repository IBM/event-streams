---
title: "Migrating existing applications to the Event Streams schema registry"
excerpt: "Read about how you can migrate to using the Event Streams schema registry."
categories: schemas
slug: migrating
toc: true
---

If you are using the Confluent Platform schema registry, {{site.data.reuse.short_name}} provides a migration path for moving your Kafka consumers and producers over to use the {{site.data.reuse.short_name}} schema registry.

## Migrating schemas to {{site.data.reuse.short_name}} schema registry

To migrate schemas, you can use schema auto-registration in your Kafka producer, or you can manually migrate schemas by downloading the schema definitions from the Confluent Platform schema registry and adding them to the {{site.data.reuse.short_name}} schema registry. 

### Migrating schemas with auto-registration

When using auto-registration, the schema will be automatically uploaded to the {{site.data.reuse.short_name}} schema registry, and named with the subject ID (which is based on the subject name strategy in use) and a random suffix. 

Auto-registration is enabled by default in the Confluent Platform schema registry client library. To disable it, set the `auto.register.schemas` property to `false`.

**Note:** To auto-register schemas in the {{site.data.reuse.short_name}} schema registry, you need an API key that has operator role permissions (or higher) and permission to create schemas. You can generate API keys by using the ES UI or CLI.

Using the UI:
1. {{site.data.reuse.es_ui_login}}
2. Click **Connect to this cluster** on the right.
3. Click **Generate API key**.
4. Enter a name for your application, and select **Produce, consume, create topics and schemas**.
5. Click **Next**.
4. Enter your topic name or set **All topics** to **On**.
5. Click **Next**.
5. Enter the consumer group name or set **All consumer groups** to **On**.
6. Click **Generate API key** to generate an API key.
7. Click **Copy API key**.

Using the CLI:
1. {{site.data.reuse.icp_cli_login321}}
2. Run the following command to initialize the {{site.data.reuse.short_name}} CLI on the cluster:\\
   `cloudctl es init`
3. Run the following command to create a service ID with an API key that has permissions to auto-register schemas and produce messages to any topic:\\
   `cloudctl es iam-service-id-create <service-id-name> --role operator --all-topics --all-schemas`


### Migrating schemas manually

To manually migrate the schemas, download the schema definitions from the Confluent Platform schema registry, and add them to the {{site.data.reuse.short_name}} Schema Registry. When manually adding schemas to the {{site.data.reuse.short_name}} Schema Registry, the provided schema name must match the subject ID used by the Confluent Platform schema registry subject name strategy.

If you are using the default `TopicNameStrategy`, the schema name must be `<TOPIC_NAME>-<'value'|'key'>`

If you are using the `RecordNameStrategy`, the schema name must be `<SCHEMA_DEFINITION_NAMESPACE>.<SCHEMA_DEFINITION_NAME>`

For example, if you are using the default `TopicNameStrategy` as your subject name strategy, and you are serializing your data into the message value and producing to the **MyTopic** topic, then the schema name you must provide when adding the schema in the UI must be `MyTopic-value`

For example, if you are using the `RecordNameStrategy` as your subject name strategy, and the schema definition file begins with the following, then the schema name you must provide when adding the schema in the UI must be `org.example.Book`:

```
{
    "type": "record",
    "name": "Book",
    "namespace": "org.example",
    "fields": [
...
```

If you are using the CLI, run the following command when adding the schema:

`cloudctl es schema-add --create --name org.example.Book --version 1.0.0 --file /path/to/Book.avsc`


## Migrating a Kafka producer application

To migrate a Kafka producer application that uses the Confluent Platform schema registry, secure the connection from your application to {{site.data.reuse.short_name}}, and add additional properties to enable the Confluent Platform schema registry client library to interact with the {{site.data.reuse.short_name}} schema registry.

1. Configure your producer application to [secure the connection](../../getting-started/client/#securing-the-connection) between the producer and {{site.data.reuse.short_name}}.
2. Retrieve the full URL for the {{site.data.reuse.short_name}} [API endpoint](../../connecting/rest-api/#prerequisites), including the host name and port number by using the `cloudctl es init` command.
2. Ensure you add the following schema properties to your Kafka producers:

   Property name        |  Property value
   ---------------------|----------------
    `schema.registry.url` |  `https://<host name>:<API port>`
    `basic.auth.credentials.source` |  `SASL_INHERIT`

   You can also use the following code snippet for Java applications:
   ```
   props.put(AbstractKafkaAvroSerDeConfig.SCHEMA_REGISTRY_URL_CONFIG, "https://<host name>:<API port>");
   props.put(AbstractKafkaAvroSerDeConfig.BASIC_AUTH_CREDENTIALS_SOURCE, "SASL_INHERIT");
   ```
3. Set the Java SSL truststore JVM properties to allow the Confluent Platform schema registry client library to make HTTPS calls to the {{site.data.reuse.short_name}} schema registry. For example:\\
   ```
   export KAFKA_OPTS="-Djavax.net.ssl.trustStore=/path/to/es-cert.jks \ 
      -Djavax.net.ssl.trustStorePassword=password"
   ```

## Migrating a Kafka consumer application

To migrate a Kafka consumer application that uses the Confluent Platform schema registry, secure the connection from your application to {{site.data.reuse.short_name}}, and add additional properties to enable the Confluent Platform schema registry client library to interact with the {{site.data.reuse.short_name}} schema registry.

1. Configure your consumer application to [secure the connection](../../getting-started/client/#securing-the-connection) between the consumer and {{site.data.reuse.short_name}}.
2. Retrieve the full URL for the {{site.data.reuse.short_name}} [API endpoint](../../connecting/rest-api/#prerequisites), including the host name and port number by using the `cloudctl es init` command.
2. Ensure you add the following schema properties to your Kafka producers:

   Property name        |  Property value
   ---------------------|----------------
    `schema.registry.url` |  `https://<host name>:<API port>`
    `basic.auth.credentials.source` |  `SASL_INHERIT`

   You can also use the following code snippet for Java applications:
   ```
   props.put(AbstractKafkaAvroSerDeConfig.SCHEMA_REGISTRY_URL_CONFIG, "https://<host name>:<API port>");
   props.put(AbstractKafkaAvroSerDeConfig.BASIC_AUTH_CREDENTIALS_SOURCE, "SASL_INHERIT");
   ```
3. Set the Java SSL truststore JVM properties to allow the Confluent Platform schema registry client library to make HTTPS calls to the {{site.data.reuse.short_name}} schema registry. For example:\\
   ```
   export KAFKA_OPTS="-Djavax.net.ssl.trustStore=/path/to/es-cert.jks \ 
       -Djavax.net.ssl.trustStorePassword=password"
   ```
