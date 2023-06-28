---
title: "Configuring secure JMX connections"
excerpt: "Connecting securely to Kafka JMX ports"
categories: security
slug: secure-jmx-connections
layout: redirects
toc: true
---

## Java Management Extensions (JMX)

Java Management Extensions (JMX) is a way of retrieving metrics from your specific processes dynamically at runtime. This can be used to get metrics that are specific to Java operations on Kafka

To manage resources, management beans (MBeans) are used. MBeans represent a resource in the JVM. There are specific [MBean attributes](https://kafka.apache.org/28/documentation/#remote_jmx) you can use with Kafka.

Metrics can be retrieved from applications running inside your {{site.data.reuse.openshift_short}} cluster by connecting to an exposed JMX port. The metrics can also be pushed in various formats to remote sinks inside or outside of the cluster by using JmxTrans.

## Exposing a JMX port on Kafka

You can expose the JMX port (`9999`) of each Kafka broker to be accessible to secure connections from within the {{site.data.reuse.openshift_short}} cluster. This grants applications deployed inside the cluster (including JmxTrans) read-only access to Kafka metrics. To expose the JMX port, set the `spec.strimziOverrides.kafka.jmxOptions` value to `{}`. This will create an open JMX port allowing any pod to read from it.

The JMX port can be password-protected to prevent unauthorised pods from accessing it. It is good practice to secure the JMX port, as an unprotected port could allow a user to invoke an MBean operation on the Java JVM. To enable security for the JMX port, set the `spec.strimiziOverrrides.kafka.jmxOptions.authentication.type` field to `password`. For example:

```
#...
spec:
  #...
  strimziOverrides:
    #...
    kafka:
      #...
      jmxOptions:
        authentication:
          type: "password"
    #...
```

This will cause the JMX port to be secured using a generated username and password. When the JMX port is password protected, a Kubernetes secret named `{{site.data.reuse.jmx-secret}}` is created inside the {{site.data.reuse.short_name}} namespace. The secret contains the following content:

| Name           | Description                                                |
| -------------- | ---------------------------------------------------------- |
| `jmx_username` | The user that is authenticated to connect to the JMX port. |
| `jmx_password` | The password for the authenticated user.                   |

## Connecting internal applications

To connect your application to the Kafka JMX port, it must be deployed running inside the {{site.data.reuse.openshift_short}} cluster.

After your application is deployed, you can connect to each Kafka broker with the following URL pattern:
`<cluster-name>-kafka-<kafka-ordinal>.<cluster-name>-kafka-brokers.svc:9999`

To connect to the JMX port, clients must use the following Java options:

- `javax.net.ssl.trustStore=<path to trustStore>`
- `javax.net.ssl.trustStorePassword=<password for trustStore>`

In addition, when initiating the JMX connection, if the port is secured then clients must provide the `username` and `password` from the JMX secret. For example, the `JConsole` UI provide a username/password box to enter the credentials.

### Retrieving the truststore

#### Using the {{site.data.reuse.short_name}} UI:

1. {{site.data.reuse.es_ui_login}}
2. Click **Topics** in the primary navigation.
3. Click **Connect to this cluster**.
4. In the certificates section, click **download certificate**.
   You will now have the required certificate and the password will be displayed in the UI.

#### Using the {{site.data.reuse.short_name}} CLI:

1. {{site.data.reuse.cp_cli_login}}
2. {{site.data.reuse.es_cli_init}}
3. Run the command `cloudctl es certificates` to download the certificate. The password is displayed in the CLI.

### Retrieving the JMX username and password

#### Using the `oc` CLI

1. {{site.data.reuse.openshift_cli_login}}
2. Run the following commands:

   `oc get secret <cluster-name>-jmx -o jsonpath='{.data.jmx\-username}' -namespace <name_of_your_namespace> | base64 -decode > jmx_username.txt`

   `oc get secret <cluster-name>-jmx -o jsonpath='{.data.jmx\-password}' -namespace <name_of_your_namespace> | base64 -decode > jmx_password.txt`

These will output the `jmx_username` and `jmx_password` values into the respective `.txt` files.

#### Mounting the JMX secret directly into a pod

Mounting the secret will project the `jmx_username` and `jmx_password` values as files under the mount path folder.

```
apiVersion: v1
kind: Pod
metadata:
  name: example-pod
spec:
  volumes:
      - name: jmx-secret
        secret:
          secretName: <cluster-name>-jmx
  containers:
    - name: example-container
      image: example-image
    volumeMounts:
    - name: jmx-secret
      mountPath: /path/to/jmx-secret
      readOnly: true
```

For more information, see [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-files-from-a-pod)

If the connecting application is not installed inside the {{site.data.reuse.short_name}} namespace, it must be copied to the application namespace using the following command:

```
oc -n <instance_namespace> get secret {{site.data.reuse.jmx-secret}} -o yaml --export | oc -n <application_namespace> apply -f -
```

## JmxTrans

The Kafka broker JMX ports are not exposed to applications outside of the cluster. However, a JmxTrans pod can be deployed that provides a mechanism to read JMX metrics from the Kafka brokers and push them to applications inside or outside the cluster.

JmxTrans reads JMX metric data from the Kafka brokers and sends the data to applications in various data formats.

## Configuring a JmxTrans deployment

To configure a JmxTrans deployment, you will need to use the `spec.strimziOverrides.jmxTrans` field to define the `outputDefinitions` and `kafkaQueries`.

**outputDefinitions:** This specifies where the metric data will be pushed to and in what data format it will be provided in.

| Attribute    | Description                                                                                                                                                                                    |
| ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `outputType` | The specified format you want to transform your query to. For a list of supported data formats, see the [OutputWriters documentation](https://github.com/jmxtrans/jmxtrans/wiki/OutputWriters) |
| `host`       | The target host address the data is pushed to.                                                                                                                                                 |
| `port`       | The target port the data is pushed to.                                                                                                                                                         |
| `flushDelay` | Number of seconds JmxTrans agent waits before pushing new data.                                                                                                                                |
| `name`       | Name of the property which is later referenced by `spec.strimiziOverrides.jmxTrans.queries`.                                                                                                   |

The following is an example configuration pushing JMX data to `standardOut` in the JmxTrans logs and another pushing JMX data every 10 seconds in the Graphite format to a Logstash database at the address `mylogstash.com:31028`:

```
# ...
spec:
  # ...
  strimziOverrides:
    # ...
    jmxTrans:
      # ...
      outputDefinitions:
        - outputType: "com.googlecode.jmxtrans.model.output.StdOutWriter"
          name: "standardOut"
        - outputType: "com.googlecode.jmxtrans.model.output.GraphiteOutputWriter"
          host: "mylogstash.com"
          port: 31028
          flushDelayInSeconds: 5
          name: "logstash"
```

**kafkaQueries:** This specifies what JMX metrics are read from the Kafka brokers.

Note: Metrics are read from all Kafka brokers. There is no configuration option to obtain metrics from selected brokers only.

| Attribute     | Description                                                               |
| ------------- | ------------------------------------------------------------------------- |
| `targetMBean` | Specifies what metrics you want to get from the JVM.                      |
| `attributes`  | Specifies which MBean metric is read from the targetMBean as JMX metrics. |
| `output`      | Defines where the metrics are pushed to, by choosing an output type.      |

The following is an example JmxTrans deployment that reads from all MBeans that match the pattern `kafka.server:type=BrokerTopicMetrics,name=*` and have `name` in the target MBeans name. From those MBeans, it obtains JMX metrics about the `Count` attribute, and pushes the metrics to a standard output as defined by the `outputs` attribute.

```
#...
spec:
  #...
  strimziOverrides:
    #...
    jmxTrans:
      #...
      kafkaQueries:
        - targetMBean: "kafka.server:type=BrokerTopicMetrics,name=*"
          attributes: ["Count"]
          outputs: ["standardOut"]
```
