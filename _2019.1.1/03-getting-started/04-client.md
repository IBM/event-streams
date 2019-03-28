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

1. Log in to your {{site.data.reuse.long_name}} UI.
2. Click the **Toolbox** tab.
3. Go to the **Apache Kafka Java client** section and click **Find out more**.
4. Click the **Apache Kafka Client JAR** link to download the JAR file. The file contains the Java class files and related resources needed to compile and run client applications you intend to use with {{site.data.reuse.long_name}}.
5. [Download](https://www.slf4j.org/download.html){:target="_blank"} the JAR files for **SLF4J** required by the Kafka Java client for logging.
6. Include the downloaded JAR files in your Java build and classpaths before compiling and running your Apache Kafka Java client.
7. Ensure you [set up security](#securing-the-connection).

## Creating an Apache Kafka Java client application using Maven or Gradle

If you are using Maven or Gradle to manage your project, you can use the following snippets to include the Kafka client JAR and dependent JARs on your classpath.

* For Maven, use the following snippet in the `<dependencies>` section of your `pom.xml` file:\\
   ```
   <dependency>
       <groupId>org.apache.kafka</groupId>
       <artifactId>kafka-clients</artifactId>
       <version>2.1.0</version>
   </dependency>
   <dependency>
       <groupId>org.slf4j</groupId>
       <artifactId>slf4j-api</artifactId>
       <version>1.7.25</version>
   </dependency>
   <dependency>
       <groupId>org.slf4j</groupId>
       <artifactId>slf4j-simple</artifactId>
       <version>1.7.25</version>
   </dependency>
   ```
* For Gradle, use the following snippet in the `dependencies{}` section of your `build.gradle` file:\\
   ```
   implementation group: 'org.apache.kafka', name: 'kafka-clients', version: '2.1.0'
   implementation group: 'org.slf4j', name: 'slf4j-api', version: '1.7.25'
   implementation group: 'org.slf4j', name: 'slf4j-simple', version: '1.7.25'
   ```
* Ensure you [set up security](#securing-the-connection).


## Securing the connection

You must secure the connection from your client applications to {{site.data.reuse.long_name}}. To secure the connection, you must obtain the following:

- A copy of the server-side public certificate added to your client-side trusted certificates.
- An API key generated from the {{site.data.reuse.icp}} UI.

Before connecting an external client, ensure the necessary certificates are configured within your client environment. Use the TLS and CA certificates if you provided them during installation, or use the following instructions to retrieve a copy.

Copy the server-side public certificate and generate an API key as follows:
1. Log in to your {{site.data.reuse.long_name}} UI.
2. Click **Connect to this cluster** on the right.
3. On the **Connect a client** tab, copy the address from the **Bootstrap server** section. This gives the bootstrap address for Kafka clients.
4. From the **Certificates** section, download the server certificate. If you are using a Java client, use the **Java truststore**. Otherwise, use the **PEM certificate**.
5. To generate API keys, go to the **API key** section and follow the instructions.

### Configuring your client

Add the certificate details and the API key to your Kafka client application to set up a secure connection from your application to your {{site.data.reuse.short_name}} instance. For example, for Java:

```
Properties properties = new Properties();
properties.put(CommonClientConfigs.BOOTSTRAP_SERVERS_CONFIG, "<broker_url>");
properties.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
properties.put(SslConfigs.SSL_PROTOCOL_CONFIG, "TLSv1.2");
properties.put(SslConfigs.SSL_TRUSTSTORE_LOCATION_CONFIG, "<certs.jks_file_location>");
properties.put(SslConfigs.SSL_TRUSTSTORE_PASSWORD_CONFIG, "<truststore_password>");
properties.put(SaslConfigs.SASL_MECHANISM, "PLAIN");
properties.put(SaslConfigs.SASL_JAAS_CONFIG, "org.apache.kafka.common.security.plain.PlainLoginModule required "
    + "username=\"token\" password=\"<api_key>\";");
```


Replace `<broker_url>` with your cluster's broker URL, `<certs.jks_file_location>` with the path to your truststore file, `<truststore_password>` with `"password"`, and `<api_key>` with the API key copied from its file.

**Note:** You can copy the connection code snippet from the {{site.data.reuse.short_name}} UI with the broker URL already filled in for you. After logging in, click **Connect to this cluster** on the right, and click the **Sample code** tab. Copy the snippet from the **Sample connection code** section into your Kafka client application.
