---
title: "Configuring secure JMX connections"
excerpt: "Connecting securely to Kafka JMX ports"
categories: security
slug: secure-jmx-connections
toc: true
---

## Java Management Extensions (JMX)

Java Management Extensions (JMX) is a way of retrieving metrics from your specific processes dynamically at runtime. This can be used to get metrics that are specific to Java operations on Kafka

To manage resources, management beans (MBeans) are used. MBeans represent a resource in the JVM. There are specific [MBean attributes](https://kafka.apache.org/documentation/#remote_jmx){:target="_blank"} you can use with Kafka.

Metrics can be retrieved from applications running inside your Kubernetes cluster by connecting to an exposed JMX port.

## Exposing a JMX port on Kafka

You can expose the JMX port (`9999`) of each Kafka broker to be accessible to secure connections from within the Kubernetes cluster. This grants applications deployed inside the cluster read-only access to Kafka metrics. To expose the JMX port, set the `spec.strimziOverrides.kafka.jmxOptions` value to `{}`. This will create an open JMX port allowing any pod to read from it.

The JMX port can be password-protected to prevent unauthorized pods from accessing it. It is good practice to secure the JMX port, as an unprotected port could allow a user to invoke an MBean operation on the Java JVM. To enable security for the JMX port, set the `spec.strimiziOverrrides.kafka.jmxOptions.authentication.type` field to `password`. For example:

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

This will cause the JMX port to be secured using a generated username and password. When the JMX port is password protected, a Kubernetes secret named `{{site.data.reuse.jmx-secret-name}}` is created inside the {{site.data.reuse.short_name}} namespace. The secret contains the following content:

| Name           | Description                                                |
| -------------- | ---------------------------------------------------------- |
| `jmx_username` | The user that is authenticated to connect to the JMX port. |
| `jmx_password` | The password for the authenticated user.                   |

## Connecting internal applications

To connect your application to the Kafka JMX port, it must be deployed running inside the Kubernetes cluster.

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

1. {{site.data.reuse.es_cli_init_111}}
2. Run the command `kubectl es certificates` to download the certificate. The password is displayed in the CLI.

### Retrieving the JMX username and password

#### Using the Kubernetes command-line tool (`kubectl`)

1. {{site.data.reuse.cncf_cli_login}}
2. Run the following commands:

   `kubectl get secret {{site.data.reuse.jmx-secret-name}} -o jsonpath='{.data.jmx\-username}' -namespace <name_of_your_namespace> | base64 -decode > jmx_username.txt`

   `kubectl get secret {{site.data.reuse.jmx-secret-name}} -o jsonpath='{.data.jmx\-password}' -namespace <name_of_your_namespace> | base64 -decode > jmx_password.txt`

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
        secretName: {{site.data.reuse.jmx-secret-name}}
  containers:
    - name: example-container
      image: example-image
      volumeMounts:
      - name: jmx-secret
        mountPath: /path/to/jmx-secret
        readOnly: true
```

For more information, see [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-files-from-a-pod){:target="_blank"}.

If the connecting application is not installed inside the {{site.data.reuse.short_name}} namespace, it must be copied to the application namespace using the following command:

```
kubectl -n <instance_namespace> get secret {{site.data.reuse.jmx-secret-name}} -o yaml --export | kubectl -n <application_namespace> apply -f -
```
