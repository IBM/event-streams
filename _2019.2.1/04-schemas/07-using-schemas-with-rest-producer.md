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

`curl "https://192.0.2.171:30342/topics/<topicname>/records?schemaname=<schema-name>&schemaversion=<schema-version-name>" -d '<avro_encoded_message>' -H "Content-Type: application/json" -H "Authorization: Bearer <apikey>" --cacert es-cert.pem` 

By adding these parameters to the API call, a lookup is done on the specified schema and its version to check if it is valid. If valid, the correct message headers are set for the produced message.

**Important:** When using the producer API, the lookup does not validate the data in the request to see if it matches the schema. Ensure the message conforms to the schema, and that it has been encoded in the Apache Avro binary or JSON encoding format. If the message does not conform and is not encoded with either of those formats, consumers will not be able to deserialize the data.

If the message has been encoded in the Apache Avro binary format, ensure the HTTP `Content-Type` header is set to `application/octet-stream`.

If the message has been encoded in the Apache Avro JSON format, ensure the HTTP `Content-Type` header is set to `application/json`.
