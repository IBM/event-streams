---
title: "Connecting clients"
excerpt: "Find out how to discover connection details to connect your client applications to Event Streams."
categories: getting-started
slug: connecting
toc: true
---

Learn how to discover connection details to connect your clients to your {{site.data.reuse.short_name}} instance.

## Obtaining the bootstrap address

Use one of the following methods to obtain the bootstrap address for your connection to your {{site.data.reuse.short_name}} instance, choosing the listener **`type`** appropriate for your client. More information on configuring listener types can be found in the [configuring Kafka access section](../../installing/configuring/#kafka-access).

### Using the {{site.data.reuse.short_name}} UI

1. {{site.data.reuse.es_ui_login_nonadmin}}
2. Click the **Connect to this cluster** tile.
3. Go to the **Kafka listener and credentials** section, and select the listener from the list.

   - Click the **External** tab for applications connecting from outside of the {{site.data.reuse.openshift_short}} cluster.
   - Click the **Internal** tab for applications connecting from inside the {{site.data.reuse.openshift_short}} cluster.

   **Note:** The list reflects the listeners [configured](../../installing/configuring) in `spec.strimziOverrides.kafka.listeners`. For example, you will have external listeners displayed if you have `spec.strimziOverrides.kafka.listeners.external` configured. If `spec.strimziOverrides.kafka.listeners` is empty for your instance (not configured), then no address is displayed here.

### Using the {{site.data.reuse.short_name}} CLI

**Note:** You can only use the {{site.data.reuse.short_name}} CLI to retrieve the address if your {{site.data.reuse.short_name}} instance has an external listener [configured](../../installing/configuring) in `spec.strimziOverrides.kafka.listeners.external`.

1. {{site.data.reuse.cp_cli_login}}
2. [Install the {{site.data.reuse.short_name}} CLI plugin](../../installing/post-installation/#installing-the-event-streams-command-line-interface) if not already installed.
3. Run the following command to initialize the {{site.data.reuse.long_name}} CLI on the cluster:\\
   `cloudctl es init`\\
   Make note of the **Event Streams bootstrap address** value. This is the Kafka bootstrap address that your application will use.

   **Note:** If you have multiple listeners defined in `spec.strimziOverrides.kafka.listeners`, only the external listener is displayed. If you only have internal listeners defined, nothing is displayed.

### Using the {{site.data.reuse.openshift_short}} web console

1. {{site.data.reuse.openshift_ui_login}}
2. {{site.data.reuse.task_openshift_navigate_installed_operators}}
3. {{site.data.reuse.task_openshift_select_operator}}
4. {{site.data.reuse.task_openshift_select_instance}}
5. Select the **YAML** tab.
6. Scroll down and look for `status.kafkaListeners`.
7. The `kafkaListeners` field will contain one or more listeners each with a `bootstrapServers` property.
   Find the `type` of listener you want to connect to and use the `bootstrapServers` value from the entry.

**Note:** if using the `external` Kafka listener, the OpenShift route is a HTTPS address so the port in use is 443.

### Using the {{site.data.reuse.openshift_short}} CLI

1. {{site.data.reuse.openshift_cli_login}}
2. To find the type and address for the Kafka bootstrap route for each listener run the following command:\\
   `oc get eventstreams <instance-name> -o=jsonpath='{range .status.kafkaListeners[*]}{.type} {.bootstrapServers}{"\n"}{end}'`\\
   Where `<instance-name>` is the name of your {{site.data.reuse.short_name}} instance.

**Note:** if using the `external` Kafka listener, the OpenShift route is a HTTPS address so the port in use is 443.

## Securing the connection

To connect client applications to a secured {{site.data.reuse.long_name}}, you must obtain the following:

- A copy of the server-side public certificate to add to your client-side trusted certificates.
- SCRAM-SHA-512 (`username` and `password`) or Mutual TLS (user certificates) Kafka credentials.

### Obtaining the server-side public certificate from the {{site.data.reuse.short_name}} UI

1. {{site.data.reuse.es_ui_login_nonadmin}}
2. Click **Connect to this cluster** on the right.
3. From the **Certificates** section, download the server certificate. If you are using a Java client, use the **PKCS12 certificate**, remembering to copy the truststore password presented during download. Otherwise, use the **PEM certificate**.

### Obtaining the server-side public certificate from the {{site.data.reuse.short_name}} CLI

1. {{site.data.reuse.cp_cli_login}}
2. [Install the {{site.data.reuse.short_name}} CLI plugin](../../installing/post-installation/#installing-the-event-streams-command-line-interface) if not already installed.
3. Run the following command to initialize the {{site.data.reuse.long_name}} CLI on the cluster:\\
   `cloudctl es init`
4. Use the `certificates` command to download the cluster's public certificate in the required format:\\
   `cloudctl es certificates --format p12`\\
   The truststore password will be displayed in the output for the command. The following example has a truststore password of `mypassword`:

   ```
   $ cloudctl es certificates --format p12

   Trustore password is mypassword
   Certificate successfully written to /es-cert.p12.
   OK
   ```

   **Note:** You can optionally change the format to download a `PEM` Certificate if required.

### Obtaining the server-side public certificate from the {{site.data.reuse.openshift_short}} web console

1. {{site.data.reuse.openshift_ui_login}}
2. {{site.data.reuse.task_openshift_navigate_installed_operators}}
3. {{site.data.reuse.task_openshift_select_operator}}
4. {{site.data.reuse.task_openshift_select_instance}}
5. Select the **Resources** tab.
6. To filter only secrets, deselect all resource types with the exception of **Secret**.
7. Locate and select the `<instance-name>-cluster-ca-cert` secret. Where `<instance-name>` is the name of your {{site.data.reuse.short_name}} instance.
8. In the **Secret Overview** panel scroll down to the **Data** section. Then, click the copy button to transfer the `ca.p12` certificate to the clipboard. The password can be found under `ca.password`.

**Note:** For a `PEM` certificate, click the copy button for `ca.crt` instead.

### Obtaining the server-side public certificate from the {{site.data.reuse.openshift_short}} CLI

To extract the server-side public certificate to a `ca.p12` file, run the following command:

`oc extract secret/<instance-name>-cluster-ca-cert --keys=ca.p12`

Where `<instance-name>` is the name of your {{site.data.reuse.short_name}} instance.

To extract the password for the certificate to a `ca.password` file, run the following command:

`oc extract secret/<instance-name>-cluster-ca-cert --keys=ca.password`

**Note:** If a `PEM` certificate is required, run the following command to extract the certificate to a `ca.crt` file:

`oc extract secret/<instance-name>-cluster-ca-cert --keys=ca.crt`

### Generating or Retrieving Client Credentials

See the [assigning access to applications](../../security/managing-access/#assigning-access-to-applications) section to learn how to create new application credentials or retrieve existing credentials.

### Configuring your SCRAM client

Add the [truststore certificate details](#securing-the-connection) and the [SCRAM credentials](#generating-or-retrieving-client-credentials) to your Kafka client application to set up a secure connection from your application to your {{site.data.reuse.short_name}} instance.

You can configure a Java application as follows:

```
Properties properties = new Properties();
properties.put(CommonClientConfigs.BOOTSTRAP_SERVERS_CONFIG, "<bootstrap-address>");
properties.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
properties.put(SslConfigs.SSL_PROTOCOL_CONFIG, "TLSv1.2");
properties.put(SslConfigs.SSL_TRUSTSTORE_LOCATION_CONFIG, "<certs.p12-file-location>");
properties.put(SslConfigs.SSL_TRUSTSTORE_PASSWORD_CONFIG, "<truststore-password>");
properties.put(SaslConfigs.SASL_MECHANISM, "SCRAM-SHA-512");
properties.put(SaslConfigs.SASL_JAAS_CONFIG, "org.apache.kafka.common.security.scram.ScramLoginModule required "
    + "username=\"<scram-username>\" password=\"<scram-password>\";");
```

| Property Placeholder        | Description                                                                                                                              |
| :-------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------- |
| `<bootstrap-address>`       | [Bootstrap servers address](#obtaining-the-bootstrap-address)                                                                            |
| `<certs.p12-file-location>` | Path to your truststore certificate. This must be a fully qualified path. As this is a Java application, the PKCS12 certificate is used. |
| `<truststore-password>`     | Truststore password.                                                                                                                     |
| `<scram-username>`          | SCRAM username.                                                                                                                          |
| `<scram-password>`          | SCRAM password.                                                                                                                          |

### Configuring your Mutual TLS client

Add the [truststore and keystore certificate details](#securing-the-connection) to your Kafka client application to set up a secure connection from your application to your {{site.data.reuse.short_name}} instance.

You can configure a Java application as follows:

```
Properties properties = new Properties();
properties.put(CommonClientConfigs.BOOTSTRAP_SERVERS_CONFIG, "<bootstrap-address>");
properties.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
properties.put(SslConfigs.SSL_PROTOCOL_CONFIG, "TLSv1.2");
properties.put(SslConfigs.SSL_TRUSTSTORE_LOCATION_CONFIG, "<certs.p12-file-location>");
properties.put(SslConfigs.SSL_TRUSTSTORE_PASSWORD_CONFIG, "<truststore-password>");
properties.put(SslConfigs.SSL_KEYSTORE_LOCATION_CONFIG, "<user.p12-file-location>");
properties.put(SslConfigs.SSL_KEYSTORE_PASSWORD_CONFIG, "<user.p12-password>");
```

| Property Placeholder        | Description                                                                                                                                        |
| :-------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------- |
| `<bootstrap-address>`       | [Bootstrap servers address](#obtaining-the-bootstrap-address).                                                                                     |
| `<certs.p12-file-location>` | Path to your truststore certificate. This must be a fully qualified path. As this is a Java application, the PKCS12 certificate is used.           |
| `<truststore-password>`     | Truststore password.                                                                                                                               |
| `<user.p12-file-location>`  | Path to `user.p12` keystore file from [credentials zip archive](#generating-or-retrieving-client-credentials).                                     |
| `<user.p12-password>`       | The `user.p12` keystore password found in the `user.password` file in the [credentials zip archive](#generating-or-retrieving-client-credentials). |

### Obtaining Java code samples from the {{site.data.reuse.short_name}} UI

For a Java application, you can copy the connection code snippet from the {{site.data.reuse.short_name}} UI by doing the following:

1. {{site.data.reuse.es_ui_login_nonadmin}}
2. Click the **Connect to this cluster** tile.
3. Click the **Sample code** tab.
4. Copy the snippet from the **Sample connection code** section into your Java Kafka client application. Uncomment the relevant sections and replace the property placeholders with the values from the relevant table for [SCRAM](#configuring-your-scram-client) or [Mutual TLS](#configuring-your-mutual-tls-client).
