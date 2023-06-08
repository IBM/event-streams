---
title: "Creating and adding schemas"
excerpt: "Learn how to create schemas and add them to the schema registry."
categories: schemas
slug: creating
toc: true
---

You can [create schemas](#creating-schemas) in Avro format and then use the {{site.data.reuse.short_name}} UI or CLI to [add them to the Apicurio Registry](#adding-schemas-to-the-registry).

{{site.data.reuse.apicurio_note}}


## Creating schemas

{{site.data.reuse.short_name}} supports Apache Avro schemas. Avro schemas are written in JSON to define the format of the messages. For more information about Avro schemas, see the [Avro documentation](http://avro.apache.org/docs/1.11.0/spec.html#schemas){:target="_blank"}.

Apicurio Registry in {{site.data.reuse.short_name}} imports, stores, and uses Avro schemas to serialize and deserialize Kafka messages. Apicurio Registry supports Avro schemas using the `record` complex type. The `record` type can include multiple fields of any data type, primitive or complex.

Define your Avro schema files and save them by using the `.avsc` or `.json` file extension.

For example, the following Avro schema defines a `Book` record in the `org.example` namespace, and contains the `Title`, `Author`, and `Format` fields with different data types:

```
{
    "type": "record",
    "name": "Book",
    "namespace": "org.example",
    "fields": [
        {"name": "Title", "type": "string"},
        {"name": "Author",  "type": "string"},
        {"name": "Format",
         "type": {
                    "type": "enum",
                    "name": "Booktype",
                    "symbols": ["HARDBACK", "PAPERBACK"]
                 }
        }
    ]
}
```

## Adding schemas to the registry

To use schemas in Kafka applications, import your schema definitions into the schema registry. Your applications can then retrieve the schemas from the registry as required.

### Using the UI

1. {{site.data.reuse.es_ui_login}}
2. Click **Schema registry** in the primary navigation, and then click **Add schema**.
3. Click **Upload definition** and select your Avro schema file. Avro schema files use the `.avsc` or `.json` file extensions.\\
   The file is loaded and its format validated. If the validation finds any problems with the file, a warning message is displayed.
4. Optional: Edit the **Schema name** and **Version** fields.\\
   - The `name` of the record defined in the Avro schema file is added to the **Schema name** field. You can edit this field to add a different name for the schema. Changing the **Schema name** field does not update the Avro schema definition itself.
   - The value `1.0.0` is automatically added to the **Version** field as the initial version of the schema. You can edit this field to set a different version number for the schema.
5. Click **Add schema**. The schema is added to the list of schemas in the schema registry.

### Using the CLI

1. [Install the {{site.data.reuse.short_name}} CLI plugin](../../installing/post-installation/#installing-the-event-streams-command-line-interface) if not already installed.
2. {{site.data.reuse.es_cli_init_111}}
3. Run the following command to add a schema to the schema registry:\\
   `kubectl es schema-add --name <schema-name> --version <schema-version> --file <path-to-schema-file>`

## Adding new schema versions

Apicurio Registry can store multiple versions of the same schema. As your applications and environments evolve, your schemas need to change to accommodate the requirements. You can import, manage, and use different versions of a schema. As your schemas change, consider the options for [managing their lifecycle](../manage-lifecycle/).

**Note:** A new version of a schema must be compatible with previous versions. This means that messages that have been serialized with an earlier version of a schema can be deserialized with a later version. To be compatible, fields in later versions of a schema cannot be removed, and any new schema field must have a default value.

For example, the following Avro schema defines a new version of the `Book` record, adding a `PageCount` field. By including a default value for this field, messages that were serialized with the previous version of this schema (which would not have a `PageCount` value) can still be deserialized using this version.

```
{
    "type": "record",
    "name": "Book",
    "namespace": "org.example",
    "fields": [
        {"name": "Title", "type": "string"},
        {"name": "Author",  "type": "string"},
        {"name": "Format",
         "type": {
                    "type": "enum",
                    "name": "Booktype",
                    "symbols": ["HARDBACK", "PAPERBACK"]
                 }
        },
        {"name": "PageCount",  "type": "int", "default": 0}
    ]
}
```

### Using the UI

1. {{site.data.reuse.es_ui_login}}
2. Click **Schema registry** in the primary navigation.
3. Locate your schema in the list of registered schemas and click its name. The list of versions for the schema is displayed.
4. Click **Add new version** to add a new version of the schema.
5. Click **Upload definition** and select the file that contains the new version of your schema. Avro schema files use the `.avsc` or `.json` file extensions.\\
   The file is loaded and its format validated. If the validation finds any problems with the file, a warning message is displayed.
6. Set a value in the **Version** field to be the version number for this iteration of the schema. For the current list of all versions, click **View all versions**.
7. Click **Add schema**. The schema version is added to the list of all versions for the schema.

### Using the CLI

1. [Install the {{site.data.reuse.short_name}} CLI plugin](../../installing/post-installation/#installing-the-event-streams-command-line-interface) if not already installed.
2. {{site.data.reuse.es_cli_init_111}}
3. Run the following command to list all schemas in the schema registry, and find the schema name you want to add a new version to:\\
   `kubectl es schemas`
4. Run the following command to add a new version of the schema to the registry:\\
   `kubectl es schema-add --name <schema-name-from-previous-step> --version <new-schema-version> --file <path-to-new-schema-file>`
