---
title: "Not authorized error when building Maven schema registry project"
excerpt: "When building a Maven project that pulls dependencies from the Event Streams schema registry, a not authorized error is issued."
categories: troubleshooting
slug: schema-registry-not-authorized-error
layout: redirects
toc: true
---

## Symptoms

When building a Maven project that pulls from the {{site.data.reuse.long_name}} schema registry, the build fails with an error similar to the following message:

```
Could not resolve dependencies for project <project>: Failed to collect dependencies at com.ibm.eventstreams.schemas:<schema-name>:jar:<version>: Failed to read artifact descriptor for com.ibm.eventstreams.schemas:<schema-name>:jar:<version> Could not transfer artifact com.ibm.eventstreams.schemas:<schema-name>:pom:<version> from/to eventstreams-schemas-repository (https://<schema-registry-route>/files/schemas): Not authorized
```

## Causes

The Maven `settings.xml` code snippets provided in the {{site.data.reuse.short_name}} UI for both SCRAM and Mutual TLS are missing the `<servers>` XML elements.

In addition, the same error can also be displayed when using SCRAM credentials, and the `Authorization` value does not have the following format: `Basic <scram-token>`

## Resolving the problem

Update the Maven `settings.xml` file to have the following format:

```
<settings>
  <servers>
    <server>
      <id>eventstreams-schemas-repository</id>
      <configuration>
        <httpHeaders>
          <property>
            <name>Authorization</name>
            <value>Basic <scram-token></value>
          </property>
        </httpHeaders>
      </configuration>
    </server>
  </servers>
  <profiles>
    <profile>
      # ...
```

Also, if using SCRAM credentials, ensure that the `Authorization` element has the format `Basic <scram-token>`, where the `<scram-token>` value is a Base64-encoded string in the following format: `<scram-username>:<scram-password>`
