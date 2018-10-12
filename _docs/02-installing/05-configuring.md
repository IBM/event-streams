---
title: "Configuring"
permalink: /installing/configuring/
excerpt: "Configure your IBM Event Streams installation."
last_modified_at:
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

**Note:** The geo-replication feature is disabled if the value is set to `0` (default). If you want to use geo-replication, ensure you set a minimum of 2 nodes for high availability reasons.

[Consider the number of geo-replication nodes](../../georeplication/planning/#preparing-destination-clusters) to run on a destination cluster. You can also set up destination clusters and configure the number of geo-replication worker nodes for an existing installation later.

## Configuring external access

By default, external Kafka client applications connect to the {{site.data.reuse.icp}} master node directly without any configuration required. You simply leave the **External hostname/IP address** field of the [**External access settings**](#external-access-settings) section blank.

If you want clients to connect through a different route such as a load balancer, use the field to specify the host name or IP address of the endpoint.

Also ensure you configure security for your cluster by setting certificate details in the [**Secure connection settings**](#secure-connection-settings) section. By default, a self-signed certificate is created during installation and the **Private key**, **TLS certificate**, and **CA certificate** fields can be left blank. If you want to use an existing certificate, select **provided** under **Certificate type**, and provide these additional keys and certificate values as base 64-encoded strings. Alternatively, you can [**generate your own certificates**](#generating-your-own-certificates).

<!--
When installing by using the CLI, add the `proxy.externalEndpoint=<external-ip-address-or-hostname>` value to the Helm install command, and set the values for secure connections. For more information, see the README.
-->

After installation, [set up external access](../post-installation/#connecting-clients) by checking the port number to use for external connections and ensuring the necessary certificates are configured within your client environment.

## Configuration reference

Configure your {{site.data.reuse.long_name}} installation by setting the following parameters as needed.

### Global install settings

The following table describes the parameters for setting global installation options.

Field  | Description   | Default
--|---|--
**Docker image registry**  | Docker images are fetched from this registry. The format is `<cluster_name>:<port>/<namespace>`.<br />**Note:** Ensure the **Docker image registry** value does not have a trailing slash, for example: `mycluster.icp:8500/ibmcom`  |`ibmcom`
**Image pull secret**  | If using a registry that requires authentication, the name of the secret containing credentials  |`None`
**Image pull policy** | Controls when Docker images are fetched from the registry  | `IfNotPresent`
**File system group ID**   | Specify the ID of the group that owns the file system intended to be used for persistent volumes. Volumes that support ownership management must be owned and writable by this group ID.  |  `None`
**Insights - help us improve our product**  | Select to enable product usage analytics to be transmitted to IBM for business reporting and product usage understanding.<br /> **Note:** The data gathered helps IBM understand how {{site.data.reuse.long_name}} is used, and can help build knowledge about typical deployment scenarios and common user preferences. The aim is to improve the overall user experience, and the data could influence decisions about future enhancements. For example, information about the configuration options used the most often could help IBM provide better default values for making the installation process easier. The data is only used by IBM and is not shared outside of IBM.<br />If you enable analytics, but want to opt out later, or want more information, [contact us](mailto:eventstreams@uk.ibm.com). | `Not selected (false)`


### Kafka broker settings

The following table describes the options for configuring Kafka brokers.

Field  | Description  | Default
--|---|--
**CPU limit for Kafka brokers**  | The maximum CPU resource that is allowed for each Kafka broker when the broker is heavily loaded expressed in CPU units  |  `1000m`
**Memory limit for Kafka brokers**  | The maximum amount of memory that will be allocated for each Kafka broker when the broker is heavily loaded. The value should be a plain integer using one of these suffixes: Gi, G, Mi, M  | `2Gi`
**CPU request for Kafka brokers**  | The expected CPU resource that will be required for each Kafka broker expressed in CPU units  | `1000m`
**Memory request for Kafka brokers**  | The base amount of memory allocated for each Kafka broker. The value should be a plain integer using one of these suffixes: Gi, G, Mi, M  | `2Gi`
**Heap size for Kafka broker JVM**  | This should be set to 75% of the memory limit for Kafka brokers | `1500m`
**Kafka brokers**  | Number of brokers in the Kafka cluster  | `3`
**Cluster configuration ConfigMap**  | Provide the name of a ConfigMap containing Kafka configuration to apply changes to Kafka's server.properties. See [how to create a ConfigMap](../planning/#configmap-for-kafka-static-configuration) for your installation.  | `None`

### Kafka persistent storage settings

The following table describes the options for configuring persistent storage.

Field  | Description  | Default
--|---|--
**Enable persistent storage for Apache Kafka**  | Set whether to store Apache Kafka broker data on Persistent Volumes.  | `Not selected (false)`
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
**Geo-replicator workers**  | Number of workers to support geo-replication. | `0` (geo-replication off)

### Generating your own certificates

You can create your own certificates for configuring external access. When prompted, answer all questions with the appropriate information.

1. Create the certificate to use for the Certificate Authority (CA):\\
   `openssl req -newkey rsa:2048 -nodes -keyout ca.key -x509 -days 365 -out ca.pem`
2. Generate a RSA 2048-bit private key:\\
     `openssl genrsa -out es.key 2048`\\
     Other key lengths and algorithms are also supported. See the following list for supported cipher suites.\\
     **Note:** In the following list, the string "TLS" is interchangeable with "SSL" and vice versa. For example, where TLS_RSA_WITH_AES_128_CBC_SHA is specified, SSL_RSA_WITH_AES_128_CBC_SHA also applies. For more information about each cipher suite, go to the  [Internet Assigned Numbers Authority (IANA) site](https://www.iana.org/assignments/tls-parameters/tls-parameters.xml) and search for the selected cipher suite ID.\\
     - TLS_RSA_WITH_RC4_128_SHA
     - TLS_RSA_WITH_3DES_EDE_CBC_SHA
     - TLS_RSA_WITH_AES_128_CBC_SHA
     - TLS_RSA_WITH_AES_256_CBC_SHA
     - TLS_RSA_WITH_AES_128_CBC_SHA256
     - TLS_RSA_WITH_AES_128_GCM_SHA256
     - TLS_RSA_WITH_AES_256_GCM_SHA384
     - TLS_ECDHE_ECDSA_WITH_RC4_128_SHA
     - TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA
     - TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA
     - TLS_ECDHE_RSA_WITH_RC4_128_SHA
     - TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA
     - TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA
     - TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA
     - TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256
     - TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256
     - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
     - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
     - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
     - TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
     - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305
     - TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305

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
