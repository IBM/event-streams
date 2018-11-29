---
title: "Creating Kafka client applications"
permalink: /getting-started/client/
excerpt: "Create Kafka client applications to use with IBM Event Streams."

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
5. Include the downloaded JAR file in your Java build and classpaths before compiling and running your Apache Kafka Java client.
6. Ensure you [set up security](#securing-the-connection) as follows.

## Securing the connection

You must secure the connection from your client applications to {{site.data.reuse.long_name}}. To secure the connection, you must obtain the following:

- A copy of the server-side public certificate added to your client-side trusted certificates.
- An API key generated from the {{site.data.reuse.icp}} UI.

Before connecting an external client, ensure the necessary certificates are configured within your client environment. Use the TLS and CA certificates if you provided them during installation, or use the following instructions to retrieve a copy.

![Event Streams 2018.3.0 only icon](../../images/2018.3.0.svg "Only in Event Streams 2018.3.0.") In {{site.data.reuse.long_name}} 2018.3.0, copy the server-side public certificate and generate an API key as follows:
1. Log in to your {{site.data.reuse.long_name}} UI.
2. Click the **Topics** tab.
3. Select any topic in the list of topics.
5. Click the **Connection information** tab.
6. Copy the **Broker URL**. This is the Kafka bootstrap server.
7. In the **Certificates** section, download the Java trustore or PEM certificate and provide it to your client application.

To generate an API key:
1. {{site.data.reuse.icp_ui_login}}
2. From the navigation menu, click **Manage > Identity & Access-> Service IDs**.
3. Click **Create a Service ID**.
4. Provide a name, a description, and select your namespace. Then click **Create**.
5. Click the service id you created.
6. Click **Create Service Policy**.
7. Select a [role](../../security/managing-access/#what-roles-can-i-assign), select `eventstreams` as your service type, select the {{site.data.reuse.short_name}} release instance you want to apply the policy to, and provide a [**Resource Type**](../../security/managing-access/#what-resource-types-can-i-secure) (for example, topic) and a **Resource Identifier** (for example, the name of the topic).\\
   If you do not specify a resource type or identifier, the policy applies its role to all resources in the {{site.data.reuse.short_name}} instance.
8. Click **Add**.
9. Click the **API keys** tab.
10. Click **Create API key**.
11. Provide a name and a description. Then click **Create**.
12. Click **Download** to download a file containing the API key.

**Important:** To have access to the **Connection information** tab in the UI, you must have at least one topic. For example, if you are just starting out, use the [starter application to generate topics](../generating-starter-app/).

![Event Streams 2018.3.1 and later icon](../../images/2018.3.1.svg "Only in Event Streams 2018.3.1 and later.") In {{site.data.reuse.long_name}} 2018.3.1 and later, copy the server-side public certificate and generate an API key as follows:
1. Log in to your {{site.data.reuse.long_name}} UI.
2. Click **Connect to this cluster** on the right.
3. On the **Connect a client** tab, copy the address from the **Bootstrap server** section. This gives the bootstrap address for Kafka clients.
4. From the **Certificates** section, download the server certificate. If you are using a Java client, use the **Java truststore**. Otherwise, use the **PEM certificate**.
5. To generate API keys, go to the **API key** section and follow the instructions.

### Configuring your client

Add the certificate details and the API key to your Kafka client application, for example, for Java:

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
