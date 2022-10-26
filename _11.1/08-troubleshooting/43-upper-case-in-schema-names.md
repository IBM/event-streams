---
title: "Schema details not accessible when upper-case letters are used in schema names"
excerpt: "If a schema name has upper-case letters, it is not accessible through Event Streams."
categories: troubleshooting
slug: upper-case-in-schema-names
toc: true
---

## Symptoms

A schema that has been registered by a non-IBM client with upper-case letters in its name is not accessible in the {{site.data.reuse.short_name}} UI or CLI. Non-IBM clients include the Apicurio and Confluent `serdes` client libraries. Clicking on the schema name in the UI returns a `404 Not Found` error, and the CLI cannot access the schema to retrieve properties.

Similarly, a schema with upper-case letters in its name that has been added to the registry in the {{site.data.reuse.short_name}} UI or CLI is not accessible to non-IBM clients, such as the Apicurio and Confluent `serdes` client libraries.

## Causes

When using the schema name to search for a schema that has been registered with upper-case letters in the ID, the IBM compatible API client used in the {{site.data.reuse.short_name}} UI and CLI cannot find any schemas with IDs containing upper-case letters, so a `404 Not Found` error is returned.

Similarly, when using a non-IBM client library to look up a schema that has been pre-registered through the {{site.data.reuse.short_name}} UI or CLI, the non-IBM client library will not find the schema. This is because the schema ID has been registered by the {{site.data.reuse.short_name}} UI or CLI with lower-case characters only, whereas the non-IBM client client library is searching for the original name with upper-case characters.

## Resolving the problem

To use the {{site.data.reuse.short_name}} UI or CLI with schemas that have been registered by non-IBM clients, avoid using upper-case letters in schema IDs.

If a schema with an upper-case name is already in use, transition the schema to a new schema with a lower-case name, and delete the previous schema with the following commands for the Apicurio REST API:

`curl -u <scram-user-name>:<scram-password> \ https://<apicurioregistry-url>/artifacts/<artifact-id> -X DELETE -k`

If you require schema names with upper-case characters, configure the non-IBM client libraries to auto-register schemas. This creates a schema that the non-IBM client library can find and use, but would not be accessible in the {{site.data.reuse.short_name}} UI or CLI. In this case, use Apicurio Registry REST API calls to manage the schema directly.
