---
title: "Creating Kafka client applications"
excerpt: "Create Kafka client applications to use with IBM Event Streams."
categories: getting-started
slug: client
toc: true
---

The {{site.data.reuse.long_name}} UI provides help with creating an Apache Kafka Java client application and discovering connection details for a specific topic.

## Creating an Apache Kafka Java client application

You can create Apache Kafka Java client applications to use with {{site.data.reuse.long_name}}.

Download the JAR file from {{site.data.reuse.long_name}}, and include it in your Java build and classpaths before compiling and running Kafka Java clients.

1. {{site.data.reuse.es_ui_login_nonadmin}}
2. Click **Toolbox** in the primary navigation.
3. Go to the **Apache Kafka Java client** section and click **Find out more**.
4. Click the **Apache Kafka Client JAR** link to download the JAR file. The file contains the Java class files and related resources needed to compile and run client applications you intend to use with {{site.data.reuse.long_name}}.
5. [Download](https://www.slf4j.org/download.html){:target="_blank"} the JAR files for **SLF4J** required by the Kafka Java client for logging.
6. Include the downloaded JAR files in your Java build and classpaths before compiling and running your Apache Kafka Java client.
7. Ensure you [set up security](../connecting/#securing-the-connection).

## Creating an Apache Kafka Java client application using Maven or Gradle

If you are using Maven or Gradle to manage your project, you can use the following snippets to include the Kafka client JAR and dependent JARs on your classpath.

- For Maven, use the following snippet in the `<dependencies>` section of your `pom.xml` file:\\
  ```
  <dependency>
      <groupId>org.apache.kafka</groupId>
      <artifactId>kafka-clients</artifactId>
      <version>2.5.0</version>
  </dependency>
  <dependency>
      <groupId>org.slf4j</groupId>
      <artifactId>slf4j-api</artifactId>
      <version>1.7.26</version>
  </dependency>
  <dependency>
      <groupId>org.slf4j</groupId>
      <artifactId>slf4j-simple</artifactId>
      <version>1.7.26</version>
  </dependency>
  ```
- For Gradle, use the following snippet in the `dependencies{}` section of your `build.gradle` file:\\
  ```
  implementation group: 'org.apache.kafka', name: 'kafka-clients', version: '2.5.0'
  implementation group: 'org.slf4j', name: 'slf4j-api', version: '1.7.26'
  implementation group: 'org.slf4j', name: 'slf4j-simple', version: '1.7.26'
  ```
- Ensure you [set up security](../connecting/#securing-the-connection).
