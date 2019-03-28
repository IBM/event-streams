---
title: "Configuring"
excerpt: "Configure your IBM Event Streams installation."
categories: installing
slug: configuring
toc: true
---

## Enabling persistent storage

Set persistent storage for Kafka and ZooKeeper in your {{site.data.reuse.long_name}} installation.

To enable persistent storage for Kafka:
1. Go to the [**Kafka persistent storage settings**](#kafka-persistent-storage-settings) section.
2. Select the **Enable persistent storage for Apache Kafka** check box.
3. Optional: Select the **Use dynamic provisioning for Apache Kafka** check box and provide a storage class name if the Persistent Volumes will be created dynamically.

To enable persistent storage for ZooKeeper:
1. Go to the [**ZooKeeper settings**](#zookeeper-settings) section.
2. Select the **Enable persistent storage for ZooKeeper servers** check box.
3. Optional: Select the **Use dynamic provisioning for ZooKeeper servers** check box and provide a storage class name if the Persistent Volumes will be created dynamically.

{{site.data.reuse.fsGroupGid}}

## Specifying a ConfigMap for Kafka configuration

If you have a ConfigMap for Kafka configuration settings, you can provide it to your {{site.data.reuse.long_name}} installation to use. Enter the name in the **Cluster configuration ConfigMap** field of the [**Kafka broker settings**](#kafka-broker-settings) section.

**Important**: The ConfigMap must be in the same namespace as where you intend to install the {{site.data.reuse.long_name}} release.

## Setting geo-replication nodes

When installing {{site.data.reuse.long_name}} as an instance intended for geo-replication, configure the number of geo-replication worker nodes in the **[Geo-replication settings](#geo-replication-settings)** section by setting the number of nodes required in the **Geo-replicator workers** field.

**Note:** If you want to set up a cluster as a destination for geo-replication, ensure you set a minimum of 2 nodes for high availability reasons.

[Consider the number of geo-replication nodes](../../georeplication/planning/#preparing-destination-clusters) to run on a destination cluster. You can also set up destination clusters and configure the number of geo-replication worker nodes for an existing installation later.

{{site.data.reuse.geo-rep_note}}

## Configuring external access

By default, external Kafka client applications connect to the {{site.data.reuse.icp}} master node directly without any configuration required. You simply leave the **External hostname/IP address** field of the [**External access settings**](#external-access-settings) section blank.

If you want clients to connect through a different route such as a load balancer, use the field to specify the host name or IP address of the endpoint.

Also ensure you configure security for your cluster by setting certificate details in the [**Secure connection settings**](#secure-connection-settings) section. By default, a self-signed certificate is created during installation and the **Private key**, **TLS certificate**, and **CA certificate** fields can be left blank. If you want to use an existing certificate, select **provided** under **Certificate type**, and provide these additional keys and certificate values as base 64-encoded strings. Alternatively, you can [**generate your own certificates**](#generating-your-own-certificates).

<!--
When installing by using the CLI, add the `proxy.externalEndpoint=<external-ip-address-or-hostname>` value to the Helm install command, and set the values for secure connections. For more information, see the README.
-->

After installation, [set up external access](../post-installation/#connecting-clients) by checking the port number to use for external connections and ensuring the necessary certificates are configured within your client environment.

## Configuring external monitoring tools

You can use third party monitoring tools to monitor the deployed {{site.data.reuse.short_name}} Kafka cluster by connecting to the JMX port on the Kafka brokers and reading Kafka metrics. To set this up, you need to:

- Have a third party monitoring tool set up to be used within your {{site.data.reuse.icp}} cluster.
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
**Architecture scheduling preferences**  | Select the platform you want to install {{site.data.reuse.short_name}} on. | `amd64`

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
**CPU limit for Kafka brokers**  | The maximum CPU resource that is allowed for each Kafka broker when the broker is heavily loaded expressed in CPU units.  |  `1000m`
**Memory limit for Kafka brokers**  | The maximum amount of memory that will be allocated for each Kafka broker when the broker is heavily loaded. The value should be a plain integer using one of these suffixes: Gi, G, Mi, M.  | `2Gi`
**CPU request for Kafka brokers**  | The expected CPU resource that will be required for each Kafka broker expressed in CPU units.  | `1000m`
**Memory request for Kafka brokers**  | The base amount of memory allocated for each Kafka broker. The value should be a plain integer using one of these suffixes: Gi, G, Mi, M.  | `2Gi`
**Kafka brokers**  | Number of brokers in the Kafka cluster.  | `3`
**Cluster configuration ConfigMap**  | Provide the name of a ConfigMap containing Kafka configuration to apply changes to Kafka's server.properties. See [how to create a ConfigMap](../planning/#configmap-for-kafka-static-configuration) for your installation.  | `None`
**Enable secure JMX connections** | Select to make each Kafka broker’s JMX port accessible to secure connections from applications running inside the {{site.data.reuse.icp}} cluster. When access is enabled, you can configure your applications to [connect to a secure JMX port](../../security/secure-jmx-connections/) and read Kafka metrics. Also, see [**External monitoring settings**](#external-monitoring) for application-specific configuration requirements. | `Not selected (false)`

### Kafka persistent storage settings

The following table describes the options for configuring persistent storage.

Field  | Description  | Default
--|---|--
**Enable persistent storage for Apache Kafka**  | Set whether to store Apache Kafka broker data on Persistent Volumes.  |`Not selected (false)`
**Use dynamic provisioning for Apache Kafka**  | Set whether to use a Storage Class when provisioning Persistent Volumes for Apache Kafka. Selecting will dynamically create Persistent Volume Claims for the Kafka brokers. | `Not selected (false)`
**Name**  | Prefix for the name of the Persistent Volume Claims used for the Apache Kafka brokers. | `datadir`
**Storage class name**  | Storage Class to use for Kafka brokers if dynamically provisioning Persistent Volume Claims.  | `None`
**Size**  | Size to use for the Persistent Volume Claims created for Kafka nodes.  | `4Gi`

### ZooKeeper settings

The following table describes the options for configuring ZooKeeper.

Field  | Description  | Default
--|---|--
**CPU limit for ZooKeeper servers**   | The maximum CPU resource that is allowed for each ZooKeeper server when the server is heavily loaded, expressed in CPU units.  | `100m`
**CPU request for ZooKeeper servers**  | The expected CPU resource that will be required for each ZooKeeeper server, expressed in CPU units.  | `100m`
**Enable persistent storage for ZooKeeper servers**  | Set whether to store Apache ZooKeeper data on Persistent Volumes.  | `Not selected (false)`
**Use dynamic provisioning for ZooKeeper servers**  | Set whether to use a Storage Class when provisioning Persistent Volumes for Apache ZooKeeper. Selecting will dynamically create Persistent Volume Claims for the ZooKeeper servers. | `Not selected (false)`
**Name**  | Prefix for the name of the Persistent Volume Claims used for Apache ZooKeeper.  | `datadir`
**Storage class name**  | Storage Class to use for Apache ZooKeeper if dynamically provisioning Persistent Volume Claims.  | `None`
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
**Private key**  | If you set **Certificate type** to `provided`, this is the base64-encoded TLS key or private key.  | `None`
**TLS certificate**  | If you set **Certificate type** to `provided`, this is the base64-encoded TLS certificate or public key certificate.  | `None`
**CA certificate**  | If you set **Certificate type** to `provided`, this is the base64-encoded TLS cacert or Certificate Authority Root Certificate.  | `None`


### Message indexing settings

The following table describes the options for configuring message indexing.

Field  | Description  | Default
--|---|--
**Enable message indexing**  | Set whether to enable message indexing to enhance browsing the messages on topics. | `Selected (true)`
**Memory limits for Index Manager nodes**  | The maximum amount of memory allocated for index manager nodes. The value should be a plain integer using one of these suffixes: Gi, G, Mi, M. | `2Gi`

### Geo-replication settings

The following table describes the options for configuring geo-replicating topics between clusters.

Field  | Description  | Default
--|---|--
**Geo-replicator workers**  | Number of workers to support geo-replication. | `0`

{{site.data.reuse.geo-rep_note}}

### External monitoring

The following table describes the options for configuring external monitoring tools.

Field | Description | Default
---|---|---
**Datadog - Autodiscovery annotation check templates for Kafka brokers** | YAML object that contains the Datadog Autodiscovery annotations for configuring the Kafka JMX checks. The Datadog prefix and container identifier is applied automatically to the annotation, so only use the template name as the object’s keys (for example, `check_names`). For more information about setting up monitoring with Datadog, see the [Datadog tutorial](../../tutorials/monitor-with-datadog/).  | `None`

## Generating your own certificates

You can create your own certificates for configuring external access. When prompted, answer all questions with the appropriate information.

1. Create the certificate to use for the Certificate Authority (CA):\\
   `openssl req -newkey rsa:2048 -nodes -keyout ca.key -x509 -days 365 -out ca.pem`
2. Generate a RSA 2048-bit private key:\\
     `openssl genrsa -out es.key 2048`\\
     Other key lengths and algorithms are also supported. The following cipher suites are supported, using TLS 1.2 and later only:
     - TLS_RSA_WITH_AES_128_GCM_SHA256
     - TLS_RSA_WITH_AES_256_GCM_SHA384
     - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
     - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\\

   **Note:** The string "TLS" is interchangeable with "SSL" and vice versa. For example, where TLS_RSA_WITH_AES_128_CBC_SHA is specified, SSL_RSA_WITH_AES_128_CBC_SHA also applies. For more information about each cipher suite, go to the  [Internet Assigned Numbers Authority (IANA) site](https://www.iana.org/assignments/tls-parameters/tls-parameters.xml){:target="_blank"}, and search for the selected cipher suite ID.

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
