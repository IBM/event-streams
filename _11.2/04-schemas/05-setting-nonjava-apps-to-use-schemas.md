---
title: "Setting non-Java applications to use schemas"
excerpt: "Set up your non-Java applications to use schemas."
categories: schemas
slug: setting-nonjava-apps
toc: true
---

If you have producer or consumer applications created in languages other than Java, use the following guidance to set them up to use schemas. You can also use the [REST producer API](../using-with-rest-producer) to send messages that are encoded with a schema.

{{site.data.reuse.apicurio_note}}

For a producer application:
1. Retrieve the schema definition that you will be using from Apicurio Registry in {{site.data.reuse.short_name}} and save it in a local file.
2. Use an Apache Avro library for your programming language to read the schema definition from the local file and encode a Kafka message with it.
3. Set the schema registry headers in the Kafka message, so that consumer applications can understand which schema and version was used to encode the message, and which encoding format was used.
4. Send the message to Kafka.

For a consumer application:
1. Retrieve the schema definition that you will be using from Apicurio Registry in {{site.data.reuse.short_name}} and save it in a local file.
2. Consume a message from Kafka.
3. Check the headers for the Kafka message to ensure they match the expected schema ID and schema version ID.
4. Use the Apache Avro library for your programming language to read the schema definition from the local file and decode the Kafka message with it.

## Retrieving the schema definition from the schema registry

### Using the UI

1. {{site.data.reuse.es_ui_login}}
2. Click **Schema registry** in the primary navigation and find your schema in the list.
3. Copy the schema definition into a new local file.\\
  - For the latest version of the schema, expand the row. Copy and paste the schema definition into a new local file.
  - For a different version of the schema, click on the row and then select the version to use from the list of schema versions. Click the **Schema definition** tab and then copy and paste the schema definition into a new local file.

### Using the CLI

1. {{site.data.reuse.es_cli_init_111}}
2. Run the following command to list all the schemas in the schema registry:\\
    `kubectl es schemas`
3. Select your schema from the list and run the following command to list all the versions of the schema:\\
    `kubectl es schema <schema-name>`
4. Select your version of the schema from the list and run the following command to retrieve the schema definition for the version and copy it into a new local file:\\
    `kubectl es schema <schema-name> --version <schema-version-id> > <schema-definition-file>.avsc`

**Note:** `<schema-version-id>`is the integer ID that is displayed when listing schema versions using the following command:
`kubectl es schema <schema-name>`.

