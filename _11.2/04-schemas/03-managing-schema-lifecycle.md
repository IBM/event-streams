---
title: "Managing schema lifecycle"
excerpt: "Understand how to manage the lifecycle of schemas."
categories: schemas
slug: manage-lifecycle
toc: true
---

Multiple versions of each schema can be stored in the Apicurio Registry. Kafka producers and consumers retrieve the right schema version they use from the registry based on a unique identifier and version.

When a [new schema version](../creating/#adding-new-schema-versions) is added, you can set both the producer and consumer applications to use that version. You then have the following options to handle earlier versions.

The lifecycle is as follows:

1. Add schema
2. Add new schema version
3. Deprecate version or entire schema
4. Disable version or entire schema
5. Remove version or entire schema

## Deprecating

If you want your applications to use a new version of a schema, you can set the earlier version to **Deprecated**. When a version is deprecated, the applications using that version receive a message to warn them to stop using it. Applications can continue to use the old version of the schema, but warnings will be written to application logs about the schema version being deprecated. You can customize the message to be provided in the logs, such as providing information for what schema or version to use instead.

Deprecated versions are still available in the registry and can be used again.

**Note:** You can deprecate an entire schema, not just the versions of that schema. If the entire schema is set to deprecated, then all of its versions are reported as deprecated (including any new ones added).

### Using the UI

1. {{site.data.reuse.es_ui_login}}
2. Click **Schema registry** in the primary navigation.
3. Select the schema you want to deprecate from the list.
4. Set the entire schema or a selected version of the schema to be deprecated:\\
   - If you want to deprecate the entire schema and all its versions, click the **Manage schema** tab, and set **Mark schema as deprecated** to on.
   - To deprecate a specific version, select it from the list, and click the **Manage version** tab for that version. Then set **Mark schema as deprecated** to on.

Deprecated schemas and versions are marked with a **Deprecated** flag on the UI.

You can re-activate a schema or its version by setting **Mark schema as deprecated** to off.

### Using the CLI

1. {{site.data.reuse.es_cli_init_111}}
2. Run the following command to deprecate a schema version:\\
   `kubectl es schema-modify --deprecate --name <schema-name> --version <schema-version-id>`

   To deprecate an entire schema, do not specify the `--version <schema-version-id>` option.

   To re-activate a schema version:\\
   `kubectl es schema-modify --activate --name <schema-name> --version <schema-version-id>`

   To re-activate an entire schema, do not specify the `--version <schema-version-id>` option.

**Note:** `<schema-version-id>` is the integer ID that is displayed when listing schema versions using the following command:
`kubectl es schema <schema-name>`.

## Disabling

If you want your applications to stop using a specific schema, you can set the schema version to **Disabled**. If you disable a version, applications will be prevented from producing and consuming messages using it. After being disabled, a schema can be enabled again to allow applications to use the schema.

When a schema is disabled, applications that want to use the schema receive an error response.

**Note:** You can disable a entire schema, not just the versions of that schema. If the entire schema is disabled, then all of its versions are disabled as well, which means no version of the schema can be used by applications (including any new ones added).

### Using the UI

1. {{site.data.reuse.es_ui_login}}
2. Click **Schema registry** in the primary navigation.
3. Select the schema you want to disable from the list.
4. Set the entire schema or a selected version of the schema to be disabled:\\
   - If you want to disable the entire schema and all its versions, click the **Manage schema** tab, and click **Disable schema**, then click **Disable**.
   - To disable a specific version, select it from the list, and click the **Manage version** tab for that version. Then click **Disable version**, then click **Disable**.\\
   You can re-enable a schema by clicking **Enable schema**, and re-enable a schema version by clicking  **Re-enable version**.

### Using the CLI

1.  {{site.data.reuse.es_cli_init_111}}`
2. Run the following command to disable a schema version:\\
   `kubectl es schema-modify --disable --name <schema-name> --version <schema-version-id>`

   To disable an entire schema, do not specify the `--version <schema-version-id>` option.

   To re-enable a schema version:\\
   `kubectl es schema-modify --enable --name <schema-name> --version <schema-version-id>`

   To re-enable an entire schema, do not specify the `--version <schema-version-id>` option.

**Note:** `<schema-version-id>` is the integer ID that is displayed when listing schema versions using the following command:
`kubectl es schema <schema-name>`.


## Removing

If a schema version has not been used for a period of time, you can remove it from the schema registry. Removing a schema version means it will be permanently deleted from the schema registry of your {{site.data.reuse.short_name}} instance, and applications will be prevented from producing and consuming messages using it.

**Important:** You cannot reverse the removal of a schema. This action is permanent.

**Note:** You can remove an entire schema, including all of its versions. If the entire schema is removed, then all of its versions are permanently deleted from the schema registry of your {{site.data.reuse.short_name}} instance.

### Using the UI

1. {{site.data.reuse.es_ui_login}}
2. Click **Schema registry** in the primary navigation.
3. Select the schema you want to remove from the list.
4. Remove the entire schema or a selected version of the schema:\\
   - If you want to remove the entire schema and all its versions, click the **Manage schema** tab, and click **Remove schema**, then click **Remove**.
   - To remove a specific version, select it from the list, and click the **Manage version** tab for that version. Then click **Remove version**, then click **Remove**.

   **Important:** This action is permanent and cannot be reversed.


### Using the CLI

1. {{site.data.reuse.es_cli_init_111}}
2. Run the following command to remove a schema version:\\
   `kubectl es schema-remove --name <schema-name> --version <schema-version-id>`

   To remove an entire schema, do not specify the `--version <schema-version-id>` option.

   **Important:** This action is permanent and cannot be reversed.

**Note:** `<schema-version-id>` is the integer ID that is displayed when listing schema versions using the following command:
`kubectl es schema <schema-name>`.
