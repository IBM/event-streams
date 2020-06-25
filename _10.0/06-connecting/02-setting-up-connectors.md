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

The most straightforward way to run Kafka Connect on {{site.data.reuse.openshift_short}} is to use a custom resource called `KafkaConnectS2I`. An instance of this custom resource represents a Kafka Connect distributed worker cluster. In this mode, workload balancing is automatic, scaling is dynamic, and tasks and data are fault-tolerant. Each connector is represented by another custom resource called `KafkaConnector`.

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

## Set up a Kafka Connect environment

To begin using Kafka Connect, do the following.

### Download Kafka Connect configuration

1. In the {{site.data.reuse.short_name}} UI, click **Toolbox** in the primary navigation. Scroll to the **Connectors** section.
2. Go to the **Set up a Kafka Connect environment** tile, and click **Set up**.
3. Click **Download Kafka Connect ZIP** to download the compressed file, then extract the contents to your preferred location.

You will have a Kubernetes manifest for a `KafkaConnectS2I` and an empty directory called `my-plugins`.

### Configure Kafka Connect

Edit the downloaded `kafka-connect-s2i.yaml` file to enable Kafka Connect to connect to your {{site.data.reuse.openshift_short}} cluster. You can use the snippets in the {{site.data.reuse.short_name}} UI as guidance to configure Kafka Connect.

* Choose a name for your Kafka Connect instance.
* You can run more than one worker by increasing the `replicas` from 1.
* Set `bootstrapServers` to connect the bootstrap server address of a listener. If using an internal listener, this will be the address of a service. If using an external listener, this will be the address of a route.
* If you have fewer than 3 brokers in your {{site.data.reuse.short_name}} cluster, you must set `config.storage.replication.factor`, `offset.storage.replication.factor` and `status.storage.replication.factor` to 1.
* Unless your {{site.data.reuse.short_name}} cluster has authentication turned off, you must provide authentication credentials in the `authentication` configuration.
* If clients require a certificate to connect to your {{site.data.reuse.short_name}} cluster (as they will if you are connecting using a route), you must provide a certificate in the `tls` configuration.

### Deploy Kafka Connect

Deploy the Kafka Connect instance by applying the YAML file using the {{site.data.reuse.openshift_short}} CLI:

```
oc apply -f kafka-connect-s2i.yaml
```

Verify the Kafka Connect instance has been created. It can take up to 5 minutes to become ready.

```
oc get kafkaconnects2i
```

Once ready, you can see the status and which connectors are available:

```
oc describe kafkaconnects2i <kafka_connect_name>
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

## Starting Kafka Connect with your connectors

Click **Next** at the bottom of the page. You can also access this page by clicking **Toolbox** in the primary navigation, scrolling to the **Connectors** section, and clicking **Start Kafka Connect** on the **Start Kafka Connect with your connectors** tile.

### Build Kafka Connect with your connectors

To add your connector JARs into your Kafka Connect environment, start a build using the directory you prepared:

```
oc start-build <kafka_connect_name>-connect --from-dir ./my-plugins/
```

Wait for the build to be marked complete and the Kafka Connect pod to become ready. It can take up to 2 minutes to complete.

```
oc get builds
oc get pods
```

Verify that your chosen connectors are installed in your Kafka Connect environment.

```
oc describe kafkaconnects2i <kafka_connect_name>
```

### Start a connector

Create a YAML file for the connector configuration. For the MQ connectors, you can use the {{site.data.reuse.short_name}} CLI to generate the YAML file. Alternatively, you can use the following template, taking care to replace `<kafka_connect_name>` with the name of the KafkaConnectS2I instance:

```
apiVersion: eventstreams.ibm.com/v1alpha1
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

Start the connector build applying the YAML file:

```
oc apply -f <connector_filename>.yaml
```

You can view the status of the connector by describing the custom resource:

```
oc describe kafkaconnector <connector_name>
```
