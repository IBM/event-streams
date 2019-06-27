---
title: "Configuring secure JMX connections"
excerpt: "Connecting securely to Kafka JMX ports"
categories: security
slug: secure-jmx-connections
toc: true
---


You can set up the Kafka broker JMX ports to be accessible to secure connections from within the {{site.data.reuse.icp}} cluster. This grants applications deployed inside the cluster read-only access to Kafka metrics.

By default, Kafka broker JMX ports are not accessible from outside the Kubernetes pod. To enable access, ensure you select the **Enable secure JMX connections** check box in the [**Kafka broker settings**](../../installing/configuring/#kafka-broker-settings) section when installing {{site.data.reuse.short_name}}.

You can also enable secure JMX connections for existing installations by [modifying your settings](../../administering/modifying-installation/).

When access is enabled, you can configure your applications to connect securely to the JMX port as follows.

## Enabling external connections

When {{site.data.reuse.short_name}} is installed with the **Enable secure JMX connections** option, the Kafka broker is configured to start the JMX port with SSL and authentication enabled. The JMX port `9999` is opened on the Kafka pod and is accessible from within the cluster using the hostname `<releasename>-ibm-es-kafka-broker-svc-<brokerNum>.<namespace>.svc`

To retrieve the local name of the service you can use the following command (the results do not have the `<namespace>.svc` suffix):

`kubectl -n <namespace> get services`

To connect to the JMX port, clients must use the following Java options:

- `javax.net.ssl.trustStore=<path to trustStore>`
- `javax.net.ssl.trustStorePassword=<password for trustStore>`

In addition, clients must provide a `username` and `password` when initiating the JMX connection.

## Providing configuration values

When secure JMX connections is enabled, a Kubernetes secret named `{{site.data.reuse.jmx-secret}}` is created inside the {{site.data.reuse.short_name}} namespace. The secret contains the following content:

| Name | Description |
|---|---|
|`truststore.jks` | A Java truststore containing the certificates needed for SSL communication with the Kafka broker JMX port. |
|`trust_store_password` | The password associated with the truststore.
|`jmx_username` | The user that is authenticated to connect to the JMX port.
|`jmx_password` | The password for the authenticated user.

The Kubernetes secret's contents must then be mounted as volumes and environment variables inside the application pod to provide the required runtime configuration to create a JMX connection.

For example:

```
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: container1
      env:
        - name: jmx_username
          secretRef:
            secretName: es-secret
      ...
      volumeMounts:
        - name: es-volume
          mountPath: /path/to/volume/on/pod/file/system
  ...
  volumes:
    - name: es-volume
      fromSecret:
        secretName: es-secret
        items:
          - name: truststore.jks
            path: jks.jks
```


If the connecting application is not installed inside the {{site.data.reuse.short_name}} namespace, it must be copied to the application namespace using the following command:

```
kubectl -n <releaseNamespace> get secret {{site.data.reuse.jmx-secret}} -o yaml --export | kubectl -n <applicationNamespace> apply -f -
```
