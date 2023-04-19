---
title: "Setting up and running connectors"
excerpt: "Event Streams helps you set up a Kafka Connect environment, add connectors to it, and run the connectors to help integrate external systems."
categories: connecting
slug: setting-up-connectors
toc: true
---

{{site.data.reuse.long_name}} helps you set up a Kafka Connect environment, prepare the connection to other systems by adding connectors to the environment, and start Kafka Connect with the connectors to help integrate external systems.

[Log in](../../getting-started/logging-in/) to the {{site.data.reuse.short_name}} UI, and click **Toolbox** in the primary navigation. Scroll to the **Connectors** section and follow the guidance for each main task. You can also find additional help on this page.


## Using Kafka Connect

The most straightforward way to run Kafka Connect on {{site.data.reuse.openshift_short}} is to use a custom resource called `KafkaConnect`. An instance of this custom resource represents a Kafka Connect distributed worker cluster. In this mode, workload balancing is automatic, scaling is dynamic, and tasks and data are fault-tolerant. Each connector is represented by another custom resource called `KafkaConnector`.

### Kafka Connect topics

When running in distributed mode, Kafka Connect uses three topics to store configuration, current offsets and status. Kafka Connect can create these topics automatically as it is started by the {{site.data.reuse.short_name}} operator. By default, the topics are:

- **connect-configs**: This topic stores the connector and task configurations.
- **connect-offsets**: This topic stores offsets for Kafka Connect.
- **connect-status**: This topic stores status updates of connectors and tasks.

If you want to run multiple Kafka Connect environments on the same cluster, you can override the default names of the topics in the configuration.

### Authentication and authorization

Kafka Connect uses an Apache Kafka client just like a regular application, and the usual authentication and authorization rules apply.

Kafka Connect will need authorization to:

* Produce and consume to the internal Kafka Connect topics and, if you want the topics to be created automatically, to create these topics
* Produce to the target topics of any source connectors you are using
* Consume from the source topics of any sink connectors you are using.

**Note:** For more information about authentication and the credentials and certificates required, see the information about [managing access](../../security/managing-access/).

### Kafka Connect Source-to-Image deprecation

The `KafkaConnectS2I` custom resource is deprecated in {{site.data.reuse.short_name}} version 10.4.0 and later. When installing new Kafka Connect instances, use the `KafkaConnect` custom resource and provide a pre-built image. The `KafkaConnectS2I` custom resource will be removed in future versions of {{site.data.reuse.short_name}}. Ensure your existing Kafka Connect clusters are migrated to use the `KafkaConnect` custom resource.

To migrate an existing Kafka Connect cluster from the `KafkaConnectS2I` custom resource to the `KafkaConnect` custom resource:

1. [Download the Kafka connect ZIP](#download-kafka-connect-configuration) from the  {{site.data.reuse.short_name}} UI.
2. [Build and push](#adding-connectors-to-your-kafka-connect-environment) a Kafka Connect image that includes your connectors.
3. Follow the steps in the [Strimzi documentation](https://strimzi.io/docs/operators/0.22.0/using.html#proc-migrating-kafka-connect-s2i-str) to migrate the custom resource, setting the `.spec.image` property to be the image you built earlier.

## Set up a Kafka Connect environment

To begin using Kafka Connect, do the following.

### Download Kafka Connect configuration

1. In the {{site.data.reuse.short_name}} UI, click **Toolbox** in the primary navigation. Scroll to the **Connectors** section.
2. Go to the **Set up a Kafka Connect environment** tile, and click **Set up**.
3. Click **Download Kafka Connect ZIP** to download the compressed file, then extract the contents to your preferred location.

You will have a Kubernetes manifest for a `KafkaConnect`, a `Dockerfile`, and an empty directory called `my-plugins`.

### Configure Kafka Connect

Edit the downloaded `kafka-connect.yaml` file to enable Kafka Connect to connect to your {{site.data.reuse.openshift_short}} cluster. You can use the snippets in the {{site.data.reuse.short_name}} UI as guidance to configure Kafka Connect.

1. Choose a name for your Kafka Connect instance.
2. You can run more than one worker by increasing the `replicas` from 1.
3. Set `bootstrapServers` to connect the bootstrap server address of a listener. If using an internal listener, this will be the address of a service. If using an external listener, this will be the address of a route.
4. If you have fewer than 3 brokers in your {{site.data.reuse.short_name}} cluster, you must set `config.storage.replication.factor`, `offset.storage.replication.factor` and `status.storage.replication.factor` to 1.
5. If {{site.data.reuse.short_name}} has any form of authentication enabled, ensure you use the appropriate credentials in the Kafka Connect YAML configuration file.
6. To connect to a listener that requires a certificate, provide a reference to the appropriate certificate in the `spec.tls.trustedCertificates` section of the `KafkaConnect` custom resource.

For example, when connecting to a listener with `tls` authentication and  Mutual TLS encryption (`tls: true`), the Kafka Connect credentials will resemble the following:

  ```
  tls:
    trustedCertificates:
        - secretName: kafka-connect-user
          certificate: ca.crt
    authentication:
      type: tls
      certificateAndKey:
        certificate: user.crt
        key: user.key
        secretName: kafka-connect-user
  ```



## Adding connectors to your Kafka Connect environment

Prepare Kafka Connect for connections to your other systems by adding the required connectors.

Following on from the previous step, click **Next** at the bottom of the page. You can also access this page by clicking **Toolbox** in the primary navigation, scrolling to the **Connectors** section, and clicking **Add connectors** on the **Add connectors to your Kafka Connect environment** tile.

To run a particular connector Kafka Connect must have access to a JAR file or set of JAR files for the connector.

If your connector consists of just a single JAR file, you can copy it directly into the `my-plugins` directory.

If your connector consists of multiple JAR files, create a directory for the connector inside the `my-plugins` directory and copy all of the connector's JAR files into that directory.

Here's an example of how the directory structure might look with 3 connectors:

```
+--  my-plugins
|    +--  connector1.jar
|    +--  connector2
|    |    +-- connector2.jar
|    |    +-- connector2-lib.jar
|    +-- connector3.jar
```

### Build a Kafka Connect Docker image

Build a custom Kafka Connect Docker image that includes your chosen connectors.

Navigate to the directory where you extracted the Kafka Connect `.zip` file and run the following command:

```bash
docker build -t my-connect-cluster-image:latest <extracted_zip>/
```

**Note:** You might need to log in to the [IBM Container software library](https://myibm.ibm.com/products-services/containerlibrary){:target="_blank"} before building the image to allow the base image that is specified in the `Dockerfile` to be pulled successfully.

### Push the Kafka Connect Docker image to your registry

Push the custom Kafka Connect image containing your connector JAR files to an image registry that is accessible to your {{site.data.reuse.short_name}} instance.

To retag the image for your chosen registry:

```bash
docker tag my-connect-cluster-image:latest <registry>/my-connect-cluster-image:latest
```

To push the image:

```bash
docker push <registry>/my-connect-cluster-image:latest
```

### Add the image to the Kafka Connect file

Edit the image property in the downloaded `kafka-connect.yaml` file to match the image tag that was pushed to your image registry. See the {{site.data.reuse.short_name}} UI for an example.

## Starting Kafka Connect with your connectors

Click **Next** at the bottom of the page. You can also access this page by clicking **Toolbox** in the primary navigation, scrolling to the **Connectors** section, and clicking **Start Kafka Connect** on the **Start Kafka Connect with your connectors** tile.

### Start Kafka Connect with your connectors

By using the {{site.data.reuse.openshift_short}} CLI, deploy the Kafka Connect instance by applying the YAML file:

```
oc apply -f kafka-connect.yaml
```

Wait for the Kafka Connect pod to become ready. You can check status with the following command:

```
oc get pods
```

When it is ready, you can use the following command to check the status and view which connectors are available:

```
oc describe kafkaconnect my-connect-cluster
```

### Start a connector

Create a YAML file for the connector configuration. For the MQ connectors, you can use the {{site.data.reuse.short_name}} UI or CLI to generate the YAML file. Alternatively, you can use the following template, taking care to replace `<kafka_connect_name>` with the name of the `KafkaConnect` instance:

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: KafkaConnector
metadata:
  name: <connector_name>
  labels:
    # The eventstreams.ibm.com/cluster label identifies the KafkaConnect instance
    # in which to create this connector. That KafkaConnect instance
    # must have the eventstreams.ibm.com/use-connector-resources annotation
    # set to true.
    eventstreams.ibm.com/cluster: <kafka_connect_name>
spec:
  class: <connector_class_name>
  tasksMax: 1
  config:
  # The connector configuration goes here
```

Start the connector by applying the YAML file:

```
oc apply -f <connector_filename>.yaml
```

You can view the status of the connector by describing the custom resource:

```
oc describe kafkaconnector <connector_name>
```
