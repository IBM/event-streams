---
title: "Configuring"
excerpt: "Configure your IBM Event Streams installation."
categories: installing
slug: configuring
toc: true
---

## Enabling persistent storage

If you want your data to be preserved in the event of a restart, set persistent storage for Kafka, ZooKeeper, and schemas in your {{site.data.reuse.long_name}} installation.

To enable persistent storage for Kafka:
1. Go to the [**Kafka persistent storage settings**](#kafka-persistent-storage-settings) section.
2. Select the **Enable persistent storage for Apache Kafka** check box.
3. To use a specific storage class, select the **Enable storage class for Apache Kafka** check box, and provide the name of the storage class to use for the persistent volume claims intended for Kafka. Also, provide a prefix to use for the persistent volume claims, and set the minimum size required for your intended usage.

   If present, existing persistent volumes with the specified storage class are used after installation, or if a provisioner is configured for the specified storage class, new persistent volumes are created.

   **Note:** If you enable persistent storage, and also select the **Enable storage class for Apache Kafka** check box, but do not provide the name of the storage class to use, the deployment will use the default storage class set.

   If you do not select the **Enable storage class for Apache Kafka** check box, and do not provide the name of the storage class to use, the deployment will use any persistent volume claims that have at least the set size value.

To enable persistent storage for ZooKeeper:
1. Go to the [**ZooKeeper settings**](#zookeeper-settings) section.
2. Select the **Enable persistent storage for ZooKeeper servers** check box.
3. To use a specific storage class, select the **Enable storage class for ZooKeeper servers** check box, and provide the name of the storage class to use for the persistent volume claims intended for ZooKeeper. Also, provide a prefix to use for the persistent volume claims, and set the minimum size required for your intended usage.

   If present, existing persistent volumes with the specified storage class are used after installation, or if a provisioner is configured for the specified storage class, new persistent volumes are created.

   **Note:** If you enable persistent storage, and also select the **Enable storage class for ZooKeeper servers** check box, but do not provide the name of the storage class to use, the deployment will use the default storage class set.

   If you do not select the **Enable storage class for ZooKeeper servers** check box, and do not provide the name of the storage class to use, the deployment will use any persistent volume claims that have at least the set size value.

To enable persistent storage for schemas:
1. Go to the [**Schema Registry settings**](#schema-registry-settings) section.
2. Select the **Enable persistent storage for Schema Registry API servers** check box.
3. Select the access mode to use for the persistent volumes (`ReadWriteMany` or `ReadWriteOncein`).
3. To use a specific storage class, select the **Enable storage class for Schema Registry API servers** check box, and provide the name of the storage class to use for the persistent volume claims intended for schemas. Also, provide a prefix to use for the persistent volume claims, and set the minimum size required for your intended usage.

   If present, existing persistent volumes with the specified storage class are used after installation, or if a provisioner is configured for the specified storage class, new persistent volumes are created.

   **Note:** If you enable persistent storage, and also select the **Enable storage class for Schema Registry API servers** check box, but do not provide the name of the storage class to use, the deployment will use the default storage class set.

   If you do not select the **Enable storage class for Schema Registry API servers** check box, and do not provide the name of the storage class to use, the deployment will use any persistent volume claims that have at least the set size value.

{{site.data.reuse.fsGroupGid}}

## Enabling encryption between pods

To enable TLS encryption for communication between {{site.data.reuse.short_name}} pods, set the [**Pod to pod encryption**](#global-install-settings) field of the **Global install settings** section to **Enabled**. By default, encryption between pods is disabled.

## Specifying a ConfigMap for Kafka configuration

If you have a ConfigMap for Kafka configuration settings, you can provide it to your {{site.data.reuse.long_name}} installation to use. Enter the name in the **Cluster configuration ConfigMap** field of the [**Kafka broker settings**](#kafka-broker-settings) section.

**Important**: The ConfigMap must be in the same namespace as where you intend to install the {{site.data.reuse.long_name}} release.

## Installing into a multizone cluster

Set the [**Number of zones**](#global-install-settings) field of the **Global install settings** section to match the number of clusters you want to install your zones into. Enter the number of zones that contain a Kafka broker to ensure there is at least one broker in each zone.

If your cluster is zone aware, then the zones are automatically allocated during installation.

If your cluster is not zone aware, specify the zone label values for each zone in the [**Zone labels**](#global-install-settings) field of the **Global install settings** section. The list must be the same length as the number of zones. These are the labels you added as part of [preparing](../preparing-multizone/#setting-up-non-zone-aware-clusters) for a multizone installation. Add the labels as an array and using YAML syntax, for example:
   {% raw %}
   `- es-zone-0`<br>
   `- es-zone-1`<br>
   `- es-zone-2`
   {% endraw %}

**Important:** If you are installing as a Team Administrator, ensure you clear the **Generate cluster roles** checkbox.

## Setting geo-replication nodes

When installing {{site.data.reuse.long_name}} as an instance intended for geo-replication, configure the number of geo-replication worker nodes in the **[Geo-replication settings](#geo-replication-settings)** section by setting the number of nodes required in the **Geo-replicator workers** field.

**Note:** If you want to set up a cluster as a destination for geo-replication, ensure you set a minimum of 2 nodes for high availability reasons.

[Consider the number of geo-replication nodes](../../georeplication/planning/#preparing-destination-clusters) to run on a destination cluster. You can also set up destination clusters and configure the number of geo-replication worker nodes for an existing installation later.

## Configuring external access

By default, external Kafka client applications connect to the {{site.data.reuse.icp}} master node directly without any configuration required. You simply leave the **External hostname/IP address** field of the [**External access settings**](#external-access-settings) section blank.

If you want clients to connect through a different route such as a load balancer, use the field to specify the host name or IP address of the endpoint.

Also ensure you configure security for your cluster by setting certificate details in the [**Secure connection settings**](#secure-connection-settings) section. By default, a self-signed certificate is created during installation and the **Private key**, **TLS certificate**, and **CA certificate** fields can be left blank. If you want to use an existing certificate, select **provided** under **Certificate type**, and provide these additional keys and certificate values as base 64-encoded strings. Alternatively, you can [**generate your own certificates**](#generating-your-own-certificates).

<!--
When installing by using the CLI, add the `proxy.externalEndpoint=<external-ip-address-or-hostname>` value to the Helm install command, and set the values for secure connections. For more information, see the README.
-->

After installation, [set up external access](../post-installation/#connecting-clients) by checking the port number to use for external connections and ensuring the necessary certificates are configured within your client environment.

## Configuring external monitoring tools

You can use third-party monitoring tools to monitor the deployed {{site.data.reuse.short_name}} Kafka cluster by connecting to the JMX port on the Kafka brokers and reading Kafka metrics. To set this up, you need to:

- Have a third-party monitoring tool set up to be used within your {{site.data.reuse.icp}} cluster.
- Enable access to the broker JMX port by selecting the **Enable secure JMX connections** check box in the [**Kafka broker settings**](../../installing/configuring/#kafka-broker-settings) section.
- Provide any [configuration settings](#external-monitoring) required by your monitoring tool to be applied to {{site.data.reuse.short_name}}. For example, Datadog requires you to deploy an agent on your {{site.data.reuse.icp}} system that requires configuration settings to work with {{site.data.reuse.short_name}}.
- Configure your applications to [connect to a secure JMX port](../../security/secure-jmx-connections/).

## Configuration reference

Configure your {{site.data.reuse.short_name}} installation by setting the following parameters as needed.

### Global install settings

The following table describes the parameters for setting global installation options.

Field  | Description   | Default
--|---|--
**Docker image registry**  | Docker images are fetched from this registry. The format is `<cluster_name>:<port>/<namespace>`.  |`ibmcom`
**Image pull secret**  | If using a registry that requires authentication, the name of the secret containing credentials.  |`None`
**Image pull policy** | Controls when Docker images are fetched from the registry.  | `IfNotPresent`
**File system group ID**   | Specify the ID of the group that owns the file system intended to be used for persistent volumes. Volumes that support ownership management must be owned and writable by this group ID.  |  `None`
**Architecture**  | The worker node architecture on which to deploy {{site.data.reuse.short_name}}. | `amd64`
**Pod to pod encryption**      | Select whether you want to enable TLS encryption for communication between pods. | `Disabled`
**Kubernetes internal DNS domain name**  | If you have changed the default DNS domain name from `cluster.local` in your Kubernetes installation, then this field must be set to the same value. You cannot change this value after installation.  | `cluster.local`
**Number of zones**  | The number of zones to deploy {{site.data.reuse.short_name}} across.  |  1
**Zone labels**  | Array containing the labels for each zone. Add the labels as an array and using YAML syntax, for example: <br> {% raw %}- `es-zone-0`<br> - `es-zone-1`<br> - `es-zone-2`{% endraw %}|  `None`
**Generate cluster roles**  | Select to generate a cluster role and cluster rolebinding with your {{site.data.reuse.short_name}} installation. Must be cleared if you are installing as a Team Administrator.  |  `Selected (true)`

### IBM Cloud Private monitoring service

The following table describes the options for monitoring service.

Field  | Description  | Default
-------|--------------|--------
**Export the Event Streams dashboards**  | Select to create Grafana dashboards in the {{site.data.reuse.icp}} monitoring service to view information about {{site.data.reuse.short_name}} health, including Kafka health and performance details.  |  `Not selected (false)`

### Insights - help us improve our product

The following table describes the options for product improvement analytics.

Field  | Description  | Default
--|---|--
**Share my product usage data**  | Select to enable product usage analytics to be transmitted to IBM for business reporting and product usage understanding.  |  `Not selected (false)`

**Note:** The data gathered helps IBM understand how {{site.data.reuse.long_name}} is used, and can help build knowledge about typical deployment scenarios and common user preferences. The aim is to improve the overall user experience, and the data could influence decisions about future enhancements. For example, information about the configuration options used the most often could help IBM provide better default values for making the installation process easier. The data is only used by IBM and is not shared outside of IBM.<br />If you enable analytics, but want to opt out later, or want more information, [contact us](mailto:eventstreams@uk.ibm.com).


### Kafka broker settings

The following table describes the options for configuring Kafka brokers.

Field  | Description  | Default
--|---|--
**CPU request for Kafka brokers**  | The minimum required CPU core for each Kafka broker. Specify integers, fractions (for example, 0.5), or millicore values (for example, 100m, where 100m is equivalent to .1 core).  | `1000m`
**CPU limit for Kafka brokers**  | The maximum amount of CPU core allocated to each Kafka broker when the broker is heavily loaded. Specify integers, fractions (for example, 0.5), or millicores values (for example, 100m, where 100m is equivalent to .1 core).  |  `1000m`
**Memory request for Kafka brokers**  | The minimum amount of memory required for each Kafka broker in bytes. Specify integers with one of these suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | `2Gi`
**Memory limit for Kafka brokers**  | The maximum amount of memory in bytes allocated to each Kafka broker when the broker is heavily loaded. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki.  | `2Gi`
**Kafka brokers**  | Number of brokers in the Kafka cluster.  | `3`
**Cluster configuration ConfigMap**  | Provide the name of a ConfigMap containing Kafka configuration to apply changes to Kafka's server.properties. See [how to create a ConfigMap](../planning/#configmap-for-kafka-static-configuration) for your installation.  | `None`
**Enable secure JMX connections** | Select to make each Kafka broker’s JMX port accessible to secure connections from applications running inside the {{site.data.reuse.icp}} cluster. When access is enabled, you can configure your applications to [connect to a secure JMX port](../../security/secure-jmx-connections/) and read Kafka metrics. Also, see [**External monitoring settings**](#external-monitoring) for application-specific configuration requirements. | `Not selected (false)`

### Kafka persistent storage settings

The following table describes the options for configuring persistent storage.

Field  | Description  | Default
--|---|--
**Enable persistent storage for Apache Kafka**  | Set whether to store Apache Kafka data on a persistent volume. Enabling storage ensures the data is preserved if the pod is stopped. |`Not selected (false)`
**Enable storage class for Apache Kafka**  | Set whether to use a specific storage class when provisioning persistent volumes for Apache Kafka. | `Not selected (false)`
**Name**  | Prefix for the name of the Persistent Volume Claims used for the Apache Kafka brokers. | `datadir`
**Storage class name**  | Name of the storage class to use for the persistent volume claims intended for Apache Kafka.  | `None`
**Size**  | Size to use for the Persistent Volume Claims created for Kafka nodes.  | `4Gi`

### ZooKeeper settings

The following table describes the options for configuring ZooKeeper.

Field  | Description  | Default
--|---|--
**CPU request for ZooKeeper servers**  | The minimum required CPU core for each ZooKeeeper server. Specify integers, fractions (for example, 0.5), or millicore values (for example, 100m, where 100m is equivalent to .1 core).  | `100m`
**CPU limit for ZooKeeper servers**   | The maximum amount of CPU core allocated to each ZooKeeper server when the server is heavily loaded. Specify integers, fractions (for example, 0.5), or millicores values (for example, 100m, where 100m is equivalent to .1 core).  | `100m`
**Enable persistent storage for ZooKeeper servers**  | Set whether to store Apache ZooKeeper data on a persistent volume. Enabling storage ensures the data is preserved if the pod is stopped.  | `Not selected (false)`
**Enable storage class for ZooKeeper servers**  | Set whether to use a specific storage class when provisioning persistent volumes for Apache ZooKeeper. | `Not selected (false)`
**Name**  | Prefix for the name of the Persistent Volume Claims used for Apache ZooKeeper.  | `datadir`
**Storage class name**  | Name of the storage class to use for the persistent volume claims intended for Apache ZooKeeper.  | `None`
**Size**  | Size to use for the Persistent Volume Claims created for Apache ZooKeeper.  | `2Gi`

### External access settings

The following table describes the options for configuring external access to Kafka.

Field  | Description  | Default
--|---|--
**External hostname/IP address**  | The external hostname or IP address to be used by external clients. Leave blank to default to the IP address of the cluster master node. | `None`

### Secure connection settings

The following table describes the options for configuring secure connections.

Field  | Description  | Default
--|---|--
**Certificate type**  | Select whether you want to have a self-signed certificate generated during installation, or if you will provide your own certificate details. | `selfsigned`
**Secret containing provided TLS certificates**  | If you set **Certificate type** to `secret`, enter the name of the secret that contains the certificates to use. | `None`
**Private key**  | If you set **Certificate type** to `provided`, this is the base64-encoded TLS key or private key. If set to `secret`, this is the key name in the secret (default key name is “key”). | `None`
**Public certificate**  | If you set **Certificate type** to `provided`, this is the base64-encoded public certificate. If set to `secret`, this is the key name in the secret (default key name is “cert”). | `None`
**CA certificate**  | If you set **Certificate type** to `provided`, this is the base64-encoded Certificate Authority Root Certificate. If set to `secret`, this is the key name in the secret (default key name is “cacert”). | `None`

**Important:** If you provide your own certificates, ensure that the public certificate contains the required information for client applications to connect to Kafka as follows:

1. Depending on how your clients are connecting, ensure the certificate contains either the IP address or the Subject Alternative Name (SAN) for the host that the client applications will use.
2. The certificate must be valid for the value specified in the **External hostname/IP address** field of the [**External access settings**](#external-access-settings) section.

### Message indexing settings

The following table describes the options for configuring message indexing.

Field  | Description  | Default
--|---|--
**Enable message indexing**  | Set whether to enable message indexing to enhance browsing the messages on topics. | `Selected (true)`
**CPU request for Elastic Search nodes** | The minimum required CPU core for each Elastic Search node. Specify integers, fractions (for example, 0.5), or millicore values (for example, 100m, where 100m is equivalent to .1 core).  | `500m`
**CPU limit for Elastic Search nodes**  | The maximum amount of CPU core allocated to each Elastic Search node. Specify integers, fractions (for example, 0.5), or millicores values (for example, 100m, where 100m is equivalent to .1 core).  |  `1000m`
**Memory request for Elastic Search nodes**  | The minimum amount of memory required for each Elastic Search node in bytes. Specify integers with one of these suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki.  | `2Gi`
**Memory limits for Elastic Search nodes**  | The maximum amount of memory allocated to each Elastic Search node in bytes. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki.  | `4Gi`

### Geo-replication settings

The following table describes the options for configuring geo-replicating topics between clusters.

Field  | Description  | Default
--|---|--
**Geo-replicator workers**  | Number of workers to support geo-replication. | `0`

### Schema Registry settings

Field  | Description  | Default
--|---|--
**Enable persistent storage for Schema Registry API servers**  | Set whether to store Schema Registry data on a persistent volume. Enabling storage ensures the schema data is preserved if the pod is stopped.  | `Not selected (false)`
**Enable storage class for Schema Registry API servers**  | Set whether to use a specific storage class when provisioning persistent volumes for schemas. | `Not selected (false)`
**Storage Mode**  | Select the access mode to use for the persistent volumes (`ReadWriteMany` or `ReadWriteOncein`).  | `ReadWriteMany`
**Name**  | Prefix for the name of the Persistent Volume Claims used for schemas.  | `datadir`
**Storage class name**  | Name of the storage class to use for the persistent volume claims intended for schemas.  | `None`
**Size**  | Size to use for the Persistent Volume Claims created for schemas.  | `100Mi`

### External monitoring

The following table describes the options for configuring external monitoring tools.

Field | Description | Default
---|---|---
**Datadog - Autodiscovery annotation check templates for Kafka brokers** | YAML object that contains the Datadog Autodiscovery annotations for configuring the Kafka JMX checks. The Datadog prefix and container identifier is applied automatically to the annotation, so only use the template name as the object’s keys (for example, `check_names`). For more information about setting up monitoring with Datadog, see the [Datadog tutorial](../../tutorials/monitor-with-datadog/).  | `None`

### ![Event Streams 2019.4.2 icon](../../../images/2019.4.2.svg "In Event Streams 2019.4.2.") REST Producer API settings

The following table describes the options for configuring configuration values for the REST producer API.

Field | Description | Default
---|---|---
**Maximum key size**      | Set the maximum event key size that the REST producer API will accept in bytes.      | `4096`
**Maximum message size**  | Set the maximum event message size that the REST producer API will accept in bytes.  |  `65536`

**Important:** Do not set the **Maximum message size** to a higher value than the maximum message size that can be received by the Kafka broker or the individual topic (`max.message.bytes`). By default, the maximum message size for Kafka brokers is `1000012` bytes. If the limit is set for an individual topic, then that setting overrides the broker setting. Any message larger than the maximum limit will be rejected by Kafka.

**Note:** Sending large requests to the REST producer increases latency, as it will take the REST producer longer to process the requests.


## Generating your own certificates

You can create your own certificates for configuring external access. When prompted, answer all questions with the appropriate information.

1. Create the certificate to use for the Certificate Authority (CA):\\
   `openssl req -newkey rsa:2048 -nodes -keyout ca.key -x509 -days 365 -out ca.pem`
2. Generate a RSA 2048-bit private key:\\
     `openssl genrsa -out es.key 2048`\\
     Other key lengths and algorithms are also supported. The following cipher suites are supported, using TLS 1.2 and later only:
     - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
     - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384

   **Note:** The string "TLS" is interchangeable with "SSL" and vice versa. For example, where TLS_RSA_WITH_AES_128_GCM_SHA256 is specified, SSL_RSA_WITH_AES_128_GCM_SHA256 also applies. For more information about each cipher suite, go to the  [Internet Assigned Numbers Authority (IANA) site](https://www.iana.org/assignments/tls-parameters/tls-parameters.xml){:target="_blank"}, and search for the selected cipher suite ID.

3. Create a certificate signing request for the key generated in the previous step:\\
   `openssl req -new -key es.key -out es.csr`
4. Sign the request with the CA certificate created in step 1:\\
   `openssl x509 -req -in es.csr -CA ca.pem -CAkey ca.key -CAcreateserial -out es.pem`
5. Encode your generated file to a base64 string. This can be done using command line tools such as base64, for example, to encode the file created in step 1:\\
   `cat ca.pem | base64 > ca.b64`

Completing these steps creates the following files which, after being encoded to a base64 string, can be used to configure your installation:

1. **ca.pem** : CA public certificate
2. **es.pem** : Release public certificate
3. **es.key** : Release private key
