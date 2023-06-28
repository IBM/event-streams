---
title: "Clients using schemas fail with Apicurio 2.4.1 or later"
excerpt: "Clients using schemas fail when Apicurio Registry is migrated from 2.3.1 to 2.4.1 or later"
categories: troubleshooting
slug: upgrade-apicurio
layout: redirects
toc: true
---

## Symptoms

After upgrading to {{site.data.reuse.short_name}} 11.1.6 and migrating to use the latest version of Apicurio that is included in {{site.data.reuse.short_name}}, client applications that use the schema registry fail with errors similar to the following example:

```yaml
java.io.UncheckedIOException: com.fasterxml.jackson.databind.exc.InvalidFormatException: Cannot deserialize value of type `java.util.Date` from String "2022-12-13T20:10:29Z": expected format "yyyy-MM-dd'T'HH:mm:ssZ"
 at [Source: (jdk.internal.net.http.ResponseSubscribers$HttpResponseInputStream); line: 1, column: 54] (through reference chain: io.apicurio.registry.rest.v2.beans.ArtifactMetaData["createdOn"])
        at io.apicurio.rest.client.handler.BodyHandler.lambda$toSupplierOfType$1(BodyHandler.java:60)
        at io.apicurio.rest.client.JdkHttpClient.sendRequest(JdkHttpClient.java:204)
        at io.apicurio.registry.rest.client.impl.RegistryClientImpl.createArtifact(RegistryClientImpl.java:263)
        at io.apicurio.registry.rest.client.RegistryClient.createArtifact(RegistryClient.java:134)
        at io.apicurio.registry.resolver.DefaultSchemaResolver.lambda$handleAutoCreateArtifact$2(DefaultSchemaResolver.java:236)
        at io.apicurio.registry.resolver.ERCache.lambda$getValue$0(ERCache.java:142)
        at io.apicurio.registry.resolver.ERCache.retry(ERCache.java:181)
        at io.apicurio.registry.resolver.ERCache.getValue(ERCache.java:141)
        at io.apicurio.registry.resolver.ERCache.getByContent(ERCache.java:121)
        at io.apicurio.registry.resolver.DefaultSchemaResolver.handleAutoCreateArtifact(DefaultSchemaResolver.java:234)
        at io.apicurio.registry.resolver.DefaultSchemaResolver.getSchemaFromRegistry(DefaultSchemaResolver.java:115)
        at io.apicurio.registry.resolver.DefaultSchemaResolver.resolveSchema(DefaultSchemaResolver.java:88)
        at io.apicurio.registry.serde.AbstractKafkaSerializer.serialize(AbstractKafkaSerializer.java:83)
        at org.apache.kafka.clients.producer.KafkaProducer.doSend(KafkaProducer.java:929)
        at org.apache.kafka.clients.producer.KafkaProducer.send(KafkaProducer.java:889)
        at org.apache.kafka.clients.producer.KafkaProducer.send(KafkaProducer.java:775)
```

## Causes

Apicurio client libraries versions 2.3.1 and earlier use a date format that is not compatible with Apicurio Registry server versions 2.4.1 or later.

## Resolving the problem

Ensure you are using the latest Apicurio version as follows:

1. Ensure all applications connecting to your instance of {{site.data.reuse.short_name}} that use the schema registry are using Apicurio client libraries version 2.4.1 or later.

2. Ensure that the [migration to using the latest Apicurio image](../../installing/upgrading/#migrate-to-latest-apicurio-registry) has completed by verifying that the image for the `apicurio-registry` container in the schema registry pod is `cp.icr.io/cp/ibm-eventstreams-apicurio-registry-v24@<sha reference>`. 

   To get the images used in the schema registry pod use the following command:
   ```shell
   oc get pods -n es -l eventstreams.ibm.com/component-type=apicurio-registry-v2  -o jsonpath="{.items[*].spec.containers[*].image}"
   ```
