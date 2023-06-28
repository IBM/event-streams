---
title: "Using schemas with the REST producer API"
excerpt: "You can use schemas with the Event Streams REST producer API."
categories: schemas
slug: using-with-rest-producer
layout: redirects
toc: false
---

You can use schemas when producing messages with the {{site.data.reuse.short_name}} [REST producer API](../../connecting/rest-api/). You simply add the following parameters to the API call:

- `schemaname`: The name of the schema you want to use when producing messages.
- `schemaversion`: The schema version you want to use when producing messages.

For example, to use cURL to produce messages to a topic with the producer API, and specify the schema to be used, run the curl command as follows:

 Using SCRAM Basic Authentication:

`curl -H "Authorization: <basic-auth>" -H "Accept: application/json" -H "Content-Type: text/plain" -d '<avro-encoded-message>' --cacert es-cert.pem "https://<producer-endpoint>/topics/<my-topic>/records?schemaname=<schema-name>&schemaversion=<schema-version-name>"`

Using TLS Mutual Authentication:

`curl -H "Accept: application/json" -H "Content-Type: text/plain" -d '<avro-encoded-message>' --cacert es-cert.pem --key user.key --cert user.crt "https://<producer-endpoint>/topics/<my-topic>/records?schemaname=<schema-name>&schemaversion=<schema-version-name>"`

**Note:** Replace the values in brackets as follows:
- `<basic-auth>` with the **SCRAM Basic Authentication token** which is generated using the {{site.data.reuse.short_name}} [UI](../../security/managing-access#creating-a-kafkauser-in-the-ibm-event-streams-ui).
- `<producer-endpoint>` with the producer URL which is available from **Connect to this cluster** or **Connect to this topic** and copy the URL in the **Producer endpoint and credentials** section.
- `<my_topic>` with your topic name.
- `<schema-name>` with the name of your schema.
- `<schema-version-name>` with the version of your schema.
- `<avro-encoded-message>` with your avro encoded message.

The `es-cert.pem` certificate is downloaded by running the following command:\\
`cloudctl es certificates --format pem`

The `user.key` and `user.crt` files are downloaded in a .zip file by clicking **Generate credentials** in the **Producer endpoint and credentials** section of **Connect to this cluster** or **Connect to this topic**, selecting **Mutual TLS certificate**, following the instructions in the wizard and clicking **Download certificates**.

By adding these parameters to the API call, a lookup is done on the specified schema and its version to check if it is valid. If valid, the correct message headers are set for the produced message.

**Important:** When using the producer API, the lookup does not validate the data in the request to see if it matches the schema. Ensure the message conforms to the schema, and that it has been encoded in the Apache Avro binary or JSON encoding format. If the message does not conform and is not encoded with either of those formats, consumers will not be able to deserialize the data.

If the message has been encoded in the Apache Avro binary format, ensure the HTTP `Content-Type` header is set to `application/octet-stream`.

If the message has been encoded in the Apache Avro JSON format, ensure the HTTP `Content-Type` header is set to `application/json`.
