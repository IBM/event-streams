---
title: "Configuring"
excerpt: "Configure your IBM Event Streams installation."
categories: installing
slug: configuring
toc: true
---

{{site.data.reuse.short_name}} provides samples to help you get started with deployments, as described in the [planning](../planning/#sample-deployments) section. Choose one of the samples suited to your requirements to get started:

- Lightweight without security
- Development
- Minimal production
- Production 3 brokers
- Production 6 brokers
- Production 9 brokers

You can modify the samples, save them, and apply custom configuration settings as well. See the following sections for guidance about configuring your instance of {{site.data.reuse.short_name}}.

**Note:** The **Production 6 brokers** and **Production 9 brokers** samples are only available on [GitHub](http://ibm.biz/es-cr-samples){:target="_blank"} (download and extract the resources for your {{site.data.reuse.short_name}} version, then go to `/cr-examples/eventstreams` to access the samples). You can configure and apply them by using the [command line](../installing/#installing-an-instance-by-using-the-cli) or by dragging and dropping them onto the {{site.data.reuse.openshift_short}} [web console](../installing/#installing-by-using-the-yaml-view), and editing them.

**Note:** When applying custom Kafka configuration settings to your {{site.data.reuse.short_name}}, check the [Kafka documentation](https://kafka.apache.org/documentation) to ensure the new configuration settings are consistent and do not cause conflicts.

## Checking configuration settings

This page gives information about many configuration options. To see further information about specific configuration options, or to see what options are available, you can use the `oc explain` command. To see information about a specific field, run the following:

`oc explain eventstreams.<path-of-field>`

Where `path-of-field` is the JSON path of the field of interest.

For example, if you want to see more information about configuring external listeners for Kafka you can run the following command:

`oc explain eventstreams.spec.strimziOverrides.kafka.listeners.external`

## Enabling persistent storage

If you want your data to be preserved in the event of a restart, configure persistent storage for Kafka and ZooKeeper in your {{site.data.reuse.long_name}} installation.

**Note:** Ensure you have sufficient [disk space](../capacity-planning/#disk-space-for-persistent-volumes) for persistent storage.

These settings are specified in the YAML configuration document that defines an instance of the `EventStreams` custom resource and can be applied when defining a new {{site.data.reuse.short_name}} instance under the "IBM Event Streams" operator in the {{site.data.reuse.openshift_short}} web console.

- To enable persistent storage for Kafka, add the `storage` property under `spec.strimziOverrides.kafka`
- To enable persistent storage for ZooKeeper, add the `storage` property under `spec.strimziOverrides.zookeeper`

Complete the configuration by adding additional fields to these storage properties as follows:

1. Specify the storage type in `storage.type` (for example, `"ephemeral"` or `"persistent-claim"`).

   **Note:** When using ephemeral storage, ensure you set retention limits for Kafka topics so that you do not run out of disk space.
   If [message retention](../../getting-started/creating-topics/) is set to long periods and the message volume is high, the storage requirements for the topics could impact the OpenShift nodes that host the Kafka pods, and cause the nodes to run out of allocated disk space, which could impact normal operation.

2. Specify the storage size in `storage.size` (for example, `"100Gi"`).
3. Optionally, specify the storage class in `storage.class` (for example, `"rook-ceph-block-internal"`).
4. Optionally, specify the retention setting for the storage if the cluster is deleted in `storage.deleteClaim` (for example, `"true"`).

An example of these configuration options:

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: EventStreams
# ...
spec:
  strimziOverrides:
    kafka:
      # ...
      storage:
        type: "persistent-claim"
        size: "100Gi"
        class: "ceph-block"
    zookeeper:
      # ...
      storage:
        type: "persistent-claim"
        size: "100Gi"
        class: "ceph-block"
# ...
```

If present, existing persistent volumes with the specified storage class are used after installation, or if a [dynamic provisioner](https://docs.openshift.com/container-platform/4.12/storage/dynamic-provisioning.html){:target="_blank"} is configured for the specified storage class, new persistent volumes are created.

Where optional values are not specified:

- If no storage class is specified and a default storage class has been defined in the {{site.data.reuse.openshift_short}} settings, the default storage class will be used.
- If no storage class is specified and no default storage class has been defined in the {{site.data.reuse.openshift_short}} settings, the deployment will use any [persistent volume claims](https://kubernetes.io/docs/concepts/storage/persistent-volumes/){:target="_blank"} that have at least the set size value.

   **Note:** An empty string is not the same as not specifying a value for a field. If you include the `class` field, the field value must be a valid storage class, it cannot be an empty string. An empty string will not be accepted by the operator.

- If no retention setting is provided, the storage will be retained when the cluster is deleted.


The following example YAML document shows an example `EventStreams` custom resource with dynamically allocated storage provided using CephFS for Kafka and ZooKeeper. To try this deployment, set the required `namespace` and accept the license by changing the `spec.license.accept` value to `"true"`.

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: EventStreams
metadata:
  name: example-storage
  namespace: myproject
spec:
  license:
    accept: false
  version: 11.1.0
  adminApi: {}
  adminUI: {}
  apicurioRegistry: {}
  collector: {}
  restProducer: {}
  strimziOverrides:
    kafka:
      replicas: 1
      config:
        offsets.topic.replication.factor: 1
        transaction.state.log.min.isr: 1
        transaction.state.log.replication.factor: 1
      listeners:
        - name: external
          type: route
          port: 9092
          authentication:
            type: scram-sha-512
          tls: true
        - name: plain
          port: 9093
          type: internal
          tls: false
        - name: tls
          port: 9094
          type: internal
          tls: true
          authentication:
            type: tls
      storage:
        type: persistent-claim
        size: 100Gi
        class: rook-ceph-block-internal
        deleteClaim: true
      metricsConfig:
        type: jmxPrometheusExporter
        valueFrom:
          configMapKeyRef:
            key: kafka-metrics-config.yaml
            name: metrics-config
    zookeeper:
      replicas: 1
      storage:
        type: persistent-claim
        size: 100Gi
        class: rook-ceph-block-internal
      deleteClaim: true
      metricsConfig:
        type: jmxPrometheusExporter
        valueFrom:
          configMapKeyRef:
            key: zookeeper-metrics-config.yaml
            name: metrics-config
```

## Configuring encryption between pods

Pod-to-Pod encryption is enabled by default for all {{site.data.reuse.short_name}} pods. Unless explicitly overridden in an `EventStreams` custom resource, the configuration option `spec.security.internalTls` will be set to `TLSv1.2`. This value can be set to `NONE` which will disable Pod-to-Pod encryption.

For example, the following YAML snippet disables encryption between pods:

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: EventStreams
metadata:
  name: example-internal-disabled
  namespace: myproject
spec:
  # ...
  security:
    # ...
    internalTls: NONE
# ...
```

## Configuring UI and CLI security

By default, accessing the {{site.data.reuse.short_name}} UI and CLI requires an {{site.data.reuse.icpfs}} Identity and Access Management (IAM) user that has been assigned access to {{site.data.reuse.short_name}}.

{{site.data.reuse.short_name}} also supports the Salted Challenge Response Authentication Mechanism (SCRAM) for accessing the UI and CLI.

For more information, see [managing access](../../security/managing-access/#accessing-the-event-streams-ui-and-cli) for details

- If no authentication type is provided, IAM is the default authentication type. You can also specifically configure IAM by setting the `adminUI` authentication type to `iam` in the `EventStreams` custom resource as follows:

   ```yaml
   ...
   spec:
     ...
     adminUI:
       authentication:
         - type: iam
   ```

- You can change the authentication type from the default IAM to SCRAM by setting the `adminUI` authentication type to `scram-sha-512` in the `EventStreams` custom resource as follows:

   ```yaml
   ...
   spec:
     ...
     adminUI:
       authentication:
         - type: scram-sha-512
   ```

This allows a Kafka user that has been configured for SCRAM authentication to log in to the {{site.data.reuse.short_name}} UI and CLI by using the username and password of that Kafka user. For more information about configuring Kafka users, see [managing access to Kafka resources](../../security/managing-access/#managing-access-to-kafka-resources).

When using SCRAM, the Access Control List (ACL) that is configured for the user will determine which parts of the UI are available to the user to access and what CLI commands the user can run (for more information, see [permission mappings](../../security/managing-access/#managing-access-to-the-ui-and-cli-with-scram)).

**Note:** The {{site.data.reuse.short_name}} UI and CLI only support the use of one authentication type for a single {{site.data.reuse.short_name}} instance. This means that you can only set one authentication type at the same time. The operator will issue an error message if more than one type is provided.

The login requirement for the UI is disabled when all Kafka authentication and authorization is disabled. This is demonstrated by the proof-of-concept [**lightweight without security**](../planning/#example-deployment-lightweight-without-security) sample.

**Important:** When security is not configured, the **[Producers](../../administering/topic-health/)** and the **[Monitoring](../../administering/cluster-health/#viewing-the-preconfigured-dashboard)** dashboards are not available in the UI.

## Applying Kafka broker configuration settings

Kafka supports a number of [broker configuration settings](http://kafka.apache.org/documentation/#brokerconfigs){:target="_blank"}, typically provided in a properties file.

When creating an instance of {{site.data.reuse.short_name}}, these settings are defined in an `EventStreams` custom resource under a the `spec.strimziOverrides.kafka.config` property.

The following example uses Kafka broker settings to configure replication for system topics:

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: EventStreams
metadata:
  name: example-broker-config
  namespace: myproject
spec:
  # ...
  strimziOverrides:
    # ...
    kafka:
      # ...
      config:
        offsets.topic.replication.factor: 1
        transaction.state.log.min.isr: 1
        transaction.state.log.replication.factor: 1
```

This custom resource can be created using the `oc` command or the {{site.data.reuse.openshift_short}} web console under the **IBM Event Streams** operator page.

You can specify all the broker configuration options supported by Kafka except those managed directly by {{site.data.reuse.short_name}}. For further information, see the list of [supported configuration options](https://strimzi.io/docs/operators/latest/configuring.html#type-KafkaClusterSpec-reference){:target="_blank"}.

After deployment, these settings can be [modified](../../administering/modifying-installation/#modifying-kafka-broker-configuration-settings) by updating the `EventStreams` custom resource.

## Applying Kafka rack awareness

Kafka rack awareness is configured by setting the `rack` property in the `EventStreams` custom resource using the zone label as the topology key in the `spec.strimziOverrides.kafka.rack` field. This key needs to match the [zone label](../preparing-multizone/#zone-awareness) name applied to the nodes.

**Note:** Before this is applied, ensure the [Kafka cluster role](../preparing-multizone/#kafka-rack-awareness) for rack awareness has been applied.

The following example sets the `rack` topologyKey to `topology.kubernetes.io/zone`:

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: EventStreams
metadata:
  name: example-broker-config
  namespace: myproject
spec:
  # ...
  strimziOverrides:
    # ...
    kafka:
      # ...
      rack:
        topologyKey: topology.kubernetes.io/zone
      # ...
```

## Setting geo-replication nodes

You can install geo-replication in a cluster to enable messages to be automatically synchronized between local and remote topics. A cluster can be a geo-replication origin or destination. Origin clusters send messages to a remote system, while destination clusters receive messages from a remote system. A cluster can be both an origin and a destination cluster at the same time.

To enable geo-replication, create an `EventStreamsGeoReplicator` custom resource alongside the `EventStreams` custom resource. This can be defined in a YAML configuration document under the **IBM Event Streams** operator in the {{site.data.reuse.openshift_short}} web console.

When setting up geo-replication, consider the [number of geo-replication worker nodes (replicas)](../../georeplication/planning/#preparing-a-destination-cluster) to deploy and configure this in the `spec.replicas` property.

Ensure that the following properties match the name of the {{site.data.reuse.short_name}} instance:

- `metadata.name`
- `metadata.labels["eventstreams.ibm.com/cluster"]`

For example, to configure geo-replication with `2` replicas for an {{site.data.reuse.short_name}} instance called `sample-three` in the namespace `myproject`, create the following `EventStreamsGeoReplicator` configuration:

```yaml
apiVersion: eventstreams.ibm.com/v1beta1
kind: EventStreamsGeoReplicator
metadata:
  labels:
    eventstreams.ibm.com/cluster: sample-three
  name: sample-three
  namespace: myproject
spec:
  # ...
  replicas: 2
```

**Note:** Geo-replication can be deployed or reconfigured at any time. For more information, see [Setting up geo-replication](../../georeplication/setting-up/).

## Configuring access

If included in the {{site.data.reuse.short_name}} installation, external access is automatically configured for the following services by using {{site.data.reuse.openshift_short}} routes:

- The {{site.data.reuse.short_name}} UI
- The Apicurio Registry
- The Admin API
- The REST Producer

### REST services access

The REST services for {{site.data.reuse.short_name}} are configured with defaults for the container port, type, TLS version, certificates, and authentication mechanisms. If the Kafka listeners have been configured without authentication requirements then the authentication mechanisms are automatically removed from the REST endpoints.

The schema for REST endpoint configuration is described in the following table, followed by an example of an endpoint configuration for the Admin API. In the example, the potential values for `<component>` in `spec.<component>.endpoints` are:

- `adminApi` for the Admin API
- `restProducer` for the REST Producer
- `apicurioRegistry` for the Apicurio Registry

| Key                         | Type                         | Description                                                                                                                                                                                                                 |
| :-------------------------- | :--------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                      | String                       | Name to uniquely identify the endpoint among other endpoints in the list for a component.                                                                                                                                   |
| `containerPort`             | Integer                      | A unique port to open on the container that this endpoint will serve requests on. Restricted ranges are 0-1000 and 7000-7999.                                                                                               |
| `type`                      | String [`internal`, `route`] | {{site.data.reuse.short_name}} REST components support internal type endpoints and {{site.data.reuse.openshift_short}} Routes.                                                                                              |
| `tlsVersion`                | String [`TLSv1.2`,`NONE`]    | Specifies the TLS version where `NONE` will disable HTTPS.                                                                                                                                                                  |
| `authenticationMechanisms`  | List of Strings              | List of authentication mechanisms to be supported at this endpoint. By default, all authentication mechanisms: [`iam-bearer`,`tls`,`scram-sha-512`] are enabled. Optionally a subset or even none (`[]`) can be configured. |
| `certOverrides.certificate` | String                       | The name of the key in the provided `certOverrides.secretName` secret that contains the base64 encoded certificate.                                                                                                         |
| `certOverrides.key`         | String                       | The name of the key in the provided `certOverrides.secretName` secret that contains the base64 encoded key.                                                                                                                 |
| `certOverrides.secretName`  | String                       | The name of the secret in the instance namespace that contains the encoded certificate and key to secure the endpoint with.                                                                                                 |
| `host`                      | String (DNS rules apply)     | An optional override for the default host that an {{site.data.reuse.openshift_short}} route will generate.                                                                                                                  |

```yaml
# ...
spec:
  # ...
  adminApi:
    # ...
    endpoints:
      - name: example
        containerPort: 9080
        type: route
        tlsVersion: TLSv1.2
        authenticationMechanisms:
          - iam-bearer
          - tls
          - scram-sha-512
        certOverrides:
            certificate: mycert.crt
            key: mykey.key
            secretName: custom-endpoint-cert
        host: example-host.apps.example-domain.com
```

**Note:** Changing an endpoint in isolation might have adverse effects if Kafka is configured to require authentication and the configured endpoint has no authentication mechanisms specified. In such cases, a warning message might be displayed in the instance status conditions.

The {{site.data.reuse.short_name}} REST components also allow for the default set of cipher suites to be overridden. Though not a recommended practice, it is possible to enable alternative cipher suites to facilitate connectivity of legacy systems. This capability is provided through the `CIPHER_SUITES` environment variable as shown in this example:

```yaml
# ...
spec:
  # ...
  restProducer:
    # ...
    env:
      - name: CIPHER_SUITES
        value: >-
          TLS_RSA_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
```

### Kafka access

Sample configurations provided for {{site.data.reuse.short_name}} typically include an external listener for Kafka and varying internal listener types by default. The supported external listener is of type `route`. This indicates the use of an {{site.data.reuse.openshift_short}} route, and it can have either `tls`, `scram-sha-512`, or `oauth` configured as the authentication mechanism.
Any number of external listeners can be configured, each with any of the supported authentication mechanisms.

The following example snippet defines 2 external listeners that expose the Kafka brokers using 2 {{site.data.reuse.openshift_short}} routes, one with SCRAM-SHA-512 authentication and one with Mutual TLS enabled.

```yaml
# ...
spec:
  # ...
  strimziOverrides:
    # ...
    kafka:
      listeners:
        - name extscram
          type: route
          port: 9092
          tls: true
          authentication:
            type: scram-sha-512
        - name exttls
          type: route
          port: 9093
          tls: true
          authentication:
            type: tls
```

Internal listeners for Kafka can also be configured by setting the listener `type:` to `internal`. Each of these can be configured to have any of the authentication mechanism types (Mutual TLS, SCRAM-SHA-512, or OAuth). The following example shows 2 internal listeners configured: the first is set to use SCRAM authentication, while the second listener is set to use mutual TLS.


```yaml
# ...
spec:
  # ...
  strimziOverrides:
    # ...
    kafka:
      listeners:
        - name: intplain
          type: internal
          port: 9092
          tls: false
          authentication:
            type: scram-sha-512
        - name: inttls
          type: internal
          port: 9093
          tls: true
          authentication:
            type: tls
```

When secure listeners are configured, {{site.data.reuse.short_name}} will automatically generate cluster and client CA certificates, and a valid certificate for the listener endpoint. The generated CA certificates and the certificate for the endpoint can be replaced by provided certificates as described in [providing certificate overrides](#using-your-own-certificates).

## Enabling OAuth

Open Authorization (OAuth) is an open standard for authentication and authorization that allows client applications secure delegated access to specified resources. OAuth works over HTTPS and uses access tokens for authorization rather than credentials.

### Enable OAuth authentication

To configure OAuth authentication, configure a Kafka listener with type `oauth`, and set the listener to use one of the following token validation methods:

- **Fast local JSON Web Token (JWT) validation:** a signed token is verified against the OAuth authentication server's public certificate, and a check ensures that the token has not expired on the Kafka cluster. This means that the OAuth authorization server does not need to be contacted, which speeds up the validation.

   **Important:** Local JWT validation does not check the validity of the token with the OAuth authorization server each time the client attempts to authenticate. This means tokens that have not expired are valid even if the client that used the token has been revoked. As the token expiry time is used to identify the token's validity, consider setting short token expiry times when configuring JWT validation, keeping the `grace period` as short as possible.

- **Token validation by using an introspection endpoint:** the validation of the token is performed on the OAuth authorization server. This is a slower mechanism than the JWT validation method, but ensures that there is no grace period for revoked clients. As soon as a client is revoked, the token will become invalid, regardless of the expiration of the token.

{{site.data.reuse.short_name}} supports 2 types of SASL mechanisms: `OAUTHBEARER` or `PLAIN`. By default, OAuth authentication uses `OAUTHBEARER` SASL mechanism, which is the most secure mechanism.

**Important:** For clients that do not support the `OAUTHBEARER` authentication mechanism, you can configure the cluster to use the `PLAIN` mechanism by setting the `enableOauthBearer` property to `false` (default setting is `true` for `OAUTHBEARER`). For more information, see [OAuth 2.0 authentication mechanisms](https://strimzi.io/docs/operators/latest/deploying.html#con-oauth-authentication-flow-str){:target="_blank"}.

#### Configuring OAuth to use fast local JWT validation

To configure an OAuth listener to use fast local JWT validation authentication, add the following snippet to your `EventStreams` custom resource, and edit the  settings as follows:
- Add the respective URIs of the OAuth authentication server to the `jwksEndpointUri` and `validIssuerUri` properties.
- Create a secret that contains the public CA certificate of the OAuth authentication Server, and reference this secret in the `tlsTrustedCertificates` property of the listener configuration. The `certificate` element in the `tlsTrustedCertificates` references the secret key that contains the CA certificate.

```yaml
# ...
spec:
  # ...
  strimziOverrides:
    # ...
    kafka:
      listeners:
        - name: extoauth
          port: 9094
          tls: true
          authentication:
            type: oauth
            jwksEndpointUri: <OAuth-authentication-server-JWKS-certificate-endpoint>
            maxSecondsWithoutReauthentication: 3600
            tlsTrustedCertificates:
              - certificate: <CA-certificate-secret-key>
                secretName: <CA-certificate-secret-name>
            userNameClaim: preferred_username
            validIssuerUri: <OAuth-authentication-server-token-issuer-endpoint>
          type: route
```

The snippet provided shows a configuration containing the most commonly used properties. For information about further OAuth properties, see [Using OAuth 2.0 token-based authentication](https://strimzi.io/docs/operators/latest/deploying.html#assembly-oauth-authentication_str){:target="_blank"}.

#### Configuring OAuth to use token validation by using an introspection endpoint

To configure an OAuth listener to use introspection endpoint token validation, add the following snippet to your `EventStreams` custom resource, and edit the  settings as follows:
- Add the respective URIs of the OAuth authentication server to the `validIssuerUri` and `introspectionEndpointUri` properties.
- Create a secret that contains the public CA certificate of the OAuth authentication Server, and reference this secret in the `tlsTrustedCertificates` property of the listener configuration. The `certificate` element in the `tlsTrustedCertificates` references the secret key that contains the CA certificate.
- Create another secret that contains the secret value of the `userid` as defined in the `clientId` property of the configuration, and reference this secret in the `clientSecret` property of the configuration. In the `key` property, add the key from the Kuberenetes secret that contains the secret value for the `userid`.

```yaml
# ...
spec:
  # ...
  strimziOverrides:
    # ...
    kafka:
      listeners:
        - name: extoauth
          port: 9094
          tls: true
          authentication:
            type: oauth
            clientId: <client-id>
            clientSecret:
              secretName: <secret-name-containing-clientid-password>
              key: <secret-key-containing-client-password>
            validIssuerUri: <OAuth-authentication-server-token-issuer-endpoint>
            introspectionEndpointUri: <OAuth-authentication-server-token-introspection-endpoint>
            userNameClaim: preferred_username
            maxSecondsWithoutReauthentication: 3600
            tlsTrustedCertificates:
              - certificate: <CA-certificate-secret-key>
                secretName: <CA-certificate-secret-name>
          type: route

```

The snippet provided shows a configuration containing the most commonly used properties. For information about further OAuth properties, see [Using OAuth 2.0 token-based authentication](https://strimzi.io/docs/operators/latest/deploying.html#assembly-oauth-authentication_str){:target="_blank"}.


### Enable OAuth authorization

To use OAuth for authorizing access to Kafka resources in {{site.data.reuse.short_name}}, enable OAuth in the {{site.data.reuse.short_name}} custom resource, and then configure your Access Control List (ACL) rules in your selected OAuth server.

To enable OAuth authorization for {{site.data.reuse.short_name}}, add the following snippet to your `EventStreams` custom resource, and edit the  settings as follows:
- Ensure you set the `delegateToKafkaAcls` property to `true`. If this property is set to `false`, some {{site.data.reuse.short_name}} components will not work as expected.
- If you configure OAuth authorization, include in the `superUsers` property the user IDs of the Identity and Access Management (IAM) [admin users](../../security/managing-access/#accessing-the-event-streams-ui-and-cli) and Kubernetes Cluster admin users that administer {{site.data.reuse.short_name}} through the UI or the CLI. If you are not using OAuth authorization, you do not need to specify any `superUsers`.

```yaml
# ...
spec:
  # ...
  strimziOverrides:
    # ...
    kafka:
      authorization:
        clientId: <client-id>
        delegateToKafkaAcls: true
        tlsTrustedCertificates:
          - certificate: ca.crt
            secretName: keycloak-ca-cert
        tokenEndpointUri: <OAuth-authentication-server-token-endpoint>
        type: keycloak
        superUsers:
          - "admin"
          - "kubeadmin"
```

The snippet provided shows a configuration containing the most commonly used properties. For information about further OAuth properties, see [configuring an OAuth 2.0 authorization server](https://strimzi.io/docs/operators/latest/deploying.html#proc-oauth-server-config-str){:target="_blank"}.

## Configuring node affinity for components

You can configure {{site.data.reuse.short_name}} components to run on nodes with specific labels by using node affinity. Node affinity is configured as part of the component's pod template in the `EventStreams` custom resource.

For REST services, you can configure affinity as follows:

```yaml
# ...
spec:
  # ...
  <component>:
    # ...
    template:
      pod:
        affinity:
        # ...
```

where `<component>` is one of the following values: `adminApi`, `adminUI`, `restProducer`, or `apicurioRegistry`.

For Kafka and ZooKeeper, you can configure affinity as follows:

```yaml
# ...
spec:
  # ...
  strimziOverrides:
    # ...
    <component>:
      # ...
      template:
        pod:
          affinity:
          # ...
```
where `<component>` is either `kafka` or `zookeeper`.

The format of the `affinity` property matches the [Kubernetes specification](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity){:target="_blank"}. For example, if a node is labelled with `mykey=myvalue`, the `affinity` would contain the following settings:

```
# ...
template:
  pod:
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
              - key: mykey
                operator: In
                values:
                - myvalue
```

You can also configure architecture-based node affinity. For example, to configure a component to only deploy on `amd64` architecture, you can use the following settings:

```
# ...
template:
  pod:
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/arch
                operator: In
                values:
                - amd64
```

## Enabling collection of producer metrics

Producer metrics provide information about the health of your Kafka topics through metrics gathered from producing applications. You can view the information in the [**Producers** dashboard](../../administering/topic-health/).

Gathering producer metrics is done through a Kafka Proxy, and is not enabled by default. To enable metrics gathering and have the information displayed in the dashboard, enable the Kafka Proxy by adding the `spec.kafkaProxy` property to the `EventStreams` custom resource as follows:

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: EventStreams
# ...
spec:
  kafkaProxy: {}
# ...
```

**Important:** Enabling the Kafka Proxy to gather producer metrics places an intermediary between your producing clients and your Kafka brokers. This adds latency to any traffic to your Kafka brokers. Consider the performance implications of having the proxy in front of your Kafka brokers. You can also leave the proxy disabled and gather producer metrics from the clients directly by using [JMX](https://kafka.apache.org/documentation/#monitoring){:target="_blank"}.


## Configuring external monitoring through Prometheus

Metrics provide information about the health and operation of the {{site.data.reuse.short_name}} instance.

Metrics can be enabled for Kafka, ZooKeeper, geo-replicator, and Kafka Connect pods.

**Note:** Kafka metrics can also be exposed externally through JMX by [configuring external monitoring tools](#configuring-external-monitoring-through-jmx).

Kafka metrics can be enabled by setting `spec.strimziOverrides.kafka.metricsConfig` in the `EventStreams` custom resource to point to the `metrics-config` ConfigMap. For example:

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: EventStreams
# ...
spec:
  strimziOverrides:
    kafka:
      # ...
      metricsConfig:
        type: jmxPrometheusExporter
        valueFrom:
          configMapKeyRef:
            key: kafka-metrics-config.yaml
            name: metrics-config
# ...
```

ZooKeeper metrics can be enabled by setting `spec.strimziOverrides.zookeeper.metricsConfig` in the `EventStreams` custom resource to point to the `metrics-config` ConfigMap. For example:

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: EventStreams
# ...
spec:
  strimziOverrides:
    zookeeper:
      # ...
      metricsConfig:
        type: jmxPrometheusExporter
        valueFrom:
          configMapKeyRef:
            key: zookeeper-metrics-config.yaml
            name: metrics-config
# ...
```

The following is the default `metrics-config` ConfigMap in YAML format:

```
kind: ConfigMap
apiVersion: v1
metadata:
  name: metrics-config
data:
  kafka-metrics-config.yaml: |
    lowercaseOutputName: true
    rules:
    - attrNameSnakeCase: false
      name: kafka_controller_$1_$2_$3
      pattern: kafka.controller<type=(\w+), name=(\w+)><>(Count|Value|Mean)
    - attrNameSnakeCase: false
      name: kafka_server_BrokerTopicMetrics_$1_$2
      pattern: kafka.server<type=BrokerTopicMetrics, name=(BytesInPerSec|BytesOutPerSec)><>(Count)
    - attrNameSnakeCase: false
      name: kafka_server_BrokerTopicMetrics_$1__alltopics_$2
      pattern: kafka.server<type=BrokerTopicMetrics, name=(BytesInPerSec|BytesOutPerSec)><>(OneMinuteRate)
    - attrNameSnakeCase: false
      name: kafka_server_ReplicaManager_$1_$2
      pattern: kafka.server<type=ReplicaManager, name=(\w+)><>(Value)
  zookeeper-metrics-config.yaml: |
    lowercaseOutputName: true
    rules: []

```

Geo-replicator metrics can be enabled by setting `spec.metrics` to `{}` in the `KafkaMirrorMaker2` custom resource. For example:

```yaml
apiVersion: eventstreams.ibm.com/v1alpha1
kind: KafkaMirrorMaker2
# ...
spec:
  # ...
  metrics: {}
# ...
```

**Note:** The {{site.data.reuse.short_name}} operator automatically applies a `KafkaMirrorMaker2` custom resource when a `EventStreamsGeoReplicator` custom resource is created. Metrics can then be enabled by editing the generated `KafkaMirrorMaker2` custom resource.

Kafka Connect metrics can be enabled by setting `spec.metrics` to `{}` in the `KafkaConnect` custom resource. For example:

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: KafkaConnect
# ...
spec:
  # ...
  metrics: {}
# ...
```

To complement the default Kafka metrics, you can configure {{site.data.reuse.short_name}} to publish additional information about your {{site.data.reuse.short_name}} instance by adding the `spec.kafkaProxy` property to the `EventStreams` custom resource as follows:

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: EventStreams
# ...
spec:
  kafkaProxy: {}
# ...
```

**Note:** For details about viewing metrics information, see the [cluster health](../../administering/cluster-health) and [topic health](../../administering/topic-health) sections.

## Configuring external monitoring through JMX

You can use third-party monitoring tools to monitor the deployed {{site.data.reuse.short_name}} Kafka cluster by collecting Kafka metrics. To set this up, you need to:

- Have a third-party monitoring tool set up to be used within your {{site.data.reuse.openshift_short}} cluster.
- Enable access to the broker JMX port by setting `spec.strimizOverrides.kafka.jmxOptions`.
  
  ```yaml
  apiVersion: eventstreams.ibm.com/v1beta2
  kind: EventStreams
  # ...
  spec:
    # ...
    strimziOverrides:
      # ...
      kafka:
        jmxOptions: {}
  ```

- Include any configuration settings for {{site.data.reuse.short_name}} as required by your monitoring tool. For example, Datadog's autodiscovery requires you to annotate Kafka broker pods (`strimziOverrides.kafka.template.statefulset.metadata.annotations`)
- Configure your monitoring applications to [consume JMX metrics](../../security/secure-jmx-connections/).

## Configuring the Kafka Exporter

You can configure the Kafka Exporter to expose additional metrics to Prometheus on top of the default ones. For example, you can obtain the consumer group lag information for each topic.

Kafka Exporter can be enabled by setting `spec.kafkaExporter` to `{}` in the `EventStreams` custom resource. For example:

```yaml
  apiVersion: eventstreams.ibm.com/v1beta2
  kind: EventStreams
  # ...
  spec:
    # ...
    strimziOverrides:
      # ...
      kafkaExporter: {}
```


You can also configure Kafka Exporter using a `regex` to expose metrics for a collection of topics and consumer groups that match the expression. For example, to enable JMX metrics collection for the topic `orders` and the group `buyers`, configure the `EventStreams` custom resource as follows:

```yaml
  apiVersion: eventstreams.ibm.com/v1beta2
  kind: EventStreams
  # ...
  spec:
    # ...
    strimziOverrides:
      # ...
      kafkaExporter:
        groupRegex: buyers
        topicRegex: orders
```

For more information about configuration options, see [configuring the Kafka Exporter](https://strimzi.io/docs/operators/latest/deploying.html#proc-metrics-kafka-deploy-options-str){:target="_blank"}.

## Configuring the JMX Exporter

You can configure the JMX Exporter to expose JMX metrics from Kafka brokers, ZooKeeper nodes, and Kafka Connect nodes to Prometheus.

To enable the collection of all JMX metrics available on the Kafka brokers and ZooKeeper nodes, configure the `EventStreams` custom resource as follows:

```yaml
  apiVersion: eventstreams.ibm.com/v1beta2
  kind: EventStreams
  # ...
  spec:
  # ...
  strimziOverrides:
    kafka:
      metricsConfig:
        type: jmxPrometheusExporter
        valueFrom:
          configMapKeyRef:
            key: kafka-metrics-config.yaml
            name: metrics-config
      # ...
    zookeepers:
      #
    # ...
```

For more information about configuration options, see the following documentation:

- [Kafka and ZooKeeper JMX metrics configuration](https://strimzi.io/docs/operators/latest/deploying.html#assembly-metrics-str){:target="_blank"}
- [Kafka JMX metrics configuration](https://strimzi.io/docs/operators/latest/configuring.html#con-common-configuration-prometheus-reference){:target="_blank"}
## Enabling and configuring Kafka Bridge

With [Kafka Bridge](https://strimzi.io/blog/2019/07/19/http-bridge-intro/){:target="_blank"}, you can connect client applications to your {{site.data.reuse.short_name}} Kafka cluster over HTTP, providing a standard web API connection to {{site.data.reuse.short_name}} rather than the custom Kafka protocol.

To enable Kafka Bridge for {{site.data.reuse.short_name}}, create a `KafkaBridge` custom resource alongside the `EventStreams` custom resource. This can be defined in a YAML configuration document under the **IBM Event Streams** operator in the {{site.data.reuse.openshift_short}} web console.

For example, to enable Kafka Bridge for {{site.data.reuse.short_name}} in the namespace `es-kafka-bridge`, create the following `KafkaBridge` configuration, where `spec.bootstrapServers` is the address of your {{site.data.reuse.short_name}} Kafka cluster, and `spec.http.port` is the port number for Kafka Bridge to access your cluster (default is `8080`):

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: KafkaBridge
metadata:
  name: my-bridge
  namespace: es-kafka-bridge
spec:
  replicas: 1
  bootstrapServers: 'test.kafka-bootstrap.es-kafka-bridge:9093'
  http:
     port: 8080
  template:
    bridgeContainer:
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop:
            - ALL
        privileged: false
        readOnlyRootFilesystem: true
        runAsNonRoot: true
```

Depending on your setup and purpose of deployment, you can add more `replicas` which sets the number of Kafka Bridge instances to run. For production environments, for example, consider deploying more than one replica for resilience.

After enabling the Kafka Bridge, create an OpenShift route for the Kafka Bridge service. For example, in the OpenShift web concole, go to **Networking > Routes**, and click **Create Route**, then click **Edit YAML**, and add the following custom resource:

```yaml
kind: Route
apiVersion: route.openshift.io/v1
metadata:
    name: <route-name>
    namespace: <namespace>
spec:
  host: <route-name>-<namespace>.apps.<cluster-name>.example.com
  to:
    kind: Service
    name: my-bridge-bridge-service
    weight: 100
  port:
    targetPort: rest-api
  wildcardPolicy: None
```

Where `<cluster-name>` is the name of the OpenShift cluster you are using. If you do not provide a hostname, it is automatically generated when the route custom resource is applied.

**Note:** Ensure you expose the Kafka Bridge service by running a similar command to the following: `oc expose service my-bridge-bridge-service`.

For more information about Kafka Bridge, including further configuration options and usage, see [connecting with Kafka Bridge](../../connecting/kafka-bridge/).

## Enabling and configuring Cruise Control

To enable Cruise Control, set the `spec.strimizOverrides.cruiseControl` property to `{}` in the `EventStreams` custom resource:

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: EventStreams
# ...
spec:
  # ...
  strimziOverrides:
    # ...
    cruiseControl: {}
```

**Note:** Ensure you have more than 1 Kafka broker configured to take advantage of Cruise Control. All [sample configurations](../planning/#sample-deployments) provided have more than 1 broker except the **Lightweight without security** sample.

When enabled, you can use the [default](#cruise-control-defaults) Cruise Control configuration to optimize your Kafka cluster. You can also specify your required configuration as described in the following sections.

When configuring Cruise Control, you can define the following settings in the `EventStreams` custom resource:
- Main optimization goals in `spec.strimziOverrides.cruiseControl.config.goals`
- Default optimization goals in `spec.strimziOverrides.cruiseControl.config["default.goals"]`

   **Note:** If you do not set main optimization goals and default goals, then the [Cruise Control defaults](#cruise-control-defaults) are used.

- Hard goals in `spec.strimziOverrides.cruiseControl.config["hard.goals"]`
- The capacity limits for broker resources, which Cruise Control uses to determine if resource-based optimization goals are being broken. The `spec.strimziOverrides.cruiseControl.brokerCapacity` property defines the Kafka broker resource capacities that Cruise Control will optimize around.

Cruise Control includes a number of [configuration options](https://github.com/linkedin/cruise-control/wiki/Configurations#cruise-control-configurations){:target="_blank"}. You can modify these configuration options for {{site.data.reuse.short_name}}, except the options managed directly by [Strimzi](https://strimzi.io/docs/operators/latest/configuring.html#property-cruise-control-config-reference){:target="_blank"}.

When enabled, you can use Cruise Control and the `KafkaRebalance` custom resources to [optimize](../../administering/cruise-control/) your deployed {{site.data.reuse.short_name}} Kafka cluster.

### Cruise Control defaults

{{site.data.reuse.short_name}} supports a subset of the Cruise Control goals. If the main optimization goals and default goals (`spec.strimziOverrides.cruiseControl.config.goals` and `spec.strimziOverrides.cruiseControl.config["default.goals"]`, respectively) are not set, then the Cruise Control configuration defaults to the following goals (in descending order of priority):

- `com.linkedin.kafka.cruisecontrol.analyzer.goals.RackAwareGoal`
- `com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaCapacityGoal`
- `com.linkedin.kafka.cruisecontrol.analyzer.goals.DiskCapacityGoal`
- `com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkInboundCapacityGoal`
- `com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkOutboundCapacityGoal`
- `com.linkedin.kafka.cruisecontrol.analyzer.goals.CpuCapacityGoal`
- `com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaDistributionGoal`
- `com.linkedin.kafka.cruisecontrol.analyzer.goals.PotentialNwOutGoal`
- `com.linkedin.kafka.cruisecontrol.analyzer.goals.DiskUsageDistributionGoal`
- `com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkInboundUsageDistributionGoal`
- `com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkOutboundUsageDistributionGoal`
- `com.linkedin.kafka.cruisecontrol.analyzer.goals.CpuUsageDistributionGoal`
- `com.linkedin.kafka.cruisecontrol.analyzer.goals.TopicReplicaDistributionGoal`
- `com.linkedin.kafka.cruisecontrol.analyzer.goals.LeaderReplicaDistributionGoal`
- `com.linkedin.kafka.cruisecontrol.analyzer.goals.LeaderBytesInDistributionGoal`
- `com.linkedin.kafka.cruisecontrol.analyzer.goals.PreferredLeaderElectionGoal`

For more information about the optimization goals, see the Cruise Control [documentation](https://github.com/linkedin/cruise-control/wiki/Pluggable-Components#goals){:target="_blank"}.

### Main optimization goals

The main optimization goals define the goals available to be used in Cruise Control operations. Goals not listed cannot be used.

The `spec.strimziOverrides.cruiseControl.config.goals` property defines the list of goals Cruise Control can use.

The main optimization goals have [defaults](#cruise-control-defaults) if not configured.

For example, if you want Cruise Control to only consider using `com.linkedin.kafka.cruisecontrol.analyzer.goals.RackAwareGoal` and `com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaCapacityGoal`, set values for `spec.strimziOverrides.cruiseControl.config.goals` property as follows:

```yaml
# ...
spec:
  # ...
  strimziOverrides:
    # ...
    cruiseControl:
      # ...
      config:
        # ...
        goals: >
          com.linkedin.kafka.cruisecontrol.analyzer.goals.RackAwareGoal,
          com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaCapacityGoal
```

### Default goals

The default goals define the set of goals that you want your cluster to meet most often. They are set in the `spec.strimziOverrides.cruiseControl.config["default.goals"]` property. By default, every 15 minutes, Cruise Control will use the current state of your Kafka cluster to generate a cached optimization proposal by using the configured `default.goals` list.

If no default goals are set, the main optimization goals are used as the [default](#cruise-control-defaults) optimization goals.

For example, if you want Cruise Control to always consider meeting `com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkInboundUsageDistributionGoal`, `com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkOutboundUsageDistributionGoal`, and `com.linkedin.kafka.cruisecontrol.analyzer.goals.CpuUsageDistributionGoal`, set values for the `spec.strimziOverrides.cruiseControl.config["default.goals"]` property as follows:

```yaml
# ...
spec:
  # ...
  strimziOverrides:
    # ...
    cruiseControl:
      # ...
      config:
        # ...
        default.goals: >
          com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkInboundUsageDistributionGoal,
          com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkOutboundUsageDistributionGoal,
          com.linkedin.kafka.cruisecontrol.analyzer.goals.CpuUsageDistributionGoal
```

### Hard goals

Hard goals define the list of goals that must be met by an optimization proposal and cannot be violated in any of the optimization functions of Cruise Control.

Hard goals can be set by the `spec.strimziOverrides.cruiseControl.config["hard.goals"]` property.

In Cruise Control, the following [main optimization goals](#cruise-control-defaults) are preset as hard goals:
- `com.linkedin.kafka.cruisecontrol.analyzer.goals.RackAwareGoal`
- `com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaCapacityGoal`
- `com.linkedin.kafka.cruisecontrol.analyzer.goals.DiskCapacityGoal`
- `com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkInboundCapacityGoal`
- `com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkOutboundCapacityGoal`

For example, to configure Cruise Control to always consider `com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkInboundCapacityGoal` and `com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkOutboundCapacityGoal` in an optimization proposal, provide these goals as values in the `spec.strimziOverrides.cruiseControl.config["hard.goals"]` property as follows:

```yaml
# ...
spec:
  # ...
  strimziOverrides:
    # ...
    cruiseControl:
      # ...
      config:
        # ...
        hard.goals: >
          com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkInboundCapacityGoal,
          com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkOutboundCapacityGoal
```

**Note:** The longer the list of hard goals, the less likely it is that Cruise Control will be able to find a viable optimization proposal. Consider configuring fewer hard goals and more goals for the [optimization proposals](../../administering/cruise-control/#setting-up-optimization) in the `KafkaRebalance` custom resource.


### Cruise Control BrokerCapacity

Specifies capacity limits for broker resources.

Use the `spec.strimziOverrides.cruiseControl.brokerCapacity` property to define capacity limits for Kafka broker resources. Cruise Control will use the set limits to determine if resource-based optimization goals are being broken. The following table provides information about the resource capacity settings, the goals they affect, and the units they use:

| brokerCapacity | Goal                                                                          | unit |
| :--------------- | :---------------------------------------------------------------------------- | :--- |
| inboundNetwork   | `com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkInboundCapacityGoal`  | KB/s |
| outboundNetwork  | `com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkOutboundCapacityGoal` | KB/s |
| disk             | `com.linkedin.kafka.cruisecontrol.analyzer.goals.DiskUsageDistributionGoal`   | Bytes |
| cpuUtilization   | `com.linkedin.kafka.cruisecontrol.analyzer.goals.CpuUsageDistributionGoal`    | Percent (0-100)  |

**Note:** Ensure you add the unit when configuring a `brokerCapacity` key, except for `cpuUtilization` where the percentage is not required.

For example, to configure Cruise Control to optimize around having an inbound network byte rate of `1000` kilobytes per second and a cpu utilization of 80 percent, configure the `spec.strimziOverrides.cruiseControl.brokerCapacity` property as follows:

```yaml
# ...
spec:
  # ...
  strimziOverrides:
    # ...
    cruiseControl:
      # ...
      brokerCapacity:
        # ...
        inboundNetwork: 1000KB/s
        # Optimize for CPU utilization of 80%
        cpuUtilization: 80
```


## Using your own certificates

{{site.data.reuse.short_name}} offers the capability to provide your own CA certificates and private keys instead of using the ones generated by the operator. If a CA certificate and private key are provided, the listener certificate is generated automatically and signed using the CA certificate.

{{site.data.reuse.short_name}} also offers the capability to provide your own certificates.

**Note:** You must complete the process of providing your own certificates before installing an instance of {{site.data.reuse.short_name}}.

You must provide your own X.509 certificates and keys in PEM format with the addition of a PKCS12-formatted certificate and the CA password. If you want to use a CA which is not a Root CA, you have to include the whole chain in the certificate file. The chain should be in the following order:

1. The cluster or clients CA
2. One or more intermediate CAs
3. The root CA

All CAs in the chain should be configured as a CA with the X509v3 Basic Constraints.

### Providing a CA certificate and key

**Note:** In the following instructions, the CA public certificate file is denoted `CA.crt` and the CA private key is denoted `CA.key`.

As {{site.data.reuse.short_name}} also serves the `truststore` in PKCS12 format, generate a `.p12` file containing the relevant CA Certificates. When generating your PKCS12 truststore, ensure that the truststore does not contain the CA private key. This is important because the `.p12` file will be available to download from the {{site.data.reuse.short_name}} UI and distributed to clients.

The following is an example showing how to use the Java `keytool` utility to generate a PKCS12 truststore that does not contain a private key: \\
\\
`keytool -import -file <ca.pem> -keystore ca.jks` \\
`keytool -importkeystore -srckeystore ca.jks -srcstoretype JKS -deststoretype PKCS12 -destkeystore ca.p12`

**Note:** Using OpenSSL PKCS12 commands to generate a truststore without private keys can break the cluster, because the resulting truststore is not compatible with Java runtimes.\\
One way to test that the truststore is compatible and contains the correct certificates is to use the following java `keytool` utility command: \\
\\
`keytool -list -keystore ca.p12 -storepass <keystore password>`

The cluster and/or clients certificates, and keys must be added to secrets in the namespace that the {{site.data.reuse.short_name}} instance is intended to be created in. The naming of the secrets and required labels must follow the conventions detailed in the following command templates.

The following commands can be used to create and label the secrets for custom certificates and keys. The templates demonstrate providing cluster certificates but the same commands can be re-used substituting `cluster` with `clients` in each secret name.

For each command, provide the intended name and namespace for the {{site.data.reuse.short_name}} instance.

`oc create --namespace <namespace> secret generic <instance-name>-cluster-ca --from-file=ca.key=CA.key`

`oc label --namespace <namespace> secret <instance-name>-cluster-ca eventstreams.ibm.com/kind=Kafka eventstreams.ibm.com/cluster=<instance-name>`

`oc annotate --namespace <namespace> secret <instance-name>-cluster-ca ca-key-generation=0`

`oc create --namespace <namespace> secret generic <instance-name>-cluster-ca-cert --from-file=ca.crt=CA.crt --from-file=ca.p12=CA.p12 --from-literal=ca.password='<CA_PASSWORD>'`

`oc label --namespace <namespace> secret <instance-name>-cluster-ca-cert eventstreams.ibm.com/kind=Kafka eventstreams.ibm.com/cluster=<instance-name>`

`oc annotate --namespace <namespace> secret <instance-name>-cluster-ca-cert ca-cert-generation=0`

**Note:** The `ca-cert-generation` and `ca-key-generation` values identify whether certificates are being renewed or not. Only set 0 for these values if you have not installed an instance of {{site.data.reuse.short_name}} yet. For more information about when to amend these annotations, see [renewing certificates](../../security/renewing-certificates/).

To make use of the provided secrets, {{site.data.reuse.short_name}} will require the following overrides to be added to the custom resource.

```yaml
spec:
  # ...
  strimziOverrides:
    clusterCa:
      generateCertificateAuthority: false

  # And/Or

    clientsCa:
      generateCertificateAuthority: false
```

For information about configuring the renewal settings for certificates, see [renewing certificates](../../security/renewing-certificates/).

### Providing listener certificates

To use TLS hostname verification with your own Kafka listener certificates, ensure you use the correct Subject Alternative Names (SANs) for each listener. The certificate SANs must specify hostnames for:

 - All of the Kafka brokers in your cluster

 - The Kafka cluster bootstrap service

You can use wildcard certificates if they are supported by your CA.

For internal listeners, the hostnames will be service names. For external listeners, the hostnames will be the route addresses.


Create a secret containing the private key and server certificate:

`oc create secret generic my-secret --from-file=my-listener-key.key --from-file=my-listener-certificate.crt`

To make use of the secret, {{site.data.reuse.short_name}} will require the following overrides to be added to the custom resource.

```yaml
spec:
  # ...
  strimziOverrides:
    kafka:
      listeners:
        - name: external
          # ...
          configuration:
            brokerCertChainAndKey:
              certificate: my-listener-certificate.crt
              key: my-listener-key.key
              secretName: my-secret
```

## Unsupported settings

This release of {{site.data.reuse.short_name}} does not support the following configuration properties:
- `secretPrefix`: This property adds a prefix to the name of all secrets created from the `KafkaUser` resource. It can cause problems with the normal operation of {{site.data.reuse.short_name}}.

  Do not configure prefixes by setting the `EventStreams.spec.strimziOverrides.entityOperator.userOperator.secretPrefix` property.

- `watchedNamespace`: This property sets the namespace in which the deployed `KafkaUser` Operator watches for `KafkaUser` resources. It can cause problems with the normal operation of {{site.data.reuse.short_name}} as multiple components rely on the Entity User Operator to be watching the currently installed namespace.

  Do not configure the watched namespace by setting the `EventStreams.spec.strimziOverrides.entityOperator.userOperator.watchedNamespace` property.
